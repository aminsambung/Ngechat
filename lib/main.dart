import 'package:flutter/material.dart';

void main() {
  runApp(const NgechatApp());
}

class NgechatApp extends StatelessWidget {
  const NgechatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ngechat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101820),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF128C7E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Ngechat',
    'Pembaruan',
    'Panggilan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Menu $value belum aktif')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Profil',
                child: Text('Profil'),
              ),
              const PopupMenuItem(
                value: 'Setelan Pesan',
                child: Text('Setelan Pesan'),
              ),
              const PopupMenuItem(
                value: 'Nada Pesan',
                child: Text('Nada Pesan'),
              ),
              const PopupMenuItem(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: const [
          ChatPage(),
          UpdatesPage(),
          CallsPage(),
        ],
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF128C7E),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddContactPage(),
                  ),
                );
              },
              child: const Icon(Icons.message),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.circle_outlined),
            selectedIcon: Icon(Icons.circle),
            label: 'Pembaruan',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call),
            label: 'Panggilan',
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ChatTile(
          name: 'Ngechat',
          message: 'Selamat datang di Ngechat!',
          icon: Icons.account_circle,
          time: '10.00',
          onTap: () => openChat(context, 'Ngechat'),
        ),
        ChatTile(
          name: 'Contoh Kontak',
          message: 'Mulai percakapan baru',
          icon: Icons.person,
          time: '09.30',
          onTap: () => openChat(context, 'Contoh Kontak'),
        ),
      ],
    );
  }

  void openChat(BuildContext context, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(name: name),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final IconData icon;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: const Color(0xFF128C7E),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(message),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

class ChatRoomPage extends StatefulWidget {
  final String name;

  const ChatRoomPage({super.key, required this.name});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController controller = TextEditingController();
  final List<String> messages = [];

  void sendMessage() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(text);
      controller.clear();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF128C7E),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Mulai percakapan di Ngechat',
                      style: TextStyle(color: Colors.white60),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF075E54),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            messages[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        filled: true,
                        fillColor: const Color(0xFF1D2A32),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF128C7E),
                    child: IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Status',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFF128C7E),
            child: Icon(Icons.add, color: Colors.white),
          ),
          title: Text('Status saya'),
          subtitle: Text('Ketuk untuk menambahkan pembaruan'),
        ),
      ],
    );
  }
}

class CallsPage extends StatelessWidget {
  const CallsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFF128C7E),
            child: Icon(Icons.dialpad, color: Colors.white),
          ),
          title: Text('Keypad'),
          subtitle: Text('Masukkan nomor untuk menelepon'),
        ),
        ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.call),
          ),
          title: Text('Riwayat panggilan'),
          subtitle: Text('Belum ada panggilan'),
        ),
      ],
    );
  }
}

class AddContactPage extends StatelessWidget {
  const AddContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan baru'),
        backgroundColor: const Color(0xFF075E54),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person_add),
            ),
            title: const Text('Tambah kontak'),
            subtitle: const Text('Tambahkan kontak dengan PIN atau QR'),
            onTap: () {},
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Kontak di Ngechat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: const Text('Contoh Kontak'),
            subtitle: const Text('Belum terhubung'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ChatRoomPage(name: 'Contoh Kontak'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
