import 'package:gsr/models/customer_deposite.dart';

import '../invoice/invoice_model.dart';

class IssuedInvoicePaidModel {
  final InvoiceModel issuedInvoice;
  final double paymentAmount;
  final double? creditAmount;
  final int? chequeId;

  IssuedInvoicePaidModel({
    required this.issuedInvoice,
    required this.paymentAmount,
    this.creditAmount,
    this.chequeId,
  });

  factory IssuedInvoicePaidModel.fromJson(Map<dynamic, dynamic> json) {
    return IssuedInvoicePaidModel(
      issuedInvoice: InvoiceModel.fromJson(json['issuedInvoice']),
      paymentAmount: json['paymentAmount'],
      creditAmount: json['creditAmount'],
      chequeId: json['chequeId'],
    );
  }

  Map<dynamic, dynamic> toJson() {
    final Map<dynamic, dynamic> data = {
      'issuedInvoice': issuedInvoice.toJsonWithId(),
      'paymentAmount': paymentAmount,
    };
    if (creditAmount != null) data['creditAmount'] = creditAmount;
    if (chequeId != null) data['chequeId'] = chequeId;
    return data;
  }
}

class IssuedDepositePaidModel {
  final CustomerDeposite issuedDeposite;
  final double paymentAmount;
  final double? depositeValue;

  IssuedDepositePaidModel({
    required this.issuedDeposite,
    required this.paymentAmount,
    this.depositeValue,
  });
}
