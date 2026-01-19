import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrafficFloatingWindow extends ConsumerStatefulWidget {
  const TrafficFloatingWindow({super.key});

  @override
  ConsumerState<TrafficFloatingWindow> createState() => _TrafficFloatingWindowState();
}

class _TrafficFloatingWindowState extends ConsumerState<TrafficFloatingWindow> {
  Offset _offset = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    final showTrafficFloatingWindow = ref.watch(
      appSettingProvider.select((state) => state.showTrafficFloatingWindow),
    );
    final isStart = ref.watch(isStartProvider);

    if (!showTrafficFloatingWindow || !isStart || system.isAndroid) {
      return const SizedBox.shrink();
    }

    final traffics = ref.watch(trafficsProvider);
    final totalTraffic = ref.watch(totalTrafficProvider);
    final currentTraffic = traffics.list.isNotEmpty ? traffics.list.last : const Traffic();

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainer.withAlpha(204), // 0.8 * 255
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26), // 0.1 * 255
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: context.colorScheme.outlineVariant.withAlpha(128), // 0.5 * 255
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTrafficRow(
                context,
                Icons.arrow_upward,
                context.colorScheme.primary,
                '${currentTraffic.up.traffic.show}/s',
              ),
              const SizedBox(height: 4),
              _buildTrafficRow(
                context,
                Icons.arrow_downward,
                context.colorScheme.secondary,
                '${currentTraffic.down.traffic.show}/s',
              ),
              const Divider(height: 12),
              _buildTrafficRow(
                context,
                Icons.data_usage,
                context.colorScheme.tertiary,
                (totalTraffic.up + totalTraffic.down).traffic.show,
              ),
              if (system.isDesktop) ...[
                const Divider(height: 12),
                InkWell(
                  onTap: () {
                    ref.read(appSettingProvider.notifier).updateState(
                          (state) => state.copyWith(isMiniMode: true),
                        );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_full_outlined,
                          size: 14,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appLocalizations.miniMode,
                          style: context.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrafficRow(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
