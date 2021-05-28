import 'dart:io';

import 'package:chat_lb/screen/forgotPassword.dart';
import 'package:chat_lb/screen/home.dart';
import 'package:chat_lb/screen/registerFirst.dart';
import 'package:chat_lb/service/apiService.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/color.dart';
import 'package:chat_lb/util/string.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  final TargetPlatform platform;

  LoginPage({Key key, this.platform}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _textEmailController = TextEditingController();
  final _textPassController = TextEditingController();

  // Initially password is obscure
  bool _obscureText = true;
  bool _passwordVisible = false;
  String _errorEmailMessage = "";
  String _errorMessage = "";
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  void _toggle() {
    setState(() {
      _passwordVisible = !_passwordVisible;
      _obscureText = !_obscureText;
    });
  }

  Widget _entryFieldID() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textEmailController,
          obscureText: false,
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "メールアドレス",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Widget _entryFieldPass() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          controller: _textPassController,
          obscureText: _obscureText,
          style: TextStyle(color: Color(AppColors.primaryTextColor)),
          cursorColor: Color(AppColors.primaryColor),
          decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Color(AppColors.primaryColor),
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  _toggle();
                },
              ),
              fillColor: Colors.transparent,
              border: new UnderlineInputBorder(
                  borderSide:
                      new BorderSide(color: Color(AppColors.primaryColor))),
              hintText: "パスワード",
              hintStyle: TextStyle(color: Color(AppColors.hintTextColor)),
              filled: true)),
    );
  }

  Future<void> _login() async {
    final email = _textEmailController.text;
    final pass = _textPassController.text;
    final pushToken = await AppPrefs.share().getPushToken() ?? "";
    final params = {
      'email': email,
      'password': pass,
      'device_id': _deviceData['deviceId'],
      'device_type': _deviceData['deviceType'],
      'notification_token': pushToken,
    };
    try {
      EasyLoading.show();
      final response = await ApiService.login(params);
      setState(() {
        EasyLoading.dismiss();
        if (response.code == 200) {
          AppPrefs.share().saveToken(response.data.token);
          AppPrefs.share().saveUser(response.data);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        platform: widget.platform,
                      )),
              (route) => false);
        } else {
          _errorMessage = response.message ?? Strings.systemError;
        }
      });
    } catch (e) {
      setState(() {
        EasyLoading.dismiss();
        _errorMessage = Strings.systemError;
      });
    }
  }

  Widget _submitButton() {
    return FlatButton(
      onPressed: () {
        _errorMessage = "";
        _errorEmailMessage = "";
        _login();
      },
      padding: EdgeInsets.only(left: 32, right: 32, top: 12, bottom: 12),
      child: Text("ログイン",
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

  _gotoForgotPassword() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ForgotPasswordPage(
                  platform: widget.platform,
                )));
  }

  Widget _forgotPassword() {
    return InkWell(
        onTap: () {
          _gotoForgotPassword();
        },
        child: Container(
          alignment: Alignment.center,
          child: RichText(
            text: TextSpan(
              text: 'パスワードを忘れた場合は',
              style: TextStyle(
                  fontSize: 14, color: Color(AppColors.primaryTextColor)),
              children: <TextSpan>[
                TextSpan(
                    text: 'こちら',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue)),
              ],
            ),
          ),
        ));
  }

  _gotoRegister() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => RegisterFirstPage(
                  platform: widget.platform,
                )),
        (route) => false);
  }

  Widget _createUser() {
    return InkWell(
      onTap: () {
        _gotoRegister();
      },
      child: Container(
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            text: '新規アカウント作成は',
            style: TextStyle(
                fontSize: 14, color: Color(AppColors.primaryTextColor)),
            children: <TextSpan>[
              TextSpan(
                  text: 'こちら',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoTitle() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        "ログイン",
        style:
            TextStyle(fontSize: 24, color: Color(AppColors.primaryTextColor)),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryFieldID(),
        _errorEmailView(),
        _entryFieldPass(),
        _errorPasswordView()
      ],
    );
  }

  Widget _errorEmailView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _errorEmailMessage.isNotEmpty
          ? Text(
              _errorEmailMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(AppColors.errorTextColor), fontSize: 14),
            )
          : null,
    );
  }

  Widget _errorPasswordView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: _errorMessage.isNotEmpty
          ? Text(
              _errorMessage,
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
    // TODO: implement initState
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
                    SizedBox(height: 20),
                    _forgotPassword(),
                    SizedBox(height: 10),
                    _createUser()
                  ],
                ),
              ),
            )));
  }
}
