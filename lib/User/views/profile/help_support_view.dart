import 'package:edu_prep_academy/User/views/profile/raise_ticket_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edu_prep_academy/User/controllers/help_support_controller.dart';

class HelpSupportView extends StatelessWidget {
  HelpSupportView({super.key});

  final controller = Get.put(HelpSupportController());

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
        elevation: 8,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// ================= HEADER =================
            _header(),

            const SizedBox(height: 20),

            /// ================= CONTACT SECTION =================
            _sectionTitle("Contact Us"),

            _contactCard(
              icon: Icons.chat,
              title: "WhatsApp Support",
              subtitle: "Chat with us instantly",
              color: Colors.green,
              onTap: () {
                launchUrl(Uri.parse("https://wa.me/916306937005"));
              },
            ),

            _contactCard(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "examsolvingofficial@gmail.com",
              color: Colors.blue,
              onTap: () {
                launchUrl(
                  Uri.parse(
                    "mailto:examsolvingofficial@gmail.com?subject=Help Needed",
                  ),
                );
              },
            ),

            _contactCard(
              icon: Icons.call,
              title: "Call Support",
              subtitle: "+91 6306937005",
              color: Colors.orange,
              onTap: () {
                launchUrl(Uri.parse("tel:+916306937005"));
              },
            ),

            const SizedBox(height: 20),

            /// ================= FAQ =================
            _sectionTitle("Frequently Asked Questions"),
            const SizedBox(height: 10),

            /// FAQ LIST
            ...controller.faqs.map((faq) {
              return _FaqTile(
                question: faq['question'] ?? '',
                answer: faq['answer'] ?? '',
                category: faq['category'] ?? 'General',
              );
            }).toList(),
            const SizedBox(height: 25),

            /// ================= RAISE TICKET =================
            _raiseTicketCard(),
            const SizedBox(height: 25),

            /// ================= MY TICKETS =================
            _sectionTitle("My Tickets"),

            const SizedBox(height: 10),

            Obx(() {
              if (controller.userTickets.isEmpty) {
                return _emptyTickets();
              }

              return Column(
                children: controller.userTickets.map((ticket) {
                  return _ticketCard(ticket);
                }).toList(),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _ticketCard(Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? 'open';

    Color statusColor;
    String statusText;

    switch (status) {
      case 'resolved':
        statusColor = Colors.green;
        statusText = "Resolved";
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        statusText = "In Progress";
        break;
      default:
        statusColor = Colors.red;
        statusText = "Open";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          /// LEFT ICON
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.2),
            child: Icon(Icons.support_agent, color: statusColor),
          ),

          const SizedBox(width: 12),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 4),

                Text(
                  ticket['category'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          /// STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyTickets() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "No tickets raised yet",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Text(
            "Your support tickets will appear here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo, Colors.blue]),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent, color: Colors.white, size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "We are here to help you 24x7",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  /// ================= CONTACT CARD =================
  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// ================= RAISE TICKET =================
  Widget _raiseTicketCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Still Need Help?",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Raise a support ticket and we will respond within 24 hours.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Get.to(() => RaiseTicketView());
            },
            child: const Text("Raise Ticket"),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  final String category;

  const _FaqTile({
    required this.question,
    required this.answer,
    required this.category,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.question)),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.answer,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
