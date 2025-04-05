import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidd_technologies_demo/viewmodels/SenderViewModel.dart';
import 'package:shimmer/shimmer.dart';

class SenderView extends StatelessWidget {
  const SenderView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SenderViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sender')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: vm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: vm.titleController,
                decoration: const InputDecoration(hintText: "Task Title", border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter task title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: vm.descriptionController,
                decoration: const InputDecoration(hintText: "Task Description", border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter task description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: vm.emailController,
                decoration: const InputDecoration(hintText: "Receiver Email", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Enter receiver email';
                  if (!vm.isValidEmail(value.trim())) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: vm.sendEmail,
                onChanged: (val) => vm.setSendEmail(val ?? false),
                title: const Text("Share Task through other apps"),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text("Send Task"),
                      onPressed: () async {
                        if (vm.formKey.currentState?.validate() ?? false) {
                          final result = await vm.sendAndShareIfNeeded();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );
                        }
                      },
                    ),
              const SizedBox(height: 20),
              const Divider(),
              const Text("Sent Tasks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: vm.getSenderTasksStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Container(height: 16, color: Colors.white),
                            subtitle: Container(height: 14, margin: const EdgeInsets.only(top: 8), color: Colors.white),
                            trailing: const Icon(Icons.hourglass_empty),
                          ),
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Text("No tasks sent yet.");
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final task = docs[index].data();
                      final accepted = task['accepted'];
                      Icon statusIcon;

                      if (accepted == true) {
                        statusIcon = const Icon(Icons.check_circle, color: Colors.green);
                      } else if (accepted == false) {
                        statusIcon = const Icon(Icons.cancel, color: Colors.red);
                      } else {
                        statusIcon = const Icon(Icons.hourglass_empty, color: Colors.grey);
                      }

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Title:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(task['title'] ?? 'No Title'),
                              const SizedBox(height: 6),
                              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              Text(task['description'] ?? 'No Description'),
                              const SizedBox(height: 6),
                              Text('To: ${task['receiver'] ?? 'N/A'}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Align(alignment: Alignment.centerRight, child: statusIcon),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
