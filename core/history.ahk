#Requires AutoHotkey v2.0
#Include ..\_lib\Fs.ahk

class History {

  static fileList := [], backPool := [], cur := -1

  static Init(_dir) {
    l := this.fileList := [], this.backPool := []
    FS.ReadDir(_dir, _filter, fullPath => l.Push(fullPath), '*.*')
    this.cur := l.Length

    _filter(v) {
      SplitPath v, , , &ext
      return ext ~= '^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$'
    }
  }

  static Reset() {
    this.cur := this.fileList.Length, this.backPool := []
  }

  static AddFile(fileName) {
    this.fileList.Push(fileName), this.backPool.Push(this.fileList.Length)
    return this.fileList.Length
  }

  static DelFile(id) => this.fileList.Delete(id) ; not removeAt
  static ReturnToPool(id) => this.backPool.Push(id)

  static Consume() {
    if this.cur = -1
      throw Error('未初始化')
    if this.backPool.Length {
      id := this.backPool.Pop()
      if this.fileList.Has(id)
        fullPath := this.fileList[id]
      else {
        logger.Debug('返回池中存放已销毁')
        return History.Consume()
      }
    } else {
      while this.cur > 0 and !this.fileList.Has(this.cur) ; 在第一轮回时不会出现
        this.cur--
      if this.cur = 0
        return
      id := this.cur, fullPath := this.fileList[this.cur--]
    }
    if !FileExist(fullPath) {
      logger.Debug('外部删除了文件：' fullPath)
      return History.Consume()
    }
    return { id: id, fullPath: fullPath }
  }
}