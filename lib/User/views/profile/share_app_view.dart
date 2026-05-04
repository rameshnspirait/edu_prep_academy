import 'package:edu_prep_academy/User/controllers/share_app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShareAppCard extends StatelessWidget {
  final controller = Get.put(ShareController());

  ShareAppCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.share, color: Colors.white, size: 40),
          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Invite Friends",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Help your friends prepare better",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: controller.shareApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
            ),
            child: const Text("Share"),
          ),
        ],
      ),
    );
  }
}
