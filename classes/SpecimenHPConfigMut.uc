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
    local float newHp, newHeadHp;
    local KFMonster monster;
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
        monster= KFMonster(Other);
        newHp= monster.Health / monster.NumPlayersHealthModifer() * hpScale(monster.PlayerCountHealthScale);
        newHeadHp= monster.HeadHealth / monster.NumPlayersHeadHealthModifer() * hpScale(monster.PlayerNumHeadHealthScale);
        if(newHp > monster.Health) {
            monster.Health= newHp;
            monster.HealthMax= newHp;
            monster.HeadHealth= newHeadHp;
            if(Level.Game.NumPlayers == 1 && minNumPlayers > 1) {
                monster.MeleeDamage/= 0.75;
            }
        }
    }
    return true;
}

function float hpScale(float hpScale) {
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

