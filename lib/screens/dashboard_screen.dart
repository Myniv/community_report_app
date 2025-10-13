import 'package:community_report_app/provider/dashboard_provider.dart';
import 'package:community_report_app/widgets/chart_bar_horizontal.dart';
import 'package:community_report_app/widgets/chart_bar_vertical.dart';
import 'package:community_report_app/widgets/chart_pie.dart';
import 'package:community_report_app/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading dashboard data...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.fetchDashboardData();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                  ),
                ],
              ),
            );
          }

          final data = provider.dashboardData;
          if (data == null) {
            return Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchDashboardData(),
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Profiles',
                          value: '${data.totalProfile}',
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Posts',
                          value: '${data.totalPost}',
                          icon: Icons.post_add,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Analytics',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  ChartPie(
                    data: data.totalPostStatus,
                    title: 'Report Status',
                    customColors: {
                      'Pending': Colors.orange,
                      'On Progress': Colors.blue,
                      'Resolved': Colors.green,
                    },
                    centerSpaceRadius: 50,
                    showPercentage: true,
                  ),

                  SizedBox(height: 16),
                  
                  ChartPie(
                    data: data.totalPostUrgency,
                    title: 'Urgency Levels',
                    customColors: {
                      'High': Colors.red,
                      'Medium': Colors.orange,
                      'Low': Colors.green,
                    },
                    centerSpaceRadius: 0,
                    showPercentage: true,
                  ),

                  SizedBox(height: 16),

                  ChartBarVertical(
                    data: data.totalPostCategory,
                    title: 'Reports by Category',
                  ),
                  SizedBox(height: 16),

                  ChartBarHorizontal(
                    data: data.totalPostLocation,
                    title: 'All Locations',
                    maxItems: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
