import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/home_provider.dart';

class MonthlyOverviewGraph extends StatefulWidget {
  const MonthlyOverviewGraph({super.key});

  @override
  State<MonthlyOverviewGraph> createState() => _MonthlyOverviewGraphState();
}

class _MonthlyOverviewGraphState extends State<MonthlyOverviewGraph> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final budget = homeProvider.appSettings.monthlyAllocation;
    final spent = homeProvider.totalSpent;
    final remaining = homeProvider.remainingBalance.abs();
    final currency = homeProvider.appSettings.currency;
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    if (budget == 0) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                'Monthly Overview - $monthName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Icon(
                Icons.bar_chart,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Set budget to see overview',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxValue = [budget, spent, remaining].reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Overview - $monthName',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxValue * 1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      setState(() {
                        if (response != null &&
                            response.spot != null &&
                            event is FlTapUpEvent) {
                          _touchedIndex = response.spot!.touchedBarGroupIndex;
                        } else {
                          _touchedIndex = null;
                        }
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.black87,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        switch (groupIndex) {
                          case 0:
                            label = 'Budget';
                            break;
                          case 1:
                            label = 'Spent';
                            break;
                          case 2:
                            label = 'Remaining';
                            break;
                          default:
                            label = '';
                        }
                        return BarTooltipItem(
                          '$label\n${_getCurrencySymbol(currency)} ${NumberFormat('#,##0.00').format(rod.toY)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Budget';
                              break;
                            case 1:
                              text = 'Spent';
                              break;
                            case 2:
                              text = 'Remaining';
                              break;
                            default:
                              text = '';
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            NumberFormat.compact().format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeBarGroup(0, budget, Colors.blue),
                    _makeBarGroup(1, spent, Colors.orange),
                    _makeBarGroup(
                      2,
                      homeProvider.remainingBalance >= 0 ? remaining : 0,
                      Colors.green,
                    ),
                  ],
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue / 5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    final isTouched = _touchedIndex == x;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: isTouched ? 30 : 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'LKR':
        return 'RS';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return currency;
    }
  }
}
