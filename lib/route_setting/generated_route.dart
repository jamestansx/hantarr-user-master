import 'package:flutter/material.dart';
import 'package:hantarr/accountPage.dart';
import 'package:hantarr/bankinSlip.dart';
import 'package:hantarr/fpxOnline.dart';
import 'package:hantarr/loginpage.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_food_delivery_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_menuItem_module.dart';
import 'package:hantarr/new_food_delivery_repo/modules/new_restaurant_module.dart';
import 'package:hantarr/new_food_delivery_repo/ui/apply_voucher_pages/apply_voucher_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/checkout_wizard_pages/checkout_wizard_root_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/food_delivery_checkout_pages/new_food_delivery_checkout_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/get_location_pages/get_location_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/hantarr_homepage_repo/views/hantarr_homepage.dart';
import 'package:hantarr/new_food_delivery_repo/ui/menu_items_pages/deep_link_menu_item_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/menu_items_pages/new_menu_items_page.dart';
import 'package:hantarr/new_food_delivery_repo/ui/new_foodhistory_pages/deep_link_food_detail_page/deep_link_food_detail_page.dart';
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
import 'package:hantarr/root_page_repo/ui/error_page.dart';
import 'package:hantarr/root_page_repo/ui/history_order_pages/history_order_page.dart';
import 'package:hantarr/root_page_repo/ui/new_mainscreen.dart';
import 'package:hantarr/root_page_repo/ui/phone_sigin_pages/phone_sign_in_page.dart';
import 'package:hantarr/root_page_repo/ui/root_page.dart';
import 'package:hantarr/root_page_repo/ui/top_up_pages/topuphistoryPage.dart';
import 'package:hantarr/route_setting/route_settings.dart';
// import 'package:hantarr/topUpSelection.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  final parts = settings.name.split('?');
  var arguments;
  try {
    arguments =
        parts.length == 2 ? Uri.splitQueryString(parts[1]) : settings.arguments;
  } catch (e) {
    arguments = settings.arguments;
  }
  RouteSettings routeSettings = RouteSettings(
    name: '${settings.name}',
    arguments: settings.arguments,
  );

  switch (parts[0]) {
    // -------------    root repo    -------------  //
    case initialRoute:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => NewRootPage());
    case hantarrHomepage:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => HantarrHomepage(),
      );
    case loginPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => LoginPage());
    case phoneLoginPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => PhoneSignInPage());
    case newMainScreen:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => NewMainScreen());
    case myAccountPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => AccountPage());
    case manageMyAccountPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => ProfilePage());
    case newAddressPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => NewNewAddressPage());
    case manageAddressPage:
      // return MaterialPageRoute(builder: (context) => ManageAddressPage());
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                arguments = {"id": null};
              }
              return ManageAddressPage(
                id: arguments['id'] != null
                    ? num.tryParse(arguments['id'].toString()).toInt()
                    : null,
              );
            } catch (e) {
              return ErrorPage();
            }
          });
    case searchPlacePage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => SearchPlacePage());
    case topupHistory:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => TopUpHistoryPage());
    // case topUpMethodSelectionPage:
    //   return MaterialPageRoute(builder: (context) => TopUpSelection());
    case uploadBankSlipPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => BankInSlip());
    case billPlzPage:
      Map<String, dynamic> payloadToPass =
          settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              return FpxOnline(minAmount: payloadToPass['amount'] as double);
            } catch (e) {
              return ErrorPage();
            }
          });
    case topUpWebView:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return TopUpWebViewPage(url: arguments as String);
            } catch (e) {
              return ErrorPage();
            }
          });
    case getlocationPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              // if (arguments == null) {
              //   throw ("Argument wrong for ${parts[0]}'s page");
              // }
              return GetLocationPage(getRest: arguments);
            } catch (e) {
              return ErrorPage();
            }
          });
    case pendingOrdersPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => HistoryOrderPage());
    // -------------    food repo    -------------  //
    case newRestaurantPage:
      Map<String, dynamic> payloadToPass =
          settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              return NewRestaurantPage(
                preoder: payloadToPass['is_preorder'],
                isRetail: payloadToPass['is_retail'],
              );
            } catch (e) {
              return ErrorPage();
            }
          });
    case searchRestaurantPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => SearchRestaurantPage());
    case newMenuItemListPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return NewMenuItemPage(newRestaurant: arguments as NewRestaurant);
            } catch (e) {
              return ErrorPage();
            }
          });
    case deepLinkMenuItemPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return DeepLinkMenuItemPage(
                  restID: num.tryParse(arguments['rest_id']).toInt());
            } catch (e) {
              return ErrorPage();
            }
          });
    case newMenuItemCustomizationPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return NewItemCustomizationPage(
                  newMenuItem: arguments as NewMenuItem);
            } catch (e) {
              return ErrorPage();
            }
          });
    case newFoodDeliveryCheckoutPage:
      return MaterialPageRoute(
          builder: (context) => NewFoodDeliveryCheckOutPage());
    case foodCheckoutWizardPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => CheckoutWizardRootPage());
    case applyVoucherPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => ApplyVouchePage());
    case foodDeliveriesHistoryPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => NewFoodHistoryPage());
    case foodDeliveryDetailPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return NewFoodDeliveryDetailsPage(
                  newFoodDelivery: arguments as NewFoodDelivery);
            } catch (e) {
              return ErrorPage();
            }
          });
    case foodDeepLinkOrder:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return DeepLinkFoodOrderDetailPage(
                  orderID: num.tryParse(arguments['order_id']).toInt());
            } catch (e) {
              return ErrorPage();
            }
          });
    // -------------     p2p repo    -------------  //
    case p2pHomepage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return P2pHomepage(p2pTransaction: arguments as P2pTransaction);
            } catch (e) {
              return ErrorPage();
            }
          });
    case p2pDetailPage:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            try {
              if (arguments == null) {
                throw ("Argument wrong for ${parts[0]}'s page");
              }
              return P2PTransactionDetailWidget(
                  p2pTransaction: arguments as P2pTransaction);
            } catch (e) {
              return ErrorPage();
            }
          });
    case p2psHistoryPage:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => P2PsHistoryPage());
    default:
      return MaterialPageRoute(
          settings: routeSettings, builder: (context) => ErrorPage());
  }
}
