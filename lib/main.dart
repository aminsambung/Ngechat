import 'package:flutter/material.dart';

void main() => runApp(const NgechatApp());

class NgechatApp extends StatefulWidget {
  const NgechatApp({super.key});
  @override
  State<NgechatApp> createState() => _NgechatAppState();
}

class _NgechatAppState extends State<NgechatApp> {
  bool dark = true;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Ngechat',
    theme: ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A884), brightness: dark ? Brightness.dark : Brightness.light),
      scaffoldBackgroundColor: dark ? const Color(0xFF101B21) : const Color(0xFFF5F7F8),
      appBarTheme: AppBarTheme(backgroundColor: dark ? const Color(0xFF1F2C34) : Colors.white, elevation: 0),
    ),
    home: HomePage(dark: dark, onTheme: (v) => setState(() => dark = v)),
  );
}

class Contact {
  String name, pin;
  bool favorite;
  Contact(this.name, this.pin, {this.favorite = false});
}
class Message {
  final String text;
  final bool mine;
  final DateTime time;
  Message(this.text, this.mine) : time = DateTime.now();
}
class Room {
  final Contact contact;
  final List<Message> messages;
  Room(this.contact, [List<Message>? messages]) : messages = messages ?? [];
}

class HomePage extends StatefulWidget {
  final bool dark;
  final ValueChanged<bool> onTheme;
  const HomePage({super.key, required this.dark, required this.onTheme});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  int tab = 0;
  final contacts = <Contact>[
    Contact('Andi', 'NG1234', favorite: true),
    Contact('Siti', 'NG2345'),
    Contact('Budi', 'NG3456'),
  ];
  late final rooms = <Room>[
    Room(contacts[0], [Message('Halo, apa kabar?', false), Message('Baik, kamu?', true)]),
    Room(contacts[1], [Message('Nanti jadi bertemu?', false)]),
    Room(contacts[2]),
  ];
  final statuses = <String>['Selamat datang di Ngechat!'];
  final calls = <String>[];
  final schedules = <String>[];
  String profileName = 'Pengguna Ngechat', profilePin = 'NG0001', language = 'Indonesia';
  bool notifications = true, receipts = true, profileVisible = true, appLock = false;

