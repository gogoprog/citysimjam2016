package components;

import gengine.math.*;
import nodes.*;

enum Direction
{
    S;
    W;
    N;
    E;
}

class Vehicle
{
    public var fromCoords:IntVector2;
    public var toCoords:IntVector2;
    public var currentCoords:Vector2;
    public var direction:Direction = S;
    public var toDirection:Direction;
    public var state:String;
    public var time:Float;
    public var hasPackage:Bool = false;
    public var client:TileNode = null;

    public function new()
    {
    }
}
