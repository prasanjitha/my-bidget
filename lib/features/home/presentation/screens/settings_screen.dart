import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../providers/settings_provider.dart';
import '../../../../services/pdf_service.dart';
import 'categories_screen.dart';
import 'special_events_screen.dart';
import '../../../../core/utils/toast_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Consumer2<HomeProvider, SettingsProvider>(
        builder: (context, homeProvider, settingsProvider, child) {
          final userProfile = homeProvider.userProfile;
          final appSettings = homeProvider.appSettings;
          final currentCycle = homeProvider.currentBudgetCycle;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildDarkModeCard(context, settingsProvider),
              const SizedBox(height: 8),
              _buildCurrencyCard(context, homeProvider, appSettings),
              const SizedBox(height: 8),
              _buildMonthlyAllocationCard(context, homeProvider, appSettings),
              const SizedBox(height: 8),
              _buildProfileNameCard(context, homeProvider, userProfile?.name),
              const SizedBox(height: 8),
              _buildBudgetCycleCard(context, homeProvider, appSettings, currentCycle),
              const SizedBox(height: 8),
              _buildCategoriesCard(context),
              const SizedBox(height: 8),
              _buildSpecialEventsCard(context),
              const SizedBox(height: 8),
              _buildExportReportCard(context),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDarkModeCard(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.dark_mode),
        title: const Text('Dark Mode'),
        trailing: Switch(
          value: settingsProvider.isDarkMode,
          onChanged: (value) {
            settingsProvider.toggleDarkMode();
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(BuildContext context, HomeProvider homeProvider, appSettings) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.attach_money),
        title: const Text('Set Currency'),
        subtitle: Text('${appSettings.currency} (${settingsProvider.getCurrencySymbol(appSettings.currency)})'),
        trailing: ElevatedButton(
          onPressed: () => _showCurrencyDialog(context, homeProvider, appSettings),
          child: const Text('SET'),
        ),
      ),
    );
  }

  Widget _buildMonthlyAllocationCard(BuildContext context, HomeProvider homeProvider, appSettings) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet),
        title: const Text('Set Monthly Allocation'),
        trailing: ElevatedButton(
          onPressed: () => _showMonthlyAllocationDialog(context, homeProvider, appSettings),
          child: const Text('SET'),
        ),
      ),
    );
  }

  Widget _buildProfileNameCard(BuildContext context, HomeProvider homeProvider, String? currentName) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Change Profile Name'),
        subtitle: Text(currentName ?? 'Not Set'),
        trailing: ElevatedButton(
          onPressed: () => _showProfileNameDialog(context, homeProvider, currentName),
          child: const Text('SET'),
        ),
      ),
    );
  }

  Widget _buildBudgetCycleCard(BuildContext context, HomeProvider homeProvider, appSettings, String currentCycle) {
    final startDay = appSettings.budgetCycleStartDay;
    final cycleText = _getCycleDisplayText(startDay);

    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text('Budget Cycle Start'),
        subtitle: Text(cycleText),
        trailing: ElevatedButton(
          onPressed: () => _showBudgetCycleDialog(context, homeProvider, startDay),
          child: const Text('SET'),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.category),
        title: const Text('Categories'),
        subtitle: const Text('Manage expense categories'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CategoriesScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialEventsCard(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: const Text('Special Events'),
        subtitle: const Text('Manage special events'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SpecialEventsScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExportReportCard(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf),
        title: const Text('Export Monthly Report'),
        trailing: ElevatedButton(
          onPressed: () => _generatePdfReport(context),
          child: const Text('GENERATE'),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirmed == true && context.mounted) {
            await context.read<AuthProvider>().logout();
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  String _getCycleDisplayText(int startDay) {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    if (now.day < startDay) {
      month -= 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
    }

    final startDate = DateTime(year, month, startDay);

    int endMonth = month + 1;
    int endYear = year;
    if (endMonth > 12) {
      endMonth = 1;
      endYear += 1;
    }

    final endDate = DateTime(endYear, endMonth, startDay).subtract(const Duration(days: 1));

    final dateFormat = DateFormat('MMM d, yyyy');
    return '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
  }

  void _showCurrencyDialog(BuildContext context, HomeProvider homeProvider, appSettings) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    String selectedCurrency = appSettings.currency;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Currency'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: settingsProvider.availableCurrencies.map((currency) {
                return RadioListTile<String>(
                  title: Text('$currency (${settingsProvider.getCurrencySymbol(currency)})'),
                  subtitle: Text(settingsProvider.getCurrencyName(currency)),
                  value: currency,
                  groupValue: selectedCurrency,
                  onChanged: (value) {
                    setState(() {
                      selectedCurrency = value!;
                    });
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await homeProvider.updateCurrency(selectedCurrency);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ToastUtils.showInfo(context, 'Currency updated');
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMonthlyAllocationDialog(BuildContext context, HomeProvider homeProvider, appSettings) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final controller = TextEditingController(
      text: appSettings.monthlyAllocation.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Allocation'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '${settingsProvider.getCurrencySymbol(appSettings.currency)} ',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid number';
              }
              if (amount < 0) {
                return 'Amount must be positive';
              }
              if (amount > 999999999) {
                return 'Amount too large';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(controller.text);
                try {
                  await homeProvider.setMonthlyBudget(
                    amount,
                    appSettings.currency,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ToastUtils.showInfo(context, 'Monthly allocation updated');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showInfo(context, 'Error: $e');
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showProfileNameDialog(BuildContext context, HomeProvider homeProvider, String? currentName) {
    final controller = TextEditingController(text: currentName ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Profile Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name cannot be empty';
              }
              if (value.trim().length > 50) {
                return 'Name too long (max 50 characters)';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await homeProvider.updateUserName(controller.text.trim());
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ToastUtils.showInfo(context, 'Profile name updated');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ToastUtils.showInfo(context, 'Error: $e');
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBudgetCycleDialog(BuildContext context, HomeProvider homeProvider, int currentStartDay) {
    int selectedDay = currentStartDay;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Cycle Start',
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select the starting day of your budget cycle',
                    style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 31,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isSelected = day == selectedDay;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedDay = day;
                              });
                            },
                            child: Container(
                              width: 50,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).dividerColor,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Budget Tracking Period',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This Month's Cycle: ${_getPreviewCycleText(selectedDay)}",
                    style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await homeProvider.updateBudgetCycleStartDay(selectedDay);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ToastUtils.showInfo(context, 'Budget cycle updated');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ToastUtils.showInfo(context, 'Error: $e');
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getPreviewCycleText(int startDay) {
    final now = DateTime.now();
    int year = now.year;
    int month = now.month;

    if (now.day < startDay) {
      month -= 1;
      if (month == 0) {
        month = 12;
        year -= 1;
      }
    }

    final startDate = DateTime(year, month, startDay);

    int endMonth = month + 1;
    int endYear = year;
    if (endMonth > 12) {
      endMonth = 1;
      endYear += 1;
    }

    final daysInMonth = DateTime(endYear, endMonth + 1, 0).day;
    final endDay = startDay > daysInMonth ? daysInMonth : startDay - 1;
    final endDate = DateTime(endYear, endMonth, endDay == 0 ? daysInMonth : endDay);

    final dateFormat = DateFormat('MMM d, yyyy');
    return '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
  }

  Future<void> _generatePdfReport(BuildContext context) async {
    final homeProvider = context.read<HomeProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    final userProfile = homeProvider.userProfile;
    if (userProfile == null) {
      ToastUtils.showError(
        context,
        'Unable to generate report. User profile not loaded.',
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating PDF report...'),
          ],
        ),
      ),
    );

    try {
      final pdfService = PdfService();
      final filePath = await pdfService.generateMonthlyReport(
        userProfile: userProfile,
        appSettings: homeProvider.appSettings,
        categories: homeProvider.categories,
        expenses: homeProvider.expenses,
        budgetCycle: homeProvider.currentBudgetCycle,
        totalSpent: homeProvider.totalSpent,
        remainingBalance: homeProvider.remainingBalance,
        currency: settingsProvider.currency,
        currencySymbol: settingsProvider.getCurrencySymbol(),
      );

      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (filePath != null) {
          // Show success with multiple options
          _showReportActionsDialog(context, filePath);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        String errorMessage = 'Unable to generate report. Please try again.';
        if (e.toString().contains('permission')) {
          errorMessage = 'Storage permission required to save report';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _generatePdfReport(context);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showReportActionsDialog(BuildContext context, String filePath) {
    final homeProvider = context.read<HomeProvider>();
    final cycle = homeProvider.currentBudgetCycle;
    final fileName = 'Bidget_Report_$cycle.pdf';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Report Generated Successfully',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action buttons
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.open_in_new, color: Colors.white, size: 20),
                ),
                title: const Text('View PDF'),
                subtitle: const Text('Open in PDF viewer'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _openPdfReport(context, filePath);
                },
              ),
              const Divider(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.share, color: Colors.white, size: 20),
                ),
                title: const Text('Share PDF'),
                subtitle: const Text('Share via apps'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _sharePdfReport(context, filePath);
                },
              ),
              const Divider(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.folder_open, color: Colors.white, size: 20),
                ),
                title: const Text('Saved Location'),
                subtitle: const Text('Downloads folder'),
                onTap: () {
                  ToastUtils.showInfo(
                    context,
                    'Saved to: /storage/emulated/0/Download/$fileName',
                  );
                },
              ),
              const SizedBox(height: 16),
              // Close button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPdfReport(BuildContext context, String filePath) async {
    try {
      final homeProvider = context.read<HomeProvider>();
      final cycle = homeProvider.currentBudgetCycle;

      // Use share to open - this will show "Open with" dialog
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: "Bidget Report - $cycle",
        subject: 'Bidget Monthly Report',
      );

      if (context.mounted) {
        if (result.status == ShareResultStatus.success) {
          ToastUtils.showSuccess(context, 'PDF opened successfully');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, 'Unable to open PDF. Try sharing instead.');
      }
    }
  }

  Future<void> _sharePdfReport(BuildContext context, String filePath) async {
    try {
      final homeProvider = context.read<HomeProvider>();
      final cycle = homeProvider.currentBudgetCycle;

      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: "Here's my Bidget budget report for $cycle",
        subject: 'Bidget Monthly Report',
      );

      if (context.mounted) {
        if (result.status == ShareResultStatus.success) {
          ToastUtils.showSuccess(context, 'PDF shared successfully');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showError(context, 'Unable to share report');
      }
    }
  }
}
