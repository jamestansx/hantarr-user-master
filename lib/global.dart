import 'package:hantarr/bloc/theme_bloc.dart';
import 'package:hantarr/packageUrl.dart';

HantarrBloc hantarrBloc;
ThemeBloc themeBloc;
// Color themeBloc.state.primaryColor;
// Color Colors.white;

// food delivery base url
// String foodUrl = "https://pos.str8.my/api_v2"; // production
String foodUrl = "https://alt.str8.my/api_v2"; // production
// String foodUrlAlt = "https://alt.str8.my/api_v2"; // production
// String foodUrl = "http://8a7c09cb17cf.sn.mynetname.net/api_v2"; // test server
// String foodUrl = "http://192.168.0.29:4000/api";   // test server

// p2p base url
String p2pBaseUrl = "https://p2p.hantarr.com/api"; // production
// String p2pBaseUrl = "http://10.239.30.199:5000/api"; // test server
// String p2pBaseUrl =
//     "http://8a7c09cb17cf.sn.mynetname.net:5000/api"; // test server

String userUrl = "https://auth.hantarr.com/api";

const String privacyPolicyURL =
    "https://pos.str8.my/apk/uploads/hantarr_privacy_policy(1).html";

List<String> weekday = ["Mon", "Tue", "Wed", "Thurs", "Fri", "Sat", "Sun"];
List<String> months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "July",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

webViewWidget(BuildContext context, String selectedUrl,
    FlutterWebviewPlugin flutterWebViewPlugin, String title) async {
  // ScreenUtil.init(context);
  String result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        ScreenUtil.init(context);
        return WebviewScaffold(
          clearCache: true,
          clearCookies: true,
          url: selectedUrl,
          // javascriptChannels: jsChannels,
          mediaPlaybackRequiresUserGesture: false,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(title,
                style: TextStyle(
                    color: Colors.yellow[800],
                    fontSize: ScreenUtil().setSp(45))),
            leading: IconButton(
              icon: Icon(
                LineIcons.close,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          withZoom: true,
          withLocalStorage: true,
          hidden: true,
          initialChild: Container(
            child: Center(
              child: Container(
                child: Text("Loading..."),
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    flutterWebViewPlugin.goBack();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    flutterWebViewPlugin.goForward();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.autorenew),
                  onPressed: () {
                    flutterWebViewPlugin.reload();
                  },
                ),
              ],
            ),
          ),
        );
      });

  if (result != null) {
    return result;
  }
}

showSignInDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: LoginPage(),
        ),
      );
    },
  );
}

unablePreorderDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.30,
                  height: MediaQuery.of(context).size.width * 0.30,
                  child: Image.asset(
                    "assets/sad.png",
                    // color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Sorry, currently the pre-order is not supported for this restaurnt!",
                    style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: themeBloc.state.primaryColor,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Got it!",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(40)),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      });
}

loadingWidget(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () {
          return null;
        },
        child: Padding(
          padding: EdgeInsets.all(50),
          child: Dialog(
              elevation: 5,
              backgroundColor: Colors.black.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SpinKitChasingDots(
                      color: themeBloc.state.primaryColor,
                      size: 50,
                    ),
                  ],
                ),
              )),
        ),
      );
    },
  );
}

Widget confirmationDialog(
    BuildContext context, String title, String okButtonText) {
  return AlertDialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    ),
    title: Text(
      "$title",
    ),
    actions: [
      FlatButton(
        onPressed: () {
          Navigator.pop(context, "No");
        },
        child: Text(
          "Regret",
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
      FlatButton(
        onPressed: () {
          Navigator.pop(context, "OK");
        },
        color: themeBloc.state.primaryColor,
        child: Text(
          "$okButtonText",
          style: themeBloc.state.textTheme.button.copyWith(
            fontSize: ScreenUtil().setSp(35.0),
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}
