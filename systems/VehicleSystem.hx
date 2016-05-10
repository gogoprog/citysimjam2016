package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;
import ash.fsm.EntityStateMachine;
import gengine.components.*;
import systems.*;
import components.*;
import components.Vehicle;

class VehicleSystem extends ListIteratingSystem<VehicleNode>
{
    private var engine:Engine;
    private var offsetY = 10;
    private var sprites = new Map<Direction, Dynamic>();
    private var tileSystem:TileSystem;

    public function new()
    {
        super(VehicleNode, updateNode, onNodeAdded);

        sprites[N] = Gengine.getResourceCache().getSprite2D("garbage_NW.png", true);
        sprites[E] = Gengine.getResourceCache().getSprite2D("garbage_NE.png", true);
        sprites[S] = Gengine.getResourceCache().getSprite2D("garbage_SE.png", true);
        sprites[W] = Gengine.getResourceCache().getSprite2D("garbage_SW.png", true);
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);
        engine = _engine;
        tileSystem = engine.getSystem(TileSystem);

        spawn(2, 3);
        spawn(5, 6);
        spawn(6, 6);
        spawn(8, 2);
    }

    private function updateNode(node:VehicleNode, dt:Float):Void
    {
        var ts = tileSystem;
        var v = node.vehicle;
        var coords = v.fromCoords;
        var x = coords.x;
        var y = coords.y;

        if(node.vehicle.state == "idling")
        {
            v.toCoords.x = x;
            v.toCoords.y = y;

            v.toCoords = ts.getToCoords(coords, v.direction);

            if(ts.isRoad(v.toCoords))
            {
                node.sprite.setSprite(sprites[v.direction]);

                v.time = 0;
                v.state = "moving";
            }
            else
            {
                for(d in Type.allEnums(Direction))
                {
                    if((d.getIndex() + 2) % 4 == v.direction.getIndex())
                    {
                        continue;
                    }

                    v.toCoords = ts.getToCoords(coords, d);

                    if(ts.isRoad(v.toCoords))
                    {
                        node.sprite.setSprite(sprites[d]);
                        v.direction = d;
                        v.time = 0;
                        v.state = "moving";
                        break;
                    }
                }

                if(v.state == "idling")
                {
                    var d = Direction.createByIndex((v.direction.getIndex() + 2) % 4);

                    v.toCoords = ts.getToCoords(coords, d);

                    if(ts.isRoad(v.toCoords))
                    {
                        node.sprite.setSprite(sprites[d]);
                        v.direction = d;
                        v.time = 0;
                        v.state = "moving";
                    }
                }
            }
        }
        else if(node.vehicle.state == "moving")
        {
            var p = node.entity.position;
            var duration = 0.5;

            v.time += dt;

            if(v.time >= duration)
            {
                v.time = duration;
                v.state = "idling";
            }

            var f = v.time / duration;

            v.currentCoords.x = v.fromCoords.x + (v.toCoords.x - v.fromCoords.x) * f;
            v.currentCoords.y = v.fromCoords.y + (v.toCoords.y - v.fromCoords.y) * f;

            var converted = TileSystem.getIsoFromCar(v.currentCoords.x, v.currentCoords.y);

            p.x = converted.x * TileSystem.tileSize;
            p.y = converted.y * TileSystem.tileSize;

            node.sprite.setLayer(cast(-p.y) + 1);
            p.y += offsetY;

            node.entity.setPosition(p);

            for(otherNode in nodeList)
            {
                if(otherNode != node)
                {
                    var otherPos = otherNode.entity.position;
                    var dx = Math.abs(otherPos.x - p.x);
                    var dy = Math.abs(otherPos.y - p.y);

                    if(dx < 15 && dy < 15)
                    {
                        v.state = "crashed";
                        otherNode.vehicle.state = "crashed";
                        break;
                    }
                }
            }

            if(v.state == "idling")
            {
                v.fromCoords.x = v.toCoords.x;
                v.fromCoords.y = v.toCoords.y;

                if(!v.hasPackage)
                {
                    if(ts.isNextToType(v.fromCoords, Home))
                    {
                        v.state = "loading";
                        v.time = 0;
                    }
                }
                else
                {
                    if(ts.isNextToType(v.fromCoords, Client))
                    {
                        v.state = "delivering";
                        v.time = 0;
                    }
                }
            }
        }
        else if(node.vehicle.state == "loading")
        {
            v.time += dt;

            if(v.time > 0.5)
            {
                v.hasPackage = true;
                v.state = "idling";
                trace("Loaded!");
            }
        }
        else if(node.vehicle.state == "delivering")
        {
            v.time += dt;

            if(v.time > 0.5)
            {
                v.hasPackage = false;
                v.state = "idling";
                trace("Delivered!");
            }
        }
    }

    private function onNodeAdded(node:VehicleNode):Void
    {
        var e:Entity = node.entity;
        var p = e.position;

        var c = node.vehicle.fromCoords;
        var v = TileSystem.getIsoFromCar(c.x, c.y);

        p.x = v.x * TileSystem.tileSize;
        p.y = v.y * TileSystem.tileSize;

        node.sprite.setLayer(cast(-p.y) + 1);
        p.y += offsetY;

        e.setPosition(p);

        node.sprite.setSprite(Gengine.getResourceCache().getSprite2D("garbage_NE.png", true));
    }

    public function spawn(x:Int, y:Int)
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        e.add(new Vehicle());
        e.get(Vehicle).fromCoords = new IntVector2(x, y);
        e.get(Vehicle).toCoords = new IntVector2(x, y);
        e.get(Vehicle).currentCoords = new Vector2(x, y);
        e.get(Vehicle).state = "idling";

        engine.addEntity(e);
        return e;
    }
}
