import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ManagerPermission {
  ManagerPermission() {}

  static Future<void> requestPermission(
      {required Permission permission}) async {
    final PermissionStatus status = await permission.status;
    if (status.isGranted) {
      debugPrint("Permission already granted");
    } else if (status.isDenied) {
      if (await permission.request().isGranted) {
        debugPrint("Permission granted");
      } else {
        debugPrint("Permission denied");
      }
    } else {
      debugPrint("Permission denied");
    }
  }

  static Future<void> requestMultiplePermissions(
      {required List<Permission> permissions}) async {
    final statusMap = await [...permissions].request();
    for (var item in statusMap.entries) {
      debugPrint(
          'PermissionStatus : ${(item.key as Permission).toString()} -> ${item.value}');
    }
  }

  static Future<bool> requesPermissionWithSettings() => openAppSettings();

  static Permission getPermissionForPhoto() =>
      Platform.isAndroid ? Permission.storage : Permission.photos;
}
