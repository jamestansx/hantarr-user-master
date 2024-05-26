import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';
import 'package:hantarr/route_setting/route_settings.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';

class BankInSlip extends StatefulWidget {
  BankInSlip();
  @override
  State<StatefulWidget> createState() => new BankInSlipState();
}

class BankInSlipState extends State<BankInSlip> {
  File _image;
  TextEditingController amountController = TextEditingController();

  @override
  // ignore: must_call_super
  void initState() {
    amountController.addListener(() {
      setState(() {
        print(amountController.text);
      });
    });
  }

  Future getImage() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
        bloc: hantarrBloc,
        builder: (context, state) {
          return Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(
                  color: Colors.black, //change your color here
                ),
                title: Text(
                  hantarrBloc.state.translation.text("Upload Bank-in Slip"),
                  style: TextStyle(
                      color: themeBloc.state.primaryColor,
                      fontSize: ScreenUtil().setSp(45)),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: CustomScrollView(slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      height: ScreenUtil().setHeight(300),
                      color: themeBloc.state.primaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setSp(20),
                                top: ScreenUtil().setSp(20)),
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              hantarrBloc.state.translation
                                  .text("E-Wallet Balance"),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScreenUtil().setSp(50)),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: ScreenUtil()
                                  .setSp(250, allowFontScalingSelf: true),
                              right: ScreenUtil()
                                  .setSp(250, allowFontScalingSelf: true),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0),
                              ),
                              // elevation: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                padding: EdgeInsets.all(ScreenUtil().setSp(20)),
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "MYR ${hantarrBloc.state.hUser.creditBalance.toStringAsFixed(2)}",
                                      style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: ScreenUtil().setSp(70),
                                              color: Colors.grey[50])),
                                      textAlign: TextAlign.center,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () async {
                                        loadingWidget(context);
                                        await hantarrBloc.state.hUser
                                            .getUserData();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "RM 0.00",
                            style:
                                TextStyle(color: themeBloc.state.primaryColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setSp(20)),
                      child: Text(
                          hantarrBloc.state.translation.text(
                              "Step 1: Please bank in to the following account."),
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenUtil().setSp(35),
                          ))),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setSp(35),
                        right: ScreenUtil().setSp(35),
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        elevation: 8,
                        child: Container(
                          padding: EdgeInsets.all(ScreenUtil().setSp(50)),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: ScreenUtil().setSp(20)),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      LineIcons.bank,
                                      size: ScreenUtil().setSp(50),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Text(
                                        hantarrBloc.state.translation
                                            .text("Bank Account Details"),
                                        style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: ScreenUtil().setSp(35),
                                        ))),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("3221236420",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.montserrat(
                                            textStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: ScreenUtil().setSp(40),
                                        ))),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: "3221236420"));
                                        showToast(
                                            "Account number copied to clipboard!",
                                            context: context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: themeBloc.state.primaryColor,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5))),
                                        child: Icon(
                                          Icons.content_copy,
                                          color: Colors.white,
                                          size: ScreenUtil().setSp(35),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text("PUBLIC BANK",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenUtil().setSp(40),
                                    ))),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text("Hantarr Delivery Sdn Bhd",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenUtil().setSp(40),
                                    ))),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(50)),
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setSp(20)),
                      child: Text(
                          hantarrBloc.state.translation
                              .text("Step 2: Please upload bank in slip."),
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenUtil().setSp(35),
                          ))),
                    ),
                    _image != null
                        ? Container(
                            height: ScreenUtil().setHeight(400),
                            child: Image.file(
                              File(_image.path),
                            ),
                          )
                        : Container(),
                    Container(
                      padding: EdgeInsets.only(
                        left:
                            ScreenUtil().setSp(250, allowFontScalingSelf: true),
                        right:
                            ScreenUtil().setSp(250, allowFontScalingSelf: true),
                      ),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                        ),
                        color: themeBloc.state.primaryColor,
                        onPressed: () async {
                          await getImage();
                        },
                        child: Text(
                          hantarrBloc.state.translation
                              .text("Upload Bank-in Slip"),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(50)),
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setSp(20)),
                      child: Text(
                          hantarrBloc.state.translation.text(
                              "Step 3: Enter amount that you have bank-in."),
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenUtil().setSp(35),
                          ))),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setSp(300),
                          right: ScreenUtil().setSp(300)),
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                        decoration: InputDecoration(
                          // prefixText: "MYR ",
                          border: new OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: new BorderSide(
                                  color: themeBloc.state.primaryColor)),
                          prefix: Text(
                            "MYR ",
                            style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(50)),
                    Container(
                      padding: EdgeInsets.all(ScreenUtil().setSp(20)),
                      child: Row(
                        children: <Widget>[
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    hantarrBloc.state.translation
                                        .text("Step 4: Submit bank in slip "),
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: ScreenUtil().setSp(35),
                                            color: Colors.black))),
                                Text(
                                    hantarrBloc.state.translation.text(
                                        "(Credit will be added once your bank-in slip is reviewed)"),
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: ScreenUtil().setSp(30),
                                            color: Colors.grey[600])))
                              ]),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left:
                            ScreenUtil().setSp(250, allowFontScalingSelf: true),
                        right:
                            ScreenUtil().setSp(250, allowFontScalingSelf: true),
                      ),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(15.0),
                        ),
                        color: Colors.black,
                        onPressed: (_image != null &&
                                amountController.text.isNotEmpty)
                            ? () async {
                                // loadingDialog(context);
                                loadingWidget(context);
                                String fileName = _image.path.split('/').last;
                                FormData formData = FormData.fromMap({
                                  "topup": {
                                    "uuid": hantarrBloc
                                        .state.hUser.firebaseUser.uid,
                                    "img": await MultipartFile.fromFile(
                                      _image.path,
                                      filename: fileName,
                                      contentType: MediaType("image", "*"),
                                    ),
                                    "amount": amountController.text
                                  }
                                });
                                var uploadReq = await hantarrBloc.state.hUser
                                    .uploadBankSlip(formData);
                                Navigator.pop(context);
                                if (uploadReq['success']) {
                                  Navigator.popUntil(context,
                                      ModalRoute.withName(newMainScreen));
                                  UniqueKey key = UniqueKey();
                                  BotToast.showWidget(
                                    key: key,
                                    toastBuilder: (_) => AlertDialog(
                                      title: Text(
                                        "Upload Bank Slip Success",
                                      ),
                                      // content: Text("Pending approval from operator"),
                                      actions: [
                                        FlatButton(
                                          onPressed: () {
                                            BotToast.remove(key);
                                          },
                                          child: Text("OK"),
                                        )
                                      ],
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("${uploadReq['reason']}"),
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
                              }
                            : null,
                        child: Text(
                          hantarrBloc.state.translation.text("Submit"),
                          style: TextStyle(
                              color: themeBloc.state.primaryColor,
                              fontSize: ScreenUtil().setSp(40)),
                        ),
                      ),
                    ),
                  ]),
                )
              ]));
        });
  }
}
