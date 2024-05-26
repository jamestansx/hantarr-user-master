class ZoneDetail {
  String state;
  String area;
  String longitude;
  String latitude;
  double deliveryMaxKM;
  double extraCostPerKM;
  double deliveryCostPrice;
  double deliveryDefaultKm;

  ZoneDetail(
      {this.state,
      this.area,
      this.longitude,
      this.latitude,
      this.deliveryCostPrice,
      this.deliveryMaxKM,
      this.extraCostPerKM,
      this.deliveryDefaultKm});

  ZoneDetail.fromJson(var map) {
    state = map["state"];
    longitude = map["long"].toString();
    latitude = map["lat"].toString();
    deliveryMaxKM = map["delivery_max_km"] is int
        ? num.tryParse(map["delivery_max_km"].toString()).toDouble()
        : map["delivery_max_km"];
    deliveryCostPrice = map["delivery_cost_price"] is String
        ? num.tryParse(map["delivery_cost_price"]).toDouble()
        : map["delivery_cost_price"];
    extraCostPerKM = map["delivery_extra_per_km_cost"] is String
        ? num.tryParse(map["delivery_extra_per_km_cost"]).toDouble()
        : map["delivery_extra_per_km_cost"];
    area = map["area"];
    deliveryDefaultKm = map["delivery_default_coverage"] is String
        ? num.tryParse(map["delivery_default_coverage"]).toDouble()
        : map["delivery_default_coverage"];
  }
}
