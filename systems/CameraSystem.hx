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

    public function new()
    {
        super(CameraNode, updateNode);
        input = Gengine.getInput();
    }

    private function updateNode(node:CameraNode, dt:Float):Void
    {
        var button = 1;
        var e:Entity = node.entity;
        var p = e.position;

        if(input.getMouseButtonPress(button))
        {
            startPosition = p;
            startMousePosition = input.getMousePosition();
        }
        else if(input.getMouseButtonDown(button))
        {
            var mousePosition = input.getMousePosition();
            p.x = startPosition.x - mousePosition.x + startMousePosition.x;
            p.y = startPosition.y + mousePosition.y - startMousePosition.y;
        }

        e.setPosition(p);
    }
}
