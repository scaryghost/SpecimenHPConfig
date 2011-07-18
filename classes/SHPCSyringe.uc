class SHPCSyringe extends Syringe;

simulated function PostBeginPlay() {
    Super(KFMeleeGun).PostBeginPlay();
    
    if(Role == ROLE_AUTHORITY) {
        log("it's the new syringe!");
        if (Level.Game.NumPlayers == 1 && Class'SpecimenHPConfig.SpecimenHPConfigMut'.default.minNumPlayers == 1) {
            HealBoostAmount= 50;
        } else {
            HealBoostAmount= default.HealBoostAmount;
        }
    }
}

defaultproperties { 
    PickupClass=Class'SpecimenHPConfig.SHPCSyringePickup'
}
