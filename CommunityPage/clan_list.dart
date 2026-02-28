import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:ui_demo/CommunityPage/Clans/CreateClans/create_clan.dart';
import 'package:ui_demo/CommunityPage/data/local/clan_entity.dart';
import 'package:ui_demo/CommunityPage/widgets/clan_tile.dart';
import 'package:ui_demo/themes/app_colors.dart';
import '../CommunityPage/Clans/clan_service.dart';
// import '../widgets/group_tile.dart'; // your previously defined GroupTile

class ClanList extends StatefulWidget {
  const ClanList({super.key});

  @override
  State<ClanList> createState() => _ClanListState();
}

class _ClanListState extends State<ClanList> {
  List<Map<String, dynamic>> clans = [];
  bool loading = true;
  late final supabase.SupabaseClient _supabase;
  late final ClanService _clanService;
  @override
  void initState() {
    super.initState();
    _supabase = supabase.Supabase.instance.client;
    _clanService = ClanService(_supabase);
    loadClans();
  }

  // Future<void> loadClans() async {
  //   try {
  //     final res = await _clanService.fetchClans(); // call the static method
  //     setState(() {
  //       clans = res;
  //       // print(" clans $clans");
  //       loading = false;
  //     });
  //   } catch (e) {
  //     setState(() => loading = false);
  //     debugPrint('Error loading clans: $e');
  //   }
  // }

  Future<void> loadClans() async {
    final box = Hive.box<ClanEntity>('clans');

    //  Load cached clans (single source of truth)
    final cached = box.values.toList()
      ..sort(
        (a, b) => (b.lastMessageAt ?? DateTime(1970)).compareTo(
          a.lastMessageAt ?? DateTime(1970),
        ),
      );

    if (cached.isNotEmpty) {
      setState(() {
        clans = cached.map((c) => c.toMap()).toList();
        loading = false;
      });
    }

    // Try network refresh
    try {
      final res = await _clanService.fetchClans();

      // Normalize + sort BEFORE saving
      final entities = res.map((c) => ClanEntity.fromMap(c)).toList()
        ..sort(
          (a, b) => (b.lastMessageAt ?? DateTime(1970)).compareTo(
            a.lastMessageAt ?? DateTime(1970),
          ),
        );

      // Bulk save (logical)
      for (final c in entities) {
        box.put(c.id, c);
      }

      //  Update UI from Hive-shaped data
      setState(() {
        clans = entities.map((c) => c.toMap()).toList();
        loading = false;
      });
    } catch (e) {
      debugPrint('Offline, using cached clans');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    if (clans.isEmpty) {
      return const Center(child: Text('No clans available'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: clans.length + 1, // +1 for Create Clan
            itemBuilder: (context, index) {
              // LAST ITEM
              if (index == clans.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 250,
                        height: 1,
                        color: AppColors.textWhite,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 0),
                            reverseTransitionDuration: const Duration(
                              milliseconds: 0,
                            ),
                            pageBuilder: (_, _, _) => const CreateClanPage(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  final slide = Tween<Offset>(
                                    begin: const Offset(0.02, 0),
                                    end: Offset.zero,
                                  ).animate(animation);

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: slide,
                                      child: child,
                                    ),
                                  );
                                },
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.transparent,
                            border: Border.all(
                              width: 1,
                              color: AppColors.textWhite,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.add_circle, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                "Create clan",
                                style: TextStyle(color: AppColors.textWhite),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // NORMAL LIST ITEM
              final c = clans[index];
              return GroupTile(
                groupId: c['id'],
                name: c['name'],
                avatarUrl: c['avatar_url'],
                lastMessage: c['last_message'],
                lastMessageAt: c['last_message_at'] != null
                    ? DateTime.parse(c['last_message_at'])
                    : null,
                unreadCount: c['unread_count'] ?? 0,
              );
            },
          ),
        ),
      ],
    );
  }
}
