import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:todolist_graphql/data/models/todo_model.dart';

class TodoDetailScreen extends StatelessWidget {
  const TodoDetailScreen({
    Key? key,
    required this.todoId,
  }) : super(key: key);

  final String todoId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Detail'),
        centerTitle: true,
      ),
      body: Query(
        options: QueryOptions(
          document: gql(getTodoItemQuery()),
          variables: {'id': todoId},
        ),
        builder: (result, {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(
              child: Text(result.exception.toString()),
            );
          }

          final data = result.data?['todo'];

          if (data == null) {
            return const Center(
              child: Text("Todo Item not found"),
            );
          }
          final todo = TodoModel.fromJson(data);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    todo.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todo.isCompleted ? 'Completed' : 'Not Completed',
                    style: TextStyle(
                      fontSize: 18,
                      color: todo.isCompleted ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed('/create-update-todo', arguments: todo);
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(150, 40)),
                    child: const Text('Edit'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String getTodoItemQuery() {
    return '''
    query GetTodoList(\$id: ID!) {
      todo(id: \$id) {
          id
          title
          completed
        }
    }
  ''';
  }
}
