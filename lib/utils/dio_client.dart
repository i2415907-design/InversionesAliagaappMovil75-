import 'package:dio/dio.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(
      baseUrl: 'https://inversionesaliaga.com/v1', // Tu nuevo prefijo
      headers: {
        'Content-Type': 'application/json',
        // Header vital para Hostinger:
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      }));
}