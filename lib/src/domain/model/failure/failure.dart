import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:yubidart/src/domain/model/failure/failure_ext.dart';

abstract class YKFailure implements Exception {
  const YKFailure();

  factory YKFailure.invalidPIVManagementKey() = InvalidPIVManagementKey;

  factory YKFailure.securityConditionNotSatisfied() =
      SecurityConditionNotSatisfied;

  factory YKFailure.invalidPin() = InvalidPin;

  factory YKFailure.authMethodBlocked() = AuthMethodBlocked;

  factory YKFailure.unsupportedOperation() = UnsupportedOperation;

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
        'An error occurred',
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
    this.code,
    this.message,
    this.details,
  });

  factory InvalidPIVManagementKey.fromPlatformException(PlatformException e) {
    return InvalidPIVManagementKey(
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
    return 'InvalidPIVManagementKey(code: $code, message: $message, details: $details)';
  }
}

class SecurityConditionNotSatisfied extends YKFailure {
  const SecurityConditionNotSatisfied({
    this.code,
    this.message,
    this.details,
  });

  factory SecurityConditionNotSatisfied.fromPlatformException(
    PlatformException e,
  ) {
    return SecurityConditionNotSatisfied(
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
    return 'SecurityConditionNotSatisfied(code: $code, message: $message, details: $details)';
  }
}

class InvalidPin extends YKFailure {
  const InvalidPin({
    this.code,
    this.message,
    this.details,
  });

  factory InvalidPin.fromPlatformException(PlatformException e) {
    return InvalidPin(
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
    return 'InvalidPin(code: $code, message: $message, details: $details)';
  }
}

class AuthMethodBlocked extends YKFailure {
  const AuthMethodBlocked({
    this.code,
    this.message,
    this.details,
  });

  factory AuthMethodBlocked.fromPlatformException(PlatformException e) {
    return AuthMethodBlocked(
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
    return 'AuthMethodBlocked(code: $code, message: $message, details: $details)';
  }
}

class DeviceError extends YKFailure {
  const DeviceError({
    this.code,
    this.message,
    this.details,
  });

  factory DeviceError.fromPlatformException(PlatformException e) {
    return DeviceError(
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
    return 'DeviceError(code: $code, message: $message, details: $details)';
  }
}

class UnsupportedOperation extends YKFailure {
  const UnsupportedOperation({
    this.code,
    this.message,
    this.details,
  });

  factory UnsupportedOperation.fromPlatformException(PlatformException e) {
    return UnsupportedOperation(
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
    return 'UnsupportedOperation(code: $code, message: $message, details: $details)';
  }
}

class NotConnectedFailure extends YKFailure {
  const NotConnectedFailure({
    this.code,
    this.message,
    this.details,
  });

  factory NotConnectedFailure.fromPlatformException(PlatformException e) {
    return NotConnectedFailure(
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
    return 'NotConnectedFailure(code: $code, message: $message, details: $details)';
  }
}

class AlreadyConnectedFailure extends YKFailure {
  const AlreadyConnectedFailure({
    this.code,
    this.message,
    this.details,
  });

  factory AlreadyConnectedFailure.fromPlatformException(PlatformException e) {
    return AlreadyConnectedFailure(
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
    return 'AlreadyConnectedFailure(code: $code, message: $message, details: $details)';
  }
}

class InvalidData extends YKFailure {
  const InvalidData({
    this.code,
    this.message,
    this.details,
  });

  factory InvalidData.fromPlatformException(PlatformException e) {
    return InvalidData(
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
    return 'InvalidData(code: $code, message: $message, details: $details)';
  }
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
