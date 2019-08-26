using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Graphics;

class Background extends WatchUi.Drawable {

    hidden var bgColor;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };
        Drawable.initialize(dictionary);
    }

    /*
     * @param Number color Graphics.COLOR_* constant or 24-bit integer of the form 0xRRGGBB
     */
    function setColor(color) {
        bgColor = color;
    }

    /*
     * @param Graphics.Dc dc
     */
    function draw(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, bgColor);
        dc.clear();
        // horizontal line in the middle
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(10, 120, 230, 120);
        // fill top and bottom edge (always black)
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(0, 0, 240, 30);
        dc.fillRectangle(0, 215, 240, 240);
    }

}
