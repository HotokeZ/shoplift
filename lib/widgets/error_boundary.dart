import 'package:flutter/material.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  String errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    // Set the error builder
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      // Schedule setting the error state for the next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            hasError = true;
            errorMessage = errorDetails.exception.toString();
          });
        }
      });
      // Return an empty widget for now
      return const SizedBox.shrink();
    };
  }
  
  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hasError = false;
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }
    
    return widget.child;
  }
}