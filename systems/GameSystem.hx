package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import systems.*;

class GameSystem extends System
{
    private var input:Input;
    private var engine:Engine;
    private var playing = false;

    public function new()
    {
        super();
        input = Gengine.getInput();
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);

        engine = _engine;
    }

    override public function update(dt:Float):Void
    {
        if(input.getScancodePress(41))
        {
            Gengine.exit();
        }

        if(input.getScancodePress(44))
        {
            engine.getSystem(TileSystem).generateMap(20);
            playing = true;
        }
    }

    public function isPlaying()
    {
        return playing;
    }
}
