

class StorageMedium {

  final String path;
  final String name;
  final int totalSpace;
  int freeSpace;

  StorageMedium({
    this.path,
    this.name,
    this.totalSpace,
    this.freeSpace
  }) : assert(path != null),
       assert(name != null),
       assert(totalSpace != null);

  String getPath() => this.path;
  int getTotalSpace() => this.totalSpace;
  int getFreeSpace(){
    if(this.freeSpace == null){
      this.freeSpace = updateFreeSpace();
      return this.freeSpace;
    } else return this.freeSpace;
  }

  ///Will implement later
  int updateFreeSpace(){
    return 0;
  }
}
