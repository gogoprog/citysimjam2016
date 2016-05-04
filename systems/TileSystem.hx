package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;
import gengine.components.*;
import systems.*;
import components.*;
import haxe.ds.Vector;

class TileSystem extends ListIteratingSystem<TileNode>
{
    private var tileSize = 50;
    private var engine:Engine;
    private var grid:Vector<Vector<TileNode>>;
    private var input:Input;
    private var mouseCoords = new IntVector2(1, 1);
    private var previousMouseCoords = new IntVector2(1, 1);
    private var sprites = new Map<String, Dynamic>();

    public function new()
    {
        super(TileNode, null, onNodeAdded);
        input = Gengine.getInput();

        sprites["dirt"] = Gengine.getResourceCache().getSprite2D("dirt.png", true);
        sprites["grass"] = Gengine.getResourceCache().getSprite2D("grass.png", true);
        sprites["roadEast"] = Gengine.getResourceCache().getSprite2D("roadEast.png", true);
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);

        engine = _engine;

        generateMap(10);
    }

    override public function update(dt:Float)
    {
        super.update(dt);
        var button = 1;

        var coords = new IntVector2(0, 0);
        var mp = engine.getSystem(CameraSystem).mouseWorldPosition;

        var converted = getCarFromIso(mp.x, mp.y);
        mouseCoords.x = Math.floor((converted.x + tileSize/2) / tileSize);
        mouseCoords.y = Math.floor((converted.y + tileSize/2) / tileSize);

        if(areCoordsOnMap(previousMouseCoords))
        {
            grid[previousMouseCoords.x][previousMouseCoords.y].sprite.setColor(new Color(1, 1, 1, 1));
        }

        if(areCoordsOnMap(mouseCoords))
        {
            grid[mouseCoords.x][mouseCoords.y].sprite.setColor(new Color(1, 1, 1, 0.5));
        }

        previousMouseCoords.x = mouseCoords.x;
        previousMouseCoords.y = mouseCoords.y;

        if(input.getMouseButtonPress(button))
        {

        }
    }

    public function generateMap(size:Int)
    {
        grid = new Vector<Vector<TileNode>>(size);

        for(i in 0...size)
        {
            grid[i] = new Vector<TileNode>(size);

            for(j in 0...size)
            {
                addTile(i, j);
            }
        }
    }

    private function areCoordsOnMap(coords:IntVector2)
    {
        return coords.x >= 0 && coords.x < grid.length && coords.y >= 0 && coords.y < grid[coords.x].length;
    }

    private function onNodeAdded(node:TileNode):Void
    {
        var button = 1;
        var e:Entity = node.entity;
        var p = e.position;

        var c = node.tile.coords;
        var v = getIsoFromCar(c.x, c.y);

        p.x = v.x * tileSize;
        p.y = v.y * tileSize;

        e.setPosition(p);
        node.sprite.setLayer(cast(-p.y));
        grid[c.x][c.y] = node;

        checkTexture(node);
    }

    private function getCarFromIso(i:Float, j:Float):Vector2
    {
        return new Vector2((i + 2.0*j) / 2.0, (2.0*j - i )/2.0);
    }

    private function getIsoFromCar(x:Float, y:Float):Vector2
    {
        return new Vector2(x - y, (x + y) / 2.0);
    }

    private function addTile(x:Int, y:Int):Entity
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        e.add(new Tile(new IntVector2(x, y)));
        engine.addEntity(e);
        return e;
    }

    private function checkTexture(node:TileNode)
    {
        switch(node.tile.type)
        {
            case Dirt:
                node.sprite.setSprite(sprites["dirt"]);

            case Grass:
                node.sprite.setSprite(sprites["grass"]);

            case Road:
                node.sprite.setSprite(sprites["road"]);
        }
    }
}
