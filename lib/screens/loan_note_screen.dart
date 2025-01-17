import 'package:flutter/material.dart';
import 'package:gsr/commons/common_methods.dart';
import 'package:gsr/models/invoice.dart';
import 'package:gsr/models/invoice_item.dart';
import 'package:gsr/providers/data_provider.dart';
import 'package:gsr/screens/route_card_screen.dart';
import 'package:gsr/services/database.dart';
import 'package:provider/provider.dart';

class LoanNoteScreen extends StatefulWidget {
  final String type;
  const LoanNoteScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<LoanNoteScreen> createState() => _LoanNoteScreenState();
}

class _LoanNoteScreenState extends State<LoanNoteScreen> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    const titleRowColor = Colors.white;
    return Scaffold(
      appBar: AppBar(
        title: Text(dataProvider.itemList[0].loanType == 2
            ? 'Recived Note'
            : 'Issued Note'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          waiting(context, body: 'Sending...');
          await createLoanInvoice(context);
          dataProvider.itemList.clear();
          pop(context);
          Navigator.pushNamed(
            context,
            RouteCardScreen.routeId,
          );
        },
        child: const Text('Done'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                dataProvider.itemList[0].loanType == 2
                    ? 'Loan Recived Note'
                    : 'Loan Issued Note',
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Text(
                            dataProvider.itemList[0].loanType == 2
                                ? 'Recived To:'
                                : 'Issued To:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            dataProvider.selectedCustomer!.businessName,
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
              ),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Date: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      date(DateTime.now(), format: 'dd.MM.yyyy'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      dataProvider.itemList[0].loanType == 2
                          ? 'Recived Note Num:'
                          : 'Issued Note Num:',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: FutureBuilder<String>(
                      future: loanInvoiceNumber(context),
                      builder: (context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          dataProvider.setCurrentInvoice(Invoice(
                            invoiceItems: dataProvider.itemList
                                .map(
                                  (addedItem) => InvoiceItem(
                                    item: addedItem.item,
                                    itemPrice:
                                        addedItem.item.hasSpecialPrice != null
                                            ? addedItem
                                                .item.hasSpecialPrice!.itemPrice
                                            : addedItem.item.salePrice,
                                    itemQty: addedItem.quantity,
                                    status: 1,
                                  ),
                                )
                                .toList(),
                            invoiceNo: snapshot.data!,
                            routecardId:
                                dataProvider.currentRouteCard!.routeCardId!,
                            amount: dataProvider.getTotalAmount(),
                            customerId:
                                dataProvider.selectedCustomer?.customerId ?? 0,
                            employeeId:
                                dataProvider.currentEmployee!.employeeId!,
                          ));
                          return Text(
                              (dataProvider.itemList[0].loanType == 2
                                      ? 'LO/R/'
                                      : 'LO/I/') +
                                  snapshot.data!.replaceAll('RCN', ''),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.clip);
                        } else {
                          return const Text(
                            'Generating...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Consumer<DataProvider>(
                  builder: (context, data, _) => Table(
                    border: TableBorder.symmetric(),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              '#',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: titleRowColor,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              'Item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: titleRowColor,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              'Qty',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: titleRowColor,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...data.itemList
                          .map(
                            (item) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    (data.itemList.indexOf(item) + 1)
                                        .toString(),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    item.item.itemName,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    num(item.quantity),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
