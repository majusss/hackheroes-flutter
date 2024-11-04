import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hackheroes_flutter/screens/onboarding.dart';
import 'package:hackheroes_flutter/screens/start.dart';
import 'package:hackheroes_flutter/utils/exeptions.dart';

class ApiService {
  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  User? _user;
  String? _token;

  User get user => _user!;

  ApiService() {
    if (dotenv.env['SERVER_URL'] == null) {
      throw Exception("SERVER_URL is not defined in .env file");
    }
    _dio = Dio(BaseOptions(
      baseUrl: "${dotenv.env['SERVER_URL'] as String}/api/mobile/v1",
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
      },
      followRedirects: false,
      validateStatus: (_) => true,
    ));
    _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true));

    _storage.read(key: "token").then((value) {
      _token = value;
      if (_token != null) {
        syncUser().then((value) {
          _user = value;
        }).catchError((e) {
          logout();
        });
      }
    });
  }

  Future<User> syncUser() async {
    final response = await _dio.get("/getUser",
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $_token",
          },
        ));
    if (response.statusCode == 200 && response.data != null) {
      try {
        return User.fromJson(response.data["user"]);
      } catch (e) {
        throw LogOutException();
      }
    } else {
      throw Exception("Failed to load user data");
    }
  }

  Future<bool> isAuth() async {
    return _token != null;
  }

  void login(String token, {BuildContext? context}) async {
    await _storage.write(key: "token", value: token);
    _token = token;
    _user = await syncUser();
    if (context != null && context.mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StartScreen()));
    }
  }

  void logout({BuildContext? context}) async {
    await _storage.delete(key: "token");
    _token = null;
    _user = null;
    if (context != null && context.mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }
}

class User {
  final String id, externalId, email;

  const User({
    required this.id,
    required this.externalId,
    required this.email,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        externalId = json["externalId"],
        email = json["email"];

  @override
  String toString() {
    return "User(id: $id, externalId: $externalId, email: $email)";
  }
}
