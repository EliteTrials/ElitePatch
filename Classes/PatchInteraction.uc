/* 
    Copyright (c) 2023 Eliot van Uytfanghe. All rights reserved.

    This work is licensed under the terms of the MIT license.  
    For a copy, see <https://opensource.org/licenses/MIT>.
*/
class PatchInteraction extends Interaction;

var PatchActor Patcher;

event NotifyLevelChange()
{
    Patcher.UndoFunctionPatches();
    Patcher = none;
	Master.RemoveInteraction(self);
}