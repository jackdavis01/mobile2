import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../businesslogic/filter_bloc_cubit.dart';
import 'filterpage.dart';

/// Wrapper that manages FilterCubit lifecycle while keeping FilterPage stateless
class FilterPageWrapper extends StatefulWidget {
  const FilterPageWrapper({super.key});

  @override
  State<FilterPageWrapper> createState() => _FilterPageWrapperState();
}

class _FilterPageWrapperState extends State<FilterPageWrapper> {
  FilterCubit? _filterCubit;

  /// Initialize FilterCubit with null-safe return
  FilterCubit _initializeFilterCubit() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? selectedQuickFilter = args?['selectedQuickFilter'] as String?;
    return FilterCubit(initialQuickFilter: selectedQuickFilter);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Create cubit only once
    _filterCubit ??= _initializeFilterCubit();
  }

  @override
  void dispose() {
    _filterCubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider.value(
      // Ensure cubit is initialized even if build is called before didChangeDependencies
      value: _filterCubit ?? _initializeFilterCubit(),
      child: const FilterPage(),
    );
  }
}
