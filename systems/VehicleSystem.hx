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
    private var sprites = new Map<Direction, Dynamic>();
    private var tileSystem:TileSystem;
    private var gameSystem:GameSystem;

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
        gameSystem = engine.getSystem(GameSystem);
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

            node.isometric.coords.x = v.fromCoords.x + (v.toCoords.x - v.fromCoords.x) * f;
            node.isometric.coords.y = v.fromCoords.y + (v.toCoords.y - v.fromCoords.y) * f;

            node.sprite.setLayer(0);
            node.sprite.setOrderInLayer(Std.int(-p.y) + 16);

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
                        gameSystem.playSound("collision");
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
                    var tn = ts.findDeliverableClient(v.fromCoords);

                    if(tn != null)
                    {
                        v.state = "delivering";
                        v.client = tn;
                        tn.tile.wantsPackage = false;
                        tn.tile.notificationEntity.get(StaticSprite2D).setAlpha(0);

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
                gameSystem.playSound("step");
            }
        }
        else if(node.vehicle.state == "delivering")
        {
            v.time += dt;

            if(v.time > 0.5)
            {
                v.hasPackage = false;
                v.state = "idling";
                gameSystem.onPackageDelivered();
                var p = v.client.entity.position;
                engine.getSystem(NotificationSystem).spawn("package", new Vector3(p.x, p.y + 64, 0));
            }
        }
    }

    private function onNodeAdded(node:VehicleNode):Void
    {
        var e:Entity = node.entity;
        var p = e.position;
        var ts = engine.getSystem(TileSystem);
        var c = node.vehicle.fromCoords;
        var v = IsometricSystem.getIsoFromCar(c.x, c.y);

        p.x = v.x * TileSystem.tileSize;
        p.y = v.y * TileSystem.tileSize;

        node.sprite.setLayer(0);
        node.sprite.setOrderInLayer(Std.int(-p.y) + 1);

        e.setPosition(p);

        node.sprite.setSprite(Gengine.getResourceCache().getSprite2D("garbage_NE.png", true));

        node.sprite.setHotSpot(new Vector2(0.5, 0));
        node.sprite.setUseHotSpot(true);
    }

    public function spawn(x:Int, y:Int)
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        e.add(new Vehicle());
        e.add(new Isometric());
        e.get(Vehicle).fromCoords = new IntVector2(x, y);
        e.get(Vehicle).toCoords = new IntVector2(x, y);
        e.get(Isometric).coords = new Vector2(x, y);
        e.get(Vehicle).state = "idling";

        engine.addEntity(e);
        return e;
    }
}
