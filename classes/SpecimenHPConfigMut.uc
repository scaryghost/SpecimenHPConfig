class SpecimenHPConfigMut extends Mutator
    config(SpecimenHPConfig);

var() config int minNumPlayers;

function PostBeginPlay() {
    if (KFGameType(Level.Game) == none) {
        Destroy();
        return;
    }

}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local KFMonster monster;
    local Controller cIt;
    local int currNumPlayers;

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
    
    monster= KFMonster(Other);
    if (monster != None) {
        for(cIt= Level.ControllerList; cIt.Pawn != None; cIt= cIt.NextController) {
            if (cIt.bIsPlayer && cIt.Pawn != None && cIt.Pawn.Health > 0) {
                currNumPlayers++;
            }
        }
        if (currNumPlayers < minNumPlayers) {
            monster.Health*= hpScale(monster.PlayerCountHealthScale) / monster.NumPlayersHealthModifer();
            monster.HealthMax= monster.Health;
            monster.HeadHealth*= hpScale(monster.PlayerNumHeadHealthScale) / monster.NumPlayersHeadHealthModifer();

            if(Level.Game.NumPlayers == 1 && minNumPlayers > 1) {
                monster.MeleeDamage/= 0.75;
                monster.ScreamDamage/= 0.75;
                ///< These two variables aren't used by the FP but set them anyways
                monster.SpinDamConst/= 0.75;
                monster.SpinDamRand/= 0.75;
            }
        }
            
    }
    return true;
}

function float hpScale(float hpScale) {
    return 1.0 + (minNumPlayers - 1) * hpScale;
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
    FriendlyName="Specimen HP Config v1.1"
    Description="Scales the HP of the Killing Floor specimens"

    minNumPlayers= 1
}
