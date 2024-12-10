import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:permission_handler/permission_handler.dart'; // Permission handling
import 'package:vector_math/vector_math_64.dart';

void main() => runApp(TileARApp());

class TileARApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Tile AR Viewer")),
        body: ARViewScreen(),
      ),
    );
  }
}

class ARViewScreen extends StatefulWidget {
  @override
  _ARViewScreenState createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Request permissions at startup
  }

  Future<void> _requestPermissions() async {
    if (await Permission.camera.request().isGranted) {
      print("Camera permission granted.");
    } else {
      print("Camera permission denied. Exiting.");
      // Exit or show error dialog if permissions are not granted
    }
  }

  @override
  Widget build(BuildContext context) {
    return ARView(
      onARViewCreated: (arSessionManager, arObjectManager, arAnchorManager, arLocationManager) {
        this.arSessionManager = arSessionManager;
        this.arObjectManager = arObjectManager;

        // Initialize AR view with specific configurations
        arSessionManager.onInitialize(showFeaturePoints: false);
        arObjectManager.onInitialize();
        _add3DModel(); // Add the 3D model
      },
    );
  }

  void _add3DModel() async {
    String modelPath = "assets/tile_model.glb"; // Path to the model

    try {
      ARNode node = ARNode(
        type: NodeType.localGLTF2,
        uri: modelPath,
        scale: Vector3(0.5, 0.5, 0.5), // Adjust model size
        position: Vector3(0.0, 0.0, -1.0), // Position model 1 meter in front
      );

      bool? didAddNode = await arObjectManager.addNode(node);
      if (didAddNode == true) {
        print("Model added to the scene successfully.");
      } else {
        print("Failed to add model to the scene.");
      }
    } catch (e) {
      print("Error while adding the model: $e");
    }
  }
}
