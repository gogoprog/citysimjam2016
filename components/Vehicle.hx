package components;

import gengine.math.*;

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
    public var direction:Direction = N;
    public var toDirection:Direction;
    public var state:String;
    public var time:Float;
    public var hasPackage:Bool = false;

    public function new()
    {
    }
}
