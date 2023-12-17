import 'package:ctrlfirl/models/user_model.dart';
import 'package:ctrlfirl/services/firebase_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class AuthController extends ChangeNotifier {
  FirebaseHelper firebaseHelper = FirebaseHelper();

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool _isImageUploading = false;
  bool get isImageUploading => _isImageUploading;
  void setImageUploading(bool value) {
    _isImageUploading = value;
    notifyListeners();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This data is firebase from firebase auth
  User? _user;
  User? get user => _user;
  void setUser(User? user) {
    _user = user;
    debugPrint('setUser: $user');
    notifyListeners();
  }

  // This data is from firestore document
  UserModel? _userData = UserModel();
  UserModel? get userData => _userData;
  void setUserData(UserModel? userData) {
    _userData = userData;
    notifyListeners();
  }

  String? verificationId;

  Future<void> signUp(String phoneNumber) async {
    setLoading(true);
    try {
      debugPrint('Sending OTP to $phoneNumber');
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },
        codeSent: (String thisVerificationId, int? resendToken) async {
          debugPrint('VerificationID: $thisVerificationId');
          verificationId = thisVerificationId;
        },
        timeout: const Duration(seconds: 60),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    setLoading(false);
  }

  Future<bool> verifyOtp(String otp) async {
    setLoading(true);
    try {
      debugPrint('Verifying OTP $otp');
      var credential = await _auth.signInWithCredential(
          PhoneAuthProvider.credential(
              verificationId: verificationId!, smsCode: otp));
      setLoading(false);
      if (credential.user != null) {
        setUser(credential.user);
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setLoading(false);
    return false;
  }

  // check if user exists
  Future<bool> doesUserDocumentExist() async {
    bool isDocumentExists = await firebaseHelper.doesUserDocumentExist();
    if (isDocumentExists) {
      getUserDocumentStream();
    }
    return isDocumentExists;
  }

  // This actively listens to changes in user document in firestore unlike getUserDataFromFirestore
  void getUserDocumentStream() async {
    setLoading(true);
    debugPrint('AuthController:getUserDocumentStream called');
    firebaseHelper.getUserDocumentStream().onData((data) {
      if (data.exists) {
        UserModel userStreamData =
            UserModel.fromJson(data.data() as Map<String, dynamic>);
        setUserData(userStreamData);
        setLoading(false);
      }
    });
  }

  // close stream
  void closeUserDocumentStream() {
    firebaseHelper.closeUserDocumentStream();
  }

  Future<bool> createUserDocument(UserModel userData) async {
    debugPrint('Adding user to firestore');

    setLoading(true);
    String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      userData.uid = uid;
      userData.phoneNumber = FirebaseAuth.instance.currentUser!.phoneNumber;
      if (userData.profileImageFile != null) {
        String downloadURl = await firebaseHelper.uploadProfilePicture(
            userData.profileImageFile!, uid);
        userData.profilePicture = downloadURl;
      }

      await firebaseHelper.createUserDocument(userData).then((value) async {
        debugPrint('User added to firestore');
      });
      setLoading(false);
      return true;
    } catch (e) {
      debugPrint(e.toString());
    }
    setLoading(false);

    return false;
  }

  Future<void> signOut() async {
    setLoading(true);

    debugPrint('AuthController:signOut: Signing out user');
    try {
      closeUserDocumentStream();
      setLoading(true);
      await firebaseHelper.logout();
      setUser(null);
      setUserData(null);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  bool isLoggedIn() {
    // TODO: this is triggered on every hot reload, find a better way to check if user is logged in
    // debugPrint('isLoggedIn: ${_auth.currentUser != null}');
    // debugPrint('currentUser: ${_auth.currentUser}');
    return _auth.currentUser != null;
  }

  Future updateRecord(UserModel user) async {
    debugPrint('updateRecord: ${user.toString()}');
    await firebaseHelper.updateUserRecord(user);
  }

  void changeProfilePicture(XFile profilePicture) async {
    setImageUploading(true);
    debugPrint('changeProfilePicture');
    String downloadURl = await firebaseHelper.uploadProfilePicture(
        profilePicture, FirebaseAuth.instance.currentUser!.uid);

    _userData!.profilePicture = downloadURl;

    updateRecord(_userData!).then((value) {
      setImageUploading(false);
    });
  }
}
