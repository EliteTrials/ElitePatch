# ElitePatch

ElitePatch is a mutator/server-actor based patch for Unreal Tournament 2004 that aims to fix common issues, as well as implement enhancements to improve the quality of life of the game in general.

As it currently stands, it's more a proof of concept patch to demonstrate how UT2004 can be patched at run-time, this is possible thanks to [Unflect](https://github.com/EliotVU/UnrealScript-Unflect), an UnrealScript utility that lets us modify scripts at run-time.

## Patches

### Elite Patch

The Elite Patch intends to enhance the gameplay by taking away undesired features, such as but not limited to a rocket projectile exploding on players of the same team.

When applied, this patch will:

* Override Engine.Projectile.Touch
  - Disables Touch for allied pawns, this prevents the projectile from exploding on pawns of the same team.
    
* Override Engine.Projectile.HurtRadius
  - Disables HurtRadius for allied pawns, this prevents the projectile from dealing damage to pawns of the same team.
    
* Override XWeapons.InstantFire.DoTrace
  - Disables HitScan for allied pawns, this prevents the hitscan from being blocked by pawns of the same team. (experimental, currently limited to one blocking pawn)

#### Usage

Install by placing `ElitePatch.u` in `/UT2004Root/System/`

Enable by appending `ElitePatchActor` to your server's mutator option e.g.
```bat
?Mutator=ElitePatchActor.uc
```

## Credits

Inspired by [KFPatcher](https://github.com/InsultingPros/KFPatcher)
