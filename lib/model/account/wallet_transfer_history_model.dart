class WalletTransferModel {
  late String senderFullName;
  late String senderWalletId;
  late String senderPhone;
  late String senderEmail;
  late String receiverFullName;
  late String receiverWalletId;
  late String receiverPhone;
  late double amount;
  late String narration;
  late String transactionReference;
  late String transactionDate;
  late String transactionstatus;
  late String transactionType;

  WalletTransferModel({
    required this.amount,
    required this.narration,
    required this.receiverFullName,
    required this.receiverPhone,
    required this.receiverWalletId,
    required this.senderEmail,
    required this.senderFullName,
    required this.senderPhone,
    required this.senderWalletId,
    required this.transactionDate,
    required this.transactionReference,
    required this.transactionType,
    required this.transactionstatus,
  });

  WalletTransferModel.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    narration = json['narration'];
    receiverFullName = json['receiverFullName'];
    receiverPhone = json['receiverPhone'];
    receiverWalletId = json['receiverWalletId'];
    senderEmail = json['senderEmail'];
    senderFullName = json['senderFullName'];
    senderPhone = json['senderPhone'];
    senderWalletId = json['senderWalletId'];
    transactionDate = json['transactionDate'];
    transactionReference = json['transactionReference'];
    transactionType = json['transactionType'];
    transactionstatus = json['transactionstatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['narration'] = this.narration;
    data['receiverFullName'] = this.receiverFullName;
    data['receiverPhone'] = this.receiverPhone;
    data['receiverWalletId'] = this.receiverWalletId;
    data['senderEmail'] = this.senderEmail;
    data['senderFullName'] = this.senderFullName;
    data['senderPhone'] = this.senderPhone;
    data['senderWalletId'] = this.senderWalletId;
    data['transactionDate'] = this.transactionDate;
    data['transactionReference'] = this.transactionReference;
    data['transactionType'] = this.transactionType;
    data['transactionstatus'] = this.transactionstatus;

    return data;
  }
}
