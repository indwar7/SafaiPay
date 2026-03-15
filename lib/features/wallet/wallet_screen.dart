import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../models/transaction_model.dart';
import '../../core/theme/app_colors.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      _transactions = await _apiService.getTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showRedeemDialog() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.currentUser;
    if (user == null || user.points < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need at least 10 points to redeem',
            style: GoogleFonts.dmSans(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Redeem Points',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            color: AppColors.textWhite,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Convert ${user.points} points to \u20B9${user.points}',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '1 Point = \u20B91',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await userProvider.redeemPoints(user.points);
              await _loadTransactions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Points redeemed successfully!',
                      style: GoogleFonts.dmSans(color: AppColors.textOnLime),
                    ),
                    backgroundColor: AppColors.neonLime,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: AppColors.textOnLime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Redeem',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.walletBalance < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum withdrawal amount is \u20B9100',
            style: GoogleFonts.dmSans(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Withdraw to Bank',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            color: AppColors.textWhite,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Withdraw \u20B9${user.walletBalance} to your bank account',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You will receive the amount within 2-3 business days',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.withdraw(user.walletBalance.toDouble());
                // Reload profile + transactions
                if (context.mounted) {
                  context.read<UserProvider>().loadUser();
                }
                await _loadTransactions();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Withdrawal submitted! You\'ll receive it in 2-3 business days.',
                        style: GoogleFonts.dmSans(color: AppColors.textOnLime),
                      ),
                      backgroundColor: AppColors.neonLime,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceAll('Exception: ', ''),
                        style: GoogleFonts.dmSans(color: AppColors.textWhite),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: AppColors.textOnLime,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Proceed',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Groups transactions by date label (Today, Yesterday, or formatted date).
  Map<String, List<TransactionModel>> _groupByDate(
      List<TransactionModel> txns) {
    final Map<String, List<TransactionModel>> grouped = {};
    final now = DateTime.now();
    for (final t in txns) {
      String label;
      final diff = DateTime(now.year, now.month, now.day)
          .difference(
              DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day))
          .inDays;
      if (diff == 0) {
        label = 'Today';
      } else if (diff == 1) {
        label = 'Yesterday';
      } else {
        label = DateFormat('dd MMM yyyy').format(t.createdAt);
      }
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(t);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<UserProvider>(builder: (context, userProvider, child) {
          final user = userProvider.currentUser;
          final balance = user?.walletBalance ?? 0;
          final points = user?.points ?? 0;

          return Column(
            children: [
              // HERO BALANCE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      AppColors.neonLime.withValues(alpha: 0.06),
                      AppColors.primaryBg,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Animated balance
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: balance.toDouble()),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutExpo,
                      builder: (context, value, child) {
                        return Text(
                          '\u20B9${NumberFormat('#,##0.00').format(value)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textWhite,
                            height: 1.1,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Animated points
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: points.toDouble()),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutExpo,
                      builder: (context, value, child) {
                        return Text(
                          '${NumberFormat('#,###').format(value.toInt())} pts',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 32,
                            color: AppColors.neonLime,
                            letterSpacing: 1.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ACTION BUTTONS ROW
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'Add Points',
                          onTap: _showRedeemDialog,
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.account_balance_outlined,
                          label: 'Withdraw',
                          onTap: _showWithdrawDialog,
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.history_outlined,
                          label: 'History',
                          onTap: () {
                            _tabController.animateTo(0);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // TABS
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: AppColors.borderDefault, width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.neonLime,
                  unselectedLabelColor: AppColors.textTertiary,
                  indicatorColor: AppColors.neonLime,
                  indicatorWeight: 2,
                  labelStyle: GoogleFonts.barlowSemiCondensed(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.barlowSemiCondensed(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Earned'),
                    Tab(text: 'Redeemed'),
                  ],
                ),
              ),

              // TRANSACTION LIST
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionList(_transactions),
                    _buildTransactionList(
                      _transactions
                          .where((t) => t.type == 'earned')
                          .toList(),
                    ),
                    _buildTransactionList(
                      _transactions
                          .where((t) => t.type == 'redeemed')
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface3,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDefault, width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.neonLime, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.barlowSemiCondensed(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonLime),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.neonLime.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'NO TRANSACTIONS YET',
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                color: AppColors.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your activity will show up here',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDate(transactions);
    final dateKeys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: dateKeys.length,
      itemBuilder: (context, sectionIndex) {
        final dateLabel = dateKeys[sectionIndex];
        final items = grouped[dateLabel]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                dateLabel.toUpperCase(),
                style: GoogleFonts.barlowSemiCondensed(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...items.map((transaction) {
              final isEarned = transaction.type == 'earned';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.borderDefault,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isEarned
                            ? AppColors.neonLime.withValues(alpha: 0.12)
                            : AppColors.error.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEarned
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color:
                            isEarned ? AppColors.neonLime : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Description + time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('hh:mm a')
                                .format(transaction.createdAt),
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Amount
                    Text(
                      '${isEarned ? '+' : '-'}\u20B9${transaction.points}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:
                            isEarned ? AppColors.neonLime : AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
