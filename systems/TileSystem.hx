package systems;

import gengine.math.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;

class TileSystem extends ListIteratingSystem<TileNode>
{
    private var tileSize = new IntVector2(100, 60);

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
        var v = getCarFromIso(c.x, c.y);

        p.x = v.x * 50;
        p.y = v.y * 30;
        e.setPosition(p);
    }

    private function getCarFromIso(i:Int, j:Int):Vector2
    {
        return new Vector2((i + 2.0*j) / 2.0, (2.0*j - i )/2.0);
    }
}
