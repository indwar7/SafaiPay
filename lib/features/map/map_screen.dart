import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../models/report_model.dart';
import '../../core/theme/app_colors.dart';
import '../../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final LocationService _locationService = LocationService();
  final Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(28.6139, 77.2090); // Delhi

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadReports();
  }

  Future<void> _loadCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  Future<void> _loadReports() async {
    await context.read<ReportProvider>().loadAllReports();
    _updateMarkers();
  }

  void _updateMarkers() {
    final reports = context.read<ReportProvider>().reports;
    setState(() {
      _markers.clear();
      for (var report in reports) {
        _markers.add(
          Marker(
            markerId: MarkerId(report.id),
            position: LatLng(report.latitude, report.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              report.status == 'pending'
                  ? BitmapDescriptor.hueRed
                  : BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: report.issueType,
              snippet: report.description,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          // Header card
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'City Cleanliness Map',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildLegendItem(AppColors.red, 'Pending'),
                      const SizedBox(width: 16),
                      _buildLegendItem(AppColors.primaryGreen, 'Resolved'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // My location button
          Positioned(
            bottom: 100,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppColors.primaryGreen,
              onPressed: () async {
                final position = await _locationService.getCurrentLocation();
                if (position != null) {
                  _mapController.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(position.latitude, position.longitude),
                    ),
                  );
                }
              },
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }
}
