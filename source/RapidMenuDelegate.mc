import Toybox.Lang;
import Toybox.System;

using Toybox.Application.Storage as Disk;
using Toybox.WatchUi as Ui;

import Rez.Strings;
import Constants;

class RapidMenuDelegate extends Ui.Menu2InputDelegate {

    var checkboxMenu as Boolean = false;

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onMenu() {
        var menu = new Ui.CheckboxMenu({:title=>loadResource(Strings.settings)});
        if(Disk.getValue("haptics") == null) {
            Disk.setValue("haptics", Attention has :vibrate);
        }
        if(Disk.getValue("progress_ring" == null)) {
            Disk.setValue("progress_ring", Graphics.Dc has :drawArc);
        }
        if(Disk.getValue("backlight") == null) {
            Disk.setValue("backlight", false);
        }
        if(Disk.getValue("legacyMenu" == null)) {
            Disk.setValue("legacyMenu", false);
        }
        if(Disk.getValue("legacyView" == null)) {
            Disk.setValue("legacyView", Graphics.Dc has :drawAngledText);
        }
        if(Disk.getValue("scalingTimeOut") == null) {
            Disk.setValue("scalingTimeOut", Graphics.Dc has :drawAngledText);
        }
        menu.addItem(
            new CheckboxMenuItem(
                loadResource(Strings.haptics_string),
                "",
                :hp,
                Disk.getValue("haptics"),
                {}
            )
        );
        menu.addItem(
            new CheckboxMenuItem(
                loadResource(Strings.progress_ring),
                "",
                :pr,
                Disk.getValue("progressRing"),
                {}
            )
        );
        menu.addItem(
            new CheckboxMenuItem(
                loadResource(Strings.toggle_backlight),
                loadResource(Strings.uses_battery),
                :bk,
                Disk.getValue("backlight"),
                {}
            )
        );
        menu.addItem(
            new CheckboxMenuItem(
                loadResource(Strings.scaling_time_out),
                "",
                :to,
                Disk.getValue("scalingTimeOut"),
                {}
            )
        );
        menu.addItem(
            new CheckboxMenuItem(
                loadResource(Strings.use_menu1),
                loadResource(Strings.legacy_menu),
                :mn,
                Disk.getValue("legacyMenu"),
                {}
            )
        );
        menu.addItem(
            new CheckboxMenuItem(
                loadResource(Strings.use_legacy_view),
                "",
                :cv,
                Disk.getValue("legacyView"),
                {}
            )
        );
        checkboxMenu = true;
        Ui.pushView(menu, new $.RapidMenuDelegate(), Ui.SLIDE_IMMEDIATE);
        // Yes, it calls the same delegate that we're using right now. I am lazy
        return true;
    }

    function onSelect(item as Ui.MenuItem) as Void {
        switch(item.getId()) {
            case :sm:
                onMenu();
                return;
            case :wt:
                Globals.changingTimeHoldingVar = Globals.whiteTimeLeft;
                Globals.changingSideWithButton = 'w';
                Globals.isWhitesTurn = true;
                break;
            case :bt:
                Globals.changingTimeHoldingVar = Globals.blackTimeLeft;
                Globals.changingSideWithButton = 'b';
                Globals.isWhitesTurn = false;
                break;
            case :wi:
                Globals.changingIncrementWithButton = true;
                Globals.incrementHoldingVar = Globals.whiteIncrement;
                Globals.isWhitesTurn = true;
                break;
            case :bi:
                Globals.incrementHoldingVar = Globals.blackIncrement;
                Globals.changingIncrementWithButton = true;
                Globals.isWhitesTurn = false;
                break;
            case :st:
                Globals.changingStartingTimeWithButton = true;
                Globals.startingTimeHoldingVar = Globals.whiteTimeLeft - (Globals.whiteIncrement * 1000);
                break;
            case :si:
                Globals.changingIncrementWithButton = true;
                Globals.incrementHoldingVar = Globals.whiteIncrement;
                break;
            case :hp:
                Disk.setValue("haptics", !Disk.getValue("haptics"));
                Globals.settingChanged = true;
                return;
            case :to:
                Disk.setValue("scalingTimeOut", !Disk.getValue("scalingTimeOut"));
                Globals.settingChanged = true;
                break;
            case :bk:
                Disk.setValue("backlight", !Disk.getValue("backlight"));
                Globals.settingChanged = true;
                return;
            case :pr:
                Disk.setValue("progressRing", !Disk.getValue("progressRing"));
                Globals.settingChanged = true;
                return;
            case :cv:
                Disk.setValue("legacyView", !Disk.getValue("legacyView"));
                Globals.settingChanged = true;
                break;
            case :mn:
                Disk.setValue("legacyMenu", !Disk.getValue("legacyMenu"));
                Globals.settingChanged = true;
                break;
            case :ex:
                System.exit();
        }
        if(!checkboxMenu) {
            onBack();
        }
        return;
    }
}