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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
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
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const PeoplePage();
        }

        return const AuthPage();
      },
    );
  }
}

// ============================================================
// AUTH PAGE
// ============================================================

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Email dan password wajib diisi.');
      return;
    }

    if (!_isLogin && name.isEmpty) {
      _showMessage('Nama wajib diisi.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password minimal 6 karakter.');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;

        if (user != null) {
          await user.updateDisplayName(name);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(_authMessage(e));
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';

      case 'user-not-found':
        return 'Akun tidak ditemukan.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';

      case 'email-already-in-use':
        return 'Email sudah digunakan.';

      case 'weak-password':
        return 'Password terlalu lemah.';

      case 'network-request-failed':
        return 'Periksa koneksi internet.';

      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';

      default:
        return e.message ?? 'Terjadi kesalahan autentikasi.';
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Masukkan email terlebih dahulu.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      _showMessage('Email reset password sudah dikirim.');
    } on FirebaseAuthException catch (e) {
      _showMessage(_authMessage(e));
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngechat'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.chat_bubble_rounded,
                    size: 80,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _isLogin ? 'Selamat datang' : 'Buat akun',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _isLogin
                        ? 'Masuk ke akun Ngechat kamu'
                        : 'Daftar untuk mulai menggunakan Ngechat',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  if (!_isLogin) ...[
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_loading) {
                        _submit();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Masuk' : 'Daftar',
                            ),
                    ),
                  ),

                  if (_isLogin) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text('Lupa password?'),
                    ),
                  ],

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: _loading
                        ? null
                        : () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                    child: Text(
                      _isLogin
                          ? 'Belum punya akun? Daftar'
                          : 'Sudah punya akun? Masuk',
                    ),
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

// ============================================================
// PEOPLE PAGE
// ============================================================

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const AuthPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngechat'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat pengguna.\n\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data?.docs.where((doc) {
                return doc.id != currentUser.uid;
              }).toList() ??
              [];

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pengguna lain.',
              ),
            );
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
            ),
            itemBuilder: (context, index) {
              final data = users[index].data();

              final name =
                  (data['name'] ?? 'Tanpa nama').toString();

              final email =
                  (data['email'] ?? '').toString();

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    name.isNotEmpty
                        ? name[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(name),
                subtitle: Text(email),
                trailing: const Icon(
                  Icons.chevron_right,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        otherUserId: users[index].id,
                        otherUserName: name,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// CHAT PAGE
// ============================================================

class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late final String _chatId;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _chatId = '';
      return;
    }

    final ids = [
      currentUser.uid,
      widget.otherUserId,
    ]..sort();

    _chatId = ids.join('_');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final user = _currentUser;
    final text = _messageController.text.trim();

    if (user == null || text.isEmpty || _chatId.isEmpty) {
      return;
    }

    _messageController.clear();

    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatId);

      await chatRef.set(
        {
          'participants': [
            user.uid,
            widget.otherUserId,
          ],
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      await chatRef.collection('messages').add({
        'senderId': user.uid,
        'receiverId': widget.otherUserId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim pesan: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;

    if (user == null) {
      return const AuthPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(_chatId)
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat pesan.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final messages = snapshot.data?.docs ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesan.\nMulai percakapan sekarang.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();

                    final senderId =
                        (data['senderId'] ?? '').toString();

                    final text =
                        (data['text'] ?? '').toString();

                    final isMe = senderId == user.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width *
                                  0.75,
                        ),
                        margin:
                            const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Text(text),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
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
