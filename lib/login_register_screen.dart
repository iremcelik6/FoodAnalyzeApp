import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth için gerekli
import 'package:analyze_foodapp/auth_service.dart'; // AuthService sınıfınızı içe aktarın
import 'package:cloud_firestore/cloud_firestore.dart';



// (İsteğe bağlı: Giriş/Kayıt sonrası geçilecek bir ana sayfa)
// import 'package:analyze_foodapp/home_screen.dart'; // Örn: Giriş sonrası gidilecek ana sayfa

class LoginRegisterScreen extends StatefulWidget {
  final String language; // 'tr' veya 'en'
  const LoginRegisterScreen({super.key, required this.language});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  /*@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Text('Buraya senin ekran içeriğin gelecek'),
    ),
  );
}*/

  bool isLogin = true; // true ise Giriş Formu, false ise Kayıt Formu gösterilir
  late String lang; // Aktif dil kodu

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form validasyonu için key

  // Metin giriş alanları için kontrolcüler
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Kayıt için Ad Soyad
  final TextEditingController _allergyController = TextEditingController(); // Kayıt için Alerjiler
  final TextEditingController _diseaseController = TextEditingController(); // Kayıt için Hastalıklar

  // AuthService örneği
  late AuthService _authService;

  // DİL DESTEKLİ METİNLER:
  final Map<String, Map<String, String>> texts = {
    'tr': {
      'login_title': 'Giriş Yap',
      'register_title': 'Kayıt Ol',
      'email': 'E-posta',
      'password': 'Şifre',
      'name': 'Ad Soyad',
      'allergies': 'Alerjiler (örn: glüten, laktoz)',
      'diseases': 'Hastalıklar (örn: çölyak, diyabet)',
      'login_button': 'Giriş Yap',
      'register_button': 'Kayıt Ol',
      'toggleToRegister': 'Hesabınız yok mu? Kayıt Olun',
      'toggleToLogin': 'Zaten hesabınız var mı? Giriş Yapın',
      'email_required': 'E-posta boş bırakılamaz.',
      'password_required': 'Şifre boş bırakılamaz.',
      'password_length_error': 'Şifre en az 6 karakter olmalı.',
      'name_required': 'Adınız boş bırakılamaz.',
      'invalid_email_format': 'Geçerli bir e-posta adresi girin.',
      'login_success': 'Giriş başarılı!',
      'register_success': 'Kayıt başarılı!',
      'login_fail': 'Giriş başarısız. Bilgilerinizi kontrol edin.',
      'register_fail': 'Kayıt başarısız.',
      'email_hint': 'E-posta adresinizi girin',
      'password_hint': 'Şifrenizi girin',
      'name_hint': 'Adınızı ve soyadınızı girin',
      'allergies_hint': 'Alerjilerinizi virgülle ayırarak girin',
      'diseases_hint': 'Hastalıklarınızı virgülle ayırarak girin',
      'forgot_password': 'Şifremi Unuttum?', // Yeni eklendi
      'reset_password_title': 'Şifre Sıfırlama', // Yeni eklendi
      'reset_email_hint': 'Sıfırlama için e-posta adresinizi girin', // Yeni eklendi
      'reset_button': 'Şifreyi Sıfırla', // Yeni eklendi
      'cancel_button': 'İptal', // Yeni eklendi
      'reset_success': 'Şifre sıfırlama e-postası gönderildi. Lütfen e-postanızı kontrol edin.', // Yeni eklendi
      'reset_fail': 'Şifre sıfırlama başarısız oldu.', // Yeni eklendi
      'email_empty_reset': 'Lütfen e-posta adresinizi girin.', // Yeni eklendi
    },
    'en': {
      'login_title': 'Login',
      'register_title': 'Register',
      'email': 'Email',
      'password': 'Password',
      'name': 'Full Name',
      'allergies': 'Allergies (e.g., gluten, lactose)',
      'diseases': 'Diseases (e.g., celiac, diabetes)',
      'login_button': 'Login',
      'register_button': 'Register',
      'toggleToRegister': 'Don\'t have an account? Register',
      'toggleToLogin': 'Already have an account? Login',
      'email_required': 'Email cannot be empty.',
      'password_required': 'Password cannot be empty.',
      'password_length_error': 'Password must be at least 6 characters.',
      'name_required': 'Name cannot be empty.',
      'invalid_email_format': 'Please enter a valid email address.',
      'login_success': 'Login successful!',
      'register_success': 'Registration successful!',
      'login_fail': 'Login failed. Check your credentials.',
      'register_fail': 'Registration failed.',
      'email_hint': 'Enter your email',
      'password_hint': 'Enter your password',
      'name_hint': 'Enter your full name',
      'allergies_hint': 'Enter your allergies separated by commas',
      'diseases_hint': 'Enter your diseases separated by commas',
      'forgot_password': 'Forgot Password?', // Yeni eklendi
      'reset_password_title': 'Reset Password', // Yeni eklendi
      'reset_email_hint': 'Enter your email for reset', // Yeni eklendi
      'reset_button': 'Reset Password', // Yeni eklendi
      'cancel_button': 'Cancel', // Yeni eklendi
      'reset_success': 'Password reset email sent. Please check your email.', // Yeni eklendi
      'reset_fail': 'Password reset failed.', // Yeni eklendi
      'email_empty_reset': 'Please enter your email address.', // Yeni eklendi
    },
  };

