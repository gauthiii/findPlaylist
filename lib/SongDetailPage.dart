import 'package:findplaylist/GeneratedPlaylistPage.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class SongDetailPage extends StatelessWidget {
  final List<dynamic> song;
  final List<List<dynamic>> allSongs;

  SongDetailPage({required this.song, required this.allSongs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song[1]), // Song name as title
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
                elevation: 10,
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: song[5],
                      height: MediaQuery.sizeOf(context).width,
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        height: MediaQuery.sizeOf(context).width,
                        width: MediaQuery.sizeOf(context).width,
                        color: Colors.black.withOpacity(0.4),
                      )),
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      height: MediaQuery.sizeOf(context).width,
                      width: MediaQuery.sizeOf(context).width,
                      child: Center(
                          child: Flexible(
                              child: Text(song[1],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 30,
                                      fontFamily: "Pass",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)))))
                ])),
            const SizedBox(height: 20),
            textSection(title: 'Song Title', content: song[1]),
            textSection(title: 'Album Name', content: song[6]),
            textSection(title: 'Artist', content: song[2]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSection(title: 'Release Year', content: song[3].toString()),
                textSection(title: 'Popularity', content: song[4].toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSection(title: 'Energy', content: song[10].toString()),
                textSection(title: 'Liveness', content: song[13].toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSection(title: 'Loudness', content: song[14].toString()),
                textSection(title: 'Danceability', content: song[8].toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSection(
                    title: 'Duration',
                    content: _formatDuration(song[9].toInt())),
                textSection(
                    title: 'Scale', content: _convertScale(song[12].toInt())),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSection(title: 'Tempo', content: song[17].toString()),
                textSection(
                    title: 'Accousticness', content: song[7].toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSection(
                    title: 'Instrumentalness', content: song[11].toString()),
                textSection(title: 'Speechiness', content: song[16].toString()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSection(title: 'Mode', content: song[15].toString()),
                textSection(title: 'Valence', content: song[19].toString()),
              ],
            ),
            const SizedBox(height: 10),
            // Text(song[20]),
            Center(
              child: IconButton(
                icon: Image.asset(
                  'assets/social.png',
                  height: 50,
                ),
                onPressed: () {
                  _launchURL(
                      song[20]); // Assuming index 18 has the Spotify link
                },
              ),
            ),
            textSection(
                title: '',
                content:
                    'Click the above icon to play this track on spotify!!!'),
            const SizedBox(height: 20),
            Center(
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GeneratedPlaylistPage(
                      song: song,
                      allSongs: allSongs, // Pass the full list of songs here
                    ),
                  ),
                );
              },
              child: const Text(
                'Generate Similar Playlist',
                style: TextStyle(color: Colors.green),
              ),
            ))
          ],
        ),
      ),
    );
  }

  Widget textSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold),
            ),
          if (content.isNotEmpty)
            Text(
              content,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    int seconds = (milliseconds / 1000).round();
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    return '${minutes}m ${seconds}s';
  }

  String _convertScale(int scaleIndex) {
    Map<int, String> scaleMap = {
      0: 'C',
      1: 'C#',
      2: 'D',
      3: 'D#',
      4: 'E',
      5: 'F',
      6: 'F#',
      7: 'G',
      8: 'G#',
      9: 'A',
      10: 'A#',
      11: 'B'
    };
    return scaleMap[scaleIndex] ?? 'Unknown';
  }

  Future<void> _launchURL(String url) async {

    Uri uri = Uri.parse(song[20].toString());

    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
