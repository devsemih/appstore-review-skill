import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

/// Coins are spent on in-chat gifts and on boosting your messages to the top of a room.
class CoinShopScreen extends StatelessWidget {
  const CoinShopScreen({super.key});

  static const packs = [
    {'coins': 100, 'price': '0.99', 'amountCents': 99},
    {'coins': 550, 'price': '4.99', 'amountCents': 499},
    {'coins': 1200, 'price': '9.99', 'amountCents': 999},
  ];

  Future<void> _buy(BuildContext context, Map<String, Object> pack) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final res = await http.post(
      Uri.parse('https://api.huddle.chat/payments/create-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid, 'amount': pack['amountCents'], 'coins': pack['coins']}),
    );
    final clientSecret = jsonDecode(res.body)['clientSecret'] as String;
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Huddle',
      ),
    );
    await Stripe.instance.presentPaymentSheet();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${pack['coins']} coins added to your wallet!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin Shop')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Send gifts and boost your messages with coins.'),
          const SizedBox(height: 16),
          for (final pack in packs)
            Card(
              child: ListTile(
                leading: const Icon(Icons.monetization_on, color: Colors.amber),
                title: Text('${pack['coins']} coins'),
                trailing: FilledButton(
                  onPressed: () => _buy(context, pack.cast<String, Object>()),
                  child: Text('\$${pack['price']}'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
