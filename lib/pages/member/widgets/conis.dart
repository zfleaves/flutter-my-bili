import 'package:bilibili/common/constants.dart';
import 'package:bilibili/models/member/coin.dart';
import 'package:bilibili/pages/member_coin/widgets/item.dart';
import 'package:flutter/material.dart';


class MemberCoinsPanel extends StatelessWidget {
  final List<MemberCoinsDataModel>? data;
  const MemberCoinsPanel({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Use a fixed count for GridView
            crossAxisSpacing: StyleString.safeSpace,
            mainAxisSpacing: StyleString.safeSpace,
            childAspectRatio: 0.94,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: data!.length,
          itemBuilder: (context, i) {
            return MemberCoinsItem(coinItem: data![i]);
          },
        );
      },
    );
  }
}