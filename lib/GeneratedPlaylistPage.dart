import 'package:findplaylist/main.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// I/flutter ( 7924): 0 track_id String
// I/flutter ( 7924): 1 track_name String
// I/flutter ( 7924): 2 artist_name String
// I/flutter ( 7924): 3 year int
// I/flutter ( 7924): 4 popularity int
// I/flutter ( 7924): 5 artwork_url String
// I/flutter ( 7924): 6 album_name String
// I/flutter ( 7924): 7 acousticness double
// I/flutter ( 7924): 8 danceability double
// I/flutter ( 7924): 9 duration_ms double
// I/flutter ( 7924): 10 energy double
// I/flutter ( 7924): 11 instrumentalness double
// I/flutter ( 7924): 12 key double
// I/flutter ( 7924): 13 liveness double
// I/flutter ( 7924): 14 loudness double
// I/flutter ( 7924): 15 mode double
// I/flutter ( 7924): 16 speechiness double
// I/flutter ( 7924): 17 tempo double
// I/flutter ( 7924): 18 time_signature double
// I/flutter ( 7924): 19 valence double
// I/flutter ( 7924): 20 track_url String

class GeneratedPlaylistPage extends StatelessWidget {
  final List<dynamic> song;
  final List<List<dynamic>>
      allSongs; // Assuming you pass the full list of songs

  GeneratedPlaylistPage({required this.song, required this.allSongs});

  List<List<dynamic>> getsimilar() {
    // First, filter based on attributes.
    List<List<dynamic>> filtered = allSongs.where((song1) {
      return (song[17] - song1[17]).abs() <= 5 &&
          (song[10] - song1[10]).abs() <= 0.3 &&
          (song[8] - song1[8]).abs() <= 0.2 &&
          (song[16] - song1[16]).abs() <= 0.1 &&
          (song[11] - song1[11]).abs() <= 0.001 &&
          (song[14] - song1[14]).abs() <= 2 &&
          (song[19] - song1[19]).abs() <= 0.4 &&
          (song[7] - song1[7]).abs() <= 0.1;
    }).toList();

    // Now, remove duplicates based on title and retain most popular.
    Map<String, List<dynamic>> uniqueSongs = {};
    for (var s in filtered) {
      String title =
          songTitle(s[1]); // Use songArtist function to normalize title
      if (!uniqueSongs.containsKey(title) ||
          int.parse(s[4].toString()) >
              int.parse(uniqueSongs[title]![4].toString())) {
        uniqueSongs[title] = s;
      }
    }

    return uniqueSongs.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> similarSongs = getsimilar();

    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Playlist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: similarSongs.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: similarSongs[index][5],
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            title: Text(songTitle(similarSongs[index][1])),
            // ignore: prefer_interpolation_to_compose_strings
            subtitle: Text("Artist: ${songArtist(similarSongs[index][2])}\n" +
                "Tempo: ${similarSongs[index][17]}\n" +
                "Scale: ${similarSongs[index][12]}\n" +
                "Popularity: ${similarSongs[index][4]}\n" +
                "Energy: ${similarSongs[index][10]}\n" +
                "Liveness: ${similarSongs[index][13]}\n" +
                "Loudness: ${similarSongs[index][14]}\n" +
                "Danceability: ${similarSongs[index][8]}\n" +
                "Speechiness: ${similarSongs[index][16]}\n" +
                "Instrumentalness: ${similarSongs[index][11]}\n" +
                "Mode: ${similarSongs[index][15]}\n" +
                "Valence: ${similarSongs[index][19]}"),
          );
        },
      ),
    );
  }
}
