// widgets/show_jwt_button.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/utils/storage_helper.dart';

class ShowJwtButton extends StatelessWidget {
  const ShowJwtButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.vpn_key_outlined),
      title: const Text('Show JWT (dev only)'),
      onTap: () async {
        Navigator.pop(context); // close drawer

        final token = await StorageHelper.getToken();

        if (!context.mounted) return;

        if (token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No JWT token stored')),
          );
          return;
        }

        await Clipboard.setData(ClipboardData(text: token));

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Current JWT (copied)'),
            content: SingleChildScrollView(child: Text(token)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
