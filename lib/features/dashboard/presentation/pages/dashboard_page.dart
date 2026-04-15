import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../widgets/cards.dart';
import '../../../../core/theme.dart';
import '../../../../core/providers/patient_providers.dart';
import '../../../../core/providers/appointment_providers.dart';
import '../../../../core/providers/treatment_providers.dart';
import '../../../../core/providers/auth_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientCountAsync = ref.watch(patientCountProvider);
    final todayCountAsync = ref.watch(todayAppointmentCountProvider);
    final revenueAsync = ref.watch(totalRevenueProvider);
    final currentUser = ref.watch(currentUserProvider);
    final treatmentsAsync = ref.watch(treatmentsProvider);

    return WillPopScope(
      onWillPop: () async {
        await SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${currentUser?.name ?? 'User'} (${currentUser?.role.displayName})',
                style: const TextStyle(color: AppTheme.primaryLight),
              ),
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  ref.read(logoutProvider);
                  context.push('/login');
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  color: AppTheme.primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${currentUser?.name ?? 'User'}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Today\'s clinic overview and quick actions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Key metrics
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppTheme.paddingMedium,
              crossAxisSpacing: AppTheme.paddingMedium,
              children: [
                // Total Patients
                patientCountAsync.when(
                  data: (count) => InfoCard(
                    title: 'Total Patients',
                    value: count.toString(),
                    icon: Icons.people,
                    iconColor: AppTheme.accentColor,
                    onTap: () => context.push('/patients'),
                  ),
                  loading: () => const InfoCard(
                    title: 'Total Patients',
                    value: '--',
                    icon: Icons.people,
                    iconColor: AppTheme.accentColor,
                  ),
                  error: (e, st) => const InfoCard(
                    title: 'Total Patients',
                    value: 'Error',
                    icon: Icons.people,
                    iconColor: AppTheme.accentColor,
                  ),
                ),

                // Today's Appointments
                todayCountAsync.when(
                  data: (count) => InfoCard(
                    title: 'Today\'s Appointments',
                    value: count.toString(),
                    icon: Icons.calendar_today,
                    iconColor: AppTheme.primaryDark,
                    onTap: () => context.push('/appointments'),
                  ),
                  loading: () => const InfoCard(
                    title: 'Today\'s Appointments',
                    value: '--',
                    icon: Icons.calendar_today,
                    iconColor: AppTheme.primaryDark,
                  ),
                  error: (e, st) => const InfoCard(
                    title: 'Today\'s Appointments',
                    value: 'Error',
                    icon: Icons.calendar_today,
                    iconColor: AppTheme.primaryDark,
                  ),
                ),

                // Total Revenue
                revenueAsync.when(
                  data: (revenue) => InfoCard(
                    title: 'Total Revenue',
                    value: '\$${(revenue / 1000).toStringAsFixed(1)}K',
                    icon: Icons.trending_up,
                    iconColor: AppTheme.successColor,
                    onTap: () => context.push('/billing'),
                  ),
                  loading: () => const InfoCard(
                    title: 'Total Revenue',
                    value: '--',
                    icon: Icons.trending_up,
                    iconColor: AppTheme.successColor,
                  ),
                  error: (e, st) => const InfoCard(
                    title: 'Total Revenue',
                    value: 'Error',
                    icon: Icons.trending_up,
                    iconColor: AppTheme.successColor,
                  ),
                ),

                // Total Treatments
                treatmentsAsync.when(
                  data: (treatments) => InfoCard(
                    title: 'Treatments',
                    value: treatments.length.toString(),
                    icon: Icons.medical_services,
                    iconColor: AppTheme.primaryColor,
                    onTap: () => context.push('/treatments'),
                  ),
                  loading: () => const InfoCard(
                    title: 'Treatments',
                    value: '--',
                    icon: Icons.medical_services,
                    iconColor: AppTheme.primaryColor,
                  ),
                  error: (e, st) => const InfoCard(
                    title: 'Treatments',
                    value: 'Error',
                    icon: Icons.medical_services,
                    iconColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Revenue chart
            Text(
              'Revenue by Treatment',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            treatmentsAsync.when(
              data: (treatments) {
                if (treatments.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      child: Center(
                        child: Text(
                          'No treatment data',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  );
                }

                // Prepare chart data
                final chartData =
                    _prepareRevenueChartData(treatments);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    child: SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: List.generate(
                            chartData.length,
                            (index) => BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: chartData[index],
                                  color: AppTheme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, meta) {
                                  const titles = [
                                    'Treatment 1',
                                    'Treatment 2',
                                    'Treatment 3',
                                    'Treatment 4',
                                    'Treatment 5',
                                  ];
                                  if (value.toInt() < titles.length) {
                                    return Text(
                                      titles[value.toInt()],
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, meta) {
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.paddingLarge),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, st) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  child: Text('Error loading chart: $e'),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Quick actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppTheme.paddingMedium,
              crossAxisSpacing: AppTheme.paddingMedium,
              children: [
                _QuickActionButton(
                  icon: Icons.person_add,
                  label: 'Add Patient',
                  onTap: () => context.pushNamed('add-patient'),
                ),
                _QuickActionButton(
                  icon: Icons.calendar_today,
                  label: 'Book Appointment',
                  onTap: () => context.push('/appointments'),
                ),
                _QuickActionButton(
                  icon: Icons.medical_services,
                  label: 'Record Treatment',
                  onTap: () => context.push('/treatments'),
                ),
                _QuickActionButton(
                  icon: Icons.receipt,
                  label: 'View Billing',
                  onTap: () => context.push('/billing'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
          ],
        ),
      ),
      ),
    );
  }

  List<double> _prepareRevenueChartData(dynamic treatments) {
    // Get top 5 treatments by cost
    final sortedTreatments = [...treatments]
        ..sort((a, b) => b.cost.compareTo(a.cost));

    return sortedTreatments
        .take(5)
        .map<double>((t) => t.cost as double)
        .toList();
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
