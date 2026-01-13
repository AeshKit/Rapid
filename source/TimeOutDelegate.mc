import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.Attention;

import Globals;

using Toybox.WatchUi as Ui;

class TimeOutDelegate extends Ui.BehaviorDelegate {

    var view;

    function initialize(timeoutView) {
        Ui.BehaviorDelegate.initialize();
        view = timeoutView;
    }

    function onMenu() as Boolean {
        return view;
    }

    function onTap(clickEvent) as Boolean {
        return(handleInteraction());
    }

    function onKey(keyEvent as Ui.KeyEvent) as Boolean {
        return(handleInteraction());
    }

    function handleInteraction() as Boolean {
        if(Globals.animationCounter <= 9) {
            return true;
        }
        
        resetVariables();

        if(Graphics.Dc has :drawAngledText) {
            Ui.switchToView(new $.RapidView(), new $.RapidDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
            return true;
        }

        Ui.switchToView(new $.RapidLegacyView(), new $.RapidLegacyDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
        return true;
    }

    private function resetVariables() {
        Globals.isWhitesTurn = true;
        Globals.hasGameBeenStopped = false;
        Globals.animationCounter = 0;
        Globals.turns = 0;
    }

}