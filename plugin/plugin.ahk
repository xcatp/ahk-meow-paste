#Include g:\AHK\git-ahk-lib\util\generic\Map.ahk

class Plugin {

  static plugins := GenericMap(Integer, Plugin)

  static Load(targets*) {
    for target in targets {
      if not target is Plugin {
        throw TypeError('expect a plugin subclass object')
      } else {
        ptr := ObjPtr(target)
        if !this.plugins.Has(ptr) {
          this.plugins.Set(ptr, target)
        }
      }
    }
    return this
  }

  static Exec() {
    for k, v in this.plugins {
      v.Run()
    }
  }

  static GetLen() => this.plugins.Length

  Run(*) {
    /* default run method */
  }
}