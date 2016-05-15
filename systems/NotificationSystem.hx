package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;
import gengine.components.*;
import systems.*;
import components.*;

class NotificationSystem extends ListIteratingSystem<NotificationNode>
{
    private var engine:Engine;

    public function new()
    {
        super(NotificationNode, updateNode, onNodeAdded);
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);

        engine = _engine;
    }

    private function updateNode(node:NotificationNode, dt:Float):Void
    {
        var p = node.entity.position;
        var n = node.notification;

        n.time += dt;

        p.y = n.startPosition.y - Math.cos(n.time / 1) * 64 + 64;

        if(!n.infinite)
        {
            node.sprite.setAlpha(1 - n.time / 1);

            if(n.time > 1)
            {
                engine.removeEntity(node.entity);
                return;
            }
        }

        node.entity.position = p;
    }

    private function onNodeAdded(node:NotificationNode):Void
    {
        node.notification.startPosition = node.entity.position;
        node.notification.time = 0;
    }

    public function spawn(which:String, where:Vector3)
    {
        var e = new Entity();
        e.add(new StaticSprite2D());
        e.add(new Notification());
        e.get(StaticSprite2D).setSprite(Gengine.getResourceCache().getSprite2D(which + ".png", true));
        e.get(StaticSprite2D).setLayer(100000);
        e.setPosition(where);

        engine.addEntity(e);
    }
}
