import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String language; // 'tr' veya 'en'

  AuthService({required this.language});

  String getErrorMessage(String errorCode) {
    final errors = {
      'email-already-in-use': {
        'tr': 'Bu e-posta adresi zaten kullanımda.',
        'en': 'This email is already in use.',
      },
      'invalid-email': {
        'tr': 'Geçersiz e-posta adresi.',
        'en': 'Invalid email address.',
      },
      'weak-password': {
        'tr': 'Parola çok zayıf. Lütfen daha güçlü bir parola seçin.',
        'en': 'Password is too weak. Please choose a stronger one.',
      },
      'user-not-found': {
        'tr': 'Kullanıcı bulunamadı.',
        'en': 'User not found.',
      },
      'wrong-password': {
        'tr': 'Yanlış parola girdiniz.',
        'en': 'Wrong password.',
      },
      'too-many-requests': {
        'tr': 'Çok fazla giriş denemesi. Lütfen sonra tekrar deneyin.',
        'en': 'Too many requests. Try again later.',
      },
      'network-request-failed': {
        'tr': 'İnternet bağlantısı hatası.',
        'en': 'Network error.',
      },
      // Şifre sıfırlama için eklenebilecek hatalar
      'invalid-action-code': { // Genellikle e-posta ile gönderilen link süresi dolduğunda veya geçersiz olduğunda
        'tr': 'Geçersiz veya süresi dolmuş kod. Lütfen tekrar deneyin.',
        'en': 'Invalid or expired action code. Please try again.',
      },
      'user-disabled': { // Kullanıcının hesabı devre dışı bırakıldığında
        'tr': 'Kullanıcı hesabı devre dışı bırakıldı.',
        'en': 'The user account has been disabled.',
      },
      'missing-email': { // Şifre sıfırlama e-postası boşsa
        'tr': 'E-posta adresi boş olamaz.',
        'en': 'Email address cannot be empty.',
      },
    };

    return errors[errorCode]?[language] ??
        (language == 'tr'
            ? 'Bir hata oluştu. Lütfen tekrar deneyin.'
            : 'An error occurred. Please try again.');
  }

  // Kayıt ol
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Hata mesajını konsola yazdırıyoruz, dilinize göre.
      print(getErrorMessage(e.code));
      // Hatanın UI'a iletilmesi için bir Exception fırlatmak daha iyi olabilir.
      // throw Exception(getErrorMessage(e.code));
      return null;
    } catch (e) {
      print(language == 'tr'
          ? 'Beklenmeyen bir hata oluştu: ${e.toString()}' // Hatanın detayını da ekledim
          : 'An unexpected error occurred: ${e.toString()}');
      // throw Exception(language == 'tr' ? 'Beklenmeyen bir hata oluştu.' : 'An unexpected error occurred.');
      return null;
    }
  }

  // Giriş yap
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result =
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(getErrorMessage(e.code));
      // throw Exception(getErrorMessage(e.code));
      return null;
    } catch (e) {
      print(language == 'tr'
          ? 'Beklenmeyen bir hata oluştu: ${e.toString()}'
          : 'An unexpected error occurred: ${e.toString()}');
      // throw Exception(language == 'tr' ? 'Beklenmeyen bir hata oluştu.' : 'An unexpected error occurred.');
      return null;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    // Burada da bir try-catch bloğu kullanmak iyi bir alışkanlıktır.
    try {
      await _auth.signOut();
    } catch (e) {
      print(language == 'tr'
          ? 'Çıkış yaparken bir hata oluştu: ${e.toString()}'
          : 'An error occurred during sign out: ${e.toString()}');
      // throw Exception(language == 'tr' ? 'Çıkış yaparken bir hata oluştu.' : 'An error occurred during sign out.');
    }
  }

  // Şifre sıfırlama e-postası gönderme
  Future<void> resetPassword({
    required String email
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email); // DÜZELTME BURADA
      print(language == 'tr'
          ? 'Şifre sıfırlama e-postası gönderildi: $email'
          : 'Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      print(getErrorMessage(e.code));
      // Hatanın UI'a iletilmesi için bir Exception fırlatmak daha iyi olabilir.
      throw Exception(getErrorMessage(e.code));
    } catch (e) {
      print(language == 'tr'
          ? 'Beklenmeyen bir hata oluştu: ${e.toString()}'
          : 'An unexpected error occurred: ${e.toString()}');
      throw Exception(language == 'tr' ? 'Beklenmeyen bir hata oluştu.' : 'An unexpected error occurred.');
    }
  }
}

