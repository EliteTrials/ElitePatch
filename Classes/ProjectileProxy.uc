/** 
 * Patches the Projectile class to do:
 * * Don't explode on touch for pawns of the same team.
 * * Don't deal radius damage to pawns of the same team.
 */
class ProjectileProxy extends Engine.Projectile;

simulated singular event Touch(Actor Other)
{
    if (Class'InvariantFunctions'.static.AreFriendly(self, Pawn(Other))) {
        return;
    }

    SuperProjectileTouch(other);
}

// unmodified copy of Engine.Projectile.Touch
// Why copy? Because we cannot perform a super(Projectile).Touch(Other) if that function is hooked at run-time.
// -- so if we were to call it from here, we would cause a recursive loop.
private final simulated function SuperProjectileTouch(Actor other)
{
	local vector	HitLocation, HitNormal;

	if ( Other == None ) // Other just got destroyed in its touch?
		return;
	if ( Other.bProjTarget || Other.bBlockActors )
	{
		LastTouched = Other;
		if ( Velocity == vect(0,0,0) || Other.IsA('Mover') )
		{
			ProcessTouch(Other,Location);
			LastTouched = None;
			return;
		}

		if ( Other.TraceThisActor(HitLocation, HitNormal, Location, Location - 2*Velocity, GetCollisionExtent()) )
			HitLocation = Location;

		ProcessTouch(Other, HitLocation);
		LastTouched = None;
		if ( (Role < ROLE_Authority) && (Other.Role == ROLE_Authority) && (Pawn(Other) != None) )
			ClientSideTouch(Other, HitLocation);
	}
}

// modified copy of Engine.Projectile.HurtRadius
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
            //====PATCH
            // Disable damage to friendly pawns, but exclude ourselves, so we can still boost ourself etc
            if (Victims != Instigator && Class'InvariantFunctions'.static.AreFriendly(self, Pawn(Victims))) {
                continue;
            }
            //PATCH====
            
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);

			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
        //====PATCH
        if (Victims != Instigator && Class'InvariantFunctions'.static.AreFriendly(self, Pawn(Victims))) {
            return;
        }
        //PATCH====
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}

	bHurtEntry = false;
}