class FrameGui extends Gui {
  ; An intermediate
  
  __New() {
    super.__New('+AlwaysOnTop -Caption +ToolWindow +E0x00080000', 'frame')
    this.borderPen := Gdip_CreatePen(0xff458588, 1)
    this.staticHdc := DllCall("GetDC", 'ptr', StaticBG.insId)
    this.Show()
  }

  OnDestroy() {
    Gdip_DeletePen(this.borderPen)
    DllCall('ReleaseDC', 'int', 0, 'ptr', this.staticHdc)
    this.Destroy()
  }

  GetPos(&x, &y, &w, &h) => DCon(this.pos, &x, &y, &w, &h)

  Move(x?, y?, w?, h?) {
    DCon(this.pos, &_x, &_y, &_w, &_h)
    IsSet(x) && _x := x
    IsSet(y) && _y := y
    IsSet(w) && _w := w
    IsSet(h) && _h := h
    this.DrawFrame(_x, _y, _w, _h)
  }

  DrawFrame(x, y, w, h) {
    this.pos := [x, y, w, h]

    hdc := CreateCompatibleDC()
    hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
    obm := SelectObject(hdc, hbm)

    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)

    DllCall("BitBlt"
      , "Ptr", hdc, "int", x, "int", y, "int", w, "int", h
      , "Ptr", this.staticHdc, "int", x, "int", y
      , "uint", 0x00CC0020)

    x := w < 0 ? x + w : x, y := h < 0 ? y + h : y
    w := Abs(w), h := Abs(h)

    Gdip_DrawRectangle(G, this.borderPen, x - 1, y - 1, w + 1, h + 1)

    UpdateLayeredWindow(this.Hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)

    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
  }

  ConvertToPasteGui() {
    DCon(this.pos, &x, &y, &w, &h), this.OnDestroy()
    g := PasteGui(), g.Show(x, y, w, h)
    return g
  }
}