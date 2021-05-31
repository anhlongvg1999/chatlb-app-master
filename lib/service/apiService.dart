import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:chat_lb/model/apiResponse.dart';
import 'package:chat_lb/model/pageMessageModel.dart';
import 'package:chat_lb/model/pageNavigateModel.dart';
import 'package:chat_lb/model/pageTopicModel.dart';
import 'package:chat_lb/model/topicModel.dart';
import 'package:chat_lb/model/unreadResponse.dart';
import 'package:chat_lb/model/uploadResponse.dart';
import 'package:chat_lb/model/userModel.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/apiUrl.dart';
import 'package:chat_lb/util/string.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  static Future<ApiResponse<UserModel>> login(Map params) async {
    try {
      final json = jsonEncode(params);
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final response =
          await http.post(ApiURL.LOGIN, headers: header, body: json);
      print('login: ' + ApiURL.LOGIN + " params: " + json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('login: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
      return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse<PageMessageModel>> getChatHistory(
      String topicId, int page,
      {int size = 10}) async {
    try {
      Map<String, String> queryParams = {
        'topic_id': topicId,
        'page': page.toString(),
        'perPage': size.toString()
      };
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final url =
          ApiURL.MESSAGES + "?" + Uri(queryParameters: queryParams).query;
      print('history url: ' + url);
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('history: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
      return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> logout() async {
    try {
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final response = await http.post(ApiURL.LOGOUT, headers: header);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('logout: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<UploadResponse> uploadFile(File file) async {
    try {
      final token = await AppPrefs.share().getToken();
      var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
      var length = await file.length();

      var uri = Uri.parse(ApiURL.UPLOAD);

      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile('files', stream, length,
          filename: basename(file.path));
      //contentType: new MediaType('image', 'png'));
      request.headers['Authorization'] = "Bearer $token";
      request.files.add(multipartFile);
      var response = await request.send();
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.

        var responseByteArray = await response.stream.toBytes();
        final jsonBody = json.decode(utf8.decode(responseByteArray));
        print('upload file: ' + jsonEncode(jsonBody));
        return UploadResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return UploadResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return UploadResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse<UserModel>> me() async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final response = await http.get(ApiURL.ME, headers: header);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('me: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> updateUser(Map params) async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final json = jsonEncode(params);
      print('update user params: ' + json);
      final response = await http.put(ApiURL.UPDATE_USER, headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('update user success: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> updateNotificationToken() async {
    try {
      final token = await AppPrefs.share().getToken();
      final pushToken = await AppPrefs.share().getPushToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      Map<String, String> params = {'notification_token': pushToken};
      final json = jsonEncode(params);
      final response = await http.put(ApiURL.UPDATE_USER, headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> updateReceiveNotification(Map params) async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final json = jsonEncode(params);
      print('updateReceiveNotification: ' + jsonEncode(json));
      final response = await http.put(ApiURL.UPDATE_RECEIVE_NOTIFICATION, headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('updateReceiveNotification: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> registerFirst(Map params) async {
    try {
      final json = jsonEncode(params);
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final response =
          await http.post(ApiURL.SIGNUP, headers: header, body: json);
      print('Sign up params: ' + json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('Sign up: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse<UserModel>> registerStep2(Map params) async {
    try {
      final json = jsonEncode(params);
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final response =
          await http.post(ApiURL.SIGNUP2, headers: header, body: json);
      print('Sign up 2 params: ' + jsonEncode(params));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        print('Sign up 2: ' + response.body);
        final jsonBody = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> forgot(Map params) async {
    try {
      final json = jsonEncode(params);
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
        final response = await http.post(ApiURL.FORGOT, headers: header, body: json);
      print('forgot params: ' + json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('forgot: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  // get_subscribe: yes/no
  // + yes: đã tham gia
  // + no: chưa tham gia
  // + ""(để trống): lấy tất cả topic
  static Future<ApiResponse<PageTopicModel>> getListTopic(
      {String name = "", String getSubscribe = "yes", int page = 1, int size = 10}) async {
    try {
      Map<String, String> queryParams = {
        'name': name,
        'subscribe': getSubscribe,
        'page': page.toString(),
        'perPage': size.toString()
      };
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final url = ApiURL.TOPIC + "?" + Uri(queryParameters: queryParams).query;
      print('topic url: ' + url);
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('topic: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse<TopicModel>> getTopic(
      String topicId) async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final url = ApiURL.TOPIC + "/" + topicId;
      print('topic detail url: ' + url);
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('topic detail: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<UnReadResponse> getUnread() async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final response = await http.get(ApiURL.UNREAD_NUMBER, headers: header);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('getUnread detail: ' + jsonEncode(jsonBody));
        return UnReadResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return UnReadResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return UnReadResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> subscribe(Map params) async {
    try {
      final json = jsonEncode(params);
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final response = await http.put(ApiURL.SUBSCRIBE, headers: header, body: json);
      print('SUBSCRIBE params: ' + jsonEncode(params));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('SUBSCRIBE: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<PageNavigateModel> getNavigate() async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final url = ApiURL.NAVIGATE ;
      print('navigate url: ' + url);
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('navigate: ' + jsonEncode(jsonBody));
        return PageNavigateModel.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return PageNavigateModel(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return PageNavigateModel(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> clickMessage(String messageId) async {
    try {
      final params = {
        "message_id": messageId
      };
      final json = jsonEncode(params);
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final response = await http.patch(ApiURL.CLICK_MESSAGE, headers: header, body: json);
      print('click message params: ' + jsonEncode(params));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('click message: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> receiveMessage(String messageId) async {
    try {
      final params = {
        "message_id": messageId
      };
      final json = jsonEncode(params);
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final response = await http.patch(ApiURL.RECEIVE_MESSAGE, headers: header, body: json);
      print('receive message params: ' + jsonEncode(params));
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('receive message: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> joinQr(String topicId) async {
    try {
      final params = {
        "subscribe": true,
        "qr_code": topicId
      };
      final json = jsonEncode(params);
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      print('qrcode message params: ' + jsonEncode(params));
      final response = await http.post(ApiURL.QRCODE, headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('qrcode message: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }

  static Future<ApiResponse> verifyRegister(Map params) async {
    try {
      final json = jsonEncode(params);
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      print('verifyRegister message params: ' + jsonEncode(params));
      final response = await http.post(ApiURL.CONFIRM_REGISTER, headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('verifyRegister message: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        return ApiResponse(response.statusCode, Strings.systemError, null);
      }
    } catch (e) {
       return ApiResponse(500, Strings.systemError, null);
    }
  }
}
