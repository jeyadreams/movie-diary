import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class EntryPage extends StatefulWidget {
  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _movieNameController = TextEditingController();
  final TextEditingController _releaseYearController = TextEditingController();
  final TextEditingController _imdbLinkController = TextEditingController();
  final TextEditingController _plotController = TextEditingController();
  final TextEditingController _ottPlatformController = TextEditingController();
  final TextEditingController _watchedDateController = TextEditingController();
  String _movieStatus = 'watchlist';
  String? _poster;
  List<String> _photos = [];

  late Future<Database> _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  void _initDatabase() async {
    try {
      _database = openDatabase(
        join(await getDatabasesPath(), 'movie_diary.db'),
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE movies(id INTEGER PRIMARY KEY, name TEXT, poster TEXT, releaseYear INTEGER, imdbLink TEXT, plot TEXT, ottPlatform TEXT, status TEXT, watchedDate TEXT, photos TEXT)",
          );
        },
        version: 1,
      );
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  Future<void> _saveMovie() async {
    try {
      final Database db = await _database;

      Map<String, dynamic> movie = {
        'name': _movieNameController.text,
        'poster': _poster,
        'releaseYear': int.parse(_releaseYearController.text),
        'imdbLink': _imdbLinkController.text,
        'plot': _plotController.text,
        'ottPlatform': _ottPlatformController.text,
        'status': _movieStatus,
        'watchedDate':
            _movieStatus == 'watched' ? _watchedDateController.text : null,
        'photos': jsonEncode(_photos),
      };

      await db.insert(
        'movies',
        movie,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Movie saved successfully');
    } catch (e) {
      print('Error saving movie: $e');
    }
  }

  Future<void> _pickPoster() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = File(pickedFile.path).readAsBytesSync();
        setState(() {
          _poster = base64Encode(bytes);
        });
        print('Poster picked and encoded');
      }
    } catch (e) {
      print('Error picking poster: $e');
    }
  }

  Future<void> _pickPhotos() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage();

      if (pickedFiles != null) {
        setState(() {
          _photos.addAll(pickedFiles.map((file) {
            final bytes = File(file.path).readAsBytesSync();
            return base64Encode(bytes);
          }).toList());
        });
        print('Photos picked and encoded');
      }
    } catch (e) {
      print('Error picking photos: $e');
    }
  }

  Future<void> _pickWatchedDate(BuildContext context) async {
    try {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        setState(() {
          _watchedDateController.text =
              pickedDate.toLocal().toString().split(' ')[0];
        });
        print('Watched date picked');
      }
    } catch (e) {
      print('Error picking watched date: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _movieNameController,
                decoration: InputDecoration(labelText: 'Movie Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the movie name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Poster',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: _pickPoster,
                child: Container(
                  width: 81,
                  height: 144,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _poster != null
                      ? Image.memory(
                          base64Decode(_poster!),
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.add, size: 50),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Release Year',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _releaseYearController,
                decoration: InputDecoration(labelText: 'Release Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the release year';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'IMDB url',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _imdbLinkController,
                decoration: InputDecoration(labelText: 'IMDB Link'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the IMDB link';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Plot',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _plotController,
                decoration: InputDecoration(labelText: 'Plot'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the plot';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Ott Platform',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _ottPlatformController,
                decoration: InputDecoration(labelText: 'OTT Platform'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTT platform';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('Watched'),
                      leading: Radio<String>(
                        value: 'watched',
                        groupValue: _movieStatus,
                        onChanged: (value) {
                          setState(() {
                            _movieStatus = value!;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('Watchlist'),
                      leading: Radio<String>(
                        value: 'watchlist',
                        groupValue: _movieStatus,
                        onChanged: (value) {
                          setState(() {
                            _movieStatus = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (_movieStatus == 'watched')
                TextFormField(
                  readOnly: true,
                  controller: _watchedDateController,
                  decoration: InputDecoration(
                    labelText: 'Watched Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _pickWatchedDate(context),
                    ),
                  ),
                ),
              SizedBox(height: 20),
              Text(
                'Photos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Wrap(
                children: _photos
                    .map((photo) => Container(
                          margin: EdgeInsets.all(4),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.memory(
                            base64Decode(photo),
                            fit: BoxFit.cover,
                          ),
                        ))
                    .toList(),
              ),
              InkWell(
                onTap: _pickPhotos,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add, size: 50),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveMovie();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Success'),
                          content: Text('Movie saved successfully!'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _clearForm();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _movieNameController.clear();
    _poster = null;
    _releaseYearController.clear();
    _imdbLinkController.clear();
    _plotController.clear();
    _ottPlatformController.clear();
    _watchedDateController.clear();
    setState(() {
      _movieStatus = 'watchlist'; // Reset to default value
      _photos.clear(); // Clear photo list
    });
  }
}
