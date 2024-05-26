import 'dart:math';


Map<String, double> roundCurrency(double value) {
  double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  double exactAmount = value;
  // debugPrint("Exact amount: $exactAmount");
  double displayAmount = dp(exactAmount, 2);
  // debugPrint("Display amount: $displayAmount");

  double finalAmount = 0.0;
  // second decimal number
  int length = displayAmount.toStringAsFixed(2).length;
  int secondDecimal =
      num.tryParse(displayAmount.toStringAsFixed(2)[length - 1]).toInt();
  // debugPrint("Second Decimal: " + secondDecimal.toString());
  if (secondDecimal == 1 || secondDecimal == 2) {
    // round down
    finalAmount = dp(displayAmount, 1);
  } else if (secondDecimal == 3 || secondDecimal == 4) {
    int lastDigit = displayAmount.toStringAsFixed(2).length;
    String roundUpString =
        displayAmount.toStringAsFixed(2).substring(0, lastDigit - 1) + "5";
    finalAmount = num.tryParse(roundUpString).toDouble();
  } else if (secondDecimal == 6 || secondDecimal == 7) {
    // round down
    int lastDigit = displayAmount.toStringAsFixed(2).length;
    String roundDownString =
        displayAmount.toStringAsFixed(2).substring(0, lastDigit - 1) + "5";
    finalAmount = num.tryParse(roundDownString).toDouble();
  } else if (secondDecimal == 8 || secondDecimal == 9) {
    finalAmount = dp(displayAmount, 1);
  } else {
    finalAmount = displayAmount;
  }

  double roundedAmount = finalAmount - displayAmount;

  return {
    "exact_amount": 0.0,
    "display_amount": displayAmount,
    "final_amount": finalAmount,
    "rounded_amount": roundedAmount,
  };
}
