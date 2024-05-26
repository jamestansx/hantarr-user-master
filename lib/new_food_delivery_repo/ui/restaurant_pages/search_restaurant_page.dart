import 'package:flutter_svg/flutter_svg.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/route_setting/route_settings.dart';

class SearchRestaurantPage extends StatefulWidget {
  @override
  _SearchRestaurantPageState createState() => _SearchRestaurantPageState();
}

class _SearchRestaurantPageState extends State<SearchRestaurantPage> {
  TextEditingController searchCon = TextEditingController();
  FocusNode fn = FocusNode();
  List<NewRestaurant> restaurantList = [];

  @override
  void initState() {
    // restaurantList.addAll(
    //     List<NewRestaurant>.from(hantarrBloc.state.newRestaurantList.toList()));
    Future.delayed(
      Duration(milliseconds: (200)),
      () {
        FocusScope.of(context).requestFocus(fn);
      },
    );
    searchCon.addListener(() {
      restaurantList = [];
      if (searchCon.text.isNotEmpty) {
        // restaurantList = hantarrBloc.state.newRestaurantList
        //     .where(
        //       (x) => x.toJson().toString().toLowerCase().contains(
        //             searchCon.text.toLowerCase(),
        //           ),
        //     )
        //     .toList();
        restaurantList = NewRestaurant().fuzzySearch(searchCon.text);
      } else {
        restaurantList.addAll(List<NewRestaurant>.from(
            hantarrBloc.state.newRestaurantList.toList()));
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    searchCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    Size mediaQ = MediaQuery.of(context).size;
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: themeBloc.state.textTheme.headline6.color,
              ),
            ),
            backgroundColor: Colors.white,
            title: TextFormField(
              controller: searchCon,
              focusNode: fn,
              decoration: InputDecoration(
                labelText: "Search Restaurant",
                hintText: "",
                border: InputBorder.none,
                // fillColor: Colors.grey[100],
              ),
            ),
            actions: fn.hasFocus
                ? [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          searchCon.clear();
                          FocusScope.of(context).unfocus();
                        });
                      },
                      icon: Icon(Icons.clear, color: Colors.red),
                    ),
                  ]
                : null,
          ),
          body: Container(
            width: mediaQ.width,
            height: mediaQ.height,
            child: Column(
              children: [
                Expanded(
                  child: restaurantList.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.all(
                            ScreenUtil().setSp(10.0),
                          ),
                          itemCount: restaurantList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              onTap: () async {
                                // Navigator.pop(context, restaurantList[index]);
                                loadingWidget(context);
                                var checkRestAvailable =
                                    await restaurantList[index]
                                        .restaurantAvailable();
                                Navigator.pop(context);
                                if (checkRestAvailable['data']) {
                                  Navigator.popAndPushNamed(
                                    context,
                                    newMenuItemListPage,
                                    arguments: restaurantList[index],
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                            "${checkRestAvailable['reason']}"),
                                        content: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                checkRestAvailable[
                                                            'business_hours'] !=
                                                        null
                                                    ? Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children:
                                                            restaurantList[
                                                                    index]
                                                                .businessHours
                                                                .map(
                                                          (e) {
                                                            return ListTile(
                                                              title: Text(
                                                                "${e.dayString.toUpperCase()}",
                                                                style: themeBloc
                                                                    .state
                                                                    .textTheme
                                                                    .headline6,
                                                              ),
                                                              trailing: Text(
                                                                "${e.startTime.hour.toString().padLeft(2, '0')}:${e.startTime.minute.toString().padLeft(2, '0')} - ${e.endTime.hour.toString().padLeft(2, '0')}:${e.endTime.minute.toString().padLeft(2, '0')}",
                                                                style: themeBloc
                                                                    .state
                                                                    .textTheme
                                                                    .subtitle2,
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          MaterialButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "OK",
                                              style: themeBloc
                                                  .state.textTheme.button
                                                  .copyWith(
                                                inherit: true,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              title: Text(
                                "${restaurantList[index].name}",
                                style: themeBloc.state.textTheme.bodyText1
                                    .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: ScreenUtil().setWidth(700),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: SvgPicture.asset(
                                  "assets/empty_res.svg",
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(20),
                            ),
                            Text(
                              "No \"${searchCon.text}\" Restaurant Found",
                              style:
                                  themeBloc.state.textTheme.headline6.copyWith(
                                inherit: true,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
