import 'package:flutter/material.dart';
import 'package:more_fish/core/localization/app_translations.dart';

import '../../models/farm_models.dart';
import 'dashboard_dialog_helpers.dart';

class CreateFarmDialog extends StatefulWidget {
  const CreateFarmDialog({super.key});

  @override
  State<CreateFarmDialog> createState() => _CreateFarmDialogState();
}

class _CreateFarmDialogState extends State<CreateFarmDialog> {
  final _name = TextEditingController();
  String _location = 'Bangladesh';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
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
        constraints: BoxConstraints(maxWidth: 620, maxHeight: availableHeight),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                          appText('Create New Farm'),
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
                  const SizedBox(height: 22),
                  Text(
                    appText('FARM NAME *'),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _name,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? appText('Please enter a farm name')
                        : null,
                    decoration: dialogFieldDecoration(
                      'Example: AquaNova Fish Farm',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    appText('LOCATION'),
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _location,
                    isExpanded: true,
                    isDense: true,
                    iconSize: 20,
                    decoration: dialogFieldDecoration(null),
                    items: [
                      DropdownMenuItem(
                        value: 'Bangladesh',
                        child: Text(appText('Bangladesh')),
                      ),
                      DropdownMenuItem(
                        value: 'India',
                        child: Text(appText('India')),
                      ),
                      DropdownMenuItem(
                        value: 'Nepal',
                        child: Text(appText('Nepal')),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _location = value ?? 'Bangladesh'),
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final cancelButton = OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF61758A),
                          side: const BorderSide(color: Colors.white),
                          minimumSize: Size(
                            constraints.maxWidth < 360 ? 120 : 110,
                            48,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(appText('Cancel')),
                      );
                      final createButton = FilledButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            Navigator.of(context).pop(
                              Farm(
                                id: 'farm-${DateTime.now().millisecondsSinceEpoch}',
                                name: _name.text.trim(),
                                location: _location,
                              ),
                            );
                          }
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF315BDA),
                          minimumSize: Size(
                            constraints.maxWidth < 360 ? 120 : 130,
                            48,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(appText('Create Farm')),
                      );

                      if (constraints.maxWidth < 360) {
                        return Row(
                          children: [
                            Expanded(child: cancelButton),
                            const SizedBox(width: 8),
                            Expanded(child: createButton),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          cancelButton,
                          const SizedBox(width: 10),
                          createButton,
                        ],
                      );
                    },
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
