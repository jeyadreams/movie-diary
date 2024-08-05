import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'entry.dart';
import 'watched.dart';
import 'watchlist.dart';
import 'backup.dart';
import 'restore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialization
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Diary',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    EntryPage(),
    WatchedPage(),
    WatchlistPage(),
    BackupPage(),
    RestorePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Movie Diary',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.selected,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.edit),
                label: Text('Entry'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.movie),
                label: Text('Watched'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.watch_later),
                label: Text('Watchlist'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.backup),
                label: Text('Backup'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restore),
                label: Text('Restore'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
