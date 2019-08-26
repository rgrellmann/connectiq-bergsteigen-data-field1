using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.System;
using Toybox.Lang;
using Toybox.UserProfile;

/*
 * A DataField which displays values of interest during a mountain tour
 * It is designed to be easily readable when having a quick look at the watch
 * while walking or climbing.
 * Have a look at BergsteigenDataField2 for additional values.
 */
class BergsteigenDataField1View extends WatchUi.DataField {

    protected var altitude = 0;
    protected var clockTime;
    protected var elapsedTime = 0;
    protected var battery = 0;
    protected var currentHeartRate = 0;
    protected var currentHeartRateZone = 0;
    protected var totalAscent = 0;
    protected var totalDescent = 0;
    protected var hrZoneInfo = [];

    function initialize() {
        DataField.initialize();
        clockTime = System.getClockTime();
        hrZoneInfo = UserProfile.getHeartRateZones(UserProfile.getCurrentSport());
    }

    /*
     * Set the layout. Anytime the size of obscurity of
     * the draw context is changed this will be called.
     * @param Graphics.DC dc
     */
    function onLayout(dc) {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        View.findDrawableById("unitAltitude").setText("m");
        View.findDrawableById("labelAltitude").setText(Rez.Strings.labelAltitude);
        View.findDrawableById("labelCurrentHeartRate").setText(Rez.Strings.labelHeartRate);
        View.findDrawableById("labelElapsedTime").setText(Rez.Strings.labelElapsedTime);
        return true;
    }

    /*
     * The given info object contains all the current workout information.
     * Calculate a value and save it locally in this method.
     * Note that compute() and onUpdate() are asynchronous, and there is no
     * guarantee that compute() will be called before onUpdate().
     * @param Activity.Info info
     */
    function compute(info) {
        clockTime = System.getClockTime();
        battery = System.getSystemStats().battery;
        // initialize all numeric properties which should be part of info
        var numberProperties = [:altitude, :currentHeartRate, :totalAscent, :totalDescent, :elapsedTime];
        for (var i = 0; i < numberProperties.size(); i++) {
            if (info has numberProperties[i]) {
                if (info[numberProperties[i]] != null) {
                    self[numberProperties[i]] = info[numberProperties[i]];
                } else {
                    self[numberProperties[i]] = 0;
                }
            }
        }
        // check if the heart rate should be highlighted
        // (in or above zone 5)
        if (currentHeartRate > hrZoneInfo[5]) {
            currentHeartRateZone = 6;
        } else if (currentHeartRate > hrZoneInfo[4]) {
            currentHeartRateZone = 5;
        } else {
            currentHeartRateZone = 0;
        }
    }

    /*
     * Display the computed values.
     * Called once a second when the data field is visible.
     * @param Graphics.Dc dc
     */
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());
        // Set the foreground color and value
        var foregroundColor = Graphics.COLOR_BLACK;
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            foregroundColor = Graphics.COLOR_WHITE;
        }
        var drawables = ["altitude", "currentHeartRate", "totalDescent", "totalAscent", "elapsedTime"];
        for (var i = 0; i < drawables.size(); i++) {
            var drawable = View.findDrawableById(drawables[i]);
            drawable.setColor(foregroundColor);
        }

        var value = View.findDrawableById("altitude");
        value.setText(altitude.format("%d"));

        value = View.findDrawableById("clockTime");
        value.setText(Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]));

        value = View.findDrawableById("elapsedTime");
        var elapsedSeconds = elapsedTime / 1000;
        var hours = elapsedSeconds / 3600;
        var minutes = (elapsedSeconds) / 60 % 60;
        var seconds = elapsedSeconds % 60;
        if (hours > 0) {
            value.setText(Lang.format("$1$:$2$", [hours, minutes.format("%02d")]));
        } else {
            value.setText(Lang.format("$1$:$2$", [minutes, seconds.format("%02d")]));
        }

        value = View.findDrawableById("currentHeartRate");
        if (currentHeartRateZone == 6) {
            value.setColor(Graphics.COLOR_RED);
        } else if (currentHeartRateZone == 5) {
            value.setColor(Graphics.COLOR_YELLOW);
        } else {
            value.setColor(foregroundColor);
        }
        value.setText(currentHeartRate.format("%d"));

        value = View.findDrawableById("totalAscent");
        value.setText((totalAscent).format("%d") + 'm');
        value = View.findDrawableById("totalDescent");
        value.setText((totalDescent).format("%d") + 'm');

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);

        // all direct draw operations must be performed after View.onUpdate()

        // battery symbol at the lower edge of the screen
        drawBattery(battery, dc, 100, 220, 40, 15);

        // draw arrows for ascent and descent
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(112, 141, 107, 146);
        dc.drawLine(112, 141, 112, 158);
        dc.drawLine(112, 141, 117, 146);
        dc.drawLine(112, 187, 107, 182);
        dc.drawLine(112, 187, 112, 170);
        dc.drawLine(112, 187, 117, 182);
    }

    /*
     * Draws a battery icon with a coloured level indicator
     * @param Number battery
     * @param Graphics.Dc dc
     * @param Number xStart
     * @param Number yStart
     * @param Number width
     * @param Number height
     */
    function drawBattery(battery, dc, xStart, yStart, width, height) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(xStart, yStart, width, height);
        if (battery < 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(xStart + 3 + width / 2, yStart + 6, Graphics.FONT_XTINY, format("$1$%", [battery.format("%d")]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else if (battery < 25) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(xStart + 1, yStart + 1, (width-2) * battery / 100, height - 2);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillRectangle(xStart + width - 1, yStart + 3, 4, height - 6);
    }

}
