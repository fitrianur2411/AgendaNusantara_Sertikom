import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../database/db_helper.dart';

import 'tambah_penting_screen.dart';
import 'tambah_biasa_screen.dart';
import 'daftar_tugas_screen.dart';
import 'pengaturan_screen.dart';
import 'login_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {

  // 🎨 UNGU PASTEL SOFT
  static const _primaryColor = Color(0xFFB9A7FF);
  static const _backgroundColor = Color(0xFFF7F5FF);

  Future<Map<String, int>>? _statistikFuture;
  Future<List<Map<String, dynamic>>>? _chartDataFuture;

  DateTime _selectedWeekDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  void _refreshData() {
    setState(() {
      _statistikFuture = DBHelper.instance.getStatistik();

      final startOfWeek = _getStartOfWeek(_selectedWeekDate);
      final endOfWeek = _getEndOfWeek(_selectedWeekDate);

      _chartDataFuture = DBHelper.instance.getTugasSelesaiRentangWaktu(
        DateFormat('yyyy-MM-dd').format(startOfWeek),
        DateFormat('yyyy-MM-dd').format(endOfWeek),
      );
    });
  }

  String _todayLabel() {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID')
        .format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          'Agenda Nusantara',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8E7CFF),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text("Konfirmasi Logout"),
                    content: const Text(
                      "Apakah kamu yakin ingin keluar dari aplikasi?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Halo, Fitria 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _todayLabel(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              /// 📊 STATISTIK
              FutureBuilder<Map<String, int>>(
                future: _statistikFuture,
                builder: (context, snapshot) {
                  final selesai = snapshot.data?['selesai'] ?? 0;
                  final belum = snapshot.data?['belum'] ?? 0;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Tugas Selesai',
                          value: selesai.toString(),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Tugas Belum',
                          value: belum.toString(),
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              /// 📈 CHART (VERSI LAMA DIPAKAI LAGI)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tugas Selesai / Hari [Bonus]',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            color: _primaryColor,
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedWeekDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() {
                                _selectedWeekDate = picked;
                                _refreshData();
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 180,

                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _chartDataFuture,
                        builder: (context, snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final data = snapshot.data ?? [];

                          final labels = [
                            'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
                          ];

                          final startOfWeek = _getStartOfWeek(_selectedWeekDate);

                          final barGroups = <BarChartGroupData>[];
                          double maxY = 5;

                          for (int i = 0; i < 7; i++) {
                            final currentDay = startOfWeek.add(Duration(days: i));
                            final currentDayStr =
                                DateFormat('yyyy-MM-dd').format(currentDay);

                            final itemIndex = data.indexWhere(
                              (e) => e['tanggal'] == currentDayStr,
                            );

                            final jumlah =
                                itemIndex != -1 ? data[itemIndex]['jumlah'] : 0;

                            if (jumlah > maxY) {
                              maxY = jumlah.toDouble();
                            }

                            barGroups.add(
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: jumlah.toDouble(),
                                    width: 18,
                                    color: _primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              ),
                            );
                          }

                          return BarChart(
                            BarChartData(
                              maxY: maxY + 1,
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),

                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: true),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(labels[value.toInt()]);
                                    },
                                  ),
                                ),
                              ),

                              barGroups: barGroups,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Menu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.25,

                children: [

                  _buildMenu(
                    icon: Icons.add_task,
                    title: 'Tambah Tugas Penting',
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TambahPentingScreen(),
                        ),
                      ).then((_) => _refreshData());
                    },
                  ),

                  _buildMenu(
                    icon: Icons.add_task,
                    title: 'Tambah Tugas Biasa',
                    color: _primaryColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TambahBiasaScreen(),
                        ),
                      ).then((_) => _refreshData());
                    },
                  ),

                  _buildMenu(
                    icon: Icons.list_alt,
                    title: 'Daftar Tugas',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DaftarTugasScreen(),
                        ),
                      );
                    },
                  ),

                  _buildMenu(
                    icon: Icons.settings,
                    title: 'Pengaturan',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PengaturanScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}