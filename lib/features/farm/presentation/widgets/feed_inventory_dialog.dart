import 'package:flutter/material.dart';

import '../../models/farm_models.dart';
import 'dashboard_dialog_helpers.dart';

class FeedInventoryDialog extends StatefulWidget {
  const FeedInventoryDialog({
    super.key,
    required this.farms,
    required this.selectedFarmId,
    required this.inventories,
    required this.onCreateInventory,
    required this.onAddStock,
  });

  final List<Farm> farms;
  final String? selectedFarmId;
  final List<FeedInventory> inventories;
  final Future<void> Function(FeedInventory inventory) onCreateInventory;
  final Future<void> Function(FeedStockAddition addition) onAddStock;

  @override
  State<FeedInventoryDialog> createState() => _FeedInventoryDialogState();
}

class _FeedInventoryDialogState extends State<FeedInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _feedType = TextEditingController();
  final _brand = TextEditingController();
  final _marketPrice = TextEditingController();
  final _quantity = TextEditingController();
  final _purchasePrice = TextEditingController();

  late String _farmId;
  String? _selectedInventoryId;
  DateTime _purchaseDate = DateTime.now();
  bool _showAddStock = false;

  @override
  void initState() {
    super.initState();
    _farmId = widget.selectedFarmId ?? widget.farms.first.id;
  }

  @override
  void dispose() {
    _feedType.dispose();
    _brand.dispose();
    _marketPrice.dispose();
    _quantity.dispose();
    _purchasePrice.dispose();
    super.dispose();
  }

  List<FeedInventory> get _inventories {
    return widget.inventories
        .where((inventory) => inventory.farmId == _farmId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return ScrollableDialog(
      title: 'Feed Inventory',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFBFEAFF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF397EDB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feed Inventory',
                              style: TextStyle(
                                color: Color(0xFF102A43),
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Create a feed once, then add new stock whenever you purchase it again',
                              style: TextStyle(
                                color: Color(0xFF607690),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              setState(() => _showAddStock = false),
                          style:
                              primaryButtonStyle(
                                !_showAddStock
                                    ? const Color(0xFF397EDB)
                                    : const Color(0xFFF1F5F9),
                              ).copyWith(
                                foregroundColor: WidgetStatePropertyAll(
                                  !_showAddStock
                                      ? Colors.white
                                      : const Color(0xFF607690),
                                ),
                              ),
                          child: const Text('+ Add New Feed'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => setState(() => _showAddStock = true),
                          style:
                              primaryButtonStyle(
                                _showAddStock
                                    ? const Color(0xFF397EDB)
                                    : const Color(0xFFF1F5F9),
                              ).copyWith(
                                foregroundColor: WidgetStatePropertyAll(
                                  _showAddStock
                                      ? Colors.white
                                      : const Color(0xFF607690),
                                ),
                              ),
                          child: const Text('+ Add Stock'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _farmField(),
                  const SizedBox(height: 12),
                  if (_showAddStock)
                    _addStockFields(isMobile)
                  else
                    _newFeedFields(isMobile),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _showAddStock ? _addStock : _createFeed,
                style: primaryButtonStyle(const Color(0xFF397EDB)),
                child: Text(
                  _showAddStock
                      ? 'Add Stock to Existing Feed'
                      : 'Create Feed & Add Initial Stock',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _inventoryList(),
          ],
        ),
      ),
    );
  }

  Widget _farmField() {
    return LabeledField(
      label: 'FARM *',
      child: DropdownButtonFormField<String>(
        initialValue: _farmId,
        isExpanded: true,
        decoration: dialogFieldDecoration(null),
        items: [
          for (final farm in widget.farms)
            DropdownMenuItem(value: farm.id, child: Text(farm.name)),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _farmId = value;
            _selectedInventoryId = null;
          });
        },
      ),
    );
  }

  Widget _newFeedFields(bool isMobile) {
    final fields = [
      _textField('FEED TYPE *', _feedType, 'Example: Floating Feed'),
      _textField('BRAND *', _brand, 'Enter feed brand'),
      _textField(
        'CURRENT MARKET PRICE (BDT / KG) *',
        _marketPrice,
        'Current market price per kg',
        decimal: true,
      ),
      _textField(
        'INITIAL QUANTITY (KG) *',
        _quantity,
        'Purchased quantity',
        decimal: true,
      ),
      _textField(
        'PURCHASE PRICE (BDT / KG) *',
        _purchasePrice,
        'Your actual purchase price per kg',
        decimal: true,
      ),
      _dateField(),
    ];

    if (isMobile) {
      return Column(
        children: [
          fields[0],
          const SizedBox(height: 12),
          fields[1],
          const SizedBox(height: 12),
          fields[2],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: fields[3]),
              const SizedBox(width: 12),
              Expanded(child: fields[4]),
            ],
          ),
          const SizedBox(height: 12),
          fields[5],
        ],
      );
    }

    return Column(
      children: [
        FormRow(children: [fields[0], fields[1]]),
        const SizedBox(height: 12),
        fields[2],
        const SizedBox(height: 12),
        FormRow(children: [fields[3], fields[4]]),
        const SizedBox(height: 12),
        fields[5],
      ],
    );
  }

  Widget _addStockFields(bool isMobile) {
    final inventoryItems = _inventories;
    if (_selectedInventoryId != null &&
        !inventoryItems.any((item) => item.id == _selectedInventoryId)) {
      _selectedInventoryId = null;
    }

    final fields = [
      LabeledField(
        label: 'SELECT EXISTING FEED *',
        child: DropdownButtonFormField<String>(
          initialValue: _selectedInventoryId,
          isExpanded: true,
          hint: const Text('Choose a feed type'),
          decoration: dialogFieldDecoration(null),
          items: [
            for (final inventory in inventoryItems)
              DropdownMenuItem(
                value: inventory.id,
                child: Text('${inventory.feedType} - ${inventory.brand}'),
              ),
          ],
          onChanged: (value) => setState(() => _selectedInventoryId = value),
          validator: (value) => value == null ? 'Required' : null,
        ),
      ),
      _textField(
        'QUANTITY TO ADD (KG) *',
        _quantity,
        'Purchased quantity',
        decimal: true,
      ),
      _textField(
        'PURCHASE PRICE (BDT / KG) *',
        _purchasePrice,
        'Your actual purchase price per kg',
        decimal: true,
      ),
    ];

    return Column(
      children: [
        fields[0],
        const SizedBox(height: 12),
        isMobile
            ? Column(
                children: [fields[1], const SizedBox(height: 12), fields[2]],
              )
            : FormRow(children: [fields[1], fields[2]]),
        const SizedBox(height: 12),
        _dateField(),
      ],
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller,
    String hint, {
    bool decimal = false,
  }) {
    return LabeledField(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: decimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: dialogFieldDecoration(hint),
        validator: requiredField,
      ),
    );
  }

  Widget _dateField() {
    return LabeledField(
      label: 'PURCHASE DATE *',
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            initialDate: _purchaseDate,
          );
          if (picked != null) setState(() => _purchaseDate = picked);
        },
        child: InputDecorator(
          decoration: dialogFieldDecoration(null),
          child: Text(formatDialogDate(_purchaseDate)),
        ),
      ),
    );
  }

  Widget _inventoryList() {
    final inventories = _inventories;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFBFEAFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3. Feed Inventory List',
            style: TextStyle(
              color: Color(0xFF102A43),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (inventories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'No feed inventory added yet.',
                style: TextStyle(
                  color: Color(0xFF607690),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 38,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 48,
                columnSpacing: 30,
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'FEED TYPE',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'BRAND',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'PRICE / KG',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'AVAILABLE STOCK',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
                rows: [
                  for (var i = 0; i < inventories.length; i++)
                    DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(Text(inventories[i].feedType)),
                        DataCell(Text(inventories[i].brand)),
                        DataCell(
                          Text(
                            '৳${_formatNumber(inventories[i].purchasePrice)}',
                          ),
                        ),
                        DataCell(
                          Text('${_formatNumber(inventories[i].quantity)} kg'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  Future<void> _createFeed() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final marketPrice = double.tryParse(_marketPrice.text.trim());
    final quantity = double.tryParse(_quantity.text.trim());
    final purchasePrice = double.tryParse(_purchasePrice.text.trim());
    if (marketPrice == null ||
        quantity == null ||
        purchasePrice == null ||
        marketPrice < 0 ||
        quantity <= 0 ||
        purchasePrice < 0) {
      return;
    }

    final farm = widget.farms.firstWhere((item) => item.id == _farmId);
    final inventory = FeedInventory(
      id: 'feed-${DateTime.now().millisecondsSinceEpoch}',
      farmId: _farmId,
      farmName: farm.name,
      feedType: _feedType.text.trim(),
      brand: _brand.text.trim(),
      marketPrice: marketPrice,
      purchasePrice: purchasePrice,
      quantity: quantity,
      purchaseDate: _purchaseDate,
    );
    await widget.onCreateInventory(inventory);
    if (!mounted) return;
    setState(() {
      _selectedInventoryId = inventory.id;
      _feedType.clear();
      _brand.clear();
      _marketPrice.clear();
      _quantity.clear();
      _purchasePrice.clear();
    });
  }

  Future<void> _addStock() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final quantity = double.tryParse(_quantity.text.trim());
    final purchasePrice = double.tryParse(_purchasePrice.text.trim());
    if (_selectedInventoryId == null ||
        quantity == null ||
        purchasePrice == null ||
        quantity <= 0 ||
        purchasePrice < 0) {
      return;
    }

    await widget.onAddStock(
      FeedStockAddition(
        inventoryId: _selectedInventoryId!,
        quantity: quantity,
        purchasePrice: purchasePrice,
        purchaseDate: _purchaseDate,
      ),
    );
    if (!mounted) return;
    setState(() {
      _quantity.clear();
      _purchasePrice.clear();
    });
  }
}
