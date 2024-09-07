#Include Plugin.ahk
#Include ../core/Hook.ahk

class TimestampPlugin extends Plugin {

  __New(color := '#FFFFFF', timeformat := 'yyyyMMdd_HHmmss', pos := 2, bgc := '000000') {
    this.timeformat := timeformat, this.pos := pos, this.bgc := bgc
    this.color := SubStr(color, 2)
  }

  Run() {
    Hook.Register(Events.OnTimestampGenerate, DisplayTimestamp)

    DisplayTimestamp(g, *) {
      ts := TimestampPlugin.Timestamp(g.CreateTime(), this.timeformat, this.color, this.bgc)
      g.GetPos(&x, &y, &w, &h), ts.Show(), ts.GetPos(, , &tw, &th)
      switch this.pos {
        case 0: tx := x, ty := y
        case 1: tx := x + w - tw, ty := y
        case 2: tx := x + w - tw, ty := y + h - th
        case 3: tx := x, ty := y + h - th
      }
      ts.Move(tx, ty)

      DrawTimestamp(g, tx - x, ty - y)
      ts.Destroy()

      DrawTimestamp(target, x, y) {
        hdc_frame := DllCall('GetDC', 'ptr', ts.Hwnd)
        hdd_frame := DllCall('GetDC', 'ptr', target.Hwnd)
        DllCall("StretchBlt"
          , 'ptr', hdd_frame, 'int', x, 'int', y, 'int', tw, 'int', th
          , 'ptr', hdc_frame, 'int', 0, 'int', 0, 'int', tw, 'int', th
          , 'UInt', 0x00660046)
        DllCall('ReleaseDC', 'int', 0, 'ptr', hdc_frame)
        DllCall('ReleaseDC', 'int', 0, 'ptr', hdd_frame)
      }
    }
  }

  class Timestamp extends Gui {

    __New(time, timeformat, color, bgc) {
      timeString := FormatTime(time, timeformat)
      super.__New('+AlwaysOnTop -Caption +ToolWindow')
      this.BackColor := bgc
      this.SetFont('s11', 'consolas')
      this.AddText('vtime c' color, timeString)
    }
  }

}