import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart' show NGColors;
import 'models/models.dart';
import 'viewmodels/viewmodels.dart';

// ────────────────────────────────────────────────────────────────────────────
//  CARD DETAIL SHEET — Connected to TaskViewModel API
// ────────────────────────────────────────────────────────────────────────────
class CardDetailSheet extends StatefulWidget {
  final TaskModel task;
  final String listName;
  final int boardId;
  final Color boardColor;

  const CardDetailSheet({
    super.key,
    required this.task,
    required this.listName,
    required this.boardId,
    required this.boardColor,
  });

  @override
  State<CardDetailSheet> createState() => _CardDetailSheetState();
}

class _CardDetailSheetState extends State<CardDetailSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late String _currentListName;
  late String _dueDateStr;
  bool _isSaving = false;

  final List<String> _stages = ['To Do', 'In Progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.name);
    _descCtrl = TextEditingController(text: widget.task.description ?? '');
    _currentListName = widget.listName;
    _dueDateStr = widget.task.dueDate ??
        '${DateTime.now().add(const Duration(days: 7)).year}-'
        '${DateTime.now().add(const Duration(days: 7)).month.toString().padLeft(2, '0')}-'
        '${DateTime.now().add(const Duration(days: 7)).day.toString().padLeft(2, '0')} 12:00:00';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSaving = true);
    final taskVm = context.read<TaskViewModel>();

    final ok = await taskVm.updateTask(
      taskId: widget.task.id,
      listName: _currentListName,
      dueDate: _dueDateStr,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated via API!'),
          backgroundColor: NGColors.emerald,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(taskVm.errorMessage ?? 'Failed to update task'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, sc) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: widget.boardColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Top drag bar
              const SizedBox(height: 12),
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

              // Sheet header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    if (widget.task.tag != null && widget.task.tag!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: NGColors.gold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: NGColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          widget.task.tag!,
                          style: const TextStyle(
                            color: NGColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Form fields
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Task Title
                    const Text('Task Name',
                        style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _titleCtrl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Stage / Column Selector
                    const Text('Stage / List Column',
                        style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _stages.map((stage) {
                        final isSel = _currentListName.toLowerCase() == stage.toLowerCase();
                        return ChoiceChip(
                          label: Text(stage),
                          selected: isSel,
                          selectedColor: NGColors.gold,
                          backgroundColor: const Color(0xFF222222),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black : Colors.white70,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _currentListName = stage);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Description
                    const Text('Description',
                        style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Add details, instructions or notes...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Due Date
                    const Text('Due Date',
                        style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: NGColors.gold, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _dueDateStr.split(' ').first,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 7)),
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() {
                                  _dueDateStr =
                                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')} 12:00:00';
                                });
                              }
                            },
                            child: const Text('Change', style: TextStyle(color: NGColors.gold)),
                          ),
                        ],
                      ),
                    ),

                    if (widget.task.checklist != null && widget.task.checklist!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      const Text('Checklist Items',
                          style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.task.checklist!,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: NGColors.gold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isSaving ? null : _saveTask,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
