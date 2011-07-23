class SpecimenHPConfigMut extends Mutator
    config(SpecimenHPConfig);

var() config int minNumPlayers;

function PostBeginPlay() {
    local KFGameType KF;

    KF = KFGameType(Level.Game);

    if (KF == none) {
        Destroy();
        return;
    }

}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local float newHp, newHeadHp;

    /**
     *  This solution works for the monsters even though KFMonster.PostBeginPlay()
     *  is called after CheckReplacement().  Mathematically, the code divides by 
     *  the current HealthModifer, multiplies the dividend with the new scale if larger, 
     *  then multiplies the current HealthModifer once PostBeginPlay() is called.
     *
     *  tempHp= currHp / oldHealthModifer();
     *  tempHp*= newHealthModifer(); = (currHp / oldHealthModifer()) * newHealthModifer()
     *
     *  ### if (tempHp > currHp) ###
     *  currHp= tempHp
     *  ### else ###
     *  currHp= currHp
     *
     *  ### PostBeginPlay() called ###
     *  currHp*= oldHealthModifer() = currHp * newHealthModifer() (Modified behavior)
     *  ### or (if tempHp <= currHp) ###
     *  currHp*= oldHealthModifer() (Original behavior)
     */
    
    if (KFMonster(Other) != none) {
        newHp= KFMonster(Other).Health / KFMonster(Other).NumPlayersHealthModifer();
        newHp*= numPlayersScaleHp(KFMonster(Other).PlayerCountHealthScale);
        newHeadHp= KFMonster(Other).HeadHealth / KFMonster(Other).NumPlayersHeadHealthModifer();
        newHeadHp*= numPlayersScaleHp(KFMonster(Other).PlayerNumHeadHealthScale);
        if(newHp > KFMonster(Other).Health) {
            KFMonster(Other).Health= newHp;
            KFMonster(Other).HealthMax= newHp;
            KFMonster(Other).HeadHealth= newHeadHp;
            if(Level.Game.NumPlayers == 1 && minNumPlayers > 1) {
                KFMonster(Other).MeleeDamage/= 0.75;
            }
            if(minNumPlayers > 6) {
                /**
                 *  Increase the specimen's damgae by 5% for each 
                 *  person beyond 6
                 */
                KFMonster(Other).MeleeDamage*= (minNumPlayers-6)*0.05;
            }
        }
    } else if (SyringePickup(Other) != none) {
        log("It's a pickup!");
        ReplaceWith(Other,"SpecimenHPConfig.SHPCSyringePickup");
        return false;
    } else if (KFHumanPawn(Other) != none) {
        log("It's a human pawn!");
        KFHumanPawn(Other).RequiredEquipment[3]= "SpecimenHPConfig.SHPCSyringe";
    }
    return true;
}

function float numPlayersScaleHp(float hpScale) {
    return 1.0+(minNumPlayers-1)*hpScale;
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("Specimen HP Config", "minNumPlayers","Min Number of Players", 0, 1, "Text", "0.1;1:100");
}

static event string GetDescriptionText(string property) {
    switch(property) {
        case "minNumPlayers":
            return "Sets the minimum number of players used when scaling specimen hp based on player count";
        default:
            return Super.GetDescriptionText(property);
    }
}


defaultproperties {
	GroupName="KFSpecimenHPMut"
	FriendlyName="Specimen HP Config"
	Description="Scales the HP of the Killing Floor specimens.  This is version 1.0.0"

    minNumPlayers= 1

