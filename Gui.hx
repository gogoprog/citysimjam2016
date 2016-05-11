
import js.*;
import systems.*;

@:expose('Gui')
class Gui
{
    static public var gameSystem:GameSystem;

    static public function init()
    {
        showPage("main");

        new JQuery(".menu .play").click(function() {
            gameSystem.start();
        });
    }

    static public function showPage(name:String, ?duration = 200)
    {
        new JQuery(".pages > div").fadeOut(duration);
        new JQuery("#" + name).fadeIn(duration);
    }
}
