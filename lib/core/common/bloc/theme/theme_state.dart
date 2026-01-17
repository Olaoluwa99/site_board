part of 'theme_bloc.dart';

@immutable
sealed class ThemeState {
  final ThemeMode themeMode;
  const ThemeState(this.themeMode);
}

final class ThemeInitial extends ThemeState {
  const ThemeInitial(super.themeMode);
}

final class ThemeLoaded extends ThemeState {
  const ThemeLoaded(super.themeMode);
}
