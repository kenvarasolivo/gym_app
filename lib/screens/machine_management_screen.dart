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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _openEditor(Map<String, dynamic>? machine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMachineScreen(
          userId: widget.userId,
          machineData: machine,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "MANAGE MACHINES",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
              onPressed: () => _openEditor(null),
              label: const Text("Add Machine", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add, color: Colors.black),
              backgroundColor: kPrimaryColor,
            )
          : null,

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _machineStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }

          final machines = snapshot.data!;

          if (machines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.inventory_2_outlined, color: kMutedText, size: 48),
                    SizedBox(height: 16),
                    Text("No machines yet",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Tap 'Add Machine' to create your first one.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kMutedText, fontSize: 14)),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(kPadding, 8, kPadding, 100),
            itemCount: machines.length,
            itemBuilder: (context, index) {
              final machine = machines[index];
              return _buildMachineTile(machine);
            },
          );
        },
      ),
    );
  }

  Widget _buildMachineTile(Map<String, dynamic> machine) {
    final icon = machine['icon'];
    final hasImage = icon != null && (icon as String).isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openEditor(machine),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: hasImage
                        ? Image.network(
                            icon,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) =>
                                _iconFallback(),
                          )
                        : _iconFallback(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machine['name'] ?? 'Unknown',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.fitness_center,
                              size: 12, color: kMutedText),
                          const SizedBox(width: 5),
                          Text(
                            machine['musclegroup'] ?? 'No Group',
                            style: const TextStyle(color: kMutedText, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                  onPressed: () => _openEditor(machine),
                ),
                if (widget.isVerified)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFFFF6B6B)),
                    onPressed: () =>
                        _confirmDelete(machine['id'], machine['name'] ?? 'Unknown'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconFallback() {
    return Container(
      color: kSurfaceColor,
      child: const Icon(Icons.fitness_center, color: kMutedText),
    );
  }
}