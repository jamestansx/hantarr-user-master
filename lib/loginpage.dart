import 'dart:io';
import 'package:auth_buttons/res/buttons/apple_auth_button.dart';
import 'package:auth_buttons/res/buttons/facebook_auth_button.dart';
import 'package:auth_buttons/res/buttons/google_auth_button.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hantarr/route_setting/route_settings.dart';
// import 'package:flutter_auth_buttons/flutter_auth_buttons.dart' as customButton;
import 'package:line_icons/line_icons.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();
  TextEditingController signUpEmailController = new TextEditingController();
  TextEditingController signUpPasswordController = new TextEditingController();
  TextEditingController signUpConfirmPassController =
      new TextEditingController();
  TextEditingController forgotPasswordController = new TextEditingController();
  bool signIn = true;
  bool passwordRest = false;
  String userId;
  bool supportsAppleSignIn = false;

  bool obscurePass = true;
  bool obscureConPass = true;

  denied() {
    Navigator.pop(context);
  }

  succeed(String url) {
    var params = url.split("access_token=");
    var endparam = params[1].split("&");
    Navigator.pop(context, endparam[0]);
  }

  Widget horizontalLine() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          width: ScreenUtil().setWidth(120),
          height: 1.0,
          color: Colors.grey[200],
        ),
      );

  Widget socialButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            horizontalLine(),
            Text("Social Login",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(30),
                    fontFamily: "Poppins-Medium",
                    color: Colors.grey[200])),
            horizontalLine()
          ],
        ),
        SizedBox(
          height: ScreenUtil().setHeight(20),
        ),
        // Row(
        //   // crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: <Widget>[
        //     // SocialIcon(
        //     //   colors: [
        //     //     Color(0xFF102397),
        //     //     Color(0xFF187adf),
        //     //     Color(0xFF00eaf8),
        //     //   ],
        //     //   iconData: CustomIcons.facebook,
        //     //   onPressed: () {},
        //     // ),
        //     SocialIcon(
        //       colors: [
        //         Color(0xFFff4f38),
        //         Color(0xFFff355d),
        //       ],
        //       iconData: CustomIcons.googlePlus,
        //       onPressed: () async {
        // FirebaseUser user = await widget.auth.signInWithGoogle();
        // if (user.uid != null) {
        //   FirebaseUser user = await widget.auth.currentUser();
        //   String currentUserID = user.uid;
        //   print(currentUserID);
        // }

        // widget.googleSignedIn();
        //       },
        //     ),
        //   ],
        // ),
        Platform.isIOS
            ? Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AppleAuthButton(
                  borderRadius: 10,
                  onPressed: () async {
                    loadingWidget(context);

                    var loginreq = await hantarrBloc.state.hUser.appleSignin();
                    Navigator.pop(context);
                    if (loginreq['success']) {
                      Phoenix.rebirth(context);
                      // await User().updateUser();
                      // Navigator.pop(context);
                      // Navigator.of(context).pop();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Login Failed"),
                            content: Text("${loginreq['reason']}"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style:
                                      themeBloc.state.textTheme.button.copyWith(
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
                ))
            : Container(),
        Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: GoogleAuthButton(
              borderRadius: 10,
              onPressed: () async {
                loadingWidget(context);

                var loginreq = await hantarrBloc.state.hUser.googleSignIn();
                Navigator.pop(context);
                if (loginreq['success']) {
                  Phoenix.rebirth(context);
                  // await User().updateUser();
                  // Navigator.pop(context);
                  // Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Login Failed"),
                        content: Text("${loginreq['reason']}"),
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
              darkMode: false, // default: false
            )),
        SizedBox(
          height: ScreenUtil().setHeight(10),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: FacebookAuthButton(
            borderRadius: 10,
            onPressed: () async {
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
              if (accessToken != null) {
                loadingWidget(context);
                final facebookAuthCred =
                    FacebookAuthProvider.credential(accessToken);
                var loginreq = await hantarrBloc.state.hUser
                    .facebookSignIn(facebookAuthCred);
                Navigator.pop(context);
                if (loginreq['success']) {
                  Phoenix.rebirth(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Login Failed"),
                        content: Text("${loginreq['reason']}"),
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
              }
            },
          ),
        ),

        SizedBox(
          height: ScreenUtil().setHeight(10),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: MaterialButton(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: AutoSizeText(
                      "Sign in with phone number",
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onPressed: () async {
              Navigator.pushNamed(context, phoneLoginPage);
            },
          ),
        ),
        supportsAppleSignIn
            ? SizedBox(
                height: ScreenUtil().setHeight(10),
              )
            : Container(),
        supportsAppleSignIn
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // horizontalLine(),
                  Text("OR",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Poppins-Medium",
                          color: Colors.grey[200])),
                  // horizontalLine()
                ],
              )
            : Container(),
        supportsAppleSignIn
            ? SizedBox(
                height: ScreenUtil().setHeight(10),
              )
            : Container(),
        supportsAppleSignIn
            ? Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AppleAuthButton(
                  borderRadius: 10,
                  onPressed: () async {
                    loadingWidget(context);
                    var loginreq = await hantarrBloc.state.hUser.appleSignin();
                    Navigator.pop(context);
                    if (loginreq['success']) {
                      Phoenix.rebirth(context);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Login Failed"),
                            content: Text("${loginreq['reason']}"),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style:
                                      themeBloc.state.textTheme.button.copyWith(
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
                ),
              )
            : Container(),
      ],
    );
  }

  signInSnackBar() async {
    if (loginEmailController.text.length == 0 ||
        loginPasswordController.text.length == 0) {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
          "Fields must not be blank!",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "WorkSansSemiBold"),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ));
    } else {
      loadingWidget(context);
      var loginreq = await hantarrBloc.state.hUser
          .emailSignIn(loginEmailController.text, loginPasswordController.text);
      Navigator.pop(context);
      if (loginreq['success']) {
        Phoenix.rebirth(context);
      } else {
        if (loginreq['description'] != null) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("${loginreq['reason']}"),
                content: Text("${loginreq['description']}"),
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
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Login Failed"),
                content: Text("${loginreq['reason']}"),
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
      }
    }
  }

  signUpSnackBar() async {
    // print(_UserName);
    // bool emailValid = RegExp(r"^[a-zA-Z0-9_\-\.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    //     .hasMatch(signUpEmailController.text);
    if (signUpEmailController.text.length == 0 ||
        signUpPasswordController.text.length == 0 ||
        signUpConfirmPassController.text.length == 0) {
      setState(() {
        signUpEmailController.clear();
        signUpPasswordController.clear();
        signUpConfirmPassController.clear();
      });
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
          "All fields must be completed",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "WorkSansSemiBold"),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ));
    } else if (signUpPasswordController.text ==
                signUpConfirmPassController.text &&
            signUpPasswordController.text.length >= 8
        // &&D
        // emailValid == true
        ) {
      try {
        loadingWidget(context);
        var registReq = await hantarrBloc.state.hUser.emailRegister(
            signUpEmailController.text, signUpPasswordController.text);
        Navigator.pop(context);
        if (registReq['success']) {
          UniqueKey key = UniqueKey();
          BotToast.showWidget(
            key: key,
            toastBuilder: (_) => AlertDialog(
              title: Text("Register success"),
              content: Text(
                "Please click on the link that has just been send to your email account to verify your email and continue the registration process",
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    BotToast.remove(key);
                  },
                  color: themeBloc.state.primaryColor,
                  child: Text(
                    "OK",
                    style: themeBloc.state.textTheme.button.copyWith(
                      inherit: true,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
          setState(() {
            signUpEmailController.clear();
            signUpPasswordController.clear();
            signUpConfirmPassController.clear();
            loginEmailController.text = signUpEmailController.text;
            signIn = true;
          });
          Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text(
              "User Registered !",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontFamily: "WorkSansSemiBold"),
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ));
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Register Failed"),
                content: Text("${registReq['reason']}"),
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
      } catch (e) {
        setState(() {
          signUpEmailController.clear();
          signUpPasswordController.clear();
          signUpConfirmPassController.clear();
        });
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text(
            "An account already exists with the same email address!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontFamily: "WorkSansSemiBold"),
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ));
      }
    } else if (signUpPasswordController.text !=
        signUpConfirmPassController.text) {
      setState(() {
        //  signUpEmailController.clear();
        signUpPasswordController.clear();
        signUpConfirmPassController.clear();
      });
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
          "Password and confirmation password are not match!",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "WorkSansSemiBold"),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ));
    } else if (signUpPasswordController.text.length < 8) {
      setState(() {
        //  signUpEmailController.clear();
        signUpPasswordController.clear();
        signUpConfirmPassController.clear();
      });
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
          "Password must not be shorter than 8 characters.",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "WorkSansSemiBold"),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ));
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text(
          "Please ensure all input are correct",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontFamily: "WorkSansSemiBold"),
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ));
    }
  }

  iosPlatformChecker() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var version = iosInfo.systemVersion;

      if (version.contains('13') == true) {
        setState(() {
          supportsAppleSignIn = true;
        });
      }
    }
  }

  detailInterface() {
    ScreenUtil.init(context, width: 750, height: 1334);
    if (signIn == true) {
      //Sign In Part
      return Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(0.7),
        alignment: Alignment.center,
        // alignment: Alignment.center,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new ClipRRect(
                  borderRadius: new BorderRadius.circular(100.0),
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: MediaQuery.of(context).size.width / 2.2,
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(100),
                ),
                Container(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Material(
                      elevation: 20,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 40, right: 20, top: 10, bottom: 10),
                        child: TextField(
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter your email",
                              hintStyle: TextStyle(
                                  color: Color(0xFFE1E1E1),
                                  fontSize: ScreenUtil().setSp(30))),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  child: Container(
                    width: MediaQuery.of(context).size.width - 40,
                    child: Material(
                      elevation: 20,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 40, right: 20, top: 10, bottom: 10),
                        child: TextField(
                          controller: loginPasswordController,
                          obscureText: obscurePass,
                          keyboardType: TextInputType.visiblePassword,
                          style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Enter your password",
                            hintStyle: TextStyle(
                              color: Color(0xFFE1E1E1),
                              fontSize: ScreenUtil().setSp(30),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePass = !obscurePass;
                                });
                              },
                              icon: Icon(
                                obscurePass
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      right:
                          ScreenUtil().setSp(50, allowFontScalingSelf: true)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            signIn = false;
                            passwordRest = true;
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Text("Forgot your password? ",
                                style: TextStyle(
                                    color: Colors.grey[200],
                                    fontFamily: "Poppins-Bold",
                                    fontSize: ScreenUtil().setSp(25))),
                            Text("Reset Now",
                                style: TextStyle(
                                    color: themeBloc.state.primaryColor,
                                    fontFamily: "Poppins-Bold",
                                    fontSize: ScreenUtil().setSp(25)))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          signIn = false;
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Text("New User? ",
                              style: TextStyle(
                                  color: Colors.grey[200],
                                  fontFamily: "Poppins-Bold",
                                  fontSize: ScreenUtil().setSp(25))),
                          Text("SignUp",
                              style: TextStyle(
                                  color: themeBloc.state.primaryColor,
                                  fontFamily: "Poppins-Bold",
                                  fontSize: ScreenUtil().setSp(25)))
                        ],
                      ),
                    ),
                    InkWell(
                      child: Container(
                        width: ScreenUtil().setWidth(330),
                        height: ScreenUtil().setHeight(100),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              themeBloc.state.primaryColor,
                              themeBloc.state.primaryColor
                            ]),
                            borderRadius: BorderRadius.circular(6.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xFF6078ea).withOpacity(.3),
                                  offset: Offset(0.0, 8.0),
                                  blurRadius: 8.0)
                            ]),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              signInSnackBar();
                            },
                            child: Center(
                              child: Text("LOGIN",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Poppins-Bold",
                                      fontSize: ScreenUtil().setSp(35),
                                      letterSpacing: 1.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(40),
                ),
                socialButton(),
              ],
            ),
          ),
        ),
      );
    } else {
      //Sign Up Part
      if (passwordRest == false) {
        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.7),
          alignment: Alignment.center,
          // alignment: Alignment.center,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new ClipRRect(
                    borderRadius: new BorderRadius.circular(100.0),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: MediaQuery.of(context).size.width / 2.2,
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(100),
                  ),
                  Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: Material(
                        elevation: 20,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 40, right: 20, top: 10, bottom: 10),
                          child: TextField(
                            controller: signUpEmailController,
                            style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    color: Color(0xFFE1E1E1),
                                    fontSize: ScreenUtil().setSp(30))),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: Material(
                        elevation: 20,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 40, right: 20, top: 10, bottom: 10),
                          child: TextField(
                            obscureText: obscurePass,
                            controller: signUpPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "New Password",
                              hintStyle: TextStyle(
                                color: Color(0xFFE1E1E1),
                                fontSize: ScreenUtil().setSp(30),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePass = !obscurePass;
                                  });
                                },
                                icon: Icon(
                                  obscurePass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: Material(
                        elevation: 20,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 40, right: 20, top: 10, bottom: 10),
                          child: TextField(
                            obscureText: obscureConPass,
                            controller: signUpConfirmPassController,
                            keyboardType: TextInputType.visiblePassword,
                            style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Confirmation Password",
                              hintStyle: TextStyle(
                                color: Color(0xFFE1E1E1),
                                fontSize: ScreenUtil().setSp(30),
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscureConPass = !obscureConPass;
                                  });
                                },
                                icon: Icon(
                                  obscureConPass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          setState(() {
                            signIn = true;
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Text("Already registered? ",
                                style: TextStyle(
                                    color: Colors.grey[200],
                                    fontFamily: "Poppins-Bold",
                                    fontSize: ScreenUtil().setSp(25))),
                            Text("SignIn",
                                style: TextStyle(
                                    color: themeBloc.state.primaryColor,
                                    fontFamily: "Poppins-Bold",
                                    fontSize: ScreenUtil().setSp(25)))
                          ],
                        ),
                      ),
                      InkWell(
                        child: Container(
                          width: ScreenUtil().setWidth(330),
                          height: ScreenUtil().setHeight(100),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                themeBloc.state.primaryColor,
                                themeBloc.state.primaryColor
                              ]),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF6078ea).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                signUpSnackBar();
                              },
                              child: Center(
                                child: Text("REGISTER",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: ScreenUtil().setSp(35),
                                        letterSpacing: 1.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(40),
                  ),
                  socialButton(),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.7),
          // alignment: Alignment.center,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new ClipRRect(
                    borderRadius: new BorderRadius.circular(100.0),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: MediaQuery.of(context).size.width / 2.2,
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(80),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true),
                        right:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true)),
                    child: Text(
                      "Forgot your password?",
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: themeBloc.state.primaryColor,
                              fontSize: ScreenUtil().setSp(50),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true),
                        right:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true)),
                    child: Text(
                      "Enter your email and we will send you instructions on how to reset your password.",
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(25))),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      child: Material(
                        elevation: 20,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 40, right: 20, top: 10, bottom: 10),
                          child: TextField(
                            controller: forgotPasswordController,
                            style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Type your email",
                                hintStyle: TextStyle(
                                    color: Color(0xFFE1E1E1),
                                    fontSize: ScreenUtil().setSp(30))),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        right:
                            ScreenUtil().setSp(50, allowFontScalingSelf: true)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            setState(() {
                              signIn = true;
                              passwordRest = false;
                            });
                          },
                          child: Row(
                            children: <Widget>[
                              Text("Back to Sign In? ",
                                  style: TextStyle(
                                      color: Colors.grey[200],
                                      fontFamily: "Poppins-Bold",
                                      fontSize: ScreenUtil().setSp(25))),
                              Text("Sign in now",
                                  style: TextStyle(
                                      color: themeBloc.state.primaryColor,
                                      fontFamily: "Poppins-Bold",
                                      fontSize: ScreenUtil().setSp(25)))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          width: ScreenUtil().setWidth(330),
                          height: ScreenUtil().setHeight(80),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                themeBloc.state.primaryColor,
                                themeBloc.state.primaryColor
                              ]),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFF6078ea).withOpacity(.3),
                                    offset: Offset(0.0, 8.0),
                                    blurRadius: 8.0)
                              ]),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                if (forgotPasswordController.text
                                    .replaceAll(" ", "")
                                    .isNotEmpty) {
                                  loadingWidget(context);
                                  FirebaseAuth _firebaseAuth =
                                      FirebaseAuth.instance;
                                  try {
                                    await _firebaseAuth.sendPasswordResetEmail(
                                        email: forgotPasswordController.text);
                                    Navigator.pop(context);
                                    Scaffold.of(context)
                                        .showSnackBar(new SnackBar(
                                      content: new Text(
                                        "Password Reset Email has been sent!",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(30),
                                            fontFamily: "WorkSansSemiBold"),
                                      ),
                                      backgroundColor: Colors.lightGreen,
                                      duration: Duration(seconds: 3),
                                    ));
                                    setState(() {
                                      forgotPasswordController.clear();
                                      signIn = true;
                                      passwordRest = false;
                                    });
                                  } catch (e) {
                                    print(e);
                                    Navigator.pop(context);
                                    if (e.code == "ERROR_INVALID_EMAIL") {
                                      Scaffold.of(context)
                                          .showSnackBar(new SnackBar(
                                        content: new Text(
                                          "Invalid email!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(30),
                                              fontFamily: "WorkSansSemiBold"),
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ));
                                    } else {
                                      Scaffold.of(context)
                                          .showSnackBar(new SnackBar(
                                        content: new Text(
                                          "Email is not registered yet!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(30),
                                              fontFamily: "WorkSansSemiBold"),
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ));
                                    }
                                  }
                                } else {
                                  Scaffold.of(context)
                                      .showSnackBar(new SnackBar(
                                    content: new Text(
                                      "Email Cannot Empty!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: ScreenUtil().setSp(30),
                                          fontFamily: "WorkSansSemiBold"),
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ));
                                }
                              },
                              child: Center(
                                child: Text("Reset Password",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Poppins-Bold",
                                        fontSize: ScreenUtil().setSp(30),
                                        letterSpacing: 1.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(40),
                  ),
                  // socialButton(),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backdropColor.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      // Positioned(
                      //   child: IconButton(
                      //     onPressed: () {},
                      //     icon: Icon(
                      //       Icons.arrow_back,
                      //     ),
                      //   ),
                      // ),
                      SingleChildScrollView(
                        child: detailInterface(),
                      ),
                      Positioned(
                        child: Container(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(LineIcons.close),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
