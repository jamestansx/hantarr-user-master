import 'dart:developer';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';

// options for baseURL
// 1 ==> food Delivery
// 2 ==> P2P Delivery

Dio getDio({
  @required int baseOption,
  Map<String, dynamic> queries = const {},
}) {
  String baseUrl;
  if (baseOption == 1) {
    baseUrl = foodUrl;
  } else {
    baseUrl = "$p2pBaseUrl";
  }
  Map<String, dynamic> header = {};
  try {
    header = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Connection": "keep-alive",
      // 'Authorization': "Bearer ${hantarrBloc.st}",
    };
  } catch (e) {
    header = {
      "Content-Type": "application/json",
      "Accept": "*/*",
      "Accept-Encoding": "gzip, deflate, br",
    };
  }
  BaseOptions baseOptions = BaseOptions(
    baseUrl: baseUrl,
    queryParameters: queries,
    headers: header,
  );
  Dio dio = Dio(baseOptions);
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (DioError e, handler) async {
        return handler.next(e);
      },
    ),
  );
  (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  };
  return dio;
}
