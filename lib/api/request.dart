import 'package:dio/dio.dart';

class Api {
  Dio dio;
  Api() {
    Dio dio = new Dio();
    dio.options.baseUrl = 'https://cnodejs.org/api/v1';
    dio.interceptor.request.onSend = (Options options) {
      // Do something before request is sent
      print('dio: ${options.baseUrl}${options.path} ${options.data}');
      return options; //continue
      // If you want to resolve the request with some custom data，
      // you can return a `Response` object or return `dio.resolve(data)`.
      // If you want to reject the request with a error message,
      // you can return a `DioError` object or return `dio.reject(errMsg)`
    };
    this.dio = dio;
  }
}
