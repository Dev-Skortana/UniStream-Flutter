import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unistream/Services/Features/Search_Data/Enumeration/Enumerations_Methodes_Recherches.dart';

import 'Set_Search.dart';

class ManagerSetSearch {
  late SetSearch setOfSearch;

  ManagerSetSearch(this.setOfSearch) {}

  bool EvaluateCondition(
      Iterable<dynamic> set_data__would_include_valuesearch) {
    set_data__would_include_valuesearch =
        set_data__would_include_valuesearch.takeWhile((data) => data != null);
    Map<Enum, bool Function(Object)> map_methodesearch_condition = {
      EnumerationsMethodesRecherches.Superieure: this._filterBySuperior,
      EnumerationsMethodesRecherches.Inferieure: this._filterByLower,
      EnumerationsMethodesRecherches.Egale: this._filterByEqual,
      EnumerationsMethodesRecherches.Commence: this._filterByBegin,
      EnumerationsMethodesRecherches.Contient: this._filterByContains,
      EnumerationsMethodesRecherches.Fini: this._filterByFinished,
      EnumerationsMethodesRecherches.Fourchette: this._filterByFork
    };

    final bool Function(Object) filter_to_apply =
        map_methodesearch_condition[this.setOfSearch.methodeRecherche]!;

    if (filter_to_apply == this._filterBySuperior &&
        set_data__would_include_valuesearch is List) {
      return set_data__would_include_valuesearch[0]
          .toString()
          .trim()
          .toUpperCase()
          .contains(this.setOfSearch.valueOfSearch.toString().toUpperCase());
    } else {
      return set_data__would_include_valuesearch
          .any((element) => filter_to_apply(element));
    }
  }

  bool _filterBySuperior(Object item) {
    if (this.setOfSearch.valueOfSearch is DateTime) {
      final DateTime valueOfSearch_date =
          this.setOfSearch.valueOfSearch as DateTime;
      final DateTime item_datetime = item as DateTime;
      return item_datetime.isAfter(valueOfSearch_date);
    }
    if (this.setOfSearch.valueOfSearch is TimeOfDay) {
      final TimeOfDay valueofsearch_time =
          (this.setOfSearch.valueOfSearch as TimeOfDay);
      final TimeOfDay item_time = (item as TimeOfDay);

      final int minutes_valueofsearch =
          valueofsearch_time.hour * 60 + valueofsearch_time.minute;
      final int minutes_item = item_time.hour * 60 + item_time.minute;

      return minutes_item >= minutes_valueofsearch;
    }

    return double.parse(item.toString()) >=
        double.parse(this.setOfSearch.valueOfSearch.toString());
  }

  bool _filterByLower(Object item) {
    if (this.setOfSearch.valueOfSearch is DateTime) {
      final DateTime valueOfSearch_date =
          this.setOfSearch.valueOfSearch as DateTime;
      final DateTime item_datetime = item as DateTime;
      return item_datetime.isBefore(valueOfSearch_date);
    }

    if (this.setOfSearch.valueOfSearch is TimeOfDay) {
      final TimeOfDay valueofsearch_time =
          (this.setOfSearch.valueOfSearch as TimeOfDay);
      final TimeOfDay item_time = (item as TimeOfDay);

      final int minutes_valueofsearch =
          valueofsearch_time.hour * 60 + valueofsearch_time.minute;
      final int minutes_item = item_time.hour * 60 + item_time.minute;

      return minutes_item <= minutes_valueofsearch;
    }

    return double.parse(item.toString()) <=
        double.parse(this.setOfSearch.valueOfSearch.toString());
  }

  bool _filterByEqual(Object item) {
    final item_to_compare = this.setOfSearch.valueOfSearch is String
        ? item.toString().trim().toUpperCase()
        : item;
    final value_search = this.setOfSearch.valueOfSearch is String
        ? (this.setOfSearch.valueOfSearch as String).trim().toUpperCase()
        : this.setOfSearch.valueOfSearch;
    return item_to_compare as dynamic == value_search as dynamic;
  }

  bool _filterByBegin(Object item) {
    return (item as String).trim().toUpperCase().startsWith(
        (this.setOfSearch.valueOfSearch as String).trim().toUpperCase());
  }

  bool _filterByContains(Object item) {
    return (item as String).trim().toUpperCase().contains(
        (this.setOfSearch.valueOfSearch as String).trim().toUpperCase());
  }

  bool _filterByFinished(Object item) {
    return (item as String).trim().toUpperCase().endsWith(
        (this.setOfSearch.valueOfSearch as String).trim().toUpperCase());
  }

  bool _filterByFork(Object item) {
    if (this.setOfSearch.valueOfSearch is DateTime) {
      final DateTime valueOfSearch_main_date =
          this.setOfSearch.valueOfSearch as DateTime;

      final DateTime valueOfSearch_second_date =
          this.setOfSearch.valueOfSearchSecondary as DateTime;

      final DateTime item_datetime = item as DateTime;
      return (item_datetime.isAfter(valueOfSearch_main_date) ||
              item_datetime.isAtSameMomentAs(valueOfSearch_main_date)) &&
          (item_datetime.isBefore(valueOfSearch_second_date) ||
              item_datetime.isAtSameMomentAs(valueOfSearch_second_date));
    }

    if (this.setOfSearch.valueOfSearch is TimeOfDay) {
      final TimeOfDay valueofsearch_main_time =
          (this.setOfSearch.valueOfSearch as TimeOfDay);

      final TimeOfDay valueOfSearch_second_time =
          (this.setOfSearch.valueOfSearch as TimeOfDay);

      final int minutes_valueofsearch_main =
          valueOfSearch_second_time.hour * 60 +
              valueOfSearch_second_time.minute;

      final int minutes_valueofsearch_second =
          valueofsearch_main_time.hour * 60 + valueofsearch_main_time.minute;

      final TimeOfDay item_time = (item as TimeOfDay);
      final int minutes_item = item_time.hour * 60 + item_time.minute;

      return minutes_item >= minutes_valueofsearch_main &&
          minutes_item <= minutes_valueofsearch_second;
    }

    return double.parse(item.toString()) >=
            double.parse(this.setOfSearch.valueOfSearch.toString()) &&
        double.parse(item.toString()) <=
            double.parse(this.setOfSearch.valueOfSearchSecondary.toString());
  }
}
