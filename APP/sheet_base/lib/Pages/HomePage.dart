import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sheet_base/Models/pirateSheetBase.dart';
import 'package:sheet_base/Utils/util.dart';
import 'package:sheet_base/widgets/dialogBox.dart';
import 'package:sheet_base/widgets/dots.dart';
import 'package:sheet_base/widgets/tiles.dart';
import 'package:sheet_base/Services/api_services.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<AnimeModel> animeListDjango = [];
  late List<AnimeModel> animeListGSheet = [];
  DjangoApiService djangoApiService = DjangoApiService();
  GoogleSheetService googleSheetService = GoogleSheetService();
  bool isLoadingD = true;
  bool isLoadingG = true;
  final Utils util = Utils();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    initPrefs();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // initPrefs initializes and updates the state of the specified variables, affecting the UI appearance and behavior.
  Future<void> initPrefs() async {
    await googleSheetService.init();
    setState(() {
      isLoadingD = true;
      isLoadingG = true;
    });
    List<AnimeModel> djangoTemp = await djangoApiService.fetchAnime();
    List<AnimeModel> gsheetTemp = await googleSheetService.readAnimeRows();
    setState(() {
      animeListDjango = djangoTemp;
      isLoadingD = false;
    });
    setState(() {
      animeListGSheet = gsheetTemp;
      isLoadingG = false;
    });
  }


  // Removes an anime entry based on its unique ID. The deletion source is determined by the currently active tab.
  Future<void> _removeAnime(String id) async {
    int tabIndex = _tabController.index;
    if (tabIndex == 0) {
      // If the first tab is active, delete the anime from Google Sheets.
      await googleSheetService.deleteAnimeRow(id);
      initPrefs(); // Refresh preferences to update the UI.
    } else if (tabIndex == 1) {
      // If the second tab is active, delete the anime from the Django API.
      await djangoApiService.deleteAnime(id);
      initPrefs(); // Refresh preferences to update the UI.
    }
  }

// Opens a dialog to update an anime's details. The dialog context is determined by the currently active tab.
  Future<void> _updateAnime({AnimeModel? anime}) async {
    int tabIndex = _tabController.index;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        
        return AnimeDialog(
          anime: anime,
          tabIndex: tabIndex,
          util: util,
          formKey: _formKey,
          handleGSSubmission:
              handleGSSubmission,
          handleDBSubmission:
              handleDBSubmission, 
          googleSheetService: googleSheetService,
          djangoApiService: djangoApiService,
          initPrefs: initPrefs, // Refresh preferences after submission.
        );
      },
    );
  }

// Handles the submission of a new anime entry to the database.
  void handleDBSubmission(AnimeModel anime) async {
    await djangoApiService
        .createAnime(anime); // Create a new anime entry in the Django API.
    initPrefs(); // Refresh preferences to update the UI after the submission.
  }

// Handles the submission of a new anime entry to Google Sheets.
  void handleGSSubmission(AnimeModel newAnime) async {
    await googleSheetService
        .createAnimeRow(newAnime); // Create a new anime entry in Google Sheets API.
    initPrefs(); // Refresh preferences to update the UI after the submission.
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget showDialogBox() {
    return const Center(
      child: Text(
        'No Data available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'Pirate List',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            VerticalDotsMenu(
              initPrefs: initPrefs,
            ), 
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          isLoadingG
              ? const Center(child: CircularProgressIndicator())
              : animeListGSheet.isEmpty
                  ? showDialogBox()
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 30,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ListView.separated(
                              itemBuilder: (context, index) => AnimeTile(
                                anime: animeListGSheet[index],
                                onRemove: () =>
                                    _removeAnime(animeListGSheet[index].id),
                                onUpdate: () =>
                                    _updateAnime(anime: animeListGSheet[index]),
                              ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 20),
                              itemCount: animeListGSheet.length,
                            ),
                          ),
                        ],
                      ),
                    ),
          isLoadingD
              ? const Center(child: CircularProgressIndicator())
              : animeListDjango.isEmpty
                  ? showDialogBox()
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 30,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ListView.separated(
                              itemBuilder: (context, index) => AnimeTile(
                                anime: animeListDjango[index],
                                onRemove: () =>
                                    _removeAnime(animeListDjango[index].id),
                                onUpdate: () =>
                                    _updateAnime(anime: animeListDjango[index]),
                              ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 20),
                              itemCount: animeListDjango.length,
                            ),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _updateAnime();
        },
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: Padding( //for the Tab Navigation
        padding: const EdgeInsets.only(bottom: 30),
        child: TabBar(
          controller: _tabController,
          dividerHeight: 0,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black,
          ),
          tabs: [
            Tab(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Gsheet",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            Tab(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Django",
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
