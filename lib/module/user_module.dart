// ignore: import_of_legacy_library_into_null_safe
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart' as dioo;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hantarr/packageUrl.dart';
// ignore: unnecessary_import
import 'package:location/location.dart';
// import 'package:location_permissions/location_permissions.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

abstract class UserInterface {
  getLatestBalance();
  Future<Map<String, dynamic>> updateProfileData(String name, String phone);
  Future<Map<String, dynamic>> submitContactInfo(String url, var payload);
}

class User implements UserInterface {
  String name;
  String email;
  String phone;
  String uuid;
  String longitude;
  String latitude;
  RestaurantCart restaurantCart;
  List<ContactInfo> contactInfos;
  ContactInfo currentContactInfo;
  Delivery currentDelivery;
  List<Delivery> allDelivery;
  String fcmToken;
  double credit;
  List<TopUp> topUpHistory;

  User(
      {required this.name,
      required this.email,
      required this.phone,
      required this.uuid,
      required this.latitude,
      required this.longitude,
      required this.restaurantCart,
      required this.contactInfos,
      required this.currentContactInfo,
      required this.allDelivery,
      required this.currentDelivery,
      required this.fcmToken,
      required this.credit,
      required this.topUpHistory});

  initData() {}

  // Future<String> getSalt()async{
  //   var response = await post("$userUrl/webhook",body: jsonEncode(
  //     {
  //       "scope":"request_salt",
  //       "user_id":
  //     }
  //   ));
  // }

