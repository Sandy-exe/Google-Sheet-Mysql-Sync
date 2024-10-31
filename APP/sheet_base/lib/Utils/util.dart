import 'package:sheet_base/Models/pirateSheetBase.dart';
import 'package:sheet_base/Services/api_services.dart';
import 'package:uuid/uuid.dart';

// to Create an UniqueID
class Utils {

  GoogleSheetService googleSheetService = GoogleSheetService();

  
  
  Future<String> createUniqueId() async {
    var uuid = const Uuid();
    await googleSheetService.init();

    //check for existing id and create a new one
    List<AnimeModel> animeList = await googleSheetService.readAnimeRows();
    List<String> existingIds = animeList.map((anime) => anime.id).toList();
    
    String id = uuid.v4();
    while (existingIds.contains(id)) {
      id = uuid.v4();
    }
    return id;
  }
}
