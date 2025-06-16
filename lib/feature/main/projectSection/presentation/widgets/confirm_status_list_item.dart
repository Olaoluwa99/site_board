import 'package:flutter/material.dart';
import 'package:site_board/feature/main/projectSection/domain/DailyLog.dart';

class ConfirmStatusListItem extends StatefulWidget {
  final LogTask task;
  final int index;
  final void Function(LogTask task) onEditCompleted;
  const ConfirmStatusListItem({
    required this.task,
    required this.index,
    required this.onEditCompleted,
    super.key,
  });

  @override
  State<ConfirmStatusListItem> createState() => _ConfirmStatusListItemState();
}

class _ConfirmStatusListItemState extends State<ConfirmStatusListItem> {
  late LogTask task;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  void _updateTask(double value) {
    setState(() {
      task = task.copyWith(percentCompleted: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.index + 1}. ${task.plannedTask}',
              maxLines: 2,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Slider(
                    value: task.percentCompleted,
                    max: 100.0,
                    divisions: 20,
                    onChanged: _updateTask,
                    onChangeEnd: (value) {
                      _updateTask(value);
                      widget.onEditCompleted(task);
                    },
                  ),
                ),
                Text(
                  '${task.percentCompleted.toInt()}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*class _ConfirmStatusListItemState extends State<ConfirmStatusListItem> {
  double taskPercentCompleted = 0.0;
  @override
  void initState() {
    super.initState();
    taskPercentCompleted = widget.task.percentCompleted;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.index + 1}. ${widget.task.plannedTask}',
              maxLines: 2,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Slider(
                    value: taskPercentCompleted,
                    onChangeEnd: (value) {
                      taskPercentCompleted = value;
                      widget.onEditCompleted(
                        widget.task.copyWith(
                          percentCompleted: taskPercentCompleted,
                        ),
                      );
                      setState(() {});
                    },
                    max: 100.0,
                    divisions: 20,
                    onChanged: (double value) {
                      taskPercentCompleted = value;
                      widget.onEditCompleted(
                        widget.task.copyWith(
                          percentCompleted: taskPercentCompleted,
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ),
                Text(
                  taskPercentCompleted.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/
