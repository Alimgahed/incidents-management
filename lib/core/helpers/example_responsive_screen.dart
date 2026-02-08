import 'package:flutter/material.dart';
import 'package:incidents_managment/core/helpers/responsive.dart';
import 'package:incidents_managment/core/helpers/screen_sizes.dart';

/// Example Responsive Widget
///
/// This example demonstrates how to create a responsive widget that works
/// across mobile, tablet, and desktop devices.
class ExampleResponsiveScreen extends StatelessWidget {
  const ExampleResponsiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Example')),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.responsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive heading
            Text(
              'Responsive Design Example',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: ResponsiveHelper.responsiveFontSize(
                  context,
                  mobileSize: ResponsiveFontSizes.headlineLargeMobile,
                  desktopSize: ResponsiveFontSizes.headlineLargeDesktop,
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.responsiveSpacing(
                context,
                mobileSpacing: ResponsiveSpacing.md,
                desktopSpacing: ResponsiveSpacing.lg,
              ),
            ),

            // Device info card
            _DeviceInfoCard(),
            SizedBox(
              height: ResponsiveHelper.responsiveSpacing(
                context,
                mobileSpacing: ResponsiveSpacing.md,
                desktopSpacing: ResponsiveSpacing.lg,
              ),
            ),

            // Responsive grid example
            _ResponsiveGridExample(),
            SizedBox(
              height: ResponsiveHelper.responsiveSpacing(
                context,
                mobileSpacing: ResponsiveSpacing.md,
                desktopSpacing: ResponsiveSpacing.lg,
              ),
            ),

            // Responsive layout example
            _ResponsiveLayoutExample(),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = ResponsiveHelper.screenWidth(context);
    final height = ResponsiveHelper.screenHeight(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isLandscape = ResponsiveHelper.isLandscape(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ResponsiveSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: ResponsiveSpacing.sm),
            _InfoRow('Screen Width:', '${width.toStringAsFixed(0)}px'),
            _InfoRow('Screen Height:', '${height.toStringAsFixed(0)}px'),
            _InfoRow(
              'Device Type:',
              isMobile
                  ? 'Mobile'
                  : isTablet
                  ? 'Tablet'
                  : 'Desktop',
            ),
            _InfoRow('Orientation:', isLandscape ? 'Landscape' : 'Portrait'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ResponsiveSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class _ResponsiveGridExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.responsiveGridCrossAxisCount(
      context,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsive Grid (${crossAxisCount} columns)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: ResponsiveSpacing.md),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: ResponsiveSpacing.md,
          crossAxisSpacing: ResponsiveSpacing.md,
          children: List.generate(
            6,
            (index) => Card(child: Center(child: Text('Item ${index + 1}'))),
          ),
        ),
      ],
    );
  }
}

class _ResponsiveLayoutExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    if (isMobile) {
      // Mobile layout - single column
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobile Layout Example',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: ResponsiveSpacing.md),
          _LayoutCard(label: 'Column 1'),
          const SizedBox(height: ResponsiveSpacing.md),
          _LayoutCard(label: 'Column 2'),
          const SizedBox(height: ResponsiveSpacing.md),
          _LayoutCard(label: 'Column 3'),
        ],
      );
    } else if (isTablet) {
      // Tablet layout - two columns
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tablet Layout Example',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: ResponsiveSpacing.md),
          Row(
            children: [
              Expanded(child: _LayoutCard(label: 'Column 1')),
              const SizedBox(width: ResponsiveSpacing.md),
              Expanded(child: _LayoutCard(label: 'Column 2')),
            ],
          ),
          const SizedBox(height: ResponsiveSpacing.md),
          _LayoutCard(label: 'Column 3'),
        ],
      );
    } else {
      // Desktop layout - three columns
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Desktop Layout Example',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: ResponsiveSpacing.md),
          Row(
            children: [
              Expanded(child: _LayoutCard(label: 'Column 1')),
              const SizedBox(width: ResponsiveSpacing.md),
              Expanded(child: _LayoutCard(label: 'Column 2')),
              const SizedBox(width: ResponsiveSpacing.md),
              Expanded(child: _LayoutCard(label: 'Column 3')),
            ],
          ),
        ],
      );
    }
  }
}

class _LayoutCard extends StatelessWidget {
  final String label;

  const _LayoutCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ResponsiveSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: ResponsiveSpacing.sm),
            Text(
              'This is a responsive layout card that adapts to screen size.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
