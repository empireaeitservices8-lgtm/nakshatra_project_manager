import 'package:flutter/material.dart';
import 'dart:math';
import 'models.dart';
import 'app_state.dart';
import 'app_state.dart' show NGColors;
import 'card_detail_sheet.dart';

// ────────────────────────────────────────────────────────────────────────────
//  BOARD SCREEN
// ────────────────────────────────────────────────────────────────────────────
class BoardScreen extends StatefulWidget {
  final KanbanBoard board;
  final AppState state;

  const BoardScreen({super.key, required this.board, required this.state});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String _uid() =>
      '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}';

  KanbanBoard get board => widget.board;
  AppState get state => widget.state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NGColors.obsidian,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              board.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '${board.lists.length} lists · ${board.totalCards} tasks',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 0.3),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [board.color, board.color.withOpacity(0.2)],
              ),
            ),
          ),
        ),
        actions: [
          _AppBarAction(
              icon: Icons.filter_list_rounded, onTap: () {}),
          _AppBarAction(
              icon: Icons.more_vert,
              onTap: () => _showBoardMenu(context)),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              board.color.withOpacity(0.05),
              NGColors.obsidian,
            ],
          ),
        ),
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
              itemCount: board.lists.length + 1,
              itemBuilder: (context, i) {
                if (i == board.lists.length) {
                  return _AddListColumn(
                    boardColor: board.color,
                    onAdd: (title) {
                      state.addList(board.id,
                          KanbanList(id: _uid(), title: title));
                    },
                  );
                }
                final list = board.lists[i];
                return KanbanListColumn(
                  key: ValueKey(list.id),
                  list: list,
                  board: board,
                  state: state,
                  onAddCard: (title) => state.addCard(
                      board.id, list.id, KanbanCard(id: _uid(), title: title)),
                  onDeleteList: () => state.deleteList(board.id, list.id),
                  onCardDropped: (card, fromListId) => state.moveCard(
                    boardId: board.id,
                    fromListId: fromListId,
                    toListId: list.id,
                    card: card,
                  ),
                  onCardTap: (card) => _openCardDetail(context, list, card),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openCardDetail(
      BuildContext context, KanbanList list, KanbanCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardDetailSheet(
          card: card, list: list, board: board, state: state),
    );
  }

  void _showBoardMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            _DarkMenuTile(
              icon: Icons.delete_outline,
              label: 'Delete Board',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                state.deleteBoard(board.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
      ),
    );
  }
}

class _DarkMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _DarkMenuTile(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white70;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label,
          style:
              TextStyle(color: c, fontWeight: FontWeight.w500, fontSize: 15)),
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  KANBAN LIST COLUMN
// ────────────────────────────────────────────────────────────────────────────
class KanbanListColumn extends StatefulWidget {
  final KanbanList list;
  final KanbanBoard board;
  final AppState state;
  final Function(String) onAddCard;
  final VoidCallback onDeleteList;
  final Function(KanbanCard card, String fromListId) onCardDropped;
  final Function(KanbanCard) onCardTap;

  const KanbanListColumn({
    super.key,
    required this.list,
    required this.board,
    required this.state,
    required this.onAddCard,
    required this.onDeleteList,
    required this.onCardDropped,
    required this.onCardTap,
  });

  @override
  State<KanbanListColumn> createState() => _KanbanListColumnState();
}

class _KanbanListColumnState extends State<KanbanListColumn> {
  bool _isDragTarget = false;

