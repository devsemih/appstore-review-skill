import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'chat_screen.dart';
import 'coin_shop_screen.dart';
import 'settings_screen.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _location = LocationService();

  @override
  void initState() {
    super.initState();
    _location.startSharingLiveLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms near you'),
        actions: [
          IconButton(
            icon: const Icon(Icons.monetization_on_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoinShopScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').orderBy('lastActivity', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final rooms = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, i) {
                    final room = rooms[i];
                    return ListTile(
                      title: Text(room['name']),
                      subtitle: Text('${room['memberCount']} people chatting'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatScreen(roomId: room.id, roomName: room['name'])),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
