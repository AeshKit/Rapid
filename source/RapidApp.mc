import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;

public var languageString;

public class RapidApp extends Application.AppBase {

    var mainView;
    var mainDelegate;
    var swipeHandler;

    var sView;
    var sDelegate;

    function initialize() {

        if(Toybox.Application has :Storage) {
            Storage.setValue("firstStart", true);

            if(Storage.getValue("firstStart") || Storage.getValue("firstStart") == null) {
                runSystemChecks();
            }

            if(!Storage.getValue("legacyView")) {
                sView = new RapidView();
                sDelegate = new RapidDelegate(sView);
            } else {
                sView = new RapidLegacyView();
                sDelegate = new RapidLegacyDelegate(sView);
            }
        } else {
            Globals.hasStorage = false;
            sView = new RapidLegacyView();
            sDelegate = new RapidLegacyDelegate(sView);
        }
        
        AppBase.initialize();
    }

    function runSystemChecks() {
        if(System.getDeviceSettings() has :requiresBurnInProtection) {
            Storage.setValue("backlight", !System.getDeviceSettings().requiresBurnInProtection);
        } else {
            Storage.setValue("backlight", Attention has :backlight);
        }

        Storage.setValue("progressRing", Graphics.Dc has :drawArc);

        Storage.setValue("firstStart", false);
        Storage.setValue(
            "legacyView",
            !(Graphics.Dc has :drawAngledText)
        );
        
        Storage.setValue(
            "haptics",
            Attention has :vibrate
        );

        Storage.setValue(
            "legacyMenu",
            true
            // !(Graphics.Dc has :drawAngledText)
            // [ Menu2 has stability issues for some reason. ]
        );

        Storage.setValue(
            "scalingTimeOut",
            Graphics.Dc has :drawAngledText
        );
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ sView, sDelegate ];
    }
}

function getApp() as RapidApp {
    return Application.getApp() as RapidApp;
}