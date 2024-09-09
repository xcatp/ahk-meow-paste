PasteHistory(*) {
  if !History.FileList.Length {
    Tip.ShowTip(_t('prompt.na'), , , 1000)
    return
  }
  if r := History.Consume() {
    DllCall("gdiplus\GdipCreateBitmapFromFile", 'uptr', StrPtr(r.fullPath), 'uptr*', &pBitmap := 0)
    GetImageDimensions(pBitmap, &w, &h)

    g := HistoryGui(r.id, r.fullPath)
    g.Show(w, h, r.id)
    DisplayBitmap(pBitmap, g.Hwnd, w, h)

  } else Tip.ShowTip(_t('prompt.a'), , , 1000)
}

PasteFile(path) {
  if !path {
    Tip.ShowTip(_t('prompt.e'))
    return
  }
  SplitPath path, , , &ext
  if not ext ~= '^(?i:BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$' {
    Tip.ShowTip(_t('prompt.ee') ext _t('common.m'))
    return
  }
  DllCall("gdiplus\GdipCreateBitmapFromFile", 'uptr', StrPtr(path), 'uptr*', &pBitmap := 0)
  GetImageDimensions(pBitmap, &w, &h)
  if w > A_ScreenWidth || h > A_ScreenHeight
    Tip.ShowTip(_t('prompt.es'))

  g := BaseGui(), x := 0, y := 0
  if w <= A_ScreenWidth - 100
    x := 100
  if h <= A_ScreenHeight - 100
    y := 100
  g.Show('x' x ' y' y ' w' w ' h' h), g.RegisterEvent()

  DisplayBitmap(pBitmap, g.Hwnd, w, h)
  WinSetTransparent(255, g)
}

GetImageDimensions(pBitmap, &Width, &Height) {
  DllCall("gdiplus\GdipGetImageWidth", 'uptr', pBitmap, "uint*", &Width := 0)
  DllCall("gdiplus\GdipGetImageHeight", 'uptr', pBitmap, "uint*", &Height := 0)
}

DisplayBitmap(pBitmap, hwnd, w, h) {
  hdc := DllCall("GetDC", 'ptr', hwnd)
  hdcMem := DllCall("CreateCompatibleDC", "ptr", hdc)
  DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", 'uptr', pBitmap, 'uptr*', &hBitmap := 0, "int", 0xffffffff)
  oldBitmap := DllCall('SelectObject', 'ptr', hdcMem, 'ptr', hBitmap)
  hdcSource := DllCall("CreateCompatibleDC", "Ptr", hdc)
  DllCall('SelectObject', 'ptr', hdcSource, 'ptr', pBitmap)
  DllCall("BitBlt"
    , "ptr", hdcMem, "int", 0, "int", 0, "int", w, "int", h
    , "ptr", hdcSource, "int", 0, "int", 0
    , "uint", 0xCC0020)
  DllCall("DeleteDC", "ptr", hdcSource)
  DllCall("BitBlt"
    , "ptr", hdc, "int", 0, "int", 0, "int", w, "int", h
    , "ptr", hdcMem, "int", 0, "int", 0
    , "uint", 0xCC0020)
  DllCall('SelectObject', 'ptr', hdcMem, 'ptr', oldBitmap)
  DllCall("DeleteDC", "ptr", hdcSource)
  DllCall('DeleteObject', 'ptr', hBitmap)
  DllCall("DeleteDC", "ptr", hdcMem)
  DllCall("gdiplus\GdipDisposeImage", 'uptr', pBitmap)
}