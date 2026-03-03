import 'package:flutter/material.dart';

/// My Rides screen matching the Kotlin [MyRidesFragment].
///
/// Displays ride history with static placeholder entries matching
/// the current partially-implemented state of the original app.
class MyRidesFragment extends StatelessWidget {
  /// Creates the my rides fragment widget.
  const MyRidesFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Previous Rides',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Static ride entries matching layout placeholders
          _buildRideCard(
            status: 'Completed',
            statusColor: Colors.green,
            from: 'Bandra West',
            to: 'Bandra East',
            date: 'Today',
            fare: '₹ 50',
          ),
          _buildRideCard(
            status: 'Cancelled',
            statusColor: Colors.red,
            from: 'Gorai Naka',
            to: 'Santosh Bhuvan',
            date: '9 days ago',
            fare: '₹ 80',
          ),
          _buildRideCard(
            status: 'Completed',
            statusColor: Colors.green,
            from: 'Tulinj Road',
            to: 'Vasai',
            date: '9 days ago',
            fare: '₹ 120',
          ),
          const SizedBox(height: 24),
          // Active ride section
          const Text(
            'Active',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No active rides',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard({
    required String status,
    required Color statusColor,
    required String from,
    required String to,
    required String date,
    required String fare,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.two_wheeler, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Text(
                      'Bike Taxi',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            // From -> To
            Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.green),
                const SizedBox(width: 8),
                Text(from, style: const TextStyle(fontSize: 14)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Container(
                width: 2,
                height: 16,
                color: Colors.grey.shade300,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 10, color: Colors.red),
                const SizedBox(width: 6),
                Text(to, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            // Status + fare row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  fare,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
