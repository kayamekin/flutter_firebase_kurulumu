import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthIslemleri extends StatefulWidget {
  const FirebaseAuthIslemleri({super.key});

  @override
  State<FirebaseAuthIslemleri> createState() => _FirebaseAuthIslemleriState();
}

class _FirebaseAuthIslemleriState extends State<FirebaseAuthIslemleri> {
  late FirebaseAuth auth;

  final String _email = "baturalpmekin@gmail.com";
  final String _pass = "user1234";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    auth = FirebaseAuth.instance;

    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint("user oturumu kapalı");
      } else {
        debugPrint(
            "user oturumu açık ${user.email} ve email durumu ${user.emailVerified}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("firebase auth işlemleri"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                createUserEmailAndPass();
              },
              child: Text("Email ve Şifre ile Kayıt Ol"),
            ),
            ElevatedButton(
              onPressed: () {
                loginUserEmailAndPass();
              },
              child: Text("Email ve Şifre ile Giriş Yap"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                signOutUser();
              },
              child: Text("Çıkış Yap"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                deleteUser();
              },
              child: Text("Hesabımı Sil"),
            ),
          ],
        ),
      ),
    );
  }

  void createUserEmailAndPass() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: _email, password: _pass);
      debugPrint(_userCredential.toString());

// kullanıcı dinleme işlemi
// eğer kayıt olduysa mail adresine doğrulama gönderilmekte.
      var _myUser = _userCredential.user;
      if (!_myUser!.emailVerified) {
        await _myUser.sendEmailVerification();
      } else {
        debugPrint(
            "kullanıcının maili onaylanmış, ilgili sayfaya yönlendiriliyor.");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loginUserEmailAndPass() async {
    try {
      var _userCredential =
          await auth.signInWithEmailAndPassword(email: _email, password: _pass);
      debugPrint(_userCredential.toString());
      debugPrint("giriş yapıldı");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void signOutUser() async {
    try {
      await auth.signOut();
      debugPrint("Çıkış Yapıldı");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void deleteUser() async {
    try {
      if (auth.currentUser != null) {
        await auth.currentUser!.delete();
      } else {
        debugPrint("önce oturum açın");
      }
    } catch (e) {
      debugPrint(e.toString());
      debugPrint("hesap silinemedi");
    }
  }
}
