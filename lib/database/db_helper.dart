import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:intl/intl.dart';
import '../models/tugas_model.dart';

class DBHelper {
  // ── Singleton ──────────────────────────────────────────────────────────────
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  Future<Database> _initDatabase() async {
    String path = 'agenda_nusantara.db';
    if (!kIsWeb) {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'agenda_nusantara.db');
    }
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambahkan kolom tanggal_diselesaikan
      await db.execute('ALTER TABLE tugas ADD COLUMN tanggal_diselesaikan TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Buat tabel users
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT
      )
    ''');

    // Buat tabel tugas
    await db.execute('''
      CREATE TABLE tugas (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        judul              TEXT,
        deskripsi          TEXT,
        tanggal_jatuh_tempo TEXT,
        tanggal_diselesaikan TEXT,
        kategori           TEXT,
        is_selesai         INTEGER DEFAULT 0
      )
    ''');

    // Seed default user
    await db.insert('users', {'username': 'user', 'password': 'user'});
  }

  // ── Step 03: Implementasi semua fungsi ────────────────────────────────────

  /// Login: cocokkan username + password di tabel users.
  /// Return Map user jika ditemukan, null jika tidak.
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Insert tugas baru ke tabel tugas.
  /// Return id baris yang baru dibuat.
  Future<int> insertTugas(Tugas tugas) async {
    final db = await database;
    return await db.insert('tugas', tugas.toMap());
  }

  /// Ambil semua tugas, urut berdasarkan tanggal_jatuh_tempo ASC.
  /// Return List<Tugas>.
  Future<List<Tugas>> getAllTugas() async {
    final db = await database;
    final rows = await db.query(
      'tugas',
      orderBy: 'tanggal_jatuh_tempo ASC',
    );
    return rows.map((row) => Tugas.fromMap(row)).toList();
  }

  /// Update kolom is_selesai untuk tugas tertentu.
  /// Return jumlah baris yang terpengaruh.
  Future<int> updateStatusSelesai(int id, int isSelesai) async {
    final db = await database;
    String? tglSelesai = isSelesai == 1 ? DateFormat('yyyy-MM-dd').format(DateTime.now()) : null;
    return await db.update(
      'tugas',
      {
        'is_selesai': isSelesai,
        'tanggal_diselesaikan': tglSelesai,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hitung statistik tugas selesai vs belum selesai.
  /// Return Map {'selesai': x, 'belum': y}.
  Future<Map<String, int>> getStatistik() async {
    final db = await database;

    final selesaiResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tugas WHERE is_selesai = 1',
    );
    final belumResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tugas WHERE is_selesai = 0',
    );

    final selesai = Sqflite.firstIntValue(selesaiResult) ?? 0;
    final belum = Sqflite.firstIntValue(belumResult) ?? 0;

    return {'selesai': selesai, 'belum': belum};
  }

  /// Ganti password user.
  /// Cek passwordLama dulu — jika cocok, update ke passwordBaru → return true.
  /// Jika tidak cocok → return false.
  Future<bool> gantiPassword(String passwordLama, String passwordBaru) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'password = ?',
      whereArgs: [passwordLama],
    );
    if (result.isEmpty) return false;

    await db.update(
      'users',
      {'password': passwordBaru},
    );
    return true;
  }

  /// Ambil statistik tugas selesai per hari (berdasarkan tanggal_diselesaikan).
  /// Mengambil data pada rentang waktu startDate hingga endDate (inklusif).
  Future<List<Map<String, dynamic>>> getTugasSelesaiRentangWaktu(String startDate, String endDate) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT tanggal_diselesaikan as tanggal, COUNT(*) as jumlah
      FROM tugas
      WHERE is_selesai = 1 
        AND tanggal_diselesaikan >= ? 
        AND tanggal_diselesaikan <= ?
      GROUP BY tanggal_diselesaikan
      ORDER BY tanggal_diselesaikan ASC
    ''', [startDate, endDate]);
    return result;
  }
}
