import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReceiverViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedReceiver;
  bool isLoading = false;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllReceiversStream() {
    return _firestore.collection('users').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getReceiverTasksStream() {
    if (selectedReceiver == null) {
      return const Stream.empty();
    }

    return _firestore.collection('tasks').where('receiver', isEqualTo: selectedReceiver).orderBy('timestamp', descending: true).snapshots();
  }

  void selectReceiver(String email) {
    selectedReceiver = email;
    notifyListeners();
  }

  Future<void> updateTaskStatus(String taskId, bool accepted, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('tasks').doc(taskId).update({
        'accepted': accepted,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task ${accepted ? "accepted" : "rejected"} successfully')),
      );
    } catch (e) {
      debugPrint('Error updating task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task status')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskDescription(String taskId, String description, BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('tasks').doc(taskId).update({
        'description': description,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description updated successfully')),
      );
    } catch (e) {
      debugPrint('Error updating task description: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating description')),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Widget shimmerLoader({double height = 100.0, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
      ),
    );
  }
}
