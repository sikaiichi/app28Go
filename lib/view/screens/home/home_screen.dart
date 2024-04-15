import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/banner_controller.dart';
import 'package:efood_multivendor/controller/campaign_controller.dart';
import 'package:efood_multivendor/controller/category_controller.dart';
import 'package:efood_multivendor/controller/cuisine_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/location_controller.dart';
import 'package:efood_multivendor/controller/notification_controller.dart';
import 'package:efood_multivendor/controller/order_controller.dart';
import 'package:efood_multivendor/controller/product_controller.dart';
import 'package:efood_multivendor/controller/restaurant_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/user_controller.dart';
import 'package:efood_multivendor/data/model/response/config_model.dart';
import 'package:efood_multivendor/helper/responsive_helper.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/footer_view.dart';
import 'package:efood_multivendor/view/base/menu_drawer.dart';
import 'package:efood_multivendor/view/base/web_menu_bar.dart';
import 'package:efood_multivendor/view/screens/home/theme1/theme1_home_screen.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/all_restaurants.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/all_restaurant_filter_widget.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/enjoy_off_banner_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/new_on_stackfood_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/popular_foods_nearby_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/best_review_item_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/cuisine_view.dart';
//import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/order_again_view.dart';
//import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/location_banner_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/popular_restaurants_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/refer_banner_view.dart';
//import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/today_trends_view.dart';
import 'package:efood_multivendor/view/screens/home/web_home_screen.dart';
import 'package:efood_multivendor/view/screens/home/widget/bad_weather_widget.dart';
//import 'package:efood_multivendor/view/screens/home/widget/combined_widgets/what_on_your_mind_view.dart';
import 'package:efood_multivendor/view/screens/home/widget/banner_view.dart';
//import 'package:efood_multivendor/view/screens/booking/bookingscreen.dart';
import 'package:efood_multivendor/view/screens/restaurant/widget/customizable_space_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../base/custom_image.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static Future<void> loadData(bool reload) async {
    Get.find<BannerController>().getBannerList(reload);
    Get.find<CategoryController>().getCategoryList(reload);
    Get.find<CuisineController>().getCuisineList();
    if (Get.find<SplashController>().configModel!.popularRestaurant == 1) {
      Get.find<RestaurantController>()
          .getPopularRestaurantList(reload, 'all', false);
    }
    Get.find<CampaignController>().getItemCampaignList(reload);
    if (Get.find<SplashController>().configModel!.popularFood == 1) {
      Get.find<ProductController>().getPopularProductList(reload, 'all', false);
    }
    if (Get.find<SplashController>().configModel!.newRestaurant == 1) {
      Get.find<RestaurantController>()
          .getLatestRestaurantList(reload, 'all', false);
    }
    if (Get.find<SplashController>().configModel!.mostReviewedFoods == 1) {
      Get.find<ProductController>()
          .getReviewedProductList(reload, 'all', false);
    }
    Get.find<RestaurantController>().getRestaurantList(1, reload);
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<RestaurantController>()
          .getRecentlyViewedRestaurantList(reload, 'all', false);
      Get.find<RestaurantController>().getOrderAgainRestaurantList(reload);
      Get.find<UserController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<OrderController>().getRunningOrders(1, notify: false);
      Get.find<LocationController>().getAddressList();
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;
  bool _isLogin = false;

  @override
  void initState() {
    super.initState();

    _isLogin = Get.find<AuthController>().isLoggedIn();
    HomeScreen.loadData(false);
    initPopupAds();
  }

  Future<void> initPopupAds() async {
    var response = await Get.find<BannerController>().getAds();
    //String? title = response.title;
    String? image = response.image;
    String? campageUrl = _configModel!.baseUrls!.campaignImageUrl! + '/';
    if (image == null) {
      return null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            content: Container(
              width: double.infinity,
              padding: EdgeInsets.all(0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed(RouteHelper.getBasicCampaignRoute(response));
                        },
                        child: Stack(
                          children: [
                            CustomImage(
                                image: campageUrl + image,
                                fit: BoxFit.fitWidth
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                icon: Icon(Icons.close),
                                color: Colors.white,
                                iconSize: 30,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    //constraints: BoxConstraints(minHeight: 480),
                      ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double scrollPoint = 0.0;

    return GetBuilder<LocalizationController>(
        builder: (localizationController) {
      return Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        //backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          top: (Get.find<SplashController>().configModel!.theme == 2),
          child: RefreshIndicator(
            onRefresh: () async {
              await Get.find<BannerController>().getBannerList(true);
              await Get.find<CategoryController>().getCategoryList(true);
              await Get.find<CuisineController>().getCuisineList();
              await Get.find<RestaurantController>()
                  .getPopularRestaurantList(true, 'all', false);
              await Get.find<CampaignController>().getItemCampaignList(true);
              await Get.find<ProductController>()
                  .getPopularProductList(true, 'all', false);
              await Get.find<RestaurantController>()
                  .getLatestRestaurantList(true, 'all', false);
              await Get.find<ProductController>()
                  .getReviewedProductList(true, 'all', false);
              await Get.find<RestaurantController>().getRestaurantList(1, true);
              if (Get.find<AuthController>().isLoggedIn()) {
                await Get.find<UserController>().getUserInfo();
                await Get.find<NotificationController>()
                    .getNotificationList(true);
                await Get.find<RestaurantController>()
                    .getRecentlyViewedRestaurantList(true, 'all', false);
                await Get.find<RestaurantController>()
                    .getOrderAgainRestaurantList(true);
              }
            },
            child: ResponsiveHelper.isDesktop(context)
                ? WebHomeScreen(
                    scrollController: _scrollController,
                  )
                : (Get.find<SplashController>().configModel!.theme == 2)
                    ? Theme1HomeScreen(
                        scrollController: _scrollController,
                      )
                    : CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          /// App Bar
                          SliverAppBar(
                            pinned: true,
                            toolbarHeight: 10,
                            expandedHeight: ResponsiveHelper.isTab(context)
                                ? 72
                                : GetPlatform.isWeb
                                    ? 72
                                    : 50,
                            floating: false,
                            elevation: 0,
                            /*automaticallyImplyLeading: false,*/
                            backgroundColor: ResponsiveHelper.isDesktop(context)
                                ? Colors.transparent
                                : Theme.of(context).primaryColor,
                            flexibleSpace: FlexibleSpaceBar(
                                titlePadding: EdgeInsets.zero,
                                centerTitle: true,
                                expandedTitleScale: 1,
                                title: CustomizableSpaceBar(
                                  builder: (context, scrollingRate) {
                                    scrollPoint = scrollingRate;
                                    return Center(
                                        child: Container(
                                      width: Dimensions.webMaxWidth,
                                      color: Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.only(top: 30),
                                      child: Row(children: [
                                        Expanded(
                                            child: InkWell(
                                          onTap: () => Get.toNamed(RouteHelper
                                              .getAccessLocationRoute('home')),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions
                                                    .paddingSizeSmall),
                                            child:
                                                GetBuilder<LocationController>(
                                                    builder:
                                                        (locationController) {
                                              return Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(children: [
                                                      Icon(
                                                        locationController
                                                                    .getUserAddress()!
                                                                    .addressType ==
                                                                'home'
                                                            ? Icons.home_filled
                                                            : locationController
                                                                        .getUserAddress()!
                                                                        .addressType ==
                                                                    'office'
                                                                ? Icons.work
                                                                : Icons
                                                                    .location_on,
                                                        size: 20 -
                                                            (scrollingRate *
                                                                20),
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                      ),
                                                      Text(
                                                        locationController
                                                            .getUserAddress()!
                                                            .addressType!
                                                            .tr,
                                                        style: robotoMedium
                                                            .copyWith(
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                          fontSize: Dimensions
                                                                  .fontSizeDefault -
                                                              (scrollingRate *
                                                                  Dimensions
                                                                      .fontSizeDefault),
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ]),
                                                    SizedBox(
                                                        height: 5 -
                                                            (scrollingRate *
                                                                5)),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            locationController
                                                                .getUserAddress()!
                                                                .address!,
                                                            style: robotoRegular
                                                                .copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .cardColor,
                                                              fontSize: Dimensions
                                                                      .fontSizeSmall -
                                                                  (scrollingRate *
                                                                      Dimensions
                                                                          .fontSizeSmall),
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.arrow_drop_down,
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                          size: 16 -
                                                              (scrollingRate *
                                                                  16),
                                                        ),
                                                      ],
                                                    ),
                                                  ]);
                                            }),
                                          ),
                                        )),
                                        InkWell(
                                          child: GetBuilder<
                                                  NotificationController>(
                                              builder:
                                                  (notificationController) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .cardColor
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Dimensions
                                                              .radiusSmall)),
                                              padding: EdgeInsets.all(Dimensions
                                                      .paddingSizeExtraSmall -
                                                  (scrollPoint *
                                                      Dimensions
                                                          .paddingSizeExtraSmall)),
                                              child: Stack(children: [
                                                Icon(
                                                    Icons
                                                        .notifications_outlined,
                                                    size:
                                                        25 - (scrollPoint * 25),
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                notificationController
                                                        .hasNotification
                                                    ? Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: Container(
                                                          height: 10 -
                                                              (scrollPoint *
                                                                  10),
                                                          width: 10 -
                                                              (scrollPoint *
                                                                  10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor),
                                                          ),
                                                        ))
                                                    : const SizedBox(),
                                              ]),
                                            );
                                          }),
                                          onTap: () => Get.toNamed(RouteHelper
                                              .getNotificationRoute()),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.paddingSizeSmall),
                                      ]),
                                    ));
                                  },
                                )),
                            actions: const [SizedBox()],
                          ),
                          // Search Button
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverDelegate(
                                height: 60,
                                child: Center(
                                    child: Stack(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: Dimensions.webMaxWidth,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      child: Column(children: [
                                        Expanded(
                                            child: Container(
                                                color: Theme.of(context)
                                                    .primaryColor)),
                                        Expanded(
                                            child: Container(
                                                color: Colors.transparent)),
                                      ]),
                                    ),
                                    Positioned(
                                      left: 10,
                                      right: 10,
                                      top: 5,
                                      bottom: 5,
                                      child: InkWell(
                                        onTap: () => Get.toNamed(
                                            RouteHelper.getSearchRoute()),
                                        child: Container(
                                          transform: Matrix4.translationValues(
                                              0, -3, 0),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 5)
                                            ],
                                          ),
                                          child: Row(children: [
                                            Image.asset(Images.searchIcon,
                                                width: 25, height: 25),
                                            const SizedBox(
                                                width: Dimensions
                                                    .paddingSizeExtraSmall),
                                            Expanded(
                                                child: Text('are_you_hungry'.tr,
                                                    style:
                                                        robotoRegular.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeSmall,
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.6),
                                                    ))),
                                          ]),
                                        ),
                                      ),
                                    )
                                  ],
                                ))),
                          ),

                          SliverToBoxAdapter(
                            child: Center(
                                child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const BannerView(),
                                    const BadWeatherWidget(),

                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15), // Thêm lề 15px ở cả hai bên
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                _launchURL('https://zalo.me/3074263675374630155');
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(vertical: 5), // Thêm khoảng cách 5 đơn vị
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    'assets/image/banner.png', // Thay đổi đường dẫn và thông tin hình ảnh cần hiển thị
                                                    fit: BoxFit.cover, // Đảm bảo hình ảnh đầy đủ kích thước của widget
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 15), // Thêm lề 15px ở cả hai bên
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                _launchURL('https://zalo.me/3074263675374630155');
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(vertical: 5), // Thêm khoảng cách 5 đơn vị
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    'assets/image/banner1.png', // Thay đổi đường dẫn và thông tin hình ảnh cần hiển thị
                                                    fit: BoxFit.cover, // Đảm bảo hình ảnh đầy đủ kích thước của widget
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5), // Khoảng cách giữa hai hình ảnh
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                _launchURL('https://zalo.me/3074263675374630155');
                                              },
                                              child: Container(
                                                margin: EdgeInsets.symmetric(vertical: 5), // Thêm khoảng cách 5 đơn vị
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    'assets/image/banner-2.png', // Thay đổi đường dẫn và thông tin hình ảnh cần hiển thị
                                                    fit: BoxFit.cover, // Đảm bảo hình ảnh đầy đủ kích thước của widget
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    //LOẠI SẢN PHẨM
                                    const CuisineView(),
                                    _configModel!.popularRestaurant == 1
                                        ? const PopularRestaurantsView()
                                        : const SizedBox(),

                                    // sở thíchcủa bạn là gì?
                                    //const WhatOnYourMindView(),

                                    //TÌM GẦN BẠN (BẢN ĐỒ)
                                    //const TodayTrendsView(),
                                    //const LocationBannerView(),
                                    //_isLogin
                                    //    ? const OrderAgainView()
                                    //    : const SizedBox(),

                                    //ĐÁNH GIÁ SẢN PHẨM TỐT NHẤT
                                    _configModel!.popularFood == 1
                                        ? const BestReviewItemView(
                                            isPopular: false)
                                        : const SizedBox(),

                                    // BANNER GIỚI THIỆU
                                    const ReferBannerView(),

                                    _isLogin
                                        ? const PopularRestaurantsView(
                                            isRecentlyViewed: true)
                                        : const SizedBox(),

                                    // SẢN PHẨM NỔI BẬT Ở GẦN BẠN
                                    _configModel!.popularFood == 1
                                        ? const PopularFoodNearbyView()
                                        : const SizedBox(),

                                    //CỬA HÀNG MỚI TRÊN 28GO
                                    _configModel!.newRestaurant == 1
                                        ? const NewOnStackFoodView(
                                            isLatest: true)
                                        : const SizedBox(),
                                    //BANNER
                                    const PromotionalBannerView(),
                                  ]),
                            )),
                          ),

                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverDelegate(
                              height: 85,
                              child: const AllRestaurantFilterWidget(),
                            ),
                          ),

                          SliverToBoxAdapter(
                              child: Center(
                                  child: FooterView(
                            child: Padding(
                              padding: ResponsiveHelper.isDesktop(context)
                                  ? EdgeInsets.zero
                                  : const EdgeInsets.only(
                                      bottom: Dimensions.paddingSizeOverLarge),
                              child: AllRestaurants(
                                  scrollController: _scrollController),
                            ),
                          ))),
                        ],
                      ),
          ),
        ),
        // NÚT ĐẶT SHIP NHANH
        //floatingActionButton: BookingButton(),
        //floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        //backgroundColor: Colors.transparent,

      );
    });
  }
  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

}

// class BookingButton extends StatefulWidget {
//   @override
//   _BookingButtonState createState() => _BookingButtonState();
// }

// class _BookingButtonState extends State<BookingButton> {
//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: () {
//         // Navigate to BookingScreen when the button is tapped
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => BookingScreen()),
//         );
//       },
//       child: Image.asset(
//         Images.booking,
//         width: 80.0,
//         height: 80.0,
//       ),
//       // Sử dụng backgroundColor trong suốt
//       backgroundColor: Colors.transparent,
//       // Đặt elevation bằng 0 để loại bỏ bóng
//       elevation: 0,
//     );
//   }
// }

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 50});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}
