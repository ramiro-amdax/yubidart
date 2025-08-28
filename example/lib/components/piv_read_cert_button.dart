import 'package:flutter/material.dart';
import 'package:yubidart/yubidart.dart';
import 'package:yubikit_android_example/components/action_button.dart';

class PivReadCertButton extends StatelessWidget {
  const PivReadCertButton({
    super.key,
    required this.yubikitPlugin,
  });

  final Yubidart yubikitPlugin;

  @override
  Widget build(BuildContext context) => ActionButton(
        text: 'Read certificate',
        onPressed: () async {
          try {
          final certificate = await yubikitPlugin.piv.getCertificate(
            pin: "123456",
              slot: PivSlot.signature,
            );
            return String.fromCharCodes(certificate);
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
