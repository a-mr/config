import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.SetWMName

--main = xmonad gnomeConfig


--main = xmonad $ defaultConfig
main = xmonad $ gnomeConfig
    { borderWidth        = 4
    , terminal           = "urxvt"
    , normalBorderColor  = "#3388cc"
    , focusedBorderColor = "#ff8833" 
    , startupHook = setWMName "LG3D"
    }
