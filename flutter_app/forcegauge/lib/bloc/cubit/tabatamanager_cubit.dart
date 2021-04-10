import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:forcegauge/models/tabata/tabata.dart';

part 'tabatamanager_state.dart';

class TabatamanagerCubit extends Cubit<TabatamanagerState> {
  TabatamanagerCubit() : super(TabatamanagerInitial([])) {}

  void loadTabatasFromJson(List<dynamic> TabatasJson) {
    List<Tabata> TabataList = [];
    for (var tabataJson in TabatasJson) {
      var newTabata = new Tabata.fromJson(tabataJson);
      TabataList.add(newTabata);
    }
    emit(TabatamanagerUpdated(TabataList));
  }

  void addTabata(String name) {
    if (state.getTabataByName(name) == null) {
      var newTabata = defaultTabata;
      newTabata.name = name;
      state.tabatas.add(newTabata);
      emit(TabatamanagerUpdated(state.tabatas));
    }
  }

  void removeTabata(String name) {
    Tabata tabata = state.getTabataByName(name);
    if (tabata != null) {
      state.tabatas.remove(tabata);
      emit(TabatamanagerUpdated(state.tabatas));
    }
  }

  void removeTabataAt(int index) {
    if (index >= 0 && index < state.tabatas.length) {
      state.tabatas.removeAt(index);
      emit(TabatamanagerUpdated(state.tabatas));
    }
  }
}
