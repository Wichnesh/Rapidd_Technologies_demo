import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class SenderViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String senderEmail = 'sender@email.com';
  bool isLoading = false;

  bool sendEmail = false;

  void setSendEmail(bool value) {
    sendEmail = value;
    notifyListeners();
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^\S+@\S+\.\S+$');
    return regex.hasMatch(email);
  }

  Future<void> _createReceiverIfNotExists(String email) async {
    try {
      final userRef = _firestore.collection('users').doc(email);
      final doc = await userRef.get();

      if (!doc.exists) {
        await userRef.set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error creating receiver: $e');
    }
  }

  Future<String> sendAndShareIfNeeded() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final receiverEmail = emailController.text.trim();

    if (title.isEmpty || receiverEmail.isEmpty) {
      return "Please fill in title and receiver email.";
    }

    isLoading = true;
    notifyListeners();

    try {
      await _createReceiverIfNotExists(receiverEmail);

      await _firestore.collection('tasks').add({
        'title': title,
        'description': description,
        'sender': senderEmail,
        'receiver': receiverEmail,
        'accepted': null,
        'timestamp': FieldValue.serverTimestamp(),
        'sendEmail': sendEmail,
      });

      if (sendEmail) {
        final shareText = 'Task Title: $title\n'
            'Description: $description\n'
            'Assigned to: $receiverEmail\n'
            'Sent at: ${DateTime.now()}';
        await Share.share(shareText, subject: 'Shared Task from TODO App');
      }

      titleController.clear();
      descriptionController.clear();
      emailController.clear();
      return "Task sent successfully!";
    } catch (e) {
      return "Error: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSenderTasksStream() {
    return _firestore.collection('tasks').where('sender', isEqualTo: senderEmail).orderBy('timestamp', descending: true).snapshots();
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'No time';
    final dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  Widget loaderButton({required VoidCallback onPressed}) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send Task"),
            onPressed: onPressed,
          );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
