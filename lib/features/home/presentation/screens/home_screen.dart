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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final homeProvider = context.read<HomeProvider>();

      if (authProvider.userId != null) {
        homeProvider.initialize(authProvider.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          final authProvider = context.read<AuthProvider>();
          final homeProvider = context.read<HomeProvider>();

          if (authProvider.userId != null) {
            homeProvider.initialize(authProvider.userId!);
          }
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
    );
  }
}
