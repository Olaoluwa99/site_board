import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final Box _box = Hive.box(
    'settings',
  ); // We'll need to open this box in init_dependencies

  ThemeBloc() : super(ThemeInitial(ThemeMode.system)) {
    on<ThemeLoad>(_onThemeLoad);
    on<ThemeChanged>(_onThemeChanged);
  }

  void _onThemeLoad(ThemeLoad event, Emitter<ThemeState> emit) {
    // Default to system
    final modeIndex = _box.get(
      'themeMode',
      defaultValue: ThemeMode.system.index,
    );
    final mode = ThemeMode.values[modeIndex];
    emit(ThemeLoaded(mode));
  }

  void _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) {
    _box.put('themeMode', event.mode.index);
    emit(ThemeLoaded(event.mode));
  }
}
