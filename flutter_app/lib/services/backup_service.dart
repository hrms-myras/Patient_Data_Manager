// 



import 'dart:convert';
import 'dart:html' as html;
import '../models/patient.dart';
import 'api_service.dart';

class BackupService {
  static final ApiService _apiService = ApiService();

  // ─── GENERATE BACKUP CSV ─────────────────────────────────────────────

  static String generateBackupCSV(List<Patient> patients) {
    final rows = <List<String>>[];

    rows.add([
      'Patient Name',
      'Registration Date',
      'Phone',
      'Address',
      'Package (₹)',
      'Total Cash (₹)',
      'Total Bank (₹)',
      'Balance (₹)',
      'Cash Entries',
      'Bank Entries',
    ]);

    for (final p in patients) {
      final cashTotal = (p.cashEntries ?? [])
          .fold<double>(0, (s, e) => s + (double.tryParse(e.amount) ?? 0));
      final bankTotal = (p.bankEntries ?? [])
          .fold<double>(0, (s, e) => s + (double.tryParse(e.amount) ?? 0));
      final pkg = double.tryParse(p.package ?? '0') ?? 0;
      final balance = pkg - cashTotal - bankTotal;

      String cashEntriesStr = 'No cash entries';
      if (p.cashEntries != null && p.cashEntries!.isNotEmpty) {
        cashEntriesStr = p.cashEntries!
            .map((e) => '${e.entryDate}:₹${e.amount}')
            .join('; ');
      }

      String bankEntriesStr = 'No bank entries';
      if (p.bankEntries != null && p.bankEntries!.isNotEmpty) {
        bankEntriesStr = p.bankEntries!
            .map((e) => '${e.entryDate}:₹${e.amount}')
            .join('; ');
      }

      rows.add([
        p.patientName,
        p.date ?? '',
        p.phone ?? '',
        p.address ?? '',
        pkg.toStringAsFixed(2),
        cashTotal.toStringAsFixed(2),
        bankTotal.toStringAsFixed(2),
        balance.toStringAsFixed(2),
        cashEntriesStr,
        bankEntriesStr,
      ]);
    }

    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCSV).join(','));
    }
    return buffer.toString();
  }

  static String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // ─── SEND BACKUP EMAIL ──────────────────────────────────────────────

  static Future<bool> sendBackupEmail({
    required List<Patient> patients,
    required String recipientEmail,
    String? customMessage,
  }) async {
    try {
      final csvData = generateBackupCSV(patients);

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'backup_$timestamp.csv';

      final bytes = utf8.encode(csvData);

      final backupData = {
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'totalPatients': patients.length,
      };

      final response = await _apiService.sendBackupEmail(
        recipientEmail: recipientEmail,
        fileName: fileName,
        fileBytes: bytes,
        backupData: backupData,
        customMessage: customMessage,
      );

      // 👇 UPDATED: Proper error logging
      if (response['success'] == true) {
        return true;
      } else {
        print('❌ Backup failed. Backend response: $response');
        html.window.alert('Backup failed: ${response['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      print('❌ Backup email exception: $e');
      html.window.alert('Backup crashed: $e');
      return false;
    }
  }

  // ─── MANUAL BACKUP ──────────────────────────────────────────────────

  static Future<bool> manualBackup() async {
    try {
      final patients = await _apiService.getAllPatients();
      final userEmail = await _apiService.getUserEmail();

      if (userEmail == null) {
        throw 'User email not found';
      }

      return await sendBackupEmail(
        patients: patients,
        recipientEmail: userEmail,
        customMessage: 'Manual backup - ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      print('Manual backup error: $e');
      return false;
    }
  }

  // ─── TEST BACKUP (10 Seconds) ──────────────────────────────────────

  static void testBackup() async {
    print('🧪 Testing backup in 10 seconds...');

    await Future.delayed(const Duration(seconds: 10));

    try {
      final patients = await _apiService.getAllPatients();
      final userEmail = await _apiService.getUserEmail();

      print('📧 Sending test backup to: $userEmail');
      print('📊 Total patients: ${patients.length}');

      if (userEmail != null && patients.isNotEmpty) {
        final success = await sendBackupEmail(
          patients: patients,
          recipientEmail: userEmail,
          customMessage: '🧪 TEST BACKUP - ${DateTime.now().toString().split(' ')[0]}',
        );

        if (success) {
          print('✅ TEST backup sent successfully to: $userEmail');
          html.window.confirm('✅ Test backup sent to $userEmail!\n\nCheck your email.');
        } else {
          print('❌ TEST backup failed');
          html.window.alert('❌ Test backup failed. Check console for errors.');
        }
      } else {
        print('❌ No patients or user email found');
        html.window.alert('❌ No patients found or user not logged in.');
      }
    } catch (e) {
      print('❌ Test backup error: $e');
      html.window.alert('❌ Error: $e');
    }
  }

  // ─── GENERATE IMPORT TEMPLATE ──────────────────────────────────────

  static List<int> generateImportTemplate() {
    final rows = <List<String>>[];

    rows.add([
      'Patient Name',
      'Registration Date (YYYY-MM-DD)',
      'Phone',
      'Address',
      'Package (₹)',
      'Cash Entry Date (YYYY-MM-DD)',
      'Cash Amount (₹)',
      'Bank Entry Date (YYYY-MM-DD)',
      'Bank Amount (₹)',
    ]);

    rows.add([
      'John Doe',
      '2026-01-01',
      '9876543210',
      '123 Main Street',
      '50000',
      '2026-01-15',
      '10000',
      '2026-01-20',
      '5000',
    ]);

    return _encodeCSV(rows);
  }

  static List<int> _encodeCSV(List<List<String>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escapeCSV).join(','));
    }
    return utf8.encode(buffer.toString());
  }

  // ─── PARSE CSV FOR IMPORT ──────────────────────────────────────────

  static List<Map<String, dynamic>> parseCSVData(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.length < 2) {
      throw 'CSV file is empty or invalid';
    }

    final headers = _parseCSVLine(lines[0]);

    int nameIdx = headers.indexOf('Patient Name');
    int dateIdx = headers.indexOf('Registration Date (YYYY-MM-DD)');
    int phoneIdx = headers.indexOf('Phone');
    int addressIdx = headers.indexOf('Address');
    int packageIdx = headers.indexOf('Package (₹)');
    int cashDateIdx = headers.indexOf('Cash Entry Date (YYYY-MM-DD)');
    int cashAmtIdx = headers.indexOf('Cash Amount (₹)');
    int bankDateIdx = headers.indexOf('Bank Entry Date (YYYY-MM-DD)');
    int bankAmtIdx = headers.indexOf('Bank Amount (₹)');

    if (nameIdx == -1) {
      nameIdx = headers.indexOf('PatientName');
    }
    if (dateIdx == -1) {
      dateIdx = headers.indexOf('RegistrationDate');
    }
    if (packageIdx == -1) {
      packageIdx = headers.indexOf('Package');
    }

    final patientMap = <String, Map<String, dynamic>>{};

    for (int i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;

      final values = _parseCSVLine(lines[i]);
      if (values.length < headers.length) continue;

      final name = nameIdx != -1 && nameIdx < values.length ? values[nameIdx].trim() : '';
      if (name.isEmpty) continue;

      if (!patientMap.containsKey(name)) {
        patientMap[name] = {
          'patientName': name,
          'date': dateIdx != -1 && dateIdx < values.length ? values[dateIdx].trim() : '',
          'phone': phoneIdx != -1 && phoneIdx < values.length ? values[phoneIdx].trim() : '',
          'address': addressIdx != -1 && addressIdx < values.length ? values[addressIdx].trim() : '',
          'package': packageIdx != -1 && packageIdx < values.length ? values[packageIdx].trim() : '0',
          'cashEntries': <Map<String, String>>[],
          'bankEntries': <Map<String, String>>[],
        };
      }

      if (cashDateIdx != -1 && cashAmtIdx != -1 &&
          cashDateIdx < values.length && cashAmtIdx < values.length) {
        final cashDate = values[cashDateIdx].trim();
        final cashAmt = values[cashAmtIdx].trim();
        if (cashDate.isNotEmpty && cashAmt.isNotEmpty) {
          (patientMap[name]!['cashEntries'] as List<Map<String, String>>).add({
            'entryDate': cashDate,
            'amount': cashAmt,
          });
        }
      }

      if (bankDateIdx != -1 && bankAmtIdx != -1 &&
          bankDateIdx < values.length && bankAmtIdx < values.length) {
        final bankDate = values[bankDateIdx].trim();
        final bankAmt = values[bankAmtIdx].trim();
        if (bankDate.isNotEmpty && bankAmt.isNotEmpty) {
          (patientMap[name]!['bankEntries'] as List<Map<String, String>>).add({
            'entryDate': bankDate,
            'amount': bankAmt,
          });
        }
      }
    }

    return patientMap.values.toList();
  }

  static List<String> _parseCSVLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());
    return result;
  }
}