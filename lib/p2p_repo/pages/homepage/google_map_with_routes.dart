import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/p2p_modules/stop_module.dart';
import 'package:hantarr/root_page_repo/modules/osm_route_module.dart';

// ignore: must_be_immutable
class GoogleMapWithRoute extends StatefulWidget {
  P2pTransaction p2pTransaction;
  GoogleMapWithRoute({
    @required this.p2pTransaction,
  });
  @override
  _GoogleMapWithRouteState createState() => _GoogleMapWithRouteState();
}

class _GoogleMapWithRouteState extends State<GoogleMapWithRoute> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng chosenLocation;
  Set<Marker> _markers = {};
  Set<Polyline> polyLines = {};
  @override
  void initState() {
    setAll();
    super.initState();
  }

  _onCameraMove(CameraPosition position) {
    setState(() {
      chosenLocation = position.target;
    });
  }

  setAll() {
    if (widget.p2pTransaction.getTotalValidStopsCount() > 0) {
      chosenLocation = LatLng(
          widget.p2pTransaction.stops.first.address.latitude,
          widget.p2pTransaction.stops.first.address.longitude);
    } else {
      chosenLocation = LatLng(
          hantarrBloc.state.hUser.latitude, hantarrBloc.state.hUser.longitude);
    }
    List<double> markerColors = [
      BitmapDescriptor.hueAzure,
      BitmapDescriptor.hueBlue,
      BitmapDescriptor.hueCyan,
      BitmapDescriptor.hueMagenta,
      BitmapDescriptor.hueRose,
    ];
    _markers = {};
    for (Stop stop in widget.p2pTransaction.stops
        .where((x) => x.address.id != null)
        .toList()) {
      _markers.add(Marker(
        markerId: MarkerId("${stop.address.hashCode}"),
        position: LatLng(stop.address.latitude, stop.address.longitude),
        // infoWindow: InfoWindow(
        //     title: hantarrBloc.state.user.name,
        //     snippet: hantarrBloc.state.user.phone),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            markerColors[Random.secure().nextInt(markerColors.length)]),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    polyLines = {};

    if (widget.p2pTransaction.routes.isNotEmpty) {
      for (OSM osm in widget.p2pTransaction.routes) {
        List<LatLng> latlongs = [];
        for (OSMCoordinate co in osm.coordinates) {
          latlongs.add(
            LatLng(co.lat, co.long),
          );
        }
        polyLines.add(
          Polyline(
            polylineId: PolylineId(Key(osm.hashCode.toString()).toString()),
            color: Color.fromARGB(255, 40, 122, 198),
            points: latlongs,
          ),
        );
      }
    }
    return GoogleMap(
      mapType: MapType.normal,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      initialCameraPosition: CameraPosition(target: chosenLocation, zoom: 10.0),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        setState(() {});
      },
      markers: _markers,
      polylines: polyLines,
      onCameraMove: _onCameraMove,
    );
  }
}
