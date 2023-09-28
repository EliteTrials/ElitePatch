/* 
    Copyright (c) 2023 Eliot van Uytfanghe. All rights reserved.

    This work is licensed under the terms of the MIT license.  
    For a copy, see <https://opensource.org/licenses/MIT>.
*/
class InvariantFunctions extends Object
    abstract;

static function bool IsFriendlyFire(WeaponFire source, Pawn other)
{
    return source.Level.Game.bTeamGame
        && source.Instigator != none 
        && other != none 
        && other.GetTeamNum() == source.Instigator.GetTeamNum();
        // && other.GetTeamNum() != 255; // No teams
}

/** Returns true if the instigator of @source is on the same team as @other */
static function bool AreFriendly(Actor source, Pawn other)
{
    return source.Level.Game.bTeamGame
        && source.Instigator != none 
        && other != none 
        && other.GetTeamNum() == source.Instigator.GetTeamNum();
        // && other.GetTeamNum() != 255; // No teams
}