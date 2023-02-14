import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:todolist_graphql/data/models/todo_model.dart';
import 'package:todolist_graphql/utils/context_extension.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Todo List"),
          centerTitle: true,
        ),
        body: Query(
          options: QueryOptions(document: gql(getTodoListQuery())),
          builder: (result, {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (result.hasException) {
              return Center(
                child: Text(result.exception.toString()),
              );
            }

            final data = result.data?['todos'];

            if (data == null || data.isEmpty) {
              return const Center(
                child: Text("No todo items yet"),
              );
            }
            final todoList = TodoList.fromJson(data).todos;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView.builder(
                itemCount: todoList.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final todoItem = todoList[index];
                  return Card(
                    elevation: 2.0,
                    child: Mutation(
                      options: MutationOptions(
                          document: gql(deleteTodoItemMutation()),
                          onError: (exception) {
                            context.showSnackBar(
                                "Error occurred while deleting item");
                          },
                          onCompleted: (resultData) {
                            if (resultData != null) {
                              context.showSnackBar("Item deleted");
                            }
                          }),
                      builder: (runMutation, result) {
                        return Dismissible(
                          key: UniqueKey(),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              Icons.delete_forever_sharp,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => deleteTodoItem(
                            context: context,
                            runMutation: runMutation,
                            todoId: todoItem.id,
                          ),
                          child: ListTile(
                            title: Text(
                              todoItem.title,
                              style: TextStyle(
                                decoration: todoItem.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed('/detail', arguments: todoItem.id);
                            },
                            trailing: Checkbox(
                              value: todoItem.isCompleted,
                              onChanged: null,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/create-update-todo');
          },
          child: const Icon(Icons.add),
        ));
  }

  void deleteTodoItem({
    required RunMutation runMutation,
    required String todoId, required BuildContext context,
  }) {
    runMutation({'id': todoId});
  }

  String deleteTodoItemMutation() {
    return '''
      mutation DeleteTodoItem(\$id: ID!) {
        deleteTodo(id: \$id)
      }
    ''';
  }

  String getTodoListQuery() {
    return '''
    query GetTodoList {
      todos {
        data {
          id
          title
          completed
        }
      }
    }
    ''';
  }
}
