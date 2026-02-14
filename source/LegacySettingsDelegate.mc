import Toybox.System;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Disk;

import Rez.Strings;
import Globals;
import Constants;

class LegacySettingsDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item as $.Toybox.Lang.Symbol) as Void {
        switch(item) {
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
                if(Globals.hasStorage) {
                    Disk.setValue("haptics", !Disk.getValue("haptics"));
                } else {
                    Globals.haptics = !Globals.haptics;
                }
                Globals.settingChanged = true;
                return;
            case :bk:
                if(Globals.hasStorage) {
                    Disk.setValue("backlight", !Disk.getValue("backlight"));
                } else {
                    Globals.backLightOn = !Globals.backLightOn;
                }
                Globals.settingChanged = true;
                return;
            case :pr:
                if(Globals.hasStorage) {
                    Disk.setValue("progressRing", !Disk.getValue("progressRing"));
                } else {
                    Globals.drawProgressRing = !Globals.drawProgressRing;
                }
                Globals.settingChanged = true;
                return;
            case :cv:
                if(Globals.hasStorage) {
                    Disk.setValue("legacyView", !Disk.getValue("legacyView"));
                } else {
                    Globals.useLegacyView = !Globals.useLegacyView;
                }
                Globals.settingChanged = true;
                break;
            case :to:
                if(Globals.hasStorage) {
                    Disk.setValue("scalingTimeOut", !Disk.getValue("scalingTimeOut"));
                } else {
                    Globals.useScalingTimeOut = !Globals.useScalingTimeOut;
                }
                Globals.settingChanged = true;
                break;
            case :mn:
                if(Globals.hasStorage) {
                    Disk.setValue("legacyMenu", !Disk.getValue("legacyMenu"));
                } else {
                    Globals.drawModernMenu = !Globals.drawModernMenu;
                }
                Globals.settingChanged = true;
                break;
            case :ex:
                System.exit();
        }
        return;
    }

    function onMenu() {
        var menu = new Ui.CheckboxMenu({:title=>loadResource(Strings.settings)});
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
        Ui.pushView(menu, new $.RapidMenuDelegate(), Ui.SLIDE_IMMEDIATE);
        // Yes, it calls the same delegate that we're using right now. I am lazy
        return true;
    }
}