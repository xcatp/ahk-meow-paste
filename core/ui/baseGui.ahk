#Include inputBox.ahk
#Include ../zoom.ahk
#Include ../hook.ahk

class BaseGui extends Gui {

  data := {
    sizeW: 0,
    sizeH: 0,
    border: 0,
    hasTimestamp: false,
    zoomLevel: 0,
    createTime: ''
  }

  SizeW(v := unset) => IsSet(v) ? (this.data.sizeW := v, this) : this.data.sizeW
  SizeH(v := unset) => IsSet(v) ? (this.data.sizeH := v, this) : this.data.sizeH
  Border(v := unset) => IsSet(v) ? (this.data.border := v, this) : this.data.border
  HasTimestamp(v := unset) => IsSet(v) ? (this.data.hasTimestamp := v, this) : this.data.hasTimestamp
  ZoomLevel(v := unset) => IsSet(v) ? (this.data.zoomLevel := v, this) : this.data.zoomLevel
  CreateTime(v := unset) => IsSet(v) ? (this.data.createTime := v, this) : this.data.createTime

  __New(opt := '') {
    super.__New('+AlwaysOnTop +ToolWindow -Caption ' opt)
    this.ZoomLevel(StretchRatio.normal).CreateTime(FormatTime(, 'yyyyMMddHHmmss'))
  }

  OnDestroy(*) => this.Destroy()
  Zoom(*) => Noop()

  RegisterEvent() {
    this.GetPos(&x, &y, &w, &h)
    this.SizeW(w).SizeH(h).OnEvent('ContextMenu', _onCM)
    text := this.AddText('xs x0 y0 w' w ' h' h)
    text.OnEvent('Click', (*) => this.MoveWin())
    text.OnEvent('DoubleClick', (*) => this.OnDestroy())
    this.eProxy := text
  }

  MoveWin(*) {
    MouseGetPos(&px, &py), WinGetPos(&wx, &wy, , , 'A')
    this.GetPos(&wx, &wy)
    dx := wx - px, dy := wy - py
    While GetKeyState("LButton", "P") {
      MouseGetPos(&nx, &ny)
      this.Move(nx + dx, ny + dy)
    }
  }
}

_onCM(obj, ctrlObj, item, isR, x, y) {
  m := Menu()
  m.Add '关闭', (*) => obj.OnDestroy()
  m.Add '关闭其他', (*) => ClearAll([obj])
  m.Add
  sm := Menu()
  sm.Add '时间戳', (*) => AddTimestamp(obj, x, y)
  sm.Add '水平翻转', (*) => Flip(obj)
  sm.Add '垂直翻转', (*) => Flip(obj, true)
  m.Add '操作', sm
  m.Add
  m.Add '存入剪贴板', (*) => SaveToClipBoard(obj.Hwnd)
  m.Add '图像另存为...', (*) => SaveToFileEx(obj.Hwnd)
  m.Add
  m.Add '销毁', (*) => DestroyGui(obj)
  m.Add
  m.Add '关闭并存入剪贴板', (*) => SaveToClipBoard(obj.Hwnd, true)
  m.Add '关闭并保存到默认组', (*) => SaveToFileEx(obj.Hwnd, cfg.defaultSavePath, , true)
  m.Add
  sm := Menu()
  Extend(sm, obj.Hwnd)
  sm.Add
  sm.Add '新建分组', (*) => CreateGroup(obj.Hwnd)
  m.Add '存入组', sm
  sm := Menu()
  sm.Add '缩放: ' obj.ZoomLevel(), noop
  sm.Add FormatTime(obj.CreateTime(), 'yyyy/MM/dd_HH:mm:ss'), noop
  m.Add
  m.Add obj.SizeW() ' x ' obj.SizeH(), sm
  m.Show()
}

AddTimestamp(g, x, y) {
  if g.HasTimestamp()
    return
  Hook._Exec(Events.OnTimestampGenerate, [g, x, y])
  g.HasTimestamp(true)
}

Flip(g, vertical := false) {
  ; 不会修改内存DC，所以在缩放时会恢复
  ; 如果要同步修改，参考 timestampGenerator.ahk
  g.GetPos(, , &w, &h), hdc := DllCall('GetDC', 'ptr', g.Hwnd)
  DllCall("StretchBlt"
    , 'ptr', hdc, 'int', 0, 'int', 0, 'int', w, 'int', h
    , 'ptr', hdc, 'int', vertical ? 0 : w, 'int', vertical ? h : 0
    , 'int', vertical ? w : -w, 'int', vertical ? -h : h
    , 'UInt', 0xCC0020)
  DllCall('ReleaseDC', 'int', 0, 'ptr', hdc)
}

DestroyGui(g) {
  g.OnDestroy()
  if !g.HasProp('savePath')
    return
  path := g.savePath
  if FileExist(path) {
    if mcf.Get('recycle', 0) {
      FileRecycle(path)
      Tip.ShowTip('已回收本地文件喵~')
    } else {
      FileDelete(path)
      Tip.ShowTip('已删除本地文件喵~')
    }
    if g.HasProp('id')
      History.DelFile(g.id)
    HistoryGui.FlushCache()
    logger.Info('销毁文件：' path)
  } else {
    Tip.ShowTip('没有找到对应文件喵...')
    logger.Warn('尝试删除不存在的文件')
  }
}

Extend(sm, pass) {
  menuList := [mcf.Get('default', 'default'), cfg.groupsList*]
  for v in menuList
    sm.Add v, (itemName, itemPos, myMenu) => SaveToGroup(itemName, pass)
  defaultMenu := mcf.Get('default', 'default')
  defaultMenuName := SubStr(defaultMenu, InStr(defaultMenu, '\', , -1) + 1)
  sm.Check(defaultMenuName)
}

CreateGroup(pass) {
  ib := MyInputBox('输入组名:', '新建组', pass)
  if ib.Result = 'Ok' {
    DirCreate(cfg.groupRoot '\' ib.Value)
    groups := cfg.groupsList
    groups.Push(ib.Value)
    _ := MeowConfEx.Empty('./my.txt')
    _.Set('names', groups)
    _.Sync()
    if ib.checked {
      path := cfg.groupRoot '\' ib.value
      SaveToFileEx(pass, path)
      Tip.ShowTip('创建并保存了喵~')
    } else
      Tip.ShowTip('创建成功喵~')
    logger.Info('创建组：' ib.value)
  }
}

SaveToGroup(groupName, hwnd) {
  path := cfg.groupRoot '\' groupName
  SaveToFileEx(hwnd, path)
  logger.Info('已保存到分组：' groupName)
}