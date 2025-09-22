import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yubidart/yubidart.dart';
import 'package:yubikit_android_example/components/action_button.dart';

class PivCalculateSecretButton extends StatelessWidget {
  const PivCalculateSecretButton({
    super.key,
    required this.yubikitPlugin,
  });

  final Yubidart yubikitPlugin;

  @override
  Widget build(BuildContext context) => ActionButton(
        text: 'Sign data',
        onPressed: () async {
          final secret = await yubikitPlugin.piv.calculateSecret(
            slot: PivSlot.signature,
            pin: "123456",
            message: Uint8List.fromList(''.codeUnits),
          );
          return secret.toString();
        },
      );
}
