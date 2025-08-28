// Package imports:
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:ndef_record/ndef_record.dart';

// Project imports:
import 'package:yubidart/src/domain/model/nfc/unsupported_record.dart';
import 'package:yubidart/src/domain/model/nfc/wellknown_uri_record.dart';

// ignore: avoid_classes_with_only_static_members
abstract class Record {
  static Record fromNdef(NdefRecord record) {
    if (record.typeNameFormat == TypeNameFormat.wellKnown &&
        record.type.length == 1 &&
        record.type.first == 0x55) {
      return WellknownUriRecord.fromNdef(record);
    } else {
      return UnsupportedRecord(record);
    }
  }
}
