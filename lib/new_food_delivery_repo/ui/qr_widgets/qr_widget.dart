import 'package:hantarr/packageUrl.dart';
import 'package:qr_flutter/qr_flutter.dart';

showProfileQr(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          hantarrBloc.state.hUser.firebaseUser?.displayName != null
              ? "${hantarrBloc.state.hUser.firebaseUser?.displayName}"
              : "",
        ),
        content: Container(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: QrImage(
            data: hantarrBloc.state.hUser.firebaseUser.uid,
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
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
          )
        ],
      );
    },
  );
}
