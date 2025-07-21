import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Kullanıcı bilgilerini almak için
import 'package:analyze_foodapp/auth_service.dart'; // Çıkış yapmak için AuthService
import 'package:analyze_foodapp/login_register_screen.dart'; // LoginRegisterScreen'i içe aktarın

// Bu, giriş yapıldıktan sonra kullanıcının yönlendirileceği ana ekrandır.
class HomeScreen extends StatelessWidget {
  final String language; // Dil bilgisini alabiliriz
  const HomeScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    // Mevcut oturum açmış kullanıcıyı al
    final User? user = FirebaseAuth.instance.currentUser;

    // Dil metinleri (basit bir örnek, daha kapsamlı bir yapı kullanabilirsiniz)
    final Map<String, String> homeTexts = language == 'tr'
        ? {
            'welcome_title': 'Hoş Geldiniz!',
            'logged_in_as': 'Giriş Yaptınız:',
            'user_id': 'Kullanıcı ID:',
            'sign_out': 'Çıkış Yap',
            'no_user': 'Kullanıcı bulunamadı.',
            'sign_out_success': 'Başarıyla çıkış yapıldı.',
            'sign_out_fail': 'Çıkış yaparken bir hata oluştu.',
          }
        : {
            'welcome_title': 'Welcome!',
            'logged_in_as': 'Logged in as:',
            'user_id': 'User ID:',
            'sign_out': 'Sign Out',
            'no_user': 'No user found.',
            'sign_out_success': 'Successfully signed out.',
            'sign_out_fail': 'An error occurred during sign out.',
          };

    return Scaffold(
      appBar: AppBar(
        title: Text(homeTexts['welcome_title']!),
        backgroundColor: const Color(0xFF9D8189),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: homeTexts['sign_out']!,
            onPressed: () async {
              // AuthService üzerinden çıkış yap
              try {
                await AuthService(language: language).signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(homeTexts['sign_out_success']!)),
                );
                // Çıkış yaptıktan sonra Login/Register ekranına geri dön
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginRegisterScreen(language: language)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${homeTexts['sign_out_fail']!} ${e.toString()}")),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                homeTexts['logged_in_as']!,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (user != null) // Kullanıcı varsa bilgilerini göster
                Column(
                  children: [
                    Text(
                      'E-posta: ${user.email ?? homeTexts['no_user']}',
                      style: const TextStyle(fontSize: 18, color: Color(0xFF9D8189)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${homeTexts['user_id']!} ${user.uid}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              else // Kullanıcı yoksa mesaj göster
                Text(
                  homeTexts['no_user']!,
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 30),
              // Buraya ana ekranınızın diğer içeriklerini ekleyebilirsiniz
              // Örneğin:
              // ElevatedButton(
              //   onPressed: () {
              //     // Yeni bir özellik sayfasına git
              //   },
              //   child: Text('Profilimi Görüntüle'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
