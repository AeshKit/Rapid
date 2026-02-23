import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;

import Globals;
import Constants;
import Rez.Strings;

using Toybox.Application.Storage as Disk;
using Toybox.WatchUi as Ui;

class RapidView extends Ui.View {

    var isBacklightOn as Boolean = Disk.getValue("backlight");
    var progressRing as Boolean = Disk.getValue("progressRing");

    var whiteMinutesLeft, blackMinutesLeft;
    var whiteSecondsInMinuteLeft, blackSecondsInMinuteLeft;
    var whiteMillisecondsLeft, blackMillisecondsLeft;

    var timeChangePreviousValue as Integer = 0;

    var timerVectorFont, switchSidesVectorFont,
        timerMillisecondsVectorFont, timerSecondsOnlyVectorFont,
        flashingStringVectorFont, otherSideTimeLeftTextVectorFont,
        otherSideTimeLeftVectorFont;
        
    var minsStr, secsStr, msStr;

    var displayOnlySeconds as Boolean = false;

    var vectorSize =               (System.getDeviceSettings().screenHeight / 2.3).toNumber();
    var vectorMillisecondSize =    (System.getDeviceSettings().screenHeight / 5).toNumber();
    var vectorSecondsOnlySize =    (System.getDeviceSettings().screenHeight / 1.8).toNumber();
    var vectorSwitchSidesSize =    (System.getDeviceSettings().screenHeight / 7).toNumber();
    var vectorFlashingStringSize = (System.getDeviceSettings().screenHeight / 7.5).toNumber();
    var otherSideTimeSize =        (System.getDeviceSettings().screenHeight / 9).toNumber();
    var otherSideTimeSizeText = otherSideTimeSize;

    var centerX as Number = 0,
        centerY as Number = 0,
        widthOverOneFiveFive as Number = 0,
        widthOverOneAndAQuarter as Number = 0,
        widthOverThreeAndAQuarter as Number = 0,
        widthOverTen as Number = 0,
        heightOverFiveFive as Number = 0,
        heightOverThreeFive as Number = 0,
        heightOverThreeFour as Number = 0,
        heightOverOneNine as Number = 0,
        heightOverSevenAndThreeQuarters as Number = 0,
        vectorTimeFullWidth as Number = 0,
        vectorTimeSecondsMsWidth as Number = 0,
        gameActiveAddonsRectangleWidth as Number = 0,
        gameActiveAddonsTextWidth as Number = 0,
        gameIdleAddons1 as Number = 0,
        gameIdleAddons2 as Number = 0,
        gameIdleAddons3 as Number = 0,
        gameIdleAddons4 as Number = 0,
        gameIdleAddons5 as Number = 0,
        gameIdleAddons6 as Number = 0,
        arcwidth as Number = 0;

    function initialize() {
        Globals.haptics = Disk.getValue("haptics");
        Globals.animationTimer = new Timer.Timer();   
        View.initialize();
    }

    function onLayout(dc) as Void {
        if(System.getDeviceSettings() has :systemLanguage && System.getDeviceSettings().systemLanguage == System.LANGUAGE_SPA) {
            vectorSwitchSidesSize = (System.getDeviceSettings().screenHeight / 8).toNumber();
            vectorFlashingStringSize = (System.getDeviceSettings().screenHeight / 9.5).toNumber();
            otherSideTimeSizeText = (System.getDeviceSettings().screenHeight / 11).toNumber();
        }

        // Support for older watches, like the Fenix 7 series, which can render vector fonts but can't scale them.
        if(Lang.format("$1$2", System.getDeviceSettings().monkeyVersion).toNumber() > 52) {
            flashingStringVectorFont = Graphics.getVectorFont( {
                :font => Graphics.FONT_SYSTEM_MEDIUM,
                :scale => .9
            });
        } else {
            flashingStringVectorFont = Graphics.getVectorFont( {
                :face => ["RobotoBlack", "RobotoCondensedBold", "BionicBold", "NotoNaskhArabicBold"],
                :size => vectorFlashingStringSize
            });

            vectorMillisecondSize = (dc.getHeight() / 7).toNumber();
        }

        if(System.getDeviceSettings().partNumber.equals(Constants.fenix8solar51mmPartNumber)) {
            vectorSize = (dc.getHeight() / 2.1).toNumber();
        }

        timerVectorFont = Graphics.getVectorFont( {
            :face => ["BionicBoldNumberOnly", "BionicBold", "TomorrowBold", "ExoSemiBold", "PrimiSemiBold", "GarminRobotoBold", "NotoSansArmenianBold", "NotoSansHebrewBold"],
            :size => vectorSize
        });

        timerMillisecondsVectorFont = Graphics.getVectorFont( {
            :face => ["NotoNaskhArabicBold", "RobotoCondensedBold", "RobotoBlack", "BionicBold"],
            :size => vectorMillisecondSize
        });

        switchSidesVectorFont = Graphics.getVectorFont( {
            :face => ["RobotoBlack", "RobotoCondensedBold", "BionicBold", "NotoNaskhArabicBold"],
            :size => vectorSwitchSidesSize
        });

        timerSecondsOnlyVectorFont = Graphics.getVectorFont( {
            :face => ["BionicBoldNumberOnly", "BionicBold", "RobotoCondensedBold", "RobotoBlack", "NotoNaskhArabicBold"],
            :size => vectorSecondsOnlySize
        });

        otherSideTimeLeftTextVectorFont = Graphics.getVectorFont( {
            :face => ["BionicBold", "TomorrowBold", "ExoSemiBold", "PrimiSemiBold", "GarminRobotoBold", "NotoSansArmenianBold", "NotoSansHebrewBold"],
            :size => otherSideTimeSizeText
        });

        otherSideTimeLeftVectorFont = Graphics.getVectorFont( {
            :face => ["BionicBoldNumbersOnly", "BionicBold", "TomorrowBold", "ExoSemiBold", "PrimiSemiBold", "GarminRobotoBold", "NotoSansArmenianBold", "NotoSansHebrewBold"],
            :size => otherSideTimeSize
        });

        // Doing tons of division every frame is kinda slow
        // .toNumber() is to ensure that they are not stored as methods
        centerX = (dc.getWidth() / 2).toNumber();
        centerY = (dc.getHeight() / 2).toNumber();

        widthOverTen =              (dc.getWidth() / 10).toNumber();
        widthOverOneAndAQuarter =   (dc.getWidth() / 1.25).toNumber();
        widthOverOneFiveFive =      (dc.getWidth() / 1.55).toNumber();
        widthOverThreeAndAQuarter = (dc.getWidth() / 3.25).toNumber();

        heightOverFiveFive =  (dc.getHeight() / 5.5).toNumber();
        heightOverOneNine =   (dc.getHeight() / 1.9).toNumber();
        heightOverThreeFive = (dc.getHeight() / 3.5).toNumber();
        heightOverThreeFour = (dc.getHeight() / 3.4).toNumber();
        heightOverSevenAndThreeQuarters = (dc.getHeight() / 7.75).toNumber();

        vectorTimeFullWidth =      (dc.getWidth() / 2 + (vectorSize / 4.45)).toNumber();
        vectorTimeSecondsMsWidth = (dc.getWidth() / 2 + (vectorSize / 3.6)).toNumber();

        gameActiveAddonsRectangleWidth = (dc.getWidth() - dc.getWidth() / 2.8).toNumber();
        gameActiveAddonsTextWidth =      (dc.getWidth() - dc.getWidth() / 2.8 + (dc.getWidth() / 10) / 2).toNumber();

        gameIdleAddons1 = (dc.getWidth() / 3.95).toNumber();
        gameIdleAddons2 = (dc.getHeight() / 1.85).toNumber();
        gameIdleAddons3 = (dc.getWidth() / 12).toNumber();
        gameIdleAddons4 = (dc.getHeight() / 28).toNumber();
        gameIdleAddons5 = (dc.getWidth() / 3.095).toNumber();
        gameIdleAddons6 = (dc.getHeight() / 1.7).toNumber();

        arcwidth = (dc.getWidth() / 24).toNumber();

        if(System.getDeviceSettings().partNumber.equals(Constants.fenix8solar47mmPartNumber) || System.getDeviceSettings().partNumber.equals(Constants.fenix8solar51mmPartNumber)) {
            vectorTimeFullWidth += 8;
        }
    }

    function onShow() as Void {
        if(Globals.settingChanged) {
            if(Disk.getValue("legacyView")) {
                Ui.switchToView(new $.RapidLegacyView(), new $.RapidLegacyDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
            }

            Globals.haptics = Disk.getValue("haptics");
            isBacklightOn = Disk.getValue("backlight");
            progressRing = Disk.getValue("progressRing");
        }
    }

    function onUpdate(dc) as Void {
        if(isBacklightOn) {
            Attention.backlight(true);
        }

        if(Globals.gameStarted) {
            handleTimerDrawingAndChecks(dc);
            if(progressRing) { drawProgressRing(dc); }
            gameActiveAddons(dc);
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
        
        if(Globals.isDragging) {
            draggingDrawEvent(dc);
            return;
        }
        
        if(Globals.hasGameBeenStopped) {
            drawGameStoppedScreen(dc);
            return;
        }
        
        handleTimerDrawingAndChecks(dc);
        gameIdleAddons(dc);
    }

    function onHide() as Void {
    }

    function drawGameStoppedScreen(dc) {
        handleTimerDrawingAndChecks(dc);

        dc.fillRectangle(
            widthOverOneFiveFive,
            0,
            centerX,
            dc.getHeight()
        );

        reverseColors(dc);

        dc.drawAngledText(
            widthOverOneAndAQuarter,
            centerY,
            switchSidesVectorFont,
            loadResource(Strings.switch_sides),
            Graphics.TEXT_JUSTIFY_CENTER,
            90
        );
    }

    function drawProgressRing(dc) as Void {

        var angle = Globals.isWhitesTurn ?
        (360.0 * (Globals.whiteTimeLeft.toFloat() / ((Globals.startingTimeInSeconds + Globals.whiteIncrement).toFloat() * 1000.0))) - 180.0:
        (360.0 * (Globals.blackTimeLeft.toFloat() / ((Globals.startingTimeInSeconds + Globals.blackIncrement).toFloat() * 1000.0))) - 180.0;

        if(angle > 180) { angle = 180; }

        dc.setPenWidth(arcwidth);

        dc.drawArc(
            centerX,
            centerY,
            centerX,
            Graphics.ARC_CLOCKWISE,
            angle,
            180
        );

        dc.setPenWidth(1);
    }

    function draggingDrawEvent(dc) {
        return Globals.isDragVertical ? handleTimerTimeChange(dc) : handleTimerIncrementChange(dc);
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

        drawVectorTimerFlashingString(dc, label, flashingStringVectorFont);
        drawVectorTimerSeconds(dc, "+" + Globals.incrementHoldingVar, 0);
    }

    function handleTimerTimeChange(dc) {
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

        drawVectorTimerFlashingString(dc, label, switchSidesVectorFont);

        if(!displayOnlySeconds) {
            drawVectorTimerFull(dc, whiteMinutesLeft, whiteSecondsInMinuteLeft, whiteMillisecondsLeft);
        } else {
            drawVectorTimerSeconds(dc, whiteSecondsInMinuteLeft, whiteMillisecondsLeft);
        }
    }


    function handleTimerDrawingAndChecks(dc) as Void {
        var currentTime = Globals.isWhitesTurn ? Globals.whiteTimeLeft : Globals.blackTimeLeft;
        var mins = (currentTime / 60000).toNumber();
        var secs = ((currentTime / 1000) % 60).toNumber();
        var ms   = (currentTime % 1000).toNumber();

        minsStr = mins < 10 ? "0" + mins : mins.toString();
        secsStr = secs < 10 ? "0" + secs : secs.toString();
        msStr   = ms   < 10 ? "0" + ms   : (ms < 100 ? "0" + ms / 10 : ms / 10);

        displayOnlySeconds = currentTime < 60000;

        decideColors(dc);
        dc.clear();

        if(!displayOnlySeconds) {
            drawVectorTimerFull(dc, minsStr, secsStr, msStr);
        } else {
            drawVectorTimerSeconds(dc, secsStr, msStr);
        }
    }

    function drawVectorTimerFull(dc, minutesLeft, secondsLeft, millisecondsLeft) {
        dc.drawAngledText(
            centerX,
            heightOverFiveFive,
            timerVectorFont,
            minutesLeft + ":" + secondsLeft,
            Graphics.TEXT_JUSTIFY_VCENTER,
            90
        );

        dc.drawAngledText(
            vectorTimeFullWidth,
            heightOverFiveFive,
            timerMillisecondsVectorFont,
            loadResource(Strings.decimal_separator) + millisecondsLeft,
            Graphics.TEXT_JUSTIFY_LEFT,
            90
        );
    }

    function drawVectorTimerSeconds(dc, secondsLeft, millisecondsLeft) {
        dc.drawAngledText(
            centerX,
            heightOverThreeFive,
            timerSecondsOnlyVectorFont,
            secondsLeft,
            Graphics.TEXT_JUSTIFY_VCENTER,
            90
        );

        dc.drawAngledText(
            vectorTimeSecondsMsWidth,
            heightOverThreeFour,
            timerMillisecondsVectorFont,
            loadResource(Strings.decimal_separator) + millisecondsLeft,
            Graphics.TEXT_JUSTIFY_LEFT,
            90
        );
    }

    function drawVectorTimerFlashingString(dc as Dc, string as String, font as VectorFont) {
        if(!Globals.hasAnimationTimerStarted) {
            Globals.drawString = true;
            Globals.animationTimer.start(method(:incrementDrawStringState), 50, true);
            Globals.hasAnimationTimerStarted = true;
        }

        if(Globals.drawString) {
            dc.drawAngledText(
                widthOverThreeAndAQuarter,
                centerY,
                font,
                string,
                Graphics.TEXT_JUSTIFY_CENTER,
                90
            );
        }
    }

    function gameActiveAddons(dc) {
        dc.fillRectangle(
            gameActiveAddonsRectangleWidth,
            0,
            widthOverTen,
            dc.getHeight()
        );

        reverseColors(dc);

        if(Globals.isWhitesTurn) {
            dc.drawAngledText(
                gameActiveAddonsTextWidth,
                heightOverOneNine,
                otherSideTimeLeftTextVectorFont,
                loadResource(Strings.black_time_no_space),
                Graphics.TEXT_JUSTIFY_VCENTER,
                90
            );

            var mins = (Globals.blackTimeLeft / 60000).toNumber();
            var secs = ((Globals.blackTimeLeft / 1000) % 60).toNumber();
            var ms   = (Globals.blackTimeLeft % 1000).toNumber();

            minsStr = mins < 10 ? "0" + mins : mins.toString();
            secsStr = secs < 10 ? "0" + secs : secs.toString();
            msStr   = ms   < 10 ? "0" + ms   : (ms < 100 ? "0" + ms / 10 : ms / 10);

            if(!(Globals.uninterestingCountingVariable >= 3 && Globals.uninterestingCountingVariable <= 6) &&
               !(Globals.uninterestingCountingVariable >= 9 && Globals.uninterestingCountingVariable <= 12)) {
                dc.drawAngledText(
                    gameActiveAddonsTextWidth,
                    heightOverSevenAndThreeQuarters,
                    otherSideTimeLeftVectorFont,
                    minsStr + ":" + secsStr + loadResource(Strings.decimal_separator) + msStr,
                    Graphics.TEXT_JUSTIFY_VCENTER,
                    90
                );
            }
        } else {
            dc.drawAngledText(
                gameActiveAddonsTextWidth,
                heightOverOneNine,
                otherSideTimeLeftTextVectorFont,
                loadResource(Strings.white_time_no_space),
                Graphics.TEXT_JUSTIFY_VCENTER,
                90
            );

            var mins = (Globals.whiteTimeLeft / 60000).toNumber();
            var secs = ((Globals.whiteTimeLeft / 1000) % 60).toNumber();
            var ms   = (Globals.whiteTimeLeft % 1000).toNumber();

            minsStr = mins < 10 ? "0" + mins : mins.toString();
            secsStr = secs < 10 ? "0" + secs : secs.toString();
            msStr   = ms   < 10 ? "0" + ms   : (ms < 100 ? "0" + ms / 10 : ms / 10);

            if(!(Globals.uninterestingCountingVariable >= 3 && Globals.uninterestingCountingVariable <= 6) &&
               !(Globals.uninterestingCountingVariable >= 9 && Globals.uninterestingCountingVariable <= 12)) {
                dc.drawAngledText(
                    gameActiveAddonsTextWidth,
                    heightOverSevenAndThreeQuarters,
                    otherSideTimeLeftVectorFont,
                    minsStr + ":" + secsStr + loadResource(Strings.decimal_separator) + msStr,
                    Graphics.TEXT_JUSTIFY_VCENTER,
                    90
                );
            }
        }
    }

    function gameIdleAddons(dc) {
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_LT_GRAY);

        dc.fillRoundedRectangle(
            gameIdleAddons1,
            gameIdleAddons2,
            gameIdleAddons3,
            dc.getHeight() ,
            gameIdleAddons4
        );

        decideColors(dc);

        whiteMinutesLeft = ((Globals.whiteTimeLeft - Globals.whiteIncrement * 1000) / 60000).toNumber();
        whiteSecondsInMinuteLeft = (((Globals.whiteTimeLeft - Globals.whiteIncrement * 1000) / 1000) % 60).toNumber();
        if(whiteSecondsInMinuteLeft != 0) {
            secsStr = ":" + whiteSecondsInMinuteLeft;
        } else { secsStr = ""; }

        dc.drawAngledText(
            gameIdleAddons5,
            gameIdleAddons6,
            otherSideTimeLeftVectorFont,
            whiteMinutesLeft.toString() + secsStr + "+" + Globals.whiteIncrement,
            Graphics.TEXT_JUSTIFY_RIGHT,
            90
        );
    }

    function decideColors(dc) {
        dc.setColor(Globals.isWhitesTurn ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE,
                    Globals.isWhitesTurn ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK);
    }

    function reverseColors(dc) {
        dc.setColor(Globals.isWhitesTurn ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK,
                    Globals.isWhitesTurn ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE);
    }

    function incrementDrawStringState() as Void {
        Globals.interestingCountingVariable++;
        if(Globals.interestingCountingVariable % 30 > 15) {
            Globals.drawString = false;
        } else {Globals.drawString = true; }
        Ui.requestUpdate();
    }
}
