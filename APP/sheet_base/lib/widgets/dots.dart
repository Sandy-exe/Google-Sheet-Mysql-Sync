import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON handling
import 'package:sheet_base/constants/constants.dart'; // Import your constants file

// Code to Perform Initial Syncing 
class VerticalDotsMenu extends StatefulWidget {
  final Function() initPrefs; // Input parameter for initPrefs

  const VerticalDotsMenu({required this.initPrefs, Key? key}) : super(key: key);

  @override
  _VerticalDotsMenuState createState() => _VerticalDotsMenuState();
}

class _VerticalDotsMenuState extends State<VerticalDotsMenu> {
  bool _isSyncing = false;
  String _statusMessage = "Press 'Sync Now' to start syncing.";

  @override
  void initState() {
    super.initState(); // Call the initPrefs function during initialization
  }

  // Function to send POST request and handle response
  Future<void> _startSync() async {
    setState(() {
      _isSyncing = true;
      _statusMessage = "Syncing started...";
    });

    try {
      // Send empty POST request
      final response = await http
          .post(Uri.parse('${baseUrl.substring(0, 26)}sync_sheet_base/'));

      if (response.statusCode == 200) {
        // Successful sync
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _statusMessage = "Sync complete! "
              "${jsonResponse['missing_in_db']} missing in DB, "
              "${jsonResponse['missing_in_sheet']} missing in Sheet.";
        });
      } else {
        // Server returned an error
        setState(() {
          _statusMessage =
              "Error: Unable to sync. Status Code: ${response.statusCode}";
        });
      }
    } catch (e) {
      // Handle any errors
      setState(() {
        _statusMessage = "Error: Unable to connect to server.";
      });
    } finally {
      // This is called after the sync completes (success or failure)
      setState(() {
        _isSyncing = false;
        _statusMessage = "Sync Complete";
      });
      widget.initPrefs();
    }
  }

  // Show sync dialog box
  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog until sync is complete
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'Sync Google Sheet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _isSyncing
                    ? [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(_statusMessage),
                      ]
                    : [
                        Text(
                          _statusMessage,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                if (!_isSyncing)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isSyncing = true;
                        _statusMessage = "Syncing started...";
                      });
                      _startSync().then((_) {
                        setState(() {
                          // Update dialog content after syncing completes
                          _isSyncing = false;
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Sync button color
                      foregroundColor: Colors.white, // Sync button text color
                    ),
                    child: const Text('Sync Now'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'Sync') {
          setState(() {
            _statusMessage = "Press 'Sync Now' to start syncing.";
          });
          _showSyncDialog(context);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'Sync',
            child: Text(
              'Sync',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Darker text
                fontSize: 16,
              ),
            ),
          ),
        ];
      },
      icon: const Icon(Icons.more_vert, color: Colors.black),
      color: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}
