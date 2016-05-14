package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;
import gengine.components.*;
import systems.*;
import components.*;
import haxe.ds.Vector;
import components.Vehicle;
import components.Isometric;

class IsometricSystem extends ListIteratingSystem<IsometricNode>
{
    static public var tileSize = 50;
    private var engine:Engine;
    private var position = new Vector3(0, 0, 0);

    public function new()
    {
        super(IsometricNode, updateNode);
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);

        engine = _engine;
    }

    private function updateNode(node:IsometricNode, dt:Float):Void
    {
        var p = position;
        var coords = node.iso.coords;

        var converted = getIsoFromCar(coords.x, coords.y);

        p.x = converted.x * tileSize;
        p.y = converted.y * tileSize;

        node.entity.setPosition(p);
    }

    static public function getCarFromIso(i:Float, j:Float):Vector2
    {
        return new Vector2((i + 2.0*j) / 2.0, (2.0*j - i )/2.0);
    }

    static public function getIsoFromCar(x:Float, y:Float):Vector2
    {
        return new Vector2(x - y, (x + y) / 2.0);
    }
}
