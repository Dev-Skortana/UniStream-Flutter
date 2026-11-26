import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:unistream/Views/Templates/Bouton_Theme.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ViewWatchvideo extends StatefulWidget {
  final String UrlSiteVideo;
  final String RequestEpisode;
  final String episode_into_caracteres;

  const ViewWatchvideo(
      {super.key,
      required this.UrlSiteVideo,
      this.RequestEpisode = "",
      this.episode_into_caracteres = ""});

  @override
  State<ViewWatchvideo> createState() => _ViewWatchvideoState();
}

class _ViewWatchvideoState extends State<ViewWatchvideo> {
  late final String nameSite;

  /// Domaine du site de lecture (« anime-sama.to », « vostfree.ws »…).
  /// Seule la page PRINCIPALE est limitée à ce domaine : les lecteurs vidéo
  /// sont dans des iframes hébergées ailleurs et restent autorisés.
  late final String _domaineAutorise;

  /// Nullable : la WebView peut être détruite avant d'avoir été créée,
  /// et on le remet à null dans dispose() pour bloquer tout appel tardif.
  InAppWebViewController? _webViewController;

  /// La sélection de l'épisode ne se fait qu'une fois : onLoadStop est
  /// rappelé à chaque navigation (y compris celle que provoque la sélection).
  bool _episodeSelectionne = false;

  /// Régies publicitaires bloquées (mêmes motifs que Browser_Automation.dart).
  static final List<ContentBlocker> _bloqueursPub = [
    r".*\.cfd/.*",
    r".*\.qpon/.*",
    r".*\.cyou/.*",
    r".*acscdn\.com/.*",
    r".*doubleclick\.net/.*",
    r".*googlesyndication\.com/.*",
    r".*chagnougroalry\.net/.*",
  ]
      .map((motif) => ContentBlocker(
          trigger: ContentBlockerTrigger(urlFilter: motif),
          action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK)))
      .toList();

  @override
  void initState() {
    super.initState();
    nameSite = Uri.tryParse(widget.UrlSiteVideo)?.host ?? widget.UrlSiteVideo;
    final List<String> labels = nameSite.split(".");
    _domaineAutorise = labels.length >= 2
        ? labels.sublist(labels.length - 2).join(".")
        : nameSite;
  }

  @override
  void dispose() {
    // Le widget InAppWebView détruit LUI-MÊME son contrôleur : l'appeler ici
    // une deuxième fois provoquait « used after being disposed ».
    _webViewController = null;
    super.dispose();
  }

  bool _estSurLeSite(Uri? url) {
    if (url == null) return false;
    final String host = url.host;
    return host == _domaineAutorise || host.endsWith(".$_domaineAutorise");
  }

  /// Bloque les redirections publicitaires de la page principale
  /// (ex. anime-sama → luugy.com → hype-cult.com dans ton log).
  Future<NavigationActionPolicy> _filtrerNavigation(
      InAppWebViewController controller, NavigationAction action) async {
    final Uri? url = action.request.url;
    final String scheme = url?.scheme ?? "";

    // intent://, market://, tel:… : ouvrir une autre appli = toujours une pub
    if (scheme != "http" && scheme != "https") {
      debugPrint("[Lecture] bloqué (schéma $scheme) : $url");
      return NavigationActionPolicy.CANCEL;
    }
    // Iframes (lecteurs vidéo hébergés ailleurs) : autorisées
    if (!action.isForMainFrame) return NavigationActionPolicy.ALLOW;
    // Page principale : seulement le site de lecture
    if (_estSurLeSite(url)) return NavigationActionPolicy.ALLOW;

    debugPrint("[Lecture] redirection bloquée vers ${url?.host}");
    return NavigationActionPolicy.CANCEL;
  }

  /// Retour : on remonte d'abord l'historique de la WebView,
  /// et on ne quitte l'écran que lorsqu'il est vide.
  Future<void> _gererRetour() async {
    final InAppWebViewController? controller = _webViewController;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _selectEpisodeIfNeeded() async {
    if (_episodeSelectionne || widget.RequestEpisode.isEmpty) return;
    final InAppWebViewController? controller = _webViewController;
    if (!mounted || controller == null) return;
    _episodeSelectionne = true;

    final String script;
    if (widget.RequestEpisode
        .contains(RegExp("(select[.+]/|/select|//select)"))) {
      final List<String> morceaux = widget.RequestEpisode.split("/");
      final String xpathSelect = "//${morceaux[morceaux.length - 2]}";
      final int index = (int.tryParse(widget.episode_into_caracteres) ?? 1) - 1;
      script = """
        (function() {
          var select = document.evaluate(${jsonEncode(xpathSelect)}, document, null,
              XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
          if (!select) return false;
          select.selectedIndex = $index;
          select.dispatchEvent(new Event('change', { bubbles: true }));
          return true;
        })();
      """;
    } else {
      script = """
        (function() {
          var el = document.evaluate(${jsonEncode(widget.RequestEpisode)}, document, null,
              XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
          if (!el) return false;
          el.click();
          return true;
        })();
      """;
    }

    try {
      final dynamic ok = await controller.evaluateJavascript(source: script);
      if (ok != true) {
        debugPrint("[Lecture] épisode introuvable dans la page "
            "(${widget.RequestEpisode})");
      }
    } catch (e) {
      // L'écran a pu être quitté pendant l'exécution du script.
      debugPrint("[Lecture] sélection de l'épisode impossible : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // le bouton Retour est géré par _gererRetour
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _gererRetour();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text("Visionnage sur $nameSite"),
            centerTitle: true,
            actions: const [BoutonTheme()],
          ),
          body: InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                // Les pop-ups sont la 1re source de pubs : on les refuse.
                javaScriptCanOpenWindowsAutomatically: false,
                supportMultipleWindows: false,
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                contentBlockers: _bloqueursPub,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              shouldOverrideUrlLoading: _filtrerNavigation,
              onLoadStop: (controller, url) async {
                await Future.delayed(const Duration(milliseconds: 100));
                if (!mounted) return; // écran quitté pendant l'attente
                await _selectEpisodeIfNeeded();
              },
              initialUrlRequest:
                  URLRequest(url: WebUri(widget.UrlSiteVideo)))),
    );
  }
}