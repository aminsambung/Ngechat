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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Profil') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu Profil')),
                );
              }
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
      children: const [
        ChatTile(
          name: 'Ngechat',
          message: 'Selamat datang di Ngechat!',
          icon: Icons.account_circle,
          time: '10.00',
        ),
        ChatTile(
          name: 'Contoh Kontak',
          message: 'Mulai percakapan baru',
          icon: Icons.person,
          time: '09.30',
        ),
      ],
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final IconData icon;

  const ChatTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.icon,
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
      onTap: () {},
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
          const ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text('Contoh Kontak'),
            subtitle: Text('Belum terhubung'),
          ),
        ],
      ),
    );
  }
}
