import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/association_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _lastScannedCode;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Prevent duplicate scans
    if (code == _lastScannedCode) return;
    _lastScannedCode = code;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    // Pause the scanner
    _controller?.stop();

    // Show preview dialog
    if (mounted) {
      await _showPatientPreview(code);
    }
  }

  Future<void> _showPatientPreview(String qrCodeId) async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;

    if (token == null) {
      _showError('Not authenticated');
      return;
    }

    final associationService = AssociationService(authToken: token);

    try {
      // First, try to get patient info
      final patientData = await associationService.getPatientByQr(qrCodeId);
      final patient = patientData['patient'];

      if (!mounted) return;

      // Show patient preview dialog
      final shouldConnect = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _PatientPreviewDialog(
          patient: patient,
          isAlreadyConnected: patientData['isAlreadyConnected'] ?? false,
        ),
      );

      if (shouldConnect == true) {
        await _connectToPatient(qrCodeId, associationService);
      } else {
        _resetScanner();
      }
    } catch (e) {
      _showError('Failed to fetch patient: $e');
    }
  }

  Future<void> _connectToPatient(
    String qrCodeId,
    AssociationService associationService,
  ) async {
    try {
      final result = await associationService.scanQrCode(qrCodeId);

      if (!mounted) return;

      // Refresh user data
      await context.read<AuthProvider>().refreshUser();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['msg'] ?? 'Connected successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return success
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Failed to connect: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _resetScanner,
        ),
      ),
    );

    _resetScanner();
  }

  void _resetScanner() {
    setState(() {
      _isProcessing = false;
      _hasScanned = false;
      _lastScannedCode = null;
    });
    _controller?.start();
  }

  void _toggleTorch() {
    _controller?.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Patient QR'),
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // Overlay
          _buildOverlay(),

          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Position the QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      painter: _ScannerOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
      const Radius.circular(16),
    );

    // Draw background with cutout
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(backgroundPath, backgroundPaint);

    // Draw corner brackets
    final cornerPaint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const cornerRadius = 16.0;

    // Top-left corner
    final topLeftPath = Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + cornerRadius)
      ..arcToPoint(
        Offset(left + cornerRadius, top),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + cornerLength, top);

    // Top-right corner
    final topRightPath = Path()
      ..moveTo(left + scanAreaSize - cornerLength, top)
      ..lineTo(left + scanAreaSize - cornerRadius, top)
      ..arcToPoint(
        Offset(left + scanAreaSize, top + cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + scanAreaSize, top + cornerLength);

    // Bottom-left corner
    final bottomLeftPath = Path()
      ..moveTo(left, top + scanAreaSize - cornerLength)
      ..lineTo(left, top + scanAreaSize - cornerRadius)
      ..arcToPoint(
        Offset(left + cornerRadius, top + scanAreaSize),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + cornerLength, top + scanAreaSize);

    // Bottom-right corner
    final bottomRightPath = Path()
      ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
      ..lineTo(left + scanAreaSize - cornerRadius, top + scanAreaSize)
      ..arcToPoint(
        Offset(left + scanAreaSize, top + scanAreaSize - cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )
      ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerLength);

    canvas.drawPath(topLeftPath, cornerPaint);
    canvas.drawPath(topRightPath, cornerPaint);
    canvas.drawPath(bottomLeftPath, cornerPaint);
    canvas.drawPath(bottomRightPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PatientPreviewDialog extends StatelessWidget {
  final Map<String, dynamic> patient;
  final bool isAlreadyConnected;

  const _PatientPreviewDialog({
    required this.patient,
    required this.isAlreadyConnected,
  });

  @override
  Widget build(BuildContext context) {
    final name = patient['name'] ?? 'Unknown';
    final age = patient['age'];
    final gender = patient['gender'];
    final bloodGroup = patient['bloodGroup'];
    final diagnosis = patient['medicalHistory']?['currentDiagnosis'];

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18),
                ),
                if (isAlreadyConnected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Already Connected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _InfoRow(label: 'Age', value: age?.toString() ?? 'N/A'),
          _InfoRow(label: 'Gender', value: gender ?? 'N/A'),
          _InfoRow(label: 'Blood Group', value: bloodGroup ?? 'N/A'),
          if (diagnosis != null)
            _InfoRow(label: 'Diagnosis', value: diagnosis),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        if (!isAlreadyConnected)
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Connect'),
          )
        else
          ElevatedButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('OK'),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