  Future signOut() async {
    auth.User? user = auth.FirebaseAuth.instance.currentUser;
    try {
      if (user.providerData
          .where((x) => x.providerId.toLowerCase().contains("google.com"))
          .isNotEmpty) {
        final GoogleSignIn _gSignIn = new GoogleSignIn();
        await _gSignIn.signOut();
      }
    } catch (e) {}
    await auth.FirebaseAuth.instance.signOut();
    user = auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      hantarrBloc.state.user = null;
      hantarrBloc.state.user = User(
        allDelivery: [],
        // currentContactInfo: contactInfo,
        contactInfos: [],
        restaurantCart: RestaurantCart(menuItems: [], preOrderDateTime: ""),
      );
      hantarrBloc.add(Refresh());
    }
  }

  //google sign in
  Future<auth.User> googleSiginIn() async {
    final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
    final GoogleSignIn _gSignIn = new GoogleSignIn();
    final GoogleSignInAccount googleSignInAccount = await _gSignIn.signIn();
    final GoogleSignInAuthentication authentication =
        await googleSignInAccount.authentication;

    final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    final auth.UserCredential authResult =
        await _firebaseAuth.signInWithCredential(credential);
    return authResult.user;
  }

  //normal sign in
  Future<auth.User> signInWithEmailAndPassword(
      String email, String password) async {
    final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
    auth.UserCredential authResult = await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    return authResult.user;
  }

  // normal registration
  Future<auth.User> createUserWithEmailAndPassword(
      String email, String password) async {
    final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
    auth.UserCredential authResult = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    return authResult.user;
  }

  // apple sign in
  Future<auth.User> signInWithAppleID() async {
    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    // if (result.status == AuthorizationStatus.authorized) {
    print("successfull sign in");
    final AppleIdCredential appleIdCredential = result.credential;

    auth.OAuthProvider oAuthProvider = new auth.OAuthProvider("apple.com");
    final auth.AuthCredential credential = oAuthProvider.credential(
      idToken: String.fromCharCodes(appleIdCredential.identityToken),
      accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
    );

    final auth.UserCredential user =
        await auth.FirebaseAuth.instance.signInWithCredential(credential);
    auth.User info = auth.FirebaseAuth.instance.currentUser;
    String familyName = "";
    String givenName = "";
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

    if (familyName != "" && givenName != "") {
      await info.updateProfile(displayName: "$givenName $familyName");
    }

    return user.user;
    // }
  }

  // facebook sign in
  Future<auth.User> signInWithFacebook(auth.AuthCredential credential) async {
    auth.UserCredential authResult;
    final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
    authResult = await _firebaseAuth.signInWithCredential(credential);
    print("User Name : ${authResult.user?.displayName}");
    return authResult.user;
  }

  Future updateUser() async {
    try {
      auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // overwrite uuid for old snael customer
        var checkDatabaseUserResponse = await get(Uri.tryParse(
            "$foodUrl/sales?fields=migrate_patron&email=${firebaseUser.email}&user_id=${firebaseUser.uid}"));
        if (jsonDecode(checkDatabaseUserResponse.body) is String) {
          // create or update user api
          await post(Uri.tryParse(
              "$foodUrl/sales?fields=register_patron&user_id=${firebaseUser.uid}&phone=${firebaseUser.phoneNumber}&name=${firebaseUser?.displayName}&email=${firebaseUser.email}"));
        }
      }
      // var location = new Location();
      // LocationData currentLocation;
      double long, lat;

      // // set user details
      FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
      ContactInfo contactInfo;
      User user;
      if (firebaseUser != null) {
        contactInfo = ContactInfo(
            id: null,
            name: firebaseUser?.displayName,
            email: firebaseUser.email,
            phone: firebaseUser.phoneNumber,
            longitude: long.toString(),
            latitude: lat.toString(),
            title: "Your Current Location",
            address: "");
        String fcmToken = await _firebaseMessaging.getToken();
        print("FCM token here: " + fcmToken);
        var creditResponse =
            await get(Uri.tryParse("$foodUrl/credit/${firebaseUser.uid}"));

        await post(Uri.tryParse(
            "$foodUrl/sales?fields=register_patron&user_id=${firebaseUser.uid}&phone=${firebaseUser.phoneNumber}&name=${firebaseUser?.displayName}&email=${firebaseUser.email}&fcm_token=$fcmToken"));
        user = User(
            restaurantCart: RestaurantCart(menuItems: [], preOrderDateTime: ""),
            name: firebaseUser?.displayName,
            uuid: firebaseUser.uid,
            email: firebaseUser.email,
            phone: firebaseUser.phoneNumber == null
                ? ""
                : firebaseUser.phoneNumber,
            currentContactInfo: contactInfo,
            contactInfos: [],
            fcmToken: fcmToken,
            credit: creditResponse.body == ""
                ? 0.0
                : jsonDecode(creditResponse.body)["total"],
            topUpHistory: []);
        hantarrBloc.state.user = user;
        // get contact info //
        await ContactInfo().getContactInfo();
        // get pending order //
        await Delivery().getPendingOrder();
      } else {
        contactInfo = ContactInfo(
            id: null,
            longitude: long.toString(),
            latitude: lat.toString(),
            title: "Your Current Location",
            address: "");
        user = User(
            allDelivery: [],
            currentContactInfo: contactInfo,
            contactInfos: [],
            restaurantCart: RestaurantCart(menuItems: [], preOrderDateTime: ""),
            topUpHistory: []);
        hantarrBloc.state.user = user;
      }

      hantarrBloc.add(Refresh());
    } catch (e) {
      User user = User(
          allDelivery: [],
          currentContactInfo: null,
          contactInfos: [],
          restaurantCart: RestaurantCart(menuItems: [], preOrderDateTime: ""),
          topUpHistory: []);
      hantarrBloc.state.user = user;
      print("User update Error. ${e.toString()}");
      BotToast.showText(
          text: "Error. ${e.toString()}", duration: Duration(seconds: 3));
      hantarrBloc.add(Refresh());
    }
  }

  Future getCurrentTime() async {
    var dtResponse = await get(Uri.tryParse("$foodUrl/server_time"));
    DateTime currentDT;
    currentDT = DateTime.parse(jsonDecode(dtResponse.body.replaceAll("Z", "")))
        .add(Duration(hours: 8));
    hantarrBloc.state.serverTime = currentDT;
    hantarrBloc.add(Refresh());
    return currentDT;
  }

  Future getTopupHistory() async {
    try {
      var topupResponse = await get(
          Uri.tryParse("$foodUrl/topup/${hantarrBloc.state.user.uuid}"));
      if (topupResponse.body != "") {
        List topupMap = jsonDecode(topupResponse.body);
        hantarrBloc.state.user.topUpHistory = [];
        topupMap.forEach((var map) {
          hantarrBloc.state.user.topUpHistory.add(TopUp().fromJson(map));
        });
        hantarrBloc.add(Refresh());
      }
    } catch (e) {
      BotToast.showText(text: "Get Top Up History Failed. ${e.toString()}");
    }
  }

  setLocation() async {
    try {
      var location = new Location();
      LocationData currentLocation;
      double long, lat;
      // process to get user location
      PermissionStatus _permissionGranted = await location.hasPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _permissionGranted = await Location().requestPermission();
        if (_permissionGranted == PermissionStatus.granted) {
          bool enabled = await location.serviceEnabled();

          if (!enabled) {
            Future.delayed(Duration(seconds: 5)).then((value) async {
              enabled = await location.serviceEnabled();
            });
            await location.requestService();
          } else {
            currentLocation = await location.getLocation();
          }

          var result = await get(Uri.tryParse(
              "http://map.resertech.com:7070/reverse?lon=${currentLocation.longitude.toString()}&lat=${currentLocation.latitude.toString()}&format=geojson"));
          Map jsonMap = jsonDecode(result.body);
          try {
            if (jsonMap["features"]
                    .first["properties"]["address"]["country"]
                    .toString()
                    .toLowerCase() ==
                "malaysia") {
              long = currentLocation.longitude;
              lat = currentLocation.latitude;
            }
          } catch (e) {
            long = 101.5026;
            lat = 2.8121;
          }
        } else {
          long = 101.5026;
          lat = 2.8121;
        }
      } else {
        await location.serviceEnabled().then((enabled) async {
          if (enabled) {
            currentLocation = await location.getLocation();
            var result = await get(Uri.tryParse(
                "http://map.resertech.com:7070/reverse?lon=${currentLocation.longitude.toString()}&lat=${currentLocation.latitude.toString()}&format=geojson"));
            Map jsonMap = jsonDecode(result.body);
            try {
              if (jsonMap["features"]
                      .first["properties"]["address"]["country"]
                      .toString()
                      .toLowerCase() ==
                  "malaysia") {
                long = currentLocation.longitude;
                lat = currentLocation.latitude;
              }
            } catch (e) {
              long = 101.5026;
              lat = 2.8121;
            }
            // long = currentLocation.longitude;
            // lat = currentLocation.latitude;
          } else {
            long = 101.5026;
            lat = 2.8121;
          }
        });
      }
      this.currentContactInfo.longitude = long.toString();
      this.currentContactInfo.latitude = lat.toString();
      this.longitude = long.toString();
      this.latitude = lat.toString();
      hantarrBloc.add(Refresh());
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  getLatestBalance() async {
    try {
      var creditResponse =
          await get(Uri.tryParse("$foodUrl/credit/${this.uuid}"));
      if (creditResponse.body != "") {
        this.credit = jsonDecode(creditResponse.body)["total"];
        hantarrBloc.add(Refresh());
      }
    } catch (e) {
      BotToast.showText(text: "Retrieve Credit Failed. ${e.toString()}");
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfileData(
      String name, String phone) async {
    try {
      auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser;
      dioo.Dio dio = dioo.Dio();

      dioo.Response response = await dio.post(
        "$foodUrl/sales?scope=update_hantarr_patron",
        data: {
          "user_id": firebaseUser.uid,
          "phone": phone,
          "name": name,
        },
      );
      print(response.data);
      return {"success": true};
    } catch (e) {
      BotToast.showText(text: "Update Failed. ${e.toString()}");
      return {"success": false, "reason": e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> submitContactInfo(
      String url, var payload) async {
    try {
      dioo.Dio dio = dioo.Dio();
      dioo.Response response = await dio.post("$url", data: payload);
      print(response.data.toString() + " update/create address result");
      dioo.Response response2 =
          await dio.get("$foodUrl/${hantarrBloc.state.user.uuid}/addresses");
      if (hantarrBloc.state.user.contactInfos == null) {
        hantarrBloc.state.user.contactInfos = [];
      }
      hantarrBloc.state.user.contactInfos.clear();
      List addressList = [];
      if (response2.data != "") {
        addressList = response2.data;
      }
      for (var address in addressList) {
        ContactInfo ci = ContactInfo(
            title: address["title"] != null ? address["title"] : "",
            name: address["name"] != null ? address["name"] : "",
            phone: address["phone"] != null ? address["phone"] : "",
            longitude: address["long"].toString(),
            latitude: address["lat"].toString(),
            id: address["id"],
            email: address["email"] != null ? address["email"] : "",
            address: address["address"] != null ? address["address"] : "");
        hantarrBloc.state.user.contactInfos.add(ci);
      }

      hantarrBloc.add(Refresh());

      return {"success": true};
    } catch (e) {
      print(e.toString());
      return {
        "success": false,
        "reason": "Create address failed. ${e.toString()}"
      };
    }
  }
}
