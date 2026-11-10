import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'card_detail_sheet.dart';
import 'models/models.dart';
import 'viewmodels/viewmodels.dart';

// ────────────────────────────────────────────────────────────────────────────
//  BOARD SCREEN — Connected to BoardViewModel & TaskViewModel
// ────────────────────────────────────────────────────────────────────────────
class BoardScreen extends StatefulWidget {
  final BoardModel boardModel;
  final AppState state;

  const BoardScreen({
    super.key,
    required this.boardModel,
    required this.state,
  });

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  Color _resolveColor() {
    if (widget.boardModel.color != null && widget.boardModel.color != 0) {
      return Color(widget.boardModel.color!);
    }
    if (widget.boardModel.colour != null && widget.boardModel.colour!.isNotEmpty) {
      try {
        final hex = widget.boardModel.colour!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    return NGColors.gold;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardViewModel>().fetchBoardDetails(widget.boardModel.id);
    });
  }

  // ─── Filter Tasks by Tag Dialog ────────────────────────────────────────────
  void _showTagFilterDialog(BuildContext context) {
    final boardVm = context.read<BoardViewModel>();
    final tags = ['Design', 'Marketing', 'Procurement', 'Compliance', 'Complete', 'Urgent'];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter by Tag',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  if (boardVm.activeTagFilter != null)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        boardVm.filterByTag(widget.boardModel.id, '');
                      },
                      child: const Text('Clear', style: TextStyle(color: NGColors.ruby)),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((t) {
                  final isSelected = boardVm.activeTagFilter == t;
                  return ChoiceChip(
                    label: Text(t),
                    selected: isSelected,
                    selectedColor: NGColors.gold,
                    backgroundColor: const Color(0xFF242424),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      Navigator.pop(ctx);
                      boardVm.filterByTag(widget.boardModel.id, selected ? t : '');
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // ─── 3-Dot Menu / Edit Board Dialog ────────────────────────────────────────
  void _showBoardMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit_note_rounded, color: NGColors.gold),
              title: const Text('Update Board Description', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _showEditBoardDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: Colors.white70),
              title: const Text('Refresh Board Details', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                context.read<BoardViewModel>().fetchBoardDetails(widget.boardModel.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBoardDialog(BuildContext context) {
    final descCtrl = TextEditingController(text: widget.boardModel.description ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Update Description', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: descCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new description...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: NGColors.gold, foregroundColor: Colors.black),
            onPressed: () async {
              final newDesc = descCtrl.text.trim();
              Navigator.pop(ctx);
              final ok = await context
                  .read<BoardViewModel>()
                  .updateBoard(boardId: widget.boardModel.id, description: newDesc);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Board updated successfully!'),
                    backgroundColor: NGColors.emerald,
                  ),
                );
              }
            },
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Add Task Dialog ───────────────────────────────────────────────────────
  void _showAddTaskDialog(BuildContext context, String listName) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final tagCtrl = TextEditingController(text: 'Design');
    final checkCtrl = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.add_task_rounded, color: NGColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add Task to "$listName"',
                  style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    labelStyle: TextStyle(color: Colors.white60),
                    hintText: 'e.g. Approve 22K Kundan sample',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Tag (e.g. Design, Procurement)',
                    labelStyle: TextStyle(color: Colors.white60),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: checkCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Checklist Items (comma separated)',
                    labelStyle: TextStyle(color: Colors.white60),
                    hintText: 'Sketch approval, CAD model',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
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
              style: ElevatedButton.styleFrom(backgroundColor: NGColors.gold, foregroundColor: Colors.black),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty) return;
                      setDialogState(() => isSubmitting = true);

                      final dueStr =
                          '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')} 12:00:00';

                      final taskVm = context.read<TaskViewModel>();
                      final newTask = await taskVm.createTask(
                        boardId: widget.boardModel.id,
                        listName: listName,
                        name: title,
                        description: descCtrl.text.trim(),
                        tag: tagCtrl.text.trim(),
                        dueDate: dueStr,
                        checklist: checkCtrl.text.trim(),
                      );

                      if (!mounted) return;
                      Navigator.pop(ctx);

