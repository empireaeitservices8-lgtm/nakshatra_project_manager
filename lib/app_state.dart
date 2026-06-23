import 'package:flutter/material.dart';
import 'models.dart';

// Gold palette constants
class NGColors {
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF0C040);
  static const goldDark = Color(0xFFA67C2E);
  static const champagne = Color(0xFFF5D78E);
  static const obsidian = Color(0xFF0A0A0A);
  static const charcoal = Color(0xFF1A1A1A);
  static const graphite = Color(0xFF2A2A2A);
  static const rose = Color(0xFFB76E79);
  static const platinum = Color(0xFFE5E4E2);
  static const ruby = Color(0xFF9B1B30);
  static const emerald = Color(0xFF046307);
  static const sapphire = Color(0xFF0F52BA);
}

class AppState extends ChangeNotifier {
  final List<KanbanBoard> boards;

  AppState() : boards = _sampleBoards();

  // ─── Sample Data ───────────────────────────────────────────────────────────
  static List<KanbanBoard> _sampleBoards() {
    return [
      KanbanBoard(
        id: '1',
        title: 'Bridal Collection Launch',
        color: NGColors.gold,
        description: 'Q1 Bridal jewellery campaign',
        lists: [
          KanbanList(id: 'l1', title: 'Planning', cards: [
            KanbanCard(
              id: 'c1',
              title: 'Necklace design finalisation',
              description: 'Approve 22K gold Kundan necklace prototypes for bridal line',
              labelColor: NGColors.gold,
              labelText: 'Design',
              dueDate: DateTime.now().add(const Duration(days: 7)),
              checklist: [
                ChecklistItem(id: 'ch1', title: 'Sketch approvals', isDone: true),
                ChecklistItem(id: 'ch2', title: 'CAD modelling', isDone: false),
                ChecklistItem(id: 'ch3', title: 'Sample casting', isDone: false),
              ],
            ),
            KanbanCard(
              id: 'c2',
              title: 'Photography shoot schedule',
              labelColor: NGColors.rose,
              labelText: 'Marketing',
              description: 'Book studio, models and photographer for bridal lookbook',
            ),
            KanbanCard(
              id: 'c12',
              title: 'Packaging design',
              labelColor: NGColors.goldDark,
              labelText: 'Branding',
              description: 'Premium black and gold gift boxes with embossed logo',
            ),
          ]),
          KanbanList(id: 'l2', title: 'In Progress', cards: [
            KanbanCard(
              id: 'c3',
              title: 'Diamond sourcing — GIA certified',
              labelColor: NGColors.sapphire,
              labelText: 'Procurement',
              description: 'Source VS1 round brilliant diamonds from Surat suppliers',
              dueDate: DateTime.now().add(const Duration(days: 3)),
              checklist: [
                ChecklistItem(id: 'ch6', title: 'Vendor shortlist', isDone: true),
                ChecklistItem(id: 'ch7', title: 'Sample inspection', isDone: true),
                ChecklistItem(id: 'ch8', title: 'Purchase order', isDone: false),
              ],
            ),
          ]),
          KanbanList(id: 'l3', title: 'Quality Check', cards: [
            KanbanCard(
              id: 'c4',
              title: 'Hallmarking compliance',
              labelColor: NGColors.ruby,
              labelText: 'Compliance',
              description: 'Ensure BIS hallmarking on all 22K pieces',
              dueDate: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ]),
          KanbanList(id: 'l4', title: 'Launched', cards: [
            KanbanCard(
              id: 'c5',
              title: 'Solitaire ring collection',
              labelColor: NGColors.emerald,
              labelText: 'Complete',
              checklist: [
                ChecklistItem(id: 'ch4', title: 'Production complete', isDone: true),
                ChecklistItem(id: 'ch5', title: 'Listed on website', isDone: true),
              ],
            ),
            KanbanCard(
              id: 'c13',
              title: 'Nakshatra Classics relaunch',
              labelColor: NGColors.goldDark,
              labelText: 'Complete',
            ),
          ]),
        ],
      ),
      KanbanBoard(
        id: '2',
        title: 'Digital Marketing',
        color: NGColors.rose,
        description: 'Online brand presence & campaigns',
        lists: [
          KanbanList(id: 'l5', title: 'Ideas', cards: [
            KanbanCard(
              id: 'c6',
              title: 'Instagram Reels — making process',
              labelColor: NGColors.rose,
              labelText: 'Social Media',
              description: 'Behind-the-scenes of master craftsmen at work',
            ),
            KanbanCard(
              id: 'c14',
              title: 'Celebrity endorsement pitch',
              labelColor: NGColors.gold,
              labelText: 'Partnership',
            ),
          ]),
          KanbanList(id: 'l6', title: 'Scheduled', cards: [
            KanbanCard(
              id: 'c7',
              title: 'Email campaign — Diwali collection',
              labelColor: NGColors.sapphire,
              labelText: 'Email',
              dueDate: DateTime.now().add(const Duration(days: 14)),
              checklist: [
                ChecklistItem(id: 'ch9', title: 'Copy & design', isDone: false),
                ChecklistItem(id: 'ch10', title: 'A/B subject test', isDone: false),
              ],
            ),
          ]),
          KanbanList(id: 'l7', title: 'In Progress', cards: [
            KanbanCard(
              id: 'c15',
              title: 'Website homepage redesign',
              labelColor: NGColors.goldDark,
              labelText: 'Web',
              dueDate: DateTime.now().add(const Duration(days: 5)),
            ),
          ]),
          KanbanList(id: 'l11', title: 'Live', cards: [
            KanbanCard(
              id: 'c16',
              title: 'Google Shopping ads — rings',
              labelColor: NGColors.emerald,
              labelText: 'Ads',
            ),
          ]),
        ],
      ),
      KanbanBoard(
        id: '3',
        title: 'Store Operations',
        color: NGColors.graphite,
        description: 'Retail & inventory management',
        lists: [
          KanbanList(id: 'l8', title: 'To Do', cards: [
            KanbanCard(
              id: 'c8',
              title: 'POS system upgrade',
              labelColor: NGColors.gold,
              labelText: 'Technology',
              description: 'Integrate GST billing with new inventory software',
            ),
            KanbanCard(
              id: 'c9',
              title: 'Staff training — new collections',
              labelColor: NGColors.sapphire,
              labelText: 'Training',
              description: 'Educate sales staff on diamond 4C grading',
              checklist: [
                ChecklistItem(id: 'ch11', title: 'Mumbai store', isDone: false),
                ChecklistItem(id: 'ch12', title: 'Delhi store', isDone: false),
                ChecklistItem(id: 'ch13', title: 'Bangalore store', isDone: false),
              ],
            ),
          ]),
          KanbanList(id: 'l9', title: 'In Progress', cards: [
            KanbanCard(
              id: 'c10',
              title: 'Inventory audit — Q1',
              labelColor: NGColors.ruby,
              labelText: 'Operations',
              description: 'Full stock count across all showrooms',
              dueDate: DateTime.now().add(const Duration(days: 2)),
            ),
          ]),
          KanbanList(id: 'l10', title: 'Done', cards: [
            KanbanCard(
              id: 'c11',
              title: 'Security system upgrade',
              labelColor: NGColors.emerald,
              labelText: 'Complete',
            ),
            KanbanCard(
              id: 'c17',
              title: 'Display counter refurbishment',
              labelColor: NGColors.goldDark,
              labelText: 'Complete',
            ),
          ]),
        ],
      ),
      KanbanBoard(
        id: '4',
        title: 'Design Studio',
        color: Color(0xFF4A3728),
        description: 'Custom & bespoke jewellery orders',
        lists: [
          KanbanList(id: 'l12', title: 'Consultation', cards: [
            KanbanCard(
              id: 'c18',
              title: 'Mehta family — wedding set',
              labelColor: NGColors.gold,
              labelText: 'Bespoke',
            ),
            KanbanCard(
              id: 'c19',
              title: 'Anniversary pendant — client R.K.',
              labelColor: NGColors.rose,
              labelText: 'Custom',
            ),
          ]),
          KanbanList(id: 'l13', title: 'Crafting', cards: [
            KanbanCard(
              id: 'c20',
              title: 'Polki diamond choker — Mrs. Sharma',
              labelColor: NGColors.sapphire,
              labelText: 'In Workshop',
              description: 'Hand-set uncut diamonds in 22K yellow gold',
              checklist: [
                ChecklistItem(id: 'ch14', title: 'Gold framework cast', isDone: true),
                ChecklistItem(id: 'ch15', title: 'Stone setting', isDone: true),
                ChecklistItem(id: 'ch16', title: 'Enamel work', isDone: false),
                ChecklistItem(id: 'ch17', title: 'Final polishing', isDone: false),
              ],
            ),
          ]),
          KanbanList(id: 'l14', title: 'Approval', cards: []),
          KanbanList(id: 'l15', title: 'Delivered', cards: [
            KanbanCard(
              id: 'c21',
              title: 'Emerald cocktail ring — Dubai export',
              labelColor: NGColors.emerald,
              labelText: 'Delivered',
            ),
          ]),
        ],
      ),
    ];
  }

  // ─── Board Operations ──────────────────────────────────────────────────────

  void addBoard(KanbanBoard board) {
    boards.add(board);
    notifyListeners();
  }

  void deleteBoard(String boardId) {
    boards.removeWhere((b) => b.id == boardId);
    notifyListeners();
  }

  void updateBoardTitle(String boardId, String title) {
    final board = _findBoard(boardId);
    board?.title = title;
    notifyListeners();
  }

  // ─── List Operations ───────────────────────────────────────────────────────

  void addList(String boardId, KanbanList list) {
    _findBoard(boardId)?.lists.add(list);
    notifyListeners();
  }

  void deleteList(String boardId, String listId) {
    _findBoard(boardId)?.lists.removeWhere((l) => l.id == listId);
    notifyListeners();
  }

  void renameList(String boardId, String listId, String newTitle) {
    _findList(boardId, listId)?.title = newTitle;
    notifyListeners();
  }

  // ─── Card Operations ───────────────────────────────────────────────────────

  void addCard(String boardId, String listId, KanbanCard card) {
    _findList(boardId, listId)?.cards.add(card);
    notifyListeners();
  }

  void deleteCard(String boardId, String listId, String cardId) {
    _findList(boardId, listId)?.cards.removeWhere((c) => c.id == cardId);
    notifyListeners();
  }

  void updateCard(String boardId, String listId, KanbanCard card) {
    final list = _findList(boardId, listId);
    if (list == null) return;
    final idx = list.cards.indexWhere((c) => c.id == card.id);
    if (idx != -1) list.cards[idx] = card;
    notifyListeners();
  }

  void moveCard({
    required String boardId,
    required String fromListId,
    required String toListId,
    required KanbanCard card,
  }) {
    if (fromListId == toListId) return;
    final board = _findBoard(boardId);
    if (board == null) return;
    final fromList = board.lists.firstWhere((l) => l.id == fromListId);
    final toList = board.lists.firstWhere((l) => l.id == toListId);
    fromList.cards.remove(card);
    toList.cards.add(card);
    notifyListeners();
  }

  void notify() => notifyListeners();

  // ─── Helpers ───────────────────────────────────────────────────────────────

  KanbanBoard? _findBoard(String id) {
    try {
      return boards.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  KanbanList? _findList(String boardId, String listId) {
    try {
      return _findBoard(boardId)?.lists.firstWhere((l) => l.id == listId);
    } catch (_) {
      return null;
    }
  }
}
