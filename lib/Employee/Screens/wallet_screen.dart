import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:templink/Employee/Controllers/wallet_controller.dart';
import 'package:templink/Utils/colors.dart';
import 'package:templink/Utils/responsive.dart';

class WalletScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final bool showSidebar;

  const WalletScreen({
    Key? key,
    this.onBackPressed,
    this.showSidebar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());
    Responsive.init(context);
    final isWeb = Responsive.isDesktop(context) || Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isWeb ? null : _buildAppBar(),
      body: isWeb
          ? _buildWebLayout(context, controller)
          : _buildMobileLayout(context, controller),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)),
        onPressed: () => Navigator.pop(Get.context!),
      ),
      title: const Text(
        'Wallet',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF1F5F9)),
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, WalletController c) {
    return Column(
      children: [
        _buildWebTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: _buildContent(context, c),
          ),
        ),
      ],
    );
  }

  Widget _buildWebTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          if (showSidebar && onBackPressed != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)),
              onPressed: onBackPressed,
            ),
          const Text(
            'Wallet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text(
            'Your earnings & withdrawals',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WalletController c) {
    return RefreshIndicator(
      onRefresh: c.refresh,
      color: primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: _buildContent(context, c),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WalletController c) {
    return Obx(() {
      if (c.isLoading.value) {
        return const SizedBox(
          height: 400,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceSection(context, c),
          const SizedBox(height: 20),
          _buildConnectBanner(c),
          const SizedBox(height: 20),
          _buildTabBar(c),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: c.selectedTab.value == 0
                ? _buildWithdrawTab(context, c)
                : _buildHistoryTab(c),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // BALANCE SECTION WITH DEPOSIT BUTTON
  // ─────────────────────────────────────────────────────────────────

  Widget _buildBalanceSection(BuildContext context, WalletController c) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    final mainCard = _BalanceCard(
      label: 'Total Balance',
      amount: c.walletBalance.value,
      color: primary,
      icon: Icons.account_balance_wallet_rounded,
      large: true,
    );

    final availCard = _BalanceCard(
      label: 'Available',
      amount: c.availableBalance.value,
      color: const Color(0xFF22C55E),
      icon: Icons.check_circle_rounded,
    );

    final pendCard = _BalanceCard(
      label: 'In Transit',
      amount: c.pendingAmount.value,
      color: const Color(0xFFF59E0B),
      icon: Icons.swap_horiz_rounded,
    );

    final depositButton = _DepositButton(c: c);

    if (isSmall) {
      return Column(children: [
        Row(
          children: [
            Expanded(child: mainCard),
            const SizedBox(width: 12),
            SizedBox(width: 120, child: depositButton),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: availCard),
          const SizedBox(width: 12),
          Expanded(child: pendCard),
        ]),
      ]);
    }

    return Row(children: [
      Expanded(flex: 4, child: mainCard),
      const SizedBox(width: 16),
      Expanded(flex: 2, child: availCard),
      const SizedBox(width: 16),
      Expanded(flex: 2, child: pendCard),
      const SizedBox(width: 16),
      SizedBox(width: 140, child: depositButton),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────
  // STRIPE CONNECT BANNER
  // ─────────────────────────────────────────────────────────────────

  Widget _buildConnectBanner(WalletController c) {
    if (c.isStripeConnected.value && c.isOnboarded.value && c.isPayoutsEnabled.value) {
      return _StatusBanner(
        color: const Color(0xFF22C55E),
        icon: Icons.verified_rounded,
        title: 'Bank account connected',
        subtitle: 'Withdrawals go directly to your bank.',
        actionLabel: null,
        onAction: null,
      );
    }

    if (c.isStripeConnected.value && !c.isOnboarded.value) {
      return _StatusBanner(
        color: const Color(0xFFF59E0B),
        icon: Icons.warning_amber_rounded,
        title: 'Bank setup incomplete',
        subtitle: 'Finish your bank account setup to enable withdrawals.',
        actionLabel: 'Complete Setup',
        onAction: c.isProcessing.value ? null : c.connectBankAccount,
        isLoading: c.isProcessing.value,
      );
    }

    if (c.isStripeConnected.value && c.isOnboarded.value && !c.isPayoutsEnabled.value) {
      return _StatusBanner(
        color: const Color(0xFF3B82F6),
        icon: Icons.access_time_rounded,
        title: 'Verification in progress',
        subtitle: 'Stripe is verifying your account. This usually takes a few hours.',
        actionLabel: null,
        onAction: null,
      );
    }

    return _StatusBanner(
      color: primary,
      icon: Icons.account_balance_rounded,
      title: 'Connect your bank account',
      subtitle: 'One-time setup via Stripe. Withdrawals go straight to your bank.',
      actionLabel: 'Connect Bank',
      onAction: c.isProcessing.value ? null : c.connectBankAccount,
      isLoading: c.isProcessing.value,
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────────────────────────────

  Widget _buildTabBar(WalletController c) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        _Tab(
          label: 'Withdraw',
          icon: Icons.north_west_rounded,
          selected: c.selectedTab.value == 0,
          onTap: () => c.selectedTab.value = 0,
        ),
        _Tab(
          label: 'History',
          icon: Icons.receipt_long_rounded,
          selected: c.selectedTab.value == 1,
          onTap: () => c.selectedTab.value = 1,
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // WITHDRAW TAB
  // ─────────────────────────────────────────────────────────────────

  Widget _buildWithdrawTab(BuildContext context, WalletController c) {
    return Column(
      key: const ValueKey('withdraw'),
      children: [
        _buildWithdrawForm(c),
        const SizedBox(height: 24),
        _buildRecentTransactions(c),
      ],
    );
  }

  Widget _buildWithdrawForm(WalletController c) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.north_west_rounded, color: primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Withdraw Funds',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                  Text('Funds arrive in 1-2 business days',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 24),

          const Text('Amount', style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569),
          )),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Text(
                  'USD',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: c.withdrawAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Color(0xFFCBD5E1), fontSize: 22, fontWeight: FontWeight.w700),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  c.withdrawAmountController.text = c.availableBalance.value.toStringAsFixed(2);
                },
                child: Text(
                  'Max',
                  style: TextStyle(color: primary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              )
            ]),
          ),

          const SizedBox(height: 8),

          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available: ${c.formatCurrency(c.availableBalance.value)}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                'Min: \$${c.withdrawalLimits['minimum']}  •  Max: \$${c.withdrawalLimits['maximum']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          )),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF0EA5E9)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No withdrawal fee. Funds transferred via Stripe directly to your bank.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0369A1)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Obx(() {
            final canWithdraw = c.isPayoutsEnabled.value && !c.isProcessing.value;
            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: canWithdraw ? c.requestWithdrawal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: c.isProcessing.value
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        c.isPayoutsEnabled.value
                            ? 'Withdraw to Bank'
                            : 'Bank Account Not Connected',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: canWithdraw ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(WalletController c) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Transactions', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E),
          )),
          const SizedBox(height: 16),
          Obx(() {
            if (c.transactions.isEmpty) {
              return const _EmptyState(
                icon: Icons.receipt_long_rounded,
                message: 'No transactions yet',
              );
            }
            final items = c.transactions.take(5).toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (_, i) => _TransactionTile(tx: items[i], c: c),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HISTORY TAB
  // ─────────────────────────────────────────────────────────────────

  Widget _buildHistoryTab(WalletController c) {
    return _Card(
      key: const ValueKey('history'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Withdrawal History', style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E),
              )),
              Obx(() => Text(
                '${c.withdrawals.length} total',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (c.withdrawals.isEmpty) {
              return const _EmptyState(
                icon: Icons.account_balance_rounded,
                message: 'No withdrawals yet',
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: c.withdrawals.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (_, i) => _WithdrawalTile(w: c.withdrawals[i], c: c),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DEPOSIT BUTTON WIDGET
// ═══════════════════════════════════════════════════════════════════

class _DepositButton extends StatelessWidget {
  final WalletController c;

  const _DepositButton({required this.c});

  void _showDepositDialog() {
    final amountController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter amount to deposit', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount (USD)',
                prefixText: '\$ ',
                prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Minimum \$10 | Maximum \$5000', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              c.depositAmountController.text = amountController.text;
              Get.back();
              c.deposit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton.icon(
        onPressed: c.isProcessing.value ? null : _showDepositDialog,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Funds', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ));
  }
}

// ═══════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════

class _BalanceCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool large;

  const _BalanceCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(large ? 20 : 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: large ? 20 : 16),
              ),
              if (large)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('USD',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          SizedBox(height: large ? 16 : 12),
          Text(label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: large ? 13 : 11,
              )),
          const SizedBox(height: 2),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: large ? 28 : 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color,
                )),
                Text(subtitle, style: const TextStyle(
                  fontSize: 12, color: Color(0xFF64748B),
                )),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(actionLabel!,
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [const BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16,
                  color: selected ? primary : const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? const Color(0xFF1A1A2E) : const Color(0xFF94A3B8),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final WalletController c;

  const _TransactionTile({required this.tx, required this.c});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx['type'] == 'CREDIT';
    final amount = (tx['amount'] ?? 0).toDouble();
    final color = isCredit ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.south_east_rounded : Icons.north_west_rounded,
              color: color, size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['description'] ?? (isCredit ? 'Earnings' : 'Withdrawal'),
                  style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  c.formatDate(tx['createdAt']),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  final Map<String, dynamic> w;
  final WalletController c;

  const _WithdrawalTile({required this.w, required this.c});

  @override
  Widget build(BuildContext context) {
    final amount = (w['amount'] ?? 0).toDouble();
    final status = (w['status'] ?? 'pending') as String;
    final statusColor = c.statusColor(status);
    final hasTransferId = w['stripeTransferId'] != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_rounded, size: 18, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bank Transfer',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                Text(
                  c.formatDate(w['createdAt']),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
                if (hasTransferId) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Stripe: ${(w['stripeTransferId'] as String).substring(0, 16)}...',
                    style: const TextStyle(fontSize: 10, color: Color(0xFFCBD5E1), fontFamily: 'monospace'),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  c.statusLabel(status),
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}