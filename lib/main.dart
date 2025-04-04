import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae_mobile/models/viewmodels/settings_viewmodel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'components/router.dart';
import 'models/database/database_helper.dart';

Future<void> main() async {

  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await DatabaseHelper.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return  MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
          (context) => SettingsViewModel()
        ),
      ],
      child: Consumer<SettingsViewModel>
        (builder: (BuildContext context, SettingsViewModel value, child) {
            return MaterialApp.router(
              title: 'Taste&Tell',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                brightness: value.isDark ? Brightness.dark : Brightness.light,
              ),
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
        }),
    );
  }
}
