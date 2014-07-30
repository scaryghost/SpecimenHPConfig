class SpecimenHPConfigMut extends Mutator
    config(SpecimenHPConfig);

var() globalconfig int minNumPlayers;
var int maxAllowedPlayers;      ///< Cap it the number of players at 6
var int minAllowedPlayers;      ///< Must be set to min 1
var array<Syringe> syringes;

function PostBeginPlay() {
    if (KFGameType(Level.Game) == none) {
        Destroy();
        return;
    }
    minNumPlayers= max(minAllowedPlayers, min(minNumPlayers, maxAllowedPlayers));
    Log("SpecimenHPConfig - Scaling specimen hp by a minimum player count of:"@minNumPlayers);
}

function Timer() {
    local int i;

    for(i= 0; i < syringes.Length; i++) {
        syringes[i].HealBoostAmount= syringes[i].default.HealBoostAmount;
    }
    syringes.Length= 0;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
    local KFMonster monster;
    local Controller cIt;
    local int currNumPlayers;

    /**
     *  This solution works for the monsters even though KFMonster.PostBeginPlay()
     *  is called after CheckReplacement().  Mathematically, the code:
     *      1) multiplies the monster's health by a ratio of 'newModifier / oldModifier'
     *      2) multiply back in 'oldModifier' in KFMonster.PostBeginPlay leavin gonl 'newModifier'
     *         as the health scale value
     */
    monster= KFMonster(Other);
    if (monster != None) {
        for(cIt= Level.ControllerList; cIt != None; cIt= cIt.NextController) {
            if (cIt.bIsPlayer && cIt.Pawn != None && cIt.Pawn.Health > 0) {
                currNumPlayers++;
            }
        }
        /** Only apply the scaling if the number of living players is less than the amount set by the mutator */
        if (currNumPlayers < minNumPlayers) {
            monster.Health*= hpScale(monster.PlayerCountHealthScale) / monster.NumPlayersHealthModifer();
            monster.HealthMax= monster.Health;
            monster.HeadHealth*= hpScale(monster.PlayerNumHeadHealthScale) / monster.NumPlayersHeadHealthModifer();

            /** Appropriately adjust other variables dependent on the player count */
            if(Level.Game.NumPlayers == 1 && minNumPlayers > 1) {
                monster.MeleeDamage/= 0.75;
                monster.ScreamDamage/= 0.75;
                ///< These two variables aren't used by the FP but set them anyways
                monster.SpinDamConst/= 0.75;
                monster.SpinDamRand/= 0.75;
            }
        }
    } else if (Level.Game.NumPlayers == 1 && minNumPlayers > 1 && Syringe(Other) != none) {
        syringes[syringes.Length]= Syringe(Other);
        SetTimer(1.0, false);
    }
    return true;
}

function float hpScale(float hpScale) {
    return 1.0 + (minNumPlayers - 1) * hpScale;
}

static function FillPlayInfo(PlayInfo PlayInfo) {
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting("Specimen HP Config", "minNumPlayers","Min Number of Players", 0, 1, "Text", "0.1;1:6");
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
    FriendlyName="Specimen HP Config v1.2.1"
    Description="Scales the HP of the Killing Floor specimens"

    minNumPlayers= 1
    maxAllowedPlayers= 6
    minAllowedPlayers= 1
}
