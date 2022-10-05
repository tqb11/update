import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_app_sale_06072022/common/bases/base_widget.dart';
import 'package:flutter_app_sale_06072022/presentation/features/product_detail/product_slider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app_sale_06072022/data/model/product.dart';
import 'package:flutter_app_sale_06072022/data/repositories/product_repository.dart';
import 'package:flutter_app_sale_06072022/presentation/features/product_detail/product_detail_bloc.dart';
import 'package:flutter_app_sale_06072022/presentation/features/product_detail/product_detail_event.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/api_constant.dart';
import '../../../common/constants/variable_constant.dart';
import '../../../data/datasources/remote/api_request.dart';
import '../../../data/model/cart.dart';
class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return PageContainer(
      appBar: AppBar(
        title: const Text("Chi tiết sản phẩm"),
        actions: [
          Consumer<ProductBloc>(
            builder: (context, bloc, child){
              return StreamBuilder<Cart>(
                  initialData: null,
                  stream: bloc.cartController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError || snapshot.data == null || snapshot.data?.products.isEmpty == true) {
                      return Container();
                    }
                    int count = snapshot.data?.products.length ?? 0;
                    return Container(
                      margin: EdgeInsets.only(right: 10, top: 10),
                      child: Badge(
                          badgeContent: Text(count.toString(), style: const TextStyle(color: Colors.white),),
                          child: IconButton(
                            icon: Icon(Icons.shopping_cart_outlined),
                            onPressed: () {
                              Navigator.pushNamed(context, VariableConstant.CART_ROUTE).then((cartUpdate){
                                if(cartUpdate != null){
                                  bloc.cartController.sink.add(cartUpdate as Cart);
                                }
                              });
                            },
                          )
                      ),
                    );
                  }
              );

            },
          )
        ],
      ),
      providers: [
        Provider(create: (context) => ApiRequest()),
        ProxyProvider<ApiRequest, ProductRepository>(
          update: (context, request, repository) {
            repository?.updateRequest(request);
            return repository ?? ProductRepository()
              ..updateRequest(request);
          },
        ),
        ProxyProvider<ProductRepository, ProductBloc>(
          update: (context, repository, bloc) {
            bloc?.updateProductRepository(repository);
            return bloc ?? ProductBloc()
              ..updateProductRepository(repository);
          },
        ),
      ],
      child: ProductContainer(),
    );
  }
}

class ProductContainer extends StatefulWidget {
  const ProductContainer({Key? key}) : super(key: key);

  @override
  State<ProductContainer> createState() => _ProductContainerState();
}

class _ProductContainerState extends State<ProductContainer> {
  Product? product;
  late ProductBloc _productBloc;
  String selectedImage = "";
  String image = "";

  @override
  void initState() {
    super.initState();
    _productBloc = context.read<ProductBloc>();
    _productBloc.eventSink.add(GetCartEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var dataReceive = ModalRoute.of(context)?.settings.arguments as Product;
    product = dataReceive;
    selectedImage = image = ApiConstant.BASE_URL + product!.img;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: getBody(),
    );
  }
  Widget getBody(){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child: Stack(
              children: <Widget>[
                FadeInDown(
                  child: ProductSlider(
                    items: product!.gallery,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30,),
          FadeInDown(
            delay: Duration(
                milliseconds: 350
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 25,right: 25),
              child: Text(
                product!.name,
                style: Theme.of(context).textTheme.headline5,

              ),
            ),
          ),
          SizedBox(height: 20,),
          FadeInDown(
            delay: Duration(
                milliseconds: 400
            ),
            child:  Padding(
              padding: const EdgeInsets.only(left: 25,right: 25),
              child: Text(
                  "Giá : ${NumberFormat("#,###", "en_US")
                      .format(product!.price)} đ",
                  style: const TextStyle(fontSize: 23, color: Colors.red)
              ),
            ),
          ),
          SizedBox(height: 20,),
          FadeInDown(
            delay: Duration(
                milliseconds: 400
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 25,right: 25),
              child: Text(
                product!.address,
                maxLines: 4,
                  style: const TextStyle(fontSize: 17, color: Colors.black)
              ),
            )
          ),
          SizedBox(height: 50,),
          FadeInDown(
            delay: Duration(
                milliseconds: 550),
            child: Padding(padding:
            EdgeInsets.only(left: 5,right: 5),
              child: ElevatedButton(
                onPressed: () {
                  _productBloc.eventSink.add(AddToCartEvent(id: product!.id));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  shadowColor: Colors.grey,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                    minimumSize: const Size.fromHeight(50), //////// HERE
                ),
                child: Text("Thêm vào giỏ",
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          SizedBox(height: 70,),
        ],
      ),
    );
  }
}

