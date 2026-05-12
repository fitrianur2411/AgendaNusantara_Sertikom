/// Model class untuk satu baris di tabel `tugas`.
class Tugas {
  final int? id;          // nullable — diisi otomatis oleh SQLite
  final String judul;
  final String deskripsi;
  final String tanggalJatuhTempo; // format: YYYY-MM-DD
  final String kategori;          // "Penting" atau "Biasa"
  final int isSelesai;            // 0 = belum, 1 = selesai
  final String? tanggalDiselesaikan; // Format: YYYY-MM-DD

  Tugas({
    this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggalJatuhTempo,
    required this.kategori,
    this.isSelesai = 0,
    this.tanggalDiselesaikan,
  });

  /// Buat objek Tugas dari Map (baris SQLite → objek Dart).
  factory Tugas.fromMap(Map<String, dynamic> map) {
    return Tugas(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      deskripsi: map['deskripsi'] as String,
      tanggalJatuhTempo: map['tanggal_jatuh_tempo'] as String,
      kategori: map['kategori'] as String,
      isSelesai: map['is_selesai'] as int,
      tanggalDiselesaikan: map['tanggal_diselesaikan'] as String?,
    );
  }

  /// Ubah objek Tugas menjadi Map (untuk insert/update ke SQLite).
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'judul': judul,
      'deskripsi': deskripsi,
      'tanggal_jatuh_tempo': tanggalJatuhTempo,
      'kategori': kategori,
      'is_selesai': isSelesai,
      'tanggal_diselesaikan': tanggalDiselesaikan,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
