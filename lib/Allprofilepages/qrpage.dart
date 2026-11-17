import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Qrpage extends StatelessWidget {

  final String uid;

  const Qrpage({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {

    String qrData = 'instabee://profile/$uid';

    return Scaffold(
      appBar: AppBar(
        title: Text('Share Profile'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'My InstaBee QR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: QrImageView(
                data: qrData,
                size: 250,
              ),
            ),

            SizedBox(height: 20),

            Text('Scan to view my InstaBee profile'),

            SizedBox(height: 10),

         

          ],
        ),
      ),
    );
  }
}