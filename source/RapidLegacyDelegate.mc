import Toybox.Lang;
import Toybox.Math;
import Toybox.Timer;
import Toybox.Attention;

import Rez.Strings;
import Globals;
import Constants;

using Toybox.Application.Storage as Disk;
using Toybox.WatchUi as Ui;

class RapidLegacyDelegate extends Ui.BehaviorDelegate {

    var startX, endX;
    var startY, endY;
    var swipeThreshold = 10;

    var backTimer;
    var backTimerActive = false;
    var backVibeProfile;

    var hapticDelayCounter as Number = 0;

    var timeThen;
    var sideTimeThenWhite;
    var sideTimeThenBlack;
    var timeNow = 0;
    var timeDelta = 0;
    var totalTimeTemp;

    var screenHeight as Number;
    var screenHeightOver60 as Number;
    var screenHeightOver10 as Number;
    var halfScreenHeight as Number;
    var halfScreenWidth as Number;
    var screenWidthOver155;

    var view;
    var timer;

    function initialize(rapidView) {
        timer = new Timer.Timer();
        backTimer = new Timer.Timer();

        screenHeight = System.getDeviceSettings().screenHeight.toNumber();
        screenHeightOver10 = (screenHeight / 10).toNumber();
        screenHeightOver60 = (screenHeight / 60).toNumber();
        screenWidthOver155 = (System.getDeviceSettings().screenWidth / 1.55).toNumber();
        halfScreenHeight = (System.getDeviceSettings().screenHeight / 2).toNumber();
        halfScreenWidth = (System.getDeviceSettings().screenWidth / 2).toNumber();

        if(Attention has :VibeProfile) {
            backVibeProfile = [ new Attention.VibeProfile(100, 15) ];
        }

        Globals.whiteTimeLeft = (Globals.startingTimeInSeconds + Globals.whiteIncrement) * 1000;
        Globals.blackTimeLeft = (Globals.startingTimeInSeconds + Globals.blackIncrement) * 1000;
        sideTimeThenWhite = Globals.whiteTimeLeft;

        Ui.BehaviorDelegate.initialize();
        view = rapidView;
    }

    function onMenu() as Boolean {
        if(Globals.hasStorage) {
            if(!Disk.getValue("legacyMenu") || Disk.getValue("legacyMenu") == null) {
                drawModernMenu();
            }
            else { drawLegacyMenu(); }
            return true;
        }

        if(Globals.drawModernMenu) {
            drawModernMenu();
            return true;
        }
        drawLegacyMenu();
        return true;
    }

    function drawModernMenu() {
        var menu = new Ui.Menu2({:title=>loadResource(Strings.app_name)});

        menu.addItem(
            new MenuItem(
                loadResource(Strings.settings),
                loadResource(Strings.opens_settings_menu),
                :sm,
                {}
            )
        );

        if(Globals.hasGameBeenStopped) {
                menu.addItem(
                    new MenuItem(
                        loadResource(Strings.white_time_setting),
                        "",
                        :wt,
                        {}
                    )
                );
                menu.addItem(
                    new MenuItem(
                        loadResource(Strings.white_increment_setting),
                        "",
                        :wi,
                        {}
                    )
                );
                menu.addItem(
                    new MenuItem(
                        loadResource(Strings.black_time_setting),
                        "",
                        :bt,
                        {}
                    )
                );
                menu.addItem(
                    new MenuItem(
                        loadResource(Strings.black_increment_setting),
                        "",
                        :bi,
                        {}
                    )
                );
            } else {
                menu.addItem(
                    new MenuItem(
                        loadResource(Strings.starting_time_setting),
                        loadResource(Strings.change_starting_time),
                        :st,
                        {}
                    )
                );
                menu.addItem(
                    new MenuItem(
                        loadResource(Strings.increment_setting),
                        loadResource(Strings.change_increment),
                        :si,
                        {}
                    )
                );
            }
            menu.addItem(
                new MenuItem(
                    loadResource(Strings.kill_app),
                    "",
                    :ex,
                    {}
                )
            );
            
        Ui.pushView(menu, new $.RapidMenuDelegate(), Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function drawLegacyMenu() {
        var menu = new WatchUi.Menu();
        var delegate = new LegacySettingsDelegate();

        menu.setTitle(loadResource(Strings.app_name));

        if(Globals.hasGameBeenStopped) {
            menu.addItem(loadResource(Strings.white_time_setting), :wt);
            menu.addItem(loadResource(Strings.white_increment_short), :wi);
            menu.addItem(loadResource(Strings.black_time_setting), :bt);
            menu.addItem(loadResource(Strings.black_increment_short), :bi);
        } else {
            menu.addItem(loadResource(Strings.starting_time_setting), :st);
            menu.addItem(loadResource(Strings.starting_increment_short), :si);
        }
        if(Attention has :vibrate) {
            menu.addItem(
                Disk.getValue("haptics") ?
                loadResource(Strings.haptics_on) : loadResource(Strings.haptics_off), :hp
            );
        }
        menu.addItem(Disk.getValue("backlight") == true ?
        loadResource(Strings.backlight_on) : loadResource(Strings.backlight_off), :bk);
        if(Graphics.Dc has :drawArc) {
            menu.addItem(Disk.getValue("progressRing") == true ?
            loadResource(Strings.ring_on) : loadResource(Strings.ring_off), :pr);
        }
        menu.addItem(loadResource(Strings.use_modern_menu), :mn);
        menu.addItem(Disk.getValue("legacyView") ?
        loadResource(Strings.modern_view_off) : loadResource(Strings.modern_view_on), :cv);
        menu.addItem(loadResource(Strings.kill_app), :ex);
        

        Ui.pushView(menu, delegate, Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onTap(clickEvent) {
        if(Globals.changingStartingTimeWithButton && Ui.BehaviorDelegate has :onDrag) {
            handleHorizontalDragStop();
            Globals.changingStartingTimeWithButton = false;
            return true;
        }

        if(Globals.changingIncrementWithButton && Ui.BehaviorDelegate has :onDrag) {
            handleVerticalDragStop();
            Globals.changingIncrementWithButton = false;
            return true;
        }

        if(Globals.hasGameBeenStopped && clickEvent.getCoordinates()[1] > screenWidthOver155) {
            Globals.isWhitesTurn = !Globals.isWhitesTurn;
            Ui.requestUpdate();
            return true;
        }

        if(Globals.gameStarted) {
            changeSidesAndAddIncrement();
            return true;
        }

        if(!(Ui.BehaviorDelegate has :onDrag) && Globals.hasGameBeenStopped) {
            startTimer();
            return true;
        }

        if(!(Ui.BehaviorDelegate has :onDrag)) {

            if(!Globals.changingStartingTimeWithButton && !Globals.changingIncrementWithButton) {
                handleSideDetection(clickEvent.getCoordinates());
                return true;
            }

            if(Globals.changingStartingTimeWithButton) {
                if(clickEvent.getCoordinates()[0] < halfScreenWidth) {
                    Globals.startingTimeHoldingVar -= 15000;
                    if(Globals.startingTimeHoldingVar <  15000) {
                        Globals.startingTimeHoldingVar = 15000;
                    }
                    Ui.requestUpdate();
                    return true;
                } else {
                    Globals.startingTimeHoldingVar += 15000;
                    if(Globals.startingTimeHoldingVar >  5999999) {
                        Globals.startingTimeHoldingVar = 5999999;
                    }
                    Ui.requestUpdate();
                    return true;
                }
            }

            if(Globals.changingIncrementWithButton) {
                if(clickEvent.getCoordinates()[1] > halfScreenHeight) {
                    Globals.incrementHoldingVar--;
                    if(Globals.incrementHoldingVar <  0) {
                        Globals.incrementHoldingVar = 0;
                    }
                    Ui.requestUpdate();
                    return true;
                } else {
                    Globals.incrementHoldingVar++;
                    if(Globals.incrementHoldingVar >  30) {
                        Globals.incrementHoldingVar = 30;
                    }
                    Ui.requestUpdate();
                    return true;
                }
            }
        }

        startTimer();
        return true;
    }

    function handleSideDetection(clickEvent as Array) as Void {
        if((clickEvent[0] - (halfScreenWidth)).abs() > (clickEvent[1] - (halfScreenHeight)).abs()) {
            if(clickEvent[0] < halfScreenWidth) {
                Globals.changingStartingTimeWithButton = true;
                Globals.startingTimeHoldingVar = (Globals.startingTimeInSeconds * 1000) - 15000;
                if(Globals.startingTimeHoldingVar <  15000) {
                    Globals.startingTimeHoldingVar = 15000;
                }
                Ui.requestUpdate();
                return;
            } else {
                Globals.changingStartingTimeWithButton = true;
                Globals.startingTimeHoldingVar = (Globals.startingTimeInSeconds * 1000) + 15000;
                if(Globals.startingTimeHoldingVar >  5999999) {
                    Globals.startingTimeHoldingVar = 5999999;
                }
                Ui.requestUpdate();
                return;
            }
        } else {
            if(clickEvent[1] > halfScreenHeight) {
                Globals.changingIncrementWithButton = true;
                Globals.incrementHoldingVar = Globals.whiteIncrement - 1;
                if(Globals.incrementHoldingVar <  0) {
                    Globals.incrementHoldingVar = 0;
                }
                Ui.requestUpdate();
                return;
            } else {
                Globals.changingIncrementWithButton = true;
                Globals.incrementHoldingVar = Globals.whiteIncrement + 1;
                if(Globals.incrementHoldingVar >  30) {
                    Globals.incrementHoldingVar = 30;
                }
                Ui.requestUpdate();
                return;
            }
        }
    }

    function onDrag(dragEvent) {
        if(!Globals.gameStarted) {
            switch(dragEvent.getType()) {
                case 0: // New tap
                    Globals.isDragging = true;
                    startX = dragEvent.getCoordinates()[0];
                    startY = dragEvent.getCoordinates()[1];
                    if(Globals.changingIncrementWithButton) {
                        Globals.whiteIncrement = Globals.incrementHoldingVar;
                        Globals.blackIncrement = Globals.incrementHoldingVar;
                    } else if(Globals.changingStartingTimeWithButton) {
                        Globals.startingTimeInSeconds = Globals.startingTimeHoldingVar / 1000;
                    } else if(Globals.changingSideWithButton != 'n') {
                        if(Globals.changingSideWithButton == 'w') {
                            Globals.whiteTimeLeft = Globals.changingTimeHoldingVar;
                        } else { Globals.blackTimeLeft = Globals.changingTimeHoldingVar; }
                    }
                    break;
                case 1: // Dragging

                    var deltaX = (dragEvent.getCoordinates()[0] - startX).toNumber();
                    var deltaY = (startY - dragEvent.getCoordinates()[1]).toNumber();
                    switch(Globals.axis) {
                        case "N":
                            var absX = deltaX.abs();
                            var absY = deltaY.abs();
                            if(absX > swipeThreshold || absY > swipeThreshold) {
                                if(absX > absY) {
                                    Globals.axis = "X";
                                    Globals.isDragVertical = false;
                                    if(Globals.changingIncrementWithButton) {
                                        Globals.axis = "N";
                                        Globals.isDragging = false;
                                        break;
                                    }
                                } else {
                                    Globals.axis = "Y";
                                    Globals.isDragVertical = true;
                                    if(Globals.changingSideWithButton != 'n' || Globals.changingStartingTimeWithButton) {
                                        Globals.axis = "N";
                                        Globals.isDragging = false;
                                        Globals.incrementHoldingVar = Globals.whiteIncrement;
                                        break;
                                    }
                                }
                                Ui.requestUpdate();
                            }
                            break;
                        case "X":
                            if(!Globals.hasGameBeenStopped) {
                                Globals.startingTimeHoldingVar = (Globals.startingTimeInSeconds * 1000) + (deltaX / (screenHeightOver10)) * 15000;

                                if(Globals.startingTimeHoldingVar  < 15000) {
                                    Globals.startingTimeHoldingVar = 15000;
                                }

                                if(Globals.startingTimeHoldingVar >  5999999) {
                                    Globals.startingTimeHoldingVar = 5999999;
                                }
                                if(Globals.previousValue != Globals.startingTimeHoldingVar) {
                                    Globals.interestingCountingVariable = 0;
                                    Globals.previousValue = Globals.startingTimeHoldingVar.toNumber();
                                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                                }
                            } else {
                                var base = Globals.isWhitesTurn ? Globals.whiteTimeLeft : Globals.blackTimeLeft;
                                Globals.changingTimeHoldingVar = base + (deltaX / (screenHeightOver60)) * 5000;
                                
                                if(Globals.changingTimeHoldingVar  < 100) {
                                    Globals.changingTimeHoldingVar = 100;
                                } else

                                if(Globals.changingTimeHoldingVar  > 5999999) {
                                    Globals.changingTimeHoldingVar = 5999999;
                                }
                                if(Globals.previousValue != Globals.changingTimeHoldingVar) {
                                    Globals.interestingCountingVariable = 0;
                                    Globals.previousValue = Globals.changingTimeHoldingVar.toNumber();
                                    if(Attention has :vibrate && Globals.haptics) {
                                        hapticDelayCounter++;
                                        if(hapticDelayCounter == 2) {
                                            Attention.vibrate(backVibeProfile);
                                            hapticDelayCounter = 0;
                                        }
                                    }
                                }
                            }
                            break;
                        case "Y":
                            if(!Globals.hasGameBeenStopped || Globals.isWhitesTurn) {
                                Globals.incrementHoldingVar = Globals.whiteIncrement + deltaY / (screenHeightOver10);
                            } else {
                                Globals.incrementHoldingVar = Globals.blackIncrement + deltaY / (screenHeightOver10);
                            }
                            if(Globals.incrementHoldingVar < 0) { Globals.incrementHoldingVar = 0; }
                            if(Globals.incrementHoldingVar > 30) { Globals.incrementHoldingVar = 30; }
                            if(Globals.previousValue != Globals.incrementHoldingVar) {
                                Globals.interestingCountingVariable = 0;
                                Globals.previousValue = Globals.incrementHoldingVar.toNumber();
                                if(Attention has :vibrate) { Attention.vibrate(backVibeProfile); }
                            }
                            break;
                    }

                    break;
                case 2: // End drag
                    Globals.isDragging = false;
                    if(Globals.isDragVertical) { handleVerticalDragStop(); }
                    else { handleHorizontalDragStop(); }
                    Globals.animationTimer.stop();
                    Globals.hasAnimationTimerStarted = false;
                    Globals.axis = "N";
                    Ui.requestUpdate();
                    break;
            }
        } else if(dragEvent.getType() == 0) {
            changeSidesAndAddIncrement();
        }
        return true;
    }

    function handleVerticalDragStop() as Void {
        Globals.interestingCountingVariable = 0;
        if(!Globals.hasGameBeenStopped) {
            Globals.whiteIncrement = Globals.incrementHoldingVar;
            Globals.blackIncrement = Globals.incrementHoldingVar;
            Globals.whiteTimeLeft = (Globals.startingTimeInSeconds + Globals.whiteIncrement) * 1000;
            Globals.blackTimeLeft = (Globals.startingTimeInSeconds + Globals.blackIncrement) * 1000;
        } else if(Globals.isWhitesTurn) {
            Globals.whiteIncrement = Globals.incrementHoldingVar;
        } else {
            Globals.blackIncrement = Globals.incrementHoldingVar;
        }
    }

    function handleHorizontalDragStop() {
        Globals.interestingCountingVariable = 0;
        if(!Globals.hasGameBeenStopped) {
            Globals.startingTimeInSeconds = (Globals.startingTimeHoldingVar / 1000).toNumber();

            Globals.whiteTimeLeft = Globals.startingTimeHoldingVar;
            Globals.blackTimeLeft = Globals.startingTimeHoldingVar;
            Globals.whiteTimeLeft += Globals.whiteIncrement * 1000;
            Globals.blackTimeLeft += Globals.blackIncrement * 1000;

        } else if(Globals.isWhitesTurn) {
            Globals.whiteTimeLeft = Globals.changingTimeHoldingVar;
        } else {
            Globals.blackTimeLeft = Globals.changingTimeHoldingVar;
        }
    }

    function onKey(keyEvent as Ui.KeyEvent) as Boolean {
        switch(keyEvent.getKey()) {
            case Ui.KEY_ESC:
                if(Globals.changingStartingTimeWithButton) {
                    Globals.changingStartingTimeWithButton = false;
                    Ui.requestUpdate();
                    return true;
                }

                if(Globals.changingSideWithButton != 'n') {
                    Globals.changingSideWithButton = 'n';
                    Ui.requestUpdate();
                    return true;
                }

                if(Globals.changingIncrementWithButton) {
                    Globals.changingIncrementWithButton = false;
                    Ui.requestUpdate();
                    return true;
                }

                if(Globals.hasGameBeenStopped || Globals.gameStarted) {
                    stopTimer();
                    return true;
                }
                
                if(!backTimerActive) {
                    backTimerActive = true;

                    if(Attention has :vibrate) { Attention.vibrate(backVibeProfile); }

                    backTimer.start(method(:backTimerCallback), 750, false);
                    return true;
                }
                System.exit();
            case Ui.KEY_ENTER:
            case Ui.KEY_START:
                if(Globals.gameStarted) { changeSidesAndAddIncrement(); }
                else if(Globals.changingStartingTimeWithButton || Globals.changingSideWithButton != 'n') {
                    handleHorizontalDragStop();
                    Globals.changingStartingTimeWithButton = false;
                    Globals.changingSideWithButton = 'n';
                }
                else if(Globals.changingIncrementWithButton) {
                    handleVerticalDragStop();
                    Globals.changingIncrementWithButton = false;
                }
                else { startTimer(); }
                break;
            case Ui.KEY_DOWN:
                if(Globals.gameStarted) {
                    stopTimer();
                    Ui.requestUpdate();
                    return true;
                }
                
                if(Globals.hasGameBeenStopped && !Globals.changingStartingTimeWithButton && !Globals.changingIncrementWithButton && Globals.changingSideWithButton == 'n') {
                    Globals.isWhitesTurn = !Globals.isWhitesTurn;
                    Ui.requestUpdate();
                    return true;
                }
                
                if(!Globals.changingStartingTimeWithButton && !Globals.changingIncrementWithButton && Globals.changingSideWithButton == 'n') {
                    Globals.interestingCountingVariable = 0;
                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                    Globals.changingStartingTimeWithButton = true;
                    Globals.startingTimeHoldingVar = (Globals.startingTimeInSeconds * 1000) - 15000;
                    if(Globals.startingTimeHoldingVar <  15000) {
                        Globals.startingTimeHoldingVar = 15000;
                    }
                    Ui.requestUpdate();
                    return true;
                }
                
                if(Globals.changingStartingTimeWithButton) {
                    Globals.interestingCountingVariable = 0;
                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                    Globals.startingTimeHoldingVar -= 15000;
                    if(Globals.startingTimeHoldingVar <  15000) {
                        Globals.startingTimeHoldingVar = 15000;
                    }
                    return true;
                }

                if(Globals.changingSideWithButton != 'n') {
                    Globals.interestingCountingVariable = 0;
                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                    Globals.changingTimeHoldingVar -= 30000;

                    if(Globals.changingTimeHoldingVar  < 100) {
                        Globals.changingTimeHoldingVar = 100;
                    }
                    return true;
                }

                if(Globals.changingIncrementWithButton) {
                    Globals.interestingCountingVariable = 0;
                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                    Globals.incrementHoldingVar -= 1;
                    if(Globals.incrementHoldingVar >  0) {
                        Globals.incrementHoldingVar = 0;
                    }
                    return true;
                }

                break;
            case Ui.KEY_MENU:
            case Ui.KEY_UP:
                if(!Globals.changingIncrementWithButton && !Globals.changingStartingTimeWithButton && !Globals.gameStarted && Globals.changingSideWithButton == 'n') {
                    onMenu();
                    break;
                }
                
                if(Globals.changingStartingTimeWithButton) {
                    Globals.interestingCountingVariable = 0;
                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                    Globals.startingTimeHoldingVar += 15000;
                    if(Globals.startingTimeHoldingVar >  5999999) {
                        Globals.startingTimeHoldingVar = 5999999;
                    }
                    return true;
                }
                
                if(Globals.changingIncrementWithButton) {
                    Globals.interestingCountingVariable = 0;
                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                    if(Globals.changingSideWithButton == 'w') {
                        return true;
                    }
                    if(Globals.changingSideWithButton == 'b') {
                        return true;
                    }

                    Globals.incrementHoldingVar++;
                    if(Globals.incrementHoldingVar >  30) {
                        Globals.incrementHoldingVar = 30;
                    }
                    return true;
                }

                if(Globals.changingSideWithButton != 'n') {
                    Globals.interestingCountingVariable = 0;
                    if(Attention has :vibrate && Globals.haptics) { Attention.vibrate(backVibeProfile); }
                    Globals.changingTimeHoldingVar += 30000; // Value is updated once through the settings menu before this can be called.
                    
                    if(Globals.changingTimeHoldingVar  > 5999999) {
                        Globals.changingTimeHoldingVar = 5999999;
                    }
                    return true;
                }
                break;
        }
        return true;
    }

    function backTimerCallback() as Void {
        backTimerActive = false;
    }

    function onSwipe(swipeEvent) {
        return true;
    }

    function onHold(clickEvent as Ui.ClickEvent) as Boolean {
        if(Globals.gameStarted) { changeSidesAndAddIncrement(); }
        return true;
    }

    function startTimer() {
        timeThen = System.getTimer() & Constants.UINT32_MAX;
        Globals.gameStarted = true;
        Globals.isWhitesTurn = !Globals.hasGameBeenStopped ? true : Globals.isWhitesTurn;

        timer.start(method(Globals.isWhitesTurn ? :whiteDecrement : :blackDecrement), 50, true); // wow that looks confusing my bad bro

        sideTimeThenWhite = Globals.whiteTimeLeft;
        sideTimeThenBlack = Globals.blackTimeLeft;
        Globals.hasGameBeenStopped = false;
    }

    function stopTimer() {
        timeNow   = System.getTimer() & Constants.UINT32_MAX;
        timeDelta = (timeNow - timeThen).abs();
        timeThen  = timeNow;

        if(!Globals.hasGameBeenStopped) {
            Globals.gameStarted = false;
            Globals.hasGameBeenStopped = true;
            timer.stop();

            if(Globals.isWhitesTurn && Globals.gameStarted) {
                Globals.whiteTimeLeft = (sideTimeThenWhite - timeDelta);
                sideTimeThenWhite = Globals.whiteTimeLeft;
            } else if(Globals.gameStarted) {
                Globals.blackTimeLeft = (sideTimeThenBlack - timeDelta);
                sideTimeThenBlack = Globals.blackTimeLeft;
            }

            Ui.requestUpdate();
        } else {
            timer.stop();
            Globals.totalTime = 0;
            Globals.turns = 0;
            Globals.whiteTimeLeft = (Globals.startingTimeInSeconds + Globals.whiteIncrement) * 1000;
            Globals.blackTimeLeft = (Globals.startingTimeInSeconds + Globals.blackIncrement) * 1000;
            Globals.isWhitesTurn = true;
            Globals.hasGameBeenStopped = false;
            Ui.requestUpdate();
        }
        Globals.uninterestingCountingVariable = 0;
    }

    function changeSidesAndAddIncrement() {
        // It is implemented like this because getTimer() will overflow after about 24 days and 20.5 hours
        // This could happen during runtime. It's unlikely, but I don't want that risk.
        timeNow = System.getTimer() & Constants.UINT32_MAX;
        timeDelta = (timeNow - timeThen).abs();
        timeThen = timeNow;

        if(Globals.isWhitesTurn) {
            timer.stop();
            Globals.whiteTimeLeft = sideTimeThenWhite - timeDelta;
            Globals.whiteTimeLeft += Globals.whiteIncrement * 1000;
            totalTimeTemp = Globals.totalTime + timeDelta;
            Globals.totalTime = totalTimeTemp;

            Globals.whiteTimeLeft = Globals.whiteTimeLeft > 5999999 ? 5999999 : Globals.whiteTimeLeft;
            
            sideTimeThenWhite = Globals.whiteTimeLeft;

            Globals.isWhitesTurn = false;
            timer.start(method(:blackDecrement), 50, true);
        } else {
            timer.stop();
            Globals.blackTimeLeft = sideTimeThenBlack - timeDelta;
            Globals.blackTimeLeft += Globals.blackIncrement * 1000;
            totalTimeTemp = Globals.totalTime + timeDelta;
            Globals.totalTime = totalTimeTemp;

            Globals.blackTimeLeft = Globals.blackTimeLeft > 5999999 ? 5999999 : Globals.blackTimeLeft;
            
            sideTimeThenBlack = Globals.blackTimeLeft;
            
            Globals.isWhitesTurn = true;
            Globals.turns++;
            timer.start(method(:whiteDecrement), 50, true);
        }

        Globals.uninterestingCountingVariable = 0;

        Ui.requestUpdate();
    }

    function whiteDecrement() as Void {
        Globals.totalTime += 50;
        if(Globals.whiteTimeLeft <= 0) {
            Globals.whiteTimeLeft = 0;
            stopTimer();
            Globals.whiteLost = true;
            Ui.switchToView(new $.TimeOutViewLegacy(), new $.TimeOutDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
            return;
        }
        Globals.whiteTimeLeft -= 50;
        Globals.uninterestingCountingVariable++;
        Ui.requestUpdate();
    }

    function blackDecrement() as Void {
        Globals.totalTime += 50;
        if(Globals.blackTimeLeft <= 0) {
            Globals.blackTimeLeft = 0;
            stopTimer();
            Globals.whiteLost = false;
            Ui.switchToView(new $.TimeOutViewLegacy(), new $.TimeOutDelegate(Dictionary), Ui.SLIDE_IMMEDIATE);
            return;
        }
        Globals.blackTimeLeft -= 50;
        Globals.uninterestingCountingVariable++;
        Ui.requestUpdate();
    }
}