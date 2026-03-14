import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'dart:math';

// Fake report data for the map
class _FakeReport {
  final String id;
  final String issueType;
  final String description;
  final String address;
  final String status;
  final String timeAgo;
  final double lat;
  final double lng;

  const _FakeReport({
    required this.id,
    required this.issueType,
    required this.description,
    required this.address,
    required this.status,
    required this.timeAgo,
    required this.lat,
    required this.lng,
  });
}

const _fakeReports = [
  _FakeReport(
    id: '1',
    issueType: 'Overflowing Bin',
    description:
        'Large community bin overflowing near park entrance. Waste spilling onto sidewalk.',
    address: 'MG Road, near Trinity Metro',
    status: 'pending',
    timeAgo: '2h ago',
    lat: 12.9716,
    lng: 77.5946,
  ),
  _FakeReport(
    id: '2',
    issueType: 'Open Garbage',
    description:
        'Garbage dumped openly on empty plot. Attracting stray animals.',
    address: '12th Cross, Indiranagar',
    status: 'pending',
    timeAgo: '5h ago',
    lat: 12.9784,
    lng: 77.6408,
  ),
  _FakeReport(
    id: '3',
    issueType: 'Sewage Issue',
    description:
        'Sewage water overflowing from manhole. Strong odor in the area.',
    address: 'CMH Road, near Signal',
    status: 'resolved',
    timeAgo: '1d ago',
    lat: 12.9810,
    lng: 77.6200,
  ),
  _FakeReport(
    id: '4',
    issueType: 'Road Waste',
    description: 'Construction debris left on road after building work.',
    address: '100 Feet Road, HAL',
    status: 'pending',
    timeAgo: '3h ago',
    lat: 12.9600,
    lng: 77.6460,
  ),
  _FakeReport(
    id: '5',
    issueType: 'Littering',
    description:
        'Plastic waste and food containers around bus stop. Needs cleanup.',
    address: 'Domlur Bus Stop',
    status: 'resolved',
    timeAgo: '2d ago',
    lat: 12.9630,
    lng: 77.6380,
  ),
  _FakeReport(
    id: '6',
    issueType: 'Illegal Dumping',
    description:
        'Someone dumping industrial waste at night near the lake edge.',
    address: 'Ulsoor Lake, East Bank',
    status: 'pending',
    timeAgo: '6h ago',
    lat: 12.9810,
    lng: 77.6180,
  ),
  _FakeReport(
    id: '7',
    issueType: 'Overflowing Bin',
    description: 'BBMP bin not cleared for 3 days. Completely overflowing.',
    address: 'Koramangala 4th Block',
    status: 'resolved',
    timeAgo: '3d ago',
    lat: 12.9352,
    lng: 77.6245,
  ),
  _FakeReport(
    id: '8',
    issueType: 'Open Garbage',
    description:
        'Vegetable market waste piled up on the side of the main road.',
    address: 'Madiwala Market',
    status: 'pending',
    timeAgo: '4h ago',
    lat: 12.9226,
    lng: 77.6200,
  ),
];

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  String _activeFilter = 'All';
  _FakeReport? _selectedReport;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final List<String> _filters = ['All', 'Pending', 'Resolved', 'Near Me'];

  // Fake map viewport (Bangalore center)
  Offset _mapOffset = Offset.zero;
  double _mapZoom = 1.0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<_FakeReport> get _filteredReports {
    if (_activeFilter == 'All') return _fakeReports;
    if (_activeFilter == 'Pending') {
      return _fakeReports.where((r) => r.status == 'pending').toList();
    }
    if (_activeFilter == 'Resolved') {
      return _fakeReports.where((r) => r.status == 'resolved').toList();
    }
    // Near Me — return first 4
    return _fakeReports.take(4).toList();
  }

  void _onFilterTap(String filter) {
    setState(() {
      _activeFilter = filter;
      _selectedReport = null;
    });
  }

  void _onMarkerTap(_FakeReport report) {
    setState(() {
      _selectedReport = report;
    });
    _sheetController.animateTo(
      0.35,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── FAKE MAP ──
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _mapOffset += details.delta;
              });
            },
            onDoubleTap: () {
              setState(() {
                _mapZoom = (_mapZoom * 1.2).clamp(0.5, 3.0);
              });
            },
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFF1A1A1A),
              child: CustomPaint(
                painter: _DarkMapPainter(
                  offset: _mapOffset,
                  zoom: _mapZoom,
                ),
                child: Stack(
                  children: [
                    // Place markers on the fake map
                    ..._filteredReports.map((report) {
                      return _buildMarker(context, report);
                    }),
                    // Current location indicator
                    _buildCurrentLocationDot(),
                  ],
                ),
              ),
            ),
          ),

          // ── TOP SEARCH BAR ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.borderDefault, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded,
                      color: AppColors.neonLime, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search location...',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surface3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: AppColors.textSecondary, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // ── FILTER CHIPS ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isActive = _activeFilter == filter;
                  return GestureDetector(
                    onTap: () => _onFilterTap(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.neonLime
                            : AppColors.surface3,
                        borderRadius: BorderRadius.circular(100),
                        border: isActive
                            ? null
                            : Border.all(
                                color: AppColors.borderActive, width: 1),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.neonLime
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        filter,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.textOnLime
                              : AppColors.textWhite,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── STATS OVERLAY ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 122,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardBg.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDefault, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_fakeReports.where((r) => r.status == 'pending').length} Pending',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.neonLime,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_fakeReports.where((r) => r.status == 'resolved').length} Resolved',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── BOTTOM SHEET ──
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.0,
            minChildSize: 0.0,
            maxChildSize: 0.5,
            snap: true,
            snapSizes: const [0.0, 0.18, 0.35],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderActive,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_selectedReport != null) ...[
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedReport!.issueType,
                                      style:
                                          GoogleFonts.barlowSemiCondensed(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textWhite,
                                      ),
                                    ),
                                  ),
                                  _buildStatusChip(
                                      _selectedReport!.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedReport!.description,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Address
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      color: AppColors.textTertiary,
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _selectedReport!.address,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Time
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      color: AppColors.textTertiary,
                                      size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Reported ${_selectedReport!.timeAgo}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Action buttons
                              if (_selectedReport!.status == 'pending')
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.neonLime,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'UPVOTE REPORT',
                                            style: GoogleFonts.bebasNeue(
                                              fontSize: 16,
                                              color: AppColors.textOnLime,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      height: 44,
                                      width: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface3,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.borderDefault,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.share_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Tap a marker to view report details',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // ── FABS ──
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Zoom in
                _buildFabButton(
                  icon: Icons.add,
                  onTap: () {
                    setState(() {
                      _mapZoom = (_mapZoom * 1.2).clamp(0.5, 3.0);
                    });
                  },
                  small: true,
                ),
                const SizedBox(height: 8),
                // Zoom out
                _buildFabButton(
                  icon: Icons.remove,
                  onTap: () {
                    setState(() {
                      _mapZoom = (_mapZoom / 1.2).clamp(0.5, 3.0);
                    });
                  },
                  small: true,
                ),
                const SizedBox(height: 12),
                // My location
                _buildFabButton(
                  icon: Icons.my_location_rounded,
                  onTap: () {
                    setState(() {
                      _mapOffset = Offset.zero;
                      _mapZoom = 1.0;
                    });
                  },
                  isMain: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabButton({
    required IconData icon,
    required VoidCallback onTap,
    bool small = false,
    bool isMain = false,
  }) {
    final size = small ? 40.0 : 56.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isMain ? AppColors.neonLime : AppColors.cardBg,
          borderRadius: BorderRadius.circular(isMain ? 16 : 12),
          border: isMain
              ? null
              : Border.all(color: AppColors.borderDefault, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: isMain
                  ? AppColors.neonLime.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isMain ? AppColors.textOnLime : AppColors.textWhite,
          size: small ? 20 : 24,
        ),
      ),
    );
  }

  Widget _buildMarker(BuildContext context, _FakeReport report) {
    final screenSize = MediaQuery.of(context).size;
    // Map lat/lng to screen positions (relative to Bangalore center)
    final centerLat = 12.9600;
    final centerLng = 77.6200;

    final x = screenSize.width / 2 +
        (report.lng - centerLng) * 8000 * _mapZoom +
        _mapOffset.dx;
    final y = screenSize.height / 2 -
        (report.lat - centerLat) * 8000 * _mapZoom +
        _mapOffset.dy;

    // Only show if on screen
    if (x < -30 || x > screenSize.width + 30 || y < -30 || y > screenSize.height + 30) {
      return const SizedBox.shrink();
    }

    final isSelected = _selectedReport?.id == report.id;
    final isPending = report.status == 'pending';

    return Positioned(
      left: x - (isSelected ? 20 : 16),
      top: y - (isSelected ? 20 : 16),
      child: GestureDetector(
        onTap: () => _onMarkerTap(report),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulse ring for pending
                if (isPending && !isSelected)
                  Container(
                    width: 40 * _pulseAnimation.value,
                    height: 40 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.error.withValues(alpha: 0.15),
                    ),
                  ),
                if (isPending && !isSelected)
                  const SizedBox(),
                // Marker pin
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 40 : 32,
                  height: isSelected ? 40 : 32,
                  decoration: BoxDecoration(
                    color: isPending ? AppColors.error : AppColors.neonLime,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBg,
                      width: isSelected ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isPending ? AppColors.error : AppColors.neonLime)
                            .withValues(alpha: 0.4),
                        blurRadius: isSelected ? 16 : 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    isPending
                        ? Icons.warning_rounded
                        : Icons.check_rounded,
                    color: isPending
                        ? AppColors.textWhite
                        : AppColors.textOnLime,
                    size: isSelected ? 20 : 16,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentLocationDot() {
    final screenSize = MediaQuery.sizeOf(context);
    final x = screenSize.width / 2 + _mapOffset.dx;
    final y = screenSize.height / 2 + _mapOffset.dy;

    return Positioned(
      left: x - 12,
      top: y - 12,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4285F4).withValues(alpha: 0.2),
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4285F4),
                  border: Border.all(
                    color: AppColors.textWhite,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(0xFF4285F4).withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isResolved = status == 'resolved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isResolved
            ? AppColors.neonLime.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isResolved
              ? AppColors.neonLime.withValues(alpha: 0.4)
              : AppColors.error.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isResolved ? AppColors.neonLime : AppColors.error,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── DARK MAP PAINTER ──
// Renders a stylized dark map with roads, blocks, water, and labels
class _DarkMapPainter extends CustomPainter {
  final Offset offset;
  final double zoom;

  _DarkMapPainter({required this.offset, required this.zoom});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1A1A1A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    canvas.save();
    canvas.translate(
        size.width / 2 + offset.dx, size.height / 2 + offset.dy);
    canvas.scale(zoom);
    canvas.translate(-size.width / 2, -size.height / 2);

    // Draw grid blocks (building blocks)
    _drawBlocks(canvas, size);

    // Draw main roads
    _drawRoads(canvas, size);

    // Draw water feature (lake)
    _drawWater(canvas, size);

    // Draw park areas
    _drawParks(canvas, size);

    // Draw road labels
    _drawLabels(canvas, size);

    canvas.restore();
  }

  void _drawBlocks(Canvas canvas, Size size) {
    final blockPaint = Paint()..color = const Color(0xFF212121);
    final rng = Random(42); // Deterministic random

    // Generate city blocks
    for (double y = -200; y < size.height + 200; y += 60) {
      for (double x = -200; x < size.width + 200; x += 70) {
        final w = 40.0 + rng.nextDouble() * 20;
        final h = 30.0 + rng.nextDouble() * 20;
        final offsetX = rng.nextDouble() * 10;
        final offsetY = rng.nextDouble() * 10;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + offsetX, y + offsetY, w, h),
            const Radius.circular(2),
          ),
          blockPaint,
        );
      }
    }
  }

  void _drawRoads(Canvas canvas, Size size) {
    // Major roads
    final majorRoadPaint = Paint()
      ..color = const Color(0xFF3C3C3C)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Horizontal major roads
    final hRoad1 = Path()
      ..moveTo(-200, size.height * 0.3)
      ..lineTo(size.width + 200, size.height * 0.3);
    canvas.drawPath(hRoad1, majorRoadPaint);

    final hRoad2 = Path()
      ..moveTo(-200, size.height * 0.65)
      ..lineTo(size.width + 200, size.height * 0.65);
    canvas.drawPath(hRoad2, majorRoadPaint);

    // Vertical major roads
    final vRoad1 = Path()
      ..moveTo(size.width * 0.35, -200)
      ..lineTo(size.width * 0.35, size.height + 200);
    canvas.drawPath(vRoad1, majorRoadPaint);

    final vRoad2 = Path()
      ..moveTo(size.width * 0.7, -200)
      ..lineTo(size.width * 0.7, size.height + 200);
    canvas.drawPath(vRoad2, majorRoadPaint);

    // Minor/arterial roads
    final minorRoadPaint = Paint()
      ..color = const Color(0xFF2C2C2C)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (double y = -200; y < size.height + 200; y += 120) {
      canvas.drawLine(
          Offset(-200, y), Offset(size.width + 200, y), minorRoadPaint);
    }
    for (double x = -200; x < size.width + 200; x += 140) {
      canvas.drawLine(
          Offset(x, -200), Offset(x, size.height + 200), minorRoadPaint);
    }

    // Diagonal road
    final diagPaint = Paint()
      ..color = const Color(0xFF373737)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.8, size.height * 0.9),
      diagPaint,
    );
  }

  void _drawWater(Canvas canvas, Size size) {
    final waterPaint = Paint()..color = const Color(0xFF0D1B2A);
    final waterBorderPaint = Paint()
      ..color = const Color(0xFF1B3A5C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Lake shape
    final path = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width * 0.75, size.height * 0.25),
        width: 120,
        height: 80,
      ));
    canvas.drawPath(path, waterPaint);
    canvas.drawPath(path, waterBorderPaint);

    // Lake label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'Ulsoor Lake',
        style: TextStyle(
          color: const Color(0xFF3D6B99),
          fontSize: 9,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(size.width * 0.75 - labelPainter.width / 2,
          size.height * 0.25 - labelPainter.height / 2),
    );
  }

  void _drawParks(Canvas canvas, Size size) {
    final parkPaint = Paint()..color = const Color(0xFF1A2A1A);

    // Cubbon Park
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.25, size.height * 0.45),
          width: 80,
          height: 60,
        ),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    final parkLabel = TextPainter(
      text: TextSpan(
        text: 'Cubbon Park',
        style: TextStyle(
          color: const Color(0xFF3A5A3A),
          fontSize: 8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    parkLabel.paint(
      canvas,
      Offset(size.width * 0.25 - parkLabel.width / 2,
          size.height * 0.45 - parkLabel.height / 2),
    );
  }

  void _drawLabels(Canvas canvas, Size size) {
    final labels = [
      _MapLabel('MG Road', size.width * 0.5, size.height * 0.28, true),
      _MapLabel('CMH Road', size.width * 0.33, size.height * 0.63, true),
      _MapLabel('100 Feet Rd', size.width * 0.68, size.height * 0.63, true),
      _MapLabel('Indiranagar', size.width * 0.8, size.height * 0.4, false),
      _MapLabel('Koramangala', size.width * 0.3, size.height * 0.8, false),
      _MapLabel('Domlur', size.width * 0.55, size.height * 0.5, false),
      _MapLabel('HAL', size.width * 0.85, size.height * 0.55, false),
      _MapLabel('Madiwala', size.width * 0.4, size.height * 0.9, false),
    ];

    for (final label in labels) {
      final style = label.isRoad
          ? TextStyle(
              color: const Color(0xFF616161),
              fontSize: 8,
              letterSpacing: 1,
            )
          : TextStyle(
              color: const Color(0xFF8A8A8A),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            );

      final painter = TextPainter(
        text: TextSpan(text: label.text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      if (label.isRoad) {
        // Road label with background
        final bg = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(label.x, label.y),
            width: painter.width + 8,
            height: painter.height + 4,
          ),
          const Radius.circular(2),
        );
        canvas.drawRRect(bg, Paint()..color = const Color(0xFF1A1A1A));
      }

      painter.paint(
        canvas,
        Offset(label.x - painter.width / 2, label.y - painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DarkMapPainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.zoom != zoom;
  }
}

class _MapLabel {
  final String text;
  final double x;
  final double y;
  final bool isRoad;

  const _MapLabel(this.text, this.x, this.y, this.isRoad);
}
