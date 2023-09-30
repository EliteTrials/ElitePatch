/* 
    Copyright (c) 2023 Eliot van Uytfanghe. All rights reserved.

    This work is licensed under the terms of the MIT license.  
    For a copy, see <https://opensource.org/licenses/MIT>.
*/
class ElitePatchActor extends CommonPatchActor
    config(ElitePatch);

defaultproperties
{
    // Disables Touch for allied pawns
    FunctionPatches(0)=(Source=Function'Engine.Projectile.Touch',Destination=Function'ProjectileProxy.Touch')
    // Disables HurtRadius for allied pawns
    FunctionPatches(1)=(Source=Function'Engine.Projectile.HurtRadius',Destination=Function'ProjectileProxy.HurtRadius')
    // Disables HitScan for allied pawns
    FunctionPatches(2)=(Source=Function'XWeapons.InstantFire.DoTrace',Destination=Function'InstantFireProxy.DoTrace')
}