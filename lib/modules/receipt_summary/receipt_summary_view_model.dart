import 'package:flutter/material.dart';
import 'package:gsr/models/invoice/invoice_model.dart';
import 'package:gsr/models/payment_method/payment_method.dart';
import 'package:gsr/models/receipt/receipt_print_model.dart';

import '../../commons/common_methods.dart';
import '../../models/credit_payment/credit_payment_model.dart';

class ReceiptSummaryViewModel {
  ReceiptModel getReceiptModel(
      BuildContext context,
      List<CreditPaymentModel> payments,
      CreditPaymentModel creditPaymentModel) {
    return ReceiptModel(
      employee: creditPaymentModel.paymentInvoice?.employee?.firstName,
      billingDate: creditPaymentModel.paymentInvoice?.createdAt,
      totalPreviousPayment: payments
          .map((p) => p.value)
          .reduce((value, element) => value! + element!) as double,
      totalPayment: payments
          .map((e) => e.value)
          .toList()
          .reduce((value, current) => value! + current!) as double,
      createdAt: payments[0].createdAt == null
          ? '-'
          : date(payments[0].createdAt!, format: 'dd.MM.yyyy'),
      receiptNo: payments[0].receiptNo ?? '',
      invoicess: payments
          .map(
            (i) => InvoiceModel(
              invoiceNo: i.creditInvoice!.invoiceNo,
              paymentAmount: i.value,
              createdAt: i.creditInvoice!.createdAt,
            ),
          )
          .toList(),
      paymentMethods: payments[0]
          .payments!
          .map(
            (p) => PaymentMethodModel(
              name: p.paymentMethod == 1
                  ? 'Cash'
                  : p.paymentMethod == 2
                      ? 'Cheque'
                      : 'Voucher',
              amount: price(p.amount ?? 0).replaceAll('Rs.', ''),
              chequeNu: p.chequeNo ?? '-',
            ),
          )
          .toList(),
    );
  }
}
