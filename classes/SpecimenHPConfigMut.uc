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
        }
        
    }
    return true;
}

function float numPlayersScaleHp(float hpScale) {
    return 1.0+(minNumPlayers-1)*hpScale;
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
	FriendlyName="Specimen HP Config"
	Description="Scales the HP of the specimens.  This is version 1.0.0"

    minNumPlayers= 1

