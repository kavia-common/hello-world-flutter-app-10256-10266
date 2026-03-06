import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';

/// Notifications screen matching the Kotlin [NotificationsFragment].
///
/// Displays a themed notification list placeholder matching the
/// original app's static notification layout.
class NotificationsFragment extends StatelessWidget {
  /// Creates the notifications fragment widget.
  const NotificationsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample notifications matching the original app's style
    final notifications = [
      const _NotificationItem(
        title: 'Ride Completed',
        message: 'Your ride to Bandra Station has been completed successfully.',
        time: 'Today',
        icon: Icons.check_circle,
        color: Colors.green,
      ),
      const _NotificationItem(
        title: 'Payment Successful',
        message: 'Payment of ₹50 has been processed.',
        time: 'Today',
        icon: Icons.payment,
        color: AppTheme.accentOrange,
      ),
      const _NotificationItem(
        title: 'Welcome to Ride Karo!',
        message: 'Thank you for choosing Ride Karo. Enjoy your first ride!',
        time: '1 day ago',
        icon: Icons.celebration,
        color: AppTheme.primaryYellow,
      ),
      const _NotificationItem(
        title: 'Refer and Earn',
        message:
            'Invite your friends and earn ₹50 for every successful referral.',
        time: '3 days ago',
        icon: Icons.people,
        color: Colors.blue,
      ),
      const _NotificationItem(
        title: 'COVID-19 Safety',
        message: 'All riders wear masks and sanitize regularly. Stay safe!',
        time: '5 days ago',
        icon: Icons.health_and_safety,
        color: Colors.teal,
      ),
    ];

    return notifications.isEmpty
        ? const Center(
            child: Text(
              'No notifications yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final item = notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: item.color.withAlpha(30),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  trailing: Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
}
