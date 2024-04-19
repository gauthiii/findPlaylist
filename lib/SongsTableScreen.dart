import 'package:flutter/material.dart';

class SongsTableScreen extends StatelessWidget {
  final List<List<dynamic>> songs;

  const SongsTableScreen({Key? key, required this.songs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Songs Table'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Track ID')),
               DataColumn(label: Text('Track Name')),
                DataColumn(label: Text('Track Artist')),
                 
            
          
              DataColumn(label: Text('Song URL')),
                
              // Add more columns as needed
            ],
            rows: songs.map<DataRow>((song) => DataRow(
              cells: [
                DataCell(Text(song[0].toString())),
                DataCell(Text(song[1].toString())),
                DataCell(Text(song[2].toString())),
                 DataCell(Text(song[20].toString())),
                
                 
               
                // Add more cells as needed
              ],
            )).toList(),
          ),
        ),
      ),
    );
  }
}
