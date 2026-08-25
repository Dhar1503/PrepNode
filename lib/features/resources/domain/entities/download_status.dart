import 'package:equatable/equatable.dart';

/// Represents the download status of a resource
class DownloadStatus extends Equatable {
  final String id;
  final String userId;
  final String resourceId;
  final DownloadState state;
  final double progress; // 0.0 to 1.0
  final String? localPath;
  final int? fileSizeBytes;
  final DateTime? downloadedAt;

  const DownloadStatus({
    required this.id,
    required this.userId,
    required this.resourceId,
    required this.state,
    required this.progress,
    this.localPath,
    this.fileSizeBytes,
    this.downloadedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        resourceId,
        state,
        progress,
        localPath,
        fileSizeBytes,
        downloadedAt,
      ];
}

enum DownloadState {
  notDownloaded,
  downloading,
  completed,
  failed,
  paused,
}
