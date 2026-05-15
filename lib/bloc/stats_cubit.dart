import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:recova/models/relapse_statistics_model.dart';
import 'package:recova/services/api_service.dart';
import 'dart:developer' as developer;

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit() : super(StatsInitial());

  Future<void> fetchStats() async {
    emit(StatsLoading());
    try {
      final data = await ApiService.getRelapseStatistics();
      emit(StatsLoadSuccess(data: data));
      developer.log(data.toString());
    } catch (e) {
      emit(StatsLoadFailure(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
