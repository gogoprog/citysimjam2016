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
import components.Vehicle;
import components.Tile;

class TileSystem extends ListIteratingSystem<TileNode>
{
    static public var tileSize = 50;
    private var engine:Engine;
    private var gameSystem:GameSystem;
    private var grid:Vector<Vector<TileNode>>;
    private var input:Input;
    private var mouseCoords = new IntVector2(1, 1);
    private var previousMouseCoords = new IntVector2(1, 1);
    private var sprites = new Map<String, Dynamic>();
    public var mapSize:Int;
    public var homeTileNode:TileNode;

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
        sprites["roadEndN"] = Gengine.getResourceCache().getSprite2D("roadEndNorth.png", true);
        sprites["roadEndE"] = Gengine.getResourceCache().getSprite2D("roadEndEast.png", true);
        sprites["roadEndS"] = Gengine.getResourceCache().getSprite2D("roadEndSouth.png", true);
        sprites["roadEndW"] = Gengine.getResourceCache().getSprite2D("roadEndWest.png", true);
        sprites["building"] = Gengine.getResourceCache().getSprite2D("building.png", true);
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);

        engine = _engine;

        gameSystem = engine.getSystem(GameSystem);
    }

    override public function update(dt:Float)
    {
        super.update(dt);

        if(!gameSystem.isPlaying())
        {
            return;
        }

        var button = 1;

        var coords = new IntVector2(0, 0);
        var mp = engine.getSystem(CameraSystem).mouseWorldPosition;

        var converted = IsometricSystem.getCarFromIso(mp.x, mp.y);
        mouseCoords.x = Math.floor((converted.x + tileSize/2) / tileSize);
        mouseCoords.y = Math.floor((converted.y + tileSize/2) / tileSize);

        if(areCoordsOnMap(previousMouseCoords))
        {
            grid[previousMouseCoords.x][previousMouseCoords.y].sprite.setAlpha(1);
        }

        if(areCoordsOnMap(mouseCoords))
        {
            grid[mouseCoords.x][mouseCoords.y].sprite.setAlpha(0.7);

            if(input.getMouseButtonDown(button))
            {
                var x = mouseCoords.x;
                var y = mouseCoords.y;
                var mustCheck = false;

                if(gameSystem.canAffordCurrentTool())
                {
                    if(gameSystem.getCurrentTool() == Road)
                    {
                        if(grid[x][y].tile.type == Dirt)
                        {
                            gameSystem.playSound("build");
                            grid[x][y].tile.type = Road;
                            gameSystem.useCurrentTool();
                            mustCheck = true;
                        }
                    }
                    else if(gameSystem.getCurrentTool() == Remove)
                    {
                        if(grid[x][y].tile.type == Road)
                        {
                            gameSystem.playSound("break");
                            grid[x][y].tile.type = Dirt;
                            gameSystem.useCurrentTool();
                            mustCheck = true;
                        }
                    }
                }

                if(mustCheck)
                {
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
        }

        previousMouseCoords.x = mouseCoords.x;
        previousMouseCoords.y = mouseCoords.y;
    }

    public function generateDemoMap()
    {
        generateMap(10, 3);

        for(i in 0...60)
        {
            var tn = getRandomTileNode(Dirt);
            tn.tile.type = Road;
        }

        checkAllTextures();

        for(i in 0...5)
        {
            var tn = getRandomTileNode(Road);
            var c = tn.tile.coords;
            engine.getSystem(VehicleSystem).spawn(c.x, c.y);
        }
    }

    public function generateMap(size:Int, clients:Int)
    {
        if(grid != null)
        {
            for(i in 0...grid.length)
            {
                for(j in 0...grid[i].length)
                {
                    engine.removeEntity(grid[i][j].entity);
                }
            }
        }

        mapSize = size;
        grid = new Vector<Vector<TileNode>>(size);

        for(i in 0...size)
        {
            grid[i] = new Vector<TileNode>(size);

            for(j in 0...size)
            {
                addTile(i, j);
            }
        }

        var tn = getRandomTileNode(Dirt);
        tn.tile.type = Home;
        checkTexture(tn);
        homeTileNode = tn;

        for(i in 0...clients)
        {
            var tn = getRandomTileNode(Dirt);
            tn.tile.type = Client;
            checkTexture(tn);
        }

        var c = IsometricSystem.getIsoFromCar(size * 0.5 * tileSize, size * 0.5 * tileSize);
        engine.getSystem(CameraSystem).cameraNode.entity.setPosition(new Vector3(c.x, c.y, 0));
    }

    private function checkAllTextures()
    {
        for(i in 0...mapSize)
        {
            for(j in 0...mapSize)
            {
                checkTexture(grid[i][j]);
            }
        }
    }

    private function getRandomTileNode(type:TileType):TileNode
    {
        while(true)
        {
            var x = Std.random(mapSize);
            var y = Std.random(mapSize);

            if(grid[x][y].tile.type == type)
            {
                return grid[x][y];
            }
        }

        return grid[0][0];
    }

    private function areCoordsOnMap(coords:IntVector2)
    {
        return coords.x >= 0 && coords.x < grid.length && coords.y >= 0 && coords.y < grid[coords.x].length;
    }

    public function isRoad(coords:IntVector2)
    {
        return isType(coords, Road);
    }

    public function isType(coords:IntVector2, type:TileType)
    {
        return areCoordsOnMap(coords) && grid[coords.x][coords.y].tile.type == type;
    }

    public function isNextToType(coords:IntVector2, type:TileType)
    {
        if(isType(new IntVector2(coords.x - 1, coords.y), type))
        {
            return true;
        }

        if(isType(new IntVector2(coords.x + 1, coords.y), type))
        {
            return true;
        }

        if(isType(new IntVector2(coords.x, coords.y - 1), type))
        {
            return true;
        }

        if(isType(new IntVector2(coords.x, coords.y + 1), type))
        {
            return true;
        }

        return false;
    }

    public function getToCoords(coords:IntVector2, direction:Direction)
    {
        var toCoords = new IntVector2(coords.x, coords.y);

        switch(direction)
        {
            case N:
                toCoords.x = coords.x;
                toCoords.y = coords.y + 1;
            case E:
                toCoords.x = coords.x + 1;
                toCoords.y = coords.y;
            case S:
                toCoords.x = coords.x;
                toCoords.y = coords.y - 1;
            case W:
                toCoords.x = coords.x - 1;
                toCoords.y = coords.y;
        }

        return toCoords;
    }

    private function onNodeAdded(node:TileNode):Void
    {
        var e:Entity = node.entity;
        var p = e.position;

        var c = node.tile.coords;
        var v = IsometricSystem.getIsoFromCar(c.x, c.y);

        p.x = v.x * tileSize;
        p.y = v.y * tileSize;

        e.setPosition(p);
        node.sprite.setLayer(0);
        node.sprite.setOrderInLayer(Std.int(-p.y));

        grid[c.x][c.y] = node;

        checkTexture(node);
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

            case Client:
                node.sprite.setSprite(sprites["building"]);

            case Home:
                node.sprite.setSprite(sprites["building"]);
                node.sprite.setColor(new Color(0.6, 0.6, 0, 1));

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
                else if(n)
                {
                    node.sprite.setSprite(sprites["roadEndN"]);
                }
                else if(w)
                {
                    node.sprite.setSprite(sprites["roadEndW"]);
                }
                else if(e)
                {
                    node.sprite.setSprite(sprites["roadEndE"]);
                }
                else if(s)
                {
                    node.sprite.setSprite(sprites["roadEndS"]);
                }
                else
                {
                    node.sprite.setSprite(sprites["lot"]);
                }
        }
    }
}
