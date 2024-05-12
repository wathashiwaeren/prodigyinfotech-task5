import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRViewExample(),
    );
  }
}

class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 300,
                  ),
                  onQRViewCreated: _onQRViewCreated,
                ),
                Positioned(
                  bottom: 16,
                  child: Text(
                    'Align QR code within the frame',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (result != null)
                      ? Column(
                          children: [
                            Text('Result: ${result?.code ?? ''}'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                _copyToClipboard(result!.code!);
                              },
                              child: Text('Copy to Clipboard'),
                            ),
                          ],
                        )
                      : Text('Scan a QR code'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      _handleScannedData(scanData.code!);
    });
  }

  void _handleScannedData(String data) {
    if (Uri.tryParse(data)?.isAbsolute ?? false) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Open URL?'),
          content: Text('Do you want to open this URL?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Open the URL
                // You'll need to import 'package:url_launcher/url_launcher.dart'
                // and ensure you've added 'url_launcher' to your dependencies
                // Then, you can use launch(data) to open the URL
                //launch(data);
              },
              child: Text('Open'),
            ),
          ],
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
