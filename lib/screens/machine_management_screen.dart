import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_machine_screen.dart';
import '../core/constants.dart';

class MachineManagementScreen extends StatefulWidget {
  final String? userId;
  final VoidCallback onBackToMap;

  const MachineManagementScreen({
    super.key, 
    required this.userId, 
    required this.onBackToMap
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
      backgroundColor: const Color(0xFF121212), // Ensure background matches
      appBar: AppBar(
        title: const Text("Manage Machines"),
        backgroundColor: const Color(0xFF121212),
        // CUSTOM BACK BUTTON
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBackToMap, // <--- Calls the function from BodyMapScreen
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Pass userId to the Create Screen
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (context) => AddMachineScreen(userId: widget.userId)
            )
          );
        },
        label: const Text("Add Machine", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: kPrimaryColor, // Your Lime Green constant
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
                          // In the future, you can pass the 'machine' data here 
                          // to fill the form for editing.
                        ),
                      ),
                    );
                    // Edit logic here
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