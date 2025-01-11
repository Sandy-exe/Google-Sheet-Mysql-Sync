import 'dart:convert';
import 'package:gsheets/gsheets.dart';
import 'package:http/http.dart' as http;
import 'package:sheet_base/Models/pirateSheetBase.dart';
import 'package:sheet_base/constants/constants.dart';



class GoogleSheetService {

  final GSheets _gsheets = GSheets(credentials);
  final DjangoApiService _djangoApiService = DjangoApiService();

  Worksheet? _worksheet;

  // Initializes the Google Sheets worksheet for 'Anime'
  Future<String> init() async {
    try {
      print("Google service Initiated!!!");
      final ss = await _gsheets.spreadsheet(spreadsheetId);
      _worksheet =
          ss.worksheetByTitle('Anime') ?? await ss.addWorksheet('Anime');
      print(_worksheet);
      return "Success";
    } catch (e) {
      return "Google Error";
      // Handle any errors during initialization
    }
  }

  // Reads all anime rows from the worksheet and converts them into a list of AnimeModel
  Future<List<AnimeModel>> readAnimeRows() async {
    if (_worksheet == null) {
      return []; //WORKSHEET NOT initialized
    }
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

  Future<String> init() async {
    if (baseUrl.isEmpty) {
      return "Django error: The baseUrl cannot be empty.";
    }

    final uri = Uri.tryParse(baseUrl);

    if (uri == null || !uri.hasScheme || !(uri.scheme == "http" || uri.scheme == "https") || !uri.hasAuthority) {
      return "Django error: The baseUrl is not a valid HTTP or HTTPS URL: $baseUrl";
    }

    // If baseUrl passes all validations
    return "Success";
  }

  // Fetch all anime (GET)
  Future<List<AnimeModel>> fetchAnime() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((anime) => AnimeModel.fromJson(anime)).toList();
      } else {
        return [];
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

