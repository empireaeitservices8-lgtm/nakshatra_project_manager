import 'package:flutter/material.dart';
import 'dart:math';
import 'models.dart';
import 'app_state.dart';
import 'app_state.dart' show NGColors;
import 'board_screen.dart';
import 'login_screen.dart';

// ────────────────────────────────────────────────────────────────────────────
//  HOME SCREEN
// ────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatelessWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  String _uid() =>
      '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NGColors.obsidian,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildStatsRow(),
          _buildSectionHeader(context),
          state.boards.isEmpty
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
                      (context, i) => _BoardCard(
                        board: state.boards[i],
                        onTap: () => _openBoard(context, state.boards[i]),
                        onDelete: () => state.deleteBoard(state.boards[i].id),
                      ),
                      childCount: state.boards.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBoardDialog(context),
        backgroundColor: NGColors.gold,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New Board',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5),
        ),
      ),
    );
  }

  // ─── Sliver App Bar ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
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
              // Gold top-right orb
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
                        NGColors.gold.withOpacity(0.14),
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
                          // Brand logo
                          Image.asset(
                            'assets/images/logo.png',
                            width: 140,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 10),

                          const Spacer(),
                          _AppBarBtn(icon: Icons.search_rounded, onTap: () {}),
                          const SizedBox(width: 8),
                          _AppBarBtn(
                              icon: Icons.notifications_none_rounded,
                              onTap: () {}),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _logout(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: NGColors.gold.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          NGColors.gold,
                                          NGColors.goldDark
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('A',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('Admin',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(height: 20),
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
                        'Manage your jewellery business workflows',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
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

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a1, a2) => LoginScreen(state: state),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ─── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final totalCards = state.boards.fold<int>(0, (s, b) => s + b.totalCards);
    final totalLists = state.boards.fold<int>(0, (s, b) => s + b.lists.length);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          children: [
            Expanded(
                child: _StatCard(
                    value: '${state.boards.length}',
                    label: 'Boards',
                    icon: Icons.dashboard_rounded,
                    accentColor: NGColors.gold)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    value: '$totalLists',
                    label: 'Lists',
                    icon: Icons.view_column_rounded,
                    accentColor: NGColors.rose)),
            const SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    value: '$totalCards',
                    label: 'Tasks',
                    icon: Icons.task_alt_rounded,
                    accentColor: NGColors.champagne)),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [NGColors.gold, NGColors.goldDark],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Project Boards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            Text(
              '${state.boards.length} active',
              style: TextStyle(
                fontSize: 12,
                color: NGColors.gold.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              border:
                  Border.all(color: NGColors.gold.withOpacity(0.2), width: 1.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.diamond_outlined,
                size: 52, color: NGColors.gold.withOpacity(0.4)),
          ),
          const SizedBox(height: 24),
          const Text('No boards yet',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Create your first project board to begin',
            style:
                TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13),
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
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation & Dialogs ──────────────────────────────────────────────────
  void _openBoard(BuildContext context, KanbanBoard board) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => BoardScreen(board: board, state: state)),
    );
  }

  void _showCreateBoardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CreateBoardDialog(
        onCreate: (title, color) {
          final id = _uid();
          state.addBoard(KanbanBoard(
            id: id,
            title: title,
            color: color,
            lists: [
              KanbanList(id: '${id}a', title: 'To Do'),
              KanbanList(id: '${id}b', title: 'In Progress'),
              KanbanList(id: '${id}c', title: 'Done'),
            ],
          ));
        },
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  STAT CARD
// ────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color accentColor;

  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: accentColor)),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.35),
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  BOARD CARD
// ────────────────────────────────────────────────────────────────────────────
class _BoardCard extends StatelessWidget {
  final KanbanBoard board;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BoardCard(
      {required this.board, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isGoldBoard = board.color == NGColors.gold;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF141414),
          border: Border.all(
            color: board.color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: board.color.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Top gold gradient bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [board.color, board.color.withOpacity(0.4)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),

            // Subtle orb
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      board.color.withOpacity(0.09),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: board.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: board.color.withOpacity(0.25)),
                        ),
                        child: Icon(Icons.view_kanban_rounded,
                            color: board.color, size: 16),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.white.withOpacity(0.3),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    board.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (board.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      board.description,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 10,
                          letterSpacing: 0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Progress bar
                  _ListPreviewBar(board: board, color: board.color),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _MiniChip('${board.totalCards}', Icons.task_alt_rounded,
                          board.color),
                      const SizedBox(width: 6),
                      _MiniChip('${board.lists.length}',
                          Icons.view_column_rounded, board.color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _DarkDialog(
        title: 'Delete Board?',
        content: 'Remove "${board.title}"? This cannot be undone.',
        onConfirm: () {
          Navigator.pop(context);
          onDelete();
        },
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _MiniChip(this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ListPreviewBar extends StatelessWidget {
  final KanbanBoard board;
  final Color color;
  const _ListPreviewBar({required this.board, required this.color});

  @override
  Widget build(BuildContext context) {
    final total = board.lists.fold<int>(0, (s, l) => s + l.activeCards.length);
    if (total == 0 || board.lists.isEmpty) return const SizedBox.shrink();

    return Row(
      children: board.lists.map((l) {
        final fraction = total > 0 ? l.activeCards.length / total : 0.0;
        return Flexible(
          flex: ((fraction * 100).round()).clamp(1, 100),
          child: Container(
            height: 3,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  APP BAR ICON BUTTON
// ────────────────────────────────────────────────────────────────────────────
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
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  DARK DIALOG
// ────────────────────────────────────────────────────────────────────────────
class _DarkDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const _DarkDialog(
      {required this.title, required this.content, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(content,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.white.withOpacity(0.4))),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onConfirm,
                  child: const Text('Delete',
                      style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  CREATE BOARD DIALOG
// ────────────────────────────────────────────────────────────────────────────
class CreateBoardDialog extends StatefulWidget {
  final Function(String title, Color color) onCreate;
  const CreateBoardDialog({super.key, required this.onCreate});

  @override
  State<CreateBoardDialog> createState() => _CreateBoardDialogState();
}

class _CreateBoardDialogState extends State<CreateBoardDialog> {
  final _ctrl = TextEditingController();
  Color _selected = NGColors.gold;

  static const _palette = [
    NGColors.gold,
    NGColors.rose,
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF4A3728),
    Color(0xFF06B6D4),
    NGColors.goldDark,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: NGColors.gold.withOpacity(0.2), width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview strip
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [_selected, _selected.withOpacity(0.3)]),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('New Project Board',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Name your board and choose a colour.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.35), fontSize: 12)),
            const SizedBox(height: 20),

            // Name field
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: NGColors.gold.withOpacity(0.2), width: 1),
              ),
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: NGColors.gold,
                decoration: InputDecoration(
                  hintText: 'Board name...',
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.25), fontSize: 14),
                  prefixIcon: Icon(Icons.view_kanban_rounded,
                      color: NGColors.gold.withOpacity(0.6), size: 18),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
                ),
                autofocus: true,
              ),
            ),

            const SizedBox(height: 20),
            Text('Colour',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _palette.map((c) {
                final sel = _selected == c;
                return GestureDetector(
                  onTap: () => setState(() => _selected = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: sel
                          ? Border.all(color: Colors.white, width: 2.5)
                          : Border.all(
                              color: Colors.white.withOpacity(0.1), width: 1),
                      boxShadow: sel
                          ? [
                              BoxShadow(
                                  color: c.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1)
                            ]
                          : null,
                    ),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13)),
                    child: Text('Cancel',
                        style: TextStyle(color: Colors.white.withOpacity(0.4))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_ctrl.text.trim().isNotEmpty) {
                        widget.onCreate(_ctrl.text.trim(), _selected);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_selected, _selected.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Create',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
