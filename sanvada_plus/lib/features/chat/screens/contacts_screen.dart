import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/utils.dart';
import '../../auth/providers/auth_provider.dart';

// Conditionally import flutter_contacts only on mobile
import 'contacts_helper.dart';

/// Represents a phone contact with match info.
class _ContactEntry {
  final String displayName;
  final String phoneNumber;
  final UserModel? registeredUser; // non-null = registered on Sanvadha+

  _ContactEntry({
    required this.displayName,
    required this.phoneNumber,
    this.registeredUser,
  });
}

class ContactsScreen extends ConsumerStatefulWidget {
  const ContactsScreen({super.key});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  List<_ContactEntry> _allContacts = [];
  List<_ContactEntry> _filteredContacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _hasPermission = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        // On web, flutter_contacts is not available - show all registered users
        debugPrint('📱 [CONTACTS] Running on Web - loading registered users only');
        _hasPermission = true;
        final authService = ref.read(authServiceProvider);
        final registeredUsers = await authService.getAllUsers();

        final entries = registeredUsers
            .map((user) => _ContactEntry(
                  displayName: user.name,
                  phoneNumber: user.fullPhoneNumber,
                  registeredUser: user,
                ))
            .toList();

        entries.sort((a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));

        setState(() {
          _allContacts = entries;
          _filteredContacts = entries;
          _isLoading = false;
        });
        return;
      }

      // On mobile, use flutter_contacts
      _hasPermission = await ContactsHelper.requestPermission();
      if (!_hasPermission) {
        setState(() => _isLoading = false);
        return;
      }

      final phoneContacts = await ContactsHelper.getContacts();
      debugPrint('📱 [CONTACTS] Loaded ${phoneContacts.length} phone contacts');

      // Get all registered users from Firebase
      final authService = ref.read(authServiceProvider);
      final registeredUsers = await authService.getAllUsers();
      debugPrint('📱 [CONTACTS] Loaded ${registeredUsers.length} registered users');

      // Build contact lookup map by normalized phone number
      final registeredMap = <String, UserModel>{};
      for (final user in registeredUsers) {
        registeredMap[normalizePhone(user.fullPhoneNumber)] = user;
        registeredMap[normalizePhone(user.phoneNumber)] = user;
      }

      // Match phone contacts with registered users
      final entries = <_ContactEntry>[];
      final addedUids = <String>{};

      for (final contact in phoneContacts) {
        final phone = contact['phone'] as String;
        final name = contact['name'] as String;
        final normalized = normalizePhone(phone);

        UserModel? matched;
        matched = registeredMap[normalized];
        if (matched == null && normalized.length >= 9) {
          final suffix = normalized.substring(normalized.length - 9);
          for (final entry in registeredMap.entries) {
            if (entry.key.endsWith(suffix)) {
              matched = entry.value;
              break;
            }
          }
        }

        if (matched != null && addedUids.contains(matched.uid)) continue;
        if (matched != null) addedUids.add(matched.uid);

        entries.add(_ContactEntry(
          displayName: name.isNotEmpty ? name : phone,
          phoneNumber: phone,
          registeredUser: matched,
        ));
      }

      // Sort: registered users first, then alphabetical
      entries.sort((a, b) {
        if (a.registeredUser != null && b.registeredUser == null) return -1;
        if (a.registeredUser == null && b.registeredUser != null) return 1;
        return a.displayName
            .toLowerCase()
            .compareTo(b.displayName.toLowerCase());
      });

      setState(() {
        _allContacts = entries;
        _filteredContacts = entries;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ [CONTACTS] Error loading contacts: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _filteredContacts = _allContacts
          .where((c) =>
              c.displayName.toLowerCase().contains(query.toLowerCase()) ||
              c.phoneNumber.contains(query))
          .toList();
    });
  }

  Future<void> _sendInvite(String phoneNumber) async {
    final uri = Uri.parse(
      'sms:$phoneNumber?body=Hey! Join me on Sanvadha+ - the best chat app! Download it now.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showSnackBar(context, 'Could not open SMS app', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final registeredCount =
        _allContacts.where((c) => c.registeredUser != null).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select contact'),
            if (!_isLoading)
              Text(
                '${_allContacts.length} contacts${registeredCount > 0 ? ' ($registeredCount on Sanvadha+)' : ''}',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ContactSearchDelegate(
                  contacts: _allContacts,
                  onTap: _onContactTap,
                  onInvite: _sendInvite,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadContacts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.mediumBrown),
            )
          : _errorMessage != null
              ? _buildError(isDark)
              : !_hasPermission
                  ? _buildPermissionDenied(isDark)
                  : _filteredContacts.isEmpty
                      ? _buildEmpty(isDark)
                      : _buildContactsList(isDark),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64,
                color: isDark ? AppColors.warmGray : AppColors.tan),
            const SizedBox(height: 16),
            Text(
              'Failed to load contacts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.cream : AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.warmGray : AppColors.tan,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadContacts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contacts_rounded,
                size: 64,
                color: isDark ? AppColors.warmGray : AppColors.tan),
            const SizedBox(height: 16),
            Text(
              'Contacts permission required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.cream : AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Allow contacts access to find friends who use Sanvadha+',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.warmGray : AppColors.tan,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadContacts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Text(
        'No contacts found',
        style: TextStyle(
          color: isDark ? AppColors.warmGray : AppColors.tan,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildContactsList(bool isDark) {
    final registered =
        _filteredContacts.where((c) => c.registeredUser != null).toList();
    final notRegistered =
        _filteredContacts.where((c) => c.registeredUser == null).toList();

    return ListView(
      children: [
        // ── New group option ─────────────────────────────
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.mediumBrown,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_add_rounded, color: Colors.white),
          ),
          title: const Text('New group'),
          onTap: () {},
        ),

        // ── Registered contacts ──────────────────────────
        if (registered.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'CONTACTS ON SANVADHA+',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.tan : AppColors.mediumBrown,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...registered.map((c) => _buildContactTile(c, isDark)),
        ],

        // ── Non-registered contacts (invite) ─────────────
        if (notRegistered.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'INVITE TO SANVADHA+',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.tan : AppColors.mediumBrown,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...notRegistered.map((c) => _buildContactTile(c, isDark)),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContactTile(_ContactEntry contact, bool isDark) {
    final isRegistered = contact.registeredUser != null;

    return ListTile(
      onTap: () => _onContactTap(contact),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.cream,
        backgroundImage: isRegistered &&
                contact.registeredUser!.profilePic.isNotEmpty
            ? CachedNetworkImageProvider(contact.registeredUser!.profilePic)
            : null,
        child: (!isRegistered ||
                contact.registeredUser!.profilePic.isEmpty)
            ? Icon(
                Icons.person_rounded,
                color: isDark ? AppColors.warmGray : AppColors.tan,
              )
            : null,
      ),
      title: Text(
        isRegistered ? contact.registeredUser!.name : contact.displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        isRegistered
            ? contact.registeredUser!.about
            : contact.phoneNumber,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.warmGray : AppColors.tan,
        ),
      ),
      trailing: !isRegistered
          ? TextButton(
              onPressed: () => _sendInvite(contact.phoneNumber),
              child: const Text('Invite'),
            )
          : null,
    );
  }

  void _onContactTap(_ContactEntry contact) {
    if (contact.registeredUser != null) {
      context.pushReplacement('/chat/${contact.registeredUser!.uid}');
    } else {
      _sendInvite(contact.phoneNumber);
    }
  }
}

// ── Search delegate ─────────────────────────────────────────────
class _ContactSearchDelegate extends SearchDelegate<String> {
  final List<_ContactEntry> contacts;
  final void Function(_ContactEntry) onTap;
  final void Function(String) onInvite;

  _ContactSearchDelegate({
    required this.contacts,
    required this.onTap,
    required this.onInvite,
  });

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final filtered = contacts
        .where((c) =>
            c.displayName.toLowerCase().contains(query.toLowerCase()) ||
            c.phoneNumber.contains(query))
        .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final c = filtered[index];
        final isRegistered = c.registeredUser != null;
        return ListTile(
          leading: CircleAvatar(
            child: Icon(isRegistered ? Icons.person : Icons.person_outline),
          ),
          title: Text(
              isRegistered ? c.registeredUser!.name : c.displayName),
          subtitle: Text(c.phoneNumber),
          trailing: !isRegistered
              ? TextButton(
                  onPressed: () => onInvite(c.phoneNumber),
                  child: const Text('Invite'),
                )
              : null,
          onTap: () {
            close(context, '');
            onTap(c);
          },
        );
      },
    );
  }
}
