import 'package:flutter/material.dart';
import 'package:hantarr/packageUrl.dart';

// ignore: must_be_immutable
class TopUpWidget extends StatefulWidget {
  TopUp topUp;
  TopUpWidget({
    @required this.topUp,
  });
  @override
  _TopUpWidgetState createState() => _TopUpWidgetState();
}

class _TopUpWidgetState extends State<TopUpWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (context, state) {
        return Container();
      },
    );
  }
}
