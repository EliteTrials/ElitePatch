/* 
    Copyright (c) 2023 Eliot van Uytfanghe. All rights reserved.

    This work is licensed under the terms of the MIT license.  
    For a copy, see <https://opensource.org/licenses/MIT>.
*/
#include UnflectPackage.uci
class PatchActor extends Mutator
    config(Patch);

const Unflect = Class'Unflect';

var() const array<struct FunctionPatch {
    var() Function Source, Destination;
}> FunctionPatches;

simulated event PreBeginPlay()
{
    super.PreBeginPlay();

    Log(self @ "is being activated.");
    ApplyFunctionPatches();

    if (Role < ROLE_Authority) {
        ListenToLevelChange();
    }
}

simulated event Destroyed()
{
    super.Destroyed();

    UndoFunctionPatches();
}

function ServerTraveling(String URL, Bool bItems)
{
    super.ServerTraveling(URL, bItems);

    if (Role == ROLE_Authority) {
        UndoFunctionPatches();
    }
}

private simulated function ListenToLevelChange()
{
    local PlayerController localPlayer;

    localPlayer = Level.GetLocalPlayerController();
    if (localPlayer != none 
     && localPlayer.Player != none 
     && localPlayer.Player.InteractionMaster != none)
    {
        Log("Listening to event 'LevelChange'");
        PatchInteraction(localPlayer.Player.InteractionMaster.AddInteraction(string(Class'PatchInteraction'), localPlayer.Player)).Patcher = self;
    }
}

public final simulated function ApplyFunctionPatches()
{
    local int i;

    for (i = 0; i < FunctionPatches.Length; ++i) {
        Log("    Applying patch" @ i @ FunctionPatches[i].Source @ FunctionPatches[i].Destination);
        Unflect.static.HookFunction(
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Source), 
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Destination)
        );
    }
}

public final simulated function UndoFunctionPatches()
{
    local int i;

    for (i = 0; i < FunctionPatches.Length; ++i) {
        Log("    Undoing patch" @ i @ FunctionPatches[i].Source @ FunctionPatches[i].Destination);
        Unflect.static.HookFunction(
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Destination),
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Source)
        );
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true

    bAddToServerPackages=true
}