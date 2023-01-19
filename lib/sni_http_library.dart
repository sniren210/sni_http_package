library sni_http;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
// ignore: implementation_imports
import 'package:dio/src/adapters/io_adapter.dart'
    if (dart.library.html) 'package:dio/src/adapters/browser_adapter.dart';

import 'package:flutter/foundation.dart';
import 'package:model_factory/model_factory.dart';
import 'package:retry/retry.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'src/core/service.dart';
part 'src/dio/crud_service/crud_service.dart';
part 'src/dio/crud_service/delete_service_mixin.dart';
part 'src/dio/crud_service/find_service_mixin.dart';
part 'src/dio/crud_service/insert_service_mixin.dart';
part 'src/dio/crud_service/update_service_mixin.dart';
part 'src/dio/http_services.dart';
part 'src/dio/api_service.dart';
part 'src/websocket/websocket_service.dart';
part 'src/exception/general_exception.dart';
