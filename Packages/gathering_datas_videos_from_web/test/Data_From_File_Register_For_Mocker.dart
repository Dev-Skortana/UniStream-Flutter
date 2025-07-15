class DataFromFileRegisterForMocker {
  static List<Map<String, dynamic>> GetDataTest() => [
        {
          "Name": "NameSiteA",
          "Url_Reference": "https://site.A",
          "Categories": {
            "Video_Film": {
              "Url": "https://site.A/urlvideofilm",
              "Types": {
                "Video_Film": ["Type_Video"]
              }
            },
            "Video_Serie": {
              "Url": "https://site.A/urlvideoserie",
              "Types": {
                "Video_Serie": ["Type_Video"]
              }
            }
          },
          "Titre": "req",
          "Description": "req",
          "Duree": "none",
          "Date_Parution": "req",
          "Type_Video": "req",
          "Lien_Affiche": "req",
          "Liste_Genres": "req",
          "Liste_Pays": "req",
          "Liste_Realisateurs": "req",
          "Saisons": "req",
          "Episodes": "req",
          "Studio_Animes": "req",
          "Extract_Saisons_On_Xpath": "regex",
          "Extract_Episodes_On_Xpath": "regex",
          "Extract_Duree_On_Xpath": "regex",
          "Identifiant": "IVJRFKIKJAYC"
        },
        {
          "Name": "NameSiteB",
          "Url_Reference": "https://site.B",
          "Categories": {
            "AllCategories": {
              "Url": "https://site.B/urlvideo",
              "Types": {
                "Video_Film": ["fType_Video"],
                "Video_Serie": ["sType_Video"]
              }
            }
          },
          "Titre": "req",
          "Description": "req",
          "Duree": "none",
          "Date_Parution": "req",
          "Type_Video": "req",
          "Lien_Affiche": "req",
          "Liste_Genres": "req",
          "Liste_Pays": "req",
          "Liste_Realisateurs": "req",
          "Saisons": "req",
          "Episodes": "req",
          "Studio_Animes": "req",
          "Extract_Saisons_On_Xpath": "regex",
          "Extract_Episodes_On_Xpath": "regex",
          "Extract_Duree_On_Xpath": "regex",
          "Identifiant": "OLKWYPMHGICP"
        },
        {
          "Name": "NameSiteC",
          "Url_Reference": "https://site.C",
          "Categories": {
            "Video_Serie": {
              "Url": "https://site.C/urlvideoserie",
              "Types": {
                "Video_Serie": ["Type_Video"]
              }
            }
          },
          "Titre": "req",
          "Description": "req",
          "Duree": "none",
          "Date_Parution": "req",
          "Type_Video": "req",
          "Lien_Affiche": "req",
          "Liste_Genres": "req",
          "Liste_Pays": "req",
          "Liste_Realisateurs": "req",
          "Saisons": "req",
          "Episodes": "req",
          "Studio_Animes": "req",
          "Extract_Saisons_On_Xpath": "regex",
          "Extract_Episodes_On_Xpath": "regex",
          "Extract_Duree_On_Xpath": "regex",
          "Identifiant": "QAHMMPDZHEVZ"
        }
      ];
}
