import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<Map> getVersion(FirebaseApp app) async {
  FirebaseDatabase database = FirebaseDatabase.instanceFor(app: app);
  DatabaseReference versionRef =
      database.ref().child("hantarr").child("user");
  Map responses;

  // ignore: unused_local_variable
  var result =
      (await versionRef.get().then((DataSnapshot snapshot) {
    print('Connected to second database and read ${snapshot.value}');
    responses = snapshot.value;
    // BotToast.showText(text: "${responses.toString()}");
    return snapshot.value;
  }));

  return responses;
}
