import 'package:flutter/material.dart';
import 'package:gym_app_winter/palette/color_scheme.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    final bool isDark = context.colors.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.borderCream,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textBlack,
                ),
              ),
              Icon(icon, color: context.colors.stoneGray, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.oliveGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.colors.isDarkMode;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 32,
              color: context.colors.nearBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard(context, '14', 'Workouts', Icons.fitness_center),
              _buildStatCard(context, '85%', 'Completion', Icons.check_circle_outline),
              _buildStatCard(context, '2.4 hrs', 'Avg. Duration', Icons.access_time),
              _buildStatCard(context, '5', 'Active Days', Icons.calendar_today_outlined),
            ],
          ),
          const SizedBox(height: 24),
          
          // Chart Section Placeholder
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.colors.borderCream,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weekly Volume Trend',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textBlack,
                      ),
                    ),
                    Icon(Icons.trending_up, color: context.colors.brandPrimary),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Beautiful Mock Chart bars
                SizedBox(
                  height: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildChartBar(context, 0.4, 'Mon'),
                      _buildChartBar(context, 0.6, 'Tue'),
                      _buildChartBar(context, 0.3, 'Wed'),
                      _buildChartBar(context, 0.85, 'Thu'),
                      _buildChartBar(context, 0.5, 'Fri'),
                      _buildChartBar(context, 0.7, 'Sat'),
                      _buildChartBar(context, 0.2, 'Sun'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Scroll buffer
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildChartBar(BuildContext context, double heightFactor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Container(
                width: 16,
                decoration: BoxDecoration(
                  color: context.colors.brandPrimary.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.stoneGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
