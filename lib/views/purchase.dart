import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fl_clash/common/common.dart';

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});

  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  int _selectedPlanIndex = 1;

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: appLocalizations.purchase,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlanCard(
              context,
              index: 0,
              title: 'Free Plan',
              price: '\$0 / month',
              features: ['Basic features', '1 device', '10GB traffic'],
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              index: 1,
              title: 'Pro Plan',
              price: '\$9.99 / month',
              features: ['Advanced features', '5 devices', 'Unlimited traffic'],
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              context,
              index: 2,
              title: 'Enterprise Plan',
              price: '\$29.99 / month',
              features: ['All features', 'Unlimited devices', 'Priority support'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required int index,
    required String title,
    required String price,
    required List<String> features,
  }) {
    final isSelected = _selectedPlanIndex == index;
    return CommonCard(
      isSelected: isSelected,
      onPressed: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: context.colorScheme.primary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: context.textTheme.headlineSmall?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 16),
                      const SizedBox(width: 8),
                      Text(feature),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    _selectedPlanIndex = index;
                  });
                },
                child: Text(isSelected ? 'Current Plan' : 'Upgrade'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
