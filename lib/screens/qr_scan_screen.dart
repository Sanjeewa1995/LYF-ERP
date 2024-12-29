import 'package:flutter/material.dart';
import 'package:gsr/models/customer.dart';
import 'package:gsr/screens/select_customer_screen.dart';
import 'package:gsr/screens/previous_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../commons/common_methods.dart';
import '../providers/data_provider.dart';

class QRScanScreen extends StatefulWidget {
  static const routeId = 'QR';
  final String screen;
  final String? type;
  const QRScanScreen({Key? key, required this.screen, this.type})
      : super(key: key);

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool isSelectCustomer = false;

  _navigateNext(Barcode barcode, String screen) async {
    setState(() {
      isSelectCustomer = true;
    });
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final response = await respo('customers/get-by-reg-id',
        method: Method.post, data: {"registrationId": barcode.code});
    final customer = Customer.fromJson(response.data);
    dataProvider.setSelectedCustomer(customer);
    if (screen == 'Previous') {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PreviousScreen(qrText: customer.registrationId)));
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SelectCustomerScreen(
                    qrText: customer.registrationId,
                    type: widget.type,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 200.0;
    return Scaffold(
      body: isSelectCustomer
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                _onQRViewCreated(context, controller, widget.screen);
              },
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: scanArea,
              ),
            ),
    );
  }

  _onQRViewCreated(
      BuildContext context, QRViewController controller, String screen) {
    controller.scannedDataStream.listen(
      (scanData) {
        controller.stopCamera();
        _navigateNext(scanData, screen);
      },
    );
  }
}
