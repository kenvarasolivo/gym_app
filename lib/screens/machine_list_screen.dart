import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../screens/machine_detail_screen.dart';
import '../supabase/post_functions.dart';

class MachineListScreen extends StatefulWidget {
  final String muscleGroup;

  const MachineListScreen({super.key, required this.muscleGroup});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _machines = [];

  @override
  void initState() {
    super.initState();
    _fetchMachines();
  }

  Future<void> _fetchMachines() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await supabase
          .from('machine_list')
          .select('id, name, icon, musclegroup')
          .eq('musclegroup', widget.muscleGroup);

      _machines = res.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.muscleGroup.toUpperCase()} WORKOUT",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error', style: TextStyle(color: Colors.white.withAlpha(200))))
                : _machines.isEmpty
                    ? Center(child: Text('No machines found for ${widget.muscleGroup}', style: TextStyle(color: Colors.white.withAlpha(200))))
                    : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.85,
                        children: _machines.map((m) => _buildMachineCard(context, m['id'], m['name'] ?? '', m['icon'] ?? '')).toList(),
                      ),
      ),
    );
  }

  Widget _buildMachineCard(BuildContext context, dynamic id, String name, String imgUrl) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MachineDetailScreen(machineName: name)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: imgUrl.isNotEmpty
                      ? Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity)
                      : Container(color: Colors.black12),
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
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, dynamic id, String name) async {
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

    setState(() => _loading = true);
    try {
      await supabase.from('machine_list').delete().eq('id', id);
      setState(() {
        _machines.removeWhere((m) => m['id'] == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
