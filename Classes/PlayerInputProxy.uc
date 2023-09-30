class PlayerInputProxy extends Engine.PlayerInput
    abstract
    cacheexempt;

const this = Class'PlayerInputProxy';

// @PATCH DO NOT ACCESS THESE DIRECTLY, use "this.default" instead
var float BufferedClickTimer; 
var Actor.eDoubleClickDir BufferedClickDir;

function Actor.eDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	local Actor.eDoubleClickDir DoubleClickMove, OldDoubleClickDir;

    if (!bEnableDodging)
    {
        DoubleClickMove = DCLICK_None;
        return DoubleClickMove;
    }

    if ( DoubleClickDir == DCLICK_Active )
		DoubleClickMove = DCLICK_Active;
	else
		DoubleClickMove = DCLICK_None;
	if (DoubleClickTime > 0.0)
	{
		if ( DoubleClickDir == DCLICK_Active )
		{
			if ( (Pawn != None) && (Pawn.Physics == PHYS_Walking) )
			{
				DoubleClickTimer = 0.0 - DeltaTime;
				DoubleClickDir = DCLICK_Done;
			}
		}
        // @PATCH check for buffered click
		else if ( DoubleClickDir != DCLICK_Done )
		{
        processNextClickNow:
            OldDoubleClickDir = DoubleClickDir;
			DoubleClickDir = DCLICK_None;

			if (bEdgeForward && (bWasForward || this.default.BufferedClickDir == DCLICK_Forward))
				DoubleClickDir = DCLICK_Forward;
			else if (bEdgeBack && (bWasBack || this.default.BufferedClickDir == DCLICK_Back))
				DoubleClickDir = DCLICK_Back;
			else if (bEdgeLeft && (bWasLeft || this.default.BufferedClickDir == DCLICK_Left))
				DoubleClickDir = DCLICK_Left;
			else if (bEdgeRight && (bWasRight || this.default.BufferedClickDir == DCLICK_Right))
				DoubleClickDir = DCLICK_Right;

			if ( DoubleClickDir == DCLICK_None)
				DoubleClickDir = OldDoubleClickDir;
			else if ( DoubleClickDir != OldDoubleClickDir )
            {
				// DoubleClickTimer = DoubleClickTime + 0.5 * DeltaTime;
				DoubleClickTimer = DoubleClickTime; // @PATCH
            }
			else 
            {
                DoubleClickMove = DoubleClickDir;
            }
		}

        // @PATCH
        this.default.BufferedClickTimer -= DeltaTime;
        if (this.default.BufferedClickTimer <= -0.5 && this.default.BufferedClickDir != DCLICK_None) {
            this.default.BufferedClickDir = DCLICK_None;
            // ClientMessage("Reseting buffered click");
        }

		if (DoubleClickDir == DCLICK_Done)
		{
            OldDoubleClickDir = this.default.BufferedClickDir;
            // @PATCH let's buffer double clicks as soon as the interval timer has occurred (i.e. after landing from a dodge)
            if (bEdgeForward)
                this.default.BufferedClickDir = DCLICK_Forward;
            else if (bEdgeBack)
                this.default.BufferedClickDir = DCLICK_Back;
            else if (bEdgeLeft)
                this.default.BufferedClickDir = DCLICK_Left;
            else if (bEdgeRight)
                this.default.BufferedClickDir = DCLICK_Right;

            if (OldDoubleClickDir != this.default.BufferedClickDir) {
                this.default.BufferedClickTimer = 0.0;
                // ClientMessage("Buffering click" @ OldDoubleClickDir);
            }

			DoubleClickTimer = FMin(DoubleClickTimer-DeltaTime,0.0);
			if (DoubleClickTimer <= -0.35)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;

                // @PATCH let's not wait for the next tick, process the dbl click as soon as possible.
                goto processNextClickNow;
			}
		}
		else if ((DoubleClickDir != DCLICK_None) && (DoubleClickDir != DCLICK_Active))
		{
			DoubleClickTimer -= DeltaTime;
			if (DoubleClickTimer <= 0.0)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
                
                goto processNextClickNow;
			}
		}
	}
	return DoubleClickMove;
}