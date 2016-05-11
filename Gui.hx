
import js.*;
import systems.*;
import systems.GameSystem;

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

        new JQuery("#hud .tools .button").mousedown(function(e) {
            new JQuery("#hud .button").removeClass("selected");
            var that = new JQuery(e.delegateTarget);
            that.addClass("selected");
            gameSystem.setCurrentTool(Tool.createByIndex(that.index()));
        });
    }

    static public function showPage(name:String, ?duration = 200)
    {
        new JQuery(".pages > div").fadeOut(duration);
        new JQuery("#" + name).fadeIn(duration);
    }
}
