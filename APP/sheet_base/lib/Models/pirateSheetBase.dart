import 'package:intl/intl.dart'; // Use the intl package for date formatting

class AnimeModel {
  late String id;
  late String animeName;
  late int season;
  late int episodeNumber;
  late DateTime releaseTime; // Use DateTime for releaseTime
  late DateTime releaseDate; // Use DateTime for releaseDate
  late String releaseDay;
  late DateTime updatedDateTime;
  late DateTime createdDateTime;

  AnimeModel(
      {required this.id,
      required this.animeName,
      required this.season,
      required this.episodeNumber,
      required this.releaseTime,
      required this.releaseDate,
      required this.releaseDay,
      required this.updatedDateTime,
      required this.createdDateTime});

  // Factory constructor to create a new AnimeModel from JSON data
  factory AnimeModel.fromJson(Map<String, dynamic> json) {
    return AnimeModel(
      id: json['id'], // Assuming 'id' comes as a string
      animeName: json['anime_name'],
      season: json['season'] is String
          ? int.parse(json['season'])
          : json['season'],
      episodeNumber: json['episode_number'] is String
          ? int.parse(json['episode_number'])
          : json['episode_number'],

      // Parse the 'release_time' as a DateTime object (HH:MM:SS format)
      releaseTime: _parseReleaseTime(json['release_time']),

      // Parse the 'release_date' as a DateTime object (YYYY-MM-DD format)
      releaseDate: _parseReleaseDate(json['release_date']),
      releaseDay: json['release_day'],
      updatedDateTime: DateTime.parse(json['updated_datetime']),
      createdDateTime: DateTime.parse(json['created_datetime']),
    );
  }

 static DateTime _parseReleaseTime(dynamic releaseTime) {
    if (releaseTime is String) {
      // Check if the string can be parsed as a double
      double? timeAsDouble = double.tryParse(releaseTime);
      if (timeAsDouble != null) {
        return _convertFractionalTimeToDateTime(timeAsDouble);
      } else {
        return DateFormat.Hms().parse(releaseTime);
      }
    } else if (releaseTime is double) {
      return _convertFractionalTimeToDateTime(releaseTime);
    }
    throw FormatException('Invalid release time format');
  }

  static DateTime _parseReleaseDate(dynamic releaseDate) {
    if (releaseDate is String) {
      // Try to parse the string as an integer (for Julian date format)
      int? dateAsInt = int.tryParse(releaseDate);
      if (dateAsInt != null) {
        // If the string can be parsed as an integer, treat it as a Julian date
        return _convertJulianDateToDateTime(dateAsInt);
      } else {
        // Otherwise, try to parse it as a regular date string
        try {
          return DateTime.parse(releaseDate);
        } catch (e) {
          throw FormatException('Invalid date string format: $releaseDate');
        }
      }
    } else if (releaseDate is int) {
      // If it's already an integer, assume it's a Julian date
      return _convertJulianDateToDateTime(releaseDate);
    }
    throw FormatException('Invalid release date format');
  }


  static DateTime _convertFractionalTimeToDateTime(double time) {
    int totalSeconds = (time * 24 * 60 * 60).toInt();
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    DateTime now = DateTime.now(); 
    // Use the current date
    return DateTime(now.year, now.month, now.day, hours, minutes, seconds);
  }

  static DateTime _convertJulianDateToDateTime(int julianDate) {
    DateTime baseDate = DateTime(1899, 12, 30);
    // Base date for conversion
    return baseDate.add(Duration(days: julianDate));
  }

  // Convert the AnimeModel into JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id, // Keep 'id' as string
      'anime_name': animeName, // Use 'anime_name' key
      'season': season, // Integer for season
      'episode_number': episodeNumber, // Integer for episode number

      // Format the DateTime object to a string in HH:MM:SS format for release_time
      'release_time': DateFormat.Hms().format(releaseTime),

      // Format the DateTime object to a string in YYYY-MM-DD format for release_date
      'release_date': DateFormat('yyyy-MM-dd').format(releaseDate),

      'release_day': releaseDay, // Day as string

      // Format updatedDateTime to ISO 8601
      'updated_datetime':
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(updatedDateTime),

      'created_datetime':
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdDateTime),
    };
  }
}
