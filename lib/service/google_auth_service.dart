import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: kIsWeb ? null : '',
    clientId: kIsWeb ? '' : null,
  );

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://inversionesaliaga.com/v1',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  Future<bool> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? tokenFinal = googleAuth.idToken ?? googleAuth.accessToken;

      if (tokenFinal == null) {
        print("Error: No se pudo obtener ningún token de Google");
        return false;
      }

      final response = await _dio.post(
        '/auth/google',
        data: {
          'id_token': tokenFinal,
        },
      );

      if (response.statusCode == 200 && response.data['res'] == true) {
        final String? tokenServidor = response.data['token'];

        if (tokenServidor != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', tokenServidor);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      print("Error de Red/Laravel: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      print("Error inesperado en GoogleAuth: $e");
      return false;
    }
  }
}