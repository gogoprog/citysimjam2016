package components;

import gengine.math.*;

enum TileType {
    Dirt;
    Grass;
    Road;
}

class Tile
{
    public var coords:IntVector2;

    public function new(_coords:IntVector2)
    {
        coords = _coords;
    }

    public var type:TileType = TileType.Dirt;
}
