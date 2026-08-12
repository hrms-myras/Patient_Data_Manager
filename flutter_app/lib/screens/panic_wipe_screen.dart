// // lib/screens/panic_wipe_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import '../services/api_service.dart';

// class PanicWipeScreen extends StatefulWidget {
//   const PanicWipeScreen({Key? key}) : super(key: key);

//   @override
//   State<PanicWipeScreen> createState() => _PanicWipeScreenState();
// }

// class _PanicWipeScreenState extends State<PanicWipeScreen> {
//   final _pinControllers = List<TextEditingController>.generate(6, (_) => TextEditingController());
//   bool _isExecuting = false;
//   bool _confirmUnderstanding = false;
//   final _apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     // Set the API token
//     final token = Provider.of<AuthProvider>(context, listen: false).user;
//     if (token != null) {
//       // In a real app, get the token from secure storage
//     }
//   }

//   @override
//   void dispose() {
//     for (var controller in _pinControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   String get _enteredPin => _pinControllers.map((c) => c.text).join();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red[50],
//       appBar: AppBar(
//         backgroundColor: Colors.red[600],
//         title: const Text('Alarm Erase - Panic Wipe'),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             // Warning icon
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.red[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.warning_rounded,
//                 size: 64,
//                 color: Colors.red[600],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Warning text
//             Text(
//               'ALARM ERASE',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red[600],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Permanent Data Deletion',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.red[400],
//               ),
//             ),
//             const SizedBox(height: 32),

//             // Warning message
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 border: Border.all(color: Colors.red[300]!),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     'WARNING',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red[700],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'This action will:\n'
//                     '• Create a final encrypted backup\n'
//                     '• Email the backup to your configured address\n'
//                     '• PERMANENTLY DELETE all patient records\n'
//                     '• This cannot be undone!',
//                     style: TextStyle(
//                       color: Colors.red[700],
//                       height: 1.6,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),

//             // PIN entry
//             Text(
//               'Enter 6-Digit Panic PIN',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red[700],
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildPinEntry(),
//             const SizedBox(height: 32),

//             // Confirm checkbox
//             CheckboxListTile(
//               value: _confirmUnderstanding,
//               onChanged: (value) {
//                 setState(() {
//                   _confirmUnderstanding = value ?? false;
//                 });
//               },
//               title: Text(
//                 'I understand this will permanently delete all data',
//                 style: TextStyle(
//                   color: Colors.red[700],
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Execute button
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: ElevatedButton(
//                 onPressed: _enteredPin.length == 6 && _confirmUnderstanding
//                     ? _executePanicWipe
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red[600],
//                   disabledBackgroundColor: Colors.grey[400],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: _isExecuting
//                     ? const SizedBox(
//                         height: 24,
//                         width: 24,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : const Text(
//                         'EXECUTE PANIC WIPE',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Cancel button
//             SizedBox(
//               width: double.infinity,
//               height: 48,
//               child: OutlinedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: OutlinedButton.styleFrom(
//                   side: BorderSide(color: Colors.red[600]!),
//                 ),
//                 child: Text(
//                   'Cancel',
//                   style: TextStyle(color: Colors.red[600]),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPinEntry() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: List.generate(
//         6,
//         (index) => SizedBox(
//           width: 50,
//           child: TextField(
//             controller: _pinControllers[index],
//             textAlign: TextAlign.center,
//             keyboardType: TextInputType.number,
//             maxLength: 1,
//             onChanged: (value) {
//               if (value.isNotEmpty && index < 5) {
//                 FocusScope.of(context).nextFocus();
//               } else if (value.isEmpty && index > 0) {
//                 FocusScope.of(context).previousFocus();
//               }
//               setState(() {});
//             },
//             decoration: InputDecoration(
//               counterText: '',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.red[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.red[600]!, width: 2),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _executePanicWipe() async {
//     if (_enteredPin.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a 6-digit PIN'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     // Show final confirmation
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.red[50],
//         title: const Text('FINAL CONFIRMATION'),
//         content: const Text(
//           'This will IMMEDIATELY:\n\n'
//           '1. Backup all patient data\n'
//           '2. Send backup to email\n'
//           '3. PERMANENTLY DELETE all records\n\n'
//           'This cannot be undone!',
//           style: TextStyle(height: 1.6),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text(
//               'CONTINUE WITH PANIC WIPE',
//               style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     setState(() {
//       _isExecuting = true;
//     });

//     try {
//       final result = await _apiService.executePanicWipe(_enteredPin);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(result['message'] ?? 'Panic wipe completed'),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );

//         // Redirect to login after a delay
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) {
//           await Provider.of<AuthProvider>(context, listen: false).logout();
//           Navigator.of(context).pushReplacementNamed('/login');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             backgroundColor: Colors.red,
//           ),
//         );
//         setState(() {
//           _isExecuting = false;
//         });
//       }
//     }
//   }
// }


import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../services/api_service.dart';
import '../services/report_service.dart';
import '../models/user.dart';

class PanicWipeScreen extends StatefulWidget {
  const PanicWipeScreen({Key? key}) : super(key: key);

  @override
  State<PanicWipeScreen> createState() => _PanicWipeScreenState();
}

class _PanicWipeScreenState extends State<PanicWipeScreen> {
  final _pinControllers = List<TextEditingController>.generate(6, (_) => TextEditingController());
  bool _isExecuting = false;
  bool _isImporting = false;
  bool _confirmUnderstanding = false;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).user;
    if (token != null) {
      // Token already set in ApiService
    }
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _enteredPin => _pinControllers.map((c) => c.text).join();

  // ─── DOWNLOAD TEMPLATE ────────────────────────────────────────────────

  void _downloadTemplate() {
    try {
      final bytes = ReportService.generateImportTemplate();
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'patient_import_template.csv')
        ..click();
      html.Url.revokeObjectUrl(url);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Template downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to download template: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─── IMPORT CSV ─────────────────────────────────────────────────────────

  void _importCSV() {
    final input = html.FileUploadInputElement();
    input.accept = '.csv';
    input.click();

    input.onChange.listen((e) async {
      final files = input.files;
      if (files == null || files.isEmpty) return;

      final file = files[0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((event) async {
        try {
          final csvContent = reader.result as String;
          
          // Parse CSV
          final patientsData = ReportService.parseCSVData(csvContent);

          if (patientsData.isEmpty) {
            throw 'No valid patient data found in CSV file';
          }

          setState(() {
            _isImporting = true;
          });

          final patientProvider = Provider.of<PatientProvider>(context, listen: false);
          int successCount = 0;
          int failCount = 0;
          final errors = <String>[];

          for (final data in patientsData) {
            try {
              final result = await patientProvider.createPatient(data, UserRole.owner);
              if (result != null) {
                successCount++;
              } else {
                failCount++;
                errors.add('Failed to import: ${data['patientName']}');
              }
            } catch (e) {
              failCount++;
              errors.add('${data['patientName']}: $e');
            }
          }

          setState(() {
            _isImporting = false;
          });

          // Refresh patient list
          if (successCount > 0) {
            await patientProvider.refresh();
          }

          // Show result
          String message = '✅ $successCount patients imported successfully!';
          if (failCount > 0) {
            message += '\n⚠️ $failCount failed.';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );

          if (errors.isNotEmpty && failCount > 0) {
            // Show errors in dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Import Errors'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: errors.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $e', style: const TextStyle(fontSize: 12)),
                    )).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        } catch (e) {
          setState(() {
            _isImporting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Import failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      });

      reader.readAsText(file);
    });
  }

  // ─── EXECUTE PANIC WIPE ───────────────────────────────────────────────

  Future<void> _executePanicWipe() async {
    if (_enteredPin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit PIN'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show final confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: const Text(
          '⚠️ FINAL CONFIRMATION',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'This will IMMEDIATELY:\n\n'
          '1. Backup all patient data\n'
          '2. Send backup to email\n'
          '3. PERMANENTLY DELETE all records\n\n'
          'This cannot be undone!',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(
              'CONTINUE WITH PANIC WIPE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isExecuting = true;
    });

    try {
      final result = await _apiService.executePanicWipe(_enteredPin);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '✅ Panic wipe completed'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh patient list
        await Provider.of<PatientProvider>(context, listen: false).refresh();

        // Redirect to login after a delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          await Provider.of<AuthProvider>(context, listen: false).logout();
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isExecuting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.user?.isOwner ?? false;

    if (!isOwner) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('Access Denied'),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Only Owners can access this section',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: const Text('System Management'),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── IMPORT SECTION ──────────────────────────────────────
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.upload_file, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Import Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Import patient data from CSV file',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isImporting ? null : _downloadTemplate,
                            icon: _isImporting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.download),
                            label: Text(_isImporting ? 'Loading...' : 'Download Template'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isImporting ? null : _importCSV,
                            icon: _isImporting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.upload),
                            label: Text(_isImporting ? 'Importing...' : 'Import CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Template format: Patient Name, Date, Phone, Address, Package, Cash entries, Bank entries',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── PANIC WIPE SECTION ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Warning icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 56,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    '⚠️ SYSTEM RESET',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Permanent Data Deletion',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[400],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Warning message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'WARNING',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This action will:\n'
                          '• Create a final encrypted backup\n'
                          '• Email the backup to your configured address\n'
                          '• PERMANENTLY DELETE all patient records\n'
                          '• This cannot be undone!',
                          style: TextStyle(
                            color: Colors.red[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PIN entry
                  Text(
                    'Enter 6-Digit Panic PIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPinEntry(),
                  const SizedBox(height: 24),

                  // Confirm checkbox
                  CheckboxListTile(
                    value: _confirmUnderstanding,
                    onChanged: (value) {
                      setState(() {
                        _confirmUnderstanding = value ?? false;
                      });
                    },
                    title: Text(
                      'I understand this will permanently delete all data',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                    activeColor: Colors.red,
                  ),
                  const SizedBox(height: 16),

                  // Execute button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _enteredPin.length == 6 && _confirmUnderstanding && !_isExecuting
                          ? _executePanicWipe
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        disabledBackgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isExecuting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'EXECUTE SYSTEM RESET',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _isExecuting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red[600]!),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red[600]),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Export your data before system reset. Use Import feature to restore data from CSV backup.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinEntry() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 45,
          child: TextField(
            controller: _pinControllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                FocusScope.of(context).nextFocus();
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
              setState(() {});
            },
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red[600]!, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

