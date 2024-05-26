import 'package:flutter/material.dart';
import 'package:hantarr/route_setting/route_settings.dart';

class HantarrHomepage extends StatefulWidget {
  HantarrHomepage();

  @override
  _HantarrHomepageState createState() => _HantarrHomepageState();
}

class _HantarrHomepageState extends State<HantarrHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hantarr Homepage"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, hantarrHomepage);
        },
      ),
    );
  }
}
