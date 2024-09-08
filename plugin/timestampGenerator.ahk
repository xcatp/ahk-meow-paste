#Include Plugin.ahk
#Include ../core/Hook.ahk

class TimestampPlugin extends Plugin {

  __New(color := 'FFFFFF', timeformat := 'yyyyMMdd_HHmmss', bgc := '000000') {
    this.timeformat := timeformat, this.bgc := bgc, this.color := color
  }

  Run() {
    Hook.Register(Events.OnTimestampGenerate, DisplayTimestamp)

    DisplayTimestamp(params) {
      DCon(params, &g, &cx, &cy), g.GetPos(&x, &y, &w, &h)
      bw := w / 5, bh := h / 5, pos := 2
      if cx <= bw
        pos := cy <= bh ? 0 : cy.between(h - bh, h) ? 3 : pos
      else if cx.between(w - bw, w)
        pos := cy <= bh ? 1 : 2
      ts := TimestampPlugin.Timestamp(g.CreateTime(), this.timeformat, this.color, this.bgc)
      ts.Show(), ts.GetPos(, , &tw, &th)
      switch pos {
        case 0: tx := x, ty := y
        case 1: tx := x + w - tw, ty := y
        case 2: tx := x + w - tw, ty := y + h - th
        case 3: tx := x, ty := y + h - th
      }
      ts.Move(tx, ty)

      DrawTimestamp(g, tx - x, ty - y)
      ts.Destroy()

      DrawTimestamp(target, rx, ry) {
        hdc_frame := DllCall('GetDC', 'ptr', ts.Hwnd)
        if target.HasProp('content') { ; 避免缩放时被覆盖
          _x := rx = 0 ? 0 : target.content.w - tw
          _y := ry = 0 ? 0 : target.content.h - th
          DllCall("StretchBlt"
            , 'ptr', target.content.DC, 'int', _x, 'int', _y, 'int', tw, 'int', th
            , 'ptr', hdc_frame, 'int', 0, 'int', 0, 'int', tw, 'int', th
            , 'UInt', 0x00660046)
        }
        hdd_frame := DllCall('GetDC', 'ptr', target.Hwnd)
        DllCall("StretchBlt"
          , 'ptr', hdd_frame, 'int', rx, 'int', ry, 'int', tw, 'int', th
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