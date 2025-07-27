import 'package:flutter/material.dart';

abstract class ParametersGetLinkwatchs {
  late Map<String, dynamic> mapParametersData;

  ParametersGetLinkwatchs() {
    this.mapParametersData = {};
  }

  void preparedParameters() {
    this.preparedParametersData();
  }

  @protected
  void preparedParametersData();
}
