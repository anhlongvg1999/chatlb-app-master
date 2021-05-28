import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:chat_lb/model/apiResponse.dart';
import 'package:chat_lb/model/pageMessageModel.dart';
import 'package:chat_lb/model/pageNavigateModel.dart';
import 'package:chat_lb/model/pageTopicModel.dart';
import 'package:chat_lb/model/uploadResponse.dart';
import 'package:chat_lb/model/userModel.dart';
import 'package:chat_lb/service/appPrefs.dart';
import 'package:chat_lb/util/apiUrl.dart';
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
        throw Exception('Failed to login');
      }
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Failed to get history');
      }
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Failed to logout');
      }
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Failed to upload');
      }
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Failed to me');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<ApiResponse> updateUser(Map params) async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {'Authorization': "Bearer $token"};
      final json = jsonEncode(params);
      final response =
          await http.put(ApiURL.UPDATE_USER, headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to update user info');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<ApiResponse> updateNotificationToken() async {
    try {
      final token = await AppPrefs.share().getToken();
      final pushToken = await AppPrefs.share().getPushToken();
      Map<String, String> header = {'Authorization': "Bearer $token"};
      Map<String, String> params = {'notification_token': pushToken};
      final json = jsonEncode(params);
      final response =
          await http.put(ApiURL.UPDATE_USER, headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to update user info');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<ApiResponse> updateReceiveNotification(Map params) async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {'Authorization': "Bearer $token"};
      final json = jsonEncode(params);
      print('updateReceiveNotification: ' + jsonEncode(json));
      final response = await http.put(ApiURL.UPDATE_RECEIVE_NOTIFICATION,
          headers: header, body: json);
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        final jsonBody = jsonDecode(response.body);
        print('updateReceiveNotification: ' + jsonEncode(jsonBody));
        return ApiResponse.fromJson(jsonBody);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to update receive notification');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<bool> downloadFile(
      String url, String fileName, String localPath) async {
    try {
      final response = await http.get(url);

      if (response.contentLength == 0) {
        return false;
      }
      Directory folderFile = new Directory(localPath);
      if (await folderFile.exists() == false) {
        folderFile.create();
      }
      File downloadFile =
          new File(localPath + Platform.pathSeparator + fileName);
      await downloadFile.writeAsBytes(response.bodyBytes);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
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
        throw Exception('Failed to Sign up');
      }
    } catch (e) {
      throw Exception(e.toString());
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
        throw Exception('Failed to Sign up 2');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<ApiResponse> forgot(Map params) async {
    try {
      final json = jsonEncode(params);
      final Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      final response =
          await http.post(ApiURL.FORGOT, headers: header, body: json);
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
        throw Exception('Failed to forgot');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // get_subscribe: yes/no
  // + yes: có trường unread_message
  // + no: có trường is_subcribe
  // + ""(để trống): lấy tất cả topic
  static Future<ApiResponse<PageTopicModel>> getListTopic(
      {String name = "",
      String getSubscribe = "yes",
      int page = 1,
      int size = 10}) async {
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
        throw Exception('Failed to get topic');
      }
    } catch (e) {
      throw Exception(e.toString());
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
      final response =
          await http.put(ApiURL.SUBSCRIBE, headers: header, body: json);
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
        throw Exception('Failed to subscribe');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<PageNavigateModel> getNavigate() async {
    try {
      final token = await AppPrefs.share().getToken();
      Map<String, String> header = {
        'Authorization': "Bearer $token",
        'Content-Type': "application/json"
      };
      final url = ApiURL.NAVIGATE;
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
        throw Exception('Failed to get navigate');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
