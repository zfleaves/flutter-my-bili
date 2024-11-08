import 'package:bilibili/common/constants.dart';
import 'package:bilibili/common/widgets/badge.dart';
import 'package:bilibili/models/member/seasons.dart';
import 'package:bilibili/pages/member_seasons/widgets/item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class MemberSeasonsPanel extends StatelessWidget {
  final MemberSeasonsDataModel? data;
  const MemberSeasonsPanel({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data!.seasonsList!.length,
      itemBuilder: (context, index) {
        MemberSeasonsList item = data!.seasonsList![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () => Get.toNamed(
                    '/memberSeasons?mid=${item.meta!.mid}&seasonId=${item.meta!.seasonId}'),
                title: Text(
                  item.meta!.name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
                dense: true,
                leading: PBadge(
                  stack: 'relative',
                  size: 'small',
                  text: item.meta!.total.toString(),
                ),
                trailing: const Icon(
                  Icons.arrow_forward,
                  size: 20,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, boxConstraints) {
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Use a fixed count for GridView
                      crossAxisSpacing: StyleString.safeSpace,
                      mainAxisSpacing: StyleString.safeSpace,
                      childAspectRatio: 0.94,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: item.archives!.length,
                    itemBuilder: (context, i) {
                      return MemberSeasonsItem(seasonItem: item.archives![i]);
                    },
                  );
                }
              )
            ],
          ),
        );
      },
    );
  }
}