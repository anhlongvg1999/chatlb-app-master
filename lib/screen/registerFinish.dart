import 'dart:io';

import 'package:chat_lb/screen/home.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RegisterFinishPage extends StatefulWidget {
  final TargetPlatform platform;
  final String email;

  RegisterFinishPage({Key key, this.platform, this.email}) : super(key: key);

  @override
  _RegisterFinishPageState createState() => _RegisterFinishPageState();
}

class _RegisterFinishPageState extends State<RegisterFinishPage> {
  final _textPasswordController = TextEditingController();
  final _textConfirmPasswordController = TextEditingController();

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  String _errorPasswordMessage = "";
  String _errorConfirmMessage = "";

  Widget _entryFieldPassword() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textPasswordController,
          obscureText: true,
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "パスワード",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Widget _entryFieldConfirmPassword() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textConfirmPasswordController,
          obscureText: true,
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "パスワード（確認）",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Future<void> _registerUser() async {
    try {
      final password = _textPasswordController.text;
      final confirmPassword = _textConfirmPasswordController.text;
      if (!password.isValidPassword()) {
        _errorPasswordMessage = Strings.passwordWrongFormat;
        _errorConfirmMessage = "";
        return;
      }
      if (!confirmPassword.isValidPassword()) {
        _errorConfirmMessage = Strings.passwordWrongFormat;
        _errorPasswordMessage = "";
        return;
      }
      if (password != confirmPassword) {
        _errorConfirmMessage = Strings.passwordNotMath;
        _errorPasswordMessage = "";
        return;
      }
      EasyLoading.show();
      final email = this.widget.email;
      final pass = password;
      final pushToken = await AppPrefs.share().getPushToken() ?? "";
      final params = {
        'email': email,
        'password': pass,
        'device_id': _deviceData['deviceId'],
        'device_type': _deviceData['deviceType'],
        'notification_token': pushToken,
      };
      final response = await ApiService.registerStep2(params);
      setState(() {
        EasyLoading.dismiss();
        if (response.code == 200) {
          AppPrefs.share().saveToken(response.data.token);
          AppPrefs.share().saveUser(response.data);
          AppPrefs.share().savePassword(pass);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomePage(
                        platform: widget.platform,
                      )),
                  (route) => false);
        } else {
          _errorPasswordMessage = response.message ?? Strings.systemError;
        }
      });
    } catch (e) {
      _errorPasswordMessage =  Strings.systemError;
    }
  }

  Widget _submitButton() {
    return FlatButton(
      onPressed: () {
        _errorPasswordMessage = "";
        _registerUser();
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("登録完了",
          style: TextStyle(color: Color(AppColors.primaryTextColor))),
      textColor: Color(AppColors.primaryTextColor),
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Color(AppColors.primaryColor),
              width: 1,
              style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _logoTitle() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "パスワード設定",
        style:
            TextStyle(fontSize: 24, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryFieldPassword(),
        _errorPasswordView(),
        _entryFieldConfirmPassword(),
        _errorConfirmView()
      ],
    );
  }

  Widget _errorPasswordView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _errorPasswordMessage.isNotEmpty
          ? Text(
              _errorPasswordMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.errorTextColor), fontSize: 14),
            )
          : null,
    );
  }

  Widget _errorConfirmView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _errorConfirmMessage.isNotEmpty
          ? Text(
              _errorConfirmMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.errorTextColor), fontSize: 14),
            )
          : null,
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'deviceId': build.androidId,
      'systemFeatures': build.systemFeatures,
      'deviceType': 'android'
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'deviceId': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
      'deviceType': 'iOs'
    };
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text("アカウント"),
          centerTitle: true,
        ),
        body: Container(
            height: height,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _logoTitle(),
                    SizedBox(height: 30),
                    _emailPasswordWidget(),
                    SizedBox(height: 20),
                    _submitButton(),
                  ],
                ),
              ),
            )));
  }
}
