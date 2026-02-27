import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:task_mang/core/constants/api_constants.dart';
import 'package:task_mang/core/error/failures.dart';
import 'package:task_mang/core/network/dio_client.dart';
import 'package:task_mang/core/services/storage_service.dart';

class AuthRepository {
  final DioClient dioClient;
  final StorageService storageService;

  AuthRepository({required this.dioClient, required this.storageService});

  Future<Either<Failure, String>> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      log('data $data');
      if (data != null && data['token'] != null) {
        final token = data['token'] as String;
        await storageService.saveToken(token);

        if (data['name'] != null) {
          await storageService.saveUserName(data['name'] as String);
        }
        if (data['email'] != null) {
          await storageService.saveUserEmail(data['email'] as String);
        }

        return Right(token);
      } else {
        return const Left(AuthFailure('Invalid response from server'));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(AuthFailure(data['message']));
        }
      }
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<Either<Failure, String>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await dioClient.post(
        ApiConstants.registerEndpoint,
        data: {'name': name, 'email': email, 'password': password},
      );

      final data = response.data;
      if (data != null && data['token'] != null) {
        final token = data['token'] as String;
        await storageService.saveToken(token);

        if (data['name'] != null) {
          await storageService.saveUserName(data['name'] as String);
        }
        if (data['email'] != null) {
          await storageService.saveUserEmail(data['email'] as String);
        }

        return Right(token);
      } else {
        return const Left(AuthFailure('Invalid response from server'));
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(AuthFailure(data['message']));
        }
      }
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  Future<void> logout() async {
  
    await storageService.clearUserData();

  }

  Future<bool> isAuthenticated() async {
    final token = await storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}
