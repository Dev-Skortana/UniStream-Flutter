part of gathering_data_videos_from_web;

class GettingsValuesOrValue {
  static List getListOfOneOrManyValue(
      {required Element html_dom, required String requete_xpath}) {
    List list_results = List.empty(growable: true);
    late XPathResult values;
    try {
      values = html_dom.queryXPath(requete_xpath);
    } on Exception catch (exception) {
      print(exception);
    }
    if (values.nodes.isNotEmpty) {
      if (values.nodes.length > 1) {
        list_results = values.nodes.map((node) {
          return node.text;
        }).toList();
      } else {
        list_results = values.node!.text!.contains(",")
            ? values.node!.text!.split(",")
            : [values.node!.text];
      }
    }
    return list_results;
  }

  static List getListOfManyValueWithUsingRegex(
      {required Element html_dom,
      required String requete_xpath,
      required String requete_regex}) {
    List list_results = List.empty(growable: true);
    late XPathResult values;
    try {
      values = html_dom.queryXPath(requete_xpath);
    } on Exception catch (exception) {
      print(exception);
    }
    if (values.nodes.isNotEmpty) {
      for (XPathNode node in values.nodes) {
        RegExpMatch? result_on_regex = null;
        bool is_matched = false;
        final List<String> values_of_attributes_on_this_tag = [node.text!];
        if (node.attributes.containsKey("href")) {
          int length_in_value_href = node.attributes["href"]!.split("/").length;
          values_of_attributes_on_this_tag.add(node.attributes["href"]!.split(
              "/")[length_in_value_href > 1 ? length_in_value_href - 2 : 0]);
        }

        int index_fetch_values = 0;
        while (index_fetch_values < values_of_attributes_on_this_tag.length &&
            is_matched == false) {
          result_on_regex = RegExp(requete_regex, multiLine: true)
              .firstMatch(values_of_attributes_on_this_tag[index_fetch_values]);
          index_fetch_values += 1;
          if (result_on_regex != null) {
            is_matched = true;
          }
        }
        if (is_matched) {
          list_results.add(result_on_regex!.group(1));
        }
      }
    }
    return list_results;
  }
}
