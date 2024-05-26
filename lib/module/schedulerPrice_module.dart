class SchedulePrice {
  String untilDate;
  String fromDate;
  String untilTime;
  String fromTime;
  String frequencyDuration;
  double price;

  SchedulePrice(
      {this.frequencyDuration,
      this.fromDate,
      this.fromTime,
      this.price,
      this.untilDate,
      this.untilTime});
}
