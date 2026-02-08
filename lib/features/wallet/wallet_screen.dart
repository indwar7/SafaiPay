import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/payment_service.dart';
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
  final FirestoreService _firestoreService = FirestoreService();
  final PaymentService _paymentService = PaymentService();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
    _initializePayment();
  }

  void _initializePayment() {
    _paymentService.initialize(
      onSuccess: (paymentId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Withdrawal successful!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.red,
          ),
        );
      },
    );
  }

  Future<void> _loadTransactions() async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      _transactions = await _firestoreService.getUserTransactions(user.uid);
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
        const SnackBar(
          content: Text('You need at least 10 points to redeem'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Redeem Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Convert ${user.points} points to ₹${user.points}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              '1 Point = ₹1',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await userProvider.redeemPoints(user.points);
              await _loadTransactions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Points redeemed successfully!'),
                    backgroundColor: AppColors.primaryGreen,
                  ),
                );
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    final user = context.read<UserProvider>().currentUser;
    if (user == null || user.walletBalance < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum withdrawal amount is ₹100'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Withdraw to Bank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Withdraw ₹${user.walletBalance} to your bank account',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'You will receive the amount within 2-3 business days',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _paymentService.startPayment(
                amount: user.walletBalance,
                name: user.name ?? 'User',
                phoneNumber: user.phoneNumber,
              );
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Consumer<UserProvider>(builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SafaiPay Wallet',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Balance cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildBalanceCard(
                            'Points',
                            user?.points.toString() ?? '0',
                            AppColors.primaryGreen,
                            Icons.star,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBalanceCard(
                            'Balance',
                            '₹${user?.walletBalance ?? 0}',
                            AppColors.blue,
                            Icons.account_balance_wallet,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showRedeemDialog,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Redeem'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showWithdrawDialog,
                            icon: const Icon(Icons.account_balance),
                            label: const Text('Withdraw'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryGreen,
                unselectedLabelColor: AppColors.greyText,
                indicatorColor: AppColors.primaryGreen,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Earned'),
                  Tab(text: 'Redeemed'),
                ],
              ),
              // Transaction list
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

  Widget _buildBalanceCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.greyLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isEarned = transaction.type == 'earned';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isEarned
                          ? AppColors.primaryGreen
                          : AppColors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEarned ? Icons.add : Icons.remove,
                  color: isEarned ? AppColors.primaryGreen : AppColors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a')
                          .format(transaction.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.greyText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isEarned ? '+' : '-'}${transaction.points}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEarned ? AppColors.primaryGreen : AppColors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paymentService.dispose();
    super.dispose();
  }
}
