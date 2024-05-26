import 'package:hantarr/packageUrl.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class Rootpage extends StatefulWidget {
  Rootpage({Key key}) : super(key: key);

  @override
  _RootpageState createState() => _RootpageState();
}

class _RootpageState extends State<Rootpage> {
  bool loading = true;
  @override
  void initState() {
    checkUser();
    setTime();
    super.initState();
  }

  setTime() async {
    await User().getCurrentTime();
  }

  Future<auth.User> checkUser() async {
    auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser;
    await User().updateUser();
    setState(() {
      loading = false;
    });
    return firebaseUser;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(builder: (context, state) {
      if (!loading) {
        if (hantarrBloc.state.user.uuid != null) {
          return Homepage();
          // if (hantarrBloc.state.user.phone.isEmpty) {
          //   return Phonepage();
          // } else {
          //   return Homepage();
          // }
        } else {
          return Homepage();
        }
      } else {
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
      }
    });
  }
}
