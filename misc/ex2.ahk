; 最终的缩放方案
#Requires AutoHotkey v2.0

CoordMode 'Mouse'
CoordMode 'ToolTip'

#Include ..\_lib\GdipStarter.ahk

!q:: ExitApp

sdc := GetDC()
; ==================
; 修饰
g2 := Gui('-Caption +ToolWindow +E0x00080000 +AlwaysOnTop')
g2.Show(), g2.Move(0, 0, A_ScreenWidth, A_ScreenHeight)
borderPen := Gdip_CreatePen(0xffC07B8E, b := 2), bb := b * 2
; =================
; 贴图
g3 := Gui('-Caption +ToolWindow +AlwaysOnTop')
g3.Show('hide')
WinSetTransparent(0, g3)
g3.Show('NA')
g3.Move(800, 100, 600, 800)
hcdc := GetDC(g3.Hwnd)
text := g3.AddText('xs x0 y0 w600 h800')
text.OnEvent('Click', (*) => _moveWin())
g3.eProxy := text

g3.ZoomLevel := StretchRatio.normal
;
DllCall("BitBlt"
  , "Ptr", hcdc, "int", 0, "int", 0, "int", 600, "int", 800
  , "Ptr", sdc, "int", b, "int", b
  , "uint", 0x00CC0020)
WinSetTransparent(255, g3)

; ============ draw border
DrawBorder()

DrawBorder() {
  hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
  hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
  G := Gdip_GraphicsFromHDC(hdc)
  g3.GetPos(&xx, &yy, &ww, &hh)

  Gdip_DrawRectangle(G, borderPen, xx - b / 2, yy - b / 2, ww + b, hh + b)
  UpdateLayeredWindow(g2.Hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
}

OnMessage(0x020A, OnWheel)
OnWheel(wParam, lParam, msg, *) {
  (wParam >> 16 != 120) ? zoom('out') : zoom('in')
}

zoom(outOrIn) {

  if !g3.HasProp('eProxy')
    return
  g3.GetPos(&x, &y, &gw, &gh)
  if !g3.HasProp('content') {
    g3.content := {
      DC: GetMemDc(g3.Hwnd, gw, gh, 0, 0),
      w: gw,
      h: gh
    }
  }
  zoom := g3.ZoomLevel, frameDC := DllCall("GetDC", 'ptr', g3.hwnd)
  if outOrIn = 'out' {
    if zoom = StretchRatio.min
      return
    zoom--
    if zoom >= StretchRatio.normal {
      w := g3.content.w * (StretchRatio.zoomIn ** (zoom - StretchRatio.normal))
      h := g3.content.h * (StretchRatio.zoomIn ** (zoom - StretchRatio.normal))
    } else {
      w := gw * StretchRatio.zoomOut
      h := gh * StretchRatio.zoomOut
      DllCall("gdi32.dll\SetStretchBltMode", "uint", frameDC, "int", 4)
    }
  } else if outOrIn = 'in' {
    if zoom = StretchRatio.max
      return
    zoom++
    if zoom <= StretchRatio.normal {
      w := g3.content.w * (StretchRatio.zoomOut ** (StretchRatio.normal - zoom))
      h := g3.content.h * (StretchRatio.zoomOut ** (StretchRatio.normal - zoom))
      DllCall("gdi32.dll\SetStretchBltMode", "uint", frameDC, "int", 4)
    } else {
      w := gw * StretchRatio.zoomIn
      h := gh * StretchRatio.zoomIn
    }
  }
  w := Floor(w), h := Floor(h)
  g3.ZoomLevel := zoom

  g3.Move(, , w, h)
  g3.eProxy.Move(, , w, h)

  Sleep 0

  DllCall("StretchBlt"
    , 'ptr', frameDC, 'int', 0, 'int', 0, 'int', w, 'int', h
    , 'ptr', g3.content.DC, 'int', 0, 'int', 0, 'int', g3.content.w, 'int', g3.content.h
    , 'UInt', 0xCC0020)
  DllCall('ReleaseDC', 'int', 0, 'ptr', frameDC)
  DrawBorder()
}


_moveWin(*) {
  MouseGetPos(&px, &py)
  WinGetPos(&wx, &wy, , , 'A')
  g3.GetPos(&wx, &wy), g2.GetPos(&xx, &yy)
  dx := wx - px, dy := wy - py, bx := xx - px, by := yy - py
  While GetKeyState("LButton", "P") {
    MouseGetPos(&nx, &ny)
    g3.Move(nx + dx, ny + dy)
    g2.Move(nx + bx, ny + by)
  }
}


class StretchRatio {
  static zoomIn := 1.1                 ; the rate of zoom in
  static zoomOut := 0.95               ;
  static normal := 15                  ; the default zoom level
  static max := 30                     ; the max level
  static min := 1                      ; the min level, must be greater than 0
}


GetMemDc(hwnd, w, h, x, y) {
  hSourceDC := DllCall('GetDC', 'ptr', hwnd), hMemDC := DllCall("CreateCompatibleDC", "Ptr", 0)
  hBitmap := DllCall("CreateCompatibleBitmap", "ptr", hSourceDC, "int", w, "int", h)
  hOldBitmap := DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
  DllCall("BitBlt"
    , "Ptr", hMemDC, "int", 0, "int", 0, "int", w, "int", h
    , "Ptr", hSourceDC, "int", x, "int", y
    , "uint", 0xCC0020)
  hOldBitmap := DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hOldBitmap)
  memDC := DllCall("CreateCompatibleDC", "Ptr", 0)
  DllCall("SelectObject", "Ptr", memDC, "Ptr", hBitmap)

  DllCall('DeleteDC', 'ptr', hMemDC)
  DllCall('ReleaseDC', 'int', 0, 'ptr', hSourceDC)
  DllCall("DeleteObject", 'uptr', hBitmap)
  return memDC
}