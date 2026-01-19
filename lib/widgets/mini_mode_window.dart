import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

class MiniModeWindow extends ConsumerWidget {
  const MiniModeWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traffics = ref.watch(trafficsProvider);
    final currentTraffic = traffics.list.isNotEmpty ? traffics.list.last : const Traffic();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onPanStart: (_) {
          windowManager.startDragging();
        },
        onDoubleTap: () {
          ref.read(appSettingProvider.notifier).updateState(
                (state) => state.copyWith(isMiniMode: false),
              );
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer.withAlpha(230),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withAlpha(128),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrafficRow(
                context,
                Icons.arrow_upward,
                currentTraffic.up,
                context.colorScheme.primary,
              ),
              const SizedBox(height: 4),
              _buildTrafficRow(
                context,
                Icons.arrow_downward,
                currentTraffic.down,
                context.colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrafficRow(
    BuildContext context,
    IconData icon,
    num value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '${value.traffic.show}/s',
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Mono',
          ),
        ),
      ],
    );
  }
}
