import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/constants/global_variables.dart';
import 'package:social/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  final String shopCode;
  const HomeScreen({Key? key, required this.shopCode}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentHint = 'Search products';
  late Stream<String> _hintStream;
  Map<String, List> categoryProducts = {};
  Map<String, bool> isLoadingMap = {};

  // void navigateToSearchScreen() {
  //   Navigator.pushNamed(
  //     context,
  //     SearchScreen.routeName,
  //   );
  
  @override
  void initState() {
    final userProvider =
        Provider.of<UserProvider>(context, listen: false);
    super.initState();
    // logScreenVisit('HomeScreen');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/welcome.png'), // Local image
                    fit:
                        BoxFit.cover, // Adjust image fit (cover, contain, etc.)
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Ready in",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SemiBold',
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // const Text(
                                              //   "8 minutes",
                                              //   style: TextStyle(
                                              //     fontWeight: FontWeight.bold,
                                              //     fontSize: 25,
                                              //     fontFamily: 'SemiBold',
                                              //   ),
                                              // ),
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    const TextSpan(
                                                      text: '',
                                                      style: TextStyle(
                                                        fontFamily: 'ExtraBold',
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          'MIT Academy Of Engineering',
                                                      style: const TextStyle(
                                                        fontFamily: 'ExtraBold',
                                                        fontSize: 25,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 20,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: const Icon(
                                                        Icons.trending_up,
                                                        color: Colors.green,
                                                        size: 10,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5.0),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 3),
                                                      child: Text(
                                                        'High demand',
                                                        style: TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                            },
                                            child: Row(
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: ' HOME - ',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'SemiBold',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            'Dehu-Alandi Phata, Alandi - 431601 ',
                                                        style: const TextStyle(
                                                          fontFamily: 'Medium',
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const Icon(
                                                    Icons.arrow_drop_down)
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, '/account');
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 10),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.5),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                      offset:
                                                          const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                  size: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: GestureDetector(
                          // onTap: () => navigateToSearchScreen(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.black38, width: 1),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 0.1),
                                        blurRadius: 5,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          currentHint,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 17,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // if (Provider.of<ShopDetailsProvider>(context)
                      //         .shopDetails
                      //         ?.offerImages?['images'] ==
                      //     null)
                      // Center(
                      //   child: Container(
                      //     height: 150,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(20),
                      //     ),
                      //     clipBehavior: Clip.antiAlias,
                      //     child: Image.network(
                      //       'https://res.cloudinary.com/dybzzlqhv/image/upload/v1720875098/vegetables/swya6iwpohlynuq1r9td.gif',
                      //       fit: BoxFit.cover,
                      //     ),
                      //   ),
                      // ),


                      // SizedBox(height: 60,),
                      // const Text.rich(
                      //   TextSpan(
                      //     children: [
                      //       TextSpan(
                      //         text: 'Enjoy ',
                      //         style: TextStyle(
                      //             color: Colors.black,
                      //             fontSize: 20,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //       TextSpan(
                      //         text: 'Free Delivery!',
                      //         style: TextStyle(
                      //             color: GlobalVariables.greenColor,
                      //             fontSize: 20,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(height: 10,),
                      // const Text(
                      //   'ON YOUR FIRST ORDER',
                      //   style: TextStyle(
                      //       color: Colors.black,
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.bold),
                      // ),
                      const SizedBox(
                        height: 10,
                      ),
                      // if (Provider.of<ShopDetailsProvider>(context)
                      //         .shopDetails
                      //         ?.offerImages?['images'] !=
                      //     null)
                      //   CarouselSlider(
                      //     items: (Provider.of<ShopDetailsProvider>(context)
                      //             .shopDetails
                      //             ?.offerImages?['images'] as List<dynamic>?)
                      //         ?.map((imageUrl) => Builder(
                      //               builder: (BuildContext context) => Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     horizontal: 10),
                      //                 child: Container(
                      //                   width:
                      //                       MediaQuery.of(context).size.width,
                      //                   child: ClipRRect(
                      //                     borderRadius: BorderRadius.circular(
                      //                         15), // Set corner radius
                      //                     child: Image.network(
                      //                       imageUrl
                      //                           .toString(), // Convert to String explicitly
                      //                       fit: BoxFit.cover,
                      //                       height: 200,
                      //                       errorBuilder:
                      //                           (context, error, stackTrace) {
                      //                         return Container(
                      //                           height: 200,
                      //                           color: Colors.grey.shade200,
                      //                           child: const Center(
                      //                             child: Text(
                      //                                 'Failed to load image'),
                      //                           ),
                      //                         );
                      //                       },
                      //                       loadingBuilder: (context, child,
                      //                           loadingProgress) {
                      //                         if (loadingProgress == null)
                      //                           return child;
                      //                         return Container(
                      //                           height: 200,
                      //                           color: Colors.grey.shade100,
                      //                           child: const Center(
                      //                             child:
                      //                                 CircularProgressIndicator(),
                      //                           ),
                      //                         );
                      //                       },
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ))
                      //         .toList(),
                      //     options: CarouselOptions(
                      //       height: 200,
                      //       viewportFraction: 1.0,
                      //       enlargeCenterPage: false,
                      //       autoPlay: true,
                      //       autoPlayInterval: const Duration(seconds: 3),
                      //     ),
                      //   ),
                      // const SizedBox(
                      //   height: 20,
                      // )
                    ],
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 20,
              // ),

              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    

                  ],
                ),
              ),

              Container(
                height: 50,
                color: GlobalVariables.blueBackground,
              )

              // Orders(),
            ],
          ),
        ),
        // if (_isFloatingContainerOpen)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  // _isFloatingContainerOpen = false;
                  print('_isFloatingContainerOpen  clikced');
                });
              },
              child: Container(
                height: 133,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20), // Rounded upper corners
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(),
                  child: Column(children: [
                    // SlidingBannerWidget(),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 10, left: 10, top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 228, 229, 239),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.list,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // _isItemDetailsOpen = true;
                                // _openBottomSheet(context);
                              });
                            },
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.arrow_drop_up,
                                  color: GlobalVariables.greenColor,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(0),
                                  shadowColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                  backgroundColor: MaterialStateProperty.all(
                                      GlobalVariables.greenColor),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  // Navigator.pushNamed(
                                  //     context, '/user-cart-products');
                                  setState(() {
                                    // _isFloatingContainerOpen = false;
                                  });
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'Place order',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontFamily: 'SemiBold',
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        // if (!_isFloatingContainerOpen) const SlidingBannerWidget(),
      ]),
    );
  }
}
