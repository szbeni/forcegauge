part of 'reportmanager_cubit.dart';

abstract class ReportmanagerState {
  final List<WorkoutReport> reports;
  ReportmanagerState(this.reports);

  @override
  String toString() {
    String retval = "";
    int counter = 1;
    for (WorkoutReport r in reports) {
      retval += "${counter}: ${r}\n";
    }
    return retval;
  }
}

class ReportmanagerInitial extends ReportmanagerState {
  ReportmanagerInitial(List<WorkoutReport> reports) : super(reports);
}

class ReportmanagerSaved extends ReportmanagerState {
  ReportmanagerSaved(List<WorkoutReport> reports) : super(reports);
}

class ReportmanagerLoaded extends ReportmanagerState {
  ReportmanagerLoaded(List<WorkoutReport> reports) : super(reports);
}

class ReportmanagerUpdated extends ReportmanagerState {
  ReportmanagerUpdated(List<WorkoutReport> reports) : super(reports);
}
