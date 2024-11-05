import 'package:flutter/material.dart';

class SelectDialog<T> extends StatefulWidget {
  final T value;
  final String title;
  final List<dynamic> values;
  const SelectDialog(
      {super.key,
      required this.value,
      required this.title,
      required this.values});

  @override
  _SelectDialogState<T> createState() => _SelectDialogState<T>();
}

class _SelectDialogState<T> extends State<SelectDialog<T>> {
  late T _tempValue;

  @override
  void initState() {
    super.initState();
    _tempValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
      content: StatefulBuilder(builder:(context, setState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i in widget.values) ...[
                RadioListTile(
                  value: i['value'],
                  title: Text(i['title'], style: titleStyle),
                  groupValue: _tempValue,
                  onChanged: (value) {
                    setState(() {
                      _tempValue = value as T;
                    });
                    Navigator.pop(context, _tempValue);
                  },
                ),
              ]
            ],
          ),
        );
      },),
    );
  }
}
