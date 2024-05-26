import 'package:hantarr/packageUrl.dart';

class HantarrBloc extends Bloc<HantarrEvent, HantarrState> {
  HantarrBloc(HantarrState initialState) : super(initialState);

  // @override
  // IOIState get initialState => IOIState.initial();

  @override
  Stream<HantarrState> mapEventToState(HantarrEvent event) async* {
    if (event is Refresh) {
      yield HantarrState.save(
        state.loginStatus,
        state.user,
        state.allRestaurants,
        state.zoneDetailList,
        state.allDeliveries,
        state.translation,
        state.serverTime,
        state.storage,
        state.fcm,
        state.flutterLocalNotificationsPlugin,
        state.notificationDetails,
        state.versionName,
        // new
        state.hUser,
        state.addressList,
        state.vehicleList,
        state.p2pHistoryList,
        state.p2pStatusCodes,
        state.topUpList,
        state.pendingOrders,
        state.p2pPendingOrders,
        // new food delivery repo
        state.newRestaurantList,
        state.selectedLocation,
        state.foodCart,
        state.currentLocation,
        state.pendingFoodOrders,
        state.app,
        state.allFoodOrders,
        state.p2pVehicleLoaded,
        state.allrestList,
        state.advertisements,
        state.showedAds,
        state.foodCheckoutPageLoading,
        state.foodCheckoutErrorMsg,
        state.streamController,
      );
    }
  }
}
