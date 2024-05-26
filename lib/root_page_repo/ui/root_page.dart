import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/route_setting/route_settings.dart';

class NewRootPage extends StatefulWidget {
  @override
  _NewRootPageState createState() => _NewRootPageState();
}

class _NewRootPageState extends State<NewRootPage> {
  @override
  void initState() {
    initALL();
    this.initDynamicLinks();
    super.initState();
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      Uri deepLink = dynamicLink?.link;

      if (deepLink != null) {
        String path =
            dynamicLink.link.toString().replaceAll("https://hantarr.com", "");
        Navigator.pushNamed(context, path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
    }
  }

  initALL() async {
    // get user login status
    // if login ==> get details
    try {
      debugPrint("getting user data");
      if (hantarrBloc.state.hUser.firebaseUser != null) {
        debugPrint("success get user data");
        var getLatestBalanceReq = await hantarrBloc.state.hUser.getUserData();
        if (getLatestBalanceReq['success']) {
          hantarrBloc.add(Refresh());
        } else {
          BotToast.showText(
              text: "Retrieve credit balance failed",
              duration: Duration(seconds: 3));
        }
      } else {
        debugPrint("firebaseUser.uid is null");
      }
    } catch (e) {}

    var getLocation = await hantarrBloc.state.hUser.getLocalStrorageLocation();
    if (getLocation['success']) {
      // check user data if address same with this address then no need update
      // else need update
      try {
        LatLng dbLocation = LatLng(hantarrBloc.state.hUser.latitude,
            hantarrBloc.state.hUser.longitude);
        LatLng curSelectedLocation = hantarrBloc.state.selectedLocation;
        if (dbLocation.longitude != curSelectedLocation.longitude ||
            dbLocation.latitude != curSelectedLocation.latitude) {
        } else {
          // do nothing, no need update
        }
      } catch (e) {}

      Navigator.pushNamed(context, newMainScreen);
    } else {
      var thisresult = await Navigator.pushNamed(context, getlocationPage);
      try {
        Map<String, dynamic> result = thisresult as Map<String, dynamic>;
        if (result['success']) {
          Address thisaddress = result['data'] as Address;
          var setLocation = await hantarrBloc.state.hUser
              .setLocalStrorageLocation(thisaddress);
          if (setLocation['success']) {
            Navigator.pushNamed(context, newMainScreen);
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Something went wrong"),
                  content: Text("${setLocation['reason']}\nPlease try again."),
                  actions: [
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                        initALL();
                      },
                      child: Text("OK"),
                    )
                  ],
                );
              },
            );
          }
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Something went wrong"),
                content: Text("Please try again."),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      initALL();
                    },
                    child: Text("OK"),
                  )
                ],
              );
            },
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Something went wrong"),
              content: Text("Please try again."),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                    initALL();
                  },
                  child: Text("OK"),
                )
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    // Size mediaQ = MediaQuery.of(context).size;
    return BlocListener<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      listener: (context, state) {
        // do stuff here based on BlocA's state
      },
      child: BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (BuildContext context, HantarrState state) {
          return Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .5,
                      child: Image.asset("assets/logoword.png"),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(30),
                    ),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
