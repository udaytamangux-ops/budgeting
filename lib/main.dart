import 'package:budgeting_app/app/app.dart';
import 'package:budgeting_app/app/bootstrap/app_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ProviderContainer container = await AppBootstrap.createContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BudgetingApp(),
    ),
  );
}
