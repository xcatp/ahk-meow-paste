class MyToolBar {
  ; 我在考虑是否也使用 Gdi 重构它？

  static btnW := 60, btnH := 30

  __New(nameList, x, y, cbs) {
    this.btnCount := nameList.Length
    this.posX := x, this.posY := y
    btnList := []
    for i, v in nameList
      btnList.Push(MyToolBar.MyButton(v, MyToolBar.btnW, MyToolBar.btnH, cbs[i]))
    this.btnList := btnList
  }

  static SetWH(w, h) => (MyToolBar.btnW := w, MyToolBar.btnH := h)

  GetPos(&x, &y, &w, &h) {
    x := this.posX, y := this.posY
    w := this.btnCount * MyToolBar.btnW
    h := MyToolBar.btnH
  }

  Adapt(wx, wy, ww, wh) {
    y := wy + wh >= (A_ScreenHeight - MyToolBar.btnH) ? wy - MyToolBar.btnH : wy + wh
    y := wh >= (A_ScreenHeight - MyToolBar.btnH) ? wy + wh - 1.5 * MyToolBar.btnH : y
    x := ((wx + ww) < MyToolBar.btnW * this.btnCount) ? 0 : wx + ww - MyToolBar.btnW * this.btnCount
    this.posX := x, this.posY := y
    return this
  }

  Show(x := unset, y := unset) {
    IsSet(x) && this.posX := x
    IsSet(y) && this.posY := y
    for v in this.btnList
      v.Show(Format('x{} y{} w{} h{}'
        , this.posX + (A_Index - 1) * MyToolBar.btnW
        , this.posY
        , MyToolBar.btnW
        , MyToolBar.btnH))
  }

  Modefiy(index, v) => this.btnList[index].Text := v
  Hide() => this.btnList.foreach(v => v.Hide())

  Move(x := unset, y := unset) {
    IsSet(x) && this.posX := x
    IsSet(y) && this.posY := y
    loop this.btnCount
      this.btnList[A_Index].Move(this.posX + MyToolBar.btnW * (A_Index - 1), this.posY)
    return this
  }

  Destroy() {
    loop this.btnCount
      this.btnList[A_Index].Destroy()
  }

  Class MyButton extends Gui {

    text {
      get => this.btn.Text
      set => this.btn.Text := Value
    }

    __New(value, w, h, cb) {
      super.__New('+AlwaysOnTop -Caption +ToolWindow')
      this.SetFont('s14')
      btn := this.AddButton('xs w' w ' h' h, value)
      btn.OnEvent('Click', (*) => cb(btn))
      this.btn := btn
    }
  }
}


if A_LineFile == A_ScriptFullPath {

  CB1(btn) {
    MsgBox A_ThisFunc '/' btn.Text
  }
  CB2(btn) {
    MsgBox A_ThisFunc '/' btn.Text
  }
  MyToolBar.SetWH(70, 60)
  t := MyToolBar(['Ok', 'Cancel'], 960, 700, [CB1, CB2])
  t.Show()
  t.Move(0, 0)
  ; t.Destroy()
}