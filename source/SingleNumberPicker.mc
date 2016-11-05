using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class SingleNumberPicker extends Ui.Picker {

    function initialize(label, initial) {
        var title = new Ui.Text({:text=>label, :locX =>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color=>Gfx.COLOR_WHITE});
        var factory = new NumberFactory(1, 99, 1, {});
        var defaultValue = initial - 1;
        if (defaultValue < 1) {
            defaultValue = 1;
        }
        Picker.initialize({:title=>title, :defaults=>[defaultValue], :pattern=>[factory]});
    }

    function onUpdate(dc) {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}
