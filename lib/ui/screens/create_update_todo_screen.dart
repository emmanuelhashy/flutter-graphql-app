import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:todolist_graphql/data/models/todo_model.dart';
import 'package:todolist_graphql/utils/context_extension.dart';
class CreateUpdateTodoScreen extends StatefulWidget {
  const CreateUpdateTodoScreen({
    Key? key,
    required this.todo,
  }) : super(key: key);

  final TodoModel? todo;

  @override
  State<CreateUpdateTodoScreen> createState() => _CreateUpdateTodoScreenState();
}

class _CreateUpdateTodoScreenState extends State<CreateUpdateTodoScreen> {
  final _titleController = TextEditingController();
  final _isCompleted = ValueNotifier(false);

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.todo != null) {
      _titleController.text = widget.todo!.title;
      _isCompleted.value = widget.todo!.isCompleted;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.todo == null ? 'Create Todo' : 'Update Todo',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Todo title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<bool>(
                valueListenable: _isCompleted,
                builder: (context, value, child) {
                  return CheckboxListTile(
                    value: value,
                    title: const Text("Completed"),
                    onChanged: (newValue) {
                      _isCompleted.value = newValue!;
                    },
                  );
                }),
            const SizedBox(height: 8),
            Mutation(
              options: MutationOptions(
                document: gql(
                  widget.todo == null
                      ? createTodoItemMutation()
                      : updateTodoItemMutation(),
                ),
                onError: (exception) {
                  context.showSnackBar("Failed to create/update item");
                },
                onCompleted: (resultData) {
                  if (resultData != null) {
                    context.showSnackBar("Todo Item Created/Updated");
                    Navigator.of(context)
                        .popUntil((route) => route.settings.name == "/");
                  }
                },
              ),
              builder: (runMutation, result) {
                if (result != null && result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: () {
                    if (widget.todo != null) {
                      updateTodo(
                        runMutation: runMutation,
                        todoId: widget.todo!.id,
                      );
                    } else {
                      createTodo(runMutation);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 40)),
                  child: const Text('Save'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String updateTodoItemMutation() {
    return '''
    mutation UpdateTodoItem(\$id: ID!, \$input: UpdateTodoInput!) {
      updateTodo(id: \$id, input: \$input) {
        id
        title
      }
    }
    ''';
  }

  String createTodoItemMutation() {
    return '''
    mutation CreateTodoItem(\$input: CreateTodoInput!) {
      createTodo(input: \$input) {
        id
        title
      }
    }
    ''';
  }

  void updateTodo({
    required RunMutation runMutation,
    required String todoId,
  }) {
    final todoItemTitle = _titleController.text;
    final isTodoItemCompleted = _isCompleted.value;
    runMutation({
      'id': todoId,
      'input': {
        'title': todoItemTitle,
        'completed': isTodoItemCompleted,
      }
    });
  }

  void createTodo(RunMutation runMutation) {
    final todoItemTitle = _titleController.text;
    final isTodoItemCompleted = _isCompleted.value;
    runMutation({
      'input': {
        'title': todoItemTitle,
        'completed': isTodoItemCompleted,
      }
    });
  }
}
