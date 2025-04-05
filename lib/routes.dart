import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rapidd_technologies_demo/viewmodels/SenderViewModel.dart';

import 'viewmodels/receiver_viewmodel.dart';
import 'views/receiver_view.dart';
import 'views/role_selection_view.dart';
import 'views/sender_view.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const RoleSelectionView(),

  // ✅ Wrap with ChangeNotifierProvider
  '/sender': (context) => ChangeNotifierProvider(
        create: (_) => SenderViewModel(),
        child: const SenderView(),
      ),

  '/receiver': (context) => ChangeNotifierProvider(
        create: (_) => ReceiverViewModel(),
        child: const ReceiverView(),
      )
};
