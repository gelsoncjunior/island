import 'dart:async';
import '../models/dropped_file.dart';
import 'clipboard_service.dart';

/// Interface para o gerenciamento de arquivos
/// Segue o princípio DIP - dependência de abstração, não de implementação
abstract class IFileManagerService {
  Stream<List<DroppedFile>> get filesStream;
  List<DroppedFile> get files;
  Future<void> addFile(DroppedFile file);
  Future<void> addFileFromPath(String filePath);
  void removeFile(DroppedFile file);
  void clearAll();
  Future<bool> copyFileToClipboard(DroppedFile file);
  Future<bool> copyAllFilesToClipboard();

  // Getters para clipboard
  bool get hasFilesInClipboard;
  List<DroppedFile> get clipboardFiles;

  // Métodos para clipboard
  Future<bool> pasteFilesToDirectory(String targetDirectory);
  void clearClipboard();
}

/// Implementação concreta do serviço de gerenciamento de arquivos
/// Segue o princípio SRP - responsável apenas por gerenciar arquivos em memória
/// Agora integrado com o clipboard service
class FileManagerService implements IFileManagerService {
  static final FileManagerService _instance = FileManagerService._internal();
  factory FileManagerService() => _instance;
  FileManagerService._internal();

  final List<DroppedFile> _files = [];
  final StreamController<List<DroppedFile>> _filesController =
      StreamController<List<DroppedFile>>.broadcast();

  // Integração com clipboard service seguindo DIP
  final IClipboardService _clipboardService = ClipboardServiceFactory.create();

  @override
  Stream<List<DroppedFile>> get filesStream => _filesController.stream;

  @override
  List<DroppedFile> get files => List.unmodifiable(_files);

  @override
  Future<void> addFile(DroppedFile file) async {
    // Evita duplicatas baseado no caminho completo
    if (!_files.any((f) => f.fullPath == file.fullPath)) {
      // Garante que o arquivo tenha os bytes carregados
      final loadedFile = await file.loadBytes();
      _files.add(loadedFile);
      _notifyListeners();
    }
  }

  @override
  Future<void> addFileFromPath(String filePath) async {
    try {
      final droppedFile = await DroppedFile.fromPath(filePath);
      await addFile(droppedFile);
    } catch (e) {
      // Em caso de erro, adiciona sem bytes para manter compatibilidade
      final fallbackFile = DroppedFile.fromPathSync(filePath);
      await addFile(fallbackFile);
    }
  }

  @override
  void removeFile(DroppedFile file) {
    if (_files.remove(file)) {
      _notifyListeners();
    }
  }

  @override
  void clearAll() {
    if (_files.isNotEmpty) {
      _files.clear();
      _notifyListeners();
    }
  }

  @override
  Future<bool> copyFileToClipboard(DroppedFile file) async {
    final result = await _clipboardService.copyFileToClipboard(file);
    return result;
  }

  @override
  Future<bool> copyAllFilesToClipboard() async {
    if (_files.isEmpty) return false;
    return await _clipboardService.copyFilesToClipboard(_files);
  }

  /// Retorna informações sobre o clipboard
  @override
  bool get hasFilesInClipboard => _clipboardService.hasFilesInClipboard;

  @override
  List<DroppedFile> get clipboardFiles => _clipboardService.clipboardFiles;

  /// Cola arquivos do clipboard em um diretório
  @override
  Future<bool> pasteFilesToDirectory(String targetDirectory) async {
    return await _clipboardService.pasteFilesToDirectory(targetDirectory);
  }

  /// Limpa o clipboard
  @override
  void clearClipboard() {
    _clipboardService.clearClipboard();
  }

  void _notifyListeners() {
    _filesController.add(List.unmodifiable(_files));
  }

  void dispose() {
    _filesController.close();
    // Limpa arquivos temporários do clipboard
    if (_clipboardService is MacOSClipboardService) {
      (_clipboardService).cleanupTempFiles();
    }
  }
}
