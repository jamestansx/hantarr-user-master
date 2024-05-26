import 'dart:convert';
import 'dart:io';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hantarr/bloc/hantarrEvent.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/root_page_repo/modules/topUp_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:hantarr/utilities/api_helper.dart';
import 'package:hantarr/utilities/get_exception_log.dart';
import 'package:hantarr/utilities/get_exception_msg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';

import 'dart:async';


abstract class HantarrUserInterface {
  // utils
  factory HantarrUserInterface() => HantarrUser.initClass();
  Future<Map<String, dynamic>> getUserData();
  Future<Map<String, dynamic>> updateProfileData(String name, String phone);
  Future<Map<String, dynamic>> getCurrentLocation();
  Future<Map<String, dynamic>> getCurrentTime();
  // authentications
  Future<Map<String, dynamic>> googleSignIn();
  Future<Map<String, dynamic>> facebookSignIn(AuthCredential credential);
  Future<Map<String, dynamic>> emailSignIn(String email, String password);
  Future<Map<String, dynamic>> appleSignin();
  Future<Map<String, dynamic>> phoneSignIn();
  // registration
  Future<Map<String, dynamic>> emailRegister(String email, password);

  // local
  HantarrUser fromMap(Map<String, dynamic> map);
  void mapToLocal(HantarrUser hantarrUser);

  // utils
  Future<Map<String, dynamic>> getTopUpHistory();
  Future<void> signOut();
  Future<Map<String, dynamic>> getLocalStrorageLocation();
  Future<Map<String, dynamic>> setLocalStrorageLocation(Address address);
  Future<void> setLocalOnSelectedAddress(LatLng latLng, String address);
  Future<Map<String, dynamic>> setLocation(BuildContext context);

  Future<Map<String, dynamic>> canLoginWithPhone(String phone);

  // -- provider data check  --
  // EmailAuthProviderID: password
  // PhoneAuthProviderID: phone
  // GoogleAuthProviderID: google.com
  // FacebookAuthProviderID: facebook.com
  // TwitterAuthProviderID: twitter.com
  // GitHubAuthProviderID: github.com
  // AppleAuthProviderID: apple.com
  // YahooAuthProviderID: yahoo.com
  // MicrosoftAuthProviderID: hotmail.com
  bool isBindToFacebook();
  bool isBindToGoogle();
  bool isBindtoPhone();
  bool isBindToApple();

  bool canUnbindAcc();

  List<Map<String, dynamic>> providersWidgets(BuildContext context);

  Future<Map<String, dynamic>> bindAccontFunction(
      BuildContext context, AuthCredential credential);

  //unbind
  Future<String> confirmationUnbind(BuildContext context, String title);

  // APIs
  Future<Map<String, dynamic>> uploadBankSlip(FormData formData);
  Future<Map<String, dynamic>> logVersion(String version);
}

class HantarrUser implements HantarrUserInterface {
  int? id;
  late double creditBalance;
  double? longitude, latitude;
  User? firebaseUser;
  double? long, lat;
  String? selectedAddress;
  

  HantarrUser({
    required this.id,
    required this.creditBalance,
    required this.longitude,
    required this.latitude,
    required this.firebaseUser,
  });

