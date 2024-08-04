import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WatchedPage extends StatefulWidget {
  @override
  _WatchedPageState createState() => _WatchedPageState();
}

class _WatchedPageState extends State<WatchedPage> {
  late Future<Database> _database;
  late Future<List<Map<String, dynamic>>> _watchedMovies;

  @override
  void initState() {
    super.initState();
    _database = _initializeDatabase();
    _watchedMovies = _fetchWatchedMovies();
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    return openDatabase(
      join(databasePath, 'movie_diary.db'),
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchWatchedMovies() async {
    final Database db = await _database;
    return db.query(
      'movies',
      where: 'status = ?',
      whereArgs: ['watched'],
    );
  }

  Future<void> _deleteMovie(int id) async {
    final Database db = await _database;
    await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    setState(() {
      _watchedMovies = _fetchWatchedMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watched Movies'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _watchedMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No movies found'));
          }
          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onLongPress: () => _showDeleteDialog(context, movie['id']),
                child: ListTile(
                  title: Text(movie['name']),
                  subtitle: Text('Release Year: ${movie['releaseYear']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatchedDetailPage(movie: movie),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Movie'),
          content: Text('Are you sure you want to delete this movie?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMovie(id);
              },
            ),
          ],
        );
      },
    );
  }
}

class WatchedDetailPage extends StatelessWidget {
  final Map<String, dynamic> movie;

  WatchedDetailPage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Movie Name: ${movie['name']}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text('Release Year: ${movie['releaseYear']}'),
            Text('IMDB Link: ${movie['imdbLink']}'),
            Text('Plot: ${movie['plot']}'),
            Text('OTT Platform: ${movie['ottPlatform']}'),
            Text('Watched Date: ${movie['watchedDate']}'),
            movie['poster'] != null
                ? Image.memory(base64Decode(movie['poster']))
                : SizedBox.shrink(),
            if (movie['photos'] != null)
              ...jsonDecode(movie['photos']).map<Widget>((photo) {
                return Image.memory(base64Decode(photo));
              }).toList(),
          ],
        ),
      ),
    );
  }
}
