import 'package:hantarr/packageUrl.dart';

class ContactInfo {
  int id;
  String name;
  String address;
  String email;
  String phone;
  String latitude;
  String longitude;
  String title;

  ContactInfo({
    this.id,
    this.name = "",
    this.address = "",
    this.email = "",
    this.phone = "",
    this.latitude = "",
    this.longitude = "",
    this.title = "",
  });

  ContactInfo clone(ContactInfo ci) {
    return ContactInfo(
        id: ci.id,
        name: ci.name,
        address: ci.address,
        email: ci.email,
        phone: ci.phone,
        latitude: ci.latitude,
        longitude: ci.longitude,
        title: ci.title);
  }

  ContactInfo.fromJson(var map) {
    title = map["title"] != null ? map["title"] : "";
    name = map["name"] != null ? map["name"] : "";
    phone = map["phone"] != null ? map["phone"] : "";
    longitude = map["long"].toString();
    latitude = map["lat"].toString();
    id = map["id"];
    email = map["email"] != null ? map["email"] : "";
    address = map["address"] != null ? map["address"] : "";
  }

  Future getContactInfo() async {
    try {
      var response = await get(
          Uri.tryParse("$foodUrl/${hantarrBloc.state.user.uuid}/addresses"));
      if (hantarrBloc.state.user.contactInfos == null) {
        hantarrBloc.state.user.contactInfos = [];
      }
      hantarrBloc.state.user.contactInfos.clear();
      if (response.body != "") {
        List addressList = jsonDecode(response.body);
        for (var address in addressList) {
          ContactInfo ci = ContactInfo.fromJson(address);
          hantarrBloc.state.user.contactInfos.add(ci);
        }
      }
    } catch (e) {
      print(" get contact info failed ${e.toString()}");
    }
  }
}
