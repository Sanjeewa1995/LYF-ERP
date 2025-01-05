import 'package:flutter/material.dart';
import 'package:gsr/commons/common_consts.dart';
import 'package:gsr/commons/common_methods.dart';
import 'package:gsr/models/added_item.dart';
import 'package:gsr/models/cheque.dart';
import 'package:gsr/models/customer.dart';
import 'package:gsr/models/issued_invoice.dart';
import 'package:gsr/models/issued_invoice_paid.dart';
import 'package:gsr/models/item.dart';
import 'package:gsr/providers/data_provider.dart';
import 'package:provider/provider.dart';

import '../modules/print/print_invoice_view.dart';

class ViewIssuedInvoiceScreen extends StatelessWidget {
  static const routeId = 'ISSUED_INVOICE';
  final IssuedInvoice issuedInvoice;
  const ViewIssuedInvoiceScreen({Key? key, required this.issuedInvoice})
      : super(key: key);

  _totalPayment() {
    var total = 0.0;
    for (var payment in issuedInvoice.payments) {
      total += payment.amount;
    }
    return total;
  }

  dynamic _balance() {
    if (issuedInvoice.previousPayments!.isNotEmpty) {
      return issuedInvoice.amount +
          issuedInvoice.previousPayments!
              .map((e) => e.value)
              .toList()
              .reduce((value, element) => value + element) -
          _totalPayment();
    } else {
      return issuedInvoice.amount - _totalPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: defaultBackgroundColor,
      appBar: AppBar(
        title: Text(issuedInvoice.invoiceNo),
        actions: [
          IconButton(
              onPressed: () {
                final cash = issuedInvoice.payments
                        .where((p) => p.paymentMethod == 1)
                        .isNotEmpty
                    ? issuedInvoice.payments
                        .where((p) => p.paymentMethod == 1)
                        .toList()
                        .first
                        .amount
                    : 0.0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrintInvoiceView(
                      invoiceNo: issuedInvoice.invoiceNo,
                      rn: issuedInvoice.payments.isNotEmpty
                          ? issuedInvoice.payments[0].receiptNo
                          : '',
                      cash: cash,
                      balance: -(_balance()),
                      issuedInvoice: issuedInvoice,
                      items: issuedInvoice.items
                          .map((e) => AddedItem(
                              item: Item(
                                  id: 0,
                                  itemRegNo: '',
                                  itemName: e.item?.itemName ?? '',
                                  costPrice: 0,
                                  salePrice: e.itemPrice,
                                  openingQty: 0,
                                  vendorId: 0,
                                  priceLevelId: 0,
                                  itemTypeId: 0,
                                  stockId: 0,
                                  costAccId: 0,
                                  incomeAccId: 0,
                                  isNew: 0,
                                  status: 0),
                              quantity: e.itemQty,
                              maxQuantity: 0))
                          .toList(),
                      cheques: issuedInvoice.payments
                          .where((e) => e.paymentMethod == 2)
                          .map((c) => Cheque(
                              chequeNumber: c.chequeNo ?? '',
                              chequeAmount: c.amount))
                          .toList(),
                      previousPayments: (issuedInvoice.previousPayments ?? [])
                          .map(
                            (e) => IssuedInvoicePaid(
                              paymentAmount: e.value,
                              issuedInvoice: IssuedInvoice(
                                invoiceId: 0,
                                invoiceNo:
                                    e.creditInvoice?.invoiceNo.toString() ?? '',
                                routecardId: 0,
                                amount: e.value,
                                customer: Customer(
                                    customerId: 0,
                                    registrationId: '',
                                    businessName: '',
                                    regDate: '',
                                    ownerName: '',
                                    address: '',
                                    contactNumber: '',
                                    homeDelivery: '',
                                    depositBalance: 0,
                                    paymentMethodId: 0,
                                    customerTypeId: 0,
                                    priceLevelId: 0,
                                    routeId: 0,
                                    employeeId: 0,
                                    status: 0),
                                creditValue: 0,
                                employeeId: 0,
                                status: 0,
                                items: [],
                                payments: [],
                                previousPayments: [],
                                createdAt: DateTime.now(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
              icon: Icon(Icons.print))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const Text(
                'Invoice',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 25.0,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            'Date:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            date(issuedInvoice.createdAt, format: 'dd.MM.yyyy'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            'Customer:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            issuedInvoice.customer.businessName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                'Customer VAT ID:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                issuedInvoice.customer.customerVat ?? '-',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            'Invoice No:',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            issuedInvoice.invoiceNo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              SizedBox(
                width: double.infinity,
                child: Consumer<DataProvider>(
                  builder: (context, data, _) => Table(
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                        ),
                        children: [
                          titleCell(
                            'Item',
                            align: TextAlign.start,
                          ),
                          titleCell(
                            'Qty',
                            align: TextAlign.center,
                          ),
                          titleCell(
                            'Unit price',
                            align: TextAlign.center,
                          ),
                          titleCell(
                            'Amount',
                            align: TextAlign.end,
                          ),
                        ],
                      ),
                      ...issuedInvoice.items
                          .map(
                            (item) => TableRow(
                              children: [
                                cell(
                                  item.item?.itemName ?? '',
                                  align: TextAlign.start,
                                ),
                                cell(
                                  num(item.itemQty),
                                  align: TextAlign.center,
                                ),
                                cell(
                                  formatPrice(item.itemPrice),
                                  align: TextAlign.center,
                                ),
                                cell(
                                  formatPrice(item.itemPrice * item.itemQty),
                                  align: TextAlign.end,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    text('Sub Total'),
                    const Spacer(),
                    text(formatPrice(issuedInvoice.subTotal ?? 0)),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    text('VAT 18%'),
                    const Spacer(),
                    text(formatPrice(
                      issuedInvoice.vat ?? 0,
                    )),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    text('Grand Total:'),
                    const Spacer(),
                    text(formatPrice(
                      issuedInvoice.amount,
                    )),
                  ],
                ),
              ),
              const Divider(
                color: Colors.black,
              ),
              if (issuedInvoice.previousPayments!.isNotEmpty)
                Column(children: [
                  const Text(
                    'Previous Payments',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 25.0,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Table(
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          children: [
                            titleCell(
                              '#',
                              align: TextAlign.start,
                            ),
                            titleCell(
                              'Date',
                              align: TextAlign.center,
                            ),
                            titleCell(
                              'Invoice No:',
                              align: TextAlign.center,
                            ),
                            titleCell(
                              'Payment',
                              align: TextAlign.center,
                            ),
                          ],
                        ),
                        ...issuedInvoice.previousPayments!.map(
                          (invoice) => TableRow(
                            children: [
                              cell(
                                (issuedInvoice.previousPayments!
                                            .indexOf(invoice) +
                                        1)
                                    .toString(),
                                align: TextAlign.start,
                              ),
                              cell(
                                date(invoice.creditInvoice!.createdAt!,
                                    format: 'dd-MM-yyyy'),
                                align: TextAlign.center,
                              ),
                              cell(invoice.creditInvoice!.invoiceNo),
                              cell(
                                formatPrice(invoice.value)
                                    .replaceAll('Rs.', ''),
                                align: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                  ),
                  Row(
                    children: [
                      text('Total Previous Payment'),
                      const Spacer(),
                      text(formatPrice(issuedInvoice.previousPayments!
                          .map((e) => e.value)
                          .toList()
                          .reduce((value, element) => value + element))),
                    ],
                  ),
                ]),
              const Divider(),
              issuedInvoice.payments.isNotEmpty
                  ? Column(
                      children: [
                        const Text(
                          'Receipt',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 25.0,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  text('Receipt No:'),
                                  text(issuedInvoice.payments[0].receiptNo),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Table(
                            children: [
                              TableRow(
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                ),
                                children: [
                                  titleCell(
                                    'Method',
                                    align: TextAlign.start,
                                  ),
                                  titleCell(
                                    'Check No:',
                                    align: TextAlign.center,
                                  ),
                                  titleCell(
                                    'Amount (Rs)',
                                    align: TextAlign.end,
                                  ),
                                ],
                              ),
                              ...issuedInvoice.payments.map(
                                (payment) => TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        payment.paymentMethod == 1
                                            ? 'Cash'
                                            : payment.paymentMethod == 2
                                                ? 'Cheque'
                                                : 'Voucher',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        payment.chequeNo ?? '-',
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Text(
                                        formatPrice(payment.amount)
                                            .replaceAll('Rs.', ''),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  text(
                                    'Total payment',
                                    align: TextAlign.end,
                                  ),
                                  const Spacer(),
                                  text(
                                    formatPrice(_totalPayment()),
                                    align: TextAlign.end,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  text(
                                    'Balance',
                                    align: TextAlign.end,
                                  ),
                                  const Spacer(),
                                  if (issuedInvoice
                                      .previousPayments!.isNotEmpty)
                                    text(
                                      formatPrice(issuedInvoice.amount +
                                          issuedInvoice.previousPayments!
                                              .map((e) => e.value)
                                              .toList()
                                              .reduce((value, element) =>
                                                  value + element) -
                                          _totalPayment()),
                                      align: TextAlign.end,
                                    ),
                                  if (issuedInvoice.previousPayments!.isEmpty)
                                    text(
                                      formatPrice(issuedInvoice.amount -
                                          _totalPayment()),
                                      align: TextAlign.end,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                        const Divider(),
                      ],
                    )
                  : dummy,
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  TableCell cell(String value, {TextAlign? align}) => TableCell(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            value,
            textAlign: align ?? TextAlign.center,
          ),
        ),
      );
  TableCell titleCell(String value, {TextAlign? align}) => TableCell(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            value,
            textAlign: align ?? TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
  Widget text(String value, {TextAlign? align}) => Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          value,
          textAlign: align ?? TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
