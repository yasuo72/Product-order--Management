import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final StorageService _storageService;

  ThemeCubit(this._storageService)
      : super(_storageService.isDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      _storageService.saveDarkMode(false);
      emit(ThemeMode.light);
    } else {
      _storageService.saveDarkMode(true);
      emit(ThemeMode.dark);
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
