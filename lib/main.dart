import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skippo/Home/landing_screen.dart';
import 'package:skippo/Services/database.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final streamingSharedPrefs = await StreamingSharedPreferences.instance;
  runApp(Skippo(streamingSharedPrefs: streamingSharedPrefs));
}

class Skippo extends StatelessWidget {
  final StreamingSharedPreferences streamingSharedPrefs;
  final Database database = LocalPersistance();

  Skippo({this.streamingSharedPrefs});
  @override
  Widget build(BuildContext context) {
    return Provider<Database>(
      create: (_) => database,
      child: MaterialApp(
        builder: (context, child) {
          return Directionality(textDirection: TextDirection.rtl, child: child);
        },
        title: 'Skippo',
        theme: ThemeData(
          // fontFamily: 'amaticaRegular',
          appBarTheme: AppBarTheme(centerTitle: true, color: Colors.black),
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LandingScreen(
          streamingSharedPrefs: streamingSharedPrefs,
        ),
      ),
    );
  }
}

//TODO Add try/catch to all file opens!!
