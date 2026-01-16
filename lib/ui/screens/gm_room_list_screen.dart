import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/room_provider.dart';
import 'gm_dashboard_screen.dart';

class GMRoomListScreen extends StatefulWidget {
  const GMRoomListScreen({super.key});

  @override
  State<GMRoomListScreen> createState() => _GMRoomListScreenState();
}

class _GMRoomListScreenState extends State<GMRoomListScreen> {
  final TextEditingController _roomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carica le stanze appena la schermata si apre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomProvider>().loadMyRooms();
    });
  }

  void _createNewRoom() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2438),
        title: Text("Crea Nuova Stanza", style: GoogleFonts.cinzel(color: Colors.white)),
        content: TextField(
          controller: _roomNameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Nome della Stanza",
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
            onPressed: () async {
              if (_roomNameController.text.isNotEmpty) {
                Navigator.pop(ctx);
                // La chiamata funziona perché il secondo argomento ora è opzionale
                final roomCode = await context.read<RoomProvider>().createRoom(_roomNameController.text);
                
                if (roomCode != null && mounted) {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const GmDashboardScreen())
                  );
                }
              }
            },
            child: const Text("Crea", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomProvider>();
    final myRooms = provider.myRooms;

    return Scaffold(
      appBar: AppBar(
        title: Text("LE TUE STANZE", style: GoogleFonts.cinzel(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      backgroundColor: const Color(0xFF121212),
      body: myRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("Non hai ancora creato stanze.", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _createNewRoom,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                    child: const Text("CREA LA TUA PRIMA STANZA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myRooms.length,
              itemBuilder: (context, index) {
                final room = myRooms[index];
                return Card(
                  color: const Color(0xFF2A2438),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(room['roomName'] ?? "Stanza senza nome", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("Codice: ${room['code']}", style: const TextStyle(color: Color(0xFFD4AF37))),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    onTap: () {
                        // Riprende la sessione come GM
                        provider.resumeRoom(room['code']);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const GmDashboardScreen()));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: myRooms.isNotEmpty 
        ? FloatingActionButton(
            onPressed: _createNewRoom,
            backgroundColor: const Color(0xFFD4AF37),
            child: const Icon(Icons.add, color: Colors.black),
          )
        : null,
    );
  }
}