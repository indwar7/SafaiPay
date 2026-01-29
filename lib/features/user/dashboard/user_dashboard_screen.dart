import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.mainBackground,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello ��", style: AppTextStyles.subHeading),
                const SizedBox(height: 4),
                Text("Your Dashboard", style: AppTextStyles.heading),

                const SizedBox(height: 24),

                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recycle Your\nWaste Material",
                            style: AppTextStyles.cardTitle,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("Get Started"),
                          ),
                        ],
                      ),
                      Icon(Icons.recycling, size: 64, color: AppColors.green),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Points Earned",
                          style: AppTextStyles.subHeading),
                      const SizedBox(height: 6),
                      Text("22", style: AppTextStyles.points),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
