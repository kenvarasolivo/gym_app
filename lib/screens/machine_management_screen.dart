import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_machine_screen.dart';
import '../core/constants.dart';
import '../widgets/custom_bottom_nav.dart'; // <--- Import the widget

class MachineManagementScreen extends StatefulWidget {
  final String? userId;
  final bool isVerified;
  final Function(int) onTabSelected; // <--- Changed from VoidCallback to Function(int)

  const MachineManagementScreen({
    super.key, 
    required this.userId, 
    required this.isVerified,
    required this.onTabSelected,
  });

  @override
  State<MachineManagementScreen> createState() => _MachineManagementScreenState();
}

class _MachineManagementScreenState extends State<MachineManagementScreen> {
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _machineStream;

  @override
  void initState() {
    super.initState();
    _machineStream = _supabase
        .from('machine_list')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      appBar: AppBar(
        title: const Text("Manage Machines"),
        backgroundColor: const Color(0xFF121212),
        // Allows user to go back to "Anterior" view by clicking the back arrow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.onTabSelected(0), 
        ),
      ),

      // --- USE THE CUSTOM NAVBAR ---
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2, // This screen is always index 2
        isVerified: widget.isVerified, 
        onTap: widget.onTabSelected, // Pass the click back to BodyMapScreen
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => AddMachineScreen(userId: widget.userId)
            )
          );
        },
        label: const Text("Add Machine", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.black),
        backgroundColor: kPrimaryColor, 
      ),
      
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _machineStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final machines = snapshot.data!;
          
          if (machines.isEmpty) {
            return const Center(child: Text("No machines found.", style: TextStyle(color: Colors.white)));
          }

          return ListView.builder(
            itemCount: machines.length,
            itemBuilder: (context, index) {
              final machine = machines[index];
              return Card(
                color: const Color(0xFF1C1C1E),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: machine['icon'] != null && machine['icon'].isNotEmpty
                    ? Image.network(machine['icon'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.fitness_center, color: Colors.white),
                  title: Text(machine['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(machine['musclegroup'] ?? 'No Group', style: const TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.edit, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMachineScreen(
                          userId: widget.userId,
                          machineData: machine,
                          // Pass data here for editing in the future
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}