import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_mang/data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository taskRepository;
  int _currentPage = 1;
  static const int _limit = 10;

  TaskBloc({required this.taskRepository}) : super(TaskInitial()) {
    on<TaskFetched>(_onTaskFetched);
    on<TaskCreated>(_onTaskCreated);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskDeleted>(_onTaskDeleted);
  }

  Future<void> _onTaskFetched(
    TaskFetched event,
    Emitter<TaskState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
    }

    if (state is TaskLoaded && !event.isRefresh) {
      final currentState = state as TaskLoaded;
      if (currentState.hasReachedMax) return;

      final result = await taskRepository.getTasks(_currentPage, _limit);

      result.fold((failure) => emit(TaskError(failure.message)), (tasks) {
        emit(
          tasks.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : TaskLoaded(
                  tasks: currentState.tasks + tasks,
                  hasReachedMax: false,
                ),
        );
        if (tasks.isNotEmpty) _currentPage++;
      });
    } else {
      emit(TaskLoading());
      final result = await taskRepository.getTasks(_currentPage, _limit);

      result.fold((failure) => emit(TaskError(failure.message)), (tasks) {
        emit(TaskLoaded(tasks: tasks, hasReachedMax: tasks.length < _limit));
        if (tasks.isNotEmpty) _currentPage++;
      });
    }
  }

  Future<void> _onTaskCreated(
    TaskCreated event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    emit(TaskLoading());
    log('event task isi ${event.task}');
    final result = await taskRepository.createTask(event.task);
    log('result task isi ${result}');

    result.fold(
      (failure) {
        emit(TaskError(failure.message));
        if (currentState is TaskLoaded)
          emit(currentState); // restore previous state
      },
      (task) {
        emit(const TaskOperationSuccess('Task created successfully'));
        add(const TaskFetched(isRefresh: true));
      },
    );
  }

  Future<void> _onTaskUpdated(
    TaskUpdated event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    emit(TaskLoading());
    log('event task isi ${event.task}');
    final result = await taskRepository.updateTask(event.task);
    log('result task isi ${result}');

    result.fold(
      (failure) {
        emit(TaskError(failure.message));
        if (currentState is TaskLoaded) emit(currentState);
      },
      (task) {
        emit(const TaskOperationSuccess('Task updated successfully'));
        add(const TaskFetched(isRefresh: true));
      },
    );
  }

  Future<void> _onTaskDeleted(
    TaskDeleted event,
    Emitter<TaskState> emit,
  ) async {
    if (state is! TaskLoaded) return;
    final currentState = state;
    emit(TaskLoading());

    final result = await taskRepository.deleteTask(event.taskId);

    result.fold(
      (failure) {
        emit(TaskError(failure.message));
        if (currentState is TaskLoaded) emit(currentState);
      },
      (_) {
        emit(const TaskOperationSuccess('Task deleted successfully'));

        add(const TaskFetched(isRefresh: true));
      },
    );
  }
}
