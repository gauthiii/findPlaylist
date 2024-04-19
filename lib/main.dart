import 'dart:io';
import 'dart:math';

import 'package:findplaylist/SongDetailPage.dart';
import 'package:findplaylist/SongsTableScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Define your gradient colors here
    const Color gradientStartColor = Color(0xFF9BE19D); // Example start color
    const Color gradientEndColor = Color(0xFF1F5421); // Example end color

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Playlist Generator',
      theme: ThemeData(
        // Use the gradient colors to influence the color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: gradientStartColor,
          primary: gradientStartColor,
          secondary: gradientEndColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<List<dynamic>> songs = [];
  List<List<dynamic>> database = [];
  List<List<dynamic>> filteredSongs = [];
  bool isLoading = false;
  String searchQuery = '';
  String searchType = 'Track Name'; // Default search type
  List<String> searchOptions = ['Track Name', 'Artist Name', 'Album Name'];
  List artistList = [];
  Map<String, AlbumInfo> albums = {};

  @override
  void initState() {
    super.initState();
    loadAsset();
  }

  // Define a function to load and parse the CSV data
Future<List<List<dynamic>>> loadCsvData(String csvPath) async {
  // Load CSV data from the given path
  String csvString = await rootBundle.loadString(csvPath);

  // Parse the CSV string into a list of lists
  List<List<dynamic>> csvTable = CsvToListConverter().convert(csvString);

  return csvTable;
}

  Future<void> loadAsset() async {
    setState(() => isLoading = true);
   List<List<dynamic>> csvTable = await loadCsvData("assets/tamil_tracks.csv");
   
     List<dynamic> ls=[];
     int j=0;
     
    for(var i=0;i<csvTable[0].length;i++){
         if(j<21){
          if(j==20){
            ls.add(csvTable[0][i].split("\n")[0]);
          }
          else
          ls.add(csvTable[0][i]);
          j=j+1;
          
         }
         if(j==21){
          ls.add(csvTable[0][i].split("\n")[0]);
          songs.add(ls);
          ls=[csvTable[0][i].split("\n")[1]];
          j=1;
          
         }
    }
    print(songs.length);

    


    songs = songs.sublist(1);

    database=songs.sublist(0,10);

    Set uniqueArtists = Set(); // Set to store unique artist names

    songs.forEach((song) {
      song[1] = song[1].toString();
      song[2] = song[2].toString();
      song[6] = song[6].toString();

      List artists = song[2].split(',').map((s) => s.trim()).toList();
      uniqueArtists.addAll(artists); // Add to the set of unique artists
    });

    artistList = uniqueArtists.toList();

     songs.forEach((song) {
    String albumName = song[6];
    if (albums.containsKey(albumName)) {
      albums[albumName]?.songCount += 1;
    } else {
      albums[albumName] = AlbumInfo(albumName, song[5], 1);
    }
  });

    filteredSongs = []; // Initially display all songs
    songs.shuffle(Random());
    
    setState(() => isLoading = false);
  }

  process() async{

    final data = await rootBundle.loadString('assets/tamil_tracks.csv');
    songs = const CsvToListConverter().convert(data);
    // ignore: avoid_print
    print("${songs.length} songs");
    // ignore: avoid_print
    print(songs[1]);
    var index = 0;
    // ignore: avoid_function_literals_in_foreach_calls
    songs[1].forEach((element) {
      // ignore: avoid_print
      print("$index ${songs[0][index]} ${element.runtimeType}");
      index = index + 1;
    });
    songs = songs.sublist(1);

    Set uniqueArtists = Set(); // Set to store unique artist names

    songs.forEach((song) {
      song[1] = song[1].toString();
      song[2] = song[2].toString();
      song[6] = song[6].toString();

      List artists = song[2].split(',').map((s) => s.trim()).toList();
      uniqueArtists.addAll(artists); // Add to the set of unique artists
    });

    artistList = uniqueArtists.toList();

    filteredSongs = []; // Initially display all songs
    songs.shuffle(Random());

  }

  void updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSongs = [];
      } else {
        int index = searchOptions.indexOf(searchType);
        filteredSongs = songs.where((song) {
          if (index == 2) {
            return song[6]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          } else {
            return song[index + 1]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
          }
        }).toList();
        filteredSongs
            .sort((b, a) => a[4].compareTo(b[4])); // Sort by popularity
      }
    });
  }

  Widget songCard(int index) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SongDetailPage(
            song: filteredSongs[index],
            allSongs: songs,
          ),
        ),
      ),
      child: Card(
        color: Colors.grey[100],
        elevation: 4,
        child: ListTile(
          leading: CachedNetworkImage(
            imageUrl: filteredSongs[index][5],
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          title: Text(songTitle(filteredSongs[index][1])),
          subtitle: Text((searchType == "Album Name")
              ? filteredSongs[index][6]
              : songArtist(filteredSongs[index][2])),
          trailing: const Icon(Icons.more_vert),
        ),
      ),
    );
  }

  Widget ArtistCard(int index) {
    return Padding(
        padding: const EdgeInsets.all(4),
        child: Column(children: [
          if (index == 0)
            Padding(
                padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                child: Text(
                  "Featuring ${artistList.length} artists!",
                  textAlign: TextAlign.center,
                )),
          InkWell(
            onTap: () {
              setState(() {
                con.text = artistList[index];
              });
              updateSearchQuery(con.text);
            },
            child: Card(
                color: Theme.of(context).colorScheme.inversePrimary,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(children: [
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 35,
                          child: Padding(
                              padding: EdgeInsets.all(1),
                              child: Text(
                                (artistList[index].split(" ").length == 1)
                                    ? artistList[index].split(" ")[0][0]
                                    : artistList[index].split(" ")[0][0] +
                                        artistList[index].split(" ")[1][0],
                                style: TextStyle(
                                    fontFamily: "PoppinsBold",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontSize: 29),
                              )),
                        )),
                    Container(width: 4),
                    Flexible(
                      // Updated to use Flexible which handles overflow
                      child: Text(
                        artistList[index],
                        overflow: TextOverflow.ellipsis, // Handle text overflow
                        style: const TextStyle(
                          fontFamily: "PoppinsBold",
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ]),
                )),
          )
        ]));
  }

  initialScreen() {
    if (searchType == "Track Name") {
      return Column(children: [
        const SizedBox(
          height: 20,
        ),
       GestureDetector(
        onTap: (){
          Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongsTableScreen(songs: database)),
    );
        },
        child: Image.asset(
          'assets/social.png',
          height: 50,
        )),
        const SizedBox(
          height: 20,
        ),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              (con.text.trim().isEmpty)
                  ? "Search your favourite song from database of over a ${songs.length} spotify tracks!!!"
                  : "We're sorry but this song is not there in our database. Try searching for another track!!",
              textAlign: TextAlign.center,
            )),
      ]);
    }
    if (searchType == "Artist Name") {
      return Expanded(
          // height: MediaQuery.of(context).size.height * 0.55,
          child: ListView.builder(
        itemCount: artistList.length,
        itemBuilder: (context, index) => ArtistCard(index),
      ));
    } else {
      return Expanded(
          // height: MediaQuery.of(context).size.height * 0.55,
          child:GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (1 / 1.2), // Adjust the aspect ratio here
        ),
        itemCount: albums.length,
        itemBuilder: (BuildContext context, int index) {
          String key = albums.keys.elementAt(index);
          AlbumInfo info = albums[key]!;
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded( // Expanded widget makes the image take all available space
                  child: CachedNetworkImage(
                      imageUrl:
                    info.artworkUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                     placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(key,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('Songs: ${info.songCount}'),
                ),
              ],
            ),
          );
        },
      ),);
    }
  }

  TextEditingController con = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          setState(() {
            if (filteredSongs.isNotEmpty) {
              filteredSongs = [];
            } else {
              exitButton(context);
            }
          });
          return Future(() => false);
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Spotify Playlist Generator"),
            centerTitle: true,
          ),
          body: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (searchType == "Track Name")
                            ? Colors.black
                            : Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(
                                color: Colors.black, width: 3))),
                    onPressed: () {
                      setState(() {
                        searchType = "Track Name";
                        updateSearchQuery(con.text);
                      });
                    },
                    child: Text(
                      'Track',
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: (searchType == "Track Name")
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (searchType == "Artist Name")
                            ? Colors.black
                            : Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(
                                color: Colors.black, width: 3))),
                    onPressed: () {
                      setState(() {
                        searchType = "Artist Name";
                        updateSearchQuery(con.text);
                      });
                    },
                    child: Text(
                      'Artist',
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: (searchType == "Artist Name")
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: (searchType == "Album Name")
                            ? Colors.black
                            : Theme.of(context).colorScheme.inversePrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(
                                color: Colors.black, width: 3))),
                    onPressed: () {
                      setState(() {
                        searchType = "Album Name";
                        updateSearchQuery(con.text);
                      });
                    },
                    child: Text(
                      'Album',
                      style: TextStyle(
                          fontFamily: "Poppins",
                          color: (searchType == "Album Name")
                              ? Theme.of(context).colorScheme.inversePrimary
                              : Colors.black),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: updateSearchQuery,
                  controller: con,
                  decoration: InputDecoration(
                    // enabledBorder: OutlineInputBorder(
                    //   borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    //   borderSide: BorderSide(
                    //       color: Theme.of(context).colorScheme.inversePrimary,
                    //       width: 2),
                    // ),
                    labelText: 'Search Songs',
                    hintText: 'Enter song title...',
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              updateSearchQuery('');
                              setState(() {
                                con.clear();
                              });
                            },
                          )
                        : null,
                  ),
                ),
              ),
              if (filteredSongs.isNotEmpty)
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Text(
                      "We found ${filteredSongs.length} result${filteredSongs.length == 1 ? "" : "s"}",
                      textAlign: TextAlign.center,
                    )),
              (filteredSongs.isEmpty)
                  ? initialScreen()
                  : Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: filteredSongs.length,
                              itemBuilder: (context, index) => songCard(index),
                            ),
                    ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => _counter++),
            tooltip: 'Increment',
            child: const Icon(Icons.filter_alt),
          ),
        ));
  }
}

