import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sae_mobile/models/viewmodel/authentication_service.dart';
import 'package:sae_mobile/widgets/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'components/database_helper.dart';
import 'package:sae_mobile/components/router.dart';

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
    return MultiProvider(providers: [

        ChangeNotifierProvider(create:
        (context) => AuthenticationService()
    ),
    ],
    child: MaterialApp.router(
      title: 'Taste&Tell',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    )
    );
  }
}
