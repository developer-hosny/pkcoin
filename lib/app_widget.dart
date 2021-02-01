import 'package:flutter/material.dart';
import 'package:pkcoin/home/home.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key key}) : super(key: key);
  Widget _buildApp() {
    return HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PKCoin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (context, widget) {
        return _buildApp();
      },
    );
  }
}
