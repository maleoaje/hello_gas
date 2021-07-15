class RecomendedProductModel {
  late String item;
  late double itemPrice;
  late String itemimage;
  late String itemKg;
  late String itemCode;

  RecomendedProductModel(
      {required this.item,
      required this.itemCode,
      required this.itemPrice,
      required this.itemimage,
      required this.itemKg});

  RecomendedProductModel.fromJson(Map<String, dynamic> json) {
    item = json['item'];
    itemPrice = json['item_price'];
    itemimage = json['item_image'];
    itemKg = json['item_kg'];
    itemCode = json['item_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['item'] = this.item;
    data['item_price'] = this.itemPrice;
    data['item_image'] = this.itemimage;
    data['item_kg'] = this.itemKg;
    data['item_code'] = this.itemCode;
    return data;
  }
}
