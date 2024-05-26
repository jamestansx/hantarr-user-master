class PreorderDeliveryFee {
  double startKM, endKM, fee;
  int restaurantID;
  PreorderDeliveryFee({this.endKM, this.startKM, this.fee, this.restaurantID});

  PreorderDeliveryFee.fromJson(Map map) {
    startKM = map["start_km"];
    endKM = map["end_km"];
    fee = map["price"];
    restaurantID = map["rest_id"];
  }
}
