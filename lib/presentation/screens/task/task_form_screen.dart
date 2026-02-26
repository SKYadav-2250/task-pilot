import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_mang/data/models/task_model.dart';
import 'package:task_mang/logic/bloc/task/task_bloc.dart';
import 'package:task_mang/logic/bloc/task/task_event.dart';
import 'package:task_mang/presentation/widgets/custom_text_field.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  String _selectedStatus = 'Pending';
  final List<String> _statuses = ['Pending', 'In Progress', 'Completed'];

  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedStatus = widget.task?.status ?? 'Pending';
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id:
            widget.task?.id ??
            '', // empty implies creation (uuid generated in repo)
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        status: _selectedStatus,
        dueDate: _selectedDate,
      );
      log('task is $task');

      if (widget.task == null) {
       
        context.read<TaskBloc>().add(TaskCreated(task));
      } else {
     
        context.read<TaskBloc>().add(TaskUpdated(task));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Task' : 'New Task',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 3),
            Text(
              isEditing ? 'Update task details' : 'Create a new task',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 📝 TASK DETAILS
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        labelText: 'Title',
                        maxLines: 1,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Title required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descController,
                        labelText: 'Description',
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,

                        validator: (val) => val == null || val.isEmpty
                            ? 'Description required'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// ⚙️ STATUS & DATE
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: _statuses
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedStatus = val);
                        },
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Due date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                'Change',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// ✅ PRIMARY ACTION
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveTask,
                  icon: Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(isEditing ? 'Update Task' : 'Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
