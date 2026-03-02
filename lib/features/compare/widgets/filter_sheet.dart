import 'package:flutter/material.dart';

class FilterSheet extends StatefulWidget {
  final double initialMin;
  final double initialMax;
  final bool initialCamera;
  final bool initialPerformance;
  final bool initialSoftware;
  final void Function(
      double min,
      double max,
      bool camera,
      bool performance,
      bool software,
      ) onApply;

  const FilterSheet({
    super.key,
    required this.initialMin,
    required this.initialMax,
    required this.initialCamera,
    required this.initialPerformance,
    required this.initialSoftware,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late RangeValues _currentRange;
  late bool _reqPerf;
  late bool _reqCamera;
  late bool _reqSoftware;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(widget.initialMin, widget.initialMax);
    _reqPerf = widget.initialPerformance;
    _reqCamera = widget.initialCamera;
    _reqSoftware = widget.initialSoftware;
  }

  void _setPreset(double min, double max) {
    setState(() => _currentRange = RangeValues(min, max));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text('Filter Requirements',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Requirement checkboxes
          CheckboxListTile(
            title: const Text('⚡ Performance (Gaming/CPU)'),
            value: _reqPerf,
            onChanged: (val) => setState(() => _reqPerf = val!),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          CheckboxListTile(
            title: const Text('📷 Professional Camera'),
            value: _reqCamera,
            onChanged: (val) => setState(() => _reqCamera = val!),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          CheckboxListTile(
            title: const Text('✨ Clean Software / UI'),
            value: _reqSoftware,
            onChanged: (val) => setState(() => _reqSoftware = val!),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Quick Budget Presets',
                style: theme.textTheme.labelLarge),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                  label: const Text('Under ₹20k'),
                  onPressed: () => _setPreset(0, 20000)),
              ActionChip(
                  label: const Text('₹30k–₹50k'),
                  onPressed: () => _setPreset(30000, 50000)),
              ActionChip(
                  label: const Text('₹50k–₹80k'),
                  onPressed: () => _setPreset(50000, 80000)),
              ActionChip(
                  label: const Text('₹80k+'),
                  onPressed: () => _setPreset(80000, 200000)),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Custom Range', style: theme.textTheme.labelLarge),
              Text(
                '₹${_currentRange.start.round()} – ₹${_currentRange.end.round()}',
                style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RangeSlider(
            values: _currentRange,
            min: 0,
            max: 200000,
            divisions: 40,
            labels: RangeLabels(
              '₹${_currentRange.start.round()}',
              '₹${_currentRange.end.round()}',
            ),
            onChanged: (values) => setState(() => _currentRange = values),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentRange = const RangeValues(0, 200000);
                      _reqPerf = false;
                      _reqCamera = false;
                      _reqSoftware = false;
                    });
                    widget.onApply(0, 200000, false, false, false);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    widget.onApply(
                      _currentRange.start,
                      _currentRange.end,
                      _reqCamera,
                      _reqPerf,
                      _reqSoftware,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}