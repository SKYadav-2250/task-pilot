import 'package:equatable/equatable.dart';
import 'package:task_mang/data/models/task_model.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskFetched extends TaskEvent {
  final bool isRefresh;
  const TaskFetched({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class TaskCreated extends TaskEvent {
  final TaskModel task;
  const TaskCreated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskEvent {
  final TaskModel task;
  const TaskUpdated(this.task);

  @override
  List<Object?> get props => [task];
}

class TaskDeleted extends TaskEvent {
  final String taskId;
  const TaskDeleted(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
