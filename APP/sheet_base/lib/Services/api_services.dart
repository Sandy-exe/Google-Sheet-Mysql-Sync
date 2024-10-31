import 'dart:convert';
import 'package:gsheets/gsheets.dart';
import 'package:http/http.dart' as http;
import 'package:sheet_base/Models/pirateSheetBase.dart';
import 'package:sheet_base/constants/constants.dart';

// Your Google Sheets API credentials
const _credentials = r'''
{
  "type": "service_account",
  "project_id": "sheetbase-436908",
  "private_key_id": "8d318c6de1e9d4207ecd9e4902bfd0efcabf2bc4",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDFQ9WXhk+1nCjo\nx++/we4jITjpI9pdme3sDUar80KJI3b3+Vi321MtWsistbEkZ89WiG1nZpeJxUA9\nkjWOWNTWt/oJ+2QouoJOBjZXErds9cGBZS5oke8ysuXKqQuco1NJ47Yc0S4xHUM3\nI8CKsJN8MXuOTOOOJpDtcEEgbD5K6SbpkpnLyq3xSRYYnxZOJ53MLc+amL4Uq9WF\nKODCWYBGEL9qOmCe9HEaVS+3XISxUd6v0gIoO/t5jkruGmptxmtLS/kB4Tk5HtR8\nf3MalHzz8KfuBv18U+T0JR/YsY+C/QEs4PMe7VKpBQ00y5D3FHlZGbfGKdqCIOGw\nS+FUjqn3AgMBAAECggEACONyl15E7zD3Iu4HXoOVgF25279y0m7iKpW6jnrqj5Va\ngffpSHeIeu2xRx70uWg4DnUdQOB9iYaqy1twMFbOWFJ34MVEERW+U1eyUSAVxcIZ\nEwSFH88bkRRAiG4viMJPOXAaP5gpVas04SIqRdWI/7qXD6VlR31zYE+Dj7tw3x0o\nFELPhhyT2RCNpDYG0D/NsjSX/eOAKRmkXlIHAxhwO4owWIzAvCYfuQ3TAJ08b/uX\nB7hy4AxqWibCDdMhTlHJD+dTXBi2sEk4OpVXh56gBM502bbJgAeWu3OWC58iVD9r\nyq2J5Y+mkMmx36V7PJiMisjSv+NtA7/a5hUuCLqNIQKBgQDhpRYs7Dhg9powsSFz\nzhO6z3RvAJ05z/QyizCmvKC/OA7FMpxdTbTMhFgVJ+y2ln43XQ8mM7Doc+U4+qm1\ni+pHxAmyekYp+wjqK5k//BlzjDNOhnjopk3nb5GIHv6qKeu/Bb0wUwjJFQ7WlpAb\nFo4xVvwN+VkT0+1h+9lFj9iyJwKBgQDfzWGoAPBdTumcmpSxTPaAw9RSQW2DAK5+\nTycvQw9qzG6yzl19YzS7HDn0z728fMkpri3fHqZvIEPiIiapI9MAysIJM8TG2ush\nup0FsjCDbfCzSfAcZOIe4/8MDCB6bJg70Npevu2hCIoNPJY8kThrnAxdiVq17w7F\nq5ktEj+7sQKBgQCtBLT4RTkFwJGCfI+2CHJAcApLgyELz1Tj3K61azWm6gkJVEFp\nmcfkeiZAMpjjeInXUdfn5wLjetps0meG+X3vAXaeD/v0/LRdOokL8vZhD0PYFmxn\nl/1sVLQ2t+119Sb7Fh93CnRWG3uBN3nQC3+EfbpPzL5s4bfHxiFXoXD7SQKBgD27\nK+2oXKSQKLXumYcSQIgh/AW4UFmrLXZfpOJPcAg4XWxqqbT1UU0vKvlQ9/fuv5oE\nlliN3sCWOMM+QkWzQPdd9gmNwwBK0EKcc8VnciQ+hf8eLOHYHdsBbo9HJQo/u/n7\n0NADgA5ECbg+9v273MEp6OtAAMpgJ0X04CpjdzrxAoGAJH652ZjPZbOyK6IHW2K0\n6RkztV0FY/cjz5MUhpyB74drxfP8Ns6vD6O8+YQN2IqMq7HV/wgNTF8xPKZ0TbG6\nsu42RjPTuUzS2KI9Vian+EIZchFaHphk42G6JL7uHQpQDpdfERjZby6Ct/oqEErb\nt/BQLlEmw0qQ/NmF6gtGFnc=\n-----END PRIVATE KEY-----\n",
  "client_email": "service-account@sheetbase-436908.iam.gserviceaccount.com",
  "client_id": "105871680440677979954",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40sheetbase-436908.iam.gserviceaccount.com"
}
''';

