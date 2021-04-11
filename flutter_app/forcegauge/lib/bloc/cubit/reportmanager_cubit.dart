import 'package:bloc/bloc.dart';
import 'package:forcegauge/models/tabata/report.dart';

part 'reportmanager_state.dart';

class ReportmanagerCubit extends Cubit<ReportmanagerState> {
  ReportmanagerCubit() : super(ReportmanagerInitial([])) {}

  void loadWorkoutReportsFromJson(List<dynamic> reportsJson) {
    List<WorkoutReport> reportList = [];
    for (var devJson in reportsJson) {
      var newWorkoutReport = new WorkoutReport.fromJson(devJson);
      reportList.add(newWorkoutReport);
    }
    reportList.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    emit(ReportmanagerLoaded(reportList));
  }

  void addWorkoutReport(WorkoutReport report) {
    state.reports.add(report);
    state.reports.sort((a, b) {
      return b.date.compareTo(a.date);
    });
    emit(ReportmanagerUpdated(state.reports));
  }

  void removeWorkoutReportAt(int index) {
    if (index >= 0 && index < state.reports.length) {
      state.reports.removeAt(index);
      state.reports.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      emit(ReportmanagerUpdated(state.reports));
    }
  }
}