songTitle(name) {
  // Split the string into words.
  String splitChar = name.contains('(') ? '(' : '[';
  List<String> words1 = name.split(splitChar);
  String name1 = words1[0];
  List<String> words = name1.split(' ');
  int currentLength = 0;
  List<String> resultWords = [];

  for (var word in words) {
    if (currentLength + word.length + (resultWords.isNotEmpty ? 1 : 0) <= 25) {
      // Add the length of the word and a space (if not the first word)
      currentLength += word.length + (resultWords.isNotEmpty ? 1 : 0);
      resultWords.add(word);
    } else {
      // Stop adding more words if adding the next word would exceed 25 characters.
      break;
    }
  }

  String result = resultWords.join(' ');
  // Add an ellipsis if the original name is longer than the formatted result
  if (result.length < name1.length) {
    result += '';
  }
  return result.split(' -')[0];
}

songArtist(name) {
  if (name.length > 20) {
    List<String> x = name.split(",");
    return "${x[0]} & more";
  }
  return name;
}

exitButton(context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text("Are you sure??",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: "Poppins-Bold",
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              content: const Text("Click yes to exit App",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Poppins-Regular",
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              actions: [
                TextButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: const Text("Yes",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: "Poppins-Regular",
                            fontWeight: FontWeight.bold,
                            color: Colors.blue))),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("No",
                        style: TextStyle(
                            fontSize: 15.0,
                            fontFamily: "Poppins-Regular",
                            fontWeight: FontWeight.bold,
                            color: Colors.red))),
              ]));
}


class AlbumInfo {
  String name;
  String artworkUrl;
  int songCount;

  AlbumInfo(this.name, this.artworkUrl, this.songCount);
}
