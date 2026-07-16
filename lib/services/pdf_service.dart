import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../features/home/domain/models/user_profile.dart';
import '../features/home/domain/models/app_settings.dart';
import '../features/home/domain/models/category.dart';
import '../features/home/domain/models/expense.dart';

class PdfService {
  Future<String?> generateMonthlyReport({
    required UserProfile userProfile,
    required AppSettings appSettings,
    required List<Category> categories,
    required List<Expense> expenses,
    required String budgetCycle,
    required double totalSpent,
    required double remainingBalance,
    required String currency,
    required String currencySymbol,
  }) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          final manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            throw Exception('Storage permission required to save report');
          }
        }
      }

      final pdf = pw.Document();

      // Calculate cycle dates
      final cycleParts = budgetCycle.split('-');
      final year = int.parse(cycleParts[0]);
      final month = int.parse(cycleParts[1]);
      final startDay = appSettings.budgetCycleStartDay;

      final startDate = DateTime(year, month, startDay);
      int endMonth = month + 1;
      int endYear = year;
      if (endMonth > 12) {
        endMonth = 1;
        endYear += 1;
      }
      final endDate = DateTime(endYear, endMonth, startDay).subtract(const Duration(days: 1));

      final dateFormat = DateFormat('MMM d, yyyy');
      final cycleText = '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';

      // Calculate category breakdown
      final categoryBreakdown = <String, Map<String, double>>{};
      for (var category in categories) {
        final categoryExpenses = expenses.where((e) => e.categoryId == category.id);
        final spent = categoryExpenses.fold(0.0, (sum, e) => sum + e.amount);
        categoryBreakdown[category.name] = {
          'allocated': category.allocatedBudget,
          'spent': spent,
          'remaining': category.allocatedBudget - spent,
        };
      }

      // Group expenses by date
      final expensesByDate = <String, List<Expense>>{};
      for (var expense in expenses) {
        final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
        if (!expensesByDate.containsKey(dateKey)) {
          expensesByDate[dateKey] = [];
        }
        expensesByDate[dateKey]!.add(expense);
      }

      // Sort dates descending
      final sortedDates = expensesByDate.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Bidget - Monthly Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // User Information
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Report Information',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildInfoRow('Name:', userProfile.name ?? 'User'),
                    _buildInfoRow('Budget Cycle:', cycleText),
                    _buildInfoRow('Report Generated:', DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())),
                    _buildInfoRow('Currency:', '$currency ($currencySymbol)'),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Summary Section
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Budget Summary',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildInfoRow(
                      'Allocated Budget:',
                      '$currencySymbol ${_formatAmount(appSettings.monthlyAllocation)}',
                    ),
                    _buildInfoRow(
                      'Total Spent:',
                      '$currencySymbol ${_formatAmount(totalSpent)}',
                    ),
                    _buildInfoRow(
                      'Remaining Balance:',
                      '$currencySymbol ${_formatAmount(remainingBalance)}',
                      valueColor: remainingBalance < 0 ? PdfColors.red : PdfColors.green,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      children: [
                        pw.Text('Status: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: pw.BoxDecoration(
                            color: remainingBalance >= 0 ? PdfColors.green100 : PdfColors.red100,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            remainingBalance >= 0 ? 'In Budget' : 'Over Budget',
                            style: pw.TextStyle(
                              color: remainingBalance >= 0 ? PdfColors.green800 : PdfColors.red800,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Category Breakdown
              pw.Text(
                'Category Breakdown',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildCategoryTable(categoryBreakdown, currencySymbol),

              pw.SizedBox(height: 20),

              // Detailed Expenses
              pw.Text(
                'Detailed Expenses',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              if (expenses.isEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    'No expenses recorded for this cycle',
                    style: const pw.TextStyle(color: PdfColors.grey600),
                  ),
                )
              else
                ..._buildExpenseTables(expensesByDate, sortedDates, categories, currencySymbol),

              // Footer
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generated by Bidget App',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                    ),
                    pw.Text(
                      'Generated on: ${DateFormat('MMM d, yyyy HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF
      final output = await _getDownloadDirectory();
      final fileName = 'Bidget_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      rethrow;
    }
  }

  pw.Widget _buildInfoRow(String label, String value, {PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCategoryTable(
    Map<String, Map<String, double>> categoryBreakdown,
    String currencySymbol,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Category', isHeader: true),
            _buildTableCell('Allocated', isHeader: true),
            _buildTableCell('Spent', isHeader: true),
            _buildTableCell('Remaining', isHeader: true),
          ],
        ),
        // Rows
        ...categoryBreakdown.entries.map((entry) {
          return pw.TableRow(
            children: [
              _buildTableCell(entry.key),
              _buildTableCell('$currencySymbol ${_formatAmount(entry.value['allocated']!)}'),
              _buildTableCell('$currencySymbol ${_formatAmount(entry.value['spent']!)}'),
              _buildTableCell(
                '$currencySymbol ${_formatAmount(entry.value['remaining']!)}',
                color: entry.value['remaining']! < 0 ? PdfColors.red : null,
              ),
            ],
          );
        }),
        // Total
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('Total', isHeader: true),
            _buildTableCell(
              '$currencySymbol ${_formatAmount(categoryBreakdown.values.fold(0.0, (sum, v) => sum + v['allocated']!))}',
              isHeader: true,
            ),
            _buildTableCell(
              '$currencySymbol ${_formatAmount(categoryBreakdown.values.fold(0.0, (sum, v) => sum + v['spent']!))}',
              isHeader: true,
            ),
            _buildTableCell(
              '$currencySymbol ${_formatAmount(categoryBreakdown.values.fold(0.0, (sum, v) => sum + v['remaining']!))}',
              isHeader: true,
            ),
          ],
        ),
      ],
    );
  }

  List<pw.Widget> _buildExpenseTables(
    Map<String, List<Expense>> expensesByDate,
    List<String> sortedDates,
    List<Category> categories,
    String currencySymbol,
  ) {
    final widgets = <pw.Widget>[];

    for (var dateKey in sortedDates) {
      final dateExpenses = expensesByDate[dateKey]!;
      final date = DateTime.parse(dateKey);
      final dayTotal = dateExpenses.fold(0.0, (sum, e) => sum + e.amount);

      widgets.add(pw.SizedBox(height: 10));
      widgets.add(
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                DateFormat('EEE, MMM d, yyyy').format(date),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Total: $currencySymbol ${_formatAmount(dayTotal)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      );
      widgets.add(pw.SizedBox(height: 5));

      widgets.add(
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildTableCell('Description', isHeader: true),
                _buildTableCell('Category', isHeader: true),
                _buildTableCell('Amount', isHeader: true),
              ],
            ),
            ...dateExpenses.map((expense) {
              final category = categories.firstWhere(
                (c) => c.id == expense.categoryId,
                orElse: () => Category(
                  id: '',
                  name: 'Unknown',
                  isDefault: false,
                  allocatedBudget: 0,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
              return pw.TableRow(
                children: [
                  _buildTableCell(expense.description),
                  _buildTableCell(category.name),
                  _buildTableCell('$currencySymbol ${_formatAmount(expense.amount)}'),
                ],
              );
            }),
          ],
        ),
      );
    }

    return widgets;
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
          fontSize: isHeader ? 11 : 10,
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Try to get the Downloads directory
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory;
      }
      // Fallback to app directory
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
}
