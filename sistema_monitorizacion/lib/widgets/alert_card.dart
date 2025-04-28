import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback onAcknowledge;

  const AlertCard({
    Key? key,
    required this.alert,
    required this.onAcknowledge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determinar el color según el nivel de alerta
    Color alertColor;
    IconData alertIcon;
    
    switch (alert.level.toLowerCase()) {
      case 'high':
        alertColor = Colors.red;
        alertIcon = Icons.arrow_upward;
        break;
      case 'low':
        alertColor = Colors.orange;
        alertIcon = Icons.arrow_downward;
        break;
      default:
        alertColor = Colors.blue;
        alertIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(alertIcon, color: alertColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Alerta ${alert.level.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: alertColor,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(alert.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID Lectura: ${alert.readingId}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onAcknowledge,
              style: ElevatedButton.styleFrom(
                backgroundColor: alertColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text('Reconocer Alerta'),
            ),
          ],
        ),
      ),
    );
  }
} 