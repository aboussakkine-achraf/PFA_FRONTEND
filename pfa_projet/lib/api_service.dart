import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String authBaseUrl =
      'http://10.0.2.2:8080/api'; // For authentication-related endpoints
  static const String cardsBaseUrl =
      'http://10.0.2.2:8096/api/cards'; // For saving card data

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Register user
  static Future<String> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final Uri registerUri = Uri.parse('$authBaseUrl/register');

    final Map<String, String> body = {
      'username': username,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      registerUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return 'User registered successfully!';
    } else {
      throw Exception('Failed to register user');
    }
  }

  // Login functionality using POST request with username and password as query parameters
  static Future<bool> login(String username, String password) async {
    final Uri loginUri =
        Uri.parse('$authBaseUrl/login').replace(queryParameters: {
      'username': username,
      'password': password,
    });

    final response = await http.post(loginUri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String accessToken = data['accessToken'];
      String refreshToken = data['refreshToken'];

      await storeTokens(accessToken, refreshToken);

      return true;
    } else {
      throw Exception('Login failed');
    }
  }

  // Save Tokens Securely
  static Future<void> storeTokens(
      String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'accessToken');
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refreshToken');
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }

  // Generate authorization header
  static Future<Map<String, String>> authHeader() async {
    final String? accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('No access token found');
    }

    return {'Authorization': 'Bearer $accessToken'};
  }

  // Refresh access token if expired
  static Future<void> refreshAccessToken() async {
    final String? refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }

    final Uri refreshUri = Uri.parse('$authBaseUrl/refresh-token');
    final response = await http.post(
      refreshUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String newAccessToken = data['accessToken'];

      await storeTokens(newAccessToken, refreshToken);
    } else {
      throw Exception('Failed to refresh access token');
    }
  }

  // Logout
  static Future<void> logout() async {
    await clearTokens();
  }

  // Save card data (updated with matching field names)
  static Future<String> saveCardData(
    String cardType,
    String shortNameSchool,
    String fullNameSchool,
    String address,
    String phone,
    String schoolYear,
    String studentFullName,
    String educationLevel,
  ) async {
    final Uri saveCardUri = Uri.parse(cardsBaseUrl);

    final Map<String, String> body = {
      'cardType': cardType,
      'shortNameSchool': shortNameSchool,
      'fullNameSchool': fullNameSchool,
      'address': address,
      'phone': phone,
      'schoolYear': schoolYear,
      'studentFullName': studentFullName,
      'educationLevel': educationLevel,
    };

    final response = await http.post(
      saveCardUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return 'Card data saved successfully!';
    } else {
      throw Exception('Failed to save card data');
    }
  }
}
