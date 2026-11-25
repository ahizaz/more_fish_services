import 'package:flutter/material.dart';
import 'package:more_fish/core/localization/app_translations.dart';

class ScrollableDialog extends StatelessWidget {
  const ScrollableDialog({
    super.key,
    required this.title,
    required this.child,
    this.titleColor = const Color(0xFF102A43),
  });

  final String title;
  final Widget child;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < 600;
    final height = size.height - MediaQuery.viewInsetsOf(context).bottom - 44;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 24,
        vertical: 22,
      ),
      backgroundColor: const Color(0xE6DCE5EC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Colors.white70),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 820, maxHeight: height),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 22,
            16,
            isMobile ? 16 : 22,
            20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appText(title),
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFF4F8FC),
                        foregroundColor: const Color(0xFF61758A),
                      ),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(color: Colors.white, height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DialogSection extends StatelessWidget {
  const DialogSection({
    super.key,
    required this.title,
    required this.child,
    required this.color,
  });

  final String title;
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white70),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appText(title),
            style: TextStyle(
              color: color,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class HistorySection extends StatelessWidget {
  const HistorySection({
    super.key,
    required this.title,
    required this.headers,
    required this.rows,
  });

  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFB7EFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appText(title),
            style: const TextStyle(
              color: Color(0xFF344A65),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 42,
              dataRowMaxHeight: 64,
              columnSpacing: 28,
              columns: [
                for (final header in headers)
                  DataColumn(
                    label: Text(
                      appText(header),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      for (final value in row)
                        DataCell(
                          Text(
                            appText(value),
                            style: const TextStyle(
                              color: Color(0xFF344A65),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
}

class FormRow extends StatelessWidget {
  const FormRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            appText(label),
            style: const TextStyle(
              color: Color(0xFF17283D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
        ],
        child,
      ],
    );
  }
}

ButtonStyle primaryButtonStyle(Color color) {
  return FilledButton.styleFrom(
    backgroundColor: color,
    foregroundColor: Colors.white,
    minimumSize: const Size(132, 44),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    textStyle: const TextStyle(fontWeight: FontWeight.w800),
  );
}

String? requiredField(String? value) =>
    value == null || value.trim().isEmpty ? appText('Required') : null;

String formatDialogDate(DateTime date) => appText(
  '${date.day.toString().padLeft(2, '0')}-'
  '${date.month.toString().padLeft(2, '0')}-${date.year}',
);

InputDecoration dialogFieldDecoration(String? hint) {
  return InputDecoration(
    hintText: hint == null ? null : appText(hint),
    filled: true,
    fillColor: const Color(0xF5FFFFFF),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFB8F2FF), width: 2),
    ),
  );
}
