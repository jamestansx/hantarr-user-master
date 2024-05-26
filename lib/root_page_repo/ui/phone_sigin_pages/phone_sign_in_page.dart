import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:hantarr/packageUrl.dart';

class PhoneSignInPage extends StatefulWidget {
  @override
  _PhoneSignInPageState createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends State<PhoneSignInPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  bool codeSent = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> sendOtpFunction() async {
    FocusScope.of(context).unfocus();

    var getCanLoginWithPhonereq = await hantarrBloc.state.hUser
        .canLoginWithPhone("60" + phoneController.text);
    if (getCanLoginWithPhonereq['success']) {
      BotToast.showLoading();
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+60" + phoneController.text,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          BotToast.closeAllLoading();
          FirebaseAuth.instance
              .signInWithCredential(authCredential)
              .then((UserCredential result) {
            print(result.user?.displayName);
            Phoenix.rebirth(context);
          }).catchError((e) {
            print(e);
            BotToast.showText(
                text: "${e.message}", duration: Duration(seconds: 10));
          });
        },
        verificationFailed: (FirebaseAuthException authException) {
          BotToast.closeAllLoading();
          print(authException.message);
          BotToast.showText(
              text: "${authException.message}",
              duration: Duration(seconds: 10));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          BotToast.closeAllLoading();
          //show dialog to take input from the user
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: _codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Done"),
                        textColor: Colors.white,
                        color: Colors.redAccent,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          FirebaseAuth auth = FirebaseAuth.instance;
                          String smsCode = _codeController.text.trim();
                          AuthCredential _credential =
                              PhoneAuthProvider.credential(
                                  verificationId: verificationId,
                                  smsCode: smsCode);
                          auth
                              .signInWithCredential(_credential)
                              .then((UserCredential result) {
                            print(result.user?.displayName);
                            Phoenix.rebirth(context);
                          }).catchError((e) {
                            print(e);
                            BotToast.showText(
                                text: "${e.message}",
                                duration: Duration(seconds: 10));
                          });
                        },
                      )
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          BotToast.closeAllLoading();
          verificationId = verificationId;
          print(verificationId);
          print("Timout");
        },
      );
    } else {
      BotToast.showText(
          text:
              "${getCanLoginWithPhonereq['reason']}. Please login with other provider.");
    }
  }

  List<Widget> getPhoneWidgets() {
    List<Widget> widgetlist = [
      Text(
        "Enter your phone",
        textAlign: TextAlign.left,
        style: themeBloc.state.textTheme.subtitle1.copyWith(
          inherit: true,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: ScreenUtil().setSp(40.0),
        ),
      ),
      SizedBox(
        height: 5,
      ),
      TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        style: TextStyle(
          fontSize: ScreenUtil().setSp(38),
          color: Colors.white,
        ),
        decoration: new InputDecoration(
          prefixIcon: Icon(
            Icons.phone,
            color: Colors.white,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]),
          ),
          labelText: 'Phone Number',
          labelStyle: TextStyle(
            fontSize: ScreenUtil().setSp(38),
            color: Colors.grey[300],
          ),
          prefixText: "+60",
          prefixStyle: TextStyle(
            fontSize: ScreenUtil().setSp(38),
            color: Colors.white,
          ),
        ),
      ),
      SizedBox(
        height: 5,
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 5),
            Icon(Icons.info, color: Colors.white, size: 20.0),
            SizedBox(width: 10.0),
            Expanded(
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: 'We will send ',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400)),
                TextSpan(
                    text: 'One Time Password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700)),
                TextSpan(
                    text: ' to this mobile number',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w400)),
              ])),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 15,
      ),
      Center(
        child: RaisedButton(
          onPressed: sendOtpFunction,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          child: Text(
            "SEND OTP",
            style: TextStyle(
              color: themeBloc.state.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil().setSp(55),
            ),
          ),
        ),
      ),
    ];
    return widgetlist;
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            body: Container(
              width: mediaQ.width,
              height: mediaQ.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(25.0),
                        ),
                      ),
                      color: themeBloc.state.primaryColor,
                      child: Container(
                        width: mediaQ.width * .9,
                        height: mediaQ.height * .8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: mediaQ.width,
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipRRect(
                              borderRadius: new BorderRadius.circular(100.0),
                              child: Image.asset(
                                'assets/logo.jpg',
                                width: MediaQuery.of(context).size.width / 1.6,
                              ),
                            ),
                            // Text(
                            //   "Hantarr Delivery",
                            //   style: themeBloc.state.textTheme.headline6.copyWith(
                            //     inherit: true,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.white,
                            //     fontSize: ScreenUtil().setSp(55.0),
                            //   ),
                            // ),

                            Container(
                              width: mediaQ.width * .8,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    codeSent == false ? getPhoneWidgets() : [],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
