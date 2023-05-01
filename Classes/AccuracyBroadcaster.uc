// Purpose      : show em your skills, go tiger go!
// Author       : Shtoyan
// Home repo    : https://github.com/InsultingPros/AccuracyBroadcaster
// License      : https://www.gnu.org/licenses/gpl-3.0.en.html
class AccuracyBroadcaster extends Mutator
    config(AccuracyBroadcaster);

// config variables
var private config string accuracyMessage;
// service variables
var public transient string cachedAccuracyMessage;
const Replace="KFMod.KFMonster.TakeDamage";
const With="hookMonster.TakeDamage";
var private UtilityText UtilityTextRef;
var private transient KFGameType KFGT;
var private transient bool bSendMessage;
// per player accuracy related variables
struct sPlayerRecord {
    var private string HASH;
    var private string NAME;
    var private int headshotsWave, headshotsGame;
    var private int bodyshotsWave, bodyshotsGame;
    var private int headshotsStreak, bodyshotsStreak;
    var private int headshotsCurrentStreak, bodyshotsCurrentStreak;
};
var private array <sPlayerRecord> PlayerRecord;
// lazy way of skipping DynamicLoadObject()
var private hookMonster hookMonster;
// revert function hook on level switch
var private transient bool bCleanedUp;
var private uFunction monsterTakeDamageRef;
var private array<private byte> monsterTakeDamageOriginalScript;

event PreBeginPlay() {
    super.PreBeginPlay();

    KFGT = KFGameType(level.game);
    if (KFGT == none) {
        warn("KFGameType is not found. Terminating!");
        // cleanup nothing if we even fail to spawn
        bCleanedUp = true;
        Destroy();
        return;
    }

    UtilityTextRef.mutname = class.outer.Name;
    HookMonsterTakeDamage();
    // pre color this message
    cachedAccuracyMessage = class'UtilityColor'.static.ParseTags(accuracyMessage);
    SetTimer(2, true);
}

private final function HookMonsterTakeDamage() {
    local uFunction A, B;
    local UFunctionCast FunctionCaster;

    FunctionCaster = new(none) class'UFunctionCast';

    A = FunctionCaster.Cast(function(FindObject(Replace, class'function')));
    if (A == none) {
        warn("Failed to process " $ Replace);
        return;
    }

    B = FunctionCaster.Cast(function(FindObject(With, class'function')));
    if (B == none) {
        warn("Failed to process " $ With);
        return;
    }

    // create a backup
    monsterTakeDamageRef = A;
    monsterTakeDamageOriginalScript = A.Script;

    // switch functions
    A.Script = B.Script;

    log("> Processing " $ Replace $ "    ---->    " $ With);
}

event Timer() {
    if (
        KFGT.IsInState('MatchOver') ||
        KFGT.IsInState('PendingMatch') ||
        KFGT.WaveNum < KFGT.InitialWave
    ) {
        return;
    }

    // usual wave
    if (KFGT.bWaveInProgress) {
        if (!bSendMessage) {
            bSendMessage = true;
            return;
        }
    } else {
        // trader time, send message to everyone, once
        if (bSendMessage) {
            BroadcastAccuracy();
            ResetWaveStats();
        }
        bSendMessage = false;
    }
}

private final static function AddPlayerRecord(string HASH, string NAME) {
    local sPlayerRecord sPlayerRecord;

    // warn("creating new record: name=" $ NAME $ ", hash=" $ HASH);
    sPlayerRecord.Hash = HASH;
    sPlayerRecord.NAME = NAME;
    default.PlayerRecord[default.PlayerRecord.length] = sPlayerRecord;
}

private final static function int FindPlayerRecord(KFPlayerController instigatedByController) {
    local int idx;
    local string HASH;

    HASH = instigatedByController.GetPlayerIDHash();
    for (idx = 0; idx < default.PlayerRecord.length; idx++) {
        if (HASH == default.PlayerRecord[idx].HASH) {
            return idx;
        }
    }

    // ok, nothing found. Create a new record and return last idx
    AddPlayerRecord(HASH, instigatedByController.PlayerReplicationInfo.PlayerName);
    return default.PlayerRecord.length - 1;
}

private final function ResetWaveStats() {
    local int idx;

    for (idx = 0; idx < default.PlayerRecord.length; idx++) {
        default.PlayerRecord[idx].headshotsWave = 0;
        default.PlayerRecord[idx].bodyshotsWave = 0;
    }
}

