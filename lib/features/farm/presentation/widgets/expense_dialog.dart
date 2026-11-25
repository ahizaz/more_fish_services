import 'package:flutter/material.dart';
import 'package:more_fish/core/localization/app_translations.dart';

import '../../controllers/farm_accounting_controller.dart';
import '../../models/farm_expense.dart';

class ExpenseDialog extends StatefulWidget {
  const ExpenseDialog({
    super.key,
    required this.farmId,
    required this.batches,
    this.expense,
  });

  final String farmId;
  final List<String> batches;
  final FarmExpense? expense;

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late String _batch;
  String? _category;
  late DateTime _date;

  bool get isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _amountController = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: expense?.description ?? '',
    );
    _batch =
        expense?.stockingBatch ??
        (widget.batches.isEmpty ? 'General' : widget.batches.first);
    _category = expense?.category;
    _date = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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
        constraints: BoxConstraints(maxWidth: 650, maxHeight: availableHeight),
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
                          appText(isEditing ? 'Edit Expense' : 'Add Expense'),
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
                        _categoryField(),
                        const SizedBox(height: 16),
                        _amountField(),
                        const SizedBox(height: 16),
                        _dateField(),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _batchField()),
                        const SizedBox(width: 14),
                        Expanded(child: _categoryField()),
                      ],
                    ),
                  if (!isMobile) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _amountField()),
                        const SizedBox(width: 14),
                        Expanded(child: _dateField()),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _descriptionField(),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF102A43),
                          side: const BorderSide(color: Color(0xFFD1DDE8)),
                          minimumSize: const Size(62, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(appText('Cancel')),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0F6D72),
                          minimumSize: const Size(68, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
      'STOCKING / BATCH',
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

  Widget _categoryField() {
    return _labeledField(
      'CATEGORY *',
      DropdownButtonFormField<String>(
        initialValue: _category,
        isExpanded: true,
        decoration: _decoration('Select Category'),
        items: FarmAccountingController.categories
            .map(
              (category) => DropdownMenuItem(
                value: category,
                child: Text(appText(category)),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _category = value),
        validator: (value) => value == null || value.isEmpty
            ? appText('Select a category')
            : null,
      ),
    );
  }

  Widget _amountField() {
    return _labeledField(
      'AMOUNT (BDT) *',
      TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _decoration(''),
        validator: (value) {
          final amount = double.tryParse(value?.trim() ?? '');
          return amount == null || amount <= 0
              ? appText('Enter a valid amount')
              : null;
        },
      ),
    );
  }

  Widget _dateField() {
    return _labeledField(
      'EXPENSE DATE *',
      TextFormField(
        readOnly: true,
        controller: TextEditingController(text: _formatDate(_date)),
        decoration: _decoration(
          '',
        ).copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 16)),
        onTap: _pickDate,
      ),
    );
  }

  Widget _descriptionField() {
    return _labeledField(
      'DESCRIPTION',
      TextFormField(
        controller: _descriptionController,
        minLines: 3,
        maxLines: 4,
        decoration: _decoration(''),
      ),
    );
  }

  Widget _labeledField(String label, Widget field) {
    return Column(
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
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint.isEmpty ? null : appText(hint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1DDE8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF9FE9F3), width: 2),
      ),
    );
  }

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
    final expense = FarmExpense(
      id:
          widget.expense?.id ??
          'expense-${DateTime.now().millisecondsSinceEpoch}',
      farmId: widget.farmId,
      stockingBatch: _batch,
      category: _category!,
      amount: double.parse(_amountController.text.trim()),
      date: _date,
      description: _descriptionController.text.trim(),
    );
    Navigator.of(context).pop(expense);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    return appText('$day-${_monthName(date.month)}-${date.year}');
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return appText(months[month - 1]);
  }
}
