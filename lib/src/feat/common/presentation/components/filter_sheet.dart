import 'package:flutter/material.dart';
import 'package:mabar_slurd/src/res/custom_colors.dart';

class FilterSheet extends StatefulWidget {
  final String initialSort;
  final double initialMaxPrice;

  const FilterSheet({
    super.key,
    this.initialSort = 'Semua',
    this.initialMaxPrice = 100,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final List<String> _sorts = ['Semua', 'Terdekat', 'Termurah', 'Rating', 'Populer'];
  late String _selectedSort = widget.initialSort;

  late double _maxPrice = widget.initialMaxPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: CustomColors.mabarSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CustomColors.mabarBorderSubtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarTextPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _selectedSort = 'Semua';
                  _maxPrice = 100;
                }),
                child: const Text(
                  "Atur Ulang",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CustomColors.mabarPurpleLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle("Urutkan"),
          const SizedBox(height: 12),
          _buildChips(
            options: _sorts,
            selected: _selectedSort,
            onSelect: (v) => setState(() => _selectedSort = v),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("Harga Maksimal"),
              Text(
                "Rp ${_maxPrice.round()}.000 /jam",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarPurpleLight,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 5,
            max: 100,
            divisions: 19,
            activeColor: CustomColors.mabarBorderFocus,
            inactiveColor: CustomColors.mabarSurfaceInput,
            label: "Rp ${_maxPrice.round()}.000",
            onChanged: (v) => setState(() => _maxPrice = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.mabarBorderFocus,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context, {
                'sort': _selectedSort,
                'maxPrice': _maxPrice,
              }),
              child: const Text(
                "Terapkan Filter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.mabarTextPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: CustomColors.mabarTextPrimary,
      ),
    );
  }

  Widget _buildChips({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final bool isActive = selected == opt;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isActive
                  ? CustomColors.mabarBorderFocus
                  : CustomColors.mabarSurfaceCard,
              border: Border.all(
                color: isActive
                    ? CustomColors.mabarBorderFocus
                    : CustomColors.mabarBorderSubtle,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive
                    ? CustomColors.mabarTextPrimary
                    : CustomColors.mabarTextSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