  @override
  Widget build(BuildContext context) {
    final cards = widget.list.activeCards;

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) =>
          details.data['fromListId'] != widget.list.id,
      onAcceptWithDetails: (details) {
        setState(() => _isDragTarget = false);
        widget.onCardDropped(
          details.data['card'] as KanbanCard,
          details.data['fromListId'] as String,
        );
      },
      onMove: (_) => setState(() => _isDragTarget = true),
      onLeave: (_) => setState(() => _isDragTarget = false),
      builder: (ctx, candidates, rejected) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 288,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: _isDragTarget
                ? widget.board.color.withOpacity(0.06)
                : const Color(0xFF141414),
            borderRadius: BorderRadius.circular(18),
            border: _isDragTarget
                ? Border.all(color: widget.board.color, width: 1.5)
                : Border.all(
                    color: widget.board.color.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ColumnHeader(
                list: widget.list,
                board: widget.board,
                cardCount: cards.length,
                onDelete: () => _confirmDelete(context),
                onRename: (newTitle) => widget.state
                    .renameList(widget.board.id, widget.list.id, newTitle),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.56,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  itemCount: cards.length,
                  itemBuilder: (ctx, i) => KanbanCardTile(
                    key: ValueKey(cards[i].id),
                    card: cards[i],
                    listId: widget.list.id,
                    boardColor: widget.board.color,
                    onTap: () => widget.onCardTap(cards[i]),
                  ),
                ),
              ),
              _AddCardInline(
                  onAdd: widget.onAddCard, boardColor: widget.board.color),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delete List?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                'Remove "${widget.list.title}" and all its cards?',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.45), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4)))),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onDeleteList();
                    },
                    child: const Text('Delete',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  COLUMN HEADER
// ────────────────────────────────────────────────────────────────────────────
class _ColumnHeader extends StatefulWidget {
  final KanbanList list;
  final KanbanBoard board;
  final int cardCount;
  final VoidCallback onDelete;
  final Function(String) onRename;

  const _ColumnHeader({
    required this.list,
    required this.board,
    required this.cardCount,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<_ColumnHeader> createState() => _ColumnHeaderState();
}

class _ColumnHeaderState extends State<_ColumnHeader> {
  bool _renaming = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.list.title);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        border: Border(
          bottom:
              BorderSide(color: widget.board.color.withOpacity(0.15), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Left accent line
          Container(
            width: 3,
            height: 18,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: widget.board.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: _renaming
                ? TextField(
                    controller: _ctrl,
                    autofocus: true,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: widget.board.color),
                    cursorColor: widget.board.color,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: widget.board.color)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: widget.board.color, width: 1.5)),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) widget.onRename(v.trim());
                      setState(() => _renaming = false);
                    },
                  )
                : GestureDetector(
                    onDoubleTap: () => setState(() => _renaming = true),
                    child: Row(
                      children: [
                        Text(
                          widget.list.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Colors.white,
                              letterSpacing: 0.3),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.board.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: widget.board.color.withOpacity(0.3),
                                width: 1),
                          ),
                          child: Text(
                            '${widget.cardCount}',
                            style: TextStyle(
                                color: widget.board.color,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                size: 16, color: Colors.white.withOpacity(0.35)),
            color: const Color(0xFF222222),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: Colors.white.withOpacity(0.08), width: 1)),
            onSelected: (v) {
              if (v == 'rename') setState(() => _renaming = true);
              if (v == 'delete') widget.onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'rename',
                  child: Row(children: [
                    Icon(Icons.edit_outlined,
                        size: 15, color: Colors.white.withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text('Rename',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13))
                  ])),
              PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline,
                        size: 15, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Delete',
                        style:
                            TextStyle(color: Colors.red, fontSize: 13))
                  ])),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  KANBAN CARD TILE
// ────────────────────────────────────────────────────────────────────────────
class KanbanCardTile extends StatelessWidget {
  final KanbanCard card;
  final String listId;
  final Color boardColor;
  final VoidCallback onTap;

  const KanbanCardTile({
    super.key,
    required this.card,
    required this.listId,
    required this.boardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      data: {'card': card, 'fromListId': listId},
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 268, child: _CardBody(card: card)),
      ),
      childWhenDragging:
          Opacity(opacity: 0.2, child: _CardBody(card: card)),
      child: GestureDetector(onTap: onTap, child: _CardBody(card: card)),
    );
  }
}

class _CardBody extends StatelessWidget {
  final KanbanCard card;
  const _CardBody({required this.card});

