#Include ..\_lib\ColorExtractor.ahk
#Include Helper.ahk

class Setting extends Gui {

  __New() {
    super.__New('+AlwaysOnTop')
    this.SetFont('s13', 'Microsoft YaHei UI')
    tab := this.AddTab3('w300', ["截图框", '遮罩', "贴图", "其他"])
    tab.UseTab(1)
    noBgc := this.AddCheckbox('va Section', '使用透明色'), noBgc.Value := cfg.noBgc

    this.AddText('xs', '截图背景色:')
    e1 := this.AddEdit('yp w60 Background' cfg.frameBgc), frameBgc := this.AddButton('vh yp h30', cfg.frameBgc)
    frameBgc.OnEvent('Click', (c, *) => (!cfg.noBgc && (this._getColor(c, e1), cfg.frameBgc := c.Text)))

    this.AddText('xs', '背景透明度:'), frameTRP := this.AddEdit('vi yp w60 ' (cfg.noBgc && 'cred'), cfg.frameTRP)
    this.AddButton('yp h30', '预览').OnEvent('Click', (*) => this.ShowExample(frameBgc.Text, frameTRP.Value, '截图UI'))

    noBgc.OnEvent('Click', (c, *) => (this.ToggleState(c.Value, frameTRP), cfg.noBgc := !cfg.noBgc))
    ; ========
    tab.UseTab(2)
    showMask := this.AddCheckbox('vb Section', '显示遮罩'), showMask.Value := cfg.showMask
    maskIST := this.AddCheckbox('vc yp', '立即显示'), maskIST.Value := cfg.showMaskIST

    this.AddText('xs', '遮罩背景色:')
    e2 := this.AddEdit('yp w60 Background' cfg.maskBgc), maskBgc := this.AddButton('vj yp h30', cfg.maskBgc)
    maskBgc.OnEvent('Click', (c, *) => (cfg.showMask && (this._getColor(c, e2), cfg.maskBgc := c.Text)))

    this.AddText('xs', '遮罩透明度:')
    maskTRP := this.AddEdit('vk yp w60 ' (!cfg.showMask && 'cred'), cfg.maskTRP)
    this.AddButton('yp h30', '预览').OnEvent('Click', (*) => this.ShowExample(maskBgc.Text, maskTRP.Value, '遮罩UI'))

    showMask.OnEvent('Click', (c, *) => (this.ToggleState(!c.Value, maskTRP), cfg.showMask := !cfg.showMask))
    maskIST.OnEvent('Click', (c, *) => cfg.showMaskIST := c.Value)
    ; ========
    tab.UseTab(3)
    pastIST := this.AddCheckbox('vd', '立即贴图')
    pastIST.Value := cfg.pasteInstantly
    pastIST.OnEvent('Click', (c, *) => cfg.pasteInstantly := c.Value)
    autoSave := this.AddCheckbox('ve', '贴图后保存为历史')
    autoSave.Value := cfg.autoSave
    autoSave.OnEvent('Click', (c, *) => cfg.autoSave := c.Value)
    ; ========
    tab.UseTab(4)
    tip := this.AddCheckbox('vf', '截图时显示更多信息')
    this.AddButton('h30', '帮助').OnEvent('Click', (*) => Helper.Show())
    tip.Value := cfg.withTip
    tip.OnEvent('Click', (c, *) => cfg.withTip := c.Value)
    ; ========
    this.OnEvent('Close', (*) => this.OnClose())
    this.state := this.GetSnap()
  }

  _getColor(ctl1, ctl2) {
    if !r := ColorExtractor('0x' ctl1.Text, this.Hwnd)
      return
    rgb := r.RGB.substring(3)
    ctl2.Opt('Background' rgb)
    ctl1.Text := rgb
  }


  ShowExample(color, trans, title) {
    g := Gui('+AlwaysOnTop +ToolWindow -Caption +Border')
    g.BackColor := color, g.SetFont('s14')
    WinSetTransparent(trans, g)
    t := g.AddText('xs c33ff00 w200 h200', '双击关闭 ' title)
    t.OnEvent('DoubleClick', (*) => g.Destroy())
    t.OnEvent('Click', (*) => PostMessage(0xA1, 2))
    g.Show(Format('x{} w200 h200', A_ScreenWidth / 2 + 300))
  }

  ToggleState(flag, ctrl) => flag ? ctrl.Opt('+ReadOnly cRed') : ctrl.Opt('-ReadOnly cBlack')

  GetSnap() {
    s := 0, t := ''
    for v in 'abcdef'
      s <<= 1, s |= this[v].Value
    for v in 'hijk'
      t .= this[v].Text
    return s . t
  }

  OnClose() {
    cfg.frameTRP := this['i'].Value, cfg.maskTRP := this['k'].Value
    if this.state != this.GetSnap()
      cfg.Sync()
  }

}