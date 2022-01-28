// ignore_for_file: overridden_fields, avoid_renaming_method_parameters
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// 异常
import 'package:flutter_eyepetizer/request/app_exceptions.dart';

class MyDioSocketException extends SocketException {
  @override
  late String message;

  MyDioSocketException(
    message, {
    osError,
    address,
    port,
  }) : super(
          message,
          osError: osError,
          address: address,
          port: port,
        );
}

// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  // 是否有网
  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler errCb) async {
    // 自定义一个socket实例，因为dio原生的实例，message属于是只读的
    if (err.error is SocketException) {
      err.error = MyDioSocketException(
        err.message,
        osError: err.error?.osError,
        address: err.error?.address,
        port: err.error?.port,
      );
    }
    // 是否已经连接了网络，不判断是否没网
    if (err.type == DioErrorType.other) {
      bool isConnectNetWork = await isConnected();
      if (!isConnectNetWork && err.error is MyDioSocketException) {
        err.error.message = "当前无网络，请连接网络";
      }
    }
    // error统一处理
    AppException appException = AppException.create(err);
    // 错误提示
    debugPrint('DioError===: ${appException.toString()}');
    err.error = appException;
    return super.onError(err, errCb);
  }
}