private final static function UpdatePlayerRecord(
    bool bIsHeadShot,
    KFPlayerController instigatedByController
) {
    local int idx;
    local sPlayerRecord sPlayerRecord;

    idx = FindPlayerRecord(instigatedByController);
    sPlayerRecord = default.PlayerRecord[idx];

    if (bIsHeadShot) {
        sPlayerRecord.headshotsWave += 1;
        sPlayerRecord.headshotsGame += 1;
        sPlayerRecord.headshotsCurrentStreak += 1;
        if (sPlayerRecord.headshotsCurrentStreak > sPlayerRecord.headshotsStreak) {
            sPlayerRecord.headshotsStreak = sPlayerRecord.headshotsCurrentStreak;
        }
        sPlayerRecord.bodyshotsCurrentStreak = 0;
    } else {
        sPlayerRecord.bodyshotsWave += 1;
        sPlayerRecord.bodyshotsGame += 1;
        sPlayerRecord.bodyshotsCurrentStreak += 1;
        if (sPlayerRecord.bodyshotsCurrentStreak > sPlayerRecord.bodyshotsStreak) {
            sPlayerRecord.bodyshotsStreak = sPlayerRecord.bodyshotsCurrentStreak;
        }
        sPlayerRecord.headshotsCurrentStreak = 0;
    }
    default.PlayerRecord[idx] = sPlayerRecord;
    // debug
    // log("sPlayerRecord.HASH: " $ sPlayerRecord.HASH $
    //     ", sPlayerRecord.headshotsWave: " $ sPlayerRecord.headshotsWave $
    //     ", sPlayerRecord.headshotsGame: " $ sPlayerRecord.headshotsGame $
    //     ", sPlayerRecord.bodyshotsWave: " $ sPlayerRecord.bodyshotsWave $
    //     ", sPlayerRecord.bodyshotsGame: " $ sPlayerRecord.bodyshotsGame $
    //     ", sPlayerRecord.headshotsCurrentStreak: " $ sPlayerRecord.headshotsCurrentStreak $
    //     ", sPlayerRecord.bodyshotsCurrentStreak: " $ sPlayerRecord.bodyshotsCurrentStreak $
    //     ", sPlayerRecord.headshotsStreak: " $ sPlayerRecord.headshotsStreak $
    //     ", sPlayerRecord.bodyshotsStreak: " $ sPlayerRecord.bodyshotsStreak
    // );
}

public final static function ProcessHeadshot(bool bIsHeadShot, controller instigatedByController) {
    if (instigatedByController.IsA('KFPlayerController')) {
        UpdatePlayerRecord(bIsHeadShot, KFPlayerController(instigatedByController));
    }
}

private final function BroadcastAccuracy() {
    local int idx;
    local array<string> messages;

    messages = GetAccuracyMessages();
    for (idx = 0; idx < messages.length; idx++) {
        if (messages[idx] != "NOOB") {
            BroadcastText(messages[idx]);
        }
    }
}

// send message to everyone and save to server log file
private final function BroadcastText(string message) {
    local Controller c;
    local PlayerController pc;

    for (c = level.controllerList; c != none; c = c.nextController) {
        if (!c.IsA('PlayerController')) {
            continue;
        }

        pc = PlayerController(C);
        // this is the WebAdmin, send clean text to him
        if (c.IsA('MessagingSpectator')) {
            pc.teamMessage(none, class'UtilityColor'.static.StripColor(message), class.outer.Name);
            continue;
        } else {
            pc.teamMessage(none, message, class.outer.Name);
        }
    }
}

private final function array<string> GetAccuracyMessages() {
    local array<string> result;
    local int idx;
    // local float f;

    // clock(f);
    for (idx = 0; idx < default.PlayerRecord.length; idx++) {
        result[result.length] = UtilityTextRef.InsertVariables(
            cachedAccuracyMessage,
            default.PlayerRecord[idx]
        );
    }
    // unclock(f);
    // warn("execution time: " $ f);

    return result;
}

function Mutate(string MutateString, PlayerController sender) {
    local int i;
    local array<string> wordsArray;
    local string command, mod;
    local array<string> modArray;

    super.Mutate(MutateString, sender);

    // https://github.com/InsultingPros/FakedPlus/blob/main/Classes/FakedPlus.uc
    // ignore empty cmds and dont go further
    Split(MutateString, " ", wordsArray);
    if (wordsArray.Length == 0) {
        return;
    }

    // do stuff with our cmd
    command = wordsArray[0];
    if (wordsArray.Length > 1) {
        mod = wordsArray[1];
    } else {
        mod = "";
    }

    while (i + 1 < wordsArray.Length || i < 10) {
        if (i + 1 < wordsArray.Length) {
            modArray[i] = wordsArray[i + 1];
        } else {
            modArray[i] = "";
        }
        i += 1;
    }

    if (command ~= "HELP" || command ~= "HLP" || command ~= "HALP") {
        UtilityTextRef.PrintHelp(sender);
        return;
    } else if (command ~= "accuracy" || command ~= "acc") {
        if (sender.PlayerReplicationInfo.bOnlySpectator) {
            UtilityTextRef.SendMessage(
                sender,
                "^w^You are a spectator, not allowed to use this command!"
            );
            return;
        }

        UtilityTextRef.PrintPlayerStats(
            sender,
            self,
            default.PlayerRecord[FindPlayerRecord(KFPlayerController(sender))]
        );
        return;
    } else if (command ~= "credits") {
        UtilityTextRef.PrintCredits(sender);
    }
}

// cleanup
function ServerTraveling(string URL, bool bItems) {
    SafeCleanup();
    super.ServerTraveling(URL, bItems);
}

function Destroyed() {
    SafeCleanup();
    super.Destroyed();
}

private final function SafeCleanup() {
    if (bCleanedUp) {
        return;
    }
    monsterTakeDamageRef.Script = monsterTakeDamageOriginalScript;
    bCleanedUp = true;
    warn("All functions reverted to original state!");
}

defaultproperties {
    GroupName="KF-AccuracyBroadcaster"
    FriendlyName="Headshot Accuracy Broadcaster"
    Description="Prints headshot accuracy at trader time start. Use it to show your skill to everyone!"

    // quick access objects
    Begin Object Class=UtilityText Name=UtilityText_Instance
    End Object
    UtilityTextRef=UtilityText_Instance;

    // defaults in case someone forgets about config
    accuracyMessage="^b^%NAME% ^w^wave headshot accuracy: ^y^%ACC_WAVE%^w^, best headshot streak: ^g^%HS_STREAK%^w^."
}