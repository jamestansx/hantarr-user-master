import 'package:flutter/material.dart';
import 'package:hantarr/accountPage.dart';
import 'package:hantarr/bankinSlip.dart';
import 'package:hantarr/fpxOnline.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/apply_voucher_pages/apply_voucher_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/checkout_wizard_pages/checkout_wizard_root_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/food_delivery_checkout_pages/new_food_delivery_checkout_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/get_location_pages/get_location_page.dart';
import 'package:hantarr/loginpage.dart';
import 'package:hantarr/new_food_delivery_repo/ui/menu_items_pages/new_menu_items_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/new_food_delivery_details_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/new_food_history_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_item_customization_pages/new_item_customization_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/restaurant_pages/new_restaurants_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/restaurant_pages/search_restaurant_page.dart';
import 'package:hantarr/p2p_repo/p2p_modules/p2pTransaction_module.dart';
import 'package:hantarr/p2p_repo/pages/history/p2pS_history_page.dart';
import 'package:hantarr/p2p_repo/pages/homepage/p2p_homepage.dart';
import 'package:hantarr/p2p_repo/pages/homepage/p2p_transaction_detail_widget.dart';
import 'package:hantarr/profilePage.dart';
import 'package:hantarr/root_page_repo/ui/address_page/manage_address_page.dart';
import 'package:hantarr/root_page_repo/ui/address_page/new_addresses_page.dart';
import 'package:hantarr/root_page_repo/ui/address_page/search_place_page.dart';
import 'package:hantarr/root_page_repo/ui/custom_web_view_pages/top_up_web_view_page.dart';
import 'package:hantarr/root_page_repo/ui/history_order_pages/history_order_page.dart';
import 'package:hantarr/root_page_repo/ui/new_mainscreen.dart';
import 'package:hantarr/root_page_repo/ui/phone_sigin_pages/phone_sign_in_page.dart';
import 'package:hantarr/root_page_repo/ui/root_page.dart';
import 'package:hantarr/route_setting/route_settings.dart';
// import 'package:hantarr/topUpSelection.dart';
import 'package:hantarr/root_page_repo/ui/top_up_pages/topuphistoryPage.dart';

Map<String, Widget Function(BuildContext context)> get routes {
  return {
    // init
    initialRoute: (context) => NewRootPage(),
    loginPage: (context) => LoginPage(),
    phoneLoginPage: (context) => PhoneSignInPage(),
    // account
    myAccountPage: (context) => AccountPage(),
    manageMyAccountPage: (context) => ProfilePage(),
    // top up
    topupHistory: (context) => TopUpHistoryPage(),
    // topUpMethodSelectionPage: (context) => TopUpSelection(),
    uploadBankSlipPage: (context) => BankInSlip(),
    billPlzPage: (context) {
      double minAcount;
      try {
        minAcount = ModalRoute.of(context).settings.arguments as double;
      } catch (e) {
        minAcount = 50.0;
      }
      return FpxOnline(minAmount: minAcount);
    },
    topUpWebView: (context) => TopUpWebViewPage(
          url: ModalRoute.of(context).settings.arguments as String,
        ),
    // new mainscreen
    newMainScreen: (context) => NewMainScreen(),
    // new address
    newAddressPage: (context) => NewNewAddressPage(),
    manageAddressPage: (context) => ManageAddressPage(
          id: ModalRoute.of(context).settings.arguments,
        ),
    // search places
    searchPlacePage: (context) => SearchPlacePage(),
    // p2p
    p2pHomepage: (context) {
      P2pTransaction p2pTransaction;
      if (ModalRoute.of(context).settings.arguments != null) {
        p2pTransaction =
            ModalRoute.of(context).settings.arguments as P2pTransaction;
      } else {
        p2pTransaction = P2pTransaction.initClass();
      }

      return P2pHomepage(p2pTransaction: p2pTransaction);
    },
    p2pDetailPage: (context) {
      P2pTransaction p2pTransaction;
      if (ModalRoute.of(context).settings.arguments != null) {
        p2pTransaction =
            ModalRoute.of(context).settings.arguments as P2pTransaction;
      } else {
        throw ("parameter no exist");
      }
      return P2PTransactionDetailWidget(p2pTransaction: p2pTransaction);
    },
    //  p2ps history page
    p2psHistoryPage: (context) => P2PsHistoryPage(),
    // homepage
    // new restaurant repo
    newRestaurantPage: (context) {
      if (ModalRoute.of(context).settings.arguments != null) {
        return NewRestaurantPage(
          preoder: ModalRoute.of(context).settings.arguments as bool,
        );
      } else {
        return NewRestaurantPage(
          preoder: false,
        );
      }
    },
    searchRestaurantPage: (context) => SearchRestaurantPage(),
    // menu items page list
    newMenuItemListPage: (context) {
      if (ModalRoute.of(context).settings.arguments != null) {
        return NewMenuItemPage(
          newRestaurant:
              ModalRoute.of(context).settings.arguments as NewRestaurant,
        );
      } else {
        throw ("arguments missing");
      }
    },
    // new menu item customization page
    newMenuItemCustomizationPage: (context) {
      if (ModalRoute.of(context).settings.arguments != null) {
        return NewItemCustomizationPage(
          newMenuItem: ModalRoute.of(context).settings.arguments as NewMenuItem,
        );
      } else {
        throw ("arguments missing");
      }
    },
    // new food checkout page
    newFoodDeliveryCheckoutPage: (context) => NewFoodDeliveryCheckOutPage(),
    // food checkout wizard page
    foodCheckoutWizardPage: (context) => CheckoutWizardRootPage(),
    // apply voucher page
    applyVoucherPage: (context) => ApplyVouchePage(),
    // get location page
    getlocationPage: (context) => GetLocationPage(getRest: null),
    // food deliveries page
    foodDeliveriesHistoryPage: (context) => NewFoodHistoryPage(),
    foodDeliveryDetailPage: (context) {
      if (ModalRoute.of(context).settings.arguments != null) {
        return NewFoodDeliveryDetailsPage(
          newFoodDelivery:
              ModalRoute.of(context).settings.arguments as NewFoodDelivery,
        );
      } else {
        throw ("arguments missing");
      }
    },
    pendingOrdersPage: (context) => HistoryOrderPage(),
  };
}
