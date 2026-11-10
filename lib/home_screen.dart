import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'board_screen.dart';
import 'login_screen.dart';
import 'models/models.dart';
import 'viewmodels/viewmodels.dart';

// ────────────────────────────────────────────────────────────────────────────
//  HOME SCREEN — Fully connected to TaskManager API
// ────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final boardVm = context.read<BoardViewModel>();
    final notifVm = context.read<NotificationViewModel>();
    await Future.wait([
      boardVm.fetchBoards(),
      boardVm.fetchDashboard(),
      notifVm.fetchNotifications(unreadOnly: false),
    ]);
  }

  // ─── Search Dialog ─────────────────────────────────────────────────────────
  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search_rounded, color: NGColors.gold),
                  const SizedBox(width: 8),
                  const Text(
                    'Search Boards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter board title keyword...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: NGColors.gold),
                  filled: true,
                  fillColor: const Color(0xFF1F1F1F),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => query = val,
                onSubmitted: (val) {
                  Navigator.pop(ctx);
                  context.read<BoardViewModel>().searchBoards(val);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NGColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<BoardViewModel>().searchBoards(query);
                  },
                  child: const Text('SEARCH', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Notifications Sheet ───────────────────────────────────────────────────
  void _openNotificationsSheet() {
    final notifVm = context.read<NotificationViewModel>();
    notifVm.fetchNotifications(unreadOnly: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Consumer<NotificationViewModel>(
          builder: (ctx, vm, _) {
            return Container(
              height: MediaQuery.of(ctx).size.height * 0.75,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active_rounded, color: NGColors.gold),
                          const SizedBox(width: 8),
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (vm.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: NGColors.gold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${vm.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (vm.notifications.isNotEmpty)
                        TextButton(
                          onPressed: () => vm.markAllAsRead(),
                          child: const Text('Mark all read',
                              style: TextStyle(color: NGColors.gold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  Expanded(
                    child: vm.isLoading
                        ? const Center(child: CircularProgressIndicator(color: NGColors.gold))
                        : vm.notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.notifications_off_outlined,
                                        size: 48, color: Colors.white.withValues(alpha: 0.2)),
                                    const SizedBox(height: 12),
                                    const Text('No notifications yet',
                                        style: TextStyle(color: Colors.white54, fontSize: 14)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                itemCount: vm.notifications.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(color: Colors.white10, height: 1),
                                itemBuilder: (ctx, i) {
                                  final item = vm.notifications[i];
                                  return ListTile(
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                                    leading: CircleAvatar(
                                      backgroundColor: item.isRead
                                          ? const Color(0xFF242424)
                                          : NGColors.gold.withValues(alpha: 0.2),
                                      child: Icon(
                                        item.isRead
                                            ? Icons.done_all
                                            : Icons.notifications_rounded,
                                        color: item.isRead ? Colors.white38 : NGColors.gold,
                                        size: 18,
                                      ),
                                    ),
                                    title: Text(
                                      item.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: item.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: item.message != null
                                        ? Text(
                                            item.message!,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.5),
                                              fontSize: 12,
                                            ),
                                          )
                                        : null,
                                    trailing: item.isRead
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.check_circle_outline,
                                                color: NGColors.gold, size: 20),
                                            onPressed: () => vm.markAsRead(item.id),
                                          ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Create Board Dialog ───────────────────────────────────────────────────
  void _showCreateBoardDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int selectedColor = 0xFFD4AF37;
    bool isSubmitting = false;

    final colorOptions = [
      0xFFD4AF37,
      0xFFB76E79,
      0xFF0F52BA,
      0xFF046307,
      0xFF9B1B30,
      0xFF6B46C1,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Project Board',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Board Title',
                    labelStyle: TextStyle(color: Colors.white60),
                    hintText: 'e.g. Bridal Collection Launch',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white60),
                    hintText: 'Brief summary of board tasks',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Accent Theme',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: colorOptions.map((c) {
                    final isSel = selectedColor == c;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: isSel
                              ? Border.all(color: Colors.white, width: 2.5)
                              : null,
                        ),
                        child: isSel
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      setDialogState(() => isSubmitting = true);

                      final boardVm = context.read<BoardViewModel>();
                      final newBoard = await boardVm.createBoardVariant1(
                        name: name,
                        description: descCtrl.text.trim(),
                        color: selectedColor,
                        lists: ['To Do', 'In Progress', 'Done'],
                      );

                      if (!mounted) return;
                      Navigator.pop(ctx);

                      if (newBoard != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Board "${newBoard.name}" created!'),
                            backgroundColor: NGColors.emerald,
                          ),
                        );
                        _loadData();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(boardVm.errorMessage ?? 'Failed to create board'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: NGColors.gold,
                foregroundColor: Colors.black,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('CREATE BOARD', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _openBoard(BuildContext context, BoardModel board) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BoardScreen(
          boardModel: board,
          state: widget.state,
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthViewModel>().logout();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => LoginScreen(state: widget.state),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boardVm = context.watch<BoardViewModel>();
    final notifVm = context.watch<NotificationViewModel>();
    final authVm = context.watch<AuthViewModel>();

    final boards = boardVm.boards;
    final dashboard = boardVm.dashboardData;

    return Scaffold(
      backgroundColor: NGColors.obsidian,
      body: RefreshIndicator(
        color: NGColors.gold,
        backgroundColor: const Color(0xFF141414),
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, authVm, notifVm),
            _buildStatsRow(dashboard, boards.length),
            _buildSectionHeader(context, boardVm),
            boardVm.isLoading && boards.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: NGColors.gold),
                    ),
                  )
                : boards.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState(context))
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.80,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final board = boards[i];
                              return _ApiBoardCard(
                                board: board,
                                onTap: () => _openBoard(context, board),
                              );
                            },
                            childCount: boards.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBoardDialog(context),
        backgroundColor: NGColors.gold,
        foregroundColor: Colors.black,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text(
          'New Board',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    AuthViewModel authVm,
    NotificationViewModel notifVm,
  ) {
    final userName = authVm.currentUser?.name.isNotEmpty == true
        ? authVm.currentUser!.name
        : 'Admin';
    final userInitial = userName[0].toUpperCase();

    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0D0D0D),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D0D0D), Color(0xFF1A1400)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        NGColors.gold.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            width: 130,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                          const Spacer(),
                          _AppBarBtn(
                            icon: Icons.search_rounded,
                            onTap: _openSearchSheet,
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _AppBarBtn(
                                icon: Icons.notifications_none_rounded,
                                onTap: _openNotificationsSheet,
                              ),
                              if (notifVm.unreadCount > 0)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: NGColors.ruby,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${notifVm.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _logout(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: NGColors.gold.withValues(alpha: 0.4)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          NGColors.gold,
                                          NGColors.goldDark,
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        userInitial,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Operations Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Live synced with Nakshatra Project API',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
      ),
    );
  }

  Widget _buildStatsRow(DashboardModel? dashboard, int fallbackBoardsCount) {
    final totalBoards = dashboard?.totalBoards ?? fallbackBoardsCount;
    final totalTasks = dashboard?.totalTasks ?? 0;
    final completed = dashboard?.completedTasks ?? 0;
    final pending = dashboard?.pendingTasks ?? 0;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '$totalBoards',
                label: 'BOARDS',
                icon: Icons.dashboard_outlined,
                accentColor: NGColors.gold,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '$totalTasks',
                label: 'TOTAL TASKS',
                icon: Icons.assignment_outlined,
                accentColor: NGColors.sapphire,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '$completed',
                label: 'COMPLETED',
                icon: Icons.task_alt_outlined,
                accentColor: NGColors.emerald,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                value: '$pending',
                label: 'PENDING',
                icon: Icons.hourglass_top_outlined,
                accentColor: NGColors.rose,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, BoardViewModel boardVm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Project Workspaces',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                if (boardVm.searchQuery != null && boardVm.searchQuery!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => boardVm.searchBoards(''),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: NGColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text('Filter: "${boardVm.searchQuery}"',
                              style: const TextStyle(color: NGColors.gold, fontSize: 11)),
                          const SizedBox(width: 4),
                          const Icon(Icons.close, size: 12, color: NGColors.gold),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 20),
              onPressed: _loadData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              border: Border.all(
                color: NGColors.gold.withValues(alpha: 0.2),
                width: 1.5,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.diamond_outlined,
              size: 52,
              color: NGColors.gold.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No boards found',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first workspace board via API to begin',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => _showCreateBoardDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NGColors.gold, NGColors.goldDark],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Create Board',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiBoardCard extends StatelessWidget {
  final BoardModel board;
  final VoidCallback onTap;

  const _ApiBoardCard({required this.board, required this.onTap});

  Color _resolveColor() {
    if (board.color != null && board.color != 0) {
      return Color(board.color!);
    }
    if (board.colour != null && board.colour!.isNotEmpty) {
      try {
        final hex = board.colour!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return NGColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _resolveColor();
    final taskCount = board.lists?.fold<int>(
            0, (sum, list) => sum + list.tasks.length) ??
        0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accent.withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 4,
                child: Container(color: accent),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.dashboard_rounded, color: accent, size: 20),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      board.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (board.description != null && board.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        board.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.checklist_rounded,
                            size: 13, color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          '$taskCount tasks',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: accent.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
