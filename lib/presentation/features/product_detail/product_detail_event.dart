import 'package:flutter_app_sale_06072022/common/bases/base_event.dart';

class GetCartEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends BaseEvent {
  String id;

  AddToCartEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
class CartSuccessEvent extends BaseEvent {
  String message;

  CartSuccessEvent({required this.message});

  @override
  List<Object?> get props => [message];
}