// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';

class GlowRadioButton extends StatefulWidget {
  final String value;
  final String? groupValue;
  final String label;
  final ValueChanged<String>? onChanged;

  const GlowRadioButton({
    super.key,
    required this.value,
    required this.label,
    this.groupValue,
    this.onChanged,
  });

  @override
  _GlowRadioButtonState createState() => _GlowRadioButtonState();
}

class _GlowRadioButtonState extends State<GlowRadioButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(widget.value);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.value == widget.groupValue
                  ? Colors.white
                  : Colors.transparent,
              border: Border.all(
                color: const Color.fromARGB(222, 212, 133, 14),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: widget.value == widget.groupValue
                ? const Icon(
                    Icons.check,
                    color: Color.fromARGB(222, 212, 133, 14),
                    size: 18,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(widget.label),
        ],
      ),
    );
  }
}

