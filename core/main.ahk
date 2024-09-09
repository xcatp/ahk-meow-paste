#Include g:\AHK\git-ahk-lib\lib\gdip\GdipStarter.ahk
#Include g:\AHK\git-ahk-lib\Extend.ahk
#Include g:\AHK\git-ahk-lib\Tip.ahk
#Include g:\AHK\git-ahk-lib\util\Cursor.ahk

#Include zoom.ahk
#Include hook.ahk
#Include save.ahk
#Include paste.ahk
#Include ui/frameGui.ahk
#Include ui/baseGui.ahk
#Include ui/pasteGui.ahk
#Include ui/fullScreenGui.ahk
#Include ui/historyGui.ahk
#Include ui/delayGui.ahk
#Include ui/toolBarGui.ahk

#Include ../ui/Helper.ahk
#Include ../ui/Setting.ahk

isReady := true

tray := A_TrayMenu
  , tray.delete()
  , tray.add('截图', (*) => Start((*) => Sleep(300)))
  , tray.add('延时截图', (*) => Start((*) => DelayGui.Show(3)))
  , tray.add('打开上一次截图', (*) => PasteHistory())
  , tray.add('打开文件', (*) => PasteFile(FileSelect(, cfg.defaultSavePath)))
  , tray.add()
  , tray.add('设置', (*) => Setting().Show())
  , tray.add('打开文件夹', (*) => Run(A_ScriptDir))
  , tray.add()
  , tray.add('帮助', (*) => Helper.Show())
  , tray.add()
  , tray.add('重新启动', (*) => Reload())
  , tray.add("退出", (*) => ExitApp())
  , tray.ClickCount := cfg.clickCount
  , tray.Default := '截图'

Hotkey cfg.clipHK, (*) => Start()
Hotkey cfg.clearAllHK, (*) => ClearAll()
HotKey cfg.lastHK, (*) => PasteHistory()

Start(Before := unset) {
  global isReady
  if !isReady
    return
  isReady := false, IsSet(Before) && Before()
  Tip.ShowTip(''), StaticBG.Show(), cfg.showMaskIST && Mask.Show()
  Tip.ShowTip('READY', , , 0), Cursor.SetIcon(Cursor.Icon.cross)
  Hotkey 'LButton', cfg.pasteInstantly ? StartClip : StartClipWithToolBar, 'On'
  Hotkey(cfg.cancelHK, Cancel, 'On'), Hotkey('RButton Up', Cancel, 'On')
  Hotkey('``', (*) => (StaticBG.c := !StaticBG.c, StaticBG.ToggleWithCursor()), 'On')
}

ClearAll(excludes := []) {
  list := []
  for w in WinGetList('ahk_pid ' ProcessExist()) {
    if (g := GuiFromHwnd(w)) is FullScreenGui
      return
    if g is BaseGui and !excludes.findIndex(v => v = g)
      list.Push(g)
  }
  if !list.Length
    return
  for v in list
    v.OnDestroy()
  History.Reset(), Tip.ShowTip('Clear all')
}

StartClip(*) {
  Tip.ShowTip(''), Mask.Show()
  g := GetGui(cfg.withTip).ConvertToPasteGui(), AutoSave(g)
  ResetState(), HotKeysOff(cfg.cancelHK, 'LButton', 'RButton Up', '``')
}

StartClipWithToolBar(*) {
  Tip.ShowTip(''), Cursor.SetIcon(Cursor.Icon.arrow), Mask.Show()
  g := GetGui(cfg.withTip), g.GetPos(&x, &y, &w, &h)
  HotKeysOff('LButton', '``')

  bar := MyToolBar(['取消', '确定']
    , x + w - MyToolBar.btnW * 2, y + h
    , [(*) => Cancel_(bar, g), (*) => Bar_OkCB(bar, g.ConvertToPasteGui())])
  bar.Adapt(x, y, w, h).Show()

  Hotkey cfg.cancelHK, (*) => Cancel_(bar, g), 'On'
  Hotkey 'RButton Up', (*) => Cancel_(bar, g), 'On'
  Hotkey 'LButton', (*) => ChangeSize(bar, g), 'On'
  HotKey 'Left', (*) => HotKeyMoveWinAndToolBar(g, bar, 1), 'On'
  HotKey 'Right', (*) => HotKeyMoveWinAndToolBar(g, bar, -1), 'On'
  HotKey 'Up', (*) => HotKeyMoveWinAndToolBar(g, bar, 2), 'On'
  HotKey 'Down', (*) => HotKeyMoveWinAndToolBar(g, bar, -2), 'On'
  Hotkey '^Left', (*) => TinyAdapter(g, bar, 1), 'On'
  Hotkey '^Right', (*) => TinyAdapter(g, bar, -1), 'On'
  Hotkey '^Up', (*) => TinyAdapter(g, bar, 2), 'On'
  Hotkey '^Down', (*) => TinyAdapter(g, bar, -2), 'On'
  Hotkey '+Left', (*) => TinyAdapter(g, bar, 1, true), 'On'
  Hotkey '+Right', (*) => TinyAdapter(g, bar, -1, true), 'On'
  Hotkey '+Up', (*) => TinyAdapter(g, bar, 2, true), 'On'
  Hotkey '+Down', (*) => TinyAdapter(g, bar, -2, true), 'On'
}

AutoSave(g) {
  if !cfg.autoSave
    return
  logger.Debug('自动保存截图')
  g.savePath := f := SaveToFileEx(g.Hwnd, cfg.historyPath)
  id := History.AddFile(f), HistoryGui.FlushCache(), g.id := id
}

ResetState() {
  StaticBG.Close(), Mask.Close(), Cursor.SetIcon(Cursor.Icon.arrow), Tip.ShowTip('')
  global isReady := true
}

Cancel(*) {
  HotKeysOff(cfg.cancelHK, 'RButton Up', 'LButton', '``')
  ResetState(), Tip.ShowTip('CANCEL')
}

Cancel_(bar, g, *) {
  HotKeysOff(cfg.cancelHK, 'RButton Up', 'LButton', 'Left', 'Right', 'Up', 'Down'
    , '^Left', '^Right', '^Up', '^Down'
    , '+Left', '+Right', '+Up', '+Down', '``')
  bar.Destroy(), g.Destroy(), ResetState(), Tip.ShowTip('CANCEL')
}

Bar_OkCB(bar, g) {
  logger.Debug('微调截图，当前窗口：' WinGetTitle('A') || WinGetClass('A'))
  HotKeysOff(cfg.cancelHK, 'RButton Up', 'LButton', 'Left', 'Right', 'Up', 'Down'
    , '^Left', '^Right', '^Up', '^Down'
    , '+Left', '+Right', '+Up', '+Down')
  bar.Destroy(), AutoSave(g)
  StaticBG.Close(), Mask.Close(), Tip.ShowTip('')
  global isReady := true
}

ChangeSize(bar, g, *) {
  if IsOverGui(bar) {
    while GetKeyState('LButton', 'p')
      Sleep 50
    if IsOverGui(bar)
      Send '{LButton}'
    return
  }
  if !IsOverGui(g)
    return
  direction := OverWhere(g)
  switch direction {
    case 0: t := Cursor.Icon.sizeAll
    case 2, 19: t := Cursor.Icon.sizeNS
    case 9, 22: t := Cursor.Icon.sizeNESW
    case 26, 5: t := Cursor.Icon.sizeNWSE
    case 3, 7: t := Cursor.Icon.sizeWE
  }
  MoveWinAndToolBar(g, bar, t, direction)

  IsOverGui(guiObj) {
    guiObj.GetPos(&guiX, &guiY, &guiW, &guiH), MouseGetPos(&x, &y)
    return x > guiX && x < guiX + guiW && y > guiY && y < guiY + guiH
  }

  OverWhere(guiObj) {
    guiObj.GetPos(&guiX, &guiY, &guiW, &guiH), MouseGetPos(&x, &y)
    bT := (guiW > 60 && guiH > 60) ? 25 : 10, r := 0
    if x < guiX + bT                            ; left
      r += 3
    else if x > guiX + guiW - bT                ; right
      r += 7
    if y < guiY + bT                            ; up
      r += 2
    else if y > guiY + guiH - bT                ; bottom
      r += 19
    return r
  }
}

TinyAdapter(frame, bar, dire, reverse := false) {
  frame.GetPos(&wx, &wy, &ww, &wh)
  if dire = 1 && wx > 0                           ; left
    reverse ? frame.Move(, , ww - 1) : frame.Move(wx - 1, , ww + 1)
  else if dire = -1 && wx + ww < A_ScreenWidth    ; right
    reverse ? frame.Move(wx + 1, , ww - 1) : frame.Move(, , ww + 1)
  else if dire = 2 && wy > 0                      ; up
    reverse ? frame.Move(, , , wh - 1) : frame.Move(, wy - 1, , wh + 1)
  else if dire = -2 && wy + wh < A_ScreenHeight   ; down
    reverse ? frame.Move(, wy + 1, , wh - 1) : frame.Move(, , , wh + 1)
  frame.GetPos(&wx, &wy, &ww, &wh)
  bar.Adapt(wx, wy, ww, wh).Move()
  ToolTip ww 'X' wh, wx, wy
}

HotKeyMoveWinAndToolBar(frame, bar, dire) {
  frame.GetPos(&wx, &wy, &ww, &wh)
  if dire = 1 && wx > 0                           ; left
    frame.Move(wx - 1)
  else if dire = -1 && wx + ww < A_ScreenWidth    ; right
    frame.Move(wx + 1)
  else if dire = 2 && wy > 0                      ; up
    frame.Move(, wy - 1)
  else if dire = -2 && wy + wh < A_ScreenHeight   ; down
    frame.Move(, wy + 1)
  frame.GetPos(&wx, &wy, &ww, &wh)
  bar.Adapt(wx, wy, ww, wh).Move()
  if cfg.withTip
    ToolTip ww 'X' wh, wx, wy
}

MoveWinAndToolBar(frame, bar, cursorIcon, dire, *) {
  bar.Hide(), ToolTip(), MouseGetPos(&px, &py)
  frame.GetPos(&wx, &wy, &ww, &wh)
  dx := wx - px, dy := wy - py
  Cursor.SetIcon(cursorIcon), MouseGetPos(&lx, &ly)

  While GetKeyState("LButton", "P") {
    MouseGetPos(&nx, &ny)
    if lx = nx and ly = ny
      continue
    if dire = 0 {
      x := nx + dx <= 0 ? 0 : nx + dx
      x := ww + dx + nx >= A_ScreenWidth ? A_ScreenWidth - ww : x
      y := ny + dy <= 0 ? 0 : ny + dy
      y := wh + dy + ny >= A_ScreenHeight ? A_ScreenHeight - wh : y
      frame.Move(x, y)
    } else if dire = 3 {                            ; left
      frame.Move(nx + dx, , ww + px - nx)
    } else if dire = 7                              ; right
      frame.Move(, , ww + nx - px)
    else if dire = 2                                ; up
      frame.Move(, ny + dy, , wh + py - ny)
    else if dire = 19                               ; down
      frame.Move(, , , wh + ny - py)
    else if dire = 5                                ; ne
      frame.Move(nx + dx, ny + dy, ww + px - nx, wh + py - ny)
    else if dire = 26                               ; sw
      frame.Move(, , ww + nx - px, wh + ny - py)
    else if dire = 9                                ; nw
      frame.Move(, ny + dy, ww + nx - px, wh + py - ny)
    else if dire = 22                               ; se
      frame.Move(nx + dx, , ww + px - nx, wh + ny - py)
    lx := nx, ly := ny
  }
  Cursor.SetIcon(Cursor.Icon.arrow), frame.GetPos(&x, &y, &w, &h)
  wx := w < 0 ? x + w : x, wy := h < 0 ? y + h : y, ww := Abs(w), wh := Abs(h)
  if wx < 0
    ww += wx, wx := 0
  if wy < 0
    wh += wy, wy := 0
  if wx + ww > A_ScreenWidth
    ww := A_ScreenWidth - wx
  if wy + wh > A_ScreenHeight
    wh := A_ScreenHeight - wy
  frame.Move(wx, wy, ww, wh), bar.Adapt(wx, wy, ww, wh).Show()
  if cfg.withTip
    ToolTip ww 'X' wh, wx, wy
}

GetGui(withTip := true) {
  Hook._Exec(Events.BeforeClip)
  g := Gui('+AlwaysOnTop -Caption +ToolWindow +Border')
  if cfg.useRandomBgc
    cfg.frameBgc := GetRandomColor()
  g.BackColor := cfg.frameBgc
  MouseGetPos(&begin_x, &begin_y), g.Show('x' begin_x ' y' begin_y)
  if cfg.noBgc
    WinSetTransColor(cfg.frameBgc, g)
  else WinSetTransparent(cfg.frameTRP, g)
  last_x := 0, last_y := 0
  while GetKeyState('LButton', 'P') {
    MouseGetPos &end_x, &end_y
    x := End_x < Begin_x ? End_x : Begin_x, y := End_y < Begin_y ? End_y : Begin_y
    scope_x := Abs(begin_x - end_x), scope_y := Abs(begin_y - end_y)
    if withTip && (last_x != end_x || last_y != end_y)
      ToolTip(scope_x 'X' scope_y, x, y - 20, 1), ToolTip('(' end_x ',' end_y ')', end_x, end_y + 20, 2)
    last_x := end_x, last_y := end_y
    g.Move(x, y, scope_x, scope_y)
  }
  Hook._Exec(Events.AfterClip)
  ToolTip(), ToolTip(, , , 2)
  g.GetPos(&x, &y, &w, &h)
  f := FrameGui(), f.DrawFrame(x, y, w, h)
  g.Destroy()
  return f

  GetRandomColor() => ('0x' Floor(Random(0, 16777216)).toBase(16)).padEnd(8, '0')
}