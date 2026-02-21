import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/wallet_provider.dart';
import '../data/models/wallet_models.dart';

class WalletScreen extends ConsumerWidget {
  final String phoneOrEmail;

  const WalletScreen({
    super.key,
    required this.phoneOrEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    if (walletState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error if wallet data failed to load
    if (walletState.errorMessage != null) {
      return Column(
        children: [
          const CustomAppBar(
            title: 'My Wallet',
            showLeading: false,
          ),
          Expanded(
            child: ErrorStateWidget(
              errorMessage: walletState.errorMessage!,
              title: 'Wallet Error',
              onRetry: () => ref.read(walletProvider.notifier).fetchWallet(),
            ),
          ),
        ],
      );
    }

    // Get data from provider (populated from API)
    final double kmDriven = walletState.totalKm;
    final double kmRate = walletState.ratePerKm;
    final double netPay = walletState.balance;
    final List<Map<String, dynamic>> dailyIncentives = walletState.dailyLogs
      .map((log) => {
          'date': log.date,
          'km': log.kilometersDriven,
          'amount': log.calculatedEarnings,
        })
      .toList();

    return Column(
      children: [
        const CustomAppBar(
          title: 'My Wallet',
          showLeading: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Incentive Summary Card
                  _buildIncentiveSummaryCard(context, netPay, walletState.nextPayoutDate),
                  SizedBox(height: ResponsiveUtils.padding(context, 24)),

                  // Monthly Performance Breakdown
                  _buildEarningsBreakdownCard(context, kmDriven, kmRate, netPay),
                  SizedBox(height: ResponsiveUtils.padding(context, 24)),

                  // Daily Incentive Log
                  _buildDailyBreakdownCard(context, dailyIncentives),
                  SizedBox(height: ResponsiveUtils.padding(context, 24)),

                  // Monthly Statements
                  _buildMonthlyStatementsCard(context, walletState.monthlyStatements, ref),
                  SizedBox(height: ResponsiveUtils.padding(context, 100)), // Bottom padding for nav bar
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncentiveSummaryCard(BuildContext context, double totalAmount, String nextPayout) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFFEEB94),
            const Color(0xFFFFC200).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Incentive Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Total Unpaid Incentive',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹ ${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Next Payout: $nextPayout',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 20,
            child: Image.asset(
              'assets/images/wallet.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdownCard(BuildContext context, double kmDriven, double kmRate, double netPay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRow('Total KM Driven', '${kmDriven.toStringAsFixed(0)} KM'),
              const SizedBox(height: 12),
              _buildRow('Incentive Rate', '₹ ${kmRate.toStringAsFixed(2)} / KM'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1),
              ),
              _buildRow('Net Pay (Incentive)', '₹ ${netPay.toStringAsFixed(2)}', isBold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyBreakdownCard(BuildContext context, List<Map<String, dynamic>> dailyIncentives) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Incentive Log',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: _tableHeader("Date")),
                  Expanded(flex: 2, child: _tableHeader("KM Driven")),
                  Expanded(flex: 2, child: _tableHeader("Incentive")),
                ],
              ),
              const Divider(height: 24),
              ...dailyIncentives.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        item["date"],
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${item["km"]} KM",
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "₹ ${item["amount"].toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStatementsCard(BuildContext context, List<MonthlyStatementModel> statements, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Monthly Statements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () {
                ref.read(walletProvider.notifier).fetchMonthlyStatements();
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (statements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade400, size: 40),
                const SizedBox(height: 8),
                const Text(
                  'No monthly statements available',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(flex: 2, child: _tableHeader("Month")),
                  Expanded(flex: 2, child: _tableHeader("Year")),
                  Expanded(flex: 2, child: _tableHeader("Total Earnings")),
                ],
              ),
              const Divider(height: 24),
              ...statements.map((statement) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _monthName(statement.month),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        statement.year.toString(),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "₹ ${statement.totalMonthlyEarnings.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
          ),
      ],
    );
  }

  String _monthName(int month) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month];
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRow(String label, String amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF15803D) : Colors.black,
          ),
        ),
      ],
    );
  }
}

