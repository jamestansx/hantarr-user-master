import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/root_page_repo/modules/address_module.dart';
import 'package:hantarr/root_page_repo/ui/address_page/address_widget.dart';
import 'package:hantarr/route_setting/route_settings.dart';

class AddressSelectUtil extends StatefulWidget {
  @override
  _AddressSelectUtilState createState() => _AddressSelectUtilState();
}

class _AddressSelectUtilState extends State<AddressSelectUtil> {
  TextEditingController addressFilCon = TextEditingController();
  List<Address> addressFiltered = [];

  @override
  void initState() {
    getAllAddress();
    addressFiltered = List.from(hantarrBloc.state.addressList);
    addressFilCon.addListener(() {
      if (addressFilCon.text.isNotEmpty) {
        addressFiltered = hantarrBloc.state.addressList
            .where((x) => x
                .toJson()
                .toString()
                .toLowerCase()
                .contains(addressFilCon.text.toLowerCase()))
            .toList();
      } else {
        addressFiltered.clear();
        addressFiltered.addAll(hantarrBloc.state.addressList);
      }
      setState(() {});
    });
    super.initState();
  }

  getAllAddress() async {
    var getAddresesReq = await AddressInterface().getListAddress();
    if (getAddresesReq["success"]) {
      addressFiltered = getAddresesReq['data'];
    } else {}
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Material(
          color: Colors.transparent,
          elevation: 0.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.search),
                title: TextFormField(
                  controller: addressFilCon,
                ),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      addressFilCon.text = "";
                    });
                  },
                  icon: Icon(
                    Icons.delete,
                  ),
                ),
              ),
              addressFiltered.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: addressFiltered.length,
                          itemBuilder: (BuildContext ctxt, int ss) {
                            return ListTile(
                              onTap: () {
                                Navigator.pop(context, addressFiltered[ss]);
                              },
                              title: AddressWidget(
                                address: addressFiltered[ss],
                                clickable: false,
                              ),
                            );
                          }),
                    )
                  : Container(
                      height: ScreenUtil().setHeight(150),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Address Not Found",
                          ),
                          SizedBox(
                            height: ScreenUtil().setHeight(15.0),
                          ),
                          FlatButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                manageAddressPage,
                              );
                              getAllAddress();
                              // Navigator.pop(context);
                            },
                            color: Colors.lightGreen[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: Text("Create New Address"),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}