  void addContact() {
    final n = TextEditingController(), p = TextEditingController();
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      title: const Text('Tambah kontak via PIN'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama')),
        TextField(controller: p, decoration: const InputDecoration(labelText: 'PIN')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
        FilledButton(onPressed: () {
          if (n.text.trim().isEmpty || p.text.trim().isEmpty) return;
          setState(() { final c = Contact(n.text.trim(), p.text.trim()); contacts.add(c); rooms.add(Room(c)); });
          Navigator.pop(d);
        }, child: const Text('Simpan')),
      ],
    ));
  }
  void editContact(Contact c) {
    final n = TextEditingController(text: c.name), p = TextEditingController(text: c.pin);
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      title: const Text('Edit kontak'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama')),
        TextField(controller: p, decoration: const InputDecoration(labelText: 'PIN')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
        FilledButton(onPressed: () {
          if (n.text.trim().isEmpty || p.text.trim().isEmpty) return;
          setState(() { c.name = n.text.trim(); c.pin = p.text.trim(); });
          Navigator.pop(d);
        }, child: const Text('Simpan')),
      ],
    ));
  }
  void deleteContact(Contact c) => showDialog<void>(context: context, builder: (d) => AlertDialog(
    title: const Text('Hapus kontak?'),
    content: Text('Hapus ${c.name} dari daftar kontak?'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
      FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red), onPressed: () {
        setState(() { contacts.remove(c); rooms.removeWhere((r) => r.contact == c); });
        Navigator.pop(d);
      }, child: const Text('Hapus')),
    ],
  ));
  void openChat(Room room) => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(room: room)));
  void showContacts() => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => SafeArea(
    child: SizedBox(height: MediaQuery.of(ctx).size.height * .75, child: Column(children: [
      ListTile(title: const Text('Kontak', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), trailing: IconButton(icon: const Icon(Icons.person_add), onPressed: () { Navigator.pop(ctx); addContact(); })),
      const Divider(),
      Expanded(child: ListView(children: [for (final c in contacts) ListTile(
        leading: CircleAvatar(child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase())),
        title: Text(c.name), subtitle: Text('PIN: ${c.pin}'),
        trailing: PopupMenuButton<String>(onSelected: (v) {
          Navigator.pop(ctx);
          if (v == 'edit') editContact(c);
          if (v == 'delete') deleteContact(c);
          if (v == 'fav') setState(() => c.favorite = !c.favorite);
          if (v == 'chat') openChat(rooms.firstWhere((r) => r.contact == c));
        }, itemBuilder: (_) => [
          const PopupMenuItem(value: 'chat', child: Text('Buka chat')),
          const PopupMenuItem(value: 'edit', child: Text('Edit nama / PIN')),
          PopupMenuItem(value: 'fav', child: Text(c.favorite ? 'Hapus dari favorit' : 'Jadikan favorit')),
          const PopupMenuItem(value: 'delete', child: Text('Hapus kontak')),
        ]),
      )])),
    ])),
  ));
  void addStatus() {
    final t = TextEditingController();
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      title: const Text('Buat status teks'),
      content: TextField(controller: t, maxLines: 3, decoration: const InputDecoration(hintText: 'Tulis pembaruan...')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
        FilledButton(onPressed: () { if (t.text.trim().isNotEmpty) setState(() => statuses.insert(0, t.text.trim())); Navigator.pop(d); }, child: const Text('Bagikan')),
      ],
    ));
  }
  void dial() {
    final t = TextEditingController();
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      title: const Text('Keypad'),
      content: TextField(controller: t, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor / PIN')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
        FilledButton(onPressed: () { if (t.text.trim().isNotEmpty) setState(() => calls.insert(0, t.text.trim())); Navigator.pop(d); }, child: const Text('Catat panggilan')),
      ],
    ));
  }
  void scheduleCall() {
    final who = TextEditingController(), when = TextEditingController();
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      title: const Text('Jadwalkan panggilan'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: who, decoration: const InputDecoration(labelText: 'Nama / nomor')),
        TextField(controller: when, decoration: const InputDecoration(labelText: 'Tanggal dan jam')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Batal')),
        FilledButton(onPressed: () { if (who.text.trim().isNotEmpty && when.text.trim().isNotEmpty) setState(() => schedules.add('${who.text.trim()} • ${when.text.trim()}')); Navigator.pop(d); }, child: const Text('Simpan')),
      ],
    ));
  }
  void profile() {
    final n = TextEditingController(text: profileName);
    showDialog<void>(context: context, builder: (d) => AlertDialog(
      title: const Text('Profil saya'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 30)),
        TextField(controller: n, decoration: const InputDecoration(labelText: 'Nama')),
        ListTile(contentPadding: EdgeInsets.zero, title: const Text('PIN saya'), subtitle: Text(profilePin)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d), child: const Text('Tutup')),
        FilledButton(onPressed: () { setState(() => profileName = n.text.trim().isEmpty ? profileName : n.text.trim()); Navigator.pop(d); }, child: const Text('Simpan')),
      ],
    ));
  }
  void settings() => showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => SafeArea(
    child: SizedBox(height: MediaQuery.of(ctx).size.height * .82, child: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Pengaturan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ListTile(leading: const Icon(Icons.person), title: const Text('Profil'), subtitle: Text(profileName), onTap: () { Navigator.pop(ctx); profile(); }),
      SwitchListTile(title: const Text('Tema gelap'), value: widget.dark, onChanged: widget.onTheme),
      ListTile(leading: const Icon(Icons.language), title: const Text('Bahasa'), subtitle: Text(language), onTap: () async {
        final l = await showDialog<String>(context: ctx, builder: (d) => SimpleDialog(title: const Text('Bahasa'), children: [
          for (final x in ['Indonesia', 'English']) SimpleDialogOption(onPressed: () => Navigator.pop(d, x), child: Text(x))
        ]));
        if (l != null) setState(() => language = l);
        refresh(() {});
      }),
      SwitchListTile(title: const Text('Notifikasi'), value: notifications, onChanged: (v) { setState(() => notifications = v); refresh(() {}); }),
      const Divider(), const Text('Privasi', style: TextStyle(fontWeight: FontWeight.bold)),
      SwitchListTile(title: const Text('Tampilkan profil'), value: profileVisible, onChanged: (v) { setState(() => profileVisible = v); refresh(() {}); }),
      SwitchListTile(title: const Text('Laporan dibaca'), value: receipts, onChanged: (v) { setState(() => receipts = v); refresh(() {}); }),
      const Divider(), const Text('Keamanan', style: TextStyle(fontWeight: FontWeight.bold)),
      SwitchListTile(title: const Text('Kunci aplikasi (demo)'), value: appLock, onChanged: (v) { setState(() => appLock = v); refresh(() {}); }),
      const Text('Data dan pengaturan saat ini hanya tersimpan selama aplikasi berjalan.', style: TextStyle(color: Colors.grey)),
    ])),
  )));
  @override
  Widget build(BuildContext context) {
    final titles = ['Ngechat', 'Pembaruan', 'Panggilan'];
    return Scaffold(
      appBar: AppBar(title: Text(titles[tab], style: const TextStyle(fontWeight: FontWeight.bold)), actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () => showSearch(context: context, delegate: ChatSearch(rooms, openChat))),
        PopupMenuButton<String>(onSelected: (v) { if (v == 'contacts') showContacts(); if (v == 'profile') profile(); if (v == 'settings') settings(); }, itemBuilder: (_) => const [
          PopupMenuItem(value: 'contacts', child: Text('Kontak')),
          PopupMenuItem(value: 'profile', child: Text('Profil')),
          PopupMenuItem(value: 'settings', child: Text('Pengaturan')),
        ]),
      ]),
      body: IndexedStack(index: tab, children: [
        ListView(children: [for (final r in rooms) ListTile(
          leading: CircleAvatar(child: Text(r.contact.name[0].toUpperCase())),
          title: Text(r.contact.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(r.messages.isEmpty ? 'Mulai percakapan' : r.messages.last.text, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right), onTap: () => openChat(r),
          onLongPress: () => showModalBottomSheet<void>(context: context, builder: (d) => ListTile(leading: const Icon(Icons.delete), title: const Text('Hapus riwayat chat'), onTap: () { setState(() => r.messages.clear()); Navigator.pop(d); })),
        )]),
        ListView(padding: const EdgeInsets.all(16), children: [
          ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text('Status saya'), subtitle: const Text('Tambahkan pembaruan teks'), trailing: const Icon(Icons.add_circle, color: Color(0xFF00A884)), onTap: addStatus),
          const Divider(), const Text('Pembaruan terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final s in statuses) Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.auto_awesome)), title: const Text('Saya'), subtitle: Text(s), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => statuses.remove(s))))),
          if (statuses.isEmpty) const Text('Belum ada pembaruan.'),
        ]),
        ListView(children: [
          ListTile(leading: const Icon(Icons.dialpad), title: const Text('Keypad'), subtitle: const Text('Masukkan nomor atau PIN'), onTap: dial),
          ListTile(leading: const Icon(Icons.star), title: const Text('Favorit'), subtitle: Text(contacts.where((c) => c.favorite).map((c) => c.name).join(', ').isEmpty ? 'Belum ada favorit' : contacts.where((c) => c.favorite).map((c) => c.name).join(', '))),
          ListTile(leading: const Icon(Icons.event), title: const Text('Jadwalkan panggilan'), onTap: scheduleCall),
          const Divider(), const Padding(padding: EdgeInsets.all(16), child: Text('Riwayat panggilan', style: TextStyle(fontWeight: FontWeight.bold))),
          for (final c in calls) ListTile(leading: const Icon(Icons.call_made), title: Text(c), subtitle: const Text('Catatan panggilan demo')),
          if (calls.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Belum ada riwayat panggilan.')),
          for (final s in schedules) ListTile(leading: const Icon(Icons.schedule), title: Text(s), trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => setState(() => schedules.remove(s)))),
        ]),
      ]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: const [
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.circle_outlined), selectedIcon: Icon(Icons.circle), label: 'Pembaruan'),
        NavigationDestination(icon: Icon(Icons.call_outlined), selectedIcon: Icon(Icons.call), label: 'Panggilan'),
      ]),
      floatingActionButton: tab == 0 ? FloatingActionButton(onPressed: showContacts, child: const Icon(Icons.chat))
        : tab == 1 ? FloatingActionButton(onPressed: addStatus, child: const Icon(Icons.add))
        : FloatingActionButton(onPressed: dial, child: const Icon(Icons.dialpad)),
    );
  }
}

