import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mang/core/network/dio_client.dart';
import 'package:task_mang/core/services/storage_service.dart';
import 'package:task_mang/data/repositories/auth_repository.dart';
import 'package:task_mang/data/repositories/task_repository.dart';
import 'package:task_mang/logic/bloc/auth/auth_bloc.dart';
import 'package:task_mang/logic/bloc/task/task_bloc.dart';
import 'package:task_mang/logic/cubit/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core Data / Services
  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => secureStorage);

  sl.registerLazySingleton(
    () => StorageService(sharedPreferences: sl(), secureStorage: sl()),
  );

  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton(() => DioClient(dio: sl(), storageService: sl()));

  // Repositories
  sl.registerLazySingleton(
    () => AuthRepository(dioClient: sl(), storageService: sl()),
  );
  sl.registerLazySingleton(
    () => TaskRepository(dioClient: sl(), sharedPreferences: sl()),
  );

  // Blocs / Cubits
  sl.registerFactory(() => ThemeCubit(storageService: sl()));
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => TaskBloc(taskRepository: sl()));
}
