import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/models/special_event.dart';
import '../providers/home_provider.dart';
import '../providers/settings_provider.dart';
import '../../../../core/utils/toast_utils.dart';
import 'special_event_details_screen.dart';

class SpecialEventsScreen extends StatelessWidget {
  const SpecialEventsScreen({super.key});

  // ── Add / Edit dialog ────────────────────────────────────────────────
  void _showEventDialog(
    BuildContext context,
    HomeProvider provider, {
    SpecialEvent? event,
  }) {
    final titleCtrl = TextEditingController(text: event?.title ?? '');
    final budgetCtrl = TextEditingController(
      text: event != null ? event.budget.toStringAsFixed(2) : '',
    );
    DateTimeRange? range = event != null
        ? DateTimeRange(start: event.startDate, end: event.endDate)
        : null;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: Text(event == null ? 'New Special Event' : 'Edit Event'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: budgetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter an amount';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDateRange: range,
                        );
                        if (picked != null) setState(() => range = picked);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date Range',
                          prefixIcon: Icon(Icons.date_range),
                        ),
                        child: Text(
                          range == null
                              ? 'Select dates'
                              : '${DateFormat('MMM d').format(range!.start)} \u2013 ${DateFormat('MMM d, yyyy').format(range!.end)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        if (range == null) {
                          ToastUtils.showInfo(ctx, 'Please select a date range');
                          return;
                        }
                        setState(() => isLoading = true);
                        try {
                          if (event == null) {
                            await provider.addSpecialEvent(
                              title: titleCtrl.text.trim(),
                              startDate: range!.start,
                              endDate: range!.end,
                              budget: double.parse(budgetCtrl.text),
                            );
                          } else {
                            await provider.updateSpecialEvent(
                              event.id,
                              title: titleCtrl.text.trim(),
                              startDate: range!.start,
                              endDate: range!.end,
                              budget: double.parse(budgetCtrl.text),
                            );
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setState(() => isLoading = false);
                          if (ctx.mounted) {
                            ToastUtils.showInfo(ctx, 'Error: $e');
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(event == null ? 'Create' : 'Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Delete confirm ───────────────────────────────────────────────────
  void _confirmDelete(
    BuildContext context,
    HomeProvider provider,
    String eventId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text(
                'This will permanently delete this event and all its expenses. Continue?'),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);
                        try {
                          await provider.deleteSpecialEvent(eventId);
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final sym = settings.getCurrencySymbol(provider.appSettings.currency);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Special Events')),
      body: StreamBuilder<List<SpecialEvent>>(
        stream: provider.getSpecialEvents(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snap.data ?? [];
          final totalAmount =
              events.fold(0.0, (sum, e) => sum + e.budget);

          return Column(
            children: [
              // ── Summary card ──
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                color: const Color(0xFFE8F5E9),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'All Events Amount',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$sym ${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Events list ──
              Expanded(
                child: events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_busy,
                                size: 64,
                                color: Theme.of(context).disabledColor),
                            const SizedBox(height: 12),
                            const Text('No special events yet'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: events.length,
                        itemBuilder: (context, i) {
                          final ev = events[i];
                          final dates =
                              '${DateFormat('MMM d').format(ev.startDate)} – ${DateFormat('MMM d, yyyy').format(ev.endDate)}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.black.withValues(alpha: 0.25),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SpecialEventDetailsScreen(event: ev),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            ev.title,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$sym ${ev.budget.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(dates,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 13)),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              size: 20, color: Colors.grey),
                                          onPressed: () => _showEventDialog(
                                              context, provider,
                                              event: ev),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 20, color: Colors.red),
                                          onPressed: () => _confirmDelete(
                                              context, provider, ev.id),
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(context, provider),
        child: const Icon(Icons.add),
      ),
    );
  }
}
