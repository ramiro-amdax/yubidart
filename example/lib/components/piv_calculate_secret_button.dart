import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yubidart/yubidart.dart';
import 'package:yubikit_android_example/components/action_button.dart';

class PivCalculateSecretButton extends StatelessWidget {
  const PivCalculateSecretButton({
    super.key,
    required this.yubikitPlugin,
  });

  final Yubidart yubikitPlugin;

  static const String data = 'aGVsbG8=';
  static const String pin = '123456';

  @override
  Widget build(BuildContext context) => ActionButton(
        text: 'Sign data',
        onPressed: () async {
          final secret = await yubikitPlugin.piv.calculateSecret(
            slot: PivSlot.signature,
            pin: pin,
            message: utf8.encode(data),
          );
          // signature as hex
          final hexString = secret.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
          print('PivCalculateSecretButton hexString: $hexString');
          // data as ascii
          final asciiString = String.fromCharCodes(secret);
          print('PivCalculateSecretButton asciiString: $asciiString');
          // data as base64
          final base64String = base64Encode(secret);
          print('PivCalculateSecretButton base64String: $base64String');

          return secret.toString();
        },
      );
}
