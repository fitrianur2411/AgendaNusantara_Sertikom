import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() =>
      _PengaturanScreenState();
}

class _PengaturanScreenState
    extends State<PengaturanScreen> {

  
  static const _primaryColor = Color(0xFF6C63FF);
  static const _secondaryColor = Color(0xFF8E85FF);
  static const _backgroundColor = Color(0xFFF7F8FC);

  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();

  bool _isOldHidden = true;
  bool _isNewHidden = true;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  Future<void> _simpanPassword() async {
    final oldPass = _oldPassController.text.trim();
    final newPass = _newPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty) {
      _showSnackBar('Semua field harus diisi');
      return;
    }

    final berhasil =
        await DBHelper.instance.gantiPassword(
      oldPass,
      newPass,
    );

    if (!mounted) return;

    if (berhasil) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diganti'),
          backgroundColor: Colors.green,
        ),
      );

      _oldPassController.clear();
      _newPassController.clear();
    } else {
      _showSnackBar('Password saat ini salah');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
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
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    _primaryColor,
                    _secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),

              child: Row(
                children: const [
                  Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengaturan Akun',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Kelola keamanan akunmu',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Ganti Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // FORM
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                children: [

                  // PASSWORD SAAT INI + MATA
                  TextField(
                    controller: _oldPassController,
                    obscureText: _isOldHidden,
                    decoration: InputDecoration(
                      labelText: 'Password Saat Ini',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: _primaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isOldHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isOldHidden = !_isOldHidden;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 238, 218, 251),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔑 PASSWORD BARU + MATA
                  TextField(
                    controller: _newPassController,
                    obscureText: _isNewHidden,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: const Icon(
                        Icons.lock_reset,
                        color: _primaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: _primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewHidden = !_isNewHidden;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.green.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _simpanPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                      ),
                      child: const Text('SIMPAN PASSWORD'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Developer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // 👩‍💻 CARD DEVELOPER (FOTO DIUBAH)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Row(
                children: [

                  // FOTO PROFIL
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/fitria.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'Fitria Nur Sholikah',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 6),

                        Text(
                          'NIM: 2241760004',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          'JUNIOR MOBILE DEVELOPER',
                          style: TextStyle(
                            color: _primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}