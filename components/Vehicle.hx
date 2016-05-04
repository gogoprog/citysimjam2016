package components;

import gengine.math.*;

class Vehicle
{
    public var fromCoords:IntVector2;
    public var toCoords:IntVector2;

    public function new(_coords:IntVector2)
    {
        fromCoords = _coords;
    }
}
