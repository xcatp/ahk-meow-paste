class PasteGui extends BaseGui {

  OnDestroy(*) {
    if this.HasProp('content')
      DllCall('DeleteDC', 'ptr', this.content.DC)
    super.OnDestroy(), this.d.OnDestroy()
  }

  ExtendMenu(m) {
    m.Add _t('paste.b'), (*) => _toggleBorderDisplay()

    _toggleBorderDisplay() {
      d := this.d, d.v ? d.Clear() : d.Paint(), d.v := !d.v
    }
  }

  Show(x, y, w, h) {
    Hook._Exec(Events.BeforePaste, this)

    super.Show('Hide'), WinSetTransparent(0, this), Sleep(10)
    super.Show(Format('NA x{} y{} w{} h{}', x, y, w, h))
    this.RegisterEvent()
    sdc := GetDC(StaticBG.insId), hdc := GetDC(this.Hwnd)

    DllCall("BitBlt"
      , "ptr", hdc, "int", 0, "int", 0, "int", w, "int", h
      , "ptr", sdc, "int", x, "int", y
      , "uint", 0x00CC0020)

    WinSetTransparent(255, this)

    sg := PasteGui.DecorateGui(this), sg.Show(), this.d := sg
    ReleaseDC(sdc), ReleaseDC(hdc)

    Hook._Exec(Events.AfterPaste, this)
  }

  MoveWin() {
    MouseGetPos(&px, &py), WinGetPos(&wx, &wy, , , 'A')
    this.GetPos(&wx, &wy), this.d.GetPos(&xx, &yy)
    dx := wx - px, dy := wy - py, bx := xx - px, by := yy - py
    While GetKeyState("LButton", "P") {
      MouseGetPos(&nx, &ny)
      this.Move(nx + dx, ny + dy)
      this.d.Move(nx + bx, ny + by)
    }
  }

  Zoom() => this.d.Paint()

  class DecorateGui extends Gui {
    ; 使用 Gdi 绘图，可以绘画任何东西 :D

    __New(parent) {
      super.__New('+AlwaysOnTop -Caption +ToolWindow +E0x00080000')
      this.parent := parent, this.b := mcf.Get('borderWidth', 1), this.v := true
      this.borderPen := Gdip_CreatePen(mcf.Get('borderColor', 0xffC07B8E), this.b)
    }

    OnDestroy() {
      Gdip_DeletePen(this.borderPen)
      this.Destroy()
    }

    Show() {
      super.Show(Format('x0 y0 w{} h{}', A_ScreenWidth, A_ScreenHeight))
      this.Paint()
    }

    Clear() {
      hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
      hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
      G := Gdip_GraphicsFromHDC(hdc)
      UpdateLayeredWindow(this.Hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
      Gdip_DeleteGraphics(G)
      SelectObject(hdc, obm), DeleteObject(obm), DeleteDC(hdc)
    }

    Paint() {
      _drawBorder()

      _drawBorder() {
        hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
        hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc), b := this.b
        this.parent.GetPos(&x, &y, &w, &h)

        Gdip_DrawRectangle(G, this.borderPen, x - b / 2, y - b / 2, w + b, h + b)
        UpdateLayeredWindow(this.Hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
        Gdip_DeleteGraphics(G)
        SelectObject(hdc, obm), DeleteObject(obm), DeleteDC(hdc)
      }
    }
  }
}