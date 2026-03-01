import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.Math;

import Rez.Strings;
import Globals;
import Constants;

using Toybox.Application.Storage as Disk;
using Toybox.WatchUi as Ui;

class RapidLegacyView extends Ui.View {
    var isBacklightOn;
    var progressRing;

    var whiteMinutesLeft, blackMinutesLeft;
    var whiteSecondsInMinuteLeft, blackSecondsInMinuteLeft;
    var whiteMillisecondsLeft, blackMillisecondsLeft;

    var timeChangePreviousValue as Integer = 0;

    var displayOnlySeconds as Boolean = false;

    var mainNumberFont      as Graphics.FontDefinition = Graphics.FONT_SYSTEM_NUMBER_THAI_HOT;
    var incrementNumberFont as Graphics.FontDefinition = Graphics.FONT_TINY;
    var fontPadding as Number = 0;

    var centerX as Number = 0, centerY as Number = 0;

    var minsStr, secsStr, msStr;

    var gameStoppedRectangleY,
        switchSidesTextHeight,
        arcWidth;

    // Game Active Addons
    var font = Graphics.FONT_LARGE;
    var topOfRectangle = 0;
    var rectangleTextX = 0;
    var blackRectangleTimeTextX = 0;
    var whiteRectangleTimeTextX = 0;
    var extraDecimal = true;

    // Draw Timer Full
    var smallNumberFont = Graphics.FONT_TINY;
    var mainTextXPos    = 0;
    var msTextXPos      = 0;
    var msTextYPos      = 0;

    // Yellow Rectangle / Gamemode
    var yellowRectangleHeight;
    var gamemodeTextX;
    var yellowRectangleEndX;

    var flashingStringY = 0;

    function initialize() {

        if(Globals.hasStorage) {
            isBacklightOn = Disk.getValue("backlight");
            progressRing = Disk.getValue("progressRing");
            Globals.haptics = Disk.getValue("haptics");
        } else if(System.getDeviceSettings() has :requiresBurnInProtection){
            isBacklightOn = !System.getDeviceSettings().requiresBurnInProtection;
            progressRing = true;
        } else {
            isBacklightOn = true;
            progressRing = true;
        }

        Globals.animationTimer = new Timer.Timer();

        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        if(dc.getTextWidthInPixels("00:00", mainNumberFont) >= dc.getWidth() - dc.getWidth() / 8) {
            mainNumberFont = Graphics.FONT_NUMBER_HOT;
        }

        if(dc.getTextWidthInPixels("00:00", mainNumberFont) >= dc.getWidth() - dc.getWidth() / 8) {
            mainNumberFont = Graphics.FONT_NUMBER_MEDIUM;
        }

        if(dc.getTextWidthInPixels("00:00", mainNumberFont) >= dc.getWidth() - dc.getWidth() / 8) {
            mainNumberFont = Graphics.FONT_NUMBER_MILD;
        }

        if(dc.getTextWidthInPixels("00:00", mainNumberFont) >= dc.getWidth() - dc.getWidth() / 8) {
            mainNumberFont = Graphics.FONT_GLANCE_NUMBER;
        }

        centerX = (dc.getWidth()  / 2).toNumber();
        centerY = (dc.getHeight() / 2).toNumber();

        switchSidesTextHeight = (dc.getHeight() / 1.5 ).toNumber();
        gameStoppedRectangleY = (dc.getHeight() / 1.55).toNumber();

        flashingStringY = ((dc.getHeight() - Graphics.getFontHeight(mainNumberFont)) / 4 - 2).toNumber();
        // -2 accounts for the slight overlap with the main font

        arcWidth = (centerX / 6).toNumber();

        // Game Active Addons
        while(true) {
            topOfRectangle = ((dc.getHeight() + Graphics.getFontHeight(mainNumberFont)) / 2 - Graphics.getFontDescent(mainNumberFont) + Graphics.getFontDescent(Graphics.FONT_MEDIUM)).toNumber();
            rectangleTextX = (centerX - Math.sqrt(Math.pow(centerX, 2) - Math.pow(topOfRectangle + Graphics.getFontHeight(font) - centerY, 2)) + arcWidth / 2).toNumber();
            blackRectangleTimeTextX = (rectangleTextX + dc.getTextWidthInPixels(loadResource(Strings.black_time_no_space) + " ", font)).toNumber();
            whiteRectangleTimeTextX = (rectangleTextX + dc.getTextWidthInPixels(loadResource(Strings.white_time_no_space) + " ", font)).toNumber();

            if(
                rectangleTextX + dc.getTextWidthInPixels(loadResource(Strings.black_time_no_space) + " ", font) + dc.getTextWidthInPixels("00:00" + loadResource(Strings.decimal_separator) + "00", font)
                >
                dc.getWidth() - rectangleTextX
                ||
                rectangleTextX + dc.getTextWidthInPixels(loadResource(Strings.white_time_no_space) + " ", font) + dc.getTextWidthInPixels("00:00" + loadResource(Strings.decimal_separator) + "00", font)
                >
                dc.getWidth() - rectangleTextX
            ) {
                if(font == Graphics.FONT_LARGE) {
                    font = Graphics.FONT_MEDIUM;
                    continue;
                }
                if(font == Graphics.FONT_MEDIUM) {
                    font = Graphics.FONT_SMALL;
                    continue;
                }
                if(font == Graphics.FONT_SMALL) {
                    font = Graphics.FONT_TINY;
                    continue;
                }
                if(arcWidth == centerX / 6) {
                    arcWidth = (centerX / 9).toNumber();
                    continue;
                }
                extraDecimal = false;
            }
            break;
        }

        yellowRectangleHeight   = ((dc.getHeight() - Graphics.getFontHeight(mainNumberFont)) / 2 - Graphics.getFontHeight(Graphics.FONT_TINY)).toNumber();
        gamemodeTextX           = (dc.getWidth() / 2.35).toNumber();
        yellowRectangleEndX     = (gamemodeTextX + dc.getTextWidthInPixels("0", Graphics.FONT_TINY) + centerX).toNumber();

        // Draw Timer Full
        msTextYPos   = (dc.getHeight() / 2 - dc.getFontHeight(smallNumberFont) + Graphics.getFontDescent(smallNumberFont) + dc.getFontHeight(mainNumberFont) / 2 - Graphics.getFontDescent(mainNumberFont)).toNumber();
        var leftwardOffset = centerX - Math.sqrt(Math.pow(centerX, 2) - Math.pow(msTextXPos + dc.getFontHeight(smallNumberFont), 2)) + arcWidth / 2;
        mainTextXPos = ((dc.getWidth() - leftwardOffset) - dc.getTextWidthInPixels(loadResource(Strings.decimal_separator) + "00", smallNumberFont)).toNumber();
        msTextXPos   = ( dc.getWidth() - leftwardOffset).toNumber();
        // Center text in case it is further on the right
        if(mainTextXPos  > (dc.getWidth() + dc.getTextWidthInPixels("00:00", mainNumberFont)) / 2) {
            mainTextXPos = (dc.getWidth() + dc.getTextWidthInPixels("00:00", mainNumberFont)) / 2;
            msTextXPos   = (dc.getWidth() + dc.getTextWidthInPixels("00:00", mainNumberFont)) / 2 + dc.getTextWidthInPixels(loadResource(Strings.decimal_separator) + "00", smallNumberFont);
        }

        // Device Specific Config 
        // Mainly for devices with poor, large or no font descent numbers.
        switch(System.getDeviceSettings().partNumber) {
            case Constants.approachs60PartNumber:
                yellowRectangleHeight += 12;
                break;
            case Constants.d2charliePartNumber:
                yellowRectangleHeight -= 16;
                break;
        }
    }

    function onShow() as Void {
        if(Globals.settingChanged) {
            if((Globals.hasStorage && !Disk.getValue("legacyView")) || !Globals.useLegacyView) {
                Ui.switchToView(new $.RapidView(), new $.RapidDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
            }
        }
    }

    function onUpdate(dc) as Void {

        if(Globals.hasStorage) {
            if(isBacklightOn) {
                Attention.backlight(true);
            }
        } else {
            if(Globals.backLightOn) {
                Attention.backlight(true);
            }
        }

        if(Globals.gameStarted) {
            handleTimerDrawingAndChecks(dc);
            if(Globals.hasStorage) {
                if(progressRing) { drawProgressRing(dc); }
            } else {
                if(Globals.drawProgressRing) { drawProgressRing(dc); }
            }
            drawGameActiveAddons(dc);
            return;
        }

        if(Globals.isDragging) {
            draggingDrawEvent(dc);
            return;
        }

        if(Globals.changingStartingTimeWithButton || Globals.changingSideWithButton != 'n') {
            handleTimerTimeChange(dc);
            return;
        }
        
        if(Globals.changingIncrementWithButton) {
            handleTimerIncrementChange(dc);
            return;
        }
        
        if(Globals.hasGameBeenStopped) {
            if(Globals.hasStorage) {
                if(progressRing) { drawProgressRing(dc); }
            } else if(Globals.drawProgressRing) { drawProgressRing(dc); }
            drawGameStoppedScreen(dc);
            return;
        }

        handleTimerDrawingAndChecks(dc);
        drawGameIdleAddons(dc);

        return;
    }

    function onHide() as Void {
    }

    function drawGameStoppedScreen(dc) {
        handleTimerDrawingAndChecks(dc);

        dc.fillRectangle(
            0,
            gameStoppedRectangleY,
            dc.getWidth(),
            centerY
        );

        reverseColors(dc);

        dc.drawText(
            centerX,
            switchSidesTextHeight,
            Graphics.FONT_SYSTEM_LARGE,
            loadResource(Strings.switch_sides),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        reverseColors(dc);
    }

    function drawProgressRing(dc as Dc) as Void {

        var angle = Globals.isWhitesTurn ?
        (360.0 * (Globals.whiteTimeLeft.toFloat() / ((Globals.startingTimeInSeconds + Globals.whiteIncrement).toFloat() * 1000.0))) + 90.0
        :
        (360.0 * (Globals.blackTimeLeft.toFloat() / ((Globals.startingTimeInSeconds + Globals.blackIncrement).toFloat() * 1000.0))) + 90.0;

        if(angle > 450) { angle = 450; }

        dc.setPenWidth(arcWidth);

        dc.drawArc(
            centerX,
            centerY,
            centerX,
            Graphics.ARC_CLOCKWISE,
            angle,
            450
        );

        dc.setPenWidth(1);
    }

    function drawGameActiveAddons(dc as Dc) {
        dc.fillRectangle(
            0,
            topOfRectangle,
            dc.getWidth(),
            Graphics.getFontHeight(font) + Graphics.getFontDescent(font)
        );

        reverseColors(dc);

        if(Globals.isWhitesTurn) {
            
            dc.drawText(
                rectangleTextX,
                topOfRectangle + Graphics.getFontDescent(font) / 2,
                font,
                loadResource(Strings.black_time_no_space),
                Graphics.TEXT_JUSTIFY_LEFT
            );

            var mins = (Globals.blackTimeLeft / 60000).toNumber();
            var secs = ((Globals.blackTimeLeft / 1000) % 60).toNumber();

            minsStr = mins < 10 ? "0" + mins : mins.toString();
            secsStr = secs < 10 ? "0" + secs : secs.toString();
            if(extraDecimal) {
                var ms = (Globals.blackTimeLeft % 1000).toNumber();
                msStr  = ms < 10 ? "0" + ms : (ms < 100 ? "0" + ms / 10 : ms / 10);
            }

            // WOWWW GREAT NAMING CONVENTION ME 2 YEARS AGO
            // * UninterestingCountingVariable increments every tick. This code controls the flashing number
            if(!(Globals.uninterestingCountingVariable >= 3 && Globals.uninterestingCountingVariable <= 6) &&
               !(Globals.uninterestingCountingVariable >= 9 && Globals.uninterestingCountingVariable <= 12)) {
                dc.drawText(
                    blackRectangleTimeTextX,
                    topOfRectangle + Graphics.getFontDescent(font) / 2,
                    font,
                    minsStr + ":" + secsStr + (extraDecimal ? loadResource(Strings.decimal_separator) + msStr : ""),
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
        } else {

            dc.drawText(
                rectangleTextX,
                topOfRectangle + Graphics.getFontDescent(font) / 2,
                font,
                loadResource(Strings.white_time_no_space),
                Graphics.TEXT_JUSTIFY_LEFT
            );
            

            var mins = (Globals.whiteTimeLeft / 60000).toNumber();
            var secs = ((Globals.whiteTimeLeft / 1000) % 60).toNumber();

            minsStr = mins < 10 ? "0" + mins : mins.toString();
            secsStr = secs < 10 ? "0" + secs : secs.toString();
            if(extraDecimal) {
                var ms = (Globals.whiteTimeLeft % 1000).toNumber();
                msStr  = ms < 10 ? "0" + ms : (ms < 100 ? "0" + ms / 10 : ms / 10);
            }
            
            if(!(Globals.uninterestingCountingVariable >= 3 && Globals.uninterestingCountingVariable <= 6) &&
               !(Globals.uninterestingCountingVariable >= 9 && Globals.uninterestingCountingVariable <= 12)) {
                dc.drawText(
                    whiteRectangleTimeTextX,
                    topOfRectangle + Graphics.getFontDescent(font) / 2,
                    font,
                    minsStr + ":" + secsStr + (extraDecimal ? loadResource(Strings.decimal_separator) + msStr : ""),
                    Graphics.TEXT_JUSTIFY_LEFT
                );
            }
        }
    }

    function drawGameIdleAddons(dc as Dc) as Void {
        whiteMinutesLeft = ((Globals.whiteTimeLeft - Globals.whiteIncrement * 1000) / 60000).toNumber();
        whiteSecondsInMinuteLeft = (((Globals.whiteTimeLeft - Globals.whiteIncrement * 1000) / 1000) % 60).toNumber();
        if(whiteSecondsInMinuteLeft != 0) {
            secsStr = ":" + whiteSecondsInMinuteLeft;
        } else { secsStr = ""; }

        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);

        dc.fillRoundedRectangle(
            -centerX,
            yellowRectangleHeight,
            yellowRectangleEndX,
            Graphics.getFontHeight(Graphics.FONT_TINY),
            Graphics.getFontHeight(Graphics.FONT_TINY) / 2
        );

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        System.println(Graphics.getFontDescent(mainNumberFont));
        System.println(Graphics.getFontAscent(mainNumberFont));
        System.println(dc.getFontHeight(mainNumberFont));

        dc.drawText(
            gamemodeTextX,
            yellowRectangleHeight,
            Graphics.FONT_TINY,
            whiteMinutesLeft.toString() + secsStr + "+" + Globals.whiteIncrement,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        decideColors(dc);
    }

    function draggingDrawEvent(dc) {
        return Globals.isDragVertical ? handleTimerIncrementChange(dc) : handleTimerTimeChange(dc);
    }

    function handleTimerIncrementChange(dc) {
        decideColors(dc);
        dc.clear();

        if(Globals.incrementHoldingVar.toNumber() != timeChangePreviousValue.toNumber() && Globals.hasAnimationTimerStarted) {
            Globals.animationTimer.stop();
            Globals.hasAnimationTimerStarted = false;
        }

        timeChangePreviousValue = Globals.incrementHoldingVar;

        var label = Globals.hasGameBeenStopped
        ? (Globals.isWhitesTurn ? loadResource(Strings.white_increment) : loadResource(Strings.black_increment))
        : loadResource(Strings.increment);

        drawTimerFlashingString(dc, label);
        drawTimerSeconds(dc, "+" + Globals.incrementHoldingVar, 0);
    }

    function handleTimerTimeChange(dc as Dc) as Void {
        var tempTime;

        if(Globals.hasGameBeenStopped) {
            tempTime = Globals.changingTimeHoldingVar;
        } else {
            tempTime = Globals.startingTimeHoldingVar;
        }

        var mins = (tempTime / 60000).toNumber();
        var secs = ((tempTime / 1000) % 60).toNumber();
        var ms   = (tempTime % 1000).toNumber();

        whiteMinutesLeft         = mins < 10 ? "0" + mins : mins.toString();
        whiteSecondsInMinuteLeft = secs < 10 ? "0" + secs : secs.toString();
        whiteMillisecondsLeft    = ms   < 10 ? "0" + ms   : (ms >= 100 ? ms / 10 : ms.toString());

        displayOnlySeconds = tempTime < 60000;

        decideColors(dc);
        dc.clear();

        if(whiteSecondsInMinuteLeft.toNumber() != timeChangePreviousValue.toNumber() && Globals.hasAnimationTimerStarted) {
            Globals.animationTimer.stop();
            Globals.hasAnimationTimerStarted = false;
        }

        timeChangePreviousValue = whiteSecondsInMinuteLeft;

        var label;
        if(Globals.hasGameBeenStopped) {
            label = Globals.isWhitesTurn ? loadResource(Strings.white_time_no_space) : loadResource(Strings.black_time_no_space);
        } else {
            label = loadResource(Strings.starting_time);
        }

        drawTimerFlashingString(dc, label);

        if(!displayOnlySeconds) {
            drawTimerFull(dc, whiteMinutesLeft, whiteSecondsInMinuteLeft, whiteMillisecondsLeft);
        } else {
            drawTimerSeconds(dc, whiteSecondsInMinuteLeft, whiteMillisecondsLeft);
        }
    }


    function handleTimerDrawingAndChecks(dc as Dc) as Void {
        var currentTime = Globals.isWhitesTurn ? Globals.whiteTimeLeft : Globals.blackTimeLeft;
        var mins = (currentTime / 60000).toNumber();
        var secs = ((currentTime / 1000) % 60).toNumber();
        var ms   = (currentTime % 1000).toNumber();

        var minsStr = mins < 10 ? "0" + mins : mins.toString();
        var secsStr = secs < 10 ? "0" + secs : secs.toString();
        var msStr   = ms   < 10 ? "0" + ms   : (ms < 100 ? "0" + ms / 10 : ms / 10);

        displayOnlySeconds = currentTime < 60000;

        dc.setColor(Globals.isWhitesTurn ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE,
                    Globals.isWhitesTurn ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK);
        dc.clear();

        if(!displayOnlySeconds) {
            drawTimerFull(dc, minsStr, secsStr, msStr);
        } else {
            drawTimerSeconds(dc, secsStr, msStr);
        }
    }

    function drawTimerFull(dc, minutesLeft, secondsLeft, millisecondsLeft) as Void {

        dc.drawText(
            mainTextXPos,
            centerY,
            mainNumberFont,
            minutesLeft + ":" + secondsLeft,
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.drawText(
            msTextXPos,
            msTextYPos,
            smallNumberFont,
            loadResource(Strings.decimal_separator) + millisecondsLeft,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function drawTimerSeconds(dc as Dc, secondsLeft, millisecondsLeft) as Void {
        dc.drawText(
            centerX,
            (dc.getHeight() - dc.getFontHeight(mainNumberFont)) / 2,
            mainNumberFont,
            secondsLeft,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var smallNumberFont = Graphics.FONT_TINY;

        dc.drawText(
            (dc.getWidth() + dc.getTextWidthInPixels(secondsLeft, mainNumberFont)) / 2,
            dc.getHeight() / 2 - dc.getFontHeight(smallNumberFont) + Graphics.getFontDescent(smallNumberFont) + dc.getFontHeight(mainNumberFont) / 2 - Graphics.getFontDescent(mainNumberFont),
            smallNumberFont,
            loadResource(Strings.decimal_separator) + millisecondsLeft,
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    function drawTimerFlashingString(dc as Dc, string as String) as Void {
        if(!Globals.hasAnimationTimerStarted) {
            Globals.drawString = true;
            Globals.animationTimer.start(method(:incrementDrawStringState), 50, true);
            Globals.hasAnimationTimerStarted = true;
        }

        if(Globals.drawString) {
            dc.drawText(
                centerX,
                flashingStringY,
                Graphics.FONT_SYSTEM_MEDIUM,
                string,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }

    function decideColors(dc as Dc) as Void {
        if(Globals.isWhitesTurn) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        } else {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        }
    }

    function reverseColors(dc as Dc) as Void {
        if(Globals.isWhitesTurn) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        }
    }

    function incrementDrawStringState() as Void {
        Globals.interestingCountingVariable++;
        if(Globals.interestingCountingVariable % 30 > 15) {
            Globals.drawString = false;
        } else {Globals.drawString = true; }
        Ui.requestUpdate();
    }
}
