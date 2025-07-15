library gathering_urls_videos_from_web;

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gathering_urls_videos_from_web/Services/Automation/Browser_Automation.dart'
    as au;
import 'package:logger/logger.dart';

import 'package:async_locks/async_locks.dart';

import 'package:html/parser.dart';
import 'package:xpath_selector_html_parser/src/ext.dart';
import 'package:html/dom.dart' as html;

import 'package:meta/meta.dart';

import 'package:gathering_urls_videos_from_web/Helpers/Enumerations/Enumeration_Panels_Links.dart';

import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_ButtonSearch.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Episode_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_For_Data_Mandatory.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Movie_Video.dart';
import 'package:gathering_urls_videos_from_web/Services/Collect_Urls_On_Web/Interfaces/IRequest_Saison_Video.dart';

import 'dart:math';

import 'dart:convert';
import 'package:flutter/services.dart';

import 'dart:io';

import 'package:xpath_selector/xpath_selector.dart';

import 'package:puppeteer/puppeteer.dart';

part 'Logging/Manager_Logging.dart';
part 'Helpers/Managers_Gatherings/Manager_Html_Dom.dart';
part 'Helpers/Using_Dictionnary/Use_Dictionnary_Url_ObjectAcess.dart';
part 'Services/Collect_Urls_On_Web/Classe_Base/Gathering_Urls.dart';
part 'Services/Collect_Urls_On_Web/Classes/Acces_Of_Page_On_papadustream.dart';
part 'Services/Collect_Urls_On_Web/Classes/Acces_Of_Page_On_vostfree.dart';
part 'Services/Collect_Urls_On_Web/Classes/Acces_Of_Page_On_v6voiranime.dart';
part 'Services/Collect_Urls_On_Web/Classes/Acces_Of_Page_On_voirdrama.dart';
part 'Services/Collect_Urls_On_Web/Classes/Acces_Of_Pages_On_animesama.dart';
part 'Helpers/Builder_Identifiants.dart';
part 'Services/Manipulate_Json_File/Manipulate_Json_File_Redirect.dart';
part 'Services/Manipulate_Json_File/Manip_Json_File_Read.dart';
part 'Services/Manipulate_Json_File/Manip_Json_File_Update.dart';
part 'Helpers/Gettings_Values_Or_Value.dart';
part 'Data_Json_Into_Object/Register_Data.dart';
part 'Data_Json_Into_Object/Register_Meta_Data.dart';
part 'Main/Manager_Gathering_Data.dart';
