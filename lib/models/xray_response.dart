class ZoneInfo {
  final List<int> box;
  final double confidence;
  final String disease;
  final String label;
  final int zoneId;

  ZoneInfo({
    required this.box,
    required this.confidence,
    required this.disease,
    required this.label,
    required this.zoneId,
  });

  factory ZoneInfo.fromJson(Map<String, dynamic> json) {
    return ZoneInfo(
      box: List<int>.from(json['box']),
      confidence: json['confidence'].toDouble(),
      disease: json['disease'],
      label: json['label'],
      zoneId: json['zone_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'box': box,
      'confidence': confidence,
      'disease': disease,
      'label': label,
      'zone_id': zoneId,
    };
  }
}

class Disease {
  final String name;
  final String camFile;
  final double predProb;
  final String annotatedPath;
  final List<Map<String, dynamic>> ious;
  final List<ZoneInfo> zoneInfo;

  Disease({
    required this.name,
    required this.camFile,
    required this.predProb,
    required this.annotatedPath,
    required this.ious,
    required this.zoneInfo,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'],
      camFile: json['cam_file'],
      predProb: json['pred_prob'].toDouble(),
      annotatedPath: json['annotated_path'],
      ious: List<Map<String, dynamic>>.from(json['ious']),
      zoneInfo: (json['zone_info'] as List)
          .map((e) => ZoneInfo.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cam_file': camFile,
      'pred_prob': predProb,
      'annotated_path': annotatedPath,
      'ious': ious,
      'zone_info': zoneInfo.map((e) => e.toJson()).toList(),
    };
  }
}

class FileData {
  final String fileName;
  final String uploadTime;
  final List<Disease> diseases;

  FileData({
    required this.fileName,
    required this.uploadTime,
    required this.diseases,
  });

  factory FileData.fromJson(Map<String, dynamic> json) {
    return FileData(
      fileName: json['file_name'],
      uploadTime: json['upload_time'],
      diseases: (json['diseases'] as List)
          .map((e) => Disease.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'upload_time': uploadTime,
      'diseases': diseases.map((e) => e.toJson()).toList(),
    };
  }
}

class XrayResponse {
  final String status;
  final String message;
  final int countFindings;
  final int totalFiles;
  final List<FileData> files;

  XrayResponse({
    required this.status,
    required this.message,
    required this.countFindings,
    required this.totalFiles,
    required this.files,
  });

  factory XrayResponse.fromJson(Map<String, dynamic> json) {
    return XrayResponse(
      status: json['status'],
      message: json['message'],
      countFindings: json['count_findings'],
      totalFiles: json['total_files'],
      files: (json['files'] as List)
          .map((e) => FileData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'count_findings': countFindings,
      'total_files': totalFiles,
      'files': files.map((e) => e.toJson()).toList(),
    };
  }
}