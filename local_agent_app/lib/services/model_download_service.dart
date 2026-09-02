import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final modelDownloadProvider = StateNotifierProvider<ModelDownloadNotifier, DownloadState>((ref) {
  return ModelDownloadNotifier();
});

class DownloadState {
  final double progress;
  final String status;
  final bool isComplete;
  final bool isError;
  final String? modelPath;

  DownloadState({
    this.progress = 0.0,
    this.status = 'Initializing...',
    this.isComplete = false,
    this.isError = false,
    this.modelPath,
  });
}

class ModelDownloadNotifier extends StateNotifier<DownloadState> {
  ModelDownloadNotifier() : super(DownloadState());

  // Primary and fallback URLs to prevent HuggingFace rate limits or downtime.
  final List<String> _downloadMirrors = [
    'https://huggingface.co/Qwen/Qwen1.5-0.5B-Chat-GGUF/resolve/main/qwen1_5-0_5b-chat-q4_k_m.gguf', // Primary HF
    'https://hf-mirror.com/Qwen/Qwen1.5-0.5B-Chat-GGUF/resolve/main/qwen1_5-0_5b-chat-q4_k_m.gguf', // HF Mirror in Asia
    'https://huggingface.co/MaziyarPanahi/Qwen1.5-0.5B-Chat-GGUF/resolve/main/Qwen1.5-0.5B-Chat.Q4_K_M.gguf', // Alternate repo
  ];
  final String _modelFileName = 'qwen1.5-0.5b-chat-q4_k_m.gguf';
  
  CancelToken? _cancelToken;

  Future<void> checkExistingOrDownload() async {
    // If testing on Web Chrome, skip true native file system access and mock the flow
    if (kIsWeb) {
      await _mockDownloadForWeb();
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$_modelFileName';
      
      final file = File(savePath);
      if (await file.exists()) {
        final length = await file.length();
        // The Qwen 0.5B Q4_K_M model is roughly 398MB. 
        if (length > 300 * 1024 * 1024) {
          state = DownloadState(
            progress: 1.0, 
            status: 'Model verified.', 
            isComplete: true,
            modelPath: savePath
          );
          return;
        } else {
          // File is incomplete/corrupted, delete and restart
          await file.delete(); 
        }
      }

      await _startDownload(savePath);
    } catch (e) {
      state = DownloadState(status: 'Error checking storage: $e', isError: true);
    }
  }

  Future<void> _startDownload(String savePath) async {
    _cancelToken = CancelToken();
    final dio = Dio();
    
    for (int i = 0; i < _downloadMirrors.length; i++) {
      try {
        state = DownloadState(
          progress: 0.0, 
          status: i == 0 ? 'Connecting to Neural Network...' : 'Retrying via fallback mirror ${i + 1}...'
        );
        
        await dio.download(
          _downloadMirrors[i],
          savePath,
          cancelToken: _cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              String status = 'Downloading weights...';
              if (progress > 0.95) status = 'Finalizing core pipeline...';
              else if (progress > 0.6) status = 'Loading quantized tensors...';
              else if (progress > 0.1) status = 'Allocating memory buffer...';
              
              state = DownloadState(
                progress: progress,
                status: status,
              );
            }
          },
        );
        
        state = DownloadState(
          progress: 1.0, 
          status: 'Ready.', 
          isComplete: true,
          modelPath: savePath
        );
        return; // Success, exit loop
        
      } catch (e) {
        if (CancelToken.isCancel(e)) {
          state = DownloadState(status: 'Download cancelled.', isError: true);
          return;
        }
        // If it fails, loop continues to the next mirror
        if (i == _downloadMirrors.length - 1) {
          state = DownloadState(status: 'All fallback mirrors failed.', isError: true);
        }
      }
    }
  }

  Future<void> _mockDownloadForWeb() async {
    state = DownloadState(progress: 0.0, status: 'Simulating Web Download...');
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      final progress = i / 100;
      String status = 'Downloading weights...';
      if (progress > 0.95) status = 'Finalizing core pipeline...';
      else if (progress > 0.6) status = 'Loading quantized tensors...';
      else if (progress > 0.1) status = 'Allocating memory buffer...';
      
      state = DownloadState(progress: progress, status: status);
    }
    state = DownloadState(progress: 1.0, status: 'Ready.', isComplete: true);
  }
}
