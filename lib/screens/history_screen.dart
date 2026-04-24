import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bmi_record.dart';
import '../services/bmi_history_service.dart';
import '../widgets/glass_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.historyService});

  final BmiHistoryService historyService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<BmiRecord>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = widget.historyService.getRecords();
  }

  Future<void> _refresh() async {
    setState(() {
      _recordsFuture = widget.historyService.getRecords();
    });
  }

  Future<void> _deleteOne(String id) async {
    await widget.historyService.deleteRecord(id);
    await _refresh();
  }

  Future<void> _clearAll() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete all records?'),
          content: const Text(
            'This action will remove your complete BMI history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget.historyService.clearAll();
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI History'),
        actions: [
          IconButton(
            tooltip: 'Delete all history',
            onPressed: _clearAll,
            icon: const Icon(Icons.delete_forever_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [Color(0xFF121722), Color(0xFF0B101A)]
                : const [Color(0xFFF3F6FB), Color(0xFFE7EEF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<BmiRecord>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<BmiRecord> records = snapshot.data ?? <BmiRecord>[];
            if (records.isEmpty) {
              return const Center(
                child: Text(
                  'No saved BMI records yet.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final BmiRecord record = records[index];
                final DateTime parsed = DateTime.parse(
                  record.createdAtIso,
                ).toLocal();

                return Dismissible(
                  key: ValueKey<String>(record.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.delete_rounded),
                  ),
                  onDismissed: (_) => _deleteOne(record.id),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monitor_weight_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'BMI ${record.bmi.toStringAsFixed(1)} - ${record.category}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${record.gender}, Age ${record.age}, Height ${record.heightCm.round()} cm, Weight ${record.weightKg} kg',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(parsed),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
