import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/tugas_model.dart';

class DaftarTugasScreen extends StatefulWidget {
  const DaftarTugasScreen({super.key});

  @override
  State<DaftarTugasScreen> createState() =>
      _DaftarTugasScreenState();
}

class _DaftarTugasScreenState
    extends State<DaftarTugasScreen> {

  // 🎨 Warna Modern
  static const _primaryColor = Color(0xFF6C63FF);
  static const _backgroundColor = Color(0xFFF5F7FF);

  List<Tugas> _listTugas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final data = await DBHelper.instance.getAllTugas();

    setState(() {
      _listTugas = data;
      _isLoading = false;
    });
  }

  // ✅ Toggle selesai
  Future<void> _toggleSelesai(Tugas tugas) async {
    final newValue = tugas.isSelesai == 0 ? 1 : 0;

    await DBHelper.instance.updateStatusSelesai(
      tugas.id!,
      newValue,
    );

    await _loadData();

    if (newValue == 1 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
          content: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tugas berhasil diselesaikan!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String _formatTanggal(String tanggal) {
    try {
      final dt = DateTime.parse(tanggal);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return tanggal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          'Daftar Tugas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _listTugas.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),

                  itemCount: _listTugas.length,

                  itemBuilder: (context, index) {

                    final tugas = _listTugas[index];

                    final selesai =
                        tugas.isSelesai == 1;

                    final isPenting =
                        tugas.kategori == 'Penting';

                    return AnimatedContainer(
                      duration:
                          const Duration(
                              milliseconds: 250),

                      margin:
                          const EdgeInsets.only(
                        bottom: 16,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(24),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                    0.05),

                            blurRadius: 12,

                            offset:
                                const Offset(
                                    0, 5),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding:
                            const EdgeInsets
                                .all(16),

                        child: Row(
                          children: [

                            // ✅ Checkbox
                            Transform.scale(
                              scale: 1.1,

                              child: Checkbox(
                                value: selesai,

                                activeColor:
                                    _primaryColor,

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          6),
                                ),

                                onChanged: (_) =>
                                    _toggleSelesai(
                                        tugas),
                              ),
                            ),

                            const SizedBox(
                                width: 8),

                            // 📄 Isi Tugas
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  // Badge
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          10,
                                      vertical:
                                          5,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      color: isPenting
                                          ? Colors.red
                                              .withOpacity(
                                                  0.1)
                                          : _primaryColor
                                              .withOpacity(
                                                  0.1),

                                      borderRadius:
                                          BorderRadius.circular(
                                              30),
                                    ),

                                    child: Text(
                                      tugas.kategori,

                                      style:
                                          TextStyle(
                                        color: isPenting
                                            ? Colors.red
                                            : _primaryColor,

                                        fontWeight:
                                            FontWeight
                                                .bold,

                                        fontSize:
                                            11,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          10),

                                  // Judul
                                  Text(
                                    tugas.judul,

                                    style:
                                        TextStyle(
                                      fontSize:
                                          17,

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      color: selesai
                                          ? Colors
                                              .grey
                                          : Colors
                                              .black87,

                                      decoration:
                                          selesai
                                              ? TextDecoration
                                                  .lineThrough
                                              : TextDecoration
                                                  .none,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          6),

                                  // Deskripsi
                                  if (tugas
                                      .deskripsi
                                      .isNotEmpty)
                                    Text(
                                      tugas
                                          .deskripsi,

                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,

                                      style:
                                          TextStyle(
                                        color: Colors
                                            .grey
                                            .shade600,

                                        fontSize:
                                            13,
                                      ),
                                    ),

                                  const SizedBox(
                                      height:
                                          12),

                                  // Footer
                                  Row(
                                    children: [

                                      Icon(
                                        Icons
                                            .calendar_month_rounded,

                                        size:
                                            16,

                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),

                                      const SizedBox(
                                          width:
                                              6),

                                      Text(
                                        _formatTanggal(
                                          tugas
                                              .tanggalJatuhTempo,
                                        ),

                                        style:
                                            TextStyle(
                                          color: Colors
                                              .grey
                                              .shade700,

                                          fontSize:
                                              12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                                width: 12),

                            // ✅ Status Icon
                            AnimatedContainer(
                              duration:
                                  const Duration(
                                      milliseconds:
                                          300),

                              padding:
                                  const EdgeInsets
                                      .all(12),

                              decoration:
                                  BoxDecoration(
                                color: selesai
                                    ? Colors.green
                                        .withOpacity(
                                            0.12)
                                    : isPenting
                                        ? Colors.red
                                            .withOpacity(
                                                0.12)
                                        : _primaryColor
                                            .withOpacity(
                                                0.12),

                                shape:
                                    BoxShape.circle,
                              ),

                              child: Icon(
                                selesai
                                    ? Icons
                                        .check_circle
                                    : Icons
                                        .schedule_rounded,

                                color: selesai
                                    ? Colors.green
                                    : isPenting
                                        ? Colors.red
                                        : _primaryColor,

                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  // 📭 Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              padding: const EdgeInsets.all(28),

              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.task_alt_rounded,
                size: 70,
                color: _primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Belum Ada Tugas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Yuk mulai tambahkan tugas\nagar aktivitasmu lebih teratur',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}