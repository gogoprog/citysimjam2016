package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;

class CameraSystem extends ListIteratingSystem<CameraNode>
{
    private var input:Input;
    private var startPosition:Vector3;
    private var startMousePosition:IntVector2;
    private var zoom = 1.0;
    private var gameSystem:GameSystem;

    public var mouseWorldPosition:Vector3;
    public var cameraNode:CameraNode;

    public function new()
    {
        super(CameraNode, updateNode, onNodeAdded);
        input = Gengine.getInput();
    }

    override public function addToEngine(_engine:Engine)
    {
        super.addToEngine(_engine);
        gameSystem = _engine.getSystem(GameSystem);
    }

    private function onNodeAdded(node:CameraNode)
    {
        cameraNode = node;
    }

    private function updateNode(node:CameraNode, dt:Float):Void
    {
        if(!gameSystem.isPlaying())
        {
            return;
        }

        var button = 1 << 2;
        var e:Entity = node.entity;
        var p = e.position;
        var mousePosition = input.getMousePosition();

        if(input.getMouseButtonPress(button))
        {
            startPosition = p;
            startMousePosition = mousePosition;
        }
        else if(input.getMouseButtonDown(button))
        {
            p.x = startPosition.x - mousePosition.x + startMousePosition.x;
            p.y = startPosition.y + mousePosition.y - startMousePosition.y;
        }

        e.setPosition(p);

        mouseWorldPosition = node.camera.screenToWorldPoint(new Vector3(mousePosition.x / 1024, mousePosition.y / 768, 0));

        var w = input.getMouseMoveWheel();
        if(w != 0)
        {
            zoom += w / 10;

            node.camera.setZoom(zoom);
        }
    }
}
