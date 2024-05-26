class Discount {
  String targets;
  String requirements;
  String name;
  String type;
  String desc;
  String category;
  double amount;
  String startDate;
  String startTime;
  String endDate;
  String endTime;
  double minSpend;

  Discount({
    this.amount,
    this.category,
    this.desc = "",
    this.name = "",
    this.requirements = "",
    this.targets = "",
    this.type = "",
    this.endDate = "",
    this.endTime = "",
    this.startDate = "",
    this.startTime = "",
    this.minSpend,
  });

  Discount.fromJson(var map) {
    targets = map["targets"];
    requirements = map["requirements"];
    name = map["name"];
    type = map["disc_type"];
    desc = map["description"];
    category = map["category"];
    amount = map["amount"];
    startDate = map["start_date"];
    startTime = map["start_time"];
    endDate = map["end_date"];
    endTime = map["end_time"];
    minSpend = map["min_spend"] == null ? 0.00 : map["min_spend"];
  }
}
