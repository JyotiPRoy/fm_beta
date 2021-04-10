import 'dart:io';
import 'package:path/path.dart';

class IconProvider {

  static String getIcon(FileSystemEntity entity) {
    if (entity is Directory) {
      String _basename = basename(entity.path);
      if (_icons.containsKey(_basename)) {
        return _icons[_basename];
      } else
        return _icons['genericFolder'];
    } else if (entity is File) {
      String ext = extension(entity.path).length >= 2
          ? extension(entity.path).substring(1)
          : extension(entity.path);
      if (_icons.containsKey(ext)) {
        return _icons[ext];
      } else
        return _icons['genericFile'];
    } else
      throw UnimplementedError('Unknown File Entity');
  }

  static Map<String, String> _icons = {
    ///Folders Start
    'genericFolder': 'assets/icons/generic-folder.svg',
    'DCIM': 'assets/icons/pictures-folder.svg',
    'Pictures': 'assets/icons/pictures-folder.svg',
    'Document': 'assets/icons/documents-folder.svg',
    'Documents': 'assets/icons/documents-folder.svg',
    'Download': 'assets/icons/downloads-folder.svg',
    'Downloads': 'assets/icons/downloads-folder.svg',
    'Music': 'assets/icons/music-folder.svg',
    'Songs': 'assets/icons/music-folder.svg',
    'Movies': 'assets/icons/video-folder.svg',
    'Videos': 'assets/icons/video-folder.svg',
    'Telegram': 'assets/icons/telegram-folder.svg',
    'WhatsApp': 'assets/icons/whatsapp-folder.svg',

    ///Folders End
    ///Files Start
    'genericFile': 'assets/icons/generic-file.svg',
    'multiple_files': 'assets/icons/multiple_files.svg',
    'aac': 'assets/icons/aac.svg',
    'cbr': 'assets/icons/cbr.svg',
    'doc': 'assets/icons/doc.svg',
    'docx': 'assets/icons/doc.svg',
    'odt': 'assets/icons/doc.svg',
    'epub': 'assets/icons/epub.svg',
    'gif': 'assets/icons/gif.svg',
    'html': 'assets/icons/html_xml.svg',
    'xml': 'assets/icons/html_xml.svg',
    'java': 'assets/icons/java.svg',
    'jpg': 'assets/icons/pic.svg',
    'jpeg': 'assets/icons/pic.svg',
    'png': 'assets/icons/pic.svg',
    'mp3': 'assets/icons/music.svg',
    'mp4': 'assets/icons/video-file.svg',
    'mkv': 'assets/icons/video-file.svg',
    'mov': 'assets/icons/video-file.svg',
    'pdf': 'assets/icons/pdf.svg',
    'txt': 'assets/icons/txt.svg',
    'xls': 'assets/icons/xls.svg',
    'csv': 'assets/icons/xls.svg',
    'zip': 'assets/icons/zip.svg',

    ///Files End
  };
}