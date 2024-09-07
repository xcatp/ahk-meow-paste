#Requires AutoHotkey v2.0

class Helper extends Gui {
  static ins := Helper()

  __New() {
    super.__New('+AlwaysOnTop')
    this.SetFont('s13', 'consolas')
    this.AddListBox("xm r22 w150 0x100", ['基础操作', '注意事项', '配置文件', '关于'])
      .OnEvent('Change', (obj, *) => this.SwitchPage(obj))
    this.AddEdit("yp r22 w450 ReadOnly vInfo", FileRead('./ui/doc/1.txt', 'utf-8'))
  }

  static Show(*) {
    this.ins.Show()
  }

  SwitchPage(obj) {
    v := obj.Value
    try this['Info'].Value := FileRead('./ui/doc/' v '.txt', 'utf-8')
  }
}