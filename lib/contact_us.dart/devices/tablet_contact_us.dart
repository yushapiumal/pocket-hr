// filepath: /home/akesh/Work/new_hr/cn_pocket_hr/lib/screens/common/contact_us_screen.dart
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsTabletScreen extends StatefulWidget {
  const ContactUsTabletScreen({Key? key}) : super(key: key);

  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);
  static const double _g4 = 4;
  static const double _g8 = 8;
  static const double _g12 = 12;
  static const double _g16 = 16;
  static const double _g24 = 24;

  @override
  State<ContactUsTabletScreen> createState() => _ContactUsTabletScreenState();
}

class _ContactUsTabletScreenState extends State<ContactUsTabletScreen> {
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ContactUsTabletScreen._pageBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(ContactUsTabletScreen._g12, ContactUsTabletScreen._g16, ContactUsTabletScreen._g12, ContactUsTabletScreen._g8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: const Icon(Icons.navigate_before, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(width: ContactUsTabletScreen._g12),
                  const Expanded(
                    child: Text(
                      'Contact Us',
                      style: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(ContactUsTabletScreen._g16),
                children: [
                  // Hero banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [HRColors.orangeColor, HRColors.darkOrangeColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
                        SizedBox(height: ContactUsTabletScreen._g12),
                        Text(
                          'We\'re here to help',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: ContactUsTabletScreen._g4),
                        Text(
                          'Reach out to us through any of the channels below.',
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ContactUsTabletScreen._g24),

                  const _SectionLabel(label: 'Get in touch'),
                  const SizedBox(height: ContactUsTabletScreen._g12),

                  _ContactTile(
                    icon: Icons.email_outlined,
                    iconColor: Colors.blue,
                    title: 'Email Support',
                    subtitle: 'support@example.com',
                    onTap: () => _launch('mailto:support@example.com'),
                  ),
                  const SizedBox(height: ContactUsTabletScreen._g8),
                  _ContactTile(
                    icon: Icons.phone_outlined,
                    iconColor: Colors.green,
                    title: 'Phone Support',
                    subtitle: '+94 11 000 0000',
                    onTap: () => _launch('tel:+940110000000'),
                  ),
                  const SizedBox(height: ContactUsTabletScreen._g8),
                  _ContactTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: Colors.teal,
                    title: 'Live Chat',
                    subtitle: 'Chat with us on WhatsApp',
                    onTap: () => _launch('https://wa.me/940110000000'),
                  ),

                  const SizedBox(height: ContactUsTabletScreen._g24),
                  const _SectionLabel(label: 'Office'),
                  const SizedBox(height: ContactUsTabletScreen._g12),

                  Container(
                    padding: const EdgeInsets.all(ContactUsTabletScreen._g16),
                    decoration: BoxDecoration(
                      color: ContactUsTabletScreen._surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: HRColors.orangeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.location_on_outlined, color: HRColors.orangeColor),
                        ),
                        const SizedBox(width: ContactUsTabletScreen._g12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Head Office', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87)),
                              SizedBox(height: ContactUsTabletScreen._g4),
                              Text('123 Main Street,\nColombo 03,\nSri Lanka.', style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ContactUsTabletScreen._g24),
                  const _SectionLabel(label: 'Business Hours'),
                  const SizedBox(height: ContactUsTabletScreen._g12),

                  _HoursRow(day: 'Monday – Friday', hours: '8:30 AM – 5:30 PM'),
                  _HoursRow(day: 'Saturday', hours: '8:30 AM – 1:30 PM'),
                  _HoursRow(day: 'Sunday', hours: 'Closed', isOff: true),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87));
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;
  final bool isOff;

  const _HoursRow({required this.day, required this.hours, this.isOff = false});

  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Text(
            hours,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isOff ? Colors.red : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
