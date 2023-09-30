class InstantFireProxy extends InstantFire
    abstract
    cacheexempt;

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, Last;
    local int Damage;
    // local bool bDoReflect;
    local int ReflectNum;

	MaxRange();

    ReflectNum = 0;
    while (true)
    {
        X = Vector(Dir);
        End = Start + TraceRange * X;

        Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            //====PATCH
            // Pass right through!
            if (Class'InvariantFunctions'.static.IsFriendlyFire(self, xPawn(Other))) {
                // Start = HitLocation;
                Last = Other;
                Last.bBlockZeroExtentTraces = false;
                Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);
                Last.bBlockZeroExtentTraces = true;
            }
            else {
                if (bReflective && xPawn(Other) != none && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
                {
                    ++ReflectNum;
                    HitNormal = Vect(0,0,0);
                }
                else if ( !Other.bWorldGeometry )
                {
                    Damage = DamageMin;
                    if ( (DamageMin != DamageMax) && (FRand() > 0.5) )
                        Damage += Rand(1 + DamageMax - DamageMin);
                    Damage = Damage * DamageAtten;

                    // Update hit effect except for pawns (blood) other than vehicles.
                    if ( Other.IsA('Vehicle') || (!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) )
                        WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other, HitLocation, HitNormal);

                    Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
                    HitNormal = Vect(0,0,0);
                }
                else if ( WeaponAttachment(Weapon.ThirdPersonActor) != None )
                {
                    WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
                }
            }
            //PATCH====
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
			WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum - 1);

        if (ReflectNum > 0 && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
}