import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/user_greeting_widget.dart';
import '../widgets/monthly_budget_card.dart';
import '../widgets/category_budget_card.dart';
import '../widgets/total_spend_card.dart';
import '../widgets/remaining_balance_card.dart';
import '../widgets/monthly_overview_graph.dart';
import '../../../../core/utils/toast_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final authProvider = context.read<AuthProvider>();
    final homeProvider = context.read<HomeProvider>();

    if (authProvider.userId != null) {
      homeProvider.initialize(authProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _initializeData();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: const [
            UserGreetingWidget(),
            SizedBox(height: 16),
            MonthlyBudgetCard(),
            SizedBox(height: 12),
            CategoryBudgetCard(),
            SizedBox(height: 12),
            TotalSpendCard(),
            SizedBox(height: 12),
            RemainingBalanceCard(),
            SizedBox(height: 12),
            MonthlyOverviewGraph(),
            SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'home_refresh_fab',
        onPressed: _isRefreshing
            ? null
            : () async {
                setState(() {
                  _isRefreshing = true;
                });
                _initializeData();
                await Future.delayed(const Duration(milliseconds: 1200));
                if (!mounted) return;
                setState(() {
                  _isRefreshing = false;
                });
                if (context.mounted) {
                  ToastUtils.showSuccess(context, 'Data refreshed successfully');
                }
              },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: _isRefreshing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.refresh_rounded, size: 20),
      ),
    );
  }
}
