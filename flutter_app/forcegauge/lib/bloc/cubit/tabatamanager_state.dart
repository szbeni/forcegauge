part of 'tabatamanager_cubit.dart';

abstract class TabatamanagerState {
  final List<Tabata> tabatas;
  TabatamanagerState(this.tabatas);

  Tabata getTabataByName(String name) {
    for (var t in this.tabatas) {
      if (t.name == name) return t;
    }
    return null;
  }

  @override
  String toString() {
    String retval = "";
    int counter = 1;
    for (Tabata d in tabatas) {
      retval += "${counter}: ${d}\n";
    }
    return retval;
  }
}

class TabatamanagerInitial extends TabatamanagerState {
  TabatamanagerInitial(List<Tabata> tabatas) : super(tabatas);
}

class TabatamanagerSaved extends TabatamanagerState {
  TabatamanagerSaved(List<Tabata> tabatas) : super(tabatas);
}

class TabatamanagerLoaded extends TabatamanagerState {
  TabatamanagerLoaded(List<Tabata> tabatas) : super(tabatas);
}

class TabatamanagerUpdated extends TabatamanagerState {
  TabatamanagerUpdated(List<Tabata> tabatas) : super(tabatas);
}
