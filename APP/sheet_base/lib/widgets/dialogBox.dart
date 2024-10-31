import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sheet_base/Models/pirateSheetBase.dart';
import 'package:sheet_base/Services/api_services.dart';
import 'package:sheet_base/Utils/util.dart';

//This dialog box is used for both updation and creation by both GSheet and Django
class AnimeDialog extends StatelessWidget {
  final AnimeModel? anime;
  final int tabIndex;
  final Utils util;
  final GlobalKey<FormState> formKey;
  final Function(AnimeModel animeToSave) handleGSSubmission;
  final Function(AnimeModel animeToSave) handleDBSubmission;
  final GoogleSheetService googleSheetService;
  final DjangoApiService djangoApiService;
  final Function() initPrefs;

  const AnimeDialog(
      {super.key,
      this.anime,
      required this.tabIndex,
      required this.util,
      required this.formKey,
      required this.handleGSSubmission,
      required this.handleDBSubmission,
      required this.googleSheetService,
      required this.djangoApiService,
      required this.initPrefs});

  @override
  Widget build(BuildContext context) {
    String animeName = anime?.animeName ?? '';
    String season = anime?.season.toString() ?? '';
    String episodeNumber = anime?.episodeNumber.toString() ?? '';
    String releaseDay = anime?.releaseDay ?? '';
    String releaseTime = anime?.releaseTime != null
        ? DateFormat.Hms().format(anime!.releaseTime)
        : '';
    String releaseDate = anime?.releaseDate != null
        ? DateFormat('yyyy-MM-dd').format(anime!.releaseDate)
        : '';
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    dateController.text = releaseDate;
    timeController.text = releaseTime;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        anime == null ? 'Add Anime Details' : 'Edit Anime Details',
        style: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(20),
          ),
          height: 500,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Anime Name Field
                buildTextField(
                  initialValue: animeName,
                  hintText: 'Anime Name',
                  onChanged: (value) => animeName = value,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter anime name'
                      : null,
                ),
                const SizedBox(height: 20),
                // Season Field
                buildTextField(
                  initialValue: season,
                  hintText: 'Season',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => season = value,
                  validator: (value) => value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null
                      ? 'Please enter a valid season number'
                      : null,
                ),
                const SizedBox(height: 20),
                // Episode Number Field
                buildTextField(
                  initialValue: episodeNumber,
                  hintText: 'Episode Number',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => episodeNumber = value,
                  validator: (value) => value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null
                      ? 'Please enter a valid episode number'
                      : null,
                ),
                const SizedBox(height: 20),
                // Release Date Field
                buildDateField(context, dateController, releaseDate, (date) {
                  releaseDate = DateFormat('yyyy-MM-dd').format(date);
                  releaseDay = DateFormat('EEEE').format(date);
                }),
                const SizedBox(height: 20),
                // Release Time Field
                buildTimeField(context, timeController, releaseTime, (time) {
                  releaseTime =
                      "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              int parsedSeason = int.tryParse(season) ?? 1;
              int parsedEpisodeNumber = int.tryParse(episodeNumber) ?? 1;
              DateTime parsedDate = DateTime.parse(releaseDate);
              DateTime parsedTime = DateFormat.Hms().parse(releaseTime);
              DateTime now = DateTime.now();

              AnimeModel animeToSave = anime ??
                  AnimeModel(
                    id: await util.createUniqueId(),
                    animeName: animeName,
                    season: parsedSeason,
                    episodeNumber: parsedEpisodeNumber,
                    releaseTime: parsedTime,
                    releaseDate: parsedDate,
                    releaseDay: releaseDay,
                    createdDateTime: now,
                    updatedDateTime: now,
                  );

              if (anime != null) {
                animeToSave.animeName = animeName;
                animeToSave.season = parsedSeason;
                animeToSave.episodeNumber = parsedEpisodeNumber;
                animeToSave.releaseTime = parsedTime;
                animeToSave.releaseDate = parsedDate;
                animeToSave.releaseDay = releaseDay;
                animeToSave.updatedDateTime = now;
              }

              if (tabIndex == 0) {
                if (anime == null) {
                  handleGSSubmission(animeToSave);
                } else {
                  await googleSheetService.updateAnimeRow(animeToSave);
                }
              } else if (tabIndex == 1) {
                if (anime == null) {
                  handleDBSubmission(animeToSave);
                } else {
                  await djangoApiService.updateAnime(animeToSave);
                }
              }

              initPrefs();

              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextField({
    required String initialValue,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15),
    );
  }

  Widget buildDateField(BuildContext context, TextEditingController controller,
      String releaseDate, Function(DateTime) onDateSelected) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        icon: const Icon(Icons.calendar_today, color: Colors.black),
        hintText: "Release Date (YYYY-MM-DD)",
      ),
      readOnly: true,
      onTap: () async {
        DateTime? selectedDate = await showDatePicker(
          context: context,
          initialDate: anime?.releaseDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (selectedDate != null) {
          controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
          onDateSelected(selectedDate);
        }
      },
    );
  }

  Widget buildTimeField(BuildContext context, TextEditingController controller,
      String releaseTime, Function(TimeOfDay) onTimeSelected) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        icon: const Icon(Icons.access_time, color: Colors.black),
        hintText: "Release Time (HH:MM)",
      ),
      readOnly: true,
      onTap: () async {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime:
              TimeOfDay.fromDateTime(anime?.releaseTime ?? DateTime.now()),
        );

        if (selectedTime != null) {
          controller.text =
              "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
          onTimeSelected(selectedTime);
        }
      },
    );
  }
}
