import gengine.*;
import gengine.math.*;
import gengine.components.*;
import gengine.graphics.*;
import systems.*;
import components.*;
import Gui;

class Application
{
    private static var engine:Engine;

    public static function init()
    {
        Gengine.setWindowSize(new IntVector2(1024, 768));
        Gengine.setWindowTitle("citysimjam2016");
        Gengine.setGuiFilename("gui/gui.html");
    }

    public static function start(_engine:Engine)
    {
        engine = _engine;

        engine.addSystem(new GameSystem(), 0);
        engine.addSystem(new CameraSystem(), 0);
        engine.addSystem(new TileSystem(), 0);
        engine.addSystem(new VehicleSystem(), 0);
        engine.addSystem(new IsometricSystem(), 0);

        Gengine.getRenderer().getDefaultZone().setFogColor(new Color(0.4, 0.7, 0.7, 1));

        var cameraEntity = new Entity();
        cameraEntity.add(new Camera());
        cameraEntity.get(Camera).setOrthoSize(new Vector2(1024, 768));
        cameraEntity.get(Camera).setOrthographic(true);

        engine.addEntity(cameraEntity);

        var viewport:Viewport = new Viewport(Gengine.getContext());
        viewport.setScene(Gengine.getScene());
        viewport.setCamera(cameraEntity.get(Camera));
        Gengine.getRenderer().setViewport(0, viewport);

        engine.getSystem(TileSystem).generateDemoMap();

        Gui.gameSystem = engine.getSystem(GameSystem);
        Gui.init();
    }
}
