import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../screens/machine_detail_screen.dart';

class MachineListScreen extends StatelessWidget {
  const MachineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHEST WORKOUT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.85,
          children: [
            _buildMachineCard(
              context, 
              "Chest Press", 
              "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Pec Fly", 
              "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Bench Press", 
              "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=2070&auto=format&fit=crop"
            ),
            _buildMachineCard(
              context, 
              "Cable Cross", 
              "https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?q=80&w=2069&auto=format&fit=crop"
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineCard(BuildContext context, String name, String imgUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MachineDetailScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor, // Dark card
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(13)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
