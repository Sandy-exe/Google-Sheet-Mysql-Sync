import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sheet_base/Models/pirateSheetBase.dart'; // Update the import statement to your actual file path


//Basic Tile Design
class AnimeTile extends StatelessWidget {
  final AnimeModel anime;
  final VoidCallback onRemove;
  final VoidCallback onUpdate; // Callback for updating the anime details

  const AnimeTile({
    super.key,
    required this.anime,
    required this.onRemove,
    required this.onUpdate, // Add the onUpdate parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Adding elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(
          vertical: 8, horizontal: 8), // Spacing around the tile
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // Set background to black
          borderRadius: BorderRadius.circular(20),
        ),
        width: double.infinity,
        height: 130,
        child: Padding(
          padding:
              const EdgeInsets.all(12.0), // Increased padding for better layout
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0), // Adjusted padding
                      child: Text(
                        anime.animeName,
                        style: const TextStyle(
                          fontSize: 22, // Slightly larger font size
                          color: Colors.white, // White color for text
                          fontWeight: FontWeight.bold, // Bold font for title
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Text(
                            'S${anime.season} E${anime.episodeNumber}',
                            style: TextStyle(
                              color: Colors.grey[
                                  400], // Lighter grey for better contrast
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.white, // White color for icons
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('yyyy-MM-dd').format(anime.releaseDate),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(
                              width: 10), // Space between date and time
                          const Icon(
                            Icons.access_time, // Time icon
                            size: 20,
                            color: Colors.white, // White color for icons
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm')
                                .format(anime.releaseTime), // Format the time
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center icons vertically
                children: [
                  IconButton(
                    onPressed: onUpdate, // Trigger the update action
                    icon: const Icon(
                      Icons.edit,
                      size: 28, // Adjusted icon size
                      color: Color.fromARGB(255, 255, 255,
                          255), // Update icon color to a standout color
                    ),
                  ),
                  const SizedBox(height: 8), // Space between icons
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(
                      Icons.delete,
                      size: 28, // Adjusted icon size
                      color: Color.fromARGB(
                          255, 255, 255, 255), // Red for delete action
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
