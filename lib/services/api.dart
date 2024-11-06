import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hackheroes_flutter/screens/onboarding.dart';
import 'package:hackheroes_flutter/screens/start.dart';

class ApiService {
  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  User? _user;
  String? _token;

  User get user => _user!;
  Challenge get challenge => user.currentChallenge!;

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
    ));
    _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true));
  }

  Future setup() async {
    try {
      final freshToken = await _storage.read(key: "token");
      _token = freshToken;
      _user = await syncUser();
      if (_user?.currentChallenge == null) {
        await syncChallenge();
        _user = await syncUser();
      }
    } catch (e) {
      debugPrint("Failed to init: $e");
      _token = null;
      _user = null;
    }
  }

  Future<User> syncUser() async {
    final response = await _dio.get("/getUser",
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $_token",
          },
        ));
    if (response.statusCode == 200 && response.data != null) {
      // TODO: error handling
      return User.fromJson(response.data["user"]);
    } else {
      await logout();
      throw Exception("Failed to load user data");
    }
  }

  Future<Challenge> syncChallenge() async {
    final response = await _dio.get("/getUserCurrentChallenge",
        options: Options(
          headers: {
            HttpHeaders.authorizationHeader: "Bearer $_token",
          },
        ));

    if (response.statusCode == 200 && response.data != null) {
      return Challenge.fromJson(response.data["challenge"]);
    } else {
      await logout();
      throw Exception("Failed to load challenges");
    }
  }

  bool get isAuth => _token != null;

  Future login(String token, {BuildContext? context}) async {
    await _storage.write(key: "token", value: token);
    _token = token;
    _user = await syncUser();
    if (context != null && context.mounted) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StartScreen()));
    }
  }

  Future logout({BuildContext? context}) async {
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
  final DateTime? currentChallengeDate;
  final Challenge? currentChallenge;

  const User(
      {required this.id,
      required this.externalId,
      required this.email,
      this.currentChallengeDate,
      this.currentChallenge});

  User.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        externalId = json["externalId"],
        email = json["email"],
        currentChallengeDate = json["currentChallengeDate"] != null
            ? DateTime.parse(json["currentChallengeDate"])
            : null,
        currentChallenge = json["currentChallenge"] != null
            ? Challenge.fromJson(
                json["currentChallenge"] as Map<String, dynamic>)
            : null;

  @override
  String toString() {
    return "User(id: $id, externalId: $externalId, email: $email, currentChallengeDate: $currentChallengeDate, currentChallenge: $currentChallenge)";
  }
}

class Challenge {
  final String id, title, description;
  final int points;
  final Category category;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.category,
  });

  Challenge.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        title = json["title"],
        description = json["description"],
        points = json["points"],
        category = json["category"] != null
            ? Category.fromJson(json["category"])
            : const Category(id: "UNKNOW", name: "Nie przypisano kategorii");

  @override
  String toString() {
    return "Challenge(id: $id, title: $title, description: $description, points: $points, category: $category)";
  }
}

class Category {
  final String id, name;

  const Category({
    required this.id,
    required this.name,
  });

  Category.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"];

  @override
  String toString() {
    return "Category(id: $id, name: $name)";
  }
}
