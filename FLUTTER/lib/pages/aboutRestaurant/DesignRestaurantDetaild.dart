// ignore_for_file: library_private_types_in_public_api

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
                  ? const Color.fromARGB(222, 212, 133, 14)
                  : Colors.transparent,
              border: Border.all(
                color: const Color.fromARGB(222, 212, 133, 14),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(222, 212, 133, 14),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: widget.value == widget.groupValue
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
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
class GlowingButton extends StatefulWidget {
  final VoidCallback onPressed;

  const GlowingButton({super.key, required this.onPressed});

  @override
  GlowingButtonState createState() => GlowingButtonState();
}

class GlowingButtonState extends State<GlowingButton> {
  var glowing = true;
  var scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapUp: (val) {
        setState(() {
          glowing = false;
          scale = 1.0;
        });
      },
      onHover: (val) {
        setState(() {
          glowing = false;
          scale = 1.0;
        });
      },
      onTapDown: (val) {
        setState(() {
          glowing = true;
          scale = 1.1;
        });
      },
      onTap: widget.onPressed, 
      child: AnimatedContainer(
        transform: Matrix4.identity()..scale(scale),
        duration: const Duration(milliseconds: 200),
        height: 48,
        width: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: const LinearGradient(
            colors: [
             Color.fromARGB(222, 212, 133, 14),
              Colors.black,
            ],
          ),
          boxShadow: glowing
              ? [
                  const BoxShadow(
                    color: Color.fromARGB(222, 212, 133, 14),
                    spreadRadius: 1,
                    blurRadius: 16,
                    offset: Offset(-8, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    spreadRadius: 1,
                    blurRadius: 16,
                    offset: const Offset(8, 0),
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    spreadRadius: 16,
                    blurRadius: 32,
                    offset: Offset(-8, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 16,
                    blurRadius: 32,
                    offset: const Offset(8, 0),
                  )
                ]
              : [],
        ),
        child: const Text(
          'Commander dans ce restaurant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
