import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../commons/common_consts.dart';
import '../../commons/common_methods.dart';
import '../../providers/data_provider.dart';
import '../leak_cylinders/leak_invoice_view_model.dart';

class LeakNotePrintScreen extends StatelessWidget {
  const LeakNotePrintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final viewModel = LeakInvoiceViewModel(context: context);
    return Scaffold(
      appBar: AppBar(
        title: Text(dataProvider.itemList[0].leakType == 2
            ? 'Print Leak Received Note'
            : 'Print Leak Issued Note'),
      ),
      body: PdfPreview(
        onPrinted: (context) async {
          viewModel.onPressedSaveButton();
        },
        build: (format) => _generatePdf(format, context),
      ),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, BuildContext context) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: ThemeConstants.pageFormat,
        build: (context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  // Company details
                  ...CompanyConstants.companyDetails,

                  // Leak Note Title
                  pw.SizedBox(height: 5.0),
                  pw.Text(
                    dataProvider.itemList[0].leakType == 2
                        ? 'Leak Received Note'
                        : 'Leak Issued Note',
                    style: ThemeConstants.boldStyleForPdf,
                  ),
                  pw.SizedBox(height: 5.0),

                  // Customer Details
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '${dataProvider.itemList[0].leakType == 2 ? "Received To" : "Issued To"}: ${dataProvider.selectedCustomer?.businessName}',
                            style: const pw.TextStyle(fontSize: 22.0),
                          ),
                          pw.Text(
                            'Date: ${date(DateTime.now(), format: 'dd.MM.yyyy')}',
                            style: const pw.TextStyle(fontSize: 22.0),
                          ),
                          pw.Text(
                            'Note No: ${dataProvider.currentInvoice?.invoiceNo}',
                            style: const pw.TextStyle(fontSize: 22.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5.0),

                  // Items Table
                  pw.Table(
                    children: [
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColor.fromInt(0xFFFFFFFF),
                        ),
                        children: [
                          _buildTableHeaderCell('#', align: pw.TextAlign.left),
                          _buildTableHeaderCell('Item'),
                          if (dataProvider.itemList[0].leakType == 2) ...[
                            _buildTableHeaderCell('Cylinder No'),
                            _buildTableHeaderCell('Reference'),
                          ] else ...[
                            _buildTableHeaderCell('Cylinder No'),
                          ],
                        ],
                      ),
                      ...dataProvider.itemList.map((item) {
                        return pw.TableRow(
                          children: [
                            _buildTableCell(
                              (dataProvider.itemList.indexOf(item) + 1)
                                  .toString(),
                              align: pw.TextAlign.left,
                            ),
                            _buildTableCell(item.item.itemName),
                            if (dataProvider.itemList[0].leakType == 2) ...[
                              _buildTableCell(item.cylinderNo ?? ''),
                              _buildTableCell(item.referenceNo ?? ''),
                            ] else ...[
                              _buildTableCell(item.cylinderNo ?? ''),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),

                  // Footer
                  pw.SizedBox(height: 10),
                  _buildTableHeaderCell(
                    '${dataProvider.itemList[0].leakType == 2 ? "Received" : "Issued"} By: ${dataProvider.currentEmployee?.firstName}',
                    color: const PdfColor.fromInt(0xFF000000),
                  ),
                  _buildTableHeaderCell(
                    'Date & Time: ${date(DateTime.now(), format: 'dd.MM.yyyy hh:mm a')}',
                    color: const PdfColor.fromInt(0xFF000000),
                  ),
                  pw.SizedBox(height: 2),
                  MessageConstants.signatureNotRequired,
                  pw.SizedBox(height: 5),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildTableHeaderCell(String value,
      {pw.TextAlign? align, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(1),
      child: pw.Text(
        value,
        textAlign: align ?? pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 22.0,
          color: color ?? const PdfColor.fromInt(0xFF000000),
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String value, {pw.TextAlign? align}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(1),
      child: pw.Text(
        value,
        textAlign: align ?? pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 22.0),
      ),
    );
  }
}