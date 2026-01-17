part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent {}

final class ThemeLoad extends ThemeEvent {}

final class ThemeChanged extends ThemeEvent {
  final ThemeMode mode;
  ThemeChanged(this.mode);
}