// SpreadSheet ID i created using GOOGLEAPI
const _spreadsheetId = '1v7xBELkY1Dy3PsD6yBnQEws0l5gA9z0mCMwJ5gI3oMM';

class GoogleSheetService {

  final GSheets _gsheets = GSheets(_credentials);
  final DjangoApiService _djangoApiService = DjangoApiService();

  Worksheet? _worksheet;

  // Initializes the Google Sheets worksheet for 'Anime'
  Future<void> init() async {
    try {
      final ss = await _gsheets.spreadsheet(_spreadsheetId);
      _worksheet =
          ss.worksheetByTitle('Anime') ?? await ss.addWorksheet('Anime');
    } catch (e) {
      // Handle any errors during initialization
    }
  }

  // Reads all anime rows from the worksheet and converts them into a list of AnimeModel
  Future<List<AnimeModel>> readAnimeRows() async {
    if (_worksheet == null) throw Exception('Worksheet not initialized.');

    // Read all rows as List<List<String>>
    final List<List<String>> rows =
        await _worksheet!.values.allRows(fromRow: 1);

    // Assuming the first row contains the headers
    if (rows.isEmpty) return [];

    // Get the headers from the first row
    final headers = rows[0];
    try {
      // Convert the remaining rows into a list of AnimeModel
      final List<AnimeModel> animeList = rows.skip(1).map((row) {
        // Create a map from the header and row data
        final Map<String, dynamic> rowMap =
            Map.fromIterables(headers as Iterable<String>, row);
        return AnimeModel.fromJson(rowMap);
      }).toList();

      return animeList;
    } catch (e) {
      return [];
    }
  }

  // Appends a new anime row to the worksheet and creates it in the Django API
  Future<void> createAnimeRow(AnimeModel anime) async {
    if (_worksheet == null) throw Exception('Worksheet not initialized.');

    await _worksheet!.values.appendRow(anime.toJson().values.toList());
    await _djangoApiService.createAnime(anime);
  }

  // Updates an existing anime row in the worksheet and the Django API
  Future<void> updateAnimeRow(AnimeModel updatedAnime) async {
    if (_worksheet == null) throw Exception('Worksheet not initialized.');

    final rowIndex = await _findRowIndex(updatedAnime.id);
    if (rowIndex != null) {
      await _worksheet!.values
          .insertRow(rowIndex + 1, updatedAnime.toJson().values.toList());
      await _djangoApiService.updateAnime(updatedAnime);
    } else {
      throw Exception('Anime not found');
    }
  }

  // Deletes an anime row from the worksheet and the Django API based on ID
  Future<void> deleteAnimeRow(String id) async {
    if (_worksheet == null) throw Exception('Worksheet not initialized.');

    final index = await _worksheet!.values.rowIndexOf(id);

    if (index == -1) return;

    await _worksheet!.deleteRow(index);
    await _djangoApiService.deleteAnime(id);
  }

  // Finds the row index of an anime based on its ID
  Future<int?> _findRowIndex(String id) async {
    if (_worksheet == null) throw Exception('Worksheet not initialized.');

    final rows = await _worksheet!.values.allRows();
    for (int i = 0; i < rows.length; i++) {
      if (rows[i][0] == id) {
        // Assuming ID is in the first column
        return i;
      }
    }
    return null; // Not found
  }
}

class DjangoApiService {
  // Fetch all anime (GET)
  Future<List<AnimeModel>> fetchAnime() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((anime) => AnimeModel.fromJson(anime)).toList();
      } else {
        throw Exception('Failed to load anime');
      }
    } catch (e) {
      return [];
    }
  }

  // Create a new anime (POST)
  Future<AnimeModel> createAnime(AnimeModel anime) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(anime.toJson()),
    );

    if (response.statusCode == 201) {
      return AnimeModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create anime');
    }
  }

  // Update an existing anime (PUT)
  Future<AnimeModel> updateAnime(AnimeModel anime) async {
    final response = await http.put(
      Uri.parse('$baseUrl${anime.id}/'), // Use anime id to update
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(anime.toJson()),
    );

    if (response.statusCode == 200) {
      return AnimeModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update anime');
    }
  }

  // Delete an anime (DELETE)
  Future<void> deleteAnime(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl$id/'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete anime');
    }
  }
}

