import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspection_station/components/app_text_style/app_text_style.dart';
import 'package:inspection_station/components/loader_view.dart';
import 'package:inspection_station/utils/common/responsive_widget.dart';
import 'package:inspection_station/utils/constants/app_colors.dart';
import 'package:inspection_station/utils/constants/app_dimension.dart';
import 'package:inspection_station/utils/common/decoration.dart';
import 'package:intl/intl.dart';
import '../../data/data_structure/models/dashboard_models.dart';
import 'bloc/dashboard_bloc.dart';

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
  // Static system statuses for now as they are usually health checks
  // List<_StatusData> get _systemStatuses => [
  //   _StatusData(label: 'Database', ok: true),
  //   _StatusData(label: 'User Portal', ok: true),
  //   _StatusData(label: 'Inspector Portal', ok: true),
  //   _StatusData(label: 'Email Service', ok: true),
  // ];

  String _formatDate(DateTime dt) {
    return DateFormat(' d, MMMM EEEE, yyyy').format(dt);
  }

  List<_StatData> _mapToStatData(DashboardStats stats) {
    return [
      _StatData(
        title: 'Total Stations',
        value: stats.totalStations.toString(),
        chips: ['${stats.activeStations} Active', '${stats.totalInspectors} Inspectors'],
        icon: Icons.home_work_outlined,
        color: appColors.blue,
      ),
      _StatData(
        title: "Today's Inspections",
        value: stats.todayInspections.toString(),
        chips: ['${stats.passedInspections} Passed', '${stats.failedInspections} Failed'],
        icon: Icons.fact_check_outlined,
        color: appColors.green,
      ),
      _StatData(
        title: 'Total Appointments',
        value: stats.totalAppointments.toString(),
        chips: ['${stats.scheduledAppointments} Scheduled', '${stats.completedAppointments} Completed'],
        icon: Icons.calendar_today_outlined,
        color: appColors.purple,
      ),
      _StatData(
        title: 'Registered Vehicles',
        value: stats.totalVehicles.toString(),
        chips: ['${stats.activeStickers} Active Stickers', '${stats.totalUsers} Users'],
        icon: Icons.directions_car_outlined,
        color: appColors.orange,
      ),
    ];
  }

  List<_ActivityData> _mapToActivityData(List<DashboardActivity> activities) {
    return activities
        .map((e) => _ActivityData(title: e.title, time: e.time, subtitle: e.subtitle, user: e.user, status: e.status.toLowerCase() == 'pass' ? _ActivityStatus.pass : _ActivityStatus.fail))
        .toList();
  }

  List<_StationData> _mapToStationData(List<DashboardTopStation> stations) {
    return stations.map((e) => _StationData(name: e.name, meta: e.meta, value: e.value)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(FetchDashboardData()),
      child: Scaffold(
        backgroundColor: appColors.backgroundColor,
        body: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: LoaderView());
            } else if (state is DashboardLoaded) {
              final stats = _mapToStatData(state.stats);
              final activities = _mapToActivityData(state.activities);
              final stations = _mapToStationData(state.stations);

              return ResponsiveWidget(
                largeScreen: _DashboardLarge(
                  header: _DashboardHeader(dateText: _formatDate(DateTime.now())),
                  stats: stats,
                  activities: activities,
                  stations: stations,
                  // systemStatuses: _systemStatuses,
                ),
                mediumScreen: _DashboardLarge(
                  header: _DashboardHeader(dateText: _formatDate(DateTime.now())),
                  stats: stats,
                  activities: activities,
                  stations: stations,
                  // systemStatuses: _systemStatuses,
                ),
                smallScreen: _DashboardLarge(
                  header: _DashboardHeader(dateText: _formatDate(DateTime.now())),
                  stats: stats,
                  activities: activities,
                  stations: stations,
                  // systemStatuses: _systemStatuses,
                ),
              );
            }
            return const Center(child: Text('No data available'));
          },
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
  // final List<_StatusData> systemStatuses;
  const _DashboardLarge({required this.header, required this.stats, required this.activities, required this.stations});

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
                      child: activities.isNotEmpty ? _ActivityList(items: activities) : Center(child: Text('No activities available')),
                    ),
                    SizedBox(width: s.s16),
                    _SectionCard(
                      title: 'Top Performing Stations',
                      child: stations.isNotEmpty ? _TopStations(items: stations) : Center(child: Text('No stations available')),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _SectionCard(
                        title: 'Recent Activity',
                        child: activities.isNotEmpty ? _ActivityList(items: activities) : Center(child: Text('No activities available')),
                      ),
                    ),
                    SizedBox(width: s.s16),
                    Expanded(
                      child: _SectionCard(
                        title: 'Top Performing Stations',
                        child: stations.isNotEmpty ? _TopStations(items: stations) : Center(child: Text('No stations available')),
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
      height: 400,
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

// class _StatusData {
//   final String label;
//   final bool ok;
//   _StatusData({required this.label, required this.ok});
// }
