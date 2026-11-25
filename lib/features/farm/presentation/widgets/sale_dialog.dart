import 'package:flutter/material.dart';
import 'package:more_fish/core/localization/app_translations.dart';

import '../../models/farm_sale.dart';

class SaleDialog extends StatefulWidget {
  const SaleDialog({
    super.key,
    required this.farmId,
    required this.batches,
    this.sale,
  });

  final String farmId;
  final List<String> batches;
  final FarmSale? sale;

  @override
  State<SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<SaleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _countController;
  late final TextEditingController _priceController;
  late final TextEditingController _buyerController;
  late String _batch;
  late DateTime _date;

  bool get isEditing => widget.sale != null;

  @override
  void initState() {
    super.initState();
    final sale = widget.sale;
    _batch =
        sale?.stockingBatch ??
        (widget.batches.isEmpty ? 'General' : widget.batches.first);
    _date = sale?.date ?? DateTime.now();
    _weightController = TextEditingController(
      text: sale == null ? '' : sale.weightSold.toString(),
    );
    _countController = TextEditingController(
      text: sale?.fishCount == null ? '' : '${sale!.fishCount}',
    );
    _priceController = TextEditingController(
      text: sale == null ? '' : sale.pricePerKg.toString(),
    );
    _buyerController = TextEditingController(text: sale?.buyerName ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _countController.dispose();
    _priceController.dispose();
    _buyerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        32;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 42,
        vertical: 16,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 700, maxHeight: availableHeight),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 22),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appText(
                            isEditing ? 'Edit Fish Sale' : 'Add Fish Sale',
                          ),
                          style: const TextStyle(
                            color: Color(0xFF102A43),
                            fontFamily: 'serif',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD1DDE8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appText('Enter the record details below'),
                    style: TextStyle(
                      color: Color(0xFF607690),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (isMobile)
                    Column(
                      children: [
                        _batchField(),
                        const SizedBox(height: 16),
                        _dateField(),
                        const SizedBox(height: 16),
                        _weightField(),
                        const SizedBox(height: 16),
                        _countField(),
                        const SizedBox(height: 16),
                        _priceField(),
                        const SizedBox(height: 16),
                        _buyerField(),
                      ],
                    )
                  else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _batchField()),
                        const SizedBox(width: 14),
                        Expanded(child: _dateField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _weightField()),
                        const SizedBox(width: 14),
                        Expanded(child: _countField()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _priceField()),
                        const SizedBox(width: 14),
                        Expanded(child: _buyerField()),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(appText('Cancel')),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0F6D72),
                        ),
                        child: Text(appText(isEditing ? 'Update' : 'Save')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _batchField() {
    final batches = widget.batches.isEmpty ? ['General'] : widget.batches;
    return _labeledField(
      'STOCKING / BATCH *',
      DropdownButtonFormField<String>(
        initialValue: batches.contains(_batch) ? _batch : null,
        isExpanded: true,
        decoration: _decoration('Select Stocking / Batch'),
        items: batches
            .map(
              (batch) =>
                  DropdownMenuItem(value: batch, child: Text(appText(batch))),
            )
            .toList(),
        onChanged: (value) => setState(() => _batch = value ?? _batch),
        validator: (value) =>
            value == null || value.isEmpty ? appText('Select a batch') : null,
      ),
    );
  }

  Widget _dateField() => _labeledField(
    'SALE DATE *',
    TextFormField(
      readOnly: true,
      controller: TextEditingController(text: _formatDate(_date)),
      decoration: _decoration(
        '',
      ).copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 16)),
      onTap: _pickDate,
    ),
  );

  Widget _weightField() => _numberField(
    'WEIGHT SOLD (KG) *',
    _weightController,
    'Enter a valid weight',
  );

  Widget _countField() => _numberField(
    'FISH COUNT',
    _countController,
    'Enter a valid count',
    integer: true,
    required: false,
  );

  Widget _priceField() => _numberField(
    'PRICE PER KG (BDT) *',
    _priceController,
    'Enter a valid price',
  );

  Widget _numberField(
    String label,
    TextEditingController controller,
    String error, {
    bool integer = false,
    bool required = true,
  }) {
    return _labeledField(
      label,
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        decoration: _decoration(''),
        validator: (value) {
          if (!required && (value == null || value.trim().isEmpty)) return null;
          final parsed = integer
              ? int.tryParse(value?.trim() ?? '')
              : double.tryParse(value?.trim() ?? '');
          return parsed == null || parsed <= 0 ? appText(error) : null;
        },
      ),
    );
  }

  Widget _buyerField() => _labeledField(
    'BUYER NAME',
    TextFormField(controller: _buyerController, decoration: _decoration('')),
  );

  Widget _labeledField(String label, Widget field) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        appText(label),
        style: const TextStyle(
          color: Color(0xFF607690),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 7),
      field,
    ],
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint.isEmpty ? null : hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF9FE9F3), width: 2),
    ),
  );

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (date != null) setState(() => _date = date);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      FarmSale(
        id: widget.sale?.id ?? 'sale-${DateTime.now().millisecondsSinceEpoch}',
        farmId: widget.farmId,
        stockingBatch: _batch,
        date: _date,
        weightSold: double.parse(_weightController.text.trim()),
        fishCount: _countController.text.trim().isEmpty
            ? null
            : int.parse(_countController.text.trim()),
        pricePerKg: double.parse(_priceController.text.trim()),
        buyerName: _buyerController.text.trim(),
      ),
    );
  }

  String _formatDate(DateTime date) => appText(
    '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}',
  );
}
