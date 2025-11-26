import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;
  final bool isDark;

  const DescriptionField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Icon(
            Icons.menu,
            size: 24,
            color: (isDark ? Colors.white : Colors.black87).withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'The why',
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: (isDark ? Colors.white : Colors.black87).withOpacity(
                  0.4,
                ),
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            minLines: 1,
            maxLines: 3,
            onSubmitted: (_) => onSubmitted(),
          ),),
        ),
      ],
    );
  }
}
