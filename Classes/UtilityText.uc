// Purpose      : text related stuff
// Author       : Shtoyan
// Home repo    : https://github.com/InsultingPros/AccuracyBroadcaster
// License      : https://www.gnu.org/licenses/gpl-3.0.en.html
class UtilityText extends Object
    dependson(AccuracyBroadcaster);

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

public final function PrintHelp(PlayerController pc, AccuracyBroadcaster mut) {
    SendMessage(pc, mut, "^r^" $ mut.class.outer.Name $ " ^w^helper:");
    SendMessage(pc, mut, "^w^> Available mutate commands:");
    SendMessage(pc, mut, "    ^w^> ^y^acc / accuracy ^w^- print player accuracy stats.");
    SendMessage(pc, mut, "    ^w^> ^y^credits ^w^- who made this shit.");
}

public final function PrintPlayerStats(
    PlayerController pc,
    AccuracyBroadcaster mut,
    AccuracyBroadcaster.sPlayerRecord sPlayerRecord
) {
    SendMessage(pc, mut, "^w^Your accuracy stats:");
    SendMessage(pc, mut, "    Wave accuracy: ^y^" $ int((float(sPlayerRecord.headshotsWave) /
        float(sPlayerRecord.bodyshotsWave + sPlayerRecord.headshotsWave)) * 100) $ "%");
    SendMessage(pc, mut, "    Game accuracy: ^y^" $ int((float(sPlayerRecord.headshotsGame) /
        float(sPlayerRecord.bodyshotsGame + sPlayerRecord.headshotsGame)) * 100) $ "%");
    SendMessage(pc, mut, "    Wave headshots: ^y^" $ sPlayerRecord.headshotsWave);
    SendMessage(pc, mut, "    Game headshots: ^y^" $ sPlayerRecord.headshotsGame);
    SendMessage(pc, mut, "    Wave bodyshots: ^y^" $ sPlayerRecord.bodyshotsWave);
    SendMessage(pc, mut, "    Game bodyshots: ^y^" $ sPlayerRecord.bodyshotsGame);
    SendMessage(pc, mut, "    Current headshot streak: ^y^" $ sPlayerRecord.headshotsCurrentStreak);
    SendMessage(pc, mut, "    Current bodyshot streak: ^y^" $ sPlayerRecord.bodyshotsCurrentStreak);
    SendMessage(pc, mut, "    Best headshot streak: ^y^" $ sPlayerRecord.headshotsStreak);
    SendMessage(pc, mut, "    Best bodyshot streak: ^y^" $ sPlayerRecord.bodyshotsStreak);
}

public final function PrintCredits(PlayerController pc, AccuracyBroadcaster mut) {
    SendMessage(pc, mut, "^r^" $ mut.class.outer.Name);
    SendMessage(pc, mut, "^w^> Author: ^b^NikC-");
    SendMessage(pc, mut, "^w^> Home Repo: github.com/InsultingPros/AccuracyBroadcaster");
}

public final function SendMessage(PlayerController pc, AccuracyBroadcaster mut, coerce string text) {
    pc.teamMessage(none, class'UtilityColor'.static.ParseTags(text), mut.class.outer.Name);
}