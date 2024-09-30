SaveToClipBoard(hwnd, closePaste := false) {
  if hwnd {
    g := GuiFromHwnd(hwnd), g.GetPos(, , &w, &h)
    pBitmap := BitmapFromHWND(g.Hwnd, w - 2 * g.Border(), h - 2 * g.Border(), 0, 0)
    if closePaste
      g.OnDestroy()
  } else { ; if hwnd is 0, use window
    w := A_ScreenWidth, h := A_ScreenHeight
    pBitmap := BitmapFromHWND(hwnd, w, h, 0, 0)
    DllCall("gdiplus\GdipDisposeImage", 'uptr', pBitmap)
    logger.Info('截全屏到剪贴板')
  }
  _SetBitmapToClipboard(pBitmap)
  Tip.ShowTip(_t('savePrompt.a'), , , , false)

  _SetBitmapToClipboard(pBitmap) {
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", 'uptr', pBitmap, 'uptr*', &hBitmap := 0, "int", 0xffffffff)
    DllCall("GetObject", 'uptr', hBitmap, "int", (oi := Buffer(104, 0)).Ptr, 'uptr', oi.Ptr)
    hdib := DllCall("GlobalAlloc", "uint", 2, 'uptr', 40 + NumGet(oi, 52, "UInt"), 'uptr')
    pdib := DllCall("GlobalLock", 'uptr', hdib, 'uptr')
    DllCall("RtlMoveMemory", 'uptr', pdib, 'uptr', oi.Ptr + 32, 'uptr', 40)
    DllCall("RtlMoveMemory", 'uptr', pdib + 40, 'uptr', NumGet(oi, 32 - A_PtrSize, 'uptr'), 'uptr', NumGet(oi, 52, "UInt"))
    DllCall("GlobalUnlock", 'uptr', hdib)
    DllCall("DeleteObject", 'uptr', hBitmap)
    DllCall("OpenClipboard", 'uptr', 0)
    DllCall("EmptyClipboard")
    DllCall("SetClipboardData", "uint", 8, 'uptr', hdib)
    DllCall("CloseClipboard")
  }
}

SaveToFileEx(hwnd, _path := unset, fileName := unset, closePaste := false, suffix := cfg.saveSuffix) {
  WinSetAlwaysOnTop(0, 'ahk_id' hwnd)
  IsSet(fileName) || fileName := Meta.name '_' FormatTime(, "yyyyMMdd_HHmmss") suffix
  fullPath := IsSet(_path)
    ? _path '\' fileName
    : FileSelect("S", cfg.defaultSavePath '\' fileName, '图像另存为', '(*' suffix ')')
  WinSetAlwaysOnTop(1, 'ahk_id' hwnd)
  if !fullPath
    return
  g := GuiFromHwnd(hwnd)
  g.GetPos(, , &w, &h)
  pBitmap := BitmapFromHWND(g.Hwnd, w - 2 * g.Border(), h - 2 * g.Border(), 0, 0)
  if closePaste
    g.OnDestroy()
  return SaveToFile(pBitmap, fullPath)
}

SaveToFile(pBitmap, _path) {
  if !r := SaveBitmapToFile(pBitmap, _path) {
    Tip.ShowTip(_t('savePrompt.s'), , , , false)
    logger.Info('保存为文件，路径：' _path)
    return _path
  }
  Tip.ShowTip(_t('savePrompt.e'), , , , false)
  logger.Info('文件保存失败，值：' r)
  return
}

BitmapFromHWND(hwnd, w, h, x, y) {
  hSourceDC := hwnd ? DllCall('GetDC', 'ptr', hwnd) : DllCall('GetDC', 'ptr', 0)
  hMemDC := DllCall("CreateCompatibleDC", "Ptr", 0)
  hBitmap := DllCall("CreateCompatibleBitmap", "ptr", hSourceDC, "int", w, "int", h)
  hOldBitmap := DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
  DllCall("BitBlt"
    , "Ptr", hMemDC, "int", 0, "int", 0, "int", w, "int", h
    , "Ptr", hSourceDC, "int", x, "int", y
    , "uint", 0xCC0020)
  DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hOldBitmap)
  DllCall('DeleteDC', 'ptr', hMemDC)
  DllCall('ReleaseDC', 'int', 0, 'ptr', hSourceDC)
  DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "Ptr*", &pBitmap := 0)
  return pBitmap
}

SaveBitmapToFile(pBitmap, sOutput, quality := 75) {
  SplitPath(sOutput, , , &ext, &name)
  if !(ext ~= "i)^(BMP|DIB|RLE|JPG|JPEG|JPE|JFIF|GIF|TIF|TIFF|PNG)$")
    return -1
  DllCall("gdiplus\GdipGetImageEncodersSize", "uint*", &nCount := 0, "uint*", &nSize := 0)
  DllCall("gdiplus\GdipGetImageEncoders", "uint", nCount, "uint", nSize, "Ptr", ci := Buffer(nSize))
  if !(nCount && nSize)
    return -2
  ext := '.' ext
  loop nCount {
    sString := StrGet(NumGet(ci, (idx := (48 + 7 * A_PtrSize) * (A_Index - 1)) + 32 + 3 * A_PtrSize, "Ptr"), "UTF-16")
    if !InStr(sString, "*" ext)
      continue
    pCodec := ci.Ptr + idx
    break
  }
  if !pCodec
    return -3
  if quality != 75 and ext ~= 'i)^(\.JPG|\.JPEG|\.JPE|\.JFIF)$' {
    quality := (quality < 0) ? 0 : (quality > 100) ? 100 : quality
    DllCall("gdiplus\GdipGetEncoderParameterListSize", "Ptr", pBitmap, "Ptr", pCodec, "uint*", &nSize := 0)
    DllCall("gdiplus\GdipGetEncoderParameterList", "Ptr", pBitmap, "Ptr", pCodec, "uint", nSize, "Ptr", emt := Buffer(nSize, 0))
    loop NumGet(emt, "uint") {
      elem := (24 + A_PtrSize) * (A_Index - 1) + A_PtrSize
      if (NumGet(emt, elem + 16, "uint") = 1) && (NumGet(emt, elem + 20, "uint") = 6) {
        ep := emt.ptr + elem - A_PtrSize
        NumPut("uptr", 1, ep), NumPut("uint", 4, ep, 20 + A_PtrSize)
        NumPut("uint", quality, NumGet(ep + 24 + A_PtrSize, "uptr"))
        break
      }
    }
  }
  r := DllCall("gdiplus\GdipSaveImageToFile", "ptr", pBitmap, "ptr", StrPtr(sOutput), "ptr", pCodec, "uint", 0)
  DllCall("gdiplus\GdipDisposeImage", 'uptr', pBitmap)
  return r ? -5 : 0
}