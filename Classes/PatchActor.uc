/* 
    Copyright (c) 2023 Eliot van Uytfanghe. All rights reserved.

    This work is licensed under the terms of the MIT license.  
    For a copy, see <https://opensource.org/licenses/MIT>.
*/
#include UnflectPackage.uci
class PatchActor extends Mutator
    cacheexempt
    hidedropdown
    abstract;

const Unflect = Class'Unflect';

/** Patches to be applied as soon as possible, will be reversed as soon the level changes. */
var() const array<struct FunctionPatch { var() Function Source, Destination; }> 
    /** Patches to be applied to clients only or to a standalone client. */
    LocalPatches, 
    /** Patches to be applied to both clients and the server. i.e. a simulated function. */
    FunctionPatches, // SimulatedPatches?
    /** Patches to be applied to the server or to a standalone client, for functions that require an authority role. */
    AuthorityPatches;

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

    if (Role == ROLE_Authority) {
        for (i = 0; i < AuthorityPatches.Length; ++i) {
            Log("    Applying authority patch" @ i @ AuthorityPatches[i].Source @ AuthorityPatches[i].Destination);
            Unflect.static.HookFunction(
                Class'UFunction'.static.AsFunction(AuthorityPatches[i].Source), 
                Class'UFunction'.static.AsFunction(AuthorityPatches[i].Destination)
            );
        }
    }

    for (i = 0; i < FunctionPatches.Length; ++i) {
        Log("    Applying simulated patch" @ i @ FunctionPatches[i].Source @ FunctionPatches[i].Destination);
        Unflect.static.HookFunction(
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Source), 
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Destination)
        );
    }

    if (Level.NetMode != NM_DedicatedServer) {
        for (i = 0; i < LocalPatches.Length; ++i) {
            Log("    Applying local patch" @ i @ LocalPatches[i].Source @ LocalPatches[i].Destination);
            Unflect.static.HookFunction(
                Class'UFunction'.static.AsFunction(LocalPatches[i].Source), 
                Class'UFunction'.static.AsFunction(LocalPatches[i].Destination)
            );
        }
    }
}

public final simulated function UndoFunctionPatches()
{
    local int i;

    if (Level.NetMode != NM_DedicatedServer) {
        for (i = 0; i < LocalPatches.Length; ++i) {
            Log("    Undoing local patch" @ i @ LocalPatches[i].Source @ LocalPatches[i].Destination);
            Unflect.static.HookFunction(
                Class'UFunction'.static.AsFunction(LocalPatches[i].Destination),
                Class'UFunction'.static.AsFunction(LocalPatches[i].Source)
            );
        }
    }

    for (i = 0; i < FunctionPatches.Length; ++i) {
        Log("    Undoing simulated patch" @ i @ FunctionPatches[i].Source @ FunctionPatches[i].Destination);
        Unflect.static.HookFunction(
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Destination),
            Class'UFunction'.static.AsFunction(FunctionPatches[i].Source)
        );
    }

    if (Role == ROLE_Authority) {
        for (i = 0; i < AuthorityPatches.Length; ++i) {
            Log("    Undoing authority patch" @ i @ AuthorityPatches[i].Source @ AuthorityPatches[i].Destination);
            Unflect.static.HookFunction(
                Class'UFunction'.static.AsFunction(AuthorityPatches[i].Destination),
                Class'UFunction'.static.AsFunction(AuthorityPatches[i].Source)
            );
        }
    }
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true

    bAddToServerPackages=true
}