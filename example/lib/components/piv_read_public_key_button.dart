import 'package:flutter/material.dart';
import 'package:yubidart/yubidart.dart';
import 'package:yubikit_android_example/components/action_button.dart';

class PivReadPublicKeyButton extends StatelessWidget {
  const PivReadPublicKeyButton({
    super.key,
    required this.yubikitPlugin,
  });

  final Yubidart yubikitPlugin;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      text: 'Read Public Key',
      onPressed: () async {
        try {
          final publicKey = await yubikitPlugin.piv.getPublicKey(
            slot: PivSlot.signature,
          );

          return publicKey.toString();
        } on DeviceError catch (e) {
          print((e as DeviceError));
          return '';
        } catch (e) {
          print(e.toString());
          return '';
        }
      },
    );
  }
}
