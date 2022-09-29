import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthIslemleri extends StatefulWidget {
  const FirebaseAuthIslemleri({super.key});

  @override
  State<FirebaseAuthIslemleri> createState() => _FirebaseAuthIslemleriState();
}

class _FirebaseAuthIslemleriState extends State<FirebaseAuthIslemleri> {
  late FirebaseAuth auth;

  final String _email = "mekin@mekin.com";
  final String _pass = "password";

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
            Divider(
              indent: MediaQuery.of(context).size.width / 3,
              endIndent: MediaQuery.of(context).size.width / 3,
              thickness: 5,
              color: Colors.black54,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: () {
                changePass();
              },
              child: Text("Şifreyi güncelle"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.shade400,
              ),
              onPressed: () {
                changeEmail();
              },
              child: Text("Email güncelle"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade400,
              ),
              onPressed: () {
                googleLogin();
              },
              child: Text("Google ile giriş yap"),
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
      // google ile çıkış yapma işlemi
      var _user = await GoogleSignIn().currentUser;
      if (_user != null) {
        await GoogleSignIn().signOut();
        debugPrint("google ile çıkış yapıldı");
      }
      // ------------------------------
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

  void changePass() async {
    try {
      await auth.currentUser!.updatePassword('password');
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'require-recent-login') {
        debugPrint("reauthenticate olunacak");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _pass);
        await auth.currentUser?.reauthenticateWithCredential(credential);

        await auth.currentUser!.updatePassword('password');
        await auth.signOut();
        debugPrint("Şifre güncellendi");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void changeEmail() async {
    try {
      await auth.currentUser!.updateEmail('mekin@mekin.com');
      await auth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'require-recent-login') {
        debugPrint("reauthenticate olunacak");
        var credential =
            EmailAuthProvider.credential(email: _email, password: _pass);
        await auth.currentUser?.reauthenticateWithCredential(credential);

        await auth.currentUser!.updateEmail('mekin@mekin.com');
        await auth.signOut();
        debugPrint("Email güncellendi");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<UserCredential> googleLogin() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
