class OrderListModel {
  late int id;
  late String invoice;
  late String date;
  late String status;
  late String name;
  late String image;
  late double payment;

  OrderListModel({required this.id, required this.invoice, required this.date, required this.status, required this.name, required this.image, required this.payment});

  OrderListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    invoice = json['invoice'];
    date = json['date'];
    status = json['status'];
    name = json['name'];
    image = json['image'];
    payment = json['payment'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['invoice'] = this.invoice;
    data['date'] = this.date;
    data['status'] = this.status;
    data['name'] = this.name;
    data['image'] = this.image;
    data['payment'] = this.payment;
    return data;
  }
}