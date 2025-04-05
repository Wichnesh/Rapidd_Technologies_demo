import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidd_technologies_demo/viewmodels/SenderViewModel.dart';

import '../viewmodels/receiver_viewmodel.dart';
import '../viewmodels/role_viewmodel.dart';
import '../views/receiver_view.dart';
import '../views/sender_view.dart';
import '../widgets/animated_route.dart';

class RoleSelectionView extends StatelessWidget {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final roleVM = Provider.of<RoleViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("TODO Share App"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Sender"),
              onPressed: () {
                roleVM.setRole("sender");

                // ✅ Wrap SenderView in Provider here
                Navigator.push(
                  context,
                  createSlideRoute(
                    ChangeNotifierProvider(
                      create: (_) => SenderViewModel(),
                      child: const SenderView(),
                    ),
                    direction: AxisDirection.right,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.inbox),
              label: const Text("Receiver"),
              onPressed: () {
                roleVM.setRole("receiver");

                // ✅ Wrap ReceiverView in Provider here
                Navigator.push(
                  context,
                  createSlideRoute(
                    ChangeNotifierProvider(
                      create: (_) => ReceiverViewModel(),
                      child: const ReceiverView(),
                    ),
                    direction: AxisDirection.left,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
