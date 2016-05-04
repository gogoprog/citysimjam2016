package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;
import gengine.components.*;
import systems.*;
import components.*;

class VehicleSystem extends ListIteratingSystem<VehicleNode>
{
    private var engine:Engine;

    public function new()
    {
        super(VehicleNode, updateNode, onNodeAdded);
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);
        engine = _engine;

        spawn(2, 3);
        spawn(5, 6);
        spawn(6, 6);
        spawn(8, 2);
    }

    private function updateNode(node:VehicleNode, dt:Float):Void
    {
    }

    private function onNodeAdded(node:VehicleNode):Void
    {
        var e:Entity = node.entity;
        var p = e.position;

        var c = node.vehicle.fromCoords;
        var v = TileSystem.getIsoFromCar(c.x, c.y);

        p.x = v.x * TileSystem.tileSize;
        p.y = v.y * TileSystem.tileSize;

        node.sprite.setLayer(cast(-p.y) + 1);
        p.y += 5;

        e.setPosition(p);

        node.sprite.setSprite(Gengine.getResourceCache().getSprite2D("garbage_NE.png", true));
    }

    public function spawn(x:Int, y:Int)
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        e.add(new Vehicle(new IntVector2(x, y)));
        engine.addEntity(e);
        return e;
    }
}