class ChatPage extends StatefulWidget {
  final Room room;
  const ChatPage({super.key, required this.room});
  @override
  State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final text = TextEditingController();
  @override
  void dispose() { text.dispose(); super.dispose(); }
  void send() {
    if (text.text.trim().isEmpty) return;
    setState(() => widget.room.messages.add(Message(text.text.trim(), true)));
    text.clear();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.room.contact.name), actions: [
      IconButton(icon: const Icon(Icons.person_outline), onPressed: () => showDialog<void>(context: context, builder: (_) => AlertDialog(title: Text(widget.room.contact.name), content: Text('PIN: ${widget.room.contact.pin}')))),
      IconButton(icon: const Icon(Icons.call), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Panggilan online belum tersedia.')))),
    ]),
    body: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
        for (final m in widget.room.messages) Align(alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft, child: GestureDetector(
          onLongPress: () => showModalBottomSheet<void>(context: context, builder: (d) => ListTile(leading: const Icon(Icons.delete), title: const Text('Hapus pesan'), onTap: () { setState(() => widget.room.messages.remove(m)); Navigator.pop(d); })),
          child: Container(margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(12), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
            decoration: BoxDecoration(color: m.mine ? const Color(0xFF075E54) : const Color(0xFF26343D), borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Align(alignment: Alignment.centerLeft, child: Text(m.text)),
              Text('${m.time.hour.toString().padLeft(2, '0')}:${m.time.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ]),
          ),
        )),
      ])),
      SafeArea(child: Padding(padding: const EdgeInsets.all(8), child: Row(children: [
        IconButton(icon: const Icon(Icons.image_outlined), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur pilih gambar perlu plugin image_picker.')))),
        Expanded(child: TextField(controller: text, minLines: 1, maxLines: 4, decoration: InputDecoration(hintText: 'Pesan', filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none)), onSubmitted: (_) => send())),
        const SizedBox(width: 6),
        CircleAvatar(backgroundColor: const Color(0xFF00A884), child: IconButton(onPressed: send, icon: const Icon(Icons.send, color: Colors.white))),
      ]))),
    ]),
  );
}

class ChatSearch extends SearchDelegate<void> {
  final List<Room> rooms;
  final void Function(Room) openChat;
  ChatSearch(this.rooms, this.openChat);
  @override
  List<Widget>? buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget? buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
  @override
  Widget buildSuggestions(BuildContext context) {
    final found = rooms.where((r) => r.contact.name.toLowerCase().contains(query.toLowerCase()) || r.contact.pin.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(children: [for (final r in found) ListTile(title: Text(r.contact.name), subtitle: Text(r.contact.pin), onTap: () { close(context, null); openChat(r); })]);
  }
}
