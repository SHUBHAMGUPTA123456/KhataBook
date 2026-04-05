
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khata_book/presentation/views/main_screen.dart';
import 'core/bindings/app_binding.dart';
import 'data/repositories/database_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database BEFORE running the app
  await Get.putAsync<DatabaseRepository>(() async {
    final repo = DatabaseRepository();
    await repo.init();
    return repo;
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My Khata Book',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialBinding: AppBinding(),
      home: MainScreen(),
    );
  }
}
