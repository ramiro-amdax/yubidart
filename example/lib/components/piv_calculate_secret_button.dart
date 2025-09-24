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

  @override
  Widget build(BuildContext context) => ActionButton(
        text: 'Sign data',
        onPressed: () async {
          final secret = await yubikitPlugin.piv.calculateSecret(
            slot: PivSlot.signature,
            pin: "123456",
            message: utf8.encode(data),
          );
          print('secret: $secret');
          // signature as hex
          final hexString = secret.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
          print('hexString: $hexString');
          // data as ascii
          final asciiString = String.fromCharCodes(secret);
          print('asciiString: $asciiString');
          // data as base64
          final base64String = base64Encode(secret);
          print('base64String: $base64String');

          return secret.toString();
        },
      );
}
