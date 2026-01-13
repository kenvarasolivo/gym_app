import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_machine_screen.dart';
import '../core/constants.dart';
import '../widgets/custom_bottom_nav.dart';

class MachineManagementScreen extends StatefulWidget {
  final String? userId;
  final bool isVerified;
  final Function(int) onTabSelected; 

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

  Future<void> _confirmDelete(dynamic id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: const Text('Are you sure you want to delete this machine? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _supabase.from('machine_list').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      appBar: AppBar(
        title: const Text("Manage Machines"),
        backgroundColor: const Color(0xFF121212),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => widget.onTabSelected(0), 
        ),
      ),

      // --- USE THE CUSTOM NAVBAR ---
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2, 
        isVerified: widget.isVerified, 
        onTap: widget.onTabSelected,
      ),
      
      floatingActionButton: widget.isVerified
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMachineScreen(userId: widget.userId)),
                );
              },
              label: const Text("Add Machine", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add, color: Colors.black),
              backgroundColor: kPrimaryColor,
            )
          : null,
      
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMachineScreen(
                                userId: widget.userId,
                                machineData: machine,
                              ),
                            ),
                          );
                        },
                      ),
                      if (widget.isVerified) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                          onPressed: () => _confirmDelete(machine['id'], machine['name'] ?? 'Unknown'),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMachineScreen(
                          userId: widget.userId,
                          machineData: machine,
                          
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