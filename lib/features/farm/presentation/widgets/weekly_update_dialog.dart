import 'package:flutter/material.dart';

import '../../models/farm_models.dart';
import 'dashboard_dialog_helpers.dart';

class WeeklyUpdateDialog extends StatefulWidget {
  const WeeklyUpdateDialog({
    super.key,
    required this.farms,
    required this.ponds,
    required this.stockings,
    required this.updates,
    required this.selectedFarmId,
  });

  final List<Farm> farms;
  final List<Pond> ponds;
  final List<Stocking> stockings;
  final List<WeeklyUpdate> updates;
  final String? selectedFarmId;

  @override
  State<WeeklyUpdateDialog> createState() => _WeeklyUpdateDialogState();
}

class _WeeklyUpdateDialogState extends State<WeeklyUpdateDialog> {
  final _weight = TextEditingController();
  final _mortality = TextEditingController(text: '0');
  final _feedQuantity = TextEditingController();
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
    _weight.dispose();
    _mortality.dispose();
    _feedQuantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ponds = widget.ponds.where((pond) => pond.farmId == _farmId).toList();
    return ScrollableDialog(
      title: 'Weekly Update & History',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogSection(
              title: '1. SUBMIT NEW WEEKLY UPDATE',
              color: const Color(0xFF204DBB),
              child: Column(
                children: [
                  FormRow(
                    children: [
                      _select(
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
                      _select(
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
                      _select(
                        label: 'SPECIES *',
                        value: null,
                        hint: 'Select Species',
                        items: const [
                          DropdownMenuItem(
                            value: 'Tilapia',
                            child: Text('Tilapia'),
                          ),
                          DropdownMenuItem(
                            value: 'Catfish',
                            child: Text('Catfish'),
                          ),
                        ],
                        onChanged: (_) {},
                        validator: (_) => null,
                      ),
                      _select(
                        label: 'ACTIVE BATCH *',
                        value: null,
                        hint: 'Select Batch',
                        items: widget.stockings
                            .map(
                              (stocking) => DropdownMenuItem(
                                value: stocking.id,
                                child: Text(stocking.batchName),
                              ),
                            )
                            .toList(),
                        onChanged: (_) {},
                        validator: (_) => null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FormRow(
                    children: [
                      _field(
                        'AVG WEIGHT (G) *',
                        _weight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: requiredField,
                      ),
                      _field(
                        'MORTALITY *',
                        _mortality,
                        keyboardType: TextInputType.number,
                        validator: requiredField,
                      ),
                      _dateField(),
                    ],
                  ),
                  const Divider(height: 26, color: Colors.white),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'FEED USAGE (OPTIONAL)',
                      style: TextStyle(
                        color: Color(0xFF344A65),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FormRow(
                    children: [
                      _select(
                        label: '',
                        value: null,
                        hint: 'Select Feed Type',
                        items: const [
                          DropdownMenuItem(
                            value: 'Pellets',
                            child: Text('Pellets'),
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                      _field(
                        '',
                        _feedQuantity,
                        hint: 'Quantity used in kg',
                        validator: (_) => null,
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _save,
                      style: primaryButtonStyle(const Color(0xFF1D63F5)),
                      child: const Text('Submit Update'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            HistorySection(
              title: '2. WEEKLY UPDATES HISTORY (${widget.updates.length})',
              headers: const [
                'DATE',
                'BATCH ID',
                'AVG WEIGHT',
                'MORTALITY',
                'ACTION',
              ],
              rows: [
                for (final update in widget.updates)
                  [
                    formatDialogDate(update.date),
                    update.batchName,
                    '${update.averageWeight.toStringAsFixed(3)} g',
                    '${update.mortality} fish',
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

  Widget _select({
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

  Widget _field(
    String label,
    TextEditingController controller, {
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
      WeeklyUpdate(
        id: 'update-${DateTime.now().millisecondsSinceEpoch}',
        batchName: 'Batch #10',
        averageWeight: double.parse(_weight.text.trim()),
        mortality: int.parse(_mortality.text.trim()),
        date: _date,
      ),
    );
  }
}
