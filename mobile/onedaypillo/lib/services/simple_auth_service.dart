import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../config/theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text.dart';
import '../widgets/app_input.dart';

/// 간단한 인증 서비스 (로컬 저장소 사용)
class SimpleAuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  /// 사용자 목록 가져오기
  static Future<List<User>> _getUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      return usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      debugPrint('사용자 목록 가져오기 실패: $e');
      return [];
    }
  }

  /// 사용자 목록 저장
  static Future<void> _saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
      await prefs.setStringList(_usersKey, usersJson);
    } catch (e) {
      debugPrint('사용자 목록 저장 실패: $e');
    }
  }

  /// 현재 사용자 가져오기
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      if (userJson != null) {
        return User.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      debugPrint('현재 사용자 가져오기 실패: $e');
    }
    return null;
  }

  /// 현재 사용자 저장
  static Future<void> setCurrentUser(User? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (user != null) {
        await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      } else {
        await prefs.remove(_currentUserKey);
      }
    } catch (e) {
      debugPrint('현재 사용자 저장 실패: $e');
    }
  }

  /// 이메일로 회원가입
  static Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final users = await _getUsers();
      
      // 이메일 중복 확인
      if (users.any((user) => user.email == email)) {
        throw Exception('이미 가입된 이메일입니다.');
      }

      // 새 사용자 생성
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        provider: AuthProvider.email,
        createdAt: DateTime.now(),
        isEmailVerified: false,
      );

      users.add(newUser);
      await _saveUsers(users);
      await setCurrentUser(newUser);

      return newUser;
    } catch (e) {
      debugPrint('회원가입 실패: $e');
      rethrow;
    }
  }

  /// 이메일로 로그인
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      final users = await _getUsers();
      final user = users.firstWhere(
        (user) => user.email == email,
        orElse: () => throw Exception('존재하지 않는 이메일입니다.'),
      );

      await setCurrentUser(user);
      return user;
    } catch (e) {
      debugPrint('로그인 실패: $e');
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    await setCurrentUser(null);
  }

  /// 데모 계정 생성
  static Future<void> createDemoAccount() async {
    try {
      final users = await _getUsers();
      
      // 데모 계정이 이미 있는지 확인
      if (users.any((user) => user.email == 'sample@example.com')) {
        return;
      }

      final demoUser = User(
        id: 'demo_user_001',
        email: 'sample@example.com',
        displayName: '데모 사용자',
        provider: AuthProvider.email,
        createdAt: DateTime.now(),
        isEmailVerified: true,
      );

      users.add(demoUser);
      await _saveUsers(users);
      
      debugPrint('데모 계정 생성 완료: sample@example.com');
    } catch (e) {
      debugPrint('데모 계정 생성 실패: $e');
    }
  }
}
