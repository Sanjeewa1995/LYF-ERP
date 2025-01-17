import 'package:flutter/material.dart';
import 'package:gsr/commons/common_consts.dart';
import 'package:gsr/commons/common_methods.dart';
import 'package:gsr/models/cheque/cheque.dart';
import 'package:gsr/models/voucher.dart';
import 'package:gsr/modules/invoice/invoice_provider.dart';
import 'package:gsr/providers/data_provider.dart';
import 'package:gsr/modules/view_receipt/invoice_receipt_screen.dart';
import 'package:gsr/widgets/cheque_card.dart';
import 'package:gsr/widgets/cheque_form.dart';
import 'package:gsr/widgets/detail_card.dart';
import 'package:provider/provider.dart';

import '../providers/hive_db_provider.dart';
import '../services/voucher_service.dart';

class AddPaymentScreen extends StatefulWidget {
  static const routeId = 'PAYMENT';
  final String? type;
  final bool? isManual;

  const AddPaymentScreen({Key? key, this.type, this.isManual})
      : super(key: key);

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final chequeScrollController = ScrollController();
  final cashController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final hiveDBProvider = Provider.of<HiveDBProvider>(context, listen: false);
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    // final Respo invoiceRes = (ModalRoute.of(context)!.settings.arguments
    //     as Map<String, dynamic>)['invoiceRes'];
    final isManual = (ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>)['isManual'];
    final voucherService = VoucherService();
    return Scaffold(
      backgroundColor: defaultBackgroundColor,
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.type == 'previous') {
            if (cashController.text.trim().isEmpty &&
                dataProvider.chequeList.isEmpty) {
              return;
            }
          }
          Navigator.pushNamed(context, InvoiceReceiptScreen.routeId,
              arguments: {
                'cash': doub(cashController.text.trim().isEmpty
                    ? '0.0'
                    : cashController.text.trim().replaceAll(',', '')),
                // 'invoiceRes': invoiceRes,
                'isManual': isManual
              });
        },
        child: const Icon(
          Icons.arrow_forward_rounded,
          size: 40,
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
          child: Padding(
            padding: defaultPadding,
            child: Column(
              children: [
                DetailCard(
                  detailKey: 'Date',
                  detailvalue: date(DateTime.now(), format: 'dd.MM.yyyy'),
                ),
                DetailCard(
                  detailKey: 'Customer name',
                  detailvalue: dataProvider.selectedCustomer!.businessName,
                ),
                DetailCard(
                  detailKey: 'Invoice No',
                  detailvalue: invoiceProvider.invoiceNu ?? '',
                ),
                DetailCard(
                  detailKey: 'Total amount',
                  detailvalue: price(dataProvider.getTotalAmount() +
                      dataProvider.nonVatItemTotal +
                      (dataProvider.getTotalAmount() / 100) * 18),
                ),
                const Divider(),
                TextFormField(
                  controller: cashController,
                  // inputFormatters: [
                  //   ThousandsFormatter(
                  //     allowFraction: true,
                  //   ),
                  // ],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(fontSize: 18.0),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelText: 'Cash',
                    prefixText: 'Rs. ',
                  ),
                ),
                const Divider(),
                SizedBox(
                  width: double.infinity,
                  height: 60.0,
                  child: OutlinedButton(
                    onPressed: () {
                      final chequeNumberController = TextEditingController();
                      final chequeAmountController = TextEditingController();
                      final formKey = GlobalKey<FormState>();
                      confirm(
                        context,
                        title: 'New Cheque',
                        body: ChequeForm(
                          chequeNumberController: chequeNumberController,
                          chequeAmountController: chequeAmountController,
                          formKey: formKey,
                        ),
                        onConfirm: () {
                          if (formKey.currentState!.validate()) {
                            dataProvider.addCheque(
                              ChequeModel(
                                chequeNumber:
                                    chequeNumberController.text.trim(),
                                chequeAmount: doub(chequeAmountController.text
                                    .replaceAll(',', '')),
                              ),
                            );
                            chequeNumberController.clear();
                            chequeAmountController.clear();
                            return;
                          }
                        },
                        confirmText: 'Add',
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blue[800]),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: const Text(
                      'New cheque',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Consumer<DataProvider>(
                  builder: (context, data, _) => data.chequeList.isNotEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          height: 300.0,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ListView.separated(
                              itemCount: data.chequeList.length,
                              controller: chequeScrollController,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 5.0,
                              ),
                              itemBuilder: (context, index) {
                                final cheque = data.chequeList[index];
                                return ChequeCard(
                                  chequeNumber: cheque.chequeNumber,
                                  chequeAmount: cheque.chequeAmount,
                                  trailing: IconButton(
                                    splashRadius: 20.0,
                                    onPressed: () => data.removeCheque(cheque),
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      color: defaultErrorColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : dummy,
                ),
                const Divider(),
                if (hiveDBProvider.isInternetConnected)
                  FutureBuilder<List<VoucherModel>>(
                    future: voucherService.getVouchers(context),
                    builder: (context,
                            AsyncSnapshot<List<VoucherModel>> snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? const CircularProgressIndicator()
                            : DropdownButtonFormField<VoucherModel>(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  labelText: snapshot.hasData &&
                                          snapshot.data!.isNotEmpty
                                      ? 'Select voucher'
                                      : 'No vouchers available',
                                ),
                                value: null,
                                items: snapshot.hasData
                                    ? snapshot.data!.map((element) {
                                        return DropdownMenuItem(
                                          value: element,
                                          child: Text(
                                              '${element.code} ${element.id != 0 ? price(element.value) : ''}'),
                                        );
                                      }).toList()
                                    : [],
                                onChanged: (voucher) {
                                  if (voucher != null && voucher.id != 0) {
                                    dataProvider.setSelectedVoucher(voucher);
                                  } else {
                                    dataProvider.setSelectedVoucher(null);
                                  }
                                },
                              ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
