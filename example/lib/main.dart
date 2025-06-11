import 'package:dio/dio.dart';
import 'package:dio_logger_plus/dio_logger_plus.dart';
import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dio = Dio()..interceptors.add(DioLogger());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dio log example')),
      body: Center(
        child: FilledButton(
          onPressed: () async {
            await dio.get('https://jsonplaceholder.typicode.com/todos');
          },
          child: Text('Get request'),
        ),
      ),
    );
  }
}
