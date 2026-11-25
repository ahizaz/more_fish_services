import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:more_fish/core/localization/app_translations.dart';

import '../../models/farm_models.dart';
import 'dashboard_dialog_helpers.dart';

class CreatePondDialog extends StatefulWidget {
  const CreatePondDialog({
    super.key,
    required this.farms,
    required this.selectedFarmId,
  });

  final List<Farm> farms;
  final String? selectedFarmId;

  @override
  State<CreatePondDialog> createState() => _CreatePondDialogState();
}

class _CreatePondDialogState extends State<CreatePondDialog> {
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _farmId;
  String _areaUnit = 'DECIMAL';
  String? _imageName;

  @override
  void initState() {
    super.initState();
    _farmId = widget.selectedFarmId ?? widget.farms.first.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: false,
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _imageName = result.files.single.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom -
        48;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 24,
      ),
      backgroundColor: const Color(0xFFAFC8EE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 660, maxHeight: availableHeight),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          appText('Create New Pond & Image'),
                          style: TextStyle(
                            color: Color(0xFF102A43),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF61758A),
                        ),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    appText('SELECT FARM *'),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _farmId,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    decoration: dialogFieldDecoration(null),
                    items: widget.farms
                        .map(
                          (farm) => DropdownMenuItem(
                            value: farm.id,
                            child: Text(appText(farm.name)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _farmId = value ?? _farmId),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appText('POND NAME *'),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _name,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? appText('Please enter a pond name')
                        : null,
                    decoration: dialogFieldDecoration(
                      'Example: Blue Pearl Pond',
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final areaField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appText('AREA (OPTIONAL)'),
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _area,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: dialogFieldDecoration('2.00'),
                          ),
                        ],
                      );
                      final unitField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appText('AREA UNIT'),
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _areaUnit,
                            isExpanded: true,
                            isDense: true,
                            iconSize: 20,
                            decoration: dialogFieldDecoration(null),
                            items: [
                              DropdownMenuItem(
                                value: 'DECIMAL',
                                child: Text(appText('DECIMAL')),
                              ),
                              DropdownMenuItem(
                                value: 'ACRE',
                                child: Text(appText('ACRE')),
                              ),
                              DropdownMenuItem(
                                value: 'SQUARE_METER',
                                child: Text(appText('SQUARE_METER')),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _areaUnit = value ?? 'DECIMAL'),
                          ),
                        ],
                      );
                      if (constraints.maxWidth < 500) {
                        return Column(
                          children: [
                            areaField,
                            const SizedBox(height: 16),
                            unitField,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: areaField),
                          const SizedBox(width: 12),
                          Expanded(child: unitField),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appText('POND IMAGE (OPTIONAL)'),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: _pickImage,
                          child: Text(appText('Choose File')),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            appText(_imageName ?? 'No file chosen'),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF61758A),
                          side: const BorderSide(color: Colors.white),
                          minimumSize: const Size(110, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(appText('Cancel')),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.of(context).pop(
                              Pond(
                                id: 'pond-${DateTime.now().millisecondsSinceEpoch}',
                                farmId: _farmId,
                                name: _name.text.trim(),
                                area: _area.text.trim().isEmpty
                                    ? '0'
                                    : _area.text.trim(),
                                areaUnit: _areaUnit,
                                status: 'Active',
                                imageName: _imageName,
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF315BDA),
                          minimumSize: const Size(130, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(appText('Create Pond')),
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
}
