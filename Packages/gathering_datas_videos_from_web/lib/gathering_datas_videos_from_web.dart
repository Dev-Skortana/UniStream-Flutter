library gathering_data_videos_from_web;

//import 'package:flutter/cupertino.dart';

import 'dart:ffi';

import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Helpers/Builder_Librairys_Scrapings.dart';
import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Helpers/Object_Selector.dart';
import 'package:gathering_datas_videos_from_web/Services/Managements/Scrape_Saisons_Episodes/Interface/ILibrairy_Scrape.dart';
import 'package:logger/logger.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as test;
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:puppeteer/protocol/css.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';
import 'package:path/path.dart' as path;

import 'package:html/parser.dart';
import 'package:xpath_selector_html_parser/src/ext.dart';

import 'package:gathering_datas_videos_from_web/Services/Collect_Data_On_Web/Interfaces/IRequest_For_Data_Mandatory.dart';
import 'package:gathering_datas_videos_from_web/Services/Collect_Data_On_Web/Interfaces/IRequest_Saison_Video.dart';
import 'package:html/dom.dart';

import 'package:puppeteer/puppeteer.dart';

import 'dart:convert';
import 'dart:io';

import 'dart:math';

import 'package:flutter/material.dart' as flutter_type;
import 'package:async_locks/async_locks.dart';

import 'package:collection/collection.dart';

import 'package:intl/intl.dart';

part 'Logging/Manager_Logging.dart';
part 'Main/Manager_Gathering_Data.dart';
part 'Services/Collect_Data_On_Web/Classe_Base/Acces.dart';
part 'Helpers/Managers_Gatherings/Manager_Html_Dom.dart';
part 'Helpers/Managers_Gatherings/Manager_Playwright.dart';
part 'Services/Collect_Data_On_Web/Interfaces/IScrape_Data.dart';
part 'Services/Collect_Data_On_Web/Classes/Acces_Of_Page_On_v6voiranime.dart';
part 'Services/Collect_Data_On_Web/Classes/Acces_Of_Page_On_papadustream.dart';
part 'Services/Collect_Data_On_Web/Classes/Acces_Of_Page_On_voirdrama.dart';
part 'Services/Collect_Data_On_Web/Classes/Acces_Of_Page_On_vostfree.dart';
part 'Services/Collect_Data_On_Web/Classes/Acces_Of_Pages_On_animesama.dart';
part 'Services/Managements/Scrape_Saisons_Episodes/Manager_Seasons_And_Their_Episodes.dart';
part 'Services/Manipulate_Json_File/Manip_Json_File_Update.dart';
part 'Services/Manipulate_Json_File/Manip_Json_File_Read.dart';
part 'Services/Manipulate_Json_File/Manipulate_Json_File_Register.dart';
part 'Helpers/Builder_Identifiants.dart';
part 'Helpers/Enumerations/Enumeration_Categorie_Video.dart';
part 'Helpers/Enumerations/Enumeration_FullType_Video.dart';
part 'Helpers/Enumerations/Enumeration_Librairy_Gathering.dart';
part 'Helpers/Using_Dictionnary/Use_Dictionnary_Categorie_Urlpage.dart';
part 'Helpers/Using_Dictionnary/Use_Dictionnary_Url_ObjectAcess.dart';
part 'Data_Json_Into_Object/Register_Data.dart';
part 'Data_Json_Into_Object/Register_Meta_Data.dart';
part 'Helpers/Gettings_Values_Or_Value.dart';
part 'Helpers/Manager_Convert_Duration_To_Time.dart';
