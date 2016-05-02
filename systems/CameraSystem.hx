package systems;

import gengine.math.*;
import gengine.input.*;
import gengine.*;
import nodes.*;
import ash.tools.ListIteratingSystem;

class CameraSystem extends ListIteratingSystem<CameraNode>
{
    private var input:Input;

    public function new()
    {
        super(CameraNode, updateNode);
        input = Gengine.getInput();
    }

    private function updateNode(node:CameraNode, dt:Float):Void
    {
        var e:Entity = node.entity;
        var p = e.position;

        if(input.getMouseButtonPress(2))
        {
            trace('mousedo');
        }
        else if(input.getMouseButtonDown(3))
        {
            p.x += 100 * dt;
        }

        e.setPosition(p);
    }
}
