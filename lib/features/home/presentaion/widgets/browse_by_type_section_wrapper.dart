import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/browse_by_type_section.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_state.dart';

class BrowseByTypeSectionWrapper extends StatelessWidget {
  const BrowseByTypeSectionWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        return BrowseByTypeSection(
          selectedIndex: homeState.selectedBrowseType,
          onTap: (index) {
            context.read<HomeCubit>().updateSelectedBrowseType(index);
          },
        );
      },
    );
  }
}