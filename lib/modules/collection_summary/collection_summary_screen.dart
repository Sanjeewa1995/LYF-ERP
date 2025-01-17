import 'package:flutter/material.dart';
import 'package:gsr/commons/common_consts.dart';
import 'package:gsr/commons/common_methods.dart';
import 'package:gsr/models/payment/payment_model.dart';
import 'package:gsr/providers/data_provider.dart';
import 'package:provider/provider.dart';

import 'collection_summary_view_model.dart';

class CollectionSummaryScreen extends StatefulWidget {
  static const routeId = 'O_SUMMARY';
  const CollectionSummaryScreen({Key? key}) : super(key: key);

  @override
  State<CollectionSummaryScreen> createState() =>
      _CollectionSummaryScreenState();
}

class _CollectionSummaryScreenState extends State<CollectionSummaryScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final collectionSummaryViewModel = CollectionSummaryViewModel();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection Summary'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: defaultPadding,
          child: Column(
            children: [
              const Text(
                'Cash',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 25.0,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              FutureBuilder<List<PaymentModel>>(
                future: collectionSummaryViewModel.getPayments(
                  context,
                  dataProvider.currentRouteCard!.routeCardId!,
                  1,
                ),
                builder: (context, AsyncSnapshot<List<PaymentModel>> snapshot) {
                  var cashTotal = 0.0;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final payments = snapshot.data!;
                    for (var payment in payments) {
                      cashTotal += payment.amount!;
                    }
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                children: [
                                  titleCell(
                                    'Receipt No',
                                    align: TextAlign.start,
                                  ),
                                  titleCell(
                                    'Customer Name',
                                    align: TextAlign.start,
                                  ),
                                  titleCell('Invoice No'),
                                  titleCell(
                                    'Amount',
                                    align: TextAlign.end,
                                  ),
                                ],
                              ),
                              ...payments.map(
                                (payment) => TableRow(
                                  children: [
                                    cell(
                                      payment.receiptNo ?? '',
                                      align: TextAlign.start,
                                    ),
                                    cell(
                                      payment.invoice?.customer?.businessName ??
                                          '',
                                      align: TextAlign.start,
                                    ),
                                    cell(payment.invoice!.invoiceNo.toString()),
                                    cell(
                                      price(payment.amount ?? 0),
                                      align: TextAlign.end,
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
                            text('Total cash:'),
                            const Spacer(),
                            text(price(cashTotal)),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                },
              ),
              const Divider(),
              const Text(
                'Cheque',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 25.0,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              FutureBuilder<List<PaymentModel>>(
                future: collectionSummaryViewModel.getPayments(
                  context,
                  dataProvider.currentRouteCard!.routeCardId!,
                  2,
                ),
                builder: (context, AsyncSnapshot<List<PaymentModel>> snapshot) {
                  var chequeTotal = 0.0;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final payments = snapshot.data!;
                    for (var payment in payments) {
                      chequeTotal += payment.amount!;
                    }
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                children: [
                                  titleCell(
                                    'Receipt No',
                                    align: TextAlign.start,
                                  ),
                                  titleCell(
                                    'Customer Name',
                                    align: TextAlign.start,
                                  ),
                                  titleCell('Invoice No'),
                                  titleCell('Cheque No'),
                                  titleCell(
                                    'Amount',
                                    align: TextAlign.end,
                                  ),
                                ],
                              ),
                              ...payments.map(
                                (payment) => TableRow(
                                  children: [
                                    cell(
                                      payment.receiptNo ?? '',
                                      align: TextAlign.start,
                                    ),
                                    cell(
                                      payment.invoice?.customer?.businessName ??
                                          '',
                                      align: TextAlign.start,
                                    ),
                                    cell(payment.invoice!.invoiceNo.toString()),
                                    cell(payment.chequeNo!),
                                    cell(
                                      price(payment.amount ?? 0),
                                      align: TextAlign.end,
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
                            text('Total cheque:'),
                            const Spacer(),
                            text(price(chequeTotal)),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                },
              ),
              const Divider(),
              const Text(
                'Voucher',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 25.0,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              FutureBuilder<List<PaymentModel>>(
                future: collectionSummaryViewModel.getPayments(
                  context,
                  dataProvider.currentRouteCard!.routeCardId!,
                  3,
                ),
                builder: (context, AsyncSnapshot<List<PaymentModel>> snapshot) {
                  var voucherTotal = 0.0;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final payments = snapshot.data!;
                    for (var payment in payments) {
                      voucherTotal += payment.amount ?? 0;
                    }
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Table(
                            defaultColumnWidth: const IntrinsicColumnWidth(),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                                children: [
                                  titleCell(
                                    'Receipt No',
                                    align: TextAlign.start,
                                  ),
                                  titleCell(
                                    'Customer Name',
                                    align: TextAlign.start,
                                  ),
                                  titleCell('Invoice No'),
                                  titleCell('Voucher code'),
                                  titleCell(
                                    'Amount',
                                    align: TextAlign.end,
                                  ),
                                ],
                              ),
                              ...payments
                                  .where((element) => element.amount != 0)
                                  .map(
                                    (payment) => TableRow(
                                      children: [
                                        cell(
                                          payment.receiptNo ?? '',
                                          align: TextAlign.start,
                                        ),
                                        cell(
                                          payment.invoice?.customer
                                                  ?.businessName ??
                                              '',
                                          align: TextAlign.start,
                                        ),
                                        cell(payment.invoice!.invoiceNo
                                            .toString()),
                                        cell(payment.chequeNo ?? '-'),
                                        cell(
                                          price(payment.amount ?? 0),
                                          align: TextAlign.end,
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
                            text('Total voucher:'),
                            const Spacer(),
                            text(price(voucherTotal)),
                          ],
                        ),
                        const Divider(
                          color: Colors.black,
                        ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: Text('No data'),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
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
  Widget text(String value) => Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
