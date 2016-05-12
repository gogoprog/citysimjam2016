package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.components.*;
import gengine.*;
import nodes.*;
import systems.*;

enum Tool
{
    None;
    Road;
    Remove;
}

enum Action
{
    BuyCar;
}

class GameSystem extends System
{
    private var input:Input;
    private var engine:Engine;
    private var playing = false;
    private var currentTool:Tool;
    private var musicEntity:Entity;

    public function new()
    {
        super();
        input = Gengine.getInput();
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);

        engine = _engine;

        musicEntity = new Entity();
        musicEntity.add(new SoundSource());

        engine.addEntity(musicEntity);

        var soundSource:SoundSource = musicEntity.get(SoundSource);
        soundSource.play(Gengine.getResourceCache().getSound("music.ogg", true));
        soundSource.setGain(0.5);
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

    public function doAction(action:Action)
    {
        switch(action)
        {
            case BuyCar:
                engine.getSystem(VehicleSystem).spawn(4, 4);
        }
    }
}
