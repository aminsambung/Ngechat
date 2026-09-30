import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A884)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) return const AuthPage();
        return const PeoplePage();
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final auth = FirebaseAuth.instance;
      if (_register) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        await credential.user!.updateDisplayName(_name.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'name': _name.text.trim(),
          'email': _email.text.trim().toLowerCase(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _authMessage(e.code));
    } catch (e) {
      setState(() => _error = 'Terjadi kesalahan. Periksa koneksi dan konfigurasi Firebase.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _authMessage(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Email sudah digunakan.';
      case 'invalid-email': return 'Format email tidak valid.';
      case 'weak-password': return 'Kata sandi minimal 6 karakter.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': return 'Email atau kata sandi salah.';
      case 'network-request-failed': return 'Tidak ada koneksi internet.';
      case 'too-many-requests': return 'Terlalu banyak percobaan. Coba lagi nanti.';
      default: return 'Login/daftar gagal ($code).';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(radius: 38, child: Icon(Icons.chat, size: 38)),
                  const SizedBox(height: 14),
                  const Text('Ngechat', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_register ? 'Buat akun baru' : 'Masuk ke akun kamu'),
                  const SizedBox(height: 24),
                  if (_register) TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  if (_register) const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Masukkan email yang valid' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Kata sandi', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                    validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _submit,
                      child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_register ? 'Daftar' : 'Masuk'),
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; }),
                    child: Text(_register ? 'Sudah punya akun? Masuk' : 'Belum punya akun? Daftar'),
                  ),
                  if (!_register)
                    TextButton(
                      onPressed: _busy ? null : () async {
                        final email = _email.text.trim();
                        if (!email.contains('@')) {
                          setState(() => _error = 'Isi email terlebih dahulu untuk reset kata sandi.');
                          return;
                        }
                        // PERBAIKAN: Simpan messenger sebelum await
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                          if (mounted) {
                            messenger.showSnackBar(const SnackBar(content: Text('Email reset kata sandi sudah dikirim.')));
                          }
                        } on FirebaseAuthException catch (e) {
                          setState(() => _error = _authMessage(e.code));
                        }
                      },
                      child: const Text('Lupa kata sandi?'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngechat', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(me.displayName?.isNotEmpty == true ? me.displayName! : 'Akun saya'),
            subtitle: Text(me.email ?? ''),
            trailing: const Icon(Icons.verified_user_outlined),
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Align(alignment: Alignment.centerLeft, child: Text('Pengguna Ngechat', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('users').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Gagal memuat pengguna. Periksa Firestore Rules.'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final people = snapshot.data!.docs.where((d) => d.id != me.uid).toList();
                if (people.isEmpty) return const Center(child: Text('Belum ada pengguna lain. Daftarkan akun kedua untuk mencoba chat.'));
                return ListView.builder(
                  itemCount: people.length,
                  itemBuilder: (context, i) {
                    final data = people[i].data();
                    final name = (data['name'] as String?) ?? 'Pengguna';
                    final email = (data['email'] as String?) ?? '';
                    return ListTile(
                      leading: CircleAvatar(child: Text(name.isEmpty ? '?' : name[0].toUpperCase())),
                      title: Text(name),
                      subtitle: Text(email),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(peerUid: people[i].id, peerName: name))),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String peerUid;
  final String peerName;
  const ChatPage({super.key, required this.peerUid, required this.peerName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _text = TextEditingController();
  bool _sending = false;
  late final String _chatId;
  late final String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = FirebaseAuth.instance.currentUser!.uid;
    final ids = [_myUid, widget.peerUid]..sort();
    _chatId = ids.join('__');
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final value = _text.text.trim();
    if (value.isEmpty || _sending) return;
    
    // PERBAIKAN: Simpan messenger sebelum await
    final messenger = ScaffoldMessenger.of(context);
    
    setState(() => _sending = true);
    _text.clear();
    try {
      final db = FirebaseFirestore.instance;
      final chat = db.collection('chats').doc(_chatId);
      final memberIds = [_myUid, widget.peerUid]..sort();
      await chat.set({
        'memberIds': memberIds,
        'lastMessage': value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await chat.collection('messages').add({
        'senderId': _myUid,
        'text': value,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _text.text = value;
      // PERBAIKAN: Gunakan messenger yang sudah disimpan
      messenger.showSnackBar(const SnackBar(content: Text('Pesan gagal dikirim. Periksa koneksi dan Firestore Rules.')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = FirebaseFirestore.instance.collection('chats').doc(_chatId);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
        actions: [IconButton(icon: const Icon(Icons.call_outlined), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Panggilan belum tersedia.'))))],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: chat.collection('messages').orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Tidak dapat membaca pesan. Periksa Firestore Rules.'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('Mulai percakapan 👋'));
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final m = docs[i].data();
                    final mine = m['senderId'] == _myUid;
                    final stamp = m['createdAt'];
                    final time = stamp is Timestamp ? stamp.toDate() : null;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: mine ? const Color(0xFFDCF8C6) : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Align(alignment: Alignment.centerLeft, child: Text((m['text'] as String?) ?? '', style: TextStyle(color: mine ? Colors.black87 : null))),
                            if (time != null) Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: mine ? Colors.black54 : null)),
                          ],
                        ),
                      ),
                    );
                  },
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
                      controller: _text,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan',
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF00A884),
                    child: IconButton(onPressed: _sending ? null : _send, icon: const Icon(Icons.send, color: Colors.white)),
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
