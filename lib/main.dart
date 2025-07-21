import 'package:flutter/material.dart';
import 'package:analyze_foodapp/login_register_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:analyze_foodapp/home_screen.dart'; // HomeScreen için eklendi
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:analyze_foodapp/auth_service.dart';


void main() async  {
 WidgetsFlutterBinding.ensureInitialized();

WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);


// Bu satır firebase_options.dart dosyasını kullanır
  
  runApp(const MyApp());
}

// *** MyApp SINIFI BURADA BAŞLIYOR ***
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gıda Asistanı',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF0F3), // Arka plan rengi
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9D8189), // Buton rengi
            foregroundColor: Colors.white, // Buton metin rengi
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Buton köşe yuvarlaklığı
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(), // Uygulamanın başlangıç ekranı
      debugShowCheckedModeBanner: false, // Debug bandını kapat
    );
  }
}
// *** MyApp SINIFI BURADA BİTİYOR ***


// *** WelcomeScreen SINIFI BURADA BAŞLIYOR ***
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
State<WelcomeScreen> createState() => _WelcomeScreenState();
}  
// *** WelcomeScreen SINIFI BURADA BİTİYOR ***


// _WelcomeScreenState sınıfı
class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = 'tr'; // Seçili dil

  // İkonlar ve animasyon için boyutlandırma sabitleri
  final double iconGap = 30; // İkonlar arası yatay boşluk
  final double iconTopStart = 50.0; // İlk satırın ekranın üstünden başlangıç boşluğu
  final double commonIconHeight = 50.0; // Tüm ikonlar için sabit yükseklik

  // Her ikonun özel genişliği (şu an hepsi 50)
  final double breadWidth = 50;
  final double pastaWidth = 50;
  final double salamiWidth = 50;
  final double energyDrinkWidth = 50;
  final double chocolateWidth = 50;
  final double chipsWidth = 50;
  final double milkWidth = 50;
  final double snackWidth = 50;
  final double flourWidth = 50;
  final double iceCreamWidth = 50;

  late final AnimationController _controller; // Animasyon kontrolcüsü
  late final Animation<double> _animation; // Animasyon değeri

  // Çoklu dil için metinler
  final Map<String, Map<String, String>> texts = {
    'tr': {
      'continue': 'Devam Et',
      'hello': 'Merhaba',
    },
    'en': {
      'continue': 'Continue',
      'hello': 'Hello',
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Animasyon süresi (15 saniye)
    )..repeat(); // Animasyonu tekrar et

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Animasyon kontrolcüsünü temizle
    super.dispose();
  }

  // Bir sonraki ekrana geçiş fonksiyonu
   void goToNextScreen() {
    // Kullanıcının oturum durumunu kontrol et
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı zaten giriş yapmışsa Ana Ekrana yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(language: selectedLanguage),
        ),
      );
    } else {
      // Kullanıcı giriş yapmamışsa Giriş/Kayıt Ekranına yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginRegisterScreen(language: selectedLanguage),
        ),
      );
    }
  }
  /*void goToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginRegisterScreen(language: selectedLanguage),
      ),
    );
  }*/

  // Yardımcı Metot: İkon grubunu bir Row olarak oluşturmak için
  Widget _buildIconGroup() {
    return Row(
      mainAxisSize: MainAxisSize.min, // İçeriği kadar yer kaplar
      children: [
        Image.asset('assets/bread.png', width: breadWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/pasta.png', width: pastaWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/salami.png', width: salamiWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/energy-drink.png', width: energyDrinkWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/chocolate.png', width: chocolateWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/chips.png', width: chipsWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/milk.png', width: milkWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/snack.png', width: snackWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/flour.png', width: flourWidth, height: commonIconHeight, fit: BoxFit.contain),
        SizedBox(width: iconGap),
        Image.asset('assets/ice-cream.png', width: iceCreamWidth, height: commonIconHeight, fit: BoxFit.contain),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tüm ikon grubunun toplam yatay genişliği
    final double singleGroupWidth = breadWidth + pastaWidth + salamiWidth + energyDrinkWidth + chocolateWidth + chipsWidth + milkWidth + snackWidth + flourWidth + iceCreamWidth + (iconGap * 9);

    final screenHeight = MediaQuery.of(context).size.height; // Ekran yüksekliğini al

    List<Widget> animatedIconRows = []; // Animasyonlu ikon satırlarını tutacak liste

    // Her satırın toplam dikey yüksekliği (ikon yüksekliği + boşluk)
    final double rowHeight = commonIconHeight + iconGap + 10;

    // Ekranı dolduracak kadar ikon satırı oluşturma döngüsü
    for (double currentTop = iconTopStart; currentTop < screenHeight; currentTop += rowHeight) {
      animatedIconRows.add(
        Positioned( // Her satır için dikey konumlandırma
          top: currentTop,
          // İçerik genişliğini ve yüksekliğini belirlemek için SizedBox kullanıldı
          child: SizedBox(
            width: singleGroupWidth * 2, // İki ikon grubunu yan yana alacak kadar geniş
            height: commonIconHeight, // İkonların yüksekliği kadar
            child: AnimatedBuilder( // Her satır kendi yatay animasyonunu yönetecek
              animation: _animation,
              builder: (context, child) {
                // Animasyon değerine göre mevcut yatay ofseti hesapla
                double currentOffset = singleGroupWidth * _animation.value;

                return Stack( // İki ikon grubunu bu Stack içinde konumlandır
                  clipBehavior: Clip.none, // İçeriklerin kutu dışına taşmasına izin ver
                  children: [
                    Positioned(
                      left: -currentOffset, // İlk ikon grubu, animasyonla sola kayar
                      child: _buildIconGroup(), // Yardımcı metot Row döndürür
                    ),
                    Positioned(
                      left: -currentOffset + singleGroupWidth, // İkinci ikon grubu, ilkinin bitişinden başlar
                      child: _buildIconGroup(), // Yardımcı metot Row döndürür
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Arka plan ikonları (oluşturulan tüm satırlar buraya yayılır)
          ...animatedIconRows,

          // Dil seçimi ve buton kısmı (ikonların üzerinde görünecek)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Sütunun içeriği kadar yer kaplaması
              children: [
                const SizedBox(height: 100), // Üstten boşluk
                Text(
                  texts[selectedLanguage]!['hello']!,
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037), // Metin rengi: Koyu Kahverengi
                  ),
                ),
                const SizedBox(height: 50), // Metin ile Dropdown arası boşluk
                DropdownButton<String>(
                  value: selectedLanguage,
                  items: const [
                    DropdownMenuItem(value: 'tr', child: Text('Türkçe 🇹🇷')),
                    DropdownMenuItem(value: 'en', child: Text('English 🇬🇧')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
                const SizedBox(height: 60), // Dropdown ile buton arası boşluk
                ElevatedButton(
                  onPressed: goToNextScreen,
                  child: Text(texts[selectedLanguage]!['continue']!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}