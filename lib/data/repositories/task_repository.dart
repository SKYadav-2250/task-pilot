import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_mang/core/constants/api_constants.dart';
import 'package:task_mang/core/error/failures.dart';
import 'package:task_mang/core/network/dio_client.dart';
import 'package:task_mang/data/models/task_model.dart';

class TaskRepository {
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;

  TaskRepository({required this.dioClient, required this.sharedPreferences});

  Future<Either<Failure, List<TaskModel>>> getTasks(int page, int limit) async {
    try {
      final response = await dioClient.get(ApiConstants.tasksEndpoint);

      final data = response.data;
      if (data is List) {
        final tasks = data.map((e) => TaskModel.fromJson(e)).toList();

        // Cache for offline use
        final cachedData = tasks.map((t) => t.toJson()).toList();
        await sharedPreferences.setString(
          'cached_tasks',
          jsonEncode(cachedData),
        );

        return Right(tasks);
      } else {
        return const Left(ServerFailure('Invalid data format from server'));
      }
    } on DioException catch (e) {
      final cached = sharedPreferences.getString('cached_tasks');
      if (cached != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cached);
          final cachedTasks = decoded
              .map((e) => TaskModel.fromJson(e))
              .toList();
          return Right(cachedTasks);
        } catch (_) {}
      }
      return Left(ServerFailure(e.message ?? 'Failed to fetch tasks'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, TaskModel>> createTask(TaskModel task) async {
    try {
      log("api si ${ApiConstants.tasksEndpoint}");
      final response = await dioClient.post(
        ApiConstants.tasksEndpoint,
        data: task.toJson(),
      );

      final data = response.data;
      log(data.toString());
      if (data != null) {
        return Right(TaskModel.fromJson(data));
      } else {
        return const Left(ServerFailure('Invalid response from server'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create task'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, TaskModel>> updateTask(TaskModel task) async {
    try {
      log("api si ${ApiConstants.tasksEndpoint}/${task.id}");
      log(task.toJson().toString());
      final response = await dioClient.put(
        '${ApiConstants.tasksEndpoint}/${task.id}',
        data: task.toJson(),
      );

      final data = response.data;
      if (data != null) {
        return Right(TaskModel.fromJson(data));
      } else {
        return const Left(ServerFailure('Invalid response from server'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update task'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await dioClient.delete('${ApiConstants.tasksEndpoint}/$taskId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete task'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
