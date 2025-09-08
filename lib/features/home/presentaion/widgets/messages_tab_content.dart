import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/core/services/locator_service.dart' as di;
import 'package:dooss_business_app/features/chat/presentation/manager/chat_cubit.dart';
import 'package:dooss_business_app/features/chat/presentation/pages/chats_list_screen.dart';

class MessagesTabContent extends StatelessWidget {
  const MessagesTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatCubit>(
      create: (context) => di.sl<ChatCubit>(),
      child: const MessagesTabDataLoader(),
    );
  }
}

class MessagesTabDataLoader extends StatelessWidget {
  const MessagesTabDataLoader({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadChats();
    });

    return const ChatsListScreen();
  }
}