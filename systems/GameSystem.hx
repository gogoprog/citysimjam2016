package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import systems.*;

enum Tool
{
    None;
    Road;
    Remove;
}

class GameSystem extends System
{
    private var input:Input;
    private var engine:Engine;
    private var playing = false;
    private var currentTool:Tool;

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
            start();
        }
    }

    public function isPlaying()
    {
        return playing;
    }

    public function setCurrentTool(tool:Tool)
    {
        currentTool = tool;
    }

    public function getCurrentTool()
    {
        return currentTool;
    }

    public function start()
    {
        engine.getSystem(TileSystem).generateMap(20);
        playing = true;
        Gui.showPage("hud");
    }
}
