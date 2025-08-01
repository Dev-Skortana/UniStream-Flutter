import 'package:flutter/material.dart';

class ViewSiteStreamRegister extends StatefulWidget {
  const ViewSiteStreamRegister({super.key});

  @override
  State<ViewSiteStreamRegister> createState() => ViewSiteStreamRegisterState();
}

class ViewSiteStreamRegisterState extends State<ViewSiteStreamRegister> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Champs ci-dessous à remplir, concerne directement le site :",
                  textAlign: TextAlign.center,
                )
              ],
            ),
            Row(),
            Row(),
            Row(
              children: [
                Text("Nom du site (sans l'hebergeur,le domaine etc) :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    decoration: InputDecoration(constraints: BoxConstraints()),
                    key: Key("Name"),
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text("L'url de base du site :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Url_Reference"),
                  ),
                )
              ],
            ),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    """Ci-dessous, selectionner via case à cocher le/les catégories de vidéos que le site propose puis saisissez pour chaque catégorie l'url pointant vers le catalogue contenant les videos de la catégorie.\n
                       Dans le cas ou l'url pointe vers le catalogue affichent des videos des deux catégories, selectionner 'AllCategories' puis saisissez l'url menant au catalogue.""",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Row(
              key: Key("AllCategories"),
              spacing: 5,
              children: [
                Checkbox(key: GlobalKey(), value: false, onChanged: (value) {}),
                Text("-> L'url (Toutes catégories) :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: GlobalKey(),
                    onChanged: (value) {},
                    enabled: false,
                  ),
                )
              ],
            ),
            Row(
              key: Key("Video_Film"),
              children: [
                Checkbox(key: GlobalKey(), value: false, onChanged: (value) {}),
                Text("-> L'url (Catégories Film) :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: GlobalKey(),
                    enabled: false,
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              key: Key("Video_Serie"),
              children: [
                Checkbox(key: GlobalKey(), value: false, onChanged: (value) {}),
                Text("-> L'url (Catégories Serie) :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: GlobalKey(),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Requetes Xpath qui sera appliquer sur le site :",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Les requetes à saisir ci-dessous seront utiliser sur la page catalogue du site :",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Row(),
            Row(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Les Titres :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Titre"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Les affiches :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Lien_Affiche"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Les liens des vidéos du catalogue :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Req_Links_Videos"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Dernier page du catalogue ::"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Req_Num_Page_Max"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Les requetes suivantes ci-dessous seront utiliser sur la page de présentation de la vidéo",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Row(),
            Row(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Type de la vidéo (catégorie de la video) :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Type_Video"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Description :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Description"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Date parution :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Date_Parution"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Durée :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Duree"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Genres :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Liste_Genres"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Pays :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Liste_Pays"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Réalisateurs :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Liste_Realisateurs"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Saisons  :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Saisons"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Episodes :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Episodes"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Studio d'animations :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Studio_Animes"),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Les regex a saisir en dessous, serviront à extraire de façon plus précis les champs concerner :",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    "Ci-dessous, saisissez les regex qui seront utilisez sur les informations extraite à partir du catalogue",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Row(),
            Row(),
            Row(
              children: [
                Text("Pour la capture des numéros de saison :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Extract_Saisons_On_Xpath"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text("Pour la capture des numéros d'épisode"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Extract_Episodes_On_Xpath"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Pour la capture de la durée (temps de durée de la vidéo) :"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Extract_Duree_On_Xpath"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Saisissez l'url pointant vers une page du catalogue (en mettant cette fois la parametre page[le mot page avec sa valeur ])"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Deduction_FormatPagination"),
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Saisissez le type de video que le site propose (Drama,Anime,Serie,Film) [dans le cas que le site propose des videos autres que des Dramas/Animes saisissez Serie ou Film] :"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Value_Type_Video"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            Row(),
            Row(),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Les champs suivants, serviront à utliser le site enregistrer afin de distribuer les liens de visionnage (optionnel)."),
                ],
              ),
            ),
            Row(),
            Row(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Choisissez, parmis la liste la forme des saisons/épisodes que le site montre :"),
                  DropdownMenu(
                    key: Key("SelectPanelsLinks"),
                    hintText: "Choisissez une affirmation parmis la liste.",
                    dropdownMenuEntries: <DropdownMenuEntry>[
                      DropdownMenuEntry(
                          value:
                              "HavePanelLinksSaisons_And_HavePanelLinksEpisodes",
                          label:
                              "Sur ce site les saisons et épisodes sont sous forme de lien"),
                      DropdownMenuEntry(
                          value:
                              "HavePanelLinksSaisons_And_DontHavePanelLinksEpisodes",
                          label:
                              "Sur ce site les saisons sont sous forme de lien mais pas les épisodes"),
                      DropdownMenuEntry(
                          value:
                              "DontHavePanelLinksSaison_And_HavePanelLinksEpisodes",
                          label:
                              "Sur ce site les épisodes sont sous forme de lien mais pas les saisons"),
                      DropdownMenuEntry(
                          value:
                              "DontHavePanelLinksSaisons_And_DontHavePanelLinksEpisodes",
                          label:
                              "Sur ce site les saisons et episodes ne sont pas sous forme de lien")
                    ],
                    onSelected: (value) {},
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Question ! -> Lors de la recherche, en saisissant un titre les resultats sont ils sur la meme page ? (si oui cochez la case) "),
                  Checkbox(
                      key: Key(
                          "IsResultOFSearchOnSamePageThatPageContainsEntry"),
                      value: false,
                      onChanged: (value) {}),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Pour la capture des saisons (saisissez si ils sont en forme de liens)"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Regex_Saisons"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Pour la capture des episodes (saisissez si ils sont en forme de liens)"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Regex_Episodes"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Text("Pour la requete du bouton 'Accepter cookie'"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Req_Button_That_AcceptCookie"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text("Pour la requete de la zone de recherche :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Req_Entry_Field_Search"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Pour la requete du bouton de recherche (si la case du dessus est cocher ne saisissez rien !) :"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Req_Button_Search"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text("Pour la requete des liens resultant de la recherche :"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Req_Links_In_Results_Of_Search"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Pour la requete des titres resultant de la recherche :"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Req_Title_In_Results_Of_Search"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                      "Pour la requete du lien du film (si le site en propose):"),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      key: Key("Req_Link_Of_Movie_On_Video"),
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Text("Pour la requete de la saison (si le site en propose) :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Req_Links_Of_Saisons_On_Video"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(
              children: [
                Text("Pour la requete de l'épisode (si le site en propose) :"),
                SizedBox(
                  width: 80,
                  child: TextField(
                    key: Key("Req_Episode_On_Video"),
                    onChanged: (value) {},
                  ),
                )
              ],
            ),
            Row(),
            Row(),
            Row(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () {}, child: Text("Simulation.")),
                TextButton(
                    onPressed: () {}, child: Text("Generer les templates."))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
