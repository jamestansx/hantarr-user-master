import 'package:hantarr/new_food_delivery_repo/ui/history_pages/food_delivery_history_widget.dart';
import 'package:hantarr/packageUrl.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    List<Delivery> historyDeliveryList = hantarrBloc.state.allDeliveries
        .where((x) => (x.deliveryStatus.delivered == true ||
            x.deliveryStatus.canceled == true ||
            x.deliveryStatus.acceptFailedByRestaurant == true ||
            x.deliveryStatus.noRider == true))
        .toList();
    historyDeliveryList.sort((a, b) => a.id.compareTo(b.id));
    historyDeliveryList = historyDeliveryList.reversed.toList();

    return BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.black, //change your colo here
              ),
              title: Text(
                hantarrBloc.state.translation.text("Delivery History"),
                style: TextStyle(
                    color: themeBloc.state.primaryColor,
                    fontSize: ScreenUtil().setSp(40)),
              ),
              backgroundColor: Colors.white,
            ),
            body: historyDeliveryList.isEmpty
                ? Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset("assets/delivery.png"),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        Text(
                          hantarrBloc.state.translation.text("No Delivery"),
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: ScreenUtil().setSp(53)),
                        ),
                        SizedBox(
                          height: 80,
                        )
                      ],
                    ),
                  )
                : Container(
                    child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: historyDeliveryList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FoodDeliveryHistoryWidget(
                              delivery: historyDeliveryList[index]);
                        }),
                  ),
          );
        });
  }
}
