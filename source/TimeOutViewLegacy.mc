import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Math;

import Globals;
import Constants;
import Rez.Strings;

using Toybox.WatchUi as Ui;

class TimeOutViewLegacy extends Ui.View {

    var animationTimer;
    var textGlideCounter as Number = 1;

    var turnsText,
        timeLeftText,
        timeTotalText;
    var turnsWidthOffset,
        timeLeftWidthOffset,
        timeTotalWidthOffset;

    var mainColor as Integer,
        secondaryColor as Integer,
        greyColor as Integer;

    var mainLoseString as String,
        totalMinutes as String,
        totalSeconds as String,
        totalMilliseconds as String,
        minutesLeft as String,
        secondsLeft as String,
        millisecondsLeft as String;

    var holdingArray as Array;

    var winningSideTimeLeft as Integer;

    var mainFont as FontType,
        secondaryFont as FontType;

    var centerX,
        centerY;

    function initialize() {
        if(Globals.whiteLost) {
            mainColor = Graphics.COLOR_WHITE;
            secondaryColor = Graphics.COLOR_BLACK;
            greyColor = Graphics.COLOR_DK_GRAY;

            mainLoseString = loadResource(Strings.white_time_out);

            winningSideTimeLeft = Globals.blackTimeLeft;
        } else {
            mainColor = Graphics.COLOR_BLACK;
            secondaryColor = Graphics.COLOR_WHITE;
            greyColor = Graphics.COLOR_LT_GRAY;

            mainLoseString = loadResource(Strings.black_time_out);

            winningSideTimeLeft = Globals.whiteTimeLeft;
        }

        mainFont = Graphics.FONT_LARGE;
        secondaryFont = Graphics.FONT_TINY;

        minutesLeft      = (winningSideTimeLeft / 60000).toString();
        secondsLeft      = ((winningSideTimeLeft / 1000) % 60).toString();
        millisecondsLeft = (winningSideTimeLeft % 1000).toString();

        totalMinutes      = (Globals.totalTime / 60000).toString();
        totalSeconds      = ((Globals.totalTime / 1000) % 60).toString();
        totalMilliseconds = (Globals.totalTime % 1000).toString();


        // dunno what i was on when i wrote this. it's prolly slow as hell but whatever
        holdingArray      = standardizeTime(totalMinutes, totalSeconds, totalMilliseconds);
        totalMinutes      = holdingArray[0];
        totalSeconds      = holdingArray[1];
        totalMilliseconds = holdingArray[2];

        holdingArray      = standardizeTime(minutesLeft, secondsLeft, millisecondsLeft);
        minutesLeft       = holdingArray[0];
        secondsLeft       = holdingArray[1];
        millisecondsLeft  = holdingArray[2];

        turnsText = loadResource(Strings.turns) + Globals.turns;
        timeTotalText = loadResource(Strings.total_time) + totalMinutes + ":" + totalSeconds + loadResource(Strings.decimal_separator) + totalMilliseconds;
        timeLeftText = Globals.whiteLost ? loadResource(Strings.black_time) : loadResource(Strings.white_time);
        timeLeftText += minutesLeft + ":" + secondsLeft + loadResource(Strings.decimal_separator) + millisecondsLeft;

        Globals.animationCounter = 0;

        switch(System.getDeviceSettings().partNumber) {
            case Constants.fr630PartNumber:
            case Constants.approachs50PartNumber:
                secondaryFont = Graphics.FONT_MEDIUM;
                break;
            case Constants.d2airPartNumber:
            case Constants.d2airx10PartNumber:
            case Constants.fr745PartNumber:
            case Constants.fr935PartNumber:
            case Constants.fenixchronosPartNumber:
            case Constants.approachs62PartNumber:
            case Constants.d2bravoPartNumber:
            case Constants.d2bravo_titPartNumber:
            case Constants.vivoactive4PartNumber:
                secondaryFont = Graphics.FONT_SMALL;
                break;
            case Constants.fr255PartNumber:
            case Constants.fr255mPartNumber:
            case Constants.fr255sPartNumber:
            case Constants.fr255smPartNumber:
            case Constants.fr945PartNumber:
            case Constants.fr945ltePartNumber:
            case Constants.captainmarvelPartNumber:
            case Constants.darthvaderPartNumber:
            case Constants.firstavengerPartNumber:
            case Constants.d2charliePartNumber:
            case Constants.enduroPartNumber:
            case Constants.d2deltaPartNumber:
            case Constants.d2deltapxPartNumber:
            case Constants.d2deltasPartNumber:
            case Constants.descentg2PartNumber:
            case Constants.descentmk1PartNumber:
            case Constants.descentmk2PartNumber:
            case Constants.descentmk2sPartNumber:
            case Constants.fenix3PartNumber:
            case Constants.fenix3hrPartNumber:
            case Constants.fenix5PartNumber:
            case Constants.fenix5plusPartNumber:
            case Constants.fenix5sPartNumber:
            case Constants.fenix5splusPartNumber:
            case Constants.fenix5xPartNumber:
            case Constants.fenix5xplusPartNumber:
            case Constants.fenix6PartNumber:
            case Constants.fenix6proPartNumber:
            case Constants.fenix6sPartNumber:
            case Constants.fenix6sproPartNumber:
            case Constants.fenix6xproPartNumber:
            case Constants.venuPartNumber:
            case Constants.venu2PartNumber:
            case Constants.venu2plusPartNumber:
            case Constants.venu2sPartNumber:
            case Constants.venudPartNumber:
            case Constants.vivoactive4sPartNumber:
            case Constants.vivoactive5PartNumber:
                secondaryFont = Graphics.FONT_TINY;
                break;
            case Constants.approachs60PartNumber:
                secondaryFont = Graphics.FONT_XTINY;
                break;
        }
        if(System.getDeviceSettings() has :systemLanguage && System.getDeviceSettings().systemLanguage == System.LANGUAGE_SPA) {
            secondaryFont = Graphics.FONT_XTINY;
        }
        
        View.initialize();
    }

    function onUpdate(dc as $.Toybox.Graphics.Dc) as Void {
        switch(Globals.animationCounter) {
            case 0:
                dc.setColor(mainColor, secondaryColor);
                dc.clear();
                startAnimationTimer(100, 1, true);
                break;
            case 1:
                dc.setColor(secondaryColor, mainColor);
                dc.clear();
                startAnimationTimer(100, 1, true);
                break;
            case 2:
                dc.setColor(mainColor, secondaryColor);
                dc.clear();
                startAnimationTimer(100, 1, true);
                break;
            case 3:
                dc.setColor(secondaryColor, mainColor);
                dc.clear();
                dc.drawText(
                    centerX + (dc.getTextWidthInPixels(mainLoseString, mainFont) / 2),
                    centerY,
                    mainFont,
                    mainLoseString,
                    Graphics.TEXT_JUSTIFY_VCENTER
                );
                startAnimationTimer(1000, 1, true);
                break;
            case 4:
                // dc.setColor(secondaryColor, mainColor); -- Already Set
                dc.clear();
                startAnimationTimer(500, 6, true);
            default:
                dc.clear();
                callAnimation(dc);

                if(textGlideCounter <= 22) {
                    startAnimationTimer(50, 1, false);
                } else { animationTimer.stop(); }
                break;
        }
    }
    
    function onShow() as Void {
        
    }

    function onLayout(dc as $.Toybox.Graphics.Dc) as Void {
        centerX = (dc.getWidth() / 2).toNumber();
        centerY = (dc.getHeight() / 2).toNumber();

        turnsWidthOffset = (dc.getTextWidthInPixels(turnsText, secondaryFont) / 2).toNumber();
        timeTotalWidthOffset = (dc.getTextWidthInPixels(timeTotalText, secondaryFont) / 2).toNumber();
        timeLeftWidthOffset = (dc.getTextWidthInPixels(timeLeftText, secondaryFont) / 2).toNumber();
        animationTimer = new Timer.Timer();
    }

    private function callAnimation(dc as Dc) as Void {

        if(textGlideCounter < 20) {
            dc.drawText(
                (centerX + timeTotalWidthOffset).toNumber(),
                ((centerY / 2) +
                ((20.0 / textGlideCounter) - 1.0)).toNumber(),
                secondaryFont,
                timeTotalText,
                Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else {
            dc.drawText(
                (centerX + timeTotalWidthOffset).toNumber(),
                (centerY / 2).toNumber(),
                secondaryFont,
                timeTotalText,
                Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
        

        if(textGlideCounter >= 2 && textGlideCounter <= 21) {
            dc.drawText(
                (centerX + timeLeftWidthOffset).toNumber(),
                (centerY +
                ((20.0 / (textGlideCounter - 1)) - 1.0)).toNumber(),
                secondaryFont,
                timeLeftText,
                Graphics.TEXT_JUSTIFY_VCENTER
            );
        } else if(textGlideCounter == 1) { } else {
            dc.drawText(
                (centerX + timeLeftWidthOffset).toNumber(),
                centerY,
                secondaryFont,
                timeLeftText,
                Graphics.TEXT_JUSTIFY_VCENTER
            );
        }

        if(textGlideCounter >= 3) {
            dc.drawText(
                (centerX + turnsWidthOffset).toNumber(),
                ((dc.getHeight() * (3.0/4.0)) +
                ((20.0 / (textGlideCounter - 2)) - 1.0)),
                secondaryFont,
                turnsText,
                Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    private function standardizeTime(minutes as String, seconds as String, milliseconds as String) as Array {
        if(minutes.length() == 1) {
            minutes = "0" + minutes;
        }

        if(seconds.length() == 1) {
            seconds = "0" + seconds;
        }

        if(milliseconds.length() == 1) {
            milliseconds = "0" + milliseconds;
        } else if(milliseconds.length() == 3) {
            milliseconds = milliseconds.substring(0, milliseconds.length() - 1);
        }

        return [minutes, seconds, milliseconds];
    }

    private function startAnimationTimer(milliseconds, addCounter, addAnimationCounter as Boolean) as Void {
        if(addAnimationCounter) {
            Globals.animationCounter += addCounter;
        } else { textGlideCounter += addCounter; }
        animationTimer.start(method(:AnimationTimerCallback), milliseconds, false);
    }

    function AnimationTimerCallback() as Void {
        requestUpdate();
    }
}