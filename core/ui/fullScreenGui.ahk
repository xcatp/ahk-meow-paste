class FullScreenGui extends Gui {

  static insId := ''

  __New(opt := '') {
    super.__New('+AlwaysOnTop -Caption +ToolWindow ' opt)
  }

  static Close() {
    try WinClose('ahk_id' this.insId)
    this.insId := ''
  }
}

class Mask extends FullScreenGui {

  static Show(*) {
    if !cfg.showMask or this.insId
      return
    ins := Mask()
    ins.BackColor := cfg.maskBgc
    ins.Show('NA x0 y0 w' A_ScreenWidth ' h' A_ScreenHeight)
    WinSetTransparent(cfg.maskTRP, ins)
    this.insId := ins.Hwnd
  }
}

class StaticBG extends FullScreenGui {

  static c := mcf.Get('withCursor', 0)

  static Show(*) {
    ins := StaticBG()
    ins.Show('hide x0 y0 w' A_ScreenWidth ' h' A_ScreenHeight)
    WinSetTransparent(0, ins), Sleep(10)
    ins.Show('NA')
    hdc := DllCall('GetDC', 'ptr', ins.Hwnd), sdc := DllCall("GetDC", 'ptr', 0)

    DllCall("BitBlt"
      , "ptr", hdc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight
      , "ptr", sdc, "int", 0, "int", 0
      , "uint", 0x00CC0020)

    WinSetTransparent('off', ins)
    ReleaseDC(hdc), ReleaseDC(sdc)
    this.insId := ins.Hwnd, MouseGetPos(&x, &y)
    NumPut('uint', 24, mi := Buffer(24, 0), 0)
    DllCall('GetCursorInfo', 'uptr', mi.Ptr)
    this.data := {
      memDc: GetMemDc(ins.Hwnd, A_ScreenWidth, A_ScreenHeight, 0, 0),
      cursorX: x,
      cursorY: y,
      hCursor: DllCall("CopyIcon", "uint", NumGet(mi, 8, 'uint'))
    }
    this.ToggleWithCursor()
  }

  static Close() {
    super.Close()
    ReleaseDC(this.data.memDc)
    DllCall("DestroyIcon", "uint", this.data.hCursor)
  }

  static ToggleWithCursor() {
    sdc := GetDC(StaticBG.insId), withCursor := this.c
    withCursor ? _captureCursor() : _unCaptureCursor()
    ReleaseDC(sdc)

    _unCaptureCursor() {
      DllCall("BitBlt"
        , "ptr", sdc, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight
        , "ptr", this.data.memDc, "int", 0, "int", 0
        , "uint", 0x00CC0020)
    }

    _captureCursor() {
      DllCall('GetIconInfo', 'uint', this.data.hCursor, 'uptr', (buf := Buffer(40, 0)).Ptr)
      xHotspot := NumGet(buf, 4, 'uint')
      yHotspot := NumGet(buf, 8, 'uint')
      hbmMask := NumGet(buf, 12, 'uint')
      hbmColor := NumGet(buf, 16, 'uint')

      DllCall("DrawIcon"
        , "uint", sdc
        , "int", this.data.cursorX - xHotspot
        , "int", this.data.cursorY - yHotspot
        , "uint", this.data.hCursor)

      DllCall("DeleteObject", "uint", hbmMask)
      DllCall("DeleteObject", "uint", hbmColor)
    }
  }
}