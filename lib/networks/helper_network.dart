import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:meeting_app/models/user.dart';
import 'package:meeting_app/networks/constants_network.dart';
//import 'package:meeti_appng/utils/dynamic_link_utils.dart';
import 'package:meeting_app/utils/session_utils.dart';

class NetworkHelper {
  final _session = Session();

  //USER

  //Register the user data
  Future<String> registerUser({@required String username, @required String email, @required String password}) async {
    try {
      //get the constant of api
      final url = NetworkConstants.API_REGISTER;

      //send the post request with the user data
      final response = await http.post(url, body: {"username": username, "email": email, "password": password});

      //parse the response obtained
      final parsed = jsonDecode(response.body);

      //check the [statusCode] of the response
      if (response.statusCode == 200) {
        //get the [token] obtained in the response api
        final token = parsed['token'] as String;

        //get the token duration
        final expiresIn = parsed['expiresIn'] as int;

        // save the token
        await _registerToken(token);
        await _session.set(token, expiresIn);

        return 'true';
      } else if (response.statusCode == 500) {
        throw PlatformException(code: "500", message: parsed['message']);
      }

      throw PlatformException(code: "201", message: "Error /register");
    } on PlatformException catch (e) {
      return e.message;
    }
  }

  //Login with the user data
  Future<String> login({@required String email, @required String password}) async {
    try {
      final url = NetworkConstants.API_LOGIN;

      final response = await http.post(url, body: {"email": email, "password": password});
      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = parsed['token'] as String;
        final expiresIn = parsed['expiresIn'] as int;

        // save token
        await _registerToken(token);
        await _session.set(token, expiresIn);
        return 'true';
      } else if (response.statusCode == 500) {
        throw PlatformException(code: "500", message: parsed['message']);
      }

      throw PlatformException(code: "201", message: "Error /login");
    } on PlatformException catch (e) {
      print("Error ${e.code}:${e.message}");

      return e.message;
    }
  }

  //user info
  Future<dynamic> getUserInfo(String token) async {
    try {
      final url = NetworkConstants.API_USER_INFO;

      final response = await http.get(url, headers: {"token": token});

      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print(parsed);
        return parsed;
      } else if (response.statusCode == 403) {
        throw PlatformException(code: "403", message: parsed['message']);
      } else if (response.statusCode == 500) {
        throw PlatformException(code: "500", message: parsed['message']);
      }
      throw PlatformException(code: "201", message: "error: /user-info");
    } on PlatformException catch (e) {
      print("error getUserInfo: ${e.message}");
      _session.clear();
      return null;
    }
  }

  //TOKENS
  //register the token
  Future _registerToken(String token) async {
    try {
      //get the register token url
      final url = NetworkConstants.API_TOKEN_REGISTER;

      //send the post request with the token provides
      final response = await http.post(url, headers: {"token": token});

      //parse the obtained response
      final parsed = jsonDecode(response.body);

      //check the [statusCode]
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 500) {
        throw PlatformException(code: "500", message: parsed['message']);
      }

      throw PlatformException(code: "201", message: "Error /tokens/register");
    } on PlatformException catch (e) {
      print("Error ${e.code}:${e.message}");
    }
  }

  //refresh token
  Future<dynamic> _refreshToken(String expiredToken) async {
    print("refresh token");

    try {
      final url = NetworkConstants.API_TOKEN_REFRESH;

      final response = await http.post(url, headers: {"token": expiredToken});

      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return parsed;
      } else if (response.statusCode == 500) {
        throw PlatformException(code: "500", message: parsed['message']);
      }

      throw PlatformException(code: "201", message: "Error /tokens/refresh");
    } on PlatformException catch (e) {
      print("Error ${e.code}:${e.message}");
      return null;
    }
  }

  //get token of access in storage
  Future<String> getAccessToken() async {
    try {
      final result = await _session.get();
      if (result != null) {
        final token = result['token'] as String;
        final expiresIn = result['expiresIn'] as int;
        final createdAt = DateTime.parse(result['createdAt']);
        final currentDate = DateTime.now();

        final diff = currentDate.difference(createdAt).inSeconds;
        if (expiresIn != null && expiresIn - diff >= 60) {
          print("token is alive");
          print(token);
          return token;
        }

        // refresh
        final newData = await _refreshToken(token);
        if (newData != null) {
          final newToken = newData['token'];
          final newExpiresIn = newData['expiresIn'];
          await _session.set(newToken, newExpiresIn);
          return newToken;
        }
        return null;
      }
      return null;
    } on PlatformException catch (e) {
      print("Error ${e.code}:${e.message}");
    }
    return null;
  }

  //GROUPS
  //create group
  Future<dynamic> createGroup(BuildContext context,
      {@required String groupName, @required String descriptionGroup, File image}) async {
    try {
      //api_group
      final url = NetworkConstants.API_CREATE_GROUP;

      final token = await getAccessToken();

      final response = await http
          .post(url, body: {"groupName": groupName, "description": descriptionGroup}, headers: {"token": token});

      final parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (image != null) {
          final avatar = await updateAvatar(
              image: image, token: token, id: parsed['response']['_id'], path: NetworkConstants.API_AVATAR_GROUP);
          parsed["response"]["imgUrl"] = "${NetworkConstants.HOST}$avatar";
        }

        return parsed["response"];
      } else if (response.statusCode == 403) {
        throw PlatformException(code: "403", message: parsed['message']);
      } else if (response.statusCode == 500) {
        throw PlatformException(code: "500", message: parsed['message']);
      }
      throw PlatformException(code: "201", message: "error: /create-group");
    } on PlatformException catch (e) {
      print("error createGroup: ${e.message}");
      return null;
    }
  }

  //get group info
  Future<dynamic> getGroupInfo() async {
    try {
      final url = NetworkConstants.API_GROUP_INFO;

      final token = await getAccessToken();

      final response = await http.get(url, headers: {"token": token});

      final parsed = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return parsed;
      } else if (response.statusCode == 403) {
        throw PlatformException(code: "403", message: parsed['message']);
      } else if (response.statusCode == 500) {
        throw PlatformException(code: "500", message: parsed['message']);
      }
      throw PlatformException(code: "201", message: "error: /group-info");
    } on PlatformException catch (e) {
      print("error getUserInfo: ${e.message}");
      return null;
    }
  }

  //update group info
  Future<dynamic> updateGroup(BuildContext context,
      {@required String groupName, @required String descriptionGroup, @required String groupId, File image}) async {
    try {
      //api_group
      final url = NetworkConstants.API_UPDATE_GROUP;

      final token = await getAccessToken();

      final response = await http.post(url,
          body: {"groupName": groupName, "description": descriptionGroup, "groupId": groupId},
          headers: {"token": token});

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (image != null) {
          final imgUrl = await updateAvatar(
              image: image, token: token, id: parsed['_id'], path: NetworkConstants.API_AVATAR_GROUP);
          parsed["imgUrl"] = "${NetworkConstants.HOST}$imgUrl";
        } else {
          if (parsed["imgUrl"] != null && parsed["imgUrl"] != '') {
            parsed["imgUrl"] = "${NetworkConstants.HOST}${parsed["imgUrl"]}";
          }
        }

        return parsed;
      }
      throw PlatformException(code: "201", message: "error: /update-group");
    } on PlatformException catch (e) {
      print("error updateeGroup: ${e.message}");
      return null;
    }
  }

  Future<String> getShareLink({@required String groupId}) async {
    try {
      //api_group
      final url = NetworkConstants.API_INVITE_MEMBER;

      final token = await getAccessToken();

      final response = await http.post(url, body: {"groupId": groupId}, headers: {"token": token});

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        //  Uri sharedLink =
        //  await DynamicLinkFirebase().generateLink(parsed['response']);
        String sharedLink = "Link no se pudo generar" + parsed['response'];
        return sharedLink;
      }
      throw PlatformException(code: "201", message: "error: /create-group");
    } on PlatformException catch (e) {
      print("error invitegroup: ${e.message}");
      return null;
    }
  }

  Future<bool> deleteGroup({@required String groupId}) async {
    try {
      final url = NetworkConstants.API_DELETE_GROUP;

      final token = await getAccessToken();

      final response = await http.post(url, body: {"groupId": groupId}, headers: {"token": token});

      if (response.statusCode == 200) {
        return true;
      }
      throw PlatformException(code: "201", message: "error: /deleting-group ${response.body}");
    } on PlatformException catch (e) {
      print("error deletingGroup: ${e.message}");
      return false;
    }
  }

  Future<User> checkUser() async {
    final token = await getAccessToken();

    if (token != null) {
      final result = await getUserInfo(token);
      if (result != null) {
        final user = User.fromJson(result);
        return user;
      }
    }
    return null;
  }

  Future<User> updateUser({String email, String username, String password}) async {
    try {
      //api update user
      final url = NetworkConstants.API_USER_UPDATE;

      final token = await getAccessToken();

      email ??= '';
      password ??= '';
      username ??= '';

      final response = await http
          .post(url, body: {"email": email, "password": password, "username": username}, headers: {"token": token});

      if (response.statusCode == 200) {
        if (response.body.contains('duplicate key')) {
          return null;
        }
        final parsed = jsonDecode(response.body);
        return User.fromJson(parsed);
      }
      throw PlatformException(code: "201", message: "error: /update-user");
    } on PlatformException catch (e) {
      print("error createGroup: ${e.message}");
      return null;
    }
  }

  Future<String> updateAvatar({@required String path, @required File image, String id, token}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(path),
      );

      request.headers['token'] = token;
      if (id != null) request.fields['id'] = id;
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          image.path,
        ),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        return respStr;
      }
      throw PlatformException(code: "201", message: "error: /update-user");
    } on PlatformException catch (e) {
      print("error createGroup: ${e.message}");
      return null;
    }
  }

  Future<dynamic> deleteAvatar() async {
    try {
      final url = NetworkConstants.API_AVATAR_USER_DELETE;
      final token = await getAccessToken();

      if (token != null) {
        final result = await http.post(
          url,
          headers: {"token": token},
        );

        if (result != null) {
          return result.body.toString();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> verifyCode(String code) async {
    try {
      final url = NetworkConstants.API_CODE_GROUP;
      final response = await http.post(url, body: {"groupShareLink": code});
      final parsed = jsonDecode(response.body);
      return parsed['response'];
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<dynamic> addMember({@required String groupInvitedLink}) async {
    try {
      final url = NetworkConstants.API_CODE_ADD_MEMBER;

      final token = await getAccessToken();

      final response = await http.post(url, body: {"sharedLink": groupInvitedLink}, headers: {"token": token});

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed['response']['imgUrl'] != null) {
          parsed['response']["imgUrl"] = "${NetworkConstants.HOST}${parsed['response']['imgUrl']}";
        }
        return parsed['response'];
      }
      throw PlatformException(code: "201", message: "error: /adding-code-member ${response.body}");
    } on PlatformException catch (e) {
      print("error deletingGroup: ${e.message}");
      return null;
    }
  }

  Future<dynamic> deleteMember({@required String groupId}) async {
    try {
      final url = NetworkConstants.API_DELETE_MEMBER;

      final token = await getAccessToken();

      final response = await http.post(url, body: {"groupId": groupId}, headers: {"token": token});

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return parsed['response'];
      }
      throw PlatformException(code: "201", message: "error: /deleting-member ${response.body}");
    } on PlatformException catch (e) {
      print("error deletingGroup: ${e.message}");
      return null;
    }
  }
}
