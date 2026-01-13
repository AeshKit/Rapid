/*
NOTE:
The code is slow, and it's messy as hell, but on real hardware it's fine as the animation is running alone
If it ain't broke, don't fix it
*/
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Math;

import Globals;
import Constants;
import Rez.Strings;

using Toybox.WatchUi as Ui;

class TimeOutView extends Ui.View {

    var animationTimer;
    var textGlideCounter;

    var lostVectorFont;

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

    var lostVectorFontSize = (System.getDeviceSettings().screenHeight / 7);
    
    function initialize() {
        if(System.getDeviceSettings() has :systemLanguage && System.getDeviceSettings().systemLanguage == System.LANGUAGE_SPA) {
            lostVectorFontSize = (System.getDeviceSettings().screenHeight / 10.0);
        }

        lostVectorFont = Graphics.getVectorFont( {
            :face => ["RobotoBlack", "RobotoCondensedBold", "BionicBold"],
            :size => lostVectorFontSize
        });

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

        minutesLeft      = (winningSideTimeLeft / 60000).toString();
        secondsLeft      = ((winningSideTimeLeft / 1000) % 60).toString();
        millisecondsLeft = (winningSideTimeLeft % 1000).toString();

        totalMinutes      = (Globals.totalTime / 60000).toString();
        totalSeconds      = ((Globals.totalTime / 1000) % 60).toString();
        totalMilliseconds = (Globals.totalTime % 1000).toString();

        holdingArray      = standardizeTime(totalMinutes, totalSeconds, totalMilliseconds);
        totalMinutes      = holdingArray[0];
        totalSeconds      = holdingArray[1];
        totalMilliseconds = holdingArray[2];

        holdingArray      = standardizeTime(minutesLeft, secondsLeft, millisecondsLeft);
        minutesLeft       = holdingArray[0];
        secondsLeft       = holdingArray[1];
        millisecondsLeft  = holdingArray[2];

        Globals.animationCounter = 0;
        textGlideCounter = 0;

        System.println(System.getDeviceSettings().partNumber);

        View.initialize();

    }

    function onUpdate(dc) as Void {
        switch(Globals.animationCounter) {
            case 0:
                dc.setColor(mainColor, secondaryColor);
                dc.clear();
                startAnimationTimer(100, 1);
                break;
            case 1:
                dc.setColor(secondaryColor, mainColor);
                dc.clear();
                startAnimationTimer(100, 1);
                break;
            case 2:
                dc.setColor(mainColor, secondaryColor);
                dc.clear();
                startAnimationTimer(100, 1);
                break;
            case 3:
                dc.setColor(secondaryColor, mainColor);
                dc.clear();
                dc.drawAngledText (
                    dc.getWidth() / 2,
                    dc.getHeight() / 2,
                    lostVectorFont,
                    mainLoseString,
                    Graphics.TEXT_JUSTIFY_CENTER,
                    90
                );
                startAnimationTimer(500, 1);
                break;
            case 4:
                dc.setColor(secondaryColor, mainColor);
                dc.clear();
                dc.drawAngledText (
                    dc.getWidth() / 2,
                    dc.getHeight() / 2,
                    lostVectorFont,
                    mainLoseString,
                    Graphics.TEXT_JUSTIFY_CENTER,
                    90
                );
                Globals.animationCounter++;
                startTextSlideAnimation();
                break;
            case 5:
                dc.clear();
                callScalingAnimationsAndTimeLeftText(dc);

                if(textGlideCounter == 16) {
                    Globals.animationCounter++;
                }
                break;
            case 6:
                dc.clear();
                callScalingAnimationsAndTimeLeftText(dc);

                dc.setColor(greyColor, mainColor);
                drawTurnsStat(dc);
                dc.setColor(secondaryColor, mainColor);
                if(textGlideCounter == 18) {
                    Globals.animationCounter++;
                }
                break;
            case 7:
                dc.clear();
                callScalingAnimationsAndTimeLeftText(dc);
                
                if(textGlideCounter == 20) {
                    Globals.animationCounter++;
                }
                break;
            case 8:
                dc.clear();
                callScalingAnimationsAndTimeLeftText(dc);

                dc.setColor(greyColor, mainColor);
                drawTurnsStat(dc);
                drawTimeTotalStat(dc);
                dc.setColor(secondaryColor, mainColor);
                if(textGlideCounter == 21) {
                    Globals.animationCounter++;
                }
                break;
            case 9:
                dc.clear();
                callScalingAnimationsAndTimeLeftText(dc);

                dc.setColor(greyColor, mainColor);
                drawTurnsStat(dc);
                dc.setColor(secondaryColor, mainColor);
                if(textGlideCounter == 23) {
                    Globals.animationCounter++;
                }
                break;
            case 10:
                dc.clear();
                callScalingAnimationsAndTimeLeftText(dc);

                dc.setColor(greyColor, mainColor);
                drawTurnsStat(dc);
                drawTimeTotalStat(dc);
                dc.setColor(secondaryColor, mainColor);
                break;
            default:
                Globals.animationCounter = 10;
                animationTimer.stop();
                break;
        }
    }

    function onLayout(dc) as Void {
        animationTimer = new Timer.Timer();
    }

    function onShow() as Void {
    }

    private function callScalingAnimationsAndTimeLeftText(dc) {
        if(textGlideCounter <= 20) { resizeAndAnimateLoseText(dc); }
        else { setLoseTextEndingPosition(dc); }

        if(textGlideCounter >= 8) { resizeAndAnimateLoseRectangle(dc); }
                
        dc.setColor(mainColor, secondaryColor);
        drawTimeLeftName(dc);
        handleTimeLeftText(dc);
        dc.setColor(secondaryColor, mainColor);
    }

    private function resizeAndAnimateLoseText(dc) as Void {
        lostVectorFontSize = (System.getDeviceSettings().screenHeight / (7.0 + (1.0 - Math.pow(1.0 - textGlideCounter/20.0, 3.0))));
        if(System.getDeviceSettings().systemLanguage == System.LANGUAGE_SPA) {
            lostVectorFontSize = (System.getDeviceSettings().screenHeight / (10.0 + (1.0 - Math.pow(1.0 - textGlideCounter/20.0, 3.0))));
        }

        lostVectorFont = Graphics.getVectorFont( {
            :face => ["RobotoBlack", "RobotoCondensedBold", "BionicBold"],
            :size => lostVectorFontSize
        });

        dc.drawAngledText (
            dc.getWidth() / (2.0 + (1.0 - Math.pow(1.0 - textGlideCounter/20.0, 3.0))),
            dc.getHeight() / 2,
            lostVectorFont,
            mainLoseString,
            Graphics.TEXT_JUSTIFY_CENTER,
            90
        );
    }

    private function setLoseTextEndingPosition(dc) as Void {
        lostVectorFontSize = System.getDeviceSettings().screenHeight / 8;
        if(System.getDeviceSettings().systemLanguage == System.LANGUAGE_SPA) {
            lostVectorFontSize = (System.getDeviceSettings().screenHeight / 11);
        }

        lostVectorFont = Graphics.getVectorFont( {
            :face => ["RobotoBlack", "RobotoCondensedBold", "BionicBold"],
            :size => lostVectorFontSize
        });

        dc.drawAngledText (
            dc.getWidth() / 3,
            dc.getHeight() / 2,
            lostVectorFont,
            mainLoseString,
            Graphics.TEXT_JUSTIFY_CENTER,
            90
        );
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

    private function resizeAndAnimateLoseRectangle(dc) as Void {
        if(textGlideCounter >= 38) {
            dc.fillRectangle(
                dc.getWidth() / 2 - (dc.getWidth() / 12),
                0,
                dc.getWidth() / 6,
                dc.getHeight()
            );
            return;
        }

        dc.fillRectangle(
            dc.getWidth() / 2 - (dc.getWidth() / 12),
            (dc.getHeight() / 2.0) - (dc.getHeight() * (1.0 - Math.pow(2.0, -10.0 * ((textGlideCounter - 8.0)/30.0)))) / 2,
            // so uhh, the above line is actually gay
            dc.getWidth() / 6,
            dc.getHeight() * (1.0 - Math.pow(2.0, -10.0 * ((textGlideCounter - 8.0)/30.0)))
        );
    }

    private function drawTurnsStat(dc) {

        lostVectorFontSize = System.getDeviceSettings().screenHeight / 16;

        lostVectorFont = Graphics.getVectorFont( {
            :face => ["RobotoBlack", "RobotoCondensedBold", "BionicBold"],
            :size => lostVectorFontSize
        });

        dc.drawAngledText (
            dc.getWidth() / 2 + dc.getWidth() / 7,
            dc.getHeight() - dc.getHeight() / 14,
            lostVectorFont,
            loadResource(Strings.turns) + Globals.turns.toString(),
            Graphics.TEXT_JUSTIFY_LEFT,
            90
        );
    }

    private function drawTimeTotalStat(dc) {

        dc.drawAngledText (
            dc.getWidth() / 2 + dc.getWidth() / 7,
            dc.getHeight() / 14,
            lostVectorFont,
            loadResource(Strings.total_time) + totalMinutes + ":" + totalSeconds + loadResource(Strings.decimal_separator) + totalMilliseconds,
            Graphics.TEXT_JUSTIFY_RIGHT,
            90
        );
    }

    private function handleTimeLeftText(dc) as Void {
        lostVectorFontSize = System.getDeviceSettings().screenHeight / 6;

        lostVectorFont = Graphics.getVectorFont( {
            :face => ["BionicBold", "NotoSansArmenianBold", "NotoSansHebrewBold"],
            :size => lostVectorFontSize
        });

        dc.drawAngledText(
            dc.getWidth() / 2 + dc.getWidth() / 22,
            dc.getHeight() / 24,
            lostVectorFont,
            minutesLeft + ":" + secondsLeft + loadResource(Strings.decimal_separator) + millisecondsLeft,
            Graphics.TEXT_JUSTIFY_RIGHT,
            90
        );

    }

    private function drawTimeLeftName(dc) {

        lostVectorFontSize = System.getDeviceSettings().screenHeight / 9;

        lostVectorFont = Graphics.getVectorFont( {
            :face => ["RobotoBlack", "RobotoCondensedBold", "BionicBold"],
            :size => lostVectorFontSize
        });

        dc.drawAngledText (
            dc.getWidth() / 2 + dc.getWidth() / 24,
            dc.getHeight() - dc.getHeight() / 24,
            lostVectorFont,
            loadResource(Strings.time_left),
            Graphics.TEXT_JUSTIFY_LEFT,
            90
        );
    }

    private function startAnimationTimer(milliseconds, addCounter) {
        Globals.animationCounter += addCounter;
        animationTimer.start(method(:AnimationTimerCallback), milliseconds, false);
    }

    function AnimationTimerCallback() as Void {
        requestUpdate();
    }

    private function startTextSlideAnimation() {
        animationTimer.start(method(:glideTimerCallback), 50, true);
    }

    function glideTimerCallback() as Void {
        textGlideCounter++;
        if(textGlideCounter >= 200) {
            animationTimer.stop();
        }
        requestUpdate();
    }

    function onHide() as Void {
        animationTimer.stop();
        Globals.totalTime = 0;
        lostVectorFont = null;
    }
}
