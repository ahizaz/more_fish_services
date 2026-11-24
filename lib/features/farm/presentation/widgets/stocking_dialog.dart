import 'package:flutter/material.dart';

import '../../models/farm_models.dart';
import 'dashboard_dialog_helpers.dart';

class StockingDialog extends StatefulWidget {
  const StockingDialog({
    super.key,
    required this.farms,
    required this.ponds,
    required this.stockings,
    required this.selectedFarmId,
  });

  final List<Farm> farms;
  final List<Pond> ponds;
  final List<Stocking> stockings;
  final String? selectedFarmId;

  @override
  State<StockingDialog> createState() => _StockingDialogState();
}

class _StockingDialogState extends State<StockingDialog> {
  final _species = TextEditingController();
  final _batch = TextEditingController();
  final _count = TextEditingController();
  final _weight = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _farmId;
  String? _pondId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _farmId = widget.selectedFarmId ?? widget.farms.first.id;
  }

  @override
  void dispose() {
    _species.dispose();
    _batch.dispose();
    _count.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ponds = widget.ponds.where((pond) => pond.farmId == _farmId).toList();
    return ScrollableDialog(
      title: 'Fish Stocking Management',
      titleColor: const Color(0xFF102A43),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogSection(
              title: '1. ADD NEW STOCKING',
              color: const Color(0xFF006B52),
              child: Column(
                children: [
                  FormRow(
                    children: [
                      _selectField(
                        label: 'FARM *',
                        value: _farmId,
                        items: widget.farms
                            .map(
                              (farm) => DropdownMenuItem(
                                value: farm.id,
                                child: Text(farm.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() {
                          _farmId = value!;
                          _pondId = null;
                        }),
                      ),
                      _selectField(
                        label: 'POND *',
                        value: _pondId,
                        hint: 'Select Pond',
                        items: ponds
                            .map(
                              (pond) => DropdownMenuItem(
                                value: pond.id,
                                child: Text(pond.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _pondId = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FormRow(
                    children: [
                      _textField(
                        label: 'SPECIES *',
                        controller: _species,
                        hint: 'Example: Tilapia',
                        validator: requiredField,
                      ),
                      _textField(
                        label: 'BATCH NAME',
                        controller: _batch,
                        hint: 'Optional',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FormRow(
                    children: [
                      _textField(
                        label: 'COUNT *',
                        controller: _count,
                        keyboardType: TextInputType.number,
                        validator: requiredField,
                      ),
                      _textField(
                        label: 'INITIAL WT (G) *',
                        controller: _weight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: requiredField,
                      ),
                      _dateField(),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _save,
                      style: primaryButtonStyle(const Color(0xFF0A9D70)),
                      child: const Text('Save Stocking'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HistorySection(
              title: '2. STOCKING HISTORY (${widget.stockings.length})',
              headers: const [
                'DATE',
                'BATCH / SPECIES',
                'COUNT',
                'INIT WT',
                'ACTION',
              ],
              rows: [
                for (final item in widget.stockings)
                  [
                    formatDialogDate(item.date),
                    '${item.batchName} (${item.species})',
                    item.count.toString(),
                    '${item.initialWeight.toStringAsFixed(3)} g',
                    'Edit',
                  ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField() {
    return LabeledField(
      label: 'DATE *',
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDate: _date,
          );
          if (picked != null) setState(() => _date = picked);
        },
        child: InputDecorator(
          decoration: dialogFieldDecoration(null),
          child: Text(formatDialogDate(_date)),
        ),
      ),
    );
  }

  Widget _selectField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return LabeledField(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        isDense: true,
        iconSize: 20,
        hint: hint == null ? null : Text(hint),
        decoration: dialogFieldDecoration(null),
        items: items,
        selectedItemBuilder: (context) => [
          for (final item in items)
            SizedBox(
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: item.child,
                ),
              ),
            ),
        ],
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: dialogFieldDecoration(hint),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      Stocking(
        id: 'stocking-${DateTime.now().millisecondsSinceEpoch}',
        farmName: widget.farms.firstWhere((farm) => farm.id == _farmId).name,
        pondName: widget.ponds.firstWhere((pond) => pond.id == _pondId).name,
        species: _species.text.trim(),
        batchName: _batch.text.trim().isEmpty
            ? '${_species.text.trim()} Batch'
            : _batch.text.trim(),
        count: int.parse(_count.text.trim()),
        initialWeight: double.parse(_weight.text.trim()),
        date: _date,
      ),
    );
  }
}
