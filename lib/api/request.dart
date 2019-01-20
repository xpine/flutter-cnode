import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  Dio dio;
  Api() {
    Dio dio = new Dio();
    dio.options.baseUrl = 'https://cnodejs.org/api/v1';
    dio.interceptor.request.onSend = (Options options) async {
      // Do something before request is sent
      print('dio: ${options.baseUrl}${options.path} ${options.data}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      try {
        var accesstoken = await prefs.get('token');
        options.data['accesstoken'] = accesstoken;
        print('options $options');
        return options;
      } catch (e) {
        return options;
      }
      // If you want to resolve the request with some custom data，
      // you can return a `Response` object or return `dio.resolve(data)`.
      // If you want to reject the request with a error message,
      // you can return a `DioError` object or return `dio.reject(errMsg)`
    };
    this.dio = dio;
  }
}
