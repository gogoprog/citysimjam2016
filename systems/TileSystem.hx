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
    static public var tileSize = 50;
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
        sprites["roadH"] = Gengine.getResourceCache().getSprite2D("roadEast.png", true);
        sprites["roadV"] = Gengine.getResourceCache().getSprite2D("roadNorth.png", true);
        sprites["crossroad"] = Gengine.getResourceCache().getSprite2D("crossroad.png", true);
        sprites["lot"] = Gengine.getResourceCache().getSprite2D("lot.png", true);
        sprites["roadCornerES"] = Gengine.getResourceCache().getSprite2D("roadCornerES.png", true);
        sprites["roadCornerNE"] = Gengine.getResourceCache().getSprite2D("roadCornerNE.png", true);
        sprites["roadCornerNW"] = Gengine.getResourceCache().getSprite2D("roadCornerNW.png", true);
        sprites["roadCornerWS"] = Gengine.getResourceCache().getSprite2D("roadCornerWS.png", true);
        sprites["roadTN"] = Gengine.getResourceCache().getSprite2D("roadTNorth.png", true);
        sprites["roadTE"] = Gengine.getResourceCache().getSprite2D("roadTEast.png", true);
        sprites["roadTS"] = Gengine.getResourceCache().getSprite2D("roadTSouth.png", true);
        sprites["roadTW"] = Gengine.getResourceCache().getSprite2D("roadTWest.png", true);
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
            grid[mouseCoords.x][mouseCoords.y].sprite.setColor(new Color(0.3, 0.3, 1, 0.7));

            if(input.getMouseButtonPress(button))
            {
                var x = mouseCoords.x;
                var y = mouseCoords.y;

                grid[x][y].tile.type = Road;
                checkTexture(grid[x][y]);

                if(isRoad(new IntVector2(x - 1, y)))
                {
                    checkTexture(grid[x - 1][y]);
                }

                if(isRoad(new IntVector2(x + 1, y)))
                {
                    checkTexture(grid[x + 1][y]);
                }

                if(isRoad(new IntVector2(x, y - 1)))
                {
                    checkTexture(grid[x][y - 1]);
                }

                if(isRoad(new IntVector2(x, y + 1)))
                {
                    checkTexture(grid[x][y + 1]);
                }
            }
        }

        previousMouseCoords.x = mouseCoords.x;
        previousMouseCoords.y = mouseCoords.y;
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

    public function isRoad(coords:IntVector2)
    {
        return areCoordsOnMap(coords) && grid[coords.x][coords.y].tile.type == Road;
    }

    private function onNodeAdded(node:TileNode):Void
    {
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

    static public function getCarFromIso(i:Float, j:Float):Vector2
    {
        return new Vector2((i + 2.0*j) / 2.0, (2.0*j - i )/2.0);
    }

    static public function getIsoFromCar(x:Float, y:Float):Vector2
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
        var coords = node.tile.coords;

        switch(node.tile.type)
        {
            case Dirt:
                node.sprite.setSprite(sprites["dirt"]);

            case Grass:
                node.sprite.setSprite(sprites["grass"]);

            case Road:
                var n = false;
                var s = false;
                var e = false;
                var w = false;

                if(isRoad(new IntVector2(coords.x - 1, coords.y)))
                {
                    w = true;
                }

                if(isRoad(new IntVector2(coords.x + 1, coords.y)))
                {
                    e = true;
                }

                if(isRoad(new IntVector2(coords.x, coords.y - 1)))
                {
                    s = true;
                }

                if(isRoad(new IntVector2(coords.x, coords.y + 1)))
                {
                    n = true;
                }

                if(n && s && e && w)
                {
                    node.sprite.setSprite(sprites["crossroad"]);
                }
                else if(e && s && w)
                {
                    node.sprite.setSprite(sprites["roadTS"]);
                }
                else if(w && n && s)
                {
                    node.sprite.setSprite(sprites["roadTW"]);
                }
                else if(e && n && w)
                {
                    node.sprite.setSprite(sprites["roadTN"]);
                }
                else if(e && s && n)
                {
                    node.sprite.setSprite(sprites["roadTE"]);
                }
                else if(e && s)
                {
                    node.sprite.setSprite(sprites["roadCornerES"]);
                }
                else if(e && n)
                {
                    node.sprite.setSprite(sprites["roadCornerNE"]);
                }
                else if(w && s)
                {
                    node.sprite.setSprite(sprites["roadCornerWS"]);
                }
                else if(w && n)
                {
                    node.sprite.setSprite(sprites["roadCornerNW"]);
                }
                else if(e && w)
                {
                    node.sprite.setSprite(sprites["roadH"]);
                }
                else if(s && n)
                {
                    node.sprite.setSprite(sprites["roadV"]);
                }
                else
                {
                    node.sprite.setSprite(sprites["lot"]);
                }
        }
    }
}
