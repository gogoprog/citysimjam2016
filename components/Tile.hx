package components;

import gengine.math.*;

enum TileType {
    Dirt;
    Grass;
    Road;
    Client;
    Home;
}

class Tile
{
    public var coords:IntVector2;
    public var wantsPackage = true;

    public function new(_coords:IntVector2)
    {
        coords = _coords;
    }

    public var type:TileType = TileType.Dirt;


}
