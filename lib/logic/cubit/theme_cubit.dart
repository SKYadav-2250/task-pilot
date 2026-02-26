import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_mang/core/services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final StorageService storageService;

  ThemeCubit({required this.storageService}) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final isDark = storageService.getThemeMode();
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleTheme() async {
    final isDark = state == ThemeMode.light;
    await storageService.saveThemeMode(isDark);
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
