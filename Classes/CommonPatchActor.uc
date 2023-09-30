/* 
    Copyright (c) 2023 Eliot van Uytfanghe. All rights reserved.

    This work is licensed under the terms of the MIT license.  
    For a copy, see <https://opensource.org/licenses/MIT>.
*/
class CommonPatchActor extends PatchActor
    config(CommonPatch);

defaultproperties
{
    /** Enhances how we deal with double click moves */
    LocalPatches(0)=(Source=Function'Engine.PlayerInput.CheckForDoubleClickMove',Destination=Function'PlayerInputProxy.CheckForDoubleClickMove')
}