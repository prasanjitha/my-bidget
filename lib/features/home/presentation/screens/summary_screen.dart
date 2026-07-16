import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../../domain/models/expense.dart';
import '../widgets/spent_today_card.dart';
import '../widgets/daily_expenses_list.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/category_budget_card.dart';
import '../widgets/monthly_history_list.dart';
import 'savings_screen.dart';
import 'package:intl/intl.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    // Refresh is handled automatically via StreamBuilder
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Summary',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            fontFamily: 'Roboto',
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            fontFamily: 'Roboto',
          ),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDailyTab(),
            _buildMonthlyTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'summary_fab',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SavingsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.savings),
        label: const Text('Savings'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDailyTab() {
    final homeProvider = context.watch<HomeProvider>();
    final currency = homeProvider.appSettings.currency;

    // Get expenses for last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    return StreamBuilder<List<Expense>>(
      stream: homeProvider.getExpensesByDateRange(thirtyDaysAgo, now),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data ?? <Expense>[];

        // Calculate today's spent from expenses
        final today = DateTime.now();
        final todayExpenses = expenses.where((expense) {
          return expense.date.year == today.year &&
                 expense.date.month == today.month &&
                 expense.date.day == today.day;
        }).toList();

        final todaySpent = todayExpenses.fold<double>(
          0.0,
          (sum, expense) => sum + expense.amount,
        );

        return ListView(
          children: [
            SpentTodayCard(
              amount: todaySpent,
              currency: currency,
            ),
            if (expenses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              DailyExpensesList(
                expenses: expenses,
                categories: homeProvider.categories,
                currency: currency,
              ),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyTab() {
    final homeProvider = context.watch<HomeProvider>();
    final currency = homeProvider.appSettings.currency;
    final currentCycle = homeProvider.currentBudgetCycle;
    final allocated = homeProvider.appSettings.monthlyAllocation;
    final totalSpent = homeProvider.totalSpent;

    // Format current month
    String monthYear = 'Current Month';
    try {
      final parts = currentCycle.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final date = DateTime(year, month);
      monthYear = DateFormat('MMMM yyyy').format(date);
    } catch (e) {
      // Use default
    }

    return FutureBuilder<List<String>>(
      future: homeProvider.getPastBudgetCycles(12),
      builder: (context, snapshot) {
        final pastCycles = (snapshot.data ?? [])
            .where((cycle) => cycle != currentCycle)
            .toList();

        return ListView(
          children: [
            MonthlySummaryCard(
              monthYear: monthYear,
              totalSpent: totalSpent,
              allocated: allocated,
              currency: currency,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Category Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const CategoryBudgetCard(),
            if (pastCycles.isNotEmpty)
              MonthlyHistoryList(
                budgetCycles: pastCycles,
                currency: currency,
              ),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
