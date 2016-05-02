import gengine.*;
import gengine.math.*;
import gengine.components.*;
import gengine.graphics.*;
import systems.*;
import components.*;

class ExitSystem extends System
{
    public function new()
    {
        super();
    }

    override public function update(dt:Float):Void
    {
        if(Gengine.getInput().getScancodePress(41))
        {
            Gengine.exit();
        }
    }
}

class Application
{
    private static var engine:Engine;

    public static function init()
    {
        Gengine.setWindowSize(new IntVector2(800, 600));
        Gengine.setWindowTitle("citysimjam2016");
    }

    public static function start(_engine:Engine)
    {
        engine = _engine;

        engine.addSystem(new ExitSystem(), 0);
        engine.addSystem(new CameraSystem(), 0);
        engine.addSystem(new TileSystem(), 0);

        Gengine.getRenderer().getDefaultZone().setFogColor(new Color(1,1,1,1));

        var cameraEntity = new Entity();
        cameraEntity.add(new Camera());
        cameraEntity.get(Camera).setOrthoSize(new Vector2(800, 600));
        cameraEntity.get(Camera).setOrthographic(true);
        engine.addEntity(cameraEntity);

        var viewport:Viewport = new Viewport(Gengine.getContext());
        viewport.setScene(Gengine.getScene());
        viewport.setCamera(cameraEntity.get(Camera));
        Gengine.getRenderer().setViewport(0, viewport);

        addTile(0, 0);
        addTile(1, 0);
        addTile(1, 1);
        addTile(1, 2);
    }


    public static function addTile(x:Int, y:Int)
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        e.add(new Tile(new IntVector2(x, y)));
        var staticSprite2D:StaticSprite2D = e.get(StaticSprite2D);
        staticSprite2D.setSprite(Gengine.getResourceCache().getSprite2D("dirt.png", true));
        engine.addEntity(e);
    }
}
