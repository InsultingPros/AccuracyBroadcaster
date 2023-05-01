// Purpose      : text related stuff
// Author       : Shtoyan
// Home repo    : https://github.com/InsultingPros/AccuracyBroadcaster
// License      : https://www.gnu.org/licenses/gpl-3.0.en.html
class UtilityText extends Object
    dependson(AccuracyBroadcaster);

var public transient name mutName;
// `const`s just to make variable check faster
const PNAME="%NAME%";
// wave
const ACCURACY_WAVE="%ACC_WAVE%";
const HEADSHOTS_WAVE="%HS_WAVE%";
const BODYHOTS_WAVE="%BS_WAVE%";
// overall
const ACCURACY_GAME="%ACC_GAME%";
const HEADSHOTS_GAME="%HS_GAME%";
const BODYHOTS_GAME="%BS_GAME%";
// streaks
const STREAK_HEADSHOTS="%HS_STREAK%";
const STREAK_BODYSHOTS="%BS_STREAK%";

public final function string InsertVariables(
    string cachedAccuracyMessage,
    AccuracyBroadcaster.sPlayerRecord sPlayerRecord
) {
    local float headshotAccuracyWave;

    headshotAccuracyWave = float(sPlayerRecord.headshotsWave) /
        float(sPlayerRecord.bodyshotsWave + sPlayerRecord.headshotsWave);
    // only show this for players with >70% accuracy
    if (headshotAccuracyWave < 0.7f) {
        // warn("too low accuracy, NOOB detected!");
        return "NOOB";
    }

    ReplaceText(
        cachedAccuracyMessage,
        PNAME,
        sPlayerRecord.NAME
    );

    // wave
    ReplaceText(
        cachedAccuracyMessage,
        ACCURACY_WAVE,
        string(int(headshotAccuracyWave * 100)) $ "%"
    );
    ReplaceText(
        cachedAccuracyMessage,
        HEADSHOTS_WAVE,
        string(sPlayerRecord.headshotsWave)
    );
    ReplaceText(
        cachedAccuracyMessage,
        BODYHOTS_WAVE,
        string(sPlayerRecord.bodyshotsWave)
    );

    // overall
    ReplaceText(
        cachedAccuracyMessage,
        ACCURACY_GAME,
        string(int((float(sPlayerRecord.headshotsGame) /
            float(sPlayerRecord.bodyshotsGame + sPlayerRecord.headshotsGame)) * 100)) $ "%"
    );
    ReplaceText(
        cachedAccuracyMessage,
        HEADSHOTS_GAME,
        string(sPlayerRecord.headshotsGame)
    );
    ReplaceText(
        cachedAccuracyMessage,
        BODYHOTS_GAME,
        string(sPlayerRecord.bodyshotsGame)
    );

    // streaks
    ReplaceText(
        cachedAccuracyMessage,
        STREAK_HEADSHOTS,
        string(sPlayerRecord.headshotsStreak)
    );
    ReplaceText(
        cachedAccuracyMessage,
        STREAK_BODYSHOTS,
        string(sPlayerRecord.bodyshotsStreak)
    );

    return cachedAccuracyMessage;
}

public final function PrintHelp(PlayerController pc) {
    SendMessage(pc, "^r^" $ mutName $ " ^w^helper:");
    SendMessage(pc, "^w^> Available mutate commands:");
    SendMessage(pc, "    ^w^> ^y^acc / accuracy ^w^- print player accuracy stats.");
    SendMessage(pc, "    ^w^> ^y^credits ^w^- who made this shit.");
}

public final function PrintPlayerStats(
    PlayerController pc,
    AccuracyBroadcaster mut,
    AccuracyBroadcaster.sPlayerRecord sPlayerRecord
) {
    SendMessage(pc, "^w^Your accuracy stats:");
    SendMessage(pc, "    Wave accuracy: ^y^" $ int((float(sPlayerRecord.headshotsWave) /
        float(sPlayerRecord.bodyshotsWave + sPlayerRecord.headshotsWave)) * 100) $ "%");
    SendMessage(pc, "    Game accuracy: ^y^" $ int((float(sPlayerRecord.headshotsGame) /
        float(sPlayerRecord.bodyshotsGame + sPlayerRecord.headshotsGame)) * 100) $ "%");
    SendMessage(pc, "    Wave headshots: ^y^" $ sPlayerRecord.headshotsWave);
    SendMessage(pc, "    Game headshots: ^y^" $ sPlayerRecord.headshotsGame);
    SendMessage(pc, "    Wave bodyshots: ^y^" $ sPlayerRecord.bodyshotsWave);
    SendMessage(pc, "    Game bodyshots: ^y^" $ sPlayerRecord.bodyshotsGame);
    SendMessage(pc, "    Current headshot streak: ^y^" $ sPlayerRecord.headshotsCurrentStreak);
    SendMessage(pc, "    Current bodyshot streak: ^y^" $ sPlayerRecord.bodyshotsCurrentStreak);
    SendMessage(pc, "    Best headshot streak: ^y^" $ sPlayerRecord.headshotsStreak);
    SendMessage(pc, "    Best bodyshot streak: ^y^" $ sPlayerRecord.bodyshotsStreak);
}

public final function PrintCredits(PlayerController pc) {
    SendMessage(pc, "^r^" $ mutName);
    SendMessage(pc, "^w^> Author: ^b^NikC-");
    SendMessage(pc, "^w^> Home Repo: github.com/InsultingPros/AccuracyBroadcaster");
}

public final function SendMessage(PlayerController pc, coerce string text) {
    pc.teamMessage(none, class'UtilityColor'.static.ParseTags(text), mutName);
}