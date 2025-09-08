import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/utils/app_logger.dart';

class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendMessage,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.gray.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment Button
            IconButton(
              onPressed: () {
                AppLogger.info('Attachment button pressed', 'ChatInputField');
              },
              icon: Icon(
                Icons.attach_file,
                color: AppColors.gray,
                size: 24.sp,
              ),
            ),
            
            // Text Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: widget.controller,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTextStyles.s14w400.copyWith(
                      color: AppColors.gray,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      widget.onSendMessage(value.trim());
                      widget.controller.clear();
                      setState(() {
                        _hasText = false;
                      });
                    }
                  },
                ),
              ),
            ),
            
            SizedBox(width: 8.w),
            
            // Voice Button
            IconButton(
              onPressed: () {
                AppLogger.info('Voice message button pressed', 'ChatInputField');
              },
              icon: Icon(
                Icons.mic,
                color: AppColors.gray,
                size: 24.sp,
              ),
            ),
            
            SizedBox(width: 8.w),
            
            // Send Button
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _hasText ? AppColors.primary : AppColors.gray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _hasText
                    ? () {
                        if (widget.controller.text.trim().isNotEmpty) {
                          widget.onSendMessage(widget.controller.text.trim());
                          widget.controller.clear();
                          setState(() {
                            _hasText = false;
                          });
                        }
                      }
                    : null,
                icon: Icon(
                  Icons.send,
                  color: _hasText ? AppColors.white : AppColors.gray,
                  size: 18.sp,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