  @override
  Widget build(BuildContext context) {
    final hasLabel = card.labelColor != Colors.transparent;
    final hasDue = card.dueDate != null;
    final hasChecklist = card.checklist.isNotEmpty;
    final isOverdue = hasDue && card.dueDate!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasLabel
              ? card.labelColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label bar
          if (hasLabel)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: card.labelColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label badge
                if (card.labelText.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: card.labelColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: card.labelColor.withOpacity(0.25),
                          width: 1),
                    ),
                    child: Text(
                      card.labelText,
                      style: TextStyle(
                        color: card.labelColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                ],

                // Title
                Text(
                  card.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),

                // Description
                if (card.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    card.description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Meta row
                if (hasDue || hasChecklist) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (hasDue)
                        _MetaBadge(
                          icon: Icons.access_time_rounded,
                          label: _fmtDate(card.dueDate!),
                          color: isOverdue ? Colors.red : NGColors.champagne,
                          bg: isOverdue
                              ? Colors.red.withOpacity(0.1)
                              : NGColors.gold.withOpacity(0.08),
                          border: isOverdue
                              ? Colors.red.withOpacity(0.3)
                              : NGColors.gold.withOpacity(0.2),
                        ),
                      if (hasChecklist)
                        _MetaBadge(
                          icon: Icons.checklist_rounded,
                          label:
                              '${card.checklistDone}/${card.checklistTotal}',
                          color: card.checklistDone == card.checklistTotal
                              ? Colors.green
                              : Colors.white.withOpacity(0.5),
                          bg: card.checklistDone == card.checklistTotal
                              ? Colors.green.withOpacity(0.08)
                              : Colors.white.withOpacity(0.05),
                          border: card.checklistDone == card.checklistTotal
                              ? Colors.green.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${m[d.month - 1]} ${d.day}';
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final Color border;

  const _MetaBadge(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg,
      required this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  ADD CARD INLINE
// ────────────────────────────────────────────────────────────────────────────
class _AddCardInline extends StatefulWidget {
  final Function(String) onAdd;
  final Color boardColor;
  const _AddCardInline({required this.onAdd, required this.boardColor});

  @override
  State<_AddCardInline> createState() => _AddCardInlineState();
}

class _AddCardInlineState extends State<_AddCardInline> {
  bool _expanded = false;
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: _expanded
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: widget.boardColor.withOpacity(0.3), width: 1),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    cursorColor: widget.boardColor,
                    decoration: InputDecoration(
                      hintText: 'Task title...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.25), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_ctrl.text.trim().isNotEmpty) {
                            widget.onAdd(_ctrl.text.trim());
                            _ctrl.clear();
                            setState(() => _expanded = false);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [widget.boardColor, widget.boardColor.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('Add Task',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        _ctrl.clear();
                        setState(() => _expanded = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Icon(Icons.close,
                            size: 16,
                            color: Colors.white.withOpacity(0.4)),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : TextButton.icon(
              onPressed: () => setState(() => _expanded = true),
              icon: Icon(Icons.add_rounded,
                  size: 16, color: Colors.white.withOpacity(0.3)),
              label: Text('Add a task',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 0.3)),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
              ),
            ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  ADD LIST COLUMN
// ────────────────────────────────────────────────────────────────────────────
class _AddListColumn extends StatefulWidget {
  final Function(String) onAdd;
  final Color boardColor;
  const _AddListColumn({required this.onAdd, required this.boardColor});

  @override
  State<_AddListColumn> createState() => _AddListColumnState();
}

class _AddListColumnState extends State<_AddListColumn> {
  bool _expanded = false;
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      return GestureDetector(
        onTap: () => setState(() => _expanded = true),
        child: Container(
          width: 250,
          height: 52,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: widget.boardColor.withOpacity(0.25), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded,
                  color: widget.boardColor.withOpacity(0.6), size: 18),
              const SizedBox(width: 8),
              Text('Add list',
                  style: TextStyle(
                      color: widget.boardColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: widget.boardColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.35), blurRadius: 12)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: widget.boardColor.withOpacity(0.25), width: 1),
            ),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              cursorColor: widget.boardColor,
              decoration: InputDecoration(
                hintText: 'List name...',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.25), fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.boardColor,
                          widget.boardColor.withOpacity(0.7)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('Add List',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  setState(() => _expanded = false);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.close,
                      color: Colors.white.withOpacity(0.4), size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_ctrl.text.trim().isNotEmpty) {
      widget.onAdd(_ctrl.text.trim());
      _ctrl.clear();
      setState(() => _expanded = false);
    }
  }
}
