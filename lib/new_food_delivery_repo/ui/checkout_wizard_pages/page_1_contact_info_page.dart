import 'package:hantarr/new_food_delivery_repo/ui/delivery_datetime_option_selection/deliveryDTOptionSelection.dart';
import 'package:hantarr/packageUrl.dart';
import 'package:hantarr/utilities/date_formater.dart';

class ContactInfoPage extends StatefulWidget {
  ContactInfoPage();
  @override
  _ContactInfoPageState createState() => _ContactInfoPageState();
}

class _ContactInfoPageState extends State<ContactInfoPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController contactNameCon = TextEditingController();
  TextEditingController phoneCon = TextEditingController();

  @override
  void initState() {
    if (hantarrBloc.state.foodCart.contactPerson != null &&
        hantarrBloc.state.foodCart.contactPerson.isNotEmpty) {
      contactNameCon.text = hantarrBloc.state.foodCart.contactPerson;
    } else {
      contactNameCon.text = hantarrBloc.state.hUser.firebaseUser?.displayName;
    }

    if (hantarrBloc.state.foodCart.phoneNum != null &&
        hantarrBloc.state.foodCart.phoneNum.isNotEmpty) {
      phoneCon.text = hantarrBloc.state.foodCart.phoneNum;
    } else {
      phoneCon.text = hantarrBloc.state.hUser.firebaseUser.phoneNumber;
    }

    contactNameCon.addListener(() {
      hantarrBloc.state.foodCart.contactPerson = contactNameCon.text;
    });

    phoneCon.addListener(() {
      hantarrBloc.state.foodCart.phoneNum = phoneCon.text;
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: TextField(
                        controller: contactNameCon,
                        style: themeBloc.state.textTheme.bodyText1.copyWith(),
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Contact Person",
                          labelStyle:
                              themeBloc.state.textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          errorStyle:
                              themeBloc.state.textTheme.subtitle2.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (val) {
                          hantarrBloc.state.foodCart.contactPerson = val;
                        },
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: TextField(
                        controller: phoneCon,
                        style: themeBloc.state.textTheme.bodyText1.copyWith(),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle:
                              themeBloc.state.textTheme.bodyText1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          errorStyle:
                              themeBloc.state.textTheme.subtitle2.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (val) {
                          hantarrBloc.state.foodCart.contactPerson = val;
                        },
                      ),
                    ),
                    ListTile(
                      onTap: () async {
                        await hantarrBloc.state.foodCart
                            .changeLocation(context);
                      },
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Deliver To",
                        style: themeBloc.state.textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${hantarrBloc.state.foodCart.address.replaceAll("%address%", "")}",
                        style: themeBloc.state.textTheme.subtitle1.copyWith(),
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          String jAddress = "";
                          String jBloc = "";
                          if (hantarrBloc.state.foodCart.address
                                  .split("%address%")
                                  .length >
                              1) {
                            jAddress = hantarrBloc.state.foodCart.address
                                .split("%address%")[1];
                            jBloc = hantarrBloc.state.foodCart.address
                                .split("%address%")[0];
                          } else {
                            jBloc = "";
                            jAddress = hantarrBloc.state.foodCart.address;
                          }

                          TextEditingController blockCon =
                              TextEditingController(text: jBloc);
                          TextEditingController addCon =
                              TextEditingController(text: jAddress);

                          var result = await showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder:
                                    (BuildContext context, StateSetter state) {
                                  return AlertDialog(
                                    title: Text("Edit Address"),
                                    content: Container(
                                      width: MediaQuery.of(context).size.width *
                                          .9,
                                      child: SingleChildScrollView(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              title: TextFormField(
                                                controller: blockCon,
                                                validator: (val) {
                                                  if (val
                                                      .replaceAll(" ", "")
                                                      .isEmpty) {
                                                    return "Cannot Empty";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText:
                                                      "Company / Building Name",
                                                  fillColor: Colors.white,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.blue,
                                                      width: .4,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: .4,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            ListTile(
                                              title: TextFormField(
                                                controller: addCon,
                                                maxLines: null,
                                                maxLengthEnforced: false,
                                                validator: (val) {
                                                  if (val
                                                      .replaceAll(" ", "")
                                                      .isEmpty) {
                                                    return "Cannot Empty";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Address",
                                                  fillColor: Colors.white,
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.blue,
                                                      width: .4,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.0),
                                                    borderSide: BorderSide(
                                                      color: Colors.red,
                                                      width: .4,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context, 'no');
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: Text(
                                          "Cancel",
                                          style: themeBloc
                                              .state.textTheme.button
                                              .copyWith(
                                            inherit: true,
                                            color: themeBloc.state.primaryColor,
                                          ),
                                        ),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context, 'yes');
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        color: themeBloc.state.primaryColor,
                                        child: Text(
                                          "OK",
                                          style: themeBloc
                                              .state.textTheme.button
                                              .copyWith(
                                            inherit: true,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                          if (result == "yes") {
                            debugPrint(addCon.text);
                            if (addCon.text.replaceAll(" ", "").isNotEmpty ||
                                blockCon.text.replaceAll(" ", "").isNotEmpty) {
                              String merged =
                                  "${blockCon.text}%address%${addCon.text}";
                              hantarrBloc.state.foodCart.address = merged;
                              await hantarrBloc.state.hUser
                                  .setLocalOnSelectedAddress(
                                      hantarrBloc.state.selectedLocation,
                                      merged);
                              hantarrBloc.add(Refresh());
                            }
                          }
                        },
                        icon: Icon(Icons.edit),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                Radius.circular(
                                  10.0,
                                ),
                              )),
                              insetPadding:
                                  EdgeInsets.all(ScreenUtil().setSp(10.0)),
                              child: Container(
                                width: mediaQ.width * .9,
                                child: DeliveryDateTimeOptionSelectionWidget(
                                  newRestaurant:
                                      hantarrBloc.state.foodCart.newRestaurant,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Delivery Time",
                        style: themeBloc.state.textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        hantarrBloc.state.foodCart.isPreorder
                            ? "${dateFormater(hantarrBloc.state.foodCart.preorderDateTime)}"
                            : "Deliver Now",
                        style: themeBloc.state.textTheme.bodyText1.copyWith(),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[850],
                        size: ScreenUtil().setSp(30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