  HantarrUser.initClass() {
    this.id = null;
    this.creditBalance = 0.0;
    this.longitude = null;
    this.longitude = null;
    this.firebaseUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  void mapToLocal(HantarrUser hantarrUser) {
    this.id = hantarrUser.id;
    this.creditBalance = hantarrUser.creditBalance;
    this.longitude = hantarrUser.longitude;
    this.latitude = hantarrUser.latitude;
    this.firebaseUser = hantarrUser.firebaseUser;
  }

// @override
// HantarrUser? fromMap(Map<String, dynamic> map) {
//   HantarrUser? hantarrUser;
//   try {
//     hantarrUser = HantarrUser(
//       id: map['id'] as int?,
//       creditBalance: (map['total'] != null
//           ? num.tryParse(map['total'].toString())?.toDouble()
//           : 0.0) ?? 0.0,
//       // longitude: map['long'] != null
//       //     ? num.tryParse(map['long'].toString()).toDouble()
//       //     : null,
//       // latitude: map['lat'] != null
//       //     ? num.tryParse(map['lat'].toString()).toDouble()
//       //     : null,
//       longitude: this.longitude,
//       latitude: this.latitude,
//       firebaseUser: this.firebaseUser,
//     );
//   } catch (e) {
//     String msg = getExceptionMsg(e);
//     debugPrint("hUser from map hit error. $msg");
//     Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
//     JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//     String jsonString = encoder.convert(getExceptionLogReq);
//     FirebaseCrashlytics.instance
//         .recordError(getExceptionLogReq, StackTrace.current);
//     FirebaseCrashlytics.instance.log(jsonString);
//     hantarrUser = null;
//   }
//   return hantarrUser;
// }

  @override
  HantarrUser fromMap(Map<String, dynamic> map) {
    try {
      return HantarrUser(
        id: map['id'] as int?,
        creditBalance: (map['total'] != null
            ? num.tryParse(map['total'].toString())?.toDouble()
            : 0.0) ?? 0.0,
        longitude: map['long'] != null
            ? num.tryParse(map['long'].toString())?.toDouble()
            : null,
        latitude: map['lat'] != null
            ? num.tryParse(map['lat'].toString())?.toDouble()
            : null,
        firebaseUser: FirebaseAuth.instance.currentUser,
      );
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("HantarrUser fromMap error: $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      throw Exception("Error creating HantarrUser from map");
    }
  }



  @override
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      var location = new Location();
      PermissionStatus _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        location.requestPermission();
      }
      LocationData currentLocation;
      bool enabled = await location.serviceEnabled();
      if (!enabled) {
        Future.delayed(Duration(seconds: 5)).then((value) async {
          enabled = await location.serviceEnabled();
        });
        await location.requestService();
      }
      currentLocation = await location.getLocation();
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        this.latitude = currentLocation.latitude;
        this.longitude = currentLocation.longitude;
      }
      return {"success": true, "data": this};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get location failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> getUserData() async {
    if (this.firebaseUser == null) {
      return {"success": false, "reason": "Please login first"};
    }
    try {
      Dio fDio = getDio(baseOption: 1, queries: {
        "fields": "migrate_patron",
        "email": "${this.firebaseUser!.email}",
        "user_id": "${this.firebaseUser!.uid}",
      });
      Response fresponse = await fDio.get("/sales");
      debugPrint("${fresponse.requestOptions.queryParameters}");
      debugPrint(fresponse.data.toString());
      String phoneNum = firebaseUser!.phoneNumber ?? "";
      
      if (this.firebaseUser!.phoneNumber != null) {
        phoneNum = this.firebaseUser!.phoneNumber!;
      }
      // if (fresponse.data is String) {
      String? fcmToken = "-";
      try {
        fcmToken = await hantarrBloc.state.fcm.getToken();
      } catch (g) {
        FirebaseCrashlytics.instance.recordError(g, StackTrace.current);
        FirebaseCrashlytics.instance
            .log("${this.firebaseUser!.email} get fcm token failed");
      }
      Dio gDio = getDio(baseOption: 1, queries: {
        "fields": "register_patron",
        "email": "${this.firebaseUser!.email}",
        "user_id": "${this.firebaseUser!.uid}",
        "name": "${this.firebaseUser!?.displayName}",
        "phone": phoneNum.isNotEmpty ? "$phoneNum" : "-",
        "fcm_token": fcmToken,
      });

      Response gresponse = await gDio.post("/sales");
      debugPrint("${gresponse.requestOptions.queryParameters}");
      debugPrint(gresponse.data.toString());
      // }

      Dio dio = getDio(baseOption: 1, queries: {});
      Response response = await dio.get("/credit/${this.firebaseUser!.uid}");
      debugPrint("${response.requestOptions.queryParameters}");
      if (response.data != "") {
        HantarrUser hantarrUser =
            HantarrUser.initClass().fromMap(response.data);
        // ignore: unnecessary_null_comparison
        if (hantarrUser != null) {
          this.mapToLocal(hantarrUser);
          return {"success": true, "data": this};
        } else {
          throw ("HUser frommap hit error.");
        }
      } else {
        throw ("get API failed");
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get User failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfileData(
      String name, String phone) async {
    try {
      Dio dio =
          getDio(baseOption: 1, queries: {"scope": "update_hantarr_patron"});
      Response response = await dio.post(
        "/sales",
        data: {
          "user_id": this.firebaseUser!.uid,
          "phone": "${phone.toString()}",
          "name": "${name.toString()}",
          "selected_address": "",
          "long": null,
          "lat": null,
        },
      );
      print("${response.data}");
      try {
        await this.firebaseUser!.reload();
        this.firebaseUser = FirebaseAuth.instance.currentUser;
        hantarrBloc.add(Refresh());
      } catch (d) {}
      return {"success": true, "data": this};
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Update profile failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn _gSignIn = new GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await _gSignIn.signIn();

      if (googleSignInAccount == null) {
        return {"sucess": false, "reason": "Google sign-in aborted."};
      }

      final GoogleSignInAuthentication authentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      final UserCredential authResult =
          await _firebaseAuth.signInWithCredential(credential);
      this.firebaseUser = authResult.user;
      if (this.firebaseUser != null) {
        return {"success": true, "data": this};
      } else {
        return {"success": false, "reason": "Login failed."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Login failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> appleSignin() async {
    try {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (result.status != AuthorizationStatus.authorized) {
      return {"success": false, "reason": "Apple sign-in failed."};
      }        

      // if (result.status == AuthorizationStatus.authorized) {
      print("successfull sign in");
      final AppleIdCredential appleIdCredential = result.credential;

      OAuthProvider oAuthProvider = new OAuthProvider("apple.com");
      final AuthCredential credential = oAuthProvider.credential(
        idToken: String.fromCharCodes(appleIdCredential.identityToken),
        accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? info = FirebaseAuth.instance.currentUser;
      String familyName = appleIdCredential.fullName?.familyName ?? "";
      String givenName = appleIdCredential.fullName?.givenName ?? "";
     
      //todo: this may not needed
      try {
        if (result.credential.fullName.familyName != null &&
            result.credential.fullName.familyName != "") {
          familyName = result.credential.fullName.familyName;
        }
        if (result.credential.fullName.givenName != null &&
            result.credential.fullName.givenName != "") {
          givenName = result.credential.fullName.givenName;
        }
      } catch (e) {}
      //todo:

      if (familyName.isNotEmpty && givenName.isNotEmpty) {
        // ignore: deprecated_member_use
        await info?.updateProfile(displayName: "$givenName $familyName");
      }

      //this.firebaseUser = user.user;
      this.firebaseUser = userCredential.user;
      
      if (this.firebaseUser != null) {
        return {"success": true, "data": this};
      } else {
        return {"success": false, "reason": "Login failed."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Login failed. $msg"};
    }
  }

//  @override
//  Future<Map<String, dynamic>> phoneSignIn() async {
//    try {
//    //  final UserCredential user =
//    //           await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
//
//    } catch (e) {
//      String msg = getExceptionMsg(e);
//      debugPrint("phoneSignIn hit error. $msg");
//      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
//      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//      String jsonString = encoder.convert(getExceptionLogReq);
//      FirebaseCrashlytics.instance
//          .recordError(getExceptionLogReq, StackTrace.current);
//      FirebaseCrashlytics.instance.log(jsonString);
//      return {"success": false, "reason": "Sign failed."};
//    }
//  }
//


Future<Map<String, dynamic>> phoneSignIn(BuildContext context, String phoneNumber) async {
  try {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final Completer<Map<String, dynamic>> completer = Completer();

    void verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
      UserCredential authResult = await _firebaseAuth.signInWithCredential(phoneAuthCredential);
      firebaseUser = authResult.user;
      if (firebaseUser != null) {
        completer.complete({"success": true, "data": firebaseUser});
      } else {
        completer.complete({"success": false, "reason": "Login failed."});
      }
    }

    void verificationFailed(FirebaseAuthException e) {
      String msg = e.message ?? "Unknown error";
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      completer.complete({"success": false, "reason": "Sign failed. $msg"});
    }

    void codeSent(String verificationId, int? resendToken) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter SMS Code"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Verification Code'),
                  onChanged: (value) {
                    if (value.length == 6) {
                      // Use the verification ID and the entered code to sign in
                      PhoneAuthCredential credential = PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: value,
                      );
                      _firebaseAuth.signInWithCredential(credential).then((authResult) {
                        firebaseUser = authResult.user;
                        if (firebaseUser != null) {
                          completer.complete({"success": true, "data": firebaseUser});
                        } else {
                          completer.complete({"success": false, "reason": "Login failed."});
                        }
                        Navigator.of(context).pop(); // Close the dialog
                      }).catchError((error) {
                        String msg = error.message ?? "Unknown error";
                        FirebaseCrashlytics.instance.recordError(error, StackTrace.current);
                        completer.complete({"success": false, "reason": "Sign failed. $msg"});
                        Navigator.of(context).pop(); // Close the dialog
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  completer.complete({"success": false, "reason": "Sign in cancelled."});
                },
              ),
            ],
          );
        },
      );
    }

    void codeAutoRetrievalTimeout(String verificationId) {
      completer.complete({"success": false, "reason": "Code auto retrieval timeout."});
    }

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );

    return completer.future;

  } catch (e) {
    String msg = e.toString();
    debugPrint("phoneSignIn hit error. $msg");
    FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    return {"success": false, "reason": "Sign failed. $msg"};
  }
}




//  @override
//  Future<Map<String, dynamic>> emailSignIn(
//      String email, String password) async {
//    try {
//      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//      UserCredential authResult = await _firebaseAuth
//          .signInWithEmailAndPassword(email: email, password: password);
//      this.firebaseUser = authResult.user;
//      this.firebaseUser.reload();
//
//      if (this.firebaseUser != null) {
//        if (this.firebaseUser.emailVerified == true) {
//          return {"success": true, "data": this};
//        } else {
//          return {
//            "success": false,
//            "reason": "A verification link has been send to your email account",
//            "description":
//                "Please click on the link that has just been send to your email account to verify your email and continue the registration process",
//          };
//        }
//      } else {
//        return {"success": false, "reason": "Login failed."};
//      }
//    } catch (e) {
//      String msg = getExceptionMsg(e);
//      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
//      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//      String jsonString = encoder.convert(getExceptionLogReq);
//      FirebaseCrashlytics.instance
//          .recordError(getExceptionLogReq, StackTrace.current);
//      FirebaseCrashlytics.instance.log(jsonString);
//      return {"success": false, "reason": "Login failed. $msg"};
//    }
//  }
//

@override
Future<Map<String, dynamic>> emailSignIn(String email, String password) async {
  try {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    UserCredential authResult = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    User? firebaseUser = authResult.user;
    await firebaseUser?.reload();

    if (firebaseUser != null) {
      if (firebaseUser.emailVerified) {
        return {"success": true, "data": firebaseUser};
      } else {
        return {
          "success": false,
          "reason": "A verification link has been sent to your email account",
          "description":
              "Please click on the link that has just been sent to your email account to verify your email and continue the registration process",
        };
      }
    } else {
      return {"success": false, "reason": "Login failed."};
    }
  } catch (e) {
    String msg = getExceptionMsg(e);
    Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(getExceptionLogReq);
    FirebaseCrashlytics.instance.recordError(getExceptionLogReq, StackTrace.current);
    FirebaseCrashlytics.instance.log(jsonString);
    return {"success": false, "reason": "Login failed. $msg"};
  }
}

String getExceptionMsg(Exception e) {
  // Define how you want to handle exceptions and return meaningful messages.
  // Example:
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      // Add more cases as needed
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
  return 'An unknown error occurred.';
}

Map<String, dynamic> getExceptionLog(Exception e) {
  // Create a log entry with necessary details about the exception
  return {
    'error': e.toString(),
    'stackTrace': StackTrace.current.toString(),
    // Add more fields if needed
  };
}


//  @override
//  Future<Map<String, dynamic>> facebookSignIn(AuthCredential credential) async {
//    try {
//      UserCredential authResult;
//      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//      authResult = await _firebaseAuth.signInWithCredential(credential);
//      this.firebaseUser = authResult.user;
//      if (this.firebaseUser != null) {
//        return {"success": true, "data": this};
//      } else {
//        return {"success": false, "reason": "Login failed."};
//      }
//    } catch (e) {
//      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
//      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//      String jsonString = encoder.convert(getExceptionLogReq);
//      FirebaseCrashlytics.instance
//          .recordError(getExceptionLogReq, StackTrace.current);
//      FirebaseCrashlytics.instance.log(jsonString);
//      return {
//        "success": false,
//        "reason": "Login failed. ${getExceptionLogReq['log']}"
//      };
//    }
//  }

@override
Future<Map<String, dynamic>> facebookSignIn(AuthCredential credential) async {
  try {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
    User? firebaseUser = authResult.user;

    if (firebaseUser != null) {
      return {"success": true, "data": firebaseUser};
    } else {
      return {"success": false, "reason": "Login failed."};
    }
  } catch (e) {
    String msg = getExceptionMsg(e);
    Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(getExceptionLogReq);
    FirebaseCrashlytics.instance.recordError(getExceptionLogReq, StackTrace.current);
    FirebaseCrashlytics.instance.log(jsonString);
    return {
      "success": false,
      "reason": "Login failed. $msg"
    };
  }
}

// //Example Call:
// void signInWithFacebook(AuthCredential credential) async {
//   Map<String, dynamic> result = await facebookSignIn(credential);
//   if (result['success']) {
//     print("Facebook sign-in successful: ${result['data']}");
//   } else {
//     print("Facebook sign-in failed: ${result['reason']}");
//   }
// }


// String getExceptionMsg(Exception e) {
//   // Define how you want to handle exceptions and return meaningful messages.
//   // Example:
//   if (e is FirebaseAuthException) {
//     switch (e.code) {
//       case 'account-exists-with-different-credential':
//         return 'An account already exists with the same email address but different sign-in credentials.';
//       case 'invalid-credential':
//         return 'The supplied auth credential is malformed or has expired.';
//       case 'operation-not-allowed':
//         return 'The specified auth operation is not allowed.';
//       case 'user-disabled':
//         return 'The user corresponding to the given credential has been disabled.';
//       case 'user-not-found':
//         return 'No user corresponding to the given credential was found.';
//       case 'wrong-password':
//         return 'The password is invalid or the user does not have a password.';
//       case 'invalid-verification-code':
//         return 'The verification code is not valid.';
//       case 'invalid-verification-id':
//         return 'The verification ID is not valid.';
//       // Add more cases as needed
//       default:
//         return e.message ?? 'An unknown error occurred.';
//     }
//   }
//   return 'An unknown error occurred.';
// }


// Map<String, dynamic> getExceptionLog(Exception e) {
//   // Create a log entry with necessary details about the exception
//   return {
//     'error': e.toString(),
//     'stackTrace': StackTrace.current.toString(),
//     // Add more fields if needed
//   };
// }

// @override
// Future<Map<String, dynamic>> emailRegister(String email, password) async {
//   try {
//     final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//     UserCredential authResult =
//         await _firebaseAuth.createUserWithEmailAndPassword(
//             email: email.replaceAll(" ", ""), password: password);
//     this.firebaseUser = authResult.user;
//     this.firebaseUser.sendEmailVerification();
//     if (this.firebaseUser != null) {
//       return {"success": true, "data": this};
//     } else {
//       return {"success": false, "reason": "Register failed."};
//     }
//   } catch (e) {
//     Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
//     JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//     String jsonString = encoder.convert(getExceptionLogReq);
//     FirebaseCrashlytics.instance
//         .recordError(getExceptionLogReq, StackTrace.current);
//     FirebaseCrashlytics.instance.log(jsonString);
//     return {
//       "success": false,
//       "reason": "Register failed. ${getExceptionLogReq['log']}"
//     };
//   }
// }
// 

@override
Future<Map<String, dynamic>> emailRegister(String email, dynamic password) async {
  try {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    UserCredential authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.replaceAll(" ", ""),
      password: password,
    );

    User? firebaseUser = authResult.user;
    await firebaseUser?.sendEmailVerification();

    if (firebaseUser != null) {
      return {"success": true, "data": firebaseUser};
    } else {
      return {"success": false, "reason": "Register failed."};
    }
  } catch (e) {
    String msg = getExceptionMsg(e);
    Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    String jsonString = encoder.convert(getExceptionLogReq);
    FirebaseCrashlytics.instance.recordError(getExceptionLogReq, StackTrace.current);
    FirebaseCrashlytics.instance.log(jsonString);
    return {
      "success": false,
      "reason": "Register failed. $msg"
    };
  }
}

// String getExceptionMsg(Exception e) {
//   // Define how you want to handle exceptions and return meaningful messages.
//   // Example:
//   if (e is FirebaseAuthException) {
//     switch (e.code) {
//       case 'email-already-in-use':
//         return 'The email address is already in use by another account.';
//       case 'invalid-email':
//         return 'The email address is not valid.';
//       case 'operation-not-allowed':
//         return 'Email/password accounts are not enabled.';
//       case 'weak-password':
//         return 'The password is not strong enough.';
//       // Add more cases as needed
//       default:
//         return e.message ?? 'An unknown error occurred.';
//     }
//   }
//   return 'An unknown error occurred.';
// }

// Map<String, dynamic> getExceptionLog(Exception e) {
//   // Create a log entry with necessary details about the exception
//   return {
//     'error': e.toString(),
//     'stackTrace': StackTrace.current.toString(),
//     // Add more fields if needed
//   };
// }




  @override
  Future<Map<String, dynamic>> getCurrentTime() async {
    try {
      Dio dio = getDio(baseOption: 1, queries: {});
      Response response = await dio.get("/server_time");
      try {
        DateTime currentDT;
        currentDT = DateTime.parse(response.data.toString().replaceAll("Z", ""))
            .add(Duration(hours: 8));
        hantarrBloc.state.serverTime = currentDT;
        hantarrBloc.add(Refresh());
        return {"success": true, "data": hantarrBloc.state.serverTime};
      } catch (e) {
        throw ("get current time failed");
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get Current time failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> getTopUpHistory() async {
    try {
      var getTopUpReq = await TopUp.initClass().getTopUpHistory();
      return getTopUpReq;
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Get Top Up history failed. $msg"};
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (this
          .firebaseUser!
          .providerData
          .where((x) => x.providerId.toLowerCase().contains("google.com"))
          .isNotEmpty) {
        final GoogleSignIn _gSignIn = new GoogleSignIn();
        await _gSignIn.signOut();
      }
    } catch (e) {
      debugPrint("Google sign out failed. ${e.toString()}");
    }

    try {
      await FirebaseAuth.instance.signOut();
      this.firebaseUser = null;
    } catch (e) {
      debugPrint("Firebase signout failed. ${e.toString()}");
    }
  }

  @override
  Future<Map<String, dynamic>> setLocation(BuildContext context) async {
    try {
      var location = new Location();
      LocationData currentLocation;
      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.granted) {
        currentLocation = await Location().getLocation();
        // ignore: unnecessary_null_comparison
        if (currentLocation != null) {
          hantarrBloc.state.selectedLocation =
              LatLng(currentLocation.latitude, currentLocation.longitude);
          hantarrBloc.state.currentLocation =
              LatLng(currentLocation.latitude, currentLocation.longitude);
          hantarrBloc.add(Refresh());
          return {"success": true, "data": currentLocation};
        } else {
          await Navigator.pushNamed(context, getlocationPage);
          if (hantarrBloc.state.selectedLocation != null) {
            return {
              "success": true,
              "data": hantarrBloc.state.selectedLocation
            };
          } else {
            return {"succes": false, "reason": "Get location failed"};
          }
        }
      } else {
        PermissionStatus requestPermissionReq =
            await Location().requestPermission();
        if (requestPermissionReq == PermissionStatus.granted) {
          currentLocation = await Location().getLocation();
          if (currentLocation != null) {
            hantarrBloc.state.selectedLocation =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            hantarrBloc.state.currentLocation =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            hantarrBloc.add(Refresh());
            return {"success": true, "data": currentLocation};
          } else {
            await Navigator.pushNamed(context, getlocationPage);
            if (hantarrBloc.state.selectedLocation != null) {
              return {
                "success": true,
                "data": hantarrBloc.state.selectedLocation
              };
            } else {
              return {"succes": false, "reason": "Get location failed"};
            }
          }
        } else {
          await Navigator.pushNamed(context, getlocationPage);
          if (hantarrBloc.state.selectedLocation != null) {
            return {
              "success": true,
              "data": hantarrBloc.state.selectedLocation
            };
          } else {
            return {"succes": false, "reason": "Get location failed"};
          }
        }
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"succes": false, "reason": "Get location failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> uploadBankSlip(FormData formData) async {
    try {
      Dio dio = getDio(queries: {}, baseOption: 1);
      Response response = await dio.post(
        "/topup/new",
        data: formData,
      );
      if (response.data['id'] != null) {
        return {"success": true, "data": this};
      } else {
        return {"success": false, "reason": "Upload bank slip failed."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("uploadBankSlip hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "Upload bank slip failed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> logVersion(String version) async {
    try {
      if (this.firebaseUser == null) {
        return {"success": true, "data": null};
      }
      Dio dio = getDio(
        queries: {},
        baseOption: 1,
      );
      String os = "";
      if (Platform.isAndroid) {
        os = "h_android";
      } else if (Platform.isIOS) {
        os = "h_ios";
      } else {
        os = "unable_detect";
      }
      Response response = await dio.get(
          "/get_latest_apk/snaelMarketplace/$version?uuid=${this.firebaseUser.uid}&os=$os");
      debugPrint(response.data);
      return {"success": true, "data": response.data};
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("logVersion hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {"success": false, "reason": "logVersionfailed. $msg"};
    }
  }

  @override
  Future<Map<String, dynamic>> getLocalStrorageLocation() async {
    try {
      var resetFirstTime =
          await hantarrBloc.state.storage.read(key: "first_time");
      if (resetFirstTime == null) {
        return {"success": false, "reason": "Please select a location first.."};
      }

      var selected =
          await hantarrBloc.state.storage.read(key: "seleted_address");
      if (selected != null) {
        Address address = Address().fromMap(jsonDecode(selected));
        Map<String, dynamic> addressfromAPI = await Address().getListAddress();
        List<Address> addressFromAPI = addressfromAPI['data'];
        if (addressFromAPI.where((x) => x.id == address.id).isNotEmpty) {
          address = addressFromAPI.where((x) => x.id == address.id).first;
          await this.setLocalStrorageLocation(address);
        } else {
          // address = null;
          if (addressfromAPI.isNotEmpty) {
            await this.setLocalStrorageLocation(addressFromAPI.first);
            address = addressFromAPI.first;
          } else {
            address = null;
          }
        }
        try {
          if (address.address.contains("%address%")) {
            address.buildingBlock = address.address.split("%address%")[0];
            address.address = address.address.split("%address%")[1];
          }
        } catch (r) {}
        if (address != null) {
          hantarrBloc.state.selectedLocation =
              LatLng(address.latitude, address.longitude);
          hantarrBloc.state.foodCart.address =
              "${address.buildingBlock}%address%${address.address}";
          hantarrBloc.state.foodCart.latLng =
              LatLng(address.latitude, address.longitude);
          return {"success": true, "selected_address": address};
        } else {
          return {"success": false, "reason": "Decode address failed"};
        }
      } else {
        return {"success": false, "reason": "Please select a location first."};
      }
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("logVersion hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "getLocalStrorageLocation failed. $msg"
      };
    }
  }

  @override
  Future<Map<String, dynamic>> setLocalStrorageLocation(Address address) async {
    try {
      String encodeAddress = jsonEncode(address.toJson());
      await hantarrBloc.state.storage.write(key: "first_time", value: "true");
      await hantarrBloc.state.storage
          .write(key: "seleted_address", value: encodeAddress);
      return {"success": true};
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("logVersion hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      return {
        "success": false,
        "reason": "setLocalStrorageLocation failed. $msg"
      };
    }
  }

  @override
  Future<void> setLocalOnSelectedAddress(LatLng latLng, String address) async {
    try {
      Address setAddress = Address(
        id: null,
        title: "Current Location",
        receiverName: hantarrBloc.state.hUser.firebaseUser != null
            ? "${hantarrBloc.state.hUser.firebaseUser!?.displayName}"
            : "",
        phone: hantarrBloc.state.hUser.firebaseUser != null
            ? hantarrBloc.state.hUser.firebaseUser!.phoneNumber != null
                ? "${hantarrBloc.state.hUser.firebaseUser!.phoneNumber}"
                : ""
            : "",
        email: hantarrBloc.state.hUser.firebaseUser != null
            ? "${hantarrBloc.state.hUser.firebaseUser!.email}"
            : "",
        address: address,
        buildingBlock: "-",
        longitude: latLng.longitude,
        latitude: latLng.latitude,
        isFavourite: false,
      );
      await hantarrBloc.state.storage.write(key: "first_time", value: "true");
      await hantarrBloc.state.storage.write(
          key: "seleted_address", value: jsonEncode(setAddress.toJson()));
    } catch (e) {
      String msg = getExceptionMsg(e);
      debugPrint("setLocalOnSelectedAddress hit error. $msg");
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
    }
  }

  @override
  bool isBindToEmail() {
    try {
      if (this
          .firebaseUser!
          .providerData
          .where((x) => x.providerId == "password")
          .isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  bool isBindToFacebook() {
    try {
      if (this
          .firebaseUser!
          .providerData
          .where((x) => x.providerId == "facebook.com")
          .isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  bool isBindToGoogle() {
    try {
      if (this
          .firebaseUser!
          .providerData
          .where((x) => x.providerId == "google.com")
          .isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  bool isBindtoPhone() {
    try {
      if (this
          .firebaseUser!
          .providerData
          .where((x) => x.providerId == "phone")
          .isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  bool isBindToApple() {
    try {
      if (this
          .firebaseUser!
          .providerData
          .where((x) => x.providerId == "apple.com")
          .isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  List<Map<String, dynamic>> providersWidgets(BuildContext context) {
    denied() {
      Navigator.pop(context);
    }

    succeed(String url) {
      var params = url.split("access_token=");
      var endparam = params[1].split("&");
      Navigator.pop(context, endparam[0]);
    }

    List<Map<String, dynamic>> providersMapList = [
      {
        "Google": {
          "binded": this.isBindToGoogle(),
          "bind_func": () async {
            final GoogleSignIn _gSignIn = new GoogleSignIn();
            await _gSignIn.signOut();
            final GoogleSignInAccount? googleSignInAccount =
                await _gSignIn.signIn();
            final GoogleSignInAuthentication? authentication =
                await googleSignInAccount!.authentication;
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: authentication!.accessToken,
              idToken: authentication.idToken,
            );
            loadingWidget(context);
            var bindGoogleReq =
                await this.bindAccontFunction(context, credential);
            Navigator.pop(context);
            if (bindGoogleReq['success']) {
              BotToast.showText(text: "Bind with Google Success");
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Bind with Google Failed"),
                    content: Text("${bindGoogleReq['reason']}"),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "OK",
                          style: themeBloc.state.textTheme.button.copyWith(
                            inherit: true,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            }
          },
          "unbind_func": this.canUnbindAcc()
              ? () async {
                  var confirmationReq =
                      await this.confirmationUnbind(context, "Google");
                  if (confirmationReq == "yes") {
                    loadingWidget(context);
                    await this.firebaseUser!.unlink("google.com");
                    await this.firebaseUser!.reload();
                    Navigator.pop(context);
                    this.firebaseUser = FirebaseAuth.instance.currentUser;
                    BotToast.showText(text: "Unlinked Google Account");
                    hantarrBloc.add(Refresh());
                  }
                }
              : () {},
          "color": Colors.blueAccent,
          "icon": LineIcons.google,
          "desc": this.isBindToGoogle()
              ? "${this.firebaseUser!.providerData.where((e) => e.providerId == "google.com").first.email}"
              : "",
        },
      },
      {
        "Facebook": {
          "binded": this.isBindToFacebook(),
          "bind_func": () async {
            final flutterWebViewPlugin = FlutterWebviewPlugin();
            flutterWebViewPlugin.onUrlChanged.listen((String url) {
              print(url);
              if (url.contains("#access_token")) {
                succeed(url);
              }
              if (url.contains(
                  "https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied")) {
                denied();
              }
            });
            // ignore: non_constant_identifier_names
            String your_client_id = "705301893646504";
            // ignore: non_constant_identifier_names
            String your_redirect_url =
                "https://www.facebook.com/connect/login_success.html";
            String selectedUrl =
                'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,';

            String accessToken = await webViewWidget(
                context, selectedUrl, flutterWebViewPlugin, 'Facobook Login');
            flutterWebViewPlugin.dispose();
            loadingWidget(context);
            final facebookAuthCred =
                FacebookAuthProvider.credential(accessToken);
            var bindFacebookReq =
                await this.bindAccontFunction(context, facebookAuthCred);
            Navigator.pop(context);
            if (bindFacebookReq['success']) {
              BotToast.showText(text: "Bind with Facebook Success");
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Bind with Facebook Failed"),
                    content: Text("${bindFacebookReq['reason']}"),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "OK",
                          style: themeBloc.state.textTheme.button.copyWith(
                            inherit: true,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            }
          },
          "unbind_func": this.canUnbindAcc()
              ? () async {
                  var confimationReq =
                      await this.confirmationUnbind(context, "Facebook");
                  if (confimationReq == "yes") {
                    loadingWidget(context);
                    try {
                      await this.firebaseUser!.unlink("facebook.com");
                      await this.firebaseUser!.reload();
                      this.firebaseUser = FirebaseAuth.instance.currentUser;
                      hantarrBloc.add(Refresh());
                      BotToast.showText(text: "Unbind facebook success");
                    } catch (e) {
                      BotToast.showText(text: "Error occured");
                    }
                    Navigator.pop(context);
                  }
                }
              : () {},
          "color": Color(0xff3b5998),
          "icon": LineIcons.facebook_official,
          "desc": this.isBindToFacebook()
              ? "${this.firebaseUser!.providerData.where((e) => e.providerId == "facebook.com").first.email}"
              : "",
        },
      },
    ];

    // phone number
    if (this.isBindtoPhone()) {
      providersMapList.add(
        {
          "phone number": {
            "binded": this.isBindtoPhone(),
            "bind_func": () async {},
            "unbind_func": () async {
              var confimationReq =
                  await this.confirmationUnbind(context, "Phone");
              if (confimationReq == "yes") {
                loadingWidget(context);
                try {
                  var updateReq = await this.updateProfileData(
                      "${this.firebaseUser!?.displayName}",
                      "${this.firebaseUser!.phoneNumber} (deleted)");
                  if (updateReq['succes']) {
                    await this.firebaseUser!.unlink("phone");
                    await this.firebaseUser!.reload();
                    this.firebaseUser = FirebaseAuth.instance.currentUser;
                    hantarrBloc.add(Refresh());
                    BotToast.showText(text: "Unbind phone success");
                  } else {
                    BotToast.showText(
                        text: "Update failed. ${updateReq['reason']}");
                  }
                } catch (e) {
                  BotToast.showText(text: "Error occured");
                }
                Navigator.pop(context);
              }
            },
            "color": Colors.blueAccent,
            "icon": Icons.phone,
            "desc":
                this.isBindtoPhone() ? "${this.firebaseUser!.phoneNumber}" : "",
          },
        },
      );
    }

    if (Platform.isIOS) {
      providersMapList.add(
        {
          "Apple": {
            "binded": this.isBindToApple(),
            "bind_func": () async {
              final AuthorizationResult result =
                  await AppleSignIn.performRequests([
                AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
              ]);
              print("successfull sign in");
              final AppleIdCredential appleIdCredential = result.credential;
              OAuthProvider oAuthProvider = new OAuthProvider("apple.com");
              final AuthCredential credential = oAuthProvider.credential(
                idToken: String.fromCharCodes(appleIdCredential.identityToken),
                accessToken:
                    String.fromCharCodes(appleIdCredential.authorizationCode),
              );
              loadingWidget(context);
              var bindAppleReq =
                  await this.bindAccontFunction(context, credential);
              Navigator.pop(context);
              if (bindAppleReq['success']) {
                BotToast.showText(text: "Bind with Apple Success");
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Bind with Apple Failed"),
                      content: Text("${bindAppleReq['reason']}"),
                      actions: [
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "OK",
                            style: themeBloc.state.textTheme.button.copyWith(
                              inherit: true,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                );
              }
            },
            "unbind_func": this.canUnbindAcc()
                ? () async {
                    var confimationReq =
                        await this.confirmationUnbind(context, "Apple");
                    if (confimationReq == "yes") {
                      loadingWidget(context);
                      try {
                        await this.firebaseUser!.unlink("apple.com");
                        await this.firebaseUser!.reload();
                        this.firebaseUser = FirebaseAuth.instance.currentUser;
                        hantarrBloc.add(Refresh());
                        BotToast.showText(text: "Unbind Apple success");
                      } catch (e) {
                        BotToast.showText(text: "Error occured");
                      }
                      Navigator.pop(context);
                    }
                  }
                : () {},
            "color": Colors.black,
            "icon": LineIcons.apple,
            "desc": this.isBindToApple()
                ? this
                            .firebaseUser!
                            .providerData
                            .where((e) => e.providerId == "apple.com")
                            .first
                            ?.displayName !=
                        null
                    ? "${this.firebaseUser!.providerData.where((e) => e.providerId == "apple.com").first?.displayName}"
                    : "No Name Provided"
                : "",
          },
        },
      );
    }
    providersMapList.sort((a, b) {
      return b.values.first['binded']
          .toString()
          .compareTo(a.values.first['binded'].toString());
    });
    return providersMapList;
  }

  @override
  Future<Map<String, dynamic>> bindAccontFunction(
      BuildContext context, AuthCredential credential) async {
    try {
      await this.firebaseUser!.linkWithCredential(credential);
      await this.firebaseUser!.reload();
      this.firebaseUser = FirebaseAuth.instance.currentUser;
      hantarrBloc.add(Refresh());
      return {"success": true};
    } catch (e) {
      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      String jsonString = encoder.convert(getExceptionLogReq);
      FirebaseCrashlytics.instance
          .recordError(getExceptionLogReq, StackTrace.current);
      FirebaseCrashlytics.instance.log(jsonString);
      debugPrint("bindAccontFunction hit error. ${getExceptionLogReq['log']}");
      return {
        "success": false,
        "reason": "Bind to account failed. ${getExceptionLogReq['log']}"
      };
    }
  }

  @override
  Future<String> confirmationUnbind(BuildContext context, String title) async {
    var confirmation = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Unbind $title?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'yes');
              },
              child: Text(
                "Yes",
                style: themeBloc.state.textTheme.button?.copyWith(
                  inherit: true,
                  color: themeBloc.state.primaryColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'no');
              },
              style: ElevatedButton.styleFrom(
                primary: themeBloc.state.primaryColor,
              ),
              child: Text(
                "No",
                style: themeBloc.state.textTheme.button?.copyWith(
                  inherit: true,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmation == null) {
      confirmation = "no";
    }
    return confirmation;
  }

  @override
  bool canUnbindAcc() {
    List<bool> boolList = [
      this.isBindToFacebook(),
      this.isBindToGoogle(),
      this.isBindToApple(),
    ];
    if (boolList.where((x) => x == true).toList().length > 1) {
      return true;
    } else {
      return false;
    }
  

//  @override
//  Future<Map<String, dynamic>> canLoginWithPhone(String phone) async {
//    try {
//      Dio dio = getDio(queries: {
//        "field": "check_patron_by_phone",
//        "phone": "$phone",
//      }, baseOption: 1);
//      Response response = await dio.get("/sales");
//      if (response.data['success'] == true) {
//        return {"success": true};
//      } else {
//        return {"success": false, "reason": response.data['reason']};
//      }
//    } catch (e) {
//      Map<String, dynamic> getExceptionLogReq = getExceptionLog(e);
//      JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//      String jsonString = encoder.convert(getExceptionLogReq);
//      FirebaseCrashlytics.instance
//          .recordError(getExceptionLogReq, StackTrace.current);
//      FirebaseCrashlytics.instance.log(jsonString);
//      print(
//          "p2ptransaction module from map hit error. ${getExceptionLogReq['log']}");
//      return {"success": false, "reason": "${getExceptionLogReq['msg']}"};
//    }
//  }
//}
