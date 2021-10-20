// ignore_for_file: constant_identifier_names
import 'package:flutter_eyepetizer/request/app_exceptions.dart';

class ApiResponse<T> {
  Status status;
  T? data;
  AppException? exception;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.error(this.exception) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $exception \n Data : $data";
  }
}

enum Status { COMPLETED, ERROR }
