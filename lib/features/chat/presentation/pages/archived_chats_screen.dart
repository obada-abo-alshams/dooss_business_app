import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../manager/chat_cubit.dart';
import '../manager/chat_state.dart';
import '../widgets/chat_list_item.dart';

class ArchivedChatsScreen extends StatefulWidget {
  const ArchivedChatsScreen({super.key});

  @override
  State<ArchivedChatsScreen> createState() => _ArchivedChatsScreenState();
}

class _ArchivedChatsScreenState extends State<ArchivedChatsScreen> {
  @override
  void initState() {
    super.initState();
    // Load archived chats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadArchivedChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Archived Chats',
          style: AppTextStyles.s20w600,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          print('ArchivedChatsScreen - State: isLoadingArchivedChats=${state.isLoadingArchivedChats}, archivedChatsCount=${state.archivedChats.length}, error=${state.error}');
          
          if (state.isLoadingArchivedChats) {
            print('ArchivedChatsScreen - Showing loading indicator');
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            print('ArchivedChatsScreen - Showing error: ${state.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.gray.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 40.sp,
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading archived chats',
                    style: AppTextStyles.s16w500.copyWith(color: AppColors.gray),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.error!,
                    style: AppTextStyles.s14w400.copyWith(color: AppColors.gray),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      print('ArchivedChatsScreen - Retrying to load archived chats');
                      context.read<ChatCubit>().loadArchivedChats();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.archivedChats.isEmpty) {
            print('ArchivedChatsScreen - Showing empty state');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.gray.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.archive_outlined,
                      size: 40.sp,
                      color: AppColors.gray,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No archived chats',
                    style: AppTextStyles.s16w500.copyWith(color: AppColors.gray),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Archived conversations will appear here',
                    style: AppTextStyles.s14w400.copyWith(color: AppColors.gray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          print('ArchivedChatsScreen - Showing ${state.archivedChats.length} archived chats');
          return Column(
            children: [
              // Info banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                margin: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Tap and hold any chat to restore it to your active conversations',
                        style: AppTextStyles.s14w400.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Archived chats list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: state.archivedChats.length,
                  itemBuilder: (context, index) {
                    final chat = state.archivedChats[index];
                    print('ArchivedChatsScreen - Building archived chat item: ${chat.dealer}');
                    return GestureDetector(
                      onLongPress: () {
                        _showUnarchiveDialog(context, chat.id, chat.dealer);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ChatListItem(
                          chat: chat,
                          onTap: () {
                            print('ArchivedChatsScreen - Tapped on archived chat: ${chat.dealer}');
                            context.go('/chat/${chat.id}');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUnarchiveDialog(BuildContext context, int chatId, String dealerName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Restore Conversation',
            style: AppTextStyles.s18w600,
          ),
          content: Text(
            'Do you want to restore the conversation with $dealerName to your active conversations?',
            style: AppTextStyles.s14w400,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.s14w500.copyWith(color: AppColors.gray),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ChatCubit>().unarchiveChat(chatId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conversation with $dealerName restored successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(
                'Restore',
                style: AppTextStyles.s14w500.copyWith(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }
}