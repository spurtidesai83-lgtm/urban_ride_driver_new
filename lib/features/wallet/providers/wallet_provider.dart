import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../shared/utils/notification_service.dart';
import '../data/repositories/wallet_repository.dart';
import '../data/models/wallet_models.dart';

class TransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String status; // 'Completed' or 'Pending'

  TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class WalletState {
  final double balance;
  final String nextPayoutDate;
  final double monthlyEarnings;
  final double rideEarnings;
  final double bonus;
  final int totalRides;
  final double rating;
  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool isDownloadingStatement;
  final double totalKm;
  final double ratePerKm;
  final double totalBalance;
  final List<Map<String, dynamic>> dailyIncentives;
  final String? driverId;
  final List<DailyLogModel> dailyLogs;
  final List<MonthlyStatementModel> monthlyStatements;
  final String? errorMessage;

  WalletState({
    required this.balance,
    required this.nextPayoutDate,
    required this.monthlyEarnings,
    required this.rideEarnings,
    required this.bonus,
    required this.totalRides,
    required this.rating,
    required this.transactions,
    this.isLoading = false,
    this.isDownloadingStatement = false,
    this.totalKm = 0,
    this.ratePerKm = 0,
    this.totalBalance = 0,
    this.dailyIncentives = const [],
    this.driverId,
    this.dailyLogs = const [],
    this.monthlyStatements = const [],
    this.errorMessage,
  });

  WalletState copyWith({
    double? balance,
    String? nextPayoutDate,
    double? monthlyEarnings,
    double? rideEarnings,
    double? bonus,
    int? totalRides,
    double? rating,
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? isDownloadingStatement,
    double? totalKm,
    double? ratePerKm,
    double? totalBalance,
    List<Map<String, dynamic>>? dailyIncentives,
    String? driverId,
    List<DailyLogModel>? dailyLogs,
    List<MonthlyStatementModel>? monthlyStatements,
    String? errorMessage,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      nextPayoutDate: nextPayoutDate ?? this.nextPayoutDate,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      rideEarnings: rideEarnings ?? this.rideEarnings,
      bonus: bonus ?? this.bonus,
      totalRides: totalRides ?? this.totalRides,
      rating: rating ?? this.rating,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isDownloadingStatement: isDownloadingStatement ?? this.isDownloadingStatement,
      totalKm: totalKm ?? this.totalKm,
      ratePerKm: ratePerKm ?? this.ratePerKm,
      totalBalance: totalBalance ?? this.totalBalance,
      dailyIncentives: dailyIncentives ?? this.dailyIncentives,
      driverId: driverId ?? this.driverId,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      monthlyStatements: monthlyStatements ?? this.monthlyStatements,
      errorMessage: errorMessage,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;

  WalletNotifier(this._repository)
      : super(WalletState(
          balance: 0,
          nextPayoutDate: '',
          monthlyEarnings: 0,
          rideEarnings: 0,
          bonus: 0,
          totalRides: 0,
          rating: 0,
          transactions: [],
          isDownloadingStatement: false,
        )) {
    _loadWalletData();
  }

  // Fetch wallet balance from API
  Future<void> fetchWallet() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final wallet = await _repository.getWallet();
      
      state = state.copyWith(
        balance: wallet.currentBalance,
        totalBalance: wallet.currentBalance,
        driverId: wallet.driverIamUuid,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        balance: 0,
        errorMessage: 'Failed to fetch wallet: $e',
      );
    }
  }

  // Fetch daily logs from API
  Future<void> fetchDailyLogs() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final logsResponse = await _repository.getDailyLogs();
      
      // Calculate total earnings from logs
      final totalEarnings = logsResponse.data.fold<double>(
        0, 
        (sum, log) => sum + log.calculatedEarnings,
      );
      
      // Calculate total kilometers
      final totalKm = logsResponse.data.fold<double>(
        0,
        (sum, log) => sum + double.parse(log.kilometersDriven),
      );
      
      state = state.copyWith(
        dailyLogs: logsResponse.data,
        monthlyEarnings: totalEarnings,
        totalKm: totalKm,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Fetch monthly statements from API
  Future<void> fetchMonthlyStatements() async {
    try {
      state = state.copyWith(isLoading: true);
      print('💰 [WalletProvider] Fetching monthly statements...');
      
      final statementsResponse = await _repository.getMonthlyStatements();
      
      print('💰 [WalletProvider] Received ${statementsResponse.data.length} statements');
      print('💰 [WalletProvider] Success: ${statementsResponse.success}, Message: ${statementsResponse.message}');
      
      state = state.copyWith(
        monthlyStatements: statementsResponse.data,
        isLoading: false,
        errorMessage: null,
      );
      
      print('✅ [WalletProvider] Monthly statements state updated with ${state.monthlyStatements.length} items');
    } catch (e) {
      print('❌ [WalletProvider] Monthly statements fetch failed: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Update daily wallet with kilometers driven
  Future<void> updateDailyWallet(double kilometers) async {
    try {
      state = state.copyWith(isLoading: true);
      
      final response = await _repository.updateDailyWallet(kilometers);
      
      if (response.success) {
        state = state.copyWith(
          balance: response.data.currentBalance,
          driverId: response.data.driverIamUuid,
          isLoading: false,
          errorMessage: null,
        );
        
        // Refresh daily logs after update
        await fetchDailyLogs();
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void _loadWalletData() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      balance: 0,
      totalBalance: 0,
      nextPayoutDate: '',
      monthlyEarnings: 0,
      rideEarnings: 0,
      bonus: 0,
      totalRides: 0,
      rating: 0,
      totalKm: 0,
      ratePerKm: 0,
      dailyIncentives: [],
      dailyLogs: [],
      monthlyStatements: [],
      transactions: [],
    );

    await fetchWallet();
    await fetchDailyLogs();
    await fetchMonthlyStatements();
  }

  Future<String> downloadMonthlyStatement({
    required String driverId,
    DateTime? month,
  }) async {
    state = state.copyWith(isDownloadingStatement: true);
    final notificationService = NotificationService();
    const notificationId = 1001;

    try {
      // Show download notification
      await notificationService.showDownloadNotification(
        id: notificationId,
        title: 'Downloading Statement',
        body: 'Preparing your wallet statement...',
      );

      final now = DateTime.now();
      final targetMonth = DateTime(month?.year ?? now.year, month?.month ?? now.month, 1);
      final pdf = pw.Document();

      // Load logo image
      final ByteData logoData = await rootBundle.load('assets/images/urban_logo.png');
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      final logoImage = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          build: (_) => [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Image(logoImage, width: 180, height: 120, fit: pw.BoxFit.contain),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Driver Statement',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Month: ${_monthLabel(targetMonth)}', style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 8),
            pw.Text('Driver: $driverId', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Earnings Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  _buildKeyValueRow('Ride Earnings', _formatAmountForPdf(state.rideEarnings)),
                  _buildKeyValueRow('Bonus', _formatAmountForPdf(state.bonus)),
                  _buildKeyValueRow('Net Pay', _formatAmountForPdf(state.monthlyEarnings)),
                  _buildKeyValueRow('Current Balance', _formatAmountForPdf(state.balance)),
                  _buildKeyValueRow('Next Payout Date', state.nextPayoutDate),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Transactions', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: const ['Date', 'Title', 'Status', 'Amount'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.black),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
              cellStyle: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
              cellDecoration: (index, data, rowNum) => pw.BoxDecoration(
                color: rowNum.isEven ? PdfColors.white : PdfColors.grey50,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.2),
                3: const pw.FlexColumnWidth(1.2),
              },
              data: state.transactions
                  .map((t) => [t.date, t.title, t.status, _formatAmountForPdf(t.amount)])
                  .toList(),
            ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final safeDriverId = _sanitizeForFileName(driverId);
      final fileName =
          'urbanride_statement_${targetMonth.year}_${targetMonth.month.toString().padLeft(2, '0')}_$safeDriverId.pdf';

      // Resolve a writable directory, preferring public Downloads when permitted
      final directory = await _resolveDownloadDirectory();
      File file = File('${directory.path}/$fileName');

      try {
        // Ensure directory exists
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        await file.writeAsBytes(bytes, flush: true);
      } on FileSystemException catch (e) {
        // Fall back to an app-only directory if the public path is blocked
        debugPrint('FileSystemException writing to \${directory.path}: $e');
        final fallbackDir = await getApplicationDocumentsDirectory();
        file = File('${fallbackDir.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
      }

      // Show completion notification with file name
      await notificationService.showDownloadCompleteNotification(
        id: notificationId,
        title: 'Download Complete',
        body: 'Statement saved: $fileName',
      );

      state = state.copyWith(isDownloadingStatement: false);
      return file.path;
    } catch (error) {
      // Cancel notification on error
      await notificationService.cancelNotification(notificationId);
      state = state.copyWith(isDownloadingStatement: false);
      rethrow;
    }
  }

  Future<Directory> _resolveDownloadDirectory() async {
    Directory? directory;

    if (Platform.isAndroid) {
      // For all Android versions, use app-specific external storage directory
      // This doesn't require runtime permissions and files are accessible by file managers
      directory = await getExternalStorageDirectory();
      
      if (directory != null) {
        // Create a Documents subfolder in app-specific storage for better organization
        final documentsDir = Directory('${directory.path}/Documents');
        if (!await documentsDir.exists()) {
          await documentsDir.create(recursive: true);
        }
        directory = documentsDir;
      }

      // Final fallback
      directory ??= await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
      directory ??= await getApplicationDocumentsDirectory();
    }

    return directory;
  }

  pw.Widget _buildKeyValueRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatAmountForPdf(double amount) {
    final formatted = amount.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return 'Rs. $formatted';
  }

  String _monthLabel(DateTime date) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[date.month - 1]} ${date.year}';
  }

  String _sanitizeForFileName(String value) {
    return value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }
}

final walletRepositoryProvider = Provider((ref) => WalletRepository());

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository);
});