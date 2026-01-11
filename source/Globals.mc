import Toybox.Lang;

module Globals {
    var gameStarted as Boolean = false;
    var isWhitesTurn as Boolean = true;
    var hasGameBeenStopped as Boolean = false;
    var settingChanged as Boolean = false;

    var whiteTimeLeft as Number = 605000;
    var blackTimeLeft as Number = 605000;

    var drawString as Boolean = false;

    var startingTimeInSeconds as Number = 600;

    var isDragging as Boolean = false;
    var axis as String = "N";
    var isDragVertical as Boolean = false;

    var startingTimeHoldingVar as Integer = 605000, changingTimeHoldingVar as Integer = 605000;
    
    var whiteLost as Boolean = true;
    var turns as Integer = 0, totalTime as Integer = 0;

    var animationTimer;
    var hasAnimationTimerStarted as Boolean = false;
    var animationCounter as Integer = 0;
    var textGlideCounter as Integer = 0;

    var incrementHoldingVar as Integer = 0;

    var previousValue as Number = 0;

    var whiteIncrement as Integer = 5;
    var blackIncrement as Integer = 5;

    var changingStartingTimeWithButton as Boolean = false;
    var changingSideWithButton as Char = 'n';
    var changingIncrementWithButton as Boolean = false;
    
    var uninterestingCountingVariable as Number = 0;
    var interestingCountingVariable as Number = 0;

    // For devices without app storage
    var drawProgressRing as Boolean = true;
    var backLightOn as Boolean = true;
    var drawModernMenu as Boolean = false;
    var useLegacyView as Boolean = true;
    var useScalingTimeOut as Boolean = false;
    var hasStorage as Boolean = true;
    var haptics as Boolean = true;
}