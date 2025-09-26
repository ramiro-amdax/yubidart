import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:yubidart/src/domain/model/failure/failure_ext.dart';

abstract class YKFailure implements Exception {
  const YKFailure();

  factory YKFailure.invalidPIVManagementKey({
    String? message,
  }) = InvalidPIVManagementKey;

  factory YKFailure.securityConditionNotSatisfied() =
      SecurityConditionNotSatisfied;

  factory YKFailure.invalidPin({
    required int remainingRetries,
  }) = InvalidPin;

  factory YKFailure.authMethodBlocked() = AuthMethodBlocked;

  factory YKFailure.unsupportedOperation({
    String? message,
  }) = UnsupportedOperation;

  factory YKFailure.deviceError() = DeviceError;

  factory YKFailure.notConnected() = NotConnectedFailure;

  factory YKFailure.invalidData() = InvalidData;

  static YKFailure other({
    String? code,
    String? message,
    dynamic details,
  }) {
    return OtherFailure(
      code: code,
      message: message,
      details: details,
    );
  }

  static Future<T> guard<T>(FutureOr<T> Function() run) async {
    try {
      return await run();
    } on PlatformException catch (e, stack) {
      log(
        'An error occured',
        name: 'Yubidart',
        error: e,
        stackTrace: stack,
      );
      throw e.toYKFailure();
    } catch (e) {
      throw YKFailure.other(message: e.toString());
    }
  }
}

class InvalidPIVManagementKey extends YKFailure {
  const InvalidPIVManagementKey({
    this.message,
  });

  final String? message;
}

class SecurityConditionNotSatisfied extends YKFailure {
  const SecurityConditionNotSatisfied();
}

class InvalidPin extends YKFailure {
  const InvalidPin({
    required this.remainingRetries,
  });

  final int remainingRetries;
}

class AuthMethodBlocked extends YKFailure {
  const AuthMethodBlocked();
}

class DeviceError extends YKFailure {
  const DeviceError();
}

class UnsupportedOperation extends YKFailure {
  const UnsupportedOperation({
    this.message,
  });

  final String? message;
}

class NotConnectedFailure extends YKFailure {
  const NotConnectedFailure();
}

class AlreadyConnectedFailure extends YKFailure {
  const AlreadyConnectedFailure();
}

class InvalidData extends YKFailure {
  const InvalidData();
}

class OtherFailure extends YKFailure {
  const OtherFailure({
    this.code,
    this.message,
    this.details,
  });

  factory OtherFailure.fromPlatformException(PlatformException e) {
    return OtherFailure(
      code: e.code,
      message: e.message,
      details: e.details,
    );
  }

  final String? code;
  final String? message;
  final dynamic details;

  @override
  String toString() {
    return 'OtherFailure(code: $code, message: $message, details: $details)';
  }
}
