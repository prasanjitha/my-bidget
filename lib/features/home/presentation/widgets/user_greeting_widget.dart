import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../../../../core/utils/toast_utils.dart';

class UserGreetingWidget extends StatelessWidget {
  const UserGreetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final userName = homeProvider.userProfile?.name ?? 'User';

    String displayName = userName;
    if (userName.length > 20) {
      displayName = '${userName.substring(0, 20)}...';
    }

    return GestureDetector(
      onTap: userName.length > 20
          ? () {
              ToastUtils.showInfo(context, userName);
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Hello $displayName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
