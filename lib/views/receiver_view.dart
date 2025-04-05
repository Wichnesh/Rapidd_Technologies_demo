import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidd_technologies_demo/viewmodels/receiver_viewmodel.dart';

class ReceiverView extends StatelessWidget {
  const ReceiverView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ReceiverViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Receiver")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("Available Receivers", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: vm.getAllReceiversStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (context, index) => vm.shimmerLoader(width: 120, height: 50),
                  ),
                );
              }

              final receivers = snapshot.data!.docs;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4),
                    child: Text("Total: ${receivers.length}", style: const TextStyle(fontSize: 14)),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: receivers.length,
                      itemBuilder: (context, index) {
                        final email = receivers[index].data()['email'];

                        return GestureDetector(
                          onTap: () => vm.selectReceiver(email),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: vm.selectedReceiver == email ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                email,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: vm.selectedReceiver == email ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          if (vm.selectedReceiver != null) ...[
            const Divider(height: 30),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Tasks for: ${vm.selectedReceiver}", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: vm.getReceiverTasksStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => vm.shimmerLoader(height: 120),
                    );
                  }

                  final tasks = snapshot.data!.docs;

                  if (tasks.isEmpty) return const Center(child: Text("No tasks assigned."));

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final doc = tasks[index];
                      final task = doc.data();
                      final accepted = task['accepted'];
                      final TextEditingController descriptionController = TextEditingController(text: task['description'] ?? '');
                      Icon statusIcon;

                      if (accepted == true) {
                        statusIcon = const Icon(Icons.check_circle, color: Colors.green);
                      } else if (accepted == false) {
                        statusIcon = const Icon(Icons.cancel, color: Colors.red);
                      } else {
                        statusIcon = const Icon(Icons.hourglass_empty, color: Colors.grey);
                      }

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(task['title'] ?? 'No Title'),
                                trailing: statusIcon,
                              ),
                              TextField(
                                controller: descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text("Accept"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      onPressed: accepted == null ? () => vm.updateTaskStatus(doc.id, true, context) : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.close),
                                      label: const Text("Reject"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: accepted == null ? () => vm.updateTaskStatus(doc.id, false, context) : null,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.save),
                                      label: const Text("Update Desc"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                      onPressed: () => vm.updateTaskDescription(doc.id, descriptionController.text, context),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
