#Include Extend.ahk

GetMonitorCount() => MDMF_Enum().Count

GetMonitorInfo(MonitorNum) {
	for k, v in MDMF_Enum().OwnProps()
		if (v.Num = MonitorNum)
			return v
}

GetPrimaryMonitor() {
	for k, v in MDMF_Enum().OwnProps()
		if (v.Primary)
			return v.Num
}

MDMF_Enum(HMON := '') {
	static EnumProcAddr := CallbackCreate(MDMF_EnumProc), Monitors := {}
	Monitors.TotalCount := 0
	if !HMON {
		if !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProcAddr, "Ptr", ObjPtr(Monitors))
			return false
		else return Monitors
	} else return Monitors.HasProp('HMON') ? Monitors.HMON : false
}

MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
	Monitors := ObjFromPtrAddRef(ObjectAddr), Monitors.HMON := MDMF_GetInfo(HMON)
	Monitors.TotalCount++
	if Monitors.HMON.Primary
		Monitors.Primary := HMON
	Return true
}

MDMF_FromHWND(HWND, Flag := 0) => DllCall("User32.dll\MonitorFromWindow", "Ptr", HWND, "UInt", Flag, "Ptr")

MDMF_FromPoint(X := "", Y := "") {
	PT := Buffer(8, 0)
	if X = "" || Y = "" {
		DllCall("User32.dll\GetCursorPos", "Ptr", PT)
		if X = ""
			X := NumGet(PT, 0, "Int")
		if Y = ""
			Y := NumGet(PT, 4, "Int")
	}
	return DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", 0)
}

MDMF_FromRect(X, Y, W, H) {
	RC := Buffer(16, 0)
	NumPut("Int", X, RC, 0)
	NumPut('Int', Y, RC, 4)
	NumPut("Int", X + W, RC, 8)
	NumPut("Int", Y + H, RC, 12)
	Return DllCall("User32.dll\MonitorFromRect", "Ptr", RC, "UInt", 0)
}

MDMF_GetInfo(HMON) {
	MIEX := Buffer(40 + (32 << 1))
	NumPut("UInt", MIEX.Size, MIEX, 0)
	If DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX)
		Return { Name: (Name := StrGet(MIEX.Ptr + 40, 32))  ; CCHDEVICENAME = 32
			, Num: RegExReplace(Name, ".*(\d+)$", "$1")
			, Left: NumGet(MIEX, 4, "Int")    ; display rectangle
			, Top: NumGet(MIEX, 8, "Int")    ; "
			, Right: NumGet(MIEX, 12, "Int")   ; "
			, Bottom: NumGet(MIEX, 16, "Int")   ; "
			, WALeft: NumGet(MIEX, 20, "Int")   ; work area
			, WATop: NumGet(MIEX, 24, "Int")   ; "
			, WARight: NumGet(MIEX, 28, "Int")   ; "
			, WABottom: NumGet(MIEX, 32, "Int")   ; "
			, Primary: NumGet(MIEX, 36, "UInt") } ; contains a non-zero value for the primary monitor.
	Return false
}