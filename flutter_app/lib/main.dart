import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chanbaner/services/database_service.dart';
import 'package:chanbaner/services/koan_service.dart';
import 'package:chanbaner/screens/timer_page.dart';
import 'package:chanbaner/screens/koan_page.dart';
import 'package:chanbaner/screens/journal_page.dart';
import 'package:chanbaner/screens/privacy_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final databaseService = DatabaseService();
  await databaseService.initialize();
  
  runApp(MyApp(databaseService: databaseService));
}

class MyApp extends StatelessWidget {
  final DatabaseService databaseService;
  
  const MyApp({Key? key, required this.databaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        Provider<KoanService>(create: (_) => KoanService()),
      ],
      child: MaterialApp(
        title: 'ChanBaner',
        theme: ThemeData(
          primarySwatch: Colors.brown,
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        home: const MainNavigator(),
        routes: {
          '/privacy': (context) => const PrivacyPage(),
          '/koan': (context) => const KoanPage(),
        },
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const TimerPage(),
    const JournalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: '定课',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '日记',
          ),
        ],
      ),
    );
  }
}