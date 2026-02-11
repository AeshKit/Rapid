import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;

import Rez.Strings;
import Globals;
import Constants;

using Toybox.Application.Storage as Disk;
using Toybox.WatchUi as Ui;

class RapidLegacyView extends Ui.View {

    var isBacklightOn as Boolean = Disk.getValue("backlight");
    var progressRing as Boolean = Disk.getValue("progressRing");

    var whiteMinutesLeft, blackMinutesLeft;
    var whiteSecondsInMinuteLeft, blackSecondsInMinuteLeft;
    var whiteMillisecondsLeft, blackMillisecondsLeft;

    var timeChangePreviousValue as Integer = 0;

    var displayOnlySeconds as Boolean = false;

    var mainNumberFont      as Graphics.FontDefinition = Graphics.FONT_SYSTEM_NUMBER_THAI_HOT;
    var incrementNumberFont as Graphics.FontDefinition = Graphics.FONT_TINY;
    var fontPadding as Number = 0;

    var tooBig = false;

    var centerX as Number = 0, centerY as Number = 0;

    var minsStr, secsStr, msStr;

    var gameStoppedRectangleY as Number = 0,
        onePlusHalfHeight     as Number = 0,
        onePlusQuarterHeight  as Number = 0,
        gameActiveAddonsRect1 as Number = 0,
        heightOver8           as Number = 0,
        widthOver1_9          as Number = 0,
        gameActiveAddonsTextY as Number = 0,
        gameActiveAddonsTextX as Number = 0,
        idleRectangleX        as Number = 0,
        idleRectangleY        as Number = 0,
        idleRectangleRadius   as Number = 0,
        idleRectangleHeight   as Number = 0,
        idleTextHeight        as Number = 0,
        fontTinyHeight        as Number = 0,
        fontMainHeight        as Number = 0,
        fontMainWidth         as Number = 0,
        fontMainTimerWidth    as Number = 0,
        mainTimerX            as Number = 0,
        mainTimerMsX          as Number = 0,
        mainTimerMsY          as Number = 0,
        secondsTimerX         as Number = 0,
        sometimesCenterY      as Number = 0,
        heightOver6AndAHalf   as Number = 0,
        widthOverTwoThreeFive as Number = 0,
        arcWidth              as Number = 0;

    var isWatch = true;
    // I planned to add support for other garmin devices
    // I *might* in the future, but man I just wanna go learn a real programming language

    function initialize() {

        Globals.haptics = Disk.getValue("haptics");

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



        /*
        The names of these functions are only slightly descriptive, but that doesn't matter too much.

        The point is that as the app loads, it determins all of these numbers beforehand to improve runtime
        performance. If the performance is too poor, the timer will lag and the true value of the timer will
        stray from the on-screen approximation

        Other watches have different layouts and the fonts are all different sizes as well despite having
        the same name. This is why there is a lot of device-specific maths done here to check which device is
        actually running the app and override the defaults. In practice, the effect this has on performance is
        marginal compared to doing it on the fly, even if it results in less readable code.

        Sorry about that xP
        */

        fontTinyHeight = (dc.getFontHeight(Graphics.FONT_TINY)).toNumber();
        fontMainHeight = (dc.getFontHeight(mainNumberFont)).toNumber();
        fontMainWidth  = (dc.getTextWidthInPixels("0", mainNumberFont)).toNumber();
        fontMainTimerWidth  = (dc.getTextWidthInPixels("00:00", mainNumberFont)).toNumber();

        centerX = (dc.getWidth()  / 2).toNumber();
        centerY = (dc.getHeight() / 2).toNumber();
        sometimesCenterY = centerY.toNumber();

        heightOver8 =           (dc.getHeight() / 8   ).toNumber(); // Used for lower time display rectangle height
        onePlusHalfHeight =     (dc.getHeight() / 1.5 ).toNumber();
        onePlusQuarterHeight =  (dc.getHeight() / 1.25).toNumber();
        gameStoppedRectangleY = (dc.getHeight() / 1.55).toNumber();
        heightOver6AndAHalf =   (dc.getHeight() / 6.5 ).toNumber();

        widthOver1_9 =          (dc.getWidth() / 1.9 ).toNumber();
        widthOverTwoThreeFive = (dc.getWidth() / 2.35).toNumber();

        gameActiveAddonsRect1 = (dc.getHeight() - dc.getHeight() / 2.8).toNumber();
        gameActiveAddonsTextY = (dc.getHeight() - dc.getHeight() / 2.8 + (dc.getHeight() / 10) / 2).toNumber();
        gameActiveAddonsTextX = (dc.getWidth() - (dc.getWidth() / 7.75)).toNumber();

        idleRectangleX =      (dc.getWidth() / 1.85 * -1).toNumber();
        idleRectangleY =      (dc.getHeight() / 3.95).toNumber();
        idleRectangleHeight = (dc.getHeight() / 12).toNumber();
        idleRectangleRadius = (dc.getHeight() / 28).toNumber();
        idleTextHeight =      (idleRectangleY + (idleRectangleHeight - fontTinyHeight) / 2).toNumber();

        mainTimerX =      (centerX + fontMainTimerWidth / 2).toNumber();
        secondsTimerX   = (centerX + fontMainWidth).toNumber();
        mainTimerMsX =    (centerX + Graphics.getFontHeight(mainNumberFont) * 1.25 + (fontPadding * (dc.getWidth() / 22))).toNumber();
        mainTimerMsY =    (centerY + Graphics.getFontHeight(mainNumberFont) / 8    - (fontPadding * (dc.getHeight() / 56))).toNumber();

        arcWidth = (centerX / 6).toNumber();

        // Could've made a bunch of resources file, but that would be bloat to be honest this project is large enough
        /*
        switch(System.getDeviceSettings().partNumber) {
            case Constants.fr55PartNumber:
                tooBig = true;
                mainTimerMsX += 100; // Get rid of it
                gameActiveAddonsRect1 += 8;
                gameActiveAddonsTextY += 9;
                gameActiveAddonsTextX -= 38;
                break;
            case Constants.fr230PartNumber:
            case Constants.fr235PartNumber:
                mainTimerX += 6;
                mainTimerMsX -= 12;
                mainTimerMsY += 6;
                idleTextHeight -= 1;
            case Constants.fr245PartNumber:
            case Constants.fr245mPartNumber:
                mainTimerX   -= 12;
                mainTimerMsX -= 12;
                mainTimerMsY -= 3;
                gameActiveAddonsTextY += 2;
                arcWidth -= 12;
                break;
            case Constants.fr255PartNumber:
            case Constants.fr255mPartNumber:
                mainTimerX   -= 12;
                mainTimerMsX -= 6;
                mainTimerMsY -= 4;
                arcWidth /= 2;
                break;
            case Constants.fr255sPartNumber:
            case Constants.fr255smPartNumber:
                mainTimerX   -= 12;
                mainTimerMsX -= 6;
                mainTimerMsY -= 2;
                arcWidth /= 2;
                break;
            case Constants.fr630PartNumber:
                mainTimerMsX -= 12;
                mainTimerMsY += 3;
                gameActiveAddonsTextX -= 12;
                gameActiveAddonsTextY += 4;
                gameActiveAddonsRect1 += 4;
                break;
            case Constants.fr645PartNumber:
            case Constants.fr645mPartNumber:
                mainTimerMsX += 39;
                mainTimerMsY -= 1;
                gameActiveAddonsTextY += 2;
            case Constants.fr735xtPartNumber:
                mainTimerMsX -= 12;
                mainTimerMsY += 3;
                break;
            case Constants.fr745PartNumber:
                mainTimerX   -= 8;
                mainTimerMsX -= 6;
                mainTimerMsY -= 2;
                gameActiveAddonsTextY += 2;
                arcWidth = 8;
                break;
            case Constants.fr935PartNumber:
                mainTimerMsX += 28;
                mainTimerMsY += 1;
                arcWidth = (dc.getWidth() / 16).toNumber();
                break;
            case Constants.fr945PartNumber:
            case Constants.fr945ltePartNumber:
                mainTimerX -= 8;
                mainTimerMsX -= 6;
                mainTimerMsY -= 3;
                gameActiveAddonsTextY += 2;
                arcWidth = 12;
                break;
            case Constants.fenixchronosPartNumber:
                mainTimerMsX += 27;
                mainTimerMsY += 3;
                gameActiveAddonsTextY += 2;
                arcWidth -= 6;
                break;
            case Constants.approachs50PartNumber:
                mainTimerX -= 18;
                mainTimerMsX -= 44;
                mainTimerMsY -= 13;
                break;
            case Constants.approachs60PartNumber:
                heightOver8 += 14;
                tooBig = true;
                mainTimerMsY -= 8;
                mainTimerMsX -= 9;
                mainTimerX -= 9;
                idleTextHeight -= 2;
                gameActiveAddonsTextX -= 42;
                gameActiveAddonsTextY += 6;
                arcWidth = 14;
                break;
            case Constants.approachs62PartNumber:
                mainTimerX -= 6;
                mainTimerMsX -= 3;
                mainTimerMsY -= 4;
                gameActiveAddonsTextY += 2;
                arcWidth = 16;
                break;
            case Constants.d2airPartNumber:
                mainTimerX -= 18;
                mainTimerMsX += 4;
                mainTimerMsY -= 4;
                arcWidth = 12;
                break;
            case Constants.d2airx10PartNumber:
                heightOver6AndAHalf -= 16;
                mainTimerMsX -= 28;
                mainTimerMsY -= 16;
                arcWidth = 14;
                break;
            case Constants.d2bravoPartNumber:
            case Constants.d2bravo_titPartNumber:
                sometimesCenterY -= 6;
                mainTimerMsX -= 42;
                mainTimerMsY -= 1;
                gameActiveAddonsTextY += 2;
                arcWidth = dc.getWidth() / 9;
                break;
            case Constants.d2charliePartNumber:
            case Constants.d2deltaPartNumber:
            case Constants.d2deltapxPartNumber:
            case Constants.d2deltasPartNumber:
                idleTextHeight -= 1;
                mainTimerMsX += 28;
                mainTimerMsY += 1;
                gameActiveAddonsTextY += 2;
                break;
            case Constants.descentg2PartNumber:
                mainTimerMsX -= 20;
                mainTimerMsY -= 14;
                idleTextHeight -= 2;
                arcWidth -= 14;
                break;
            case Constants.descentmk1PartNumber:
                mainTimerMsX += 28;
                mainTimerMsY += 1;
                idleTextHeight -= 1;
                gameActiveAddonsTextY += 1;
                break;
            case Constants.descentmk2PartNumber:
                mainTimerMsX -= 23;
                mainTimerMsY -= 12;
                mainTimerX -= 8;
                idleTextHeight -= 1;
                heightOver6AndAHalf -= 12;
                arcWidth -= 6;
                break;
            case Constants.descentmk2sPartNumber:
                mainTimerMsX -= 21;
                mainTimerMsY -= 10;
                mainTimerX -= 8;
                idleTextHeight -= 1;
                heightOver6AndAHalf -= 14;
                arcWidth -= 6;
                break;
            case Constants.fenix3PartNumber:
            case Constants.fenix3hrPartNumber:
                sometimesCenterY -= 12;
                gameActiveAddonsTextY += 2;
                heightOver6AndAHalf -= 16;
                mainTimerMsX -= 45;
                mainTimerMsY -= 6;
                break;
            case Constants.fenix5PartNumber:
            case Constants.fenix5plusPartNumber:
            case Constants.fenix5xPartNumber:
            case Constants.fenix5xplusPartNumber:
                mainTimerMsX += 28;
                gameActiveAddonsTextY += 1;
                idleTextHeight -= 1;
                break;
            case Constants.fenix5sPartNumber:
            case Constants.fenix5splusPartNumber:
                mainTimerMsX += 26;
                mainTimerMsY += 1;
                gameActiveAddonsTextY += 1;
                idleTextHeight -= 1;
                break;
            case Constants.fenix6PartNumber:
            case Constants.fenix6proPartNumber:
            case Constants.fenix6xproPartNumber:
                mainTimerX -= 6;
                mainTimerMsX -= 21;
                mainTimerMsY -= 13;
                gameActiveAddonsTextY += 1;
                idleTextHeight -= 1;
                arcWidth -= 8;
                break;
            case Constants.fenix6sPartNumber:
            case Constants.fenix6sproPartNumber:
                mainTimerX -= 7;
                mainTimerMsX -= 20;
                mainTimerMsY -= 11;
                gameActiveAddonsTextY += 1;
                idleTextHeight -= 1;
                arcWidth -= 8;
                break;
            case Constants.instinct345mmPartNumber:
                mainTimerMsX -= 45;
                mainTimerMsY -= 4;
                gameActiveAddonsTextY += 2;
                break;
            case Constants.instinct350mmPartNumber:
                mainTimerMsX -= 48;
                mainTimerMsY -= 3;
                gameActiveAddonsTextY += 2;
                break;
            case Constants.venuPartNumber:
                mainTimerX -= 16;
                mainTimerMsX += 2;
                mainTimerMsY -= 6;
                gameActiveAddonsTextY += 2;
                break;
            case Constants.venu2PartNumber:
            case Constants.venu2plusPartNumber:
                mainTimerX -= 4;
                mainTimerMsX -= 36;
                mainTimerMsY -= 16;
                gameActiveAddonsTextY += 2;
                arcWidth -= 8;
                break;
            case Constants.venu2sPartNumber:
                mainTimerX -= 4;
                mainTimerMsX -= 32;
                mainTimerMsY -= 14;
                heightOver6AndAHalf -= 8;
                gameActiveAddonsTextY += 2;
                arcWidth -= 8;
                break;
            case Constants.venudPartNumber:
                mainTimerX -= 18;
                mainTimerMsY -= 4;
                gameActiveAddonsTextY += 2;
                arcWidth -= 12;
                break;
            case Constants.vivoactive4PartNumber:
            case Constants.vivoactive4sPartNumber:
                mainTimerX -= 8;
                mainTimerMsX -= 3;
                mainTimerMsY -= 4;
                gameActiveAddonsTextY += 2;
                arcWidth -= 12;
                break;
            case Constants.vivoactive5PartNumber:
                mainTimerX -= 12;
                mainTimerMsX -= 32;
                mainTimerMsY -= 14;
                arcWidth -= 6;
                break;
            case Constants.marq2PartNumber:
            case Constants.marq2aPartNumber:
            case Constants.marqadenturerPartNumber:
            case Constants.marqathletePartNumber:
            case Constants.marqaviatorPartNumber:
            case Constants.marqcaptainPartNumber:
            case Constants.marqcommanderPartNumber:
            case Constants.marqdriverPartNumber:
            case Constants.marqexpeditionPartNumber:
            case Constants.marqgolferPartNumber:
                mainTimerMsX += 2;
                mainTimerMsY += 2;
                gameActiveAddonsTextY += 2;
                idleTextHeight += 1;
            case Constants.enduroPartNumber:
                heightOver6AndAHalf = (centerX / 4).toNumber();
                mainTimerX -= 12;
                mainTimerMsX -= 26;
                mainTimerMsY -= 12;
                idleTextHeight -= 1;
                arcWidth = dc.getWidth() / 14;
                break;
            case Constants.sagareyPartNumber:
            case Constants.darthvaderPartNumber:
            case Constants.captainmarvelPartNumber:
            case Constants.firstavengerPartNumber:
                mainTimerX   -= 5;
                mainTimerMsY -= 4;
                arcWidth /= 2;
            default:
                break;
            // I am now suicidal.
        }
        */
    }

    function onShow() as Void {
        if(Globals.settingChanged) {
            if(Globals.hasStorage) {
                if(!Disk.getValue("legacyView")) {
                    Ui.switchToView(new $.RapidView(), new $.RapidDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
                    return;
                }
            } else if(!Globals.useLegacyView) {
                Ui.switchToView(new $.RapidView(), new $.RapidDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
                return;
            }
            
            Globals.haptics = Disk.getValue("haptics");
            isBacklightOn = Disk.getValue("backlight");
            progressRing = Disk.getValue("progressRing");
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

        dc.drawLine(
            centerX,
            0,
            centerX,
            dc.getHeight()
        );

        dc.drawLine(
            0,
            centerY,
            dc.getWidth(),
            centerY
        );

        dc.drawLine(
            dc.getWidth() - dc.getWidth() / 8,
            0,
            dc.getWidth() - dc.getWidth() / 8,
            dc.getHeight()
        );

        dc.drawLine(
            dc.getWidth() / 8,
            0,
            dc.getWidth() / 8,
            dc.getHeight()
        );

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


        if(System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE && !isWatch) {
            dc.drawText(
                centerX,
                onePlusQuarterHeight,
                Graphics.FONT_SYSTEM_MEDIUM,
                "Switch Sides  Reset",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        } else {
            dc.drawText(
                centerX,
                onePlusHalfHeight,
                Graphics.FONT_SYSTEM_LARGE,
                loadResource(Strings.switch_sides),
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }

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
            gameActiveAddonsRect1,
            dc.getWidth(),
            heightOver8
        );

        reverseColors(dc);

        if(Globals.isWhitesTurn) {
            var font = Graphics.FONT_TINY;
            if(System.getDeviceSettings() has :systemLanguage && System.getDeviceSettings().systemLanguage == System.LANGUAGE_SPA) {
                font = Graphics.FONT_XTINY;
            }
            
            dc.drawText(
                widthOver1_9,
                gameActiveAddonsTextY,
                font,
                loadResource(Strings.black_time_no_space),
                Graphics.TEXT_JUSTIFY_VCENTER
            );
            

            var mins = (Globals.blackTimeLeft / 60000).toNumber();
            var secs = ((Globals.blackTimeLeft / 1000) % 60).toNumber();
            var ms   = (Globals.blackTimeLeft % 1000).toNumber();

            minsStr = mins < 10 ? "0" + mins : mins.toString();
            secsStr = secs < 10 ? "0" + secs : secs.toString();
            msStr   = ms   < 10 ? "0" + ms   : (ms >= 100 ? ms / 10 : ms.toString());

            if(!(Globals.uninterestingCountingVariable >= 3 && Globals.uninterestingCountingVariable <= 6) &&
               !(Globals.uninterestingCountingVariable >= 9 && Globals.uninterestingCountingVariable <= 12)) {
                dc.drawText(
                    gameActiveAddonsTextX,
                    gameActiveAddonsTextY,
                    Graphics.FONT_TINY,
                    minsStr + ":" + secsStr + loadResource(Strings.decimal_separator) + msStr,
                    Graphics.TEXT_JUSTIFY_VCENTER
                );
            }
        } else {
            var font = Graphics.FONT_TINY;
            if(System.getDeviceSettings() has :systemLanguage && System.getDeviceSettings().systemLanguage == System.LANGUAGE_SPA) {
                font = Graphics.FONT_XTINY;
            }

            if(!tooBig) {
                dc.drawText(
                    widthOver1_9,
                    gameActiveAddonsTextY,
                    font,
                    loadResource(Strings.white_time_no_space),
                    Graphics.TEXT_JUSTIFY_VCENTER
                );
            }
            

            var mins = (Globals.whiteTimeLeft / 60000).toNumber();
            var secs = ((Globals.whiteTimeLeft / 1000) % 60).toNumber();
            var ms   = (Globals.whiteTimeLeft % 1000).toNumber();

            minsStr = mins < 10 ? "0" + mins : mins.toString();
            secsStr = secs < 10 ? "0" + secs : secs.toString();
            msStr   = ms   < 10 ? "0" + ms   : (ms >= 100 ? ms / 10 : ms.toString());

            if(!(Globals.uninterestingCountingVariable >= 3 && Globals.uninterestingCountingVariable <= 6) &&
               !(Globals.uninterestingCountingVariable >= 9 && Globals.uninterestingCountingVariable <= 12)) {
                dc.drawText(
                    gameActiveAddonsTextX,
                    gameActiveAddonsTextY,
                    Graphics.FONT_TINY,
                    minsStr + ":" + secsStr + loadResource(Strings.decimal_separator) + msStr,
                    Graphics.TEXT_JUSTIFY_VCENTER
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
            0,
            (dc.getHeight() - Graphics.getFontHeight(mainNumberFont)) / 2 - Graphics.getFontDescent(mainNumberFont),
            dc.getWidth() / 2.5 + Graphics.getFontAscent(Graphics.FONT_TINY),
            Graphics.getFontHeight(Graphics.FONT_TINY),
            Graphics.getFontHeight(Graphics.FONT_TINY) / 2
        );

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        dc.drawText(
            dc.getWidth() / 2.5,
            (dc.getHeight() - Graphics.getFontHeight(mainNumberFont)) / 2 - Graphics.getFontDescent(mainNumberFont),
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
        var msStr   = ms   < 10 ? "0" + ms   : (ms >= 100 ? ms / 10 : ms.toString());

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
        var smallNumberFont = Graphics.FONT_TINY;

        dc.drawText(
            (dc.getWidth() - dc.getWidth() / 20) - dc.getTextWidthInPixels(loadResource(Strings.decimal_separator) + millisecondsLeft, smallNumberFont),
            centerY,
            mainNumberFont,
            minutesLeft + ":" + secondsLeft,
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.drawText(
            dc.getWidth() - dc.getWidth() / 20, // TODO: CHANGE TO ACCOUNT FOR RING
            dc.getHeight() / 2 - dc.getFontHeight(smallNumberFont) + Graphics.getFontDescent(smallNumberFont) + dc.getFontHeight(mainNumberFont) / 2 - Graphics.getFontDescent(mainNumberFont),
            Graphics.FONT_TINY,
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
            Graphics.FONT_TINY,
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
                (dc.getHeight() - Graphics.getFontHeight(mainNumberFont)) / 4 - 2, // - 2 accounts for cutoff
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
