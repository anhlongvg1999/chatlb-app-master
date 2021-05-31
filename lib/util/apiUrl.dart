class ApiURL {
  static final API = "https://chatlp-server.herokuapp.com/";
  static final SOCKET = "https://chatlp-server.herokuapp.com";
  // static final API = "http://api.wes-jsc.com/";
  // static final SOCKET = "http://api.wes-jsc.com";
  static final LOGIN = API + "api/app/auth/login";
  static final SIGNUP = API + "api/app/auth/signup";
  static final SIGNUP2 = API + "api/app/auth/signup2";
  static final FORGOT = API + "api/app/auth/forgot";
  static final LOGOUT = API + "api/app/auth/logout";
  static final ME = API + "api/app/user/me";
  static final MESSAGES = API + "api/app/message";
  static final TOPIC = API + "api/app/topic";
  static final SUBSCRIBE = API + "api/app/topic/subscribe";
  static final UPLOAD = API + "api/common/uploads/file";
  static final UPDATE_RECEIVE_NOTIFICATION = API + "api/app/topic/receive-notification";
  static final UPDATE_USER = API + "api/app/user/update";
  static final NAVIGATE = API + "api/app/navigation";
  static final CLICK_MESSAGE = API + "api/app/message/click";
  static final RECEIVE_MESSAGE = API + "api/app/message/receive";
  static final QRCODE = API + "api/app/topic/qrcode";
  static final CONFIRM_REGISTER = API + "api/app/auth/user-confirm-register";
  static final UNREAD_NUMBER = API + "api/app/user/unread";
}