package systems;

import gengine.math.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;

class TileSystem extends ListIteratingSystem<TileNode>
{
    public function new()
    {
        super(TileNode, null, onNodeAdded);
    }

    private function onNodeAdded(node:TileNode):Void
    {
        var button = 1;
        var e:Entity = node.entity;
        var p = e.position;

        var c = node.tile.coords;
        var v = getIsoFromCar(c.x, c.y);

        p.x = v.x * 50;
        p.y = v.y * 50;

        e.setPosition(p);
        node.sprite.setLayer(cast(-p.y));
    }

    private function getCarFromIso(i:Int, j:Int):Vector2
    {
        return new Vector2((i + 2.0*j) / 2.0, (2.0*j - i )/2.0);
    }

    private function getIsoFromCar(x:Int, y:Int):Vector2
    {
        return new Vector2(x - y, (x + y) / 2.0);
    }
}
