import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:hantarr/bloc/hantarrBloc.dart';
import 'package:hantarr/bloc/hantarrState.dart';
import 'package:hantarr/global.dart';

class ApplyVouchePage extends StatefulWidget {
  @override
  _ApplyVouchePageState createState() => _ApplyVouchePageState();
}

class _ApplyVouchePageState extends State<ApplyVouchePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController voucherCon = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> validateVoucher() async {
    // var validateVoucher = await
    return "";
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQ = MediaQuery.of(context).size;
    ScreenUtil.init(context);
    return BlocBuilder<HantarrBloc, HantarrState>(
      bloc: hantarrBloc,
      builder: (BuildContext context, HantarrState state) {
        return Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  tooltip: "Back to checkout page",
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Text(
                "Apply voucher",
                style: themeBloc.state.textTheme.headline6.copyWith(
                  color: Colors.white,
                  fontSize: ScreenUtil().setSp(35.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView(
                padding: EdgeInsets.all(ScreenUtil().setSp(15.0)),
                children: [
                  Container(
                    width: mediaQ.width * .9,
                    child: TextFormField(
                      controller: voucherCon,
                      decoration: InputDecoration(
                        labelText: "Voucher Code",
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: themeBloc.state.primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val.replaceAll(" ", "").isEmpty) {
                          return "Cannot Empty";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(30),
                  ),
                  FlatButton(
                    onPressed: () async {
                      await hantarrBloc.state.foodCart
                          .applyVoucher(voucherCon.text, context);
                    },
                    color: themeBloc.state.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      "Apply",
                      style: themeBloc.state.textTheme.button.copyWith(
                        fontSize: ScreenUtil().setSp(45.0),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
