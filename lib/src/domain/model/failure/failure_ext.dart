import 'package:flutter/services.dart';
import 'package:yubidart/src/domain/model/failure/failure.dart';

extension YKPlatformExceptionExt on PlatformException {
  YKFailure toYKFailure() {
    switch (code) {
      case 'INVALID_DATA':
        return InvalidData.fromPlatformException(this);
      case 'ALREADY_CONNECTED':
        return AlreadyConnectedFailure.fromPlatformException(this);
      case 'NOT_CONNECTED':
        return NotConnectedFailure.fromPlatformException(this);
      case 'UNSUPPORTED_OPERATION':
        return UnsupportedOperation.fromPlatformException(this);
      case 'INVALID_PIN':
        return InvalidPin.fromPlatformException(this);
      case 'INVALID_MANAGEMENT_KEY':
        return InvalidPIVManagementKey.fromPlatformException(this);
      case 'AUTH_METHOD_BLOCKED':
        return AuthMethodBlocked.fromPlatformException(this);
      case 'SECURITY_CONDITION_NOT_SATISFIED':
        return SecurityConditionNotSatisfied.fromPlatformException(this);
      case 'DEVICE_ERROR':
        return DeviceError.fromPlatformException(this);
      default:
        return OtherFailure.fromPlatformException(this);
    }
  }
}
