; frameGui 的实现
#Include g:\AHK\git-ahk-lib\lib\gdip\GdipStarter.ahk

!q:: ExitApp
; ===========
g1 := Gui('-Caption +ToolWindow')
g1.BackColor := 'red'
WinSetTransColor('red', g1)
g1.Show('x0 y0 w' A_ScreenWidth ' h' A_ScreenHeight)
hdd_frame := DllCall("GetDC", 'ptr', 0)
hdc_frame := DllCall("GetDC", 'ptr', g1.hwnd)
DllCall("BitBlt"
  , "Ptr", hdc_frame, "int", 0, "int", 0, "int", A_ScreenWidth, "int", A_ScreenHeight
  , "Ptr", hdd_frame, "int", 0, "int", 0
  , "uint", 0x00CC0020)
DllCall('ReleaseDC', 'int', 0, 'ptr', hdc_frame)
DllCall('ReleaseDC', 'int', 0, 'ptr', hdd_frame)


g0 := Gui('-Caption +ToolWindow')
g0.BackColor := 'black'
WinSetTransparent(160, g0)
g0.Show('x0 y0 w' A_ScreenWidth ' h' A_ScreenHeight)

staticHdc := GetDC(g1.Hwnd)


f := Frame()
Move()

Move() {
  loop {
    MouseGetPos(&px, &py)
    f.DrawFrame(200, py - 100, px + 20, 200, staticHdc)
  }
}

class Frame extends Gui {

  __New() {
    super.__New('+AlwaysOnTop -Caption +ToolWindow +E0x00080000 +E0x20')
    this.borderPen := Gdip_CreatePen(0xffC07B8E, 1)
    this.Show('NA')
  }

  __Delete() {
    Gdip_DeletePen(this.borderPen)

  }

  DrawFrame(x, y, w, h, staticHdc) {
    hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)

    DllCall("BitBlt"
      , "Ptr", hdc, "int", x, "int", y, "int", w, "int", h
      , "Ptr", staticHdc, "int", x, "int", y
      , "uint", 0x00CC0020)
    Gdip_DrawRoundedRectangle(G, this.borderPen, x - 1, y - 1, w + 1, h + 1, 0)	; border

    UpdateLayeredWindow(this.Hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
  }
}