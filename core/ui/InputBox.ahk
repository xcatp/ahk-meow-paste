class MyInputBox extends Gui {

  __New(prompt, title, owner := unset, showOpt := '', placeHolder := '') {
    super.__New('+AlwaysOnTop -MinimizeBox -MaximizeBox', title)
    this.Opt(IsSet(owner) ? '+Owner' owner : '')
    this.SetFont('s12')
    this.AddText(, prompt)
    this.AddEdit('vInputBox', placeHolder).GetPos(, , &w)
    this.AddCheckbox('Section vCheck', '立刻保存')
    this.AddButton('xm w80 vConfirm', 'Ok').OnEvent('Click', (*) => this.SetResult())
    this['Confirm'].GetPos(&xb, , &bw)
    this.AddButton('yp w80 x+' (w - bw * 2), 'Cancel').OnEvent('Click', (*) => this.Exit())
    this.Show(showOpt)
    this.OnEvent('Close', (*) => this.Exit())
    this.result := ''
    while this.result = ''
      Sleep(100)
  }

  SetResult() {
    this.value := this['InputBox'].value
    this.checked := this['Check'].value
    if this.value != '' {
      this.result := 'Ok'
      this.Destroy()
    }
  }

  Exit() {
    this.result := 'Cancel'
    this.Destroy()
  }
}

if A_LineFile == A_ScriptFullPath {
  g := Gui('+AlwaysOnTop')
  g.Show('w500 h500')
  g.Opt('+Disabled') ; 可以禁止操作
  ib := MyInputBox('test', 'title', g.Hwnd)
  g.Opt('-Disabled')
  if ib.result = 'ok'
    MsgBox ib.value '/' ib.checked
}