; 废弃的缩放方案
#Requires AutoHotkey v2.0

CoordMode 'Mouse'
CoordMode 'ToolTip'

#Include ..\_lib\GdipStarter.ahk

g2 := Gui('-Caption +ToolWindow +E0x00080000 +AlwaysOnTop')
x := 115, y := 115, w := 600, h := 600
borderPen := Gdip_CreatePen(0xffC07B8E, b := 2), bb := b * 2
g2.Show()
g2.Move(x - b, y - b, w + bb, h + bb)
; ----------------
hbm := CreateDIBSection(w + bb, h + bb)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
sdc := GetDC(0)
G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4)
DllCall("BitBlt"
  , "Ptr", hdc, "int", b, "int", b, "int", w, "int", h
  , "Ptr", sdc, "int", x, "int", y
  , "uint", 0x00CC0020)
Gdip_DrawRectangle(G, borderPen, b / 2, b / 2, w + b, h + b)
UpdateLayeredWindow(g2.Hwnd, hdc, x - b, y - b, w + bb, h + bb)
Gdip_DeleteGraphics(G)
; ; -------------
bmp := Gdip_CreateBitmapFromHBITMAP(hbm)

r := 1

OnMessage(0x020A, OnWheel)
OnWheel(wParam, lParam, msg, *) {
  global r
  (wParam >> 16 = 120) ? zoom(r += 0.02) : zoom(r -= 0.02)
}

Zoom(r) {
  global w, h
  G1 := Gdip_GraphicsFromHDC(hdc)
  Gdip_SetInterpolationMode(G1, 7)
  Gdip_SetSmoothingMode(G1, 4)

  Gdip_ScaleWorldTransform(G1, r, r)
  Gdip_DrawImage(G1, bmp)

  UpdateLayeredWindow(g2.Hwnd, hdc, x - b, y - b, w + bb, h + bb)
  Gdip_DeleteGraphics(G1)
}