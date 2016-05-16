package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.components.*;
import gengine.*;
import nodes.*;
import systems.*;
import haxe.ds.Vector;

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
    private var currentTool:Tool = None;
    private var musicEntity:Entity;
    private var soundSources:Vector<SoundSource>;
    private var nextSoundSourceIndex = 0;
    private var money = 0;
    private var deliveredPackages = 0;
    private var toolCosts:Map<Tool, Int>;
    private var sounds = new Map<String, Dynamic>();
    private var clients = new Array<TileNode>();
    private var clientTime = 0.0;

    public function new()
    {
        super();
        input = Gengine.getInput();

        toolCosts = new Map<Tool,Int>();
        toolCosts[Road] = 100;
        toolCosts[Remove] = 50;

        sounds["cash"] = Gengine.getResourceCache().getSound("cash.wav", true);
        sounds["build"] = Gengine.getResourceCache().getSound("build.wav", true);
        sounds["step"] = Gengine.getResourceCache().getSound("step.wav", true);
        sounds["collision"] = Gengine.getResourceCache().getSound("collision.wav", true);
        sounds["break"] = Gengine.getResourceCache().getSound("break.wav", true);
        sounds["powerup"] = Gengine.getResourceCache().getSound("powerup.wav", true);
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);

        engine = _engine;

        musicEntity = new Entity();
        musicEntity.add(new SoundSource());

        engine.addEntity(musicEntity);

        var soundSource:SoundSource = musicEntity.get(SoundSource);
        soundSource.setSoundType("Music");
        soundSource.setGain(0.7);

        soundSources = new Vector<SoundSource>(8);

        for(i in 0...soundSources.length)
        {
            var e = new Entity();
            soundSources[i] = new SoundSource();
            e.add(soundSources[i]);
            engine.addEntity(e);
        }
    }

    override public function update(dt:Float):Void
    {
        if(!musicEntity.get(SoundSource).isPlaying())
        {
            musicEntity.get(SoundSource).play(Gengine.getResourceCache().getSound("music.ogg", true));
            musicEntity.get(SoundSource).setGain(0.7);
        }

        if(input.getScancodePress(41))
        {
            Gengine.exit();
        }

        clientTime -= dt;

        if(clientTime < 0)
        {
            clientTime = 4 + Math.random() * 4;

            var tn = clients[Std.random(clients.length)];

            if(!tn.tile.wantsPackage && tn.tile.notificationEntity != null)
            {
                tn.tile.wantsPackage = true;
                tn.tile.notificationEntity.get(StaticSprite2D).setAlpha(1);
            }
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

    public function addClient(tn:TileNode)
    {
        clients.push(tn);
    }

    public function start()
    {
        var list = new Array<Entity>();

        for(v in engine.getNodeList(VehicleNode))
        {
            list.push(v.entity);
        }

        for(v in engine.getNodeList(NotificationNode))
        {
            list.push(v.entity);
        }

        for(l in list)
        {
            engine.removeEntity(l);
        }

        clients.splice(0, clients.length);

        engine.getSystem(TileSystem).generateMap(20, 10);

        playing = true;
        Gui.showPage("hud");

        money = 5000;
        Gui.setMoney(money);

        clientTime = 0;

        playSound("powerup");
    }

    public function doAction(action:Action)
    {
        switch(action)
        {
            case BuyCar:
                if(canAfford(200))
                {
                    var htn = engine.getSystem(TileSystem).homeTileNode;
                    var c = htn.tile.coords;
                    engine.getSystem(VehicleSystem).spawn(c.x, c.y);
                    cost(200);
                }
        }
    }

    public function playSound(sound:String)
    {
        soundSources[nextSoundSourceIndex++].play(sounds[sound]);
        nextSoundSourceIndex %= soundSources.length;
    }

    public function getMoney()
    {
        return money;
    }

    public function canAfford(value:Int)
    {
        return money >= value;
    }

    public function canAffordCurrentTool()
    {
        return money >= toolCosts[currentTool];
    }

    public function useCurrentTool()
    {
        cost(toolCosts[currentTool]);
    }

    public function cost(amount:Int)
    {
        money -= amount;
        Gui.setMoney(money);
    }

    public function gain(amount:Int)
    {
        money += amount;
        Gui.setMoney(money);
        playSound("cash");
    }

    public function onPackageDelivered()
    {
        deliveredPackages++;
        Gui.setPackages(deliveredPackages);
        gain(50);
    }
}
