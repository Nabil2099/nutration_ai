import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CoachComposer extends StatelessWidget {
  const CoachComposer({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      boxShadow: const [
        BoxShadow(
          color: Color(0x140A5438),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(
          Icons.auto_awesome_outlined,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !sending,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: const InputDecoration(
              hintText: 'Ask your coach a question...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton.filled(
          onPressed: sending ? null : onSend,
          tooltip: 'Send message',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(42, 42),
          ),
          icon: sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_upward_rounded, size: 20),
        ),
      ],
    ),
  );
}