  @override
  void initState() {
    super.initState();
    lang = widget.language; // Başlangıç dilini WelcomeScreen'den al
    _authService = AuthService(language: lang); // AuthService'i başlat
  }

  @override
  void dispose() {
    // Tüm kontrolcüleri temizle
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _allergyController.dispose();
    _diseaseController.dispose();
    super.dispose();
  }

  // Form türünü (Giriş/Kayıt) değiştirme fonksiyonu
  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
      // Form değiştirildiğinde metin alanlarını temizle (isteğe bağlı ama iyi bir UX)
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
      _allergyController.clear();
      _diseaseController.clear();
      _formKey.currentState?.reset(); // Validasyon hatalarını da temizle
    });
  }

  // Kullanıcıya bilgi mesajı göstermek için Snackbar
  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3), // Mesaj 3 saniye ekranda kalır
      ),
    );
  }

  // Giriş yapma işlemi
  void _performLogin() async { // async eklendi
    if (_formKey.currentState!.validate()) {
      final enteredEmail = _emailController.text.trim();
      final enteredPassword = _passwordController.text.trim();

      try {
        User? user = await _authService.signInWithEmailAndPassword(enteredEmail, enteredPassword);
        if (user != null) {
          _showSnackBar(texts[lang]!['login_success']!, isSuccess: true);
          // Giriş başarılı olduktan sonra Home Screen'e yönlendirme örneği:
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        } else {
          // AuthService zaten hatayı print ediyor, burada sadece genel bir başarısızlık mesajı gösterilebilir.
          _showSnackBar(texts[lang]!['login_fail']!);
        }
      } on Exception catch (e) { // AuthService'iniz Exception fırlatıyorsa
        _showSnackBar("${texts[lang]!['login_fail']!} ${e.toString().replaceFirst('Exception: ', '')}");
      }
    }
  }

  // Kayıt olma işlemi
   void _performRegister() async { // async eklendi
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final allergies = _allergyController.text.trim();
      final diseases = _diseaseController.text.trim();

      try {
        User? user = await _authService.registerWithEmailAndPassword(email, password);
        if (user != null) {
          _showSnackBar(texts[lang]!['register_success']!, isSuccess: true);
          // Kayıt başarılı olduktan sonra otomatik olarak giriş ekranına geç
          _toggleForm();
          // Firebase'e kullanıcı kaydettikten sonra Firestore'a ek bilgiler kaydetmek isteyebilirsiniz:
           await FirebaseFirestore.instance.collection('users').doc(user.uid).set ({
            'name': name,
            'email': email,
          //   'allergies': allergies.split(',').map((s) => s.trim()).toList(),
          //   'diseases': diseases.split(',').map((s) => s.trim()).toList(),
           });
        } else {
          _showSnackBar(texts[lang]!['register_fail']!);
        }
      } on Exception catch (e) { // AuthService'iniz Exception fırlatıyorsa
        _showSnackBar("${texts[lang]!['register_fail']!} ${e.toString().replaceFirst('Exception: ', '')}");
      }
    }
  }




  // Şifre sıfırlama diyalogunu göster
  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController _resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(texts[lang]!['reset_password_title']!),
          content: TextField(
            controller: _resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(hintText: texts[lang]!['reset_email_hint']!),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(texts[lang]!['cancel_button']!),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(texts[lang]!['reset_button']!),
              onPressed: () async {
                String email = _resetEmailController.text.trim();
                if (email.isEmpty) {
                  _showSnackBar(texts[lang]!['email_empty_reset']!);
                  return;
                }

                try {
                  await _authService.resetPassword(email: email);
                  Navigator.of(context).pop(); // Diyalogu kapat
                  _showSnackBar(texts[lang]!['reset_success']!, isSuccess: true);
                } on Exception catch (e) {
                  Navigator.of(context).pop(); // Diyalogu kapat
                  _showSnackBar("${texts[lang]!['reset_fail']!} ${e.toString().replaceFirst('Exception: ', '')}");
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Ortak TextField Widget'ı için InputDecoration stili
  InputDecoration _commonInputDecoration(String labelText, String hintText) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText, // Placeholder metni
      labelStyle: const TextStyle(color: Color(0xFF9D8189)),
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9D8189), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9D8189), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3), // Ana ekran arka plan rengiyle uyumlu
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Şeffaf arka plan
        elevation: 0, // Gölge yok
        leading: IconButton( // Geri butonu
          icon: const Icon(Icons.arrow_back, color: Color(0xFF9D8189)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isLogin ? texts[lang]!['login_title']! : texts[lang]!['register_title']!,
          style: const TextStyle(
            color: Color(0xFF9D8189),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true, // Başlığı ortala
      ),
      body: Center( // Formu dikeyde ortalamak için
        child: SingleChildScrollView( // Klavye açıldığında taşmayı önler
          padding: const EdgeInsets.all(25), // Dış boşluk
          child: Form(
            key: _formKey,
            child: Column( // Ana Column
              mainAxisSize: MainAxisSize.min, // İçeriği kadar yer kapla
              children: [
                // KAYIT FORMU ALANLARI (SADECE isLogin FALSE OLDUĞUNDA GÖRÜNÜR)
                if (!isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: _commonInputDecoration(
                        texts[lang]!['name']!, texts[lang]!['name_hint']!),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return texts[lang]!['name_required']!;
                      }
                      return null;
                    },
                    style: const TextStyle(color: Color(0xFF5D4037)),
                  ),
                  const SizedBox(height: 15),
                ],

                // E-POSTA ALANI (HEM GİRİŞ HEM KAYIT İÇİN)
                TextFormField(
                  controller: _emailController,
                  decoration: _commonInputDecoration(
                      texts[lang]!['email']!, texts[lang]!['email_hint']!),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return texts[lang]!['email_required']!;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return texts[lang]!['invalid_email_format']!;
                    }
                    return null;
                  },
                  style: const TextStyle(color: Color(0xFF5D4037)),
                ),
                const SizedBox(height: 15),

                // ŞİFRE ALANI (HEM GİRİŞ HEM KAYIT İÇİN)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _commonInputDecoration(
                      texts[lang]!['password']!, texts[lang]!['password_hint']!),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return texts[lang]!['password_required']!;
                    }
                    if (value.length < 6) {
                      return texts[lang]!['password_length_error']!;
                    }
                    return null;
                  },
                  style: const TextStyle(color: Color(0xFF5D4037)),
                ),
                const SizedBox(height: 15),

                // ŞİFREMİ UNUTTUM? LİNKİ (SADECE GİRİŞ FORMUNDA)
                if (isLogin) // Sadece giriş formunda göster
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showResetPasswordDialog(context),
                      child: Text(
                        texts[lang]!['forgot_password']!,
                        style: const TextStyle(
                          color: Color(0xFF9D8189),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 15),

                // ALERJİLER ALANI (SADECE KAYIT FORMUNDA)
                if (!isLogin) ...[
                  TextFormField(
                    controller: _allergyController,
                    decoration: _commonInputDecoration(
                        texts[lang]!['allergies']!, texts[lang]!['allergies_hint']!),
                    style: const TextStyle(color: Color(0xFF5D4037)),
                  ),
                  const SizedBox(height: 15),
                ],

                // HASTALIKLAR ALANI (SADECE KAYIT FORMUNDA)
                if (!isLogin) ...[
                  TextFormField(
                    controller: _diseaseController,
                    decoration: _commonInputDecoration(
                        texts[lang]!['diseases']!, texts[lang]!['diseases_hint']!),
                    style: const TextStyle(color: Color(0xFF5D4037)),
                  ),
                  const SizedBox(height: 25), // Butondan önceki boşluk
                ],

                // GİRİŞ / KAYIT BUTONU
                SizedBox(
                  width: double.infinity, // Butonu tam genişlikte yap
                  child: ElevatedButton(
                    onPressed: isLogin ? _performLogin : _performRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9D8189), // Buton arka plan rengi
                      foregroundColor: Colors.white, // Buton metin rengi
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(isLogin ? texts[lang]!['login_button']! : texts[lang]!['register_button']!),
                  ),
                ),
                const SizedBox(height: 15), // Butonlar arası boşluk

                // FORM DEĞİŞTİRME BUTONU (Giriş <-> Kayıt)
                TextButton(
                  onPressed: _toggleForm,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF9D8189),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  child: Text(
                    isLogin
                        ? texts[lang]!['toggleToRegister']!
                        : texts[lang]!['toggleToLogin']!,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
