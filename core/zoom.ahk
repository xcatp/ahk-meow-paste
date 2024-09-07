#Include g:\AHK\git-ahk-lib\Tip.ahk

OnMessage(0x020A, OnWheel)

OnWheel(wParam, lParam, msg, *) {
  MouseGetPos(, , &hwnd)
  if not ((g := GuiFromHwnd(hwnd)) is BaseGui)
    return
  if (g is PasteGui) and GetKeyState('LButton', 'P')
    return
  (wParam >> 16 = 120) ? zoom(hwnd, 'in') : zoom(hwnd, 'out')
}

class StretchRatio {
  static zoomIn := 1.1                 ; the rate of zoom in
  static zoomOut := 0.95               ;
  static normal := 15                  ; the default zoom level
  static max := 30                     ; the max level
  static min := 1                      ; the min level, must be greater than 0
}

zoom(hwnd, outOrIn) {
  g := GuiFromHwnd(hwnd)
  if !g.HasProp('eProxy')
    return
  g.GetPos(&x, &y, &gw, &gh)
  if !g.HasProp('content') {
    gw -= g.Border(), gh -= g.Border()
    g.content := {
      DC: GetMemDc(g.Hwnd, gw, gh, 0, 0),
      w: gw,
      h: gh
    }
  }
  zoom := g.ZoomLevel(), frameDC := DllCall("GetDC", 'ptr', hwnd)
  if outOrIn = 'out' {
    if zoom = StretchRatio.min
      return
    zoom--
    if zoom >= StretchRatio.normal {
      w := g.content.w * (StretchRatio.zoomIn ** (zoom - StretchRatio.normal))
      h := g.content.h * (StretchRatio.zoomIn ** (zoom - StretchRatio.normal))
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
      w := g.content.w * (StretchRatio.zoomOut ** (StretchRatio.normal - zoom))
      h := g.content.h * (StretchRatio.zoomOut ** (StretchRatio.normal - zoom))
      DllCall("gdi32.dll\SetStretchBltMode", "uint", frameDC, "int", 4)
    } else {
      w := gw * StretchRatio.zoomIn
      h := gh * StretchRatio.zoomIn
    }
  }
  w := Floor(w), h := Floor(h)
  g.ZoomLevel(zoom).SizeW(w).SizeH(h)

  g.Move(, , w, h)
  g.eProxy.Move(, , w, h)

  Sleep 0

  DllCall("StretchBlt"
    , 'ptr', frameDC, 'int', 0, 'int', 0, 'int', w, 'int', h
    , 'ptr', g.content.DC, 'int', 0, 'int', 0, 'int', g.content.w, 'int', g.content.h
    , 'UInt', 0xCC0020)
  DllCall('ReleaseDC', 'int', 0, 'ptr', frameDC)
  g.Zoom()
  Tip.ShowTip(g.ZoomLevel(), x, y, 500)
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