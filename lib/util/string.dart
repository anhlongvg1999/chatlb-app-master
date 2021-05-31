class Strings {
  static String appName = "クロスch!";
  static String login = "ログイン";
  static String id = "ID";
  static String pass = "PASS";
  static String ok = "OK";
  static String cancel = "Cancel";
  static String send = "送信";
  static String hintChat = "Aa";
  static String logoutMessage = "ログアウトしてもよろしいですか？";
  static String logout = "ログアウト";
  static String cancelJP = "キャンセル";
  static String systemError = "システムエラーになりました。";
  static String downloadSuccess = "保存しました";
  static String downloadFailed = "保存できませんでした";
  static String downloadFolder = "ChatLP";
  static String canNotOpenLink = "Could not launch";
  static String pleaseInputEmail = "正しいメールアドレスを入力してください。";
  static String pleaseInputPassword = "正しいパスワードを入力してください。";
  static String passwordNotMath = "確認パスワードに誤りがあります。";
  static String noInputEmail = "メールアドレスを入力して下さい";
  static String wrongPassword = "現在のパスワードに誤りがあります。";
  static String passwordWrongFormat = "半角英数字で入力して下さい。";

  static String loginTitle = "アカウント";
}

class Events {
  static String authentication = "authentication";
  static String sendMessage = "send_message";
  static String receiveMessage = "receive_message";
  static String confirmRegisterEmail = "confirm_register_email";
  static String confirmChangeEmail = "confirm_update_email";
}

class Const {
  static final debug = true;
}


extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
          r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$')
        .hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(r'(^[a-zA-Z0-9]+$)')
        .hasMatch(this);
  }
}