import 'package:flutter/material.dart';
import 'package:camera_macos/camera_macos.dart';

/// Widget principal responsável pela exibição e controle da câmera
/// Seguindo o Princípio da Responsabilidade Única (SRP) e Inversão de Dependência (DIP)
class CameraDisplay extends StatefulWidget {
  final double radius;

  final VoidCallback onTap;

  const CameraDisplay({
    super.key,
    this.radius = 40,
    required this.onTap,
  });

  @override
  State<CameraDisplay> createState() => _CameraDisplayState();
}

class _CameraDisplayState extends State<CameraDisplay> {
  CameraMacOSController? _controller;
  bool _isLoading = false;
  bool _hasError = false;
  bool _isCameraActive = false;
  final GlobalKey _cameraKey = GlobalKey();

  @override
  void dispose() {
    _destroyCamera();
    super.dispose();
  }

  Future<void> _destroyCamera() async {
    if (_controller != null) {
      await _controller!.destroy();
      _controller = null;
    }
  }

  /// Alterna entre ativar e desativar a câmera
  Future<void> _toggleCamera() async {
    if (_isCameraActive) {
      // Desativar câmera
      setState(() {
        _isLoading = true;
      });

      await _destroyCamera();

      setState(() {
        _isCameraActive = false;
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    // Ativar câmera
    setState(() {
      _isLoading = true;
      _hasError = false;
      _isCameraActive = true;
    });
  }

  void _onCameraInitialized(CameraMacOSController controller) {
    setState(() {
      _controller = controller;
      _isLoading = false;
    });
  }

  void _onCameraError() {
    setState(() {
      _hasError = true;
      _isLoading = false;
      _isCameraActive = false;
      _controller = null;
    });
  }

  /// Constrói o widget baseado no estado atual da câmera
  Widget _buildIcon() {
    if (_hasError) {
      return CircleAvatar(
        backgroundColor: Colors.red[900],
        radius: widget.radius,
        child: Icon(
          Icons.error,
          color: Colors.white,
          size: widget.radius * 0.6,
        ),
      );
    }

    if (_isLoading) {
      return CircleAvatar(
        backgroundColor: Colors.grey[900],
        radius: widget.radius,
        child: SizedBox(
          width: widget.radius * 0.6,
          height: widget.radius * 0.6,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.grey[900],
      radius: widget.radius,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera,
            color: Colors.grey,
            size: widget.radius * 0.75,
          ),
          Text(
            'Camera',
            style: TextStyle(
              color: Colors.grey,
              fontSize: widget.radius * 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _toggleCamera();
      },
      child: _isCameraActive && !_hasError
          ? ClipOval(
              child: SizedBox(
                width: widget.radius * 2,
                height: widget.radius * 2,
                child: CameraMacOSView(
                  key: _cameraKey,
                  fit: BoxFit.cover,
                  cameraMode: CameraMacOSMode.photo,
                  onCameraInizialized: _onCameraInitialized,
                ),
              ),
            )
          : _buildIcon(),
    );
  }
}
