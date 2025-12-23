import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_station/components/app_text_style/app_text_style.dart';
import 'package:inspection_station/utils/common/responsive_widget.dart';
import 'package:inspection_station/utils/constants/app_colors.dart';
import 'package:inspection_station/utils/constants/app_dimension.dart';
import 'package:inspection_station/utils/common/decoration.dart';

double _calcStatCardWidth(BuildContext context) {
  final isLarge = ResponsiveWidget.isLargeScreen(context);
  final isMedium = ResponsiveWidget.isMediumScreen(context);
  final columns = isLarge ? 4 : (isMedium ? 2 : 1);
  final sidebar = (isLarge || isMedium) ? (isLarge ? 300.0 : 80.0) : 0.0;
  final horizontalPadding = isLarge ? s.s16 * 2 : (isMedium ? s.s128 * 2 : s.s12 * 2);
  final spacing = isLarge ? s.s18 : (isMedium ? 16.0 : 12.0);
  final total = MediaQuery.of(context).size.width - sidebar - horizontalPadding - spacing * (columns - 1);
  return total / columns;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<_StatData> get _stats => [
    _StatData(title: 'Total Stations', value: '4', chips: ['4 Active', '4 Inspectors'], icon: Icons.home_work_outlined, color: appColors.blue),
    _StatData(title: "Today's Inspections", value: '4', chips: ['3 Passed', '1 Failed'], icon: Icons.fact_check_outlined, color: appColors.green),
    _StatData(title: 'Total Appointments', value: '4', chips: ['2 Scheduled', '1 Completed'], icon: Icons.calendar_today_outlined, color: appColors.purple),
    _StatData(title: 'Registered Vehicles', value: '1,247', chips: ['1,189 Active Stickers', '892 Users'], icon: Icons.directions_car_outlined, color: appColors.orange),
  ];

  List<_ActivityData> get _activities => [
    _ActivityData(title: 'WV ABC-123 • 2018 Toyota Camry', time: '09:30 AM', subtitle: 'Kanawha Blvd', user: 'Alex Johnson', status: _ActivityStatus.pass),
    _ActivityData(title: 'WV 7XY-456 • 2021 Honda CR-V', time: '10:15 AM', subtitle: 'South Charleston', user: 'Priya Rao', status: _ActivityStatus.pass),
    _ActivityData(title: 'WV TRK-789 • 2019 Ford F-150', time: '11:45 AM', subtitle: 'Morgantown', user: 'Lisa Chen', status: _ActivityStatus.fail),
    _ActivityData(title: 'WV JEEP-01 • 2020 Jeep Wrangler', time: '13:00 PM', subtitle: 'Kanawha Blvd', user: 'Alex Johnson', status: _ActivityStatus.pass),
  ];

  List<_StationData> get _stations => [
    _StationData(name: 'Kanawha Blvd Charleston', meta: 'Kanawha County • 1 Inspectors', value: '1247'),
    _StationData(name: 'South Charleston Station', meta: 'Kanawha County • 1 Inspectors', value: '945'),
    _StationData(name: 'Morgantown Inspection', meta: 'Monongalia County • 1 Inspectors', value: '780'),
    _StationData(name: 'Wheeling Vehicle Center', meta: 'Ohio County • 1 Inspectors', value: '670'),
  ];

  List<_StatusData> get _systemStatuses => [
    _StatusData(label: 'Database', ok: true),
    _StatusData(label: 'User Portal', ok: true),
    _StatusData(label: 'Inspector Portal', ok: true),
    _StatusData(label: 'Email Service', ok: true),
  ];

  String _formatDate(DateTime dt) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    final d = days[dt.weekday - 1];
    final m = months[dt.month - 1];
    return '$d, $m ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appColors.backgroundColor,
      body: ResponsiveWidget(
        largeScreen: _DashboardLarge(
          header: _DashboardHeader(dateText: _formatDate(DateTime.now())),
          stats: _stats,
          activities: _activities,
          stations: _stations,
          systemStatuses: _systemStatuses,
        ),
        mediumScreen: _DashboardLarge(
          header: _DashboardHeader(dateText: _formatDate(DateTime.now())),
          stats: _stats,
          activities: _activities,
          stations: _stations,
          systemStatuses: _systemStatuses,
        ),
        smallScreen: _DashboardLarge(
          header: _DashboardHeader(dateText: _formatDate(DateTime.now())),
          stats: _stats,
          activities: _activities,
          stations: _stations,
          systemStatuses: _systemStatuses,
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String dateText;
  const _DashboardHeader({required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Overview',
          style: GoogleFonts.ptSans(fontSize: FontSize.s24, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
        ),
        SizedBox(height: s.s8),
        Text(
          dateText,
          style: GoogleFonts.ptSans(fontSize: FontSize.s14, fontWeight: FontWeight.w400, color: appColors.secondaryTextColor),
        ),
      ],
    );
  }
}

class _DashboardLarge extends StatelessWidget {
  final _DashboardHeader header;
  final List<_StatData> stats;
  final List<_ActivityData> activities;
  final List<_StationData> stations;
  final List<_StatusData> systemStatuses;
  const _DashboardLarge({required this.header, required this.stats, required this.activities, required this.stations, required this.systemStatuses});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: s.s16, vertical: s.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(height: s.s16),
          Wrap(
            spacing: s.s18,
            runSpacing: s.s18,
            children: stats.map((e) => _StatCard(data: e)).toList(),
          ),
          SizedBox(height: s.s16),
          ResponsiveWidget.isSmallScreen(context)
              ? Column(
                  spacing: s.s8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      title: 'Recent Activity',
                      child: _ActivityList(items: activities),
                    ),
                    SizedBox(width: s.s16),
                    _SectionCard(
                      title: 'Top Performing Stations',
                      child: _TopStations(items: stations),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SectionCard(
                        title: 'Recent Activity',
                        child: _ActivityList(items: activities),
                      ),
                    ),
                    SizedBox(width: s.s16),
                    Expanded(
                      child: _SectionCard(
                        title: 'Top Performing Stations',
                        child: _TopStations(items: stations),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: BorderRadius.circular(16),
        backgroundColor: appColors.surfaceColor,
        border: Border.all(color: appColors.gray, width: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(s.s16),
            child: Text(
              title,
              style: boldTextStyle(size: FontSize.s18, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
            ),
          ),
          const Divider(height: 0),
          Padding(padding: EdgeInsets.all(s.s16), child: child),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _calcStatCardWidth(context),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: BorderRadius.circular(16),
        backgroundColor: appColors.surfaceColor,
        border: Border.all(color: appColors.gray, width: 0.2),
      ),
      padding: EdgeInsets.all(s.s16),
      child: Column(
        spacing: 8,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: primaryTextStyle(size: FontSize.s14, color: appColors.secondaryTextColor),
                  ),
                  SizedBox(height: s.s4),
                  Text(
                    data.value,
                    style: boldTextStyle(size: FontSize.s24, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(s.s12),
                decoration: BoxDecoration(color: data.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(data.icon, color: data.color),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.chips[0],
                style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
              ),
              Text(
                data.chips[1],
                style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final List<_ActivityData> items;
  const _ActivityList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(thickness: 0.3, height: s.s35),
      itemBuilder: (context, index) {
        final e = items[index];
        return Row(
          children: [
            _StatusIcon(status: e.status),
            SizedBox(width: s.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: boldTextStyle(fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
                  ),
                  Text(
                    '${e.time} • ${e.subtitle}',
                    style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
                  ),
                ],
              ),
            ),
            Text(
              e.user,
              style: secondaryTextStyle(size: FontSize.s12, color: appColors.secondaryTextColor),
            ),
          ],
        );
      },
    );
  }
}

class _TopStations extends StatelessWidget {
  final List<_StationData> items;
  const _TopStations({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(thickness: 0.3, height: s.s35),
      itemBuilder: (context, index) {
        final e = items[index];
        return Row(
          children: [
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(color: appColors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.business_outlined, color: appColors.blue),
            ),
            SizedBox(width: s.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name,
                    style: primaryTextStyle(size: FontSize.s14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: s.s4),
                  Text(e.meta, style: secondaryTextStyle(size: FontSize.s12)),
                ],
              ),
            ),
            Text(
              e.value,
              style: boldTextStyle(size: FontSize.s14, fontWeight: FontWeight.w600, color: appColors.primaryTextColor),
            ),
          ],
        );
      },
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final _ActivityStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == _ActivityStatus.pass ? appColors.green : appColors.red;
    final icon = status == _ActivityStatus.pass ? Icons.check_circle_outline : Icons.cancel_outlined;
    return Container(
      padding: EdgeInsets.all(s.s8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatData {
  final String title;
  final String value;
  final List<String> chips;
  final IconData icon;
  final Color color;
  _StatData({required this.title, required this.value, required this.chips, required this.icon, required this.color});
}

enum _ActivityStatus { pass, fail }

class _ActivityData {
  final String title;
  final String time;
  final String subtitle;
  final String user;
  final _ActivityStatus status;
  _ActivityData({required this.title, required this.time, required this.subtitle, required this.user, required this.status});
}

class _StationData {
  final String name;
  final String meta;
  final String value;
  _StationData({required this.name, required this.meta, required this.value});
}

class _StatusData {
  final String label;
  final bool ok;
  _StatusData({required this.label, required this.ok});
}
