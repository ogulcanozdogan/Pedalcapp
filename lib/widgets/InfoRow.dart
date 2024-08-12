import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const InfoRow(
      {required this.label,
      required this.value,
      this.fontSize,
      this.backgroundColor,
      this.foregroundColor,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double effectiveFontSize = fontSize ?? 14.0;
    final Color effectiveBackgroundColor = backgroundColor ?? Colors.transparent;
    final Color effectiveForegroundColor = foregroundColor ?? Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          border: const Border(bottom: BorderSide(color: Colors.black12, width: 1))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Text(
              "$label: ",
              style: TextStyle(
                  color: effectiveForegroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: effectiveFontSize),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  color: effectiveForegroundColor, fontSize: effectiveFontSize),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