                      if (newTask != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task created via API!'),
                            backgroundColor: NGColors.emerald,
                          ),
                        );
                        context.read<BoardViewModel>().fetchBoardDetails(widget.boardModel.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(taskVm.errorMessage ?? 'Failed to create task'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('ADD TASK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Open Task Detail Sheet ────────────────────────────────────────────────
  void _openCardDetail(TaskModel task, String listName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardDetailSheet(
        task: task,
        listName: listName,
        boardId: widget.boardModel.id,
        boardColor: _resolveColor(),
      ),
    ).then((_) {
      if (mounted) {
        context.read<BoardViewModel>().fetchBoardDetails(widget.boardModel.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardVm = context.watch<BoardViewModel>();
    final taskVm = context.watch<TaskViewModel>();
    final boardColor = _resolveColor();

    // Board details from API or initial model
    final activeBoard = boardVm.currentBoard ?? widget.boardModel;

    // Use nested lists if available, or create standard Kanban columns
    final List<BoardListModel> columns = activeBoard.lists != null && activeBoard.lists!.isNotEmpty
        ? activeBoard.lists!
        : [
            const BoardListModel(id: 1, name: 'To Do', tasks: []),
            const BoardListModel(id: 2, name: 'In Progress', tasks: []),
            const BoardListModel(id: 3, name: 'Done', tasks: []),
          ];

    final totalTasks = columns.fold<int>(0, (s, l) => s + l.tasks.length);

    return Scaffold(
      backgroundColor: NGColors.obsidian,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activeBoard.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '${columns.length} columns · $totalTasks tasks',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [boardColor, boardColor.withValues(alpha: 0.2)],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: boardVm.activeTagFilter != null ? NGColors.gold : Colors.white70,
              size: 20,
            ),
            onPressed: () => _showTagFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white70, size: 20),
            onPressed: () => _showBoardMenu(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              boardColor.withValues(alpha: 0.05),
              NGColors.obsidian,
            ],
          ),
        ),
        child: boardVm.isDetailLoading
            ? const Center(child: CircularProgressIndicator(color: NGColors.gold))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                itemCount: columns.length,
                itemBuilder: (context, i) {
                  final column = columns[i];

                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 14),
                    child: DragTarget<TaskModel>(
                      onWillAcceptWithDetails: (details) => true,
                      onAcceptWithDetails: (details) async {
                        final droppedTask = details.data;
                        // Drag & Drop: Move task between columns via API
                        final ok = await taskVm.updateTask(
                          taskId: droppedTask.id,
                          listName: column.name,
                          dueDate: droppedTask.dueDate ?? '',
                        );
                        if (ok && mounted) {
                          context.read<BoardViewModel>().fetchBoardDetails(widget.boardModel.id);
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        final isHighlighted = candidateData.isNotEmpty;

                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF141414),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isHighlighted
                                  ? NGColors.gold
                                  : Colors.white.withValues(alpha: 0.08),
                              width: isHighlighted ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column Header
                              Padding(
                                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: boardColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        column.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${column.tasks.length}',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Divider(color: Colors.white10, height: 1),

                              // Column Task Cards
                              Expanded(
                                child: column.tasks.isEmpty
                                    ? Center(
                                        child: Text(
                                          'No tasks here yet\nDrag a card or click + to add',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.25),
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(10),
                                        itemCount: column.tasks.length,
                                        itemBuilder: (context, taskIndex) {
                                          final task = column.tasks[taskIndex];
                                          return LongPressDraggable<TaskModel>(
                                            data: task,
                                            feedback: Material(
                                              color: Colors.transparent,
                                              child: SizedBox(
                                                width: 260,
                                                child: _TaskCardView(
                                                  task: task,
                                                  boardColor: boardColor,
                                                  isDragging: true,
                                                ),
                                              ),
                                            ),
                                            childWhenDragging: Opacity(
                                              opacity: 0.3,
                                              child: _TaskCardView(
                                                task: task,
                                                boardColor: boardColor,
                                              ),
                                            ),
                                            child: GestureDetector(
                                              onTap: () => _openCardDetail(task, column.name),
                                              child: _TaskCardView(
                                                task: task,
                                                boardColor: boardColor,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),

                              // Add Task button
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 38,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add, color: NGColors.gold, size: 16),
                                    label: const Text(
                                      'Add Task',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    onPressed: () => _showAddTaskDialog(context, column.name),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
//  TASK CARD VIEW
// ────────────────────────────────────────────────────────────────────────────
class _TaskCardView extends StatelessWidget {
  final TaskModel task;
  final Color boardColor;
  final bool isDragging;

  const _TaskCardView({
    required this.task,
    required this.boardColor,
    this.isDragging = false,
  });

  Color _resolveTagColor(String? tag, String? hexColor) {
    if (hexColor != null && hexColor.isNotEmpty) {
      try {
        final hex = hexColor.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    switch (tag?.toLowerCase()) {
      case 'design':
        return NGColors.gold;
      case 'marketing':
        return NGColors.rose;
      case 'procurement':
        return NGColors.sapphire;
      case 'compliance':
        return NGColors.ruby;
      case 'complete':
        return NGColors.emerald;
      default:
        return const Color(0xFF6B46C1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagColor = _resolveTagColor(task.tag, task.tagColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDragging
              ? NGColors.gold
              : Colors.white.withValues(alpha: 0.06),
          width: 1,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (task.tag != null && task.tag!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: tagColor.withValues(alpha: 0.4), width: 0.8),
              ),
              child: Text(
                task.tag!,
                style: TextStyle(
                  color: tagColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            task.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (task.description != null && task.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (task.dueDate != null && task.dueDate!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate!.split(' ').first,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              if (task.assignees != null && task.assignees!.isNotEmpty)
                Row(
                  children: task.assignees!.take(2).map((a) {
                    final letter = a.name.isNotEmpty ? a.name[0].toUpperCase() : 'U';
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: NGColors.gold.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: NGColors.gold.withValues(alpha: 0.5), width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: const TextStyle(
                          color: NGColors.gold,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
