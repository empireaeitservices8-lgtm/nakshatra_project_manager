import 'package:flutter/material.dart';
import 'models.dart';
import 'app_state.dart';
import 'app_state.dart' show NGColors;

// ────────────────────────────────────────────────────────────────────────────
//  CARD DETAIL SHEET — Dark Gold Theme
// ────────────────────────────────────────────────────────────────────────────
class CardDetailSheet extends StatefulWidget {
  final KanbanCard card;
  final KanbanList list;
  final KanbanBoard board;
  final AppState state;

  const CardDetailSheet({
    super.key,
    required this.card,
    required this.list,
    required this.board,
    required this.state,
  });

  @override
  State<CardDetailSheet> createState() => _CardDetailSheetState();
}

class _CardDetailSheetState extends State<CardDetailSheet> {
  late KanbanCard _card;
  bool _editingTitle = false;
  bool _editingDesc = false;
  bool _addingCheckItem = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _checkCtrl = TextEditingController();

  static const _labelColors = [
    NGColors.gold,
    NGColors.rose,
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF84CC16),
  ];
  static const _labelTexts = [
    'Design',
    'Marketing',
    'Feature',
    'Complete',
    'Review',
    'Urgent',
    'Strategy',
    'Architecture',
    'Procurement',
    'Testing',
  ];

  @override
  void initState() {
    super.initState();
    _card = widget.card;
    _titleCtrl.text = _card.title;
    _descCtrl.text = _card.description;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  void _save() =>
      widget.state.updateCard(widget.board.id, widget.list.id, _card);

  String _uid() => DateTime.now().millisecondsSinceEpoch.toString();

  Color get _accent => widget.board.color;

  @override
  Widget build(BuildContext context) {
    final isOverdue =
        _card.dueDate != null && _card.dueDate!.isBefore(DateTime.now());
    final hasLabel = _card.labelColor != Colors.transparent;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, sc) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
                color: _accent.withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────────────
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Top accent bar ────────────────────────────────────────
              if (hasLabel) ...[
                const SizedBox(height: 10),
                Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _card.labelColor,
                      _card.labelColor.withOpacity(0.3)
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 10),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _accent,
                      _accent.withOpacity(0.2)
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],

              // ── Scrollable body ───────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: sc,
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: [
                    _buildTitleSection(),
                    _SheetDivider(),
                    _buildLabelsSection(),
                    _SheetDivider(),
                    _buildDueDateSection(isOverdue),
                    _SheetDivider(),
                    _buildDescriptionSection(),
                    _SheetDivider(),
                    _buildChecklistSection(),
                    _SheetDivider(),
                    _buildActionsSection(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Title ─────────────────────────────────────────────────────────────────
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.task_alt_rounded,
                  color: _accent.withOpacity(0.7), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _editingTitle
                  ? TextField(
                      controller: _titleCtrl,
                      autofocus: true,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      cursorColor: _accent,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1))),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: _accent, width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      onSubmitted: (_) => _saveTitle(),
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _editingTitle = true),
                      child: Text(
                        _card.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 5),
          child: Row(
            children: [
              Icon(Icons.folder_outlined,
                  size: 12,
                  color: Colors.white.withOpacity(0.25)),
              const SizedBox(width: 4),
              Text(
                widget.list.title,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ],
          ),
        ),
        if (_editingTitle) ...[
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                _DarkActionBtn(
                    label: 'Save', color: _accent, onTap: _saveTitle),
                const SizedBox(width: 8),
                _DarkActionBtn(
                    label: 'Cancel',
                    color: Colors.white.withOpacity(0.2),
                    onTap: () =>
                        setState(() => _editingTitle = false)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _saveTitle() {
    if (_titleCtrl.text.trim().isNotEmpty) {
      setState(() {
        _card.title = _titleCtrl.text.trim();
        _editingTitle = false;
      });
      _save();
    }
  }

  // ─── Labels ────────────────────────────────────────────────────────────────
  Widget _buildLabelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DarkSectionHeader(icon: Icons.label_outline_rounded, title: 'Label', accent: _accent),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // None option
            GestureDetector(
              onTap: () {
                setState(() {
                  _card.labelColor = Colors.transparent;
                  _card.labelText = '';
                });
                _save();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _card.labelColor == Colors.transparent
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Text('None',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12)),
              ),
            ),
            ...List.generate(
              _labelColors.length,
              (i) {
                final isSelected = _card.labelColor == _labelColors[i];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _card.labelColor = _labelColors[i];
                      _card.labelText = _labelTexts[i];
                    });
                    _save();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _labelColors[i]
                          .withOpacity(isSelected ? 0.2 : 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _labelColors[i]
                            : _labelColors[i].withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Icon(Icons.check,
                              size: 12,
                              color: _labelColors[i]),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          _labelTexts[i],
                          style: TextStyle(
                            color: _labelColors[i],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ─── Due Date ──────────────────────────────────────────────────────────────
  Widget _buildDueDateSection(bool isOverdue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DarkSectionHeader(
            icon: Icons.calendar_today_outlined,
            title: 'Due Date',
            accent: _accent),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_card.dueDate != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isOverdue
                        ? Colors.red.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14,
                        color: isOverdue ? Colors.red : Colors.green),
                    const SizedBox(width: 6),
                    Text(
                      _fmtFull(_card.dueDate!),
                      style: TextStyle(
                          color:
                              isOverdue ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() => _card.dueDate = null);
                        _save();
                      },
                      child: Icon(Icons.close,
                          size: 14,
                          color: Colors.white.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_calendar_outlined,
                        size: 14,
                        color: _accent.withOpacity(0.8)),
                    const SizedBox(width: 6),
                    Text(
                      _card.dueDate == null ? 'Set Date' : 'Change',
                      style: TextStyle(
                          color: _accent.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (_card.dueDate != null && isOverdue) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 13, color: Colors.red),
              const SizedBox(width: 5),
              Text('Overdue',
                  style: TextStyle(
                      color: Colors.red.withOpacity(0.8), fontSize: 12)),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _card.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: _accent,
            surface: const Color(0xFF1A1A1A),
          ),
          dialogBackgroundColor: const Color(0xFF1A1A1A),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      setState(() => _card.dueDate = d);
      _save();
    }
  }

  // ─── Description ───────────────────────────────────────────────────────────
  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DarkSectionHeader(
            icon: Icons.notes_rounded,
            title: 'Description',
            accent: _accent),
        const SizedBox(height: 12),
        if (_editingDesc) ...[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withOpacity(0.4), width: 1),
            ),
            child: TextField(
              controller: _descCtrl,
              maxLines: 5,
              minLines: 3,
              autofocus: true,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.5),
              cursorColor: _accent,
              decoration: InputDecoration(
                hintText: 'Add a description...',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.2), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _DarkActionBtn(
                  label: 'Save',
                  color: _accent,
                  onTap: () {
                    setState(() {
                      _card.description = _descCtrl.text;
                      _editingDesc = false;
                    });
                    _save();
                  }),
              const SizedBox(width: 8),
              _DarkActionBtn(
                  label: 'Cancel',
                  color: Colors.white.withOpacity(0.15),
                  onTap: () =>
                      setState(() => _editingDesc = false)),
            ],
          ),
        ] else ...[
          GestureDetector(
            onTap: () => setState(() => _editingDesc = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.07), width: 1),
              ),
              child: Text(
                _card.description.isEmpty
                    ? 'Tap to add a description...'
                    : _card.description,
                style: TextStyle(
                  color: _card.description.isEmpty
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.65),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Checklist ─────────────────────────────────────────────────────────────
  Widget _buildChecklistSection() {
    final total = _card.checklistTotal;
    final done = _card.checklistDone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _DarkSectionHeader(
                  icon: Icons.checklist_rounded,
                  title: 'Checklist',
                  accent: _accent),
            ),
            if (total > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: done == total
                      ? Colors.green.withOpacity(0.12)
                      : _accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: done == total
                        ? Colors.green.withOpacity(0.3)
                        : _accent.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$done / $total',
                  style: TextStyle(
                      color:
                          done == total ? Colors.green : _accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        if (total > 0) ...[
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                width: (MediaQuery.of(context).size.width - 40) *
                    (total > 0 ? done / total : 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: done == total
                        ? [Colors.green, Colors.green.shade300]
                        : [_accent, _accent.withOpacity(0.5)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        ..._card.checklist.map((item) => _DarkChecklistRow(
              item: item,
              accent: _accent,
              onToggle: (v) {
                setState(() => item.isDone = v);
                _save();
              },
              onDelete: () {
                setState(() => _card.checklist.remove(item));
                _save();
              },
            )),
        if (_addingCheckItem) ...[
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _accent.withOpacity(0.3), width: 1),
                  ),
                  child: TextField(
                    controller: _checkCtrl,
                    autofocus: true,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                    cursorColor: _accent,
                    decoration: InputDecoration(
                      hintText: 'Add item...',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _submitCheckItem(),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _submitCheckItem,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.green.withOpacity(0.3), width: 1),
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.green, size: 16),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  _checkCtrl.clear();
                  setState(() => _addingCheckItem = false);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.25), width: 1),
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.red, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ] else ...[
          TextButton.icon(
            onPressed: () =>
                setState(() => _addingCheckItem = true),
            icon: Icon(Icons.add_rounded,
                size: 15,
                color: _accent.withOpacity(0.7)),
            label: Text('Add item',
                style: TextStyle(
                    fontSize: 13,
                    color: _accent.withOpacity(0.7))),
            style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 0)),
          ),
        ],
      ],
    );
  }

  void _submitCheckItem() {
    if (_checkCtrl.text.trim().isNotEmpty) {
      setState(() {
        _card.checklist.add(ChecklistItem(
            id: _uid(), title: _checkCtrl.text.trim()));
        _checkCtrl.clear();
        _addingCheckItem = false;
      });
      _save();
    }
  }

  // ─── Actions ───────────────────────────────────────────────────────────────
  Widget _buildActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DarkSectionHeader(
            icon: Icons.bolt_rounded, title: 'Actions', accent: _accent),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            widget.state.deleteCard(
                widget.board.id, widget.list.id, _card.id);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.red.withOpacity(0.2), width: 1),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded,
                    color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('Delete Task',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────
  String _fmtFull(DateTime d) {
    const m = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  DARK CHECKLIST ROW
// ────────────────────────────────────────────────────────────────────────────
class _DarkChecklistRow extends StatelessWidget {
  final ChecklistItem item;
  final Color accent;
  final Function(bool) onToggle;
  final VoidCallback onDelete;

  const _DarkChecklistRow({
    required this.item,
    required this.accent,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: item.isDone ? Colors.green.withOpacity(0.04) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.85,
            child: Checkbox(
              value: item.isDone,
              onChanged: (v) => onToggle(v ?? false),
              activeColor: accent,
              checkColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.25)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                decoration:
                    item.isDone ? TextDecoration.lineThrough : null,
                color: item.isDone
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.75),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close,
                  size: 14,
                  color: Colors.white.withOpacity(0.2)),
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  SHARED WIDGETS
// ────────────────────────────────────────────────────────────────────────────
class _DarkSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent;

  const _DarkSectionHeader(
      {required this.icon, required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: accent.withOpacity(0.8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white,
              letterSpacing: 0.3),
        ),
      ],
    );
  }
}

class _SheetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          height: 1,
          color: Colors.white.withOpacity(0.05),
        ),
      );
}

class _DarkActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DarkActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }
}
