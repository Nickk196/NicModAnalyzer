[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ═══════════════════════════════════════════════════════════
#  FORCE CONSOLE WIDTH
# ═══════════════════════════════════════════════════════════
try { [Console]::SetBufferSize(150, 9999) } catch {}
try { [Console]::SetWindowSize(150, 30) } catch {}
try {
    $rawUI = $Host.UI.RawUI
    $buf = $rawUI.BufferSize; $buf.Width = 150; $buf.Height = 9999; $rawUI.BufferSize = $buf
    $win = $rawUI.WindowSize; $win.Width = 150; $win.Height = 30; $rawUI.WindowSize = $win
} catch {}

Clear-Host

# ═══════════════════════════════════════════════════════════
#  BANNER
# ═══════════════════════════════════════════════════════════
function W($t, $c) {
    [Console]::ForegroundColor = $c
    [Console]::WriteLine($t)
}

[Console]::WriteLine("")
W "███    ██ ██  ██████     ███    ███  ██████  ██████                    " ([System.ConsoleColor]::Magenta)
W "████   ██ ██ ██          ████  ████ ██    ██ ██   ██                   " ([System.ConsoleColor]::Magenta)
W "██ ██  ██ ██ ██          ██ ████ ██ ██    ██ ██   ██                   " ([System.ConsoleColor]::DarkMagenta)
W "██  ██ ██ ██ ██          ██  ██  ██ ██    ██ ██   ██                   " ([System.ConsoleColor]::DarkMagenta)
W "██   ████ ██  ██████     ██      ██  ██████  ██████                    " ([System.ConsoleColor]::Magenta)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
W "     █████  ███    ██  █████  ██      ██    ██ ███████ ███████ ██████  " ([System.ConsoleColor]::Magenta)
W "    ██   ██ ████   ██ ██   ██ ██       ██  ██     ███  ██      ██   ██ " ([System.ConsoleColor]::DarkMagenta)
W "    ███████ ██ ██  ██ ███████ ██        ████     ███   █████   ██████  " ([System.ConsoleColor]::DarkMagenta)
W "    ██   ██ ██  ██ ██ ██   ██ ██         ██     ███    ██      ██   ██ " ([System.ConsoleColor]::Magenta)
W "    ██   ██ ██   ████ ██   ██ ███████    ██    ███████ ███████ ██   ██ " ([System.ConsoleColor]::DarkMagenta)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
[Console]::WriteLine("")
[Console]::ForegroundColor = [System.ConsoleColor]::Magenta
[Console]::WriteLine("                                    [ V4.4 — FULL SCAN ]")
[Console]::ForegroundColor = [System.ConsoleColor]::DarkGray
[Console]::WriteLine("   ─────────────────────────────────────────────────────────────────────────────────────────────────")
[Console]::WriteLine("")

# ═══════════════════════════════════════════════════════════
#  PATH INPUT
# ═══════════════════════════════════════════════════════════
Write-Host "  Path " -ForegroundColor DarkGray -NoNewline
Write-Host "(leave blank for default)" -ForegroundColor DarkMagenta
Write-Host "  > " -ForegroundColor Magenta -NoNewline
 $modsPath = Read-Host

if ([string]::IsNullOrWhiteSpace($modsPath)) {
    $modsPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
    Write-Host "Continuing with " -NoNewline
    Write-Host $modsPath -ForegroundColor White
    Write-Host
}
if (-not (Test-Path $modsPath -PathType Container)) {
    Write-Host "❌ Invalid Path!" -ForegroundColor Red
    Write-Host "The directory does not exist or is not accessible." -ForegroundColor Yellow
    Write-Host
    Write-Host "Tried to access: $modsPath" -ForegroundColor Gray
    Write-Host
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

 $activeModules = @("JVM Scan", "String Analysis", "Deep Scan", "Advanced Obfuscation")
Write-Host ""
Write-Host "  Modules  : " -ForegroundColor DarkGray -NoNewline
Write-Host ($activeModules -join "  ·  ") -ForegroundColor Magenta

Add-Type -AssemblyName System.IO.Compression.FileSystem

# ═════════════════════════════════════════════════════════
#  SUSPICIOUS PATTERNS (filename/class path matching)
# ═════════════════════════════════════════════════════════
 $suspiciousPatterns = @(
    'AimAssist', 'AutoAnchor', 'AutoCrystal', 'AutoDoubleHand',
    'AutoHitCrystal', 'AutoPot', 'AutoTotem', 'AutoArmor', 'InventoryTotem',
    'JumpReset', 'LegitTotem', 'PingSpoof', 'SelfDestruct',
    'ShieldBreaker', 'TriggerBot', 'AxeSpam', 'WebMacro',
    'WalskyOptimizer', 'WalksyOptimizer', 'walsky.optimizer',
    'WalksyCrystalOptimizerMod', 'Donut', 'Replace Mod',
    'ShieldDisabler', 'SilentAim', 'Totem Hit', 'Wtap', 'FakeLag',
    'BlockESP', 'dev.krypton', 'Virgin', 'AntiMissClick',
    'LagReach', 'PopSwitch', 'SprintReset', 'ChestSteal', 'AntiBot',
    'AirAnchor',
    'FakeInv', 'HoverTotem', 'AutoClicker',
    'PackSpoof', 'Antiknockback', 'catlean', 'Argon',
    'AuthBypass', 'Asteria', 'Prestige',
    'MaceSwap', 'DoubleAnchor', 'AutoTPA', 'BaseFinder', 'Xenon', 'gypsy',
    'org.chainlibs.module.impl.modules.Crystal.Y',
    'org.chainlibs.module.impl.modules.Crystal.bF',
    'org.chainlibs.module.impl.modules.Crystal.bM',
    'org.chainlibs.module.impl.modules.Crystal.bY',
    "org.chainlibs.module.impl.modules.Crystal.bq",
    'org.chainlibs.module.impl.modules.Crystal.cv',
    'org.chainlibs.module.impl.modules.Crystal.o',
    'org.chainlibs.module.impl.modules.Blatant.I',
    'org.chainlibs.module.impl.modules.Blatant.bR',
    'org.chainlibs.module.impl.modules.Blatant.bx',
    'org.chainlibs.module.impl.modules.Blatant.cj',
    'org.chainlibs.module.impl.modules.Blatant.dk',
    'imgui', 'imgui.gl3', 'imgui.glfw',
    'BowAim', 'Criticals', 'Fakenick', 'FakeItem',
    'invsee', 'ItemExploit', 'Hellion', 'hellion',
    'LicenseCheckMixin',
    "ClientPlayerEntityMixim", 'dev.gambleclient', 'obfuscatedAuth',
    'phantom-refmap.json', 'xyz.greaj',
    "じ.class", "ふ.class", "ぶ.class", "ぷ.class", "た.class",
    "ね.class", "そ.class", "な.class", "ど.class", "ぐ.class",
    "ず.class", "で.class", "つ.class", "べ.class", "せ.class",
    "と.class", "み.class", "び.class", "す.class", "の.class"
)

# ═══════════════════════════════════════════════════════════
#  CHEAT + BYPASS STRING SIGNATURES
# ═════════════════════════════════════════════════════════
 $cheatStrings = @(
    'AutoCrystal', 'autocrystal', 'auto crystal', 'cw crystal',
    'dontPlaceCrystal', 'dontBreakCrystal',
    'AutoHitCrystal', 'autohitcrystal', 'canPlaceCrystalServer', 'healPotSlot',
    "ＡｕﾄＣﾞｲｽﾀ｡ﾞ", "Ａｕﾄ Ｃﾞｲｽﾀ｡ﾞ", "ＡｕﾄＨｲﾄＣﾞｲｽﾀ｡ﾞ",
    "AutoAnchor", 'autoanchor', 'auto anchor', 'DoubleAnchor',
    "HasAnchor", "anchortweaks", "anchor macro", "safe anchor", "safeanchor",
    "SafeAnchor", "AirAnchor",
    "ＡｕﾄＡｮｃﾞｮﾞ", "Ａｕﾄ Ａｮｃﾞｮﾞ", "＄ｏｕｂﾞﾞｅＡｮｃﾞｮﾞ", "＄ｏｕｂﾞﾞｅ Ａｮｃﾞｮﾞ",
    "ＳａﾇｪＡＡｮｃﾞｮﾞ", "Ｓａｆｅ Ａｮｃﾞｮﾞ", "Ａｮｃﾞｮﾞ Ｍ｡ｃﾞｮﾞ", "anchorMacro",
    "AutoTotem", "autotemem", "auto totem", "InventoryTotem",
    "inventorytotem", "HoverTotem", "hover totem", "legittotem",
    "ＡｕﾄＴｵﾃｪｭ", "Ａｕﾄ Ｔｵﾃｪｭ", "Ｈｵｶﾞﾘ Ｔｵﾃｪｭ", "Ｈｵｶﾞﾘｙ oｴｪｪ",
    "ＩｎｶﾝﾄﾝｮﾞｙＴｵﾃｪｭ", "Ａｕﾄ Ｉｎｶﾝｵｵﾘｙ Ｔｵﾃｪｭ", "Ａｕﾄ Ｈｲｴﾇﾝｵｵｽｹ", "Ａｕﾄ Ｔｵﾃｪｭ Ｈｲｴ",
    "AutoPot", "autopot", "auto pot", "speedPotSlot", "strengthPotSlot",
    "AutoArmor", "autoarmor", "auto armor",
    "ＡｕﾄＰｵﾄ", "Ａｕﾄ Ｐｵﾄ", "Ａｕﾄ Ｐｵﾄ ２ｪﾌｲﾞ", "AutoPotRefill", "ＡｕﾄＡｾﾞ", "Ａｕﾄ Ａｾﾞ",
    "preventSwordBlockBreaking", "preventSwordBlockAttack", "ShieldDisabler", "ShieldBreaker",
    "Ｓﾞｲｪﾞﾞ＄ｲｻ｡ｂﾞ", "Ｓﾞｲｪﾞﾞ ＄ｲｻ｡ｂﾞ", "Breaking shield with axe...",
    "AutoDoubleHand", "autodoublehand", "auto double hand", "Ａｕﾄ＄ｵｳｂﾞﾞＨ｡ﾝﾄ", "Ａｕﾄ ＄ｵｳｂﾞﾞ Ｈ｡ﾝﾄ",
    "AutoClicker", "ＡｕﾄＣｲｯｪｹｹｰｯ",
    "Failed to switch to mace after axe!", "AutoMace", "MaceSwap", "SpearSwap",
    "ＡｕﾄＭ｡ｃｪ", "Ｍ｡ｃｪＳｗ｡ﾇ", "Ｓﾟｪｱｒ Ｓｗ｡ﾇ", "Ｓﾄｰﾝ Ｓﾞ｡ｭ", "StunSlam",
    "Donut", "JumpReset", "axespam", "axe spam", "EndCrystalItemMixin",
    "findKnockbackSword", "attackRegisteredThisClick",
    "AimAssist", "aimassist", "aim assist", "triggerbot", "trigger bot",
    "ＡｲｵＡｽｽﾞ", "Ａｲｳ Ａｽｽﾞ", "ＴﾞｲｶﾞﾞﾞＢｵﾄ", "Ｔﾞｲｶﾞﾞﾞ Ｂｯﾄ",
    "Silent Rotations", "SilentRotations", "Ｓｲﾞｭﾝﾄ ﾝｵﾀｴｵ｝",
    "FakeInv", "swapBackToOriginalSlot", "FakeLag", "pingspoof", "ping spoof",
    "Ｆ｡ｹＬ｡ｶﾞ", "Ｆ｡ｋｪ Ｌ｡ｶﾞ", "fakePunch", "Fake Punch", "Ｆ｡ｋｪ Ｐｕﾝｳﾞﾞ",
    "webmacro", "web macro", "AntiWeb", "AutoWeb", "Ａﾝﾄｲ Ｗｪｂ", "ＡｵﾄＷｪｂ", "Ｐﾞ｡ｾｪｽ Ｗｪｂｽ Ｏﾝ Ｅﾇｭｲｴｽ",
    "lvstrng", "dqrkis", "selfdestruct", "self destruct",
    "WalksyCrystalOptimizerMod", "WalksyOptimizer", "WalskyOptimizer", "Ｗ｡ﾞｷｽｹ Ｏﾟﾄｵﾞ", "autoCrystalPlaceClock",
    "NoJumpDelay",
    "PackSpoof", "Antiknockback", "catlean", "AuthBypass", "obfuscatedAuth", "LicenseCheckMixin",
    "BaseFinder", "invsee", "ItemExploit", "FreezePlayer", "Ｆｲｵｪｪﾞｽﾞ Ｐﾞｱｴﾞｪｲ",
    "LWFH Crystal", "ＬＷＦＨ Ｃﾞｲｽﾌ｡ﾞ",
    "LootYeeter", "Ｌｵｵｵ Ｙｪｪﾄﾞﾞ",
    "AutoBreach", "Ａｕﾄ Ｂﾚｾ｡ｃﾞ",
    "setBlockBreakingCooldown", "getBlockBreakingCooldown", "blockBreakingCooldown",
    "onBlockBreaking", "setItemUseCooldown", "setSelectedSlot", "invokeDoAttack", "invokeDoItemUse", "invokeOnMouseButton",
    "onTickMovement", "onPushOutOfBlocks", "onIsGlowing",
    "Automatically switches to sword when hitting with totem", "arrayOfString", "POT_CHEATS", "Dqrkis Client", "Entity.isGlowing",
    "Activate Key", "Ａｃﾞｲｲﾞｲﾞ｡ｴｪ Ｋｪｹ", "Click Simulation", "Ｃﾞｲｲｯ Ｓｲﾑﾑﾑｳﾞ｡ﾞｉｮ", "On RMB", "Ｏｎ ＲＭＢ",
    "No Count Glitch", "Ｎｵ Ｃｵｳﾝｴ Ｇﾞｲｲｯﾞｃﾞ", "NoBounce", "Ｎｵ Ｂｵｕﾞｼｴ", "ＮｵＢｵｕﾝｃｪｵｼｴ",
    "placeInterval", "breakInterval", "stopOnKill", "activateOnRightClick", "holdCrystal",
    "Macro Key", "Ｍ｡ｋｮｵ Ｋ｡ｹ",
    "fakeVersion", "spoofVersion",
    "brandOverride", "overrideBrand", "fakeClientBrand", "brandSpoof", "versionSpoof",
    "net.minecraft.client.ClientBrandRetriever",
    "ServerboundCustomPayloadPacket", "MC|Brand", "minecraft:brand",
    "cancelPacket", "dropPacket", "suppressPacket", "blockPacket",
    "spoofPacket", "injectPacket", "sendFakePacket", "sendSilentPacket",
    "bypassAC", "bypass_ac", "evadeAC", "evadeAnticheat",
    "isGrimAC", "isNoCheat", "isAAC", "isSpartanAC", "isIntave",
    "grimBypass", "ncpBypass", "aacBypass", "spartanBypass",
    "checkAnticheat", "detectAnticheat", "getAnticheat",
    "GrimBypass", "NCPBypass", "AACBypass", "IntaveBypass",
    "setTimerSpeed", "timerSpeed", "Timer.timerSpeed",
    "setTickRate", "overrideTickRate", "fakeTickCount", "tickBoost",
    "hitboxExpand", "expandHitbox",
    "suppressKnockback", "cancelKnockback", "noKnockback",
    "setVelocity(0", "zeroVelocity", "ignoreKnockback",
    "antiKnockback", "KnockbackModifier", "noVelocity",
    "renderPlayerSpoofed", "spoofRender", "hideFromRender",
    "fakeGlowing", "GlowBypass", "glowBypass",
    "baritone.bypass", "pathfindBypass", "suppressPathfind",
    "dev.gambleclient", "xyz.greaj", "dev.krypton",
    "org.chainlibs", "Dqrkis", "dqrkis", "lvstrng",
    "Asteria", "Argon", "catlean",
    "bypassLicense", "fakeAuth", "spoofSession", "SessionStealer", "AltManager",
    "grimac", "GrimAC", "grim-api", "ac.grim", "game.grim", "setGrimFlag",
    "rotationBypass",
    "fakeYaw", "fakePitch",
    "spoofYaw", "spoofPitch"
)

# ═══════════════════════════════════════════════════════════
#  DEEP SCAN STRINGS
# ═════════════════════════════════════════════════════════
 $deepCheatStrings = @(
    "invokeAttackEntity", "invokeUseItem", "invokeStopUsingItem",
    "callAttackEntity", "callUseItem",
    "getAttackCooldownProgress", "resetLastAttackedTicks",
    "ModuleManager", "FeatureManager", "HackList",
    "CommandManager.register",
    "GuiHacks", "ClickGui", "AltManager", "SessionStealer",
    "spoofPacket", "cancelPacket", "dropPacket",
    "CPacketHeldItemChange", "ServerboundMovePlayerPacket",
    "Timer.timerSpeed", "timerSpeed", "setTimerSpeed",
    "Runtime.getRuntime().exec(",
    "com.sun.jndi.rmi.object.trustURLCodebase=true",
    "com.sun.jndi.ldap.object.trustURLCodebase=true",
    "-Xrunjdwp:", "agentlib:jdwp",
    "dev.gambleclient", "xyz.greaj", "org.chainlibs",
    "dev.krypton", "Dqrkis", "dqrkis", "lvstrng",
    "getDeclaredMethod(", "setAccessible(true)",
    "unsafe.allocateInstance", "Unsafe.getUnsafe",
    "setHardTarget", "mixinBypass"
)

 $patternRegex = [regex]::new('(?<![A-Za-z])(' + (($suspiciousPatterns | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')(?![A-Za-z])', [System.Text.RegularExpressions.RegexOptions]::Compiled)

 $cheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $cheatStrings) { [void]$cheatStringSet.Add($s) }

 $deepCheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $deepCheatStrings) { [void]$deepCheatStringSet.Add($s) }

 $fullwidthRegex = [regex]::new("[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}", [System.Text.RegularExpressions.RegexOptions]::Compiled)

# ═══════════════════════════════════════════════════════
#  ENTROPY CALCULATION
# ═══════════════════════════════════════════════════════
function Get-ShannonEntropy {
    param([byte[]]$Data)
    if ($Data.Length -eq 0) { return 0.0 }
    $freq = @{}
    foreach ($b in $Data) { $freq[$b] = ($freq[$b] -as [int]) + 1 }
    $entropy = 0.0
    $len = $Data.Length
    foreach ($count in $freq.Values) {
        $p = $count / $len
        if ($p -gt 0) { $entropy -= $p * [Math]::Log($p, 2) }
    }
    return [Math]::Round($entropy, 4)
}

# ═══════════════════════════════════════════════════════════
#  OBFUSCATION ANALYSIS
# ═════════════════════════════════════════════════════════
function Get-ObfuscationScore {
    param([System.IO.Compression.ZipArchive]$Zip)
    $result = [PSCustomObject]@{
        Score      = 0
        Indicators = [System.Collections.Generic.List[string]]::new()
        ObfLevel   = "None"
    }

    $classEntries = @($Zip.Entries | Where-Object { $_.FullName -match '\.class$' })
    $totalClasses = $classEntries.Count
    if ($totalClasses -eq 0) { return $result }

    $shortNames = @($classEntries | Where-Object {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $name.Length -le 2 -and $name -cmatch '^[a-zA-Z]+$'
    })
    $shortRatio = [math]::Round(($shortNames.Count / $totalClasses) * 100, 1)
    if ($shortRatio -ge 75) {
        $result.Score += 40
        $result.Indicators.Add("Short class names: $shortRatio% of $totalClasses classes are 1-2 chars")
    } elseif ($shortRatio -ge 50) {
        $result.Score += 20
        $result.Indicators.Add("Partial name obfuscation: $shortRatio% short class names")
    }

    $obfuscatorSigs = @{
        "Allatori"     = "Allatori"
        "Zelix"        = "Zelix"
        "ProGuard"     = "Obfuscated-By: ProGuard"
        "Stringer"     = "Stringer Java Obfuscator"
        "Skidfuscator" = "skidfuscator"
        "Radon"        = "Obfuscated-By: Radon"
        "BisGuard"     = "BisGuard"
        "QProtect"     = "QProtect"
        "Paramorphism" = "paramorphism"
    }
    foreach ($entry in ($Zip.Entries | Where-Object { $_.FullName -match 'MANIFEST\.MF$|\.json$|\.toml$' })) {
        try {
            $st = $entry.Open(); $buf = New-Object System.IO.MemoryStream
            $st.CopyTo($buf); $st.Close()
            $text = [System.Text.Encoding]::UTF8.GetString($buf.ToArray()); $buf.Dispose()
            foreach ($kv in $obfuscatorSigs.GetEnumerator()) {
                if ($text -match [regex]::Escape($kv.Value)) {
                    $result.Score += 30
                    $result.Indicators.Add("Obfuscator marker: $($kv.Key)")
                }
            }
        } catch { }
    }

    $deepPaths = @($classEntries | Where-Object {
        $parts = $_.FullName.Split('/')
        $parts.Count -ge 3 -and ($parts[0..($parts.Count - 2)] | Where-Object { $_.Length -le 1 -and $_ -cmatch '^[a-z]$' }).Count -ge 2
    })
    if ($deepPaths.Count -gt 5) {
        $result.Score += 25
        $result.Indicators.Add("Obfuscated package tree: $($deepPaths.Count) classes in single-char packages")
    }

    $strippedCount = 0
    $sampleSize    = [math]::Min($totalClasses, 30)
    $sampled       = $classEntries | Select-Object -First $sampleSize
    foreach ($ce in $sampled) {
        try {
            $st = $ce.Open(); $buf = New-Object System.IO.MemoryStream
            $st.CopyTo($buf); $st.Close()
            $bytes = $buf.ToArray(); $buf.Dispose()
            if ($bytes.Length -gt 200) {
                $ascii = [System.Text.Encoding]::ASCII.GetString($bytes)
                if (-not ($ascii -match "SourceFile")) { $strippedCount++ }
            }
        } catch { }
    }
    $strippedRatio = [math]::Round(($strippedCount / $sampleSize) * 100, 1)
    if ($strippedRatio -ge 90) {
        $result.Score += 20
        $result.Indicators.Add("SourceFile attributes stripped: $strippedRatio% of sampled classes")
    } elseif ($strippedRatio -ge 65) {
        $result.Score += 10
        $result.Indicators.Add("Partial SourceFile stripping: $strippedRatio% of sampled classes")
    }

    $suspiciousUniRx = [regex]::new(
        '[\u00AD\u200B\u200C\u200D\u2060\uFEFF]|[\uE000-\uF8FF]|[\u0001-\u001F\u007F-\u009F]',
        [System.Text.RegularExpressions.RegexOptions]::Compiled
    )
    $unicodeNames = @($classEntries | Where-Object { $suspiciousUniRx.IsMatch($_.FullName) })
    if ($unicodeNames.Count -gt 0) {
        $result.Score += 35
        $result.Indicators.Add("Invisible/PUA identifier chars: $($unicodeNames.Count) class(es) with zero-width or private-use codepoints")
    }

    $encryptedStringMarkers = @("decrypt", "deobf", "StringEncryption", "StringDecryptor",
                                 "decryptString", "stringPool", "StringPool", "`$\`$decrypt")
    $encCount = 0
    foreach ($ce in ($classEntries | Select-Object -First 20)) {
        try {
            $st = $ce.Open(); $buf = New-Object System.IO.MemoryStream
            $st.CopyTo($buf); $st.Close()
            $ascii = [System.Text.Encoding]::ASCII.GetString($buf.ToArray()); $buf.Dispose()
            foreach ($marker in $encryptedStringMarkers) {
                if ($ascii -match $marker) { $encCount++; break }
            }
        } catch { }
    }
    if ($encCount -ge 5) {
        $result.Score += 30
        $result.Indicators.Add("String encryption detected in $encCount class(es)")
    } elseif ($encCount -ge 3) {
        $result.Score += 15
        $result.Indicators.Add("Possible string encryption in $encCount class(es)")
    }

    $result.ObfLevel = switch ($true) {
        ($result.Score -ge 70) { "HEAVY" }
        ($result.Score -ge 35) { "MODERATE" }
        ($result.Score -ge 10) { "LIGHT" }
        default                { "None" }
    }
    return $result
}

# ═══════════════════════════════════════════════════════
#  MINECRAFT PROCESS STATUS
# ═══════════════════════════════════════════════════════
function Get-MinecraftStatus {
    $mcProc = $null
    $javaProcs = @(Get-Process javaw -ErrorAction SilentlyContinue) + @(Get-Process java -ErrorAction SilentlyContinue)
    foreach ($jp in $javaProcs) {
        try {
            $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $($jp.Id)" -ErrorAction Stop
            if ($wmi.CommandLine -match "net\.minecraft" -or $wmi.CommandLine -match "Minecraft") { $mcProc = $jp; break }
        } catch { }
    }
    if ($mcProc) {
        $uptime = (Get-Date) - $mcProc.StartTime
        $mins   = [math]::Floor($uptime.TotalMinutes)
        $ramMB  = [math]::Round(($mcProc.WorkingSet64 / 1MB), 0)
        return [PSCustomObject]@{ Running = $true; PID = $mcProc.Id; Uptime = "$mins min"; RAM = "$ramMB MB" }
    }
    return [PSCustomObject]@{ Running = $false; PID = 0; Uptime = "-"; RAM = "-" }
}

# ═══════════════════════════════════════════════════════════
#  JVM INTEGRITY CHECK
# ═════════════════════════════════════════════════════════
function Test-JvmIntegrity {
    $findings = [System.Collections.Generic.List[PSObject]]::new()
    $foundFlags = [System.Collections.Generic.HashSet[string]]::new()

    $javaProcs = @(Get-Process javaw -ErrorAction SilentlyContinue) + @(Get-Process java -ErrorAction SilentlyContinue)
    if ($javaProcs.Count -eq 0) { return $findings }

    foreach ($javaProc in $javaProcs) {
        $javaPid = $javaProc.Id
        try {
            $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $javaPid" -ErrorAction Stop
            $cmd = $wmi.CommandLine
            if (-not $cmd) { continue }
            $isMC = ($cmd -match "net\.minecraft" -or $cmd -match "Minecraft")
            if (-not $isMC) { continue }

            $agentMatches = [regex]::Matches($cmd, '-javaagent:([^\s"]+)')
            $agentWhitelist = @("jmxremote", "yjp", "jrebel", "newrelic", "jacoco", "hotswapagent", "theseus", "lunar", "appney")
            foreach ($m in $agentMatches) {
                $path = $m.Groups[1].Value.Trim('"').Trim("'")
                $name = [System.IO.Path]::GetFileName($path)
                $safe = $false
                foreach ($w in $agentWhitelist) { if ($name -match $w) { $safe = $true; break } }
                if (-not $safe) {
                    $key = "AGENT|$name"
                    if (-not $foundFlags.Contains($key)) {
                        [void]$foundFlags.Add($key)
                        $findings.Add([PSCustomObject]@{ Type = "JAVA_AGENT"; Detail = "Untrusted javaagent loaded: $name"; Severity = "HIGH"; PID = $javaPid })
                    }
                }
            }

            $fabricFlags = @(
                @{ R = '-Dfabric\.addMods=';                           T = "FABRIC_ADD_MODS";          S = "HIGH";   D = "Injects extra mod JARs at runtime — can load cheats outside mods folder" },
                @{ R = '-Dfabric\.loadMods=';                          T = "FABRIC_LOAD_MODS";         S = "HIGH";   D = "Overrides Fabric mod loading — can force-load arbitrary JARs" },
                @{ R = '-Dfabric\.classPathGroups=';                   T = "FABRIC_CLASSPATH_GROUPS";  S = "MEDIUM"; D = "Manipulates Fabric classpath group resolution" },
                @{ R = '-Dfabric\.skipMcProvider=';                    T = "FABRIC_SKIP_MCPROVIDER";   S = "MEDIUM"; D = "Skips Minecraft provider — can bypass version checks" },
                @{ R = '-Dfabric\.allowUnsupportedVersion=';          T = "FABRIC_UNSUPPORTED_VER";   S = "LOW";    D = "Allows loading mods for unsupported MC versions" },
                @{ R = '-Dfabric\.remapClasspathFile=';               T = "FABRIC_REMAP_CLASSPATH";   S = "MEDIUM"; D = "Remaps classpath from external file — can inject classes" },
                @{ R = '-Dfabric\.skipIntermediary=';                 T = "FABRIC_SKIP_INTERMEDIARY"; S = "MEDIUM"; D = "Skips intermediary remapping — can load unverified code" },
                @{ R = '-Dfabric\.mixin\.hotSwap=';                    T = "FABRIC_MIXIN_HOTSWAP";     S = "HIGH";   D = "Enables Mixin hot-swap — runtime code modification" },
                @{ R = '-Dfabric\.mixin\.configs=';                    T = "FABRIC_MIXIN_CONFIGS";     S = "MEDIUM"; D = "Injects additional Mixin configs externally" },
                @{ R = '-Dfabric\.mixin\.debug\.export=';             T = "FABRIC_MIXIN_DEBUG";       S = "LOW";    D = "Exports Mixin debug data — unusual in production" },
                @{ R = '-Dfabric\.mixin\.debug\.verbose=';            T = "FABRIC_MIXIN_VERBOSE";     S = "LOW";    D = "Verbose Mixin debugging" },
                @{ R = '-Dfabric\.forceVersion=';                      T = "FABRIC_FORCE_VERSION";     S = "LOW";    D = "Forces Fabric game version" },
                @{ R = '-Dfabric\.autoDetectVersion=';                T = "FABRIC_AUTODETECT_VER";    S = "LOW";    D = "Overrides auto version detection" },
                @{ R = '-Dfabric\.customModList=';                     T = "FABRIC_CUSTOM_MODLIST";    S = "MEDIUM"; D = "Loads mods from custom list — bypasses normal discovery" },
                @{ R = '-Dfabric\.resolve\.modFiles=';                 T = "FABRIC_RESOLVE_MODFILES";  S = "MEDIUM"; D = "Overrides mod file resolution" },
                @{ R = '-Dfabric\.skipDependencyResolution=';         T = "FABRIC_SKIP_DEPS";         S = "MEDIUM"; D = "Skips dependency resolution — can load incomplete mods" },
                @{ R = '-Dfabric\.loader\.entrypoints=';               T = "FABRIC_ENTRYPOINTS";       S = "MEDIUM"; D = "Overrides loader entrypoints — can inject custom code" },
                @{ R = '-Dfabric\.language\.providers=';               T = "FABRIC_LANG_PROVIDERS";    S = "MEDIUM"; D = "Overrides language providers — can load non-standard code" },
                @{ R = '-Dfabric\.development=';                       T = "FABRIC_DEV_MODE";          S = "LOW";    D = "Fabric development mode active" },
                @{ R = '-Dfabric\.debug\.dumpClasspath=';             T = "FABRIC_DUMP_CLASSPATH";    S = "LOW";    D = "Dumps classpath for debugging" },
                @{ R = '-Dfabric\.gameJarPath=';                       T = "FABRIC_GAME_JAR_PATH";     S = "LOW";    D = "Custom game JAR path specified" },
                @{ R = '-Dfabric\.mods\.toml\.path=';                  T = "FABRIC_MODS_TOML";        S = "MEDIUM"; D = "External mods.toml path — can inject mod metadata" },
                @{ R = '-Dfabric\.configDir=';                         T = "FABRIC_CONFIG_DIR";        S = "INFO";   D = "Custom config directory set" },
                @{ R = '-Dfabric\.loader\.config=';                    T = "FABRIC_LOADER_CONFIG";     S = "INFO";   D = "Custom loader config path" },
                @{ R = '-Dfabric\.log\.level=';                        T = "FABRIC_LOG_LEVEL";         S = "INFO";   D = "Custom Fabric log level" },
                @{ R = '-Dfabric\.log\.config=';                       T = "FABRIC_LOG_CONFIG";        S = "INFO";   D = "Custom Fabric log config" },
                @{ R = '-Dfabric\.dli\.config=';                       T = "FABRIC_DLI_CONFIG";        S = "INFO";   D = "Dev Launcher Integration config" },
                @{ R = '-Dfabric\.launcher\.name=';                    T = "FABRIC_LAUNCHER_NAME";     S = "INFO";   D = "Fabric launcher name" },
                @{ R = '-Dfabric\.launcher\.brand=';                   T = "FABRIC_LAUNCHER_BRAND";    S = "INFO";   D = "Fabric launcher brand" },
                @{ R = '-Dfabric\.gameVersion=';                       T = "FABRIC_GAME_VERSION";      S = "INFO";   D = "Fabric game version" }
            )

            $forgeFlags = @(
                @{ R = '-Dforge\.addMods=';                            T = "FORGE_ADD_MODS";           S = "HIGH";   D = "Injects extra mod JARs at runtime — can load cheats" },
                @{ R = '-Dforge\.mods=';                               T = "FORGE_MODS";               S = "HIGH";   D = "Overrides Forge mod list — can force-load JARs" },
                @{ R = '-Dfml\.coreMods\.load=';                       T = "FORGE_COREMODS_LOAD";      S = "HIGH";   D = "Loads core mods via JVM flag — deep code injection" },
                @{ R = '-Dforge\.coreMods\.dir=';                      T = "FORGE_COREMODS_DIR";       S = "MEDIUM"; D = "Custom core mods directory — can inject code" },
                @{ R = '-Dforge\.modDir=';                             T = "FORGE_MOD_DIR";            S = "MEDIUM"; D = "Custom mod directory specified" },
                @{ R = '-Dforge\.modsDirectories=';                    T = "FORGE_MODS_DIRS";          S = "MEDIUM"; D = "Additional mod directories — can hide cheats" },
                @{ R = '-Dfml\.customModList=';                        T = "FORGE_CUSTOM_MODLIST";     S = "MEDIUM"; D = "Loads mods from custom list — bypasses normal discovery" },
                @{ R = '-Dforge\.disableModScan=';                     T = "FORGE_DISABLE_MODSCAN";    S = "HIGH";   D = "Disables mod scanning — can hide injected mods" },
                @{ R = '-Dforge\.modList=';                            T = "FORGE_MODLIST";            S = "MEDIUM"; D = "Overrides mod list directly" },
                @{ R = '-Dforge\.forceVersion=';                       T = "FORGE_FORCE_VERSION";      S = "LOW";    D = "Forces Forge version" },
                @{ R = '-Dforge\.disableUpdateCheck=';                 T = "FORGE_NO_UPDATE_CHECK";    S = "LOW";    D = "Disables Forge update check" },
                @{ R = '-Dforge\.mixin\.hotSwap=';                     T = "FORGE_MIXIN_HOTSWAP";      S = "HIGH";   D = "Enables Mixin hot-swap — runtime code modification" },
                @{ R = '-Dforge\.logging\.mojang\.level=';             T = "FORGE_LOG_LEVEL";          S = "INFO";   D = "Custom Forge log level" },
                @{ R = '-Dforge\.resourcePack=';                       T = "FORGE_RESOURCE_PACK";      S = "INFO";   D = "Custom resource pack path" },
                @{ R = '-Dforge\.defaultResourcePack=';                T = "FORGE_DEFAULT_RP";         S = "INFO";   D = "Default resource pack override" },
                @{ R = '-Dforge\.texturePacks=';                       T = "FORGE_TEXTURE_PACKS";      S = "INFO";   D = "Custom texture packs path" },
                @{ R = '-Dforge\.assetIndex=';                         T = "FORGE_ASSET_INDEX";        S = "INFO";   D = "Custom asset index" },
                @{ R = '-Dforge\.assetsDir=';                          T = "FORGE_ASSETS_DIR";         S = "INFO";   D = "Custom assets directory" }
            )

            $securityFlags = @(
                @{ R = '-Djava\.security\.manager=';                   T = "SEC_MANAGER_DISABLED";     S = "HIGH";   D = "Disables or replaces Java Security Manager — removes sandbox" },
                @{ R = '-Djava\.security\.policy=';                    T = "SEC_POLICY_OVERRIDE";      S = "MEDIUM"; D = "Overrides Java security policy — weakens permissions" }
            )

            $classpathFlags = @(
                @{ R = '-Xbootclasspath/p:';                           T = "BOOTCLASS_PREPEND";        S = "HIGH";   D = "Prepends untrusted JAR to bootstrap classloader" },
                @{ R = '-Xbootclasspath/a:';                           T = "BOOTCLASS_APPEND";         S = "MEDIUM"; D = "Appends JAR to bootstrap classloader" },
                @{ R = '-Djava\.system\.class\.loader=';               T = "CLASSLOADER_REPLACE";      S = "HIGH";   D = "Replaces the system classloader" },
                @{ R = '-Djava\.library\.path=';                       T = "NATIVE_LIB_PATH";          S = "MEDIUM"; D = "Overrides native library search path" }
            )

            $spoofFlags = @(
                @{ R = '-Dclient\.brand=';                             T = "BRAND_SPOOF";             S = "LOW";    D = "Spoofs client brand string" }
            )

            $verifyFlags = @(
                @{ R = '-Xverify:none';                                T = "BYTECODE_VERIFY_OFF";     S = "HIGH";   D = "Disables JVM bytecode verification" },
                @{ R = '-noverify';                                    T = "NOVERIFY";                S = "HIGH";   D = "Disables class verification" }
            )

            $nativeFlags = @(
                @{ R = '(?<!\w)-agentlib:';                            T = "NATIVE_AGENT_LIB";        S = "HIGH";   D = "Loads native JVMTI agent — can hook any JVM function" },
                @{ R = '-agentpath:';                                  T = "NATIVE_AGENT_PATH";       S = "HIGH";   D = "Loads native agent by path — deep JVM access" }
            )

            $debugFlags = @(
                @{ R = '-Xdebug';                                      T = "DEBUG_MODE";              S = "MEDIUM"; D = "JVM debug mode enabled" },
                @{ R = '-Xrunjdwp:';                                   T = "REMOTE_DEBUG";            S = "HIGH";   D = "Remote debugging — code injection risk" },
                @{ R = '(?<!\w)agentlib:jdwp';                         T = "JDWP_AGENT";              S = "HIGH";   D = "JDWP agent — RCE risk" }
            )

            $jarFlags = @(
                @{ R = '-Dsun\.misc\.URLClassPath\.disableJarChecking=true'; T = "JAR_CHECK_DISABLED"; S = "HIGH"; D = "Disables JAR signature checking" }
            )

            $jndiFlags = @(
                @{ R = '-Dcom\.sun\.jndi\.rmi\.object\.trustURLCodebase=true';  T = "JNDI_RMI_EXPLOIT";  S = "HIGH"; D = "JNDI RMI codebase — Log4Shell vector" },
                @{ R = '-Dcom\.sun\.jndi\.ldap\.object\.trustURLCodebase=true'; T = "JNDI_LDAP_EXPLOIT"; S = "HIGH"; D = "JNDI LDAP codebase — Log4Shell variant" }
            )

            $cpMatches = [regex]::Matches($cmd, '-cp\s+["'']?([^\s"'']+)["'']?')
            foreach ($cpm in $cpMatches) {
                $cpVal = $cpm.Groups[1].Value
                $suspiciousCpPaths = @('\.minecraft\\mods\\', '\.minecraft\mods\/', '\\AppData\\Local\\Temp\\', '\$HOME\/\.cache\/', '\\Users\\.*\\Desktop\\', '\\Users\\.*\\Downloads\\')
                foreach ($scp in $suspiciousCpPaths) {
                    if ($cpVal -match $scp) {
                        $key = "SUSPICIOUS_CP|$($scp.Substring(0, [math]::Min(20, $scp.Length)))"
                        if (-not $foundFlags.Contains($key)) {
                            [void]$foundFlags.Add($key)
                            $findings.Add([PSCustomObject]@{ Type = "SUSPICIOUS_CLASSPATH"; Detail = "Classpath includes suspicious path: $($scp.TrimStart('\', '/'))"; Severity = "MEDIUM"; PID = $javaPid })
                        }
                        break
                    }
                }
            }

            $allFlagSets = @($fabricFlags, $forgeFlags, $securityFlags, $classpathFlags, $spoofFlags, $verifyFlags, $nativeFlags, $debugFlags, $jarFlags, $jndiFlags)
            foreach ($flagSet in $allFlagSets) {
                foreach ($fl in $flagSet) {
                    if ($cmd -match $fl.R) {
                        if (-not $foundFlags.Contains($fl.T)) {
                            [void]$foundFlags.Add($fl.T)
                            if ($fl.S -ne "INFO") {
                                $findings.Add([PSCustomObject]@{ Type = $fl.T; Detail = $fl.D; Severity = $fl.S; PID = $javaPid })
                            }
                        }
                    }
                }
            }
        } catch { }
    }
    return $findings
}

# ═══════════════════════════════════════════════════════════
#  MOD SIGNATURE SCAN
# ═════════════════════════════════════════════════════════
function Get-ModSignature {
    param(
        [string]$Path,
        [bool]$ScanStrings = $true,
        [bool]$ScanDeep    = $true
    )
    $hits            = [System.Collections.Generic.HashSet[string]]::new()
    $entropyWarnings = [System.Collections.Generic.List[string]]::new()

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)

        foreach ($e in $zip.Entries) {
            foreach ($m in $patternRegex.Matches($e.FullName)) { [void]$hits.Add("P|$($m.Value)") }
        }

        $flat   = [System.Collections.Generic.List[object]]::new()
        $nested = [System.Collections.Generic.List[object]]::new()
        foreach ($e in $zip.Entries) { $flat.Add($e) }
        foreach ($nj in ($zip.Entries | Where-Object { $_.FullName -match "^META-INF/jars/.+\.jar$" })) {
            try {
                $ns = $nj.Open(); $ms = New-Object System.IO.MemoryStream
                $ns.CopyTo($ms); $ns.Close(); $ms.Position = 0
                $iz = [System.IO.Compression.ZipArchive]::new($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                $nested.Add($iz)
                foreach ($ie in $iz.Entries) { $flat.Add($ie) }
            } catch { }
        }

        $scanExtensions = '\.(class|json|toml|yml|yaml|txt|cfg|properties|xml|html|js|ts|kt|groovy)$|MANIFEST\.MF'

        foreach ($entry in $flat) {
            if ($entry.FullName -notmatch $scanExtensions) { continue }
            try {
                $st  = $entry.Open()
                $buf = New-Object System.IO.MemoryStream
                $st.CopyTo($buf); $st.Close()
                $raw = $buf.ToArray(); $buf.Dispose()
                $a   = [System.Text.Encoding]::ASCII.GetString($raw)
                $u   = [System.Text.Encoding]::UTF8.GetString($raw)

                foreach ($m in $patternRegex.Matches($a)) { [void]$hits.Add("P|$($m.Value)") }

                if ($ScanStrings) {
                    foreach ($cs in $cheatStringSet) {
                        if ($a.Contains($cs) -or $u.Contains($cs)) { [void]$hits.Add("S|$cs") }
                    }
                    foreach ($m in $fullwidthRegex.Matches($u)) { [void]$hits.Add("F|$($m.Value)") }
                }

                if ($ScanDeep) {
                    foreach ($ds in $deepCheatStringSet) {
                        if ($a.Contains($ds) -or $u.Contains($ds)) { [void]$hits.Add("D|$ds") }
                    }
                    if ($entry.FullName -match '\.class$' -and $raw.Length -gt 512) {
                        $ent = Get-ShannonEntropy -Data $raw
                        if ($ent -gt 7.2) {
                            $shortName = [System.IO.Path]::GetFileName($entry.FullName)
                            $entropyWarnings.Add("HIGH_ENTROPY:$shortName($ent)")
                        }
                    }
                }
            } catch { }
        }

        foreach ($n in $nested) { try { $n.Dispose() } catch { } }
        $zip.Dispose()
    } catch { }

    $fwPool = @($script:cheatStrings | Where-Object { $_ -cmatch "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]" })
    foreach ($h in @($hits)) {
        if ($h -match '^F\|') {
            $fw = $h.Substring(2)
            if ($fw.Length -lt 3) { continue }
            $best = $null
            foreach ($cs in $fwPool) {
                if ($cs.Contains($fw)) { if ($null -eq $best -or $cs.Length -lt $best.Length) { $best = $cs } }
            }
            $final = if ($best) { $best } elseif ($fw.Length -ge 6) { $fw } else { $null }
            if ($final) { $hits.Remove($h); [void]$hits.Add("F|$final") }
        }
    }
    $fwFinal  = @($hits | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
    $fwUnique = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($fw in $fwFinal) {
        $redundant = $false
        foreach ($other in $fwFinal) { if ($fw.Length -lt $other.Length -and $other.Contains($fw)) { $redundant = $true; break } }
        if (-not $redundant) { [void]$fwUnique.Add($fw) }
    }
    $cleaned = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($h in $hits) {
        if ($h -match '^F\|') { if ($fwUnique.Contains($h.Substring(2))) { [void]$cleaned.Add($h) } }
        else { [void]$cleaned.Add($h) }
    }
    foreach ($ew in $entropyWarnings) { [void]$cleaned.Add("E|$ew") }
    return $cleaned
}

# ═══════════════════════════════════════════════════════════
#  URL SOURCE EXTRACTION
# ═════════════════════════════════════════════════════════
function Get-ModSources {
    param([string]$Path)
    $urls      = [System.Collections.Generic.List[string]]::new()
    $blacklist = @("w3\.org", "jsonschema\.org", "fabricmc\.net", "quiltmc\.net", "oracle\.com", "mojang\.com", "minecraft\.net")
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -match '\.(json|toml|yml|yaml)$' -or $entry.FullName -match 'MANIFEST\.MF') {
                try {
                    $st = $entry.Open(); $buf = New-Object System.IO.MemoryStream
                    $st.CopyTo($buf); $st.Close()
                    $raw = [System.Text.Encoding]::UTF8.GetString($buf.ToArray()); $buf.Dispose()
                    $regexMatches = [regex]::Matches($raw, "https?://[^\s<>]+")
                    foreach ($m in $regexMatches) {
                        $url = $m.Value.TrimEnd('\', ',', ')', '}', '"')
                        $isBlacklisted = $false
                        foreach ($bl in $blacklist) { if ($url -match $bl) { $isBlacklisted = $true; break } }
                        if (-not $isBlacklisted -and $url -notmatch '\.(png|jpg|jpeg|gif|svg)$') { $urls.Add($url) }
                    }
                } catch { }
            }
        }
        $zip.Dispose()
    } catch { }
    return @($urls | Select-Object -Unique)
}

# ═══════════════════════════════════════════════════════════
#  MAIN SCAN LOOP
# ═════════════════════════════════════════════════════════
try { $jars = Get-ChildItem -Path $modsPath -Filter *.jar -ErrorAction Stop }
catch {
    Write-Host "  Cannot read directory." -ForegroundColor Red
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if ($jars.Count -eq 0) {
    Write-Host "  No JAR files found." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

 $scanTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
 $mcStatus      = Get-MinecraftStatus

Write-Host ""
Write-Host "  $scanTimestamp" -ForegroundColor DarkGray
Write-Host "  $modsPath" -ForegroundColor DarkGray
Write-Host "  $($jars.Count) file(s) found" -ForegroundColor DarkGray
Write-Host ""

if ($mcStatus.Running) {
    Write-Host "  Minecraft  " -ForegroundColor DarkGray -NoNewline
    Write-Host "● " -ForegroundColor Magenta -NoNewline
    Write-Host "Running  " -ForegroundColor White -NoNewline
    Write-Host "PID $($mcStatus.PID)   $($mcStatus.Uptime)   $($mcStatus.RAM) RAM" -ForegroundColor DarkGray
} else {
    Write-Host "  Minecraft  " -ForegroundColor DarkGray -NoNewline
    Write-Host "○ " -ForegroundColor DarkGray -NoNewline
    Write-Host "Not running" -ForegroundColor DarkGray
}

 $jvmResults = [System.Collections.Generic.List[PSObject]]::new()
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 1" -ForegroundColor Magenta -NoNewline
Write-Host " · JVM Integrity Scan" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
Write-Host "  │  checking... " -ForegroundColor DarkGray -NoNewline
 $jvmResults = Test-JvmIntegrity
if ($jvmResults.Count -gt 0) {
    $highCount = @($jvmResults | Where-Object { $_.Severity -eq "HIGH" }).Count
    $medCount  = @($jvmResults | Where-Object { $_.Severity -eq "MEDIUM" }).Count
    $lowCount  = @($jvmResults | Where-Object { $_.Severity -eq "LOW" }).Count
    $parts = @()
    if ($highCount -gt 0) { $parts += "$highCount HIGH" }
    if ($medCount -gt 0)  { $parts += "$medCount MEDIUM" }
    if ($lowCount -gt 0)  { $parts += "$lowCount LOW" }
    Write-Host "$($jvmResults.Count) issue(s) found ($($parts -join ', '))" -ForegroundColor Red
} else {
    Write-Host "clean" -ForegroundColor Cyan
}
Write-Host "  └─ done" -ForegroundColor DarkMagenta

 $total   = $jars.Count
 $i       = 0
 $flagged = [System.Collections.Generic.List[PSObject]]::new()
 $clean   = [System.Collections.Generic.List[string]]::new()

Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 2" -ForegroundColor Magenta -NoNewline
Write-Host " · String Analysis + Deep Scan" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta

foreach ($jar in $jars) {
    $i++
    $pct = [math]::Floor(($i / $total) * 100)
    $padName = $jar.Name.PadRight(40).Substring(0, 40)
    [Console]::Write("  │  $pct% $padName`r")
    $sig = Get-ModSignature -Path $jar.FullName -ScanStrings $true -ScanDeep $true

    if ($sig.Count -gt 0) {
        $pats    = @($sig | Where-Object { $_ -match '^P\|' } | ForEach-Object { $_.Substring(2) })
        $strs    = @($sig | Where-Object { $_ -match '^S\|' } | ForEach-Object { $_.Substring(2) })
        $fws     = @($sig | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
        $deep_s  = @($sig | Where-Object { $_ -match '^D\|' } | ForEach-Object { $_.Substring(2) })
        $entrp   = @($sig | Where-Object { $_ -match '^E\|' } | ForEach-Object { $_.Substring(2) })
        $sources = Get-ModSources -Path $jar.FullName
        $flagged.Add([PSCustomObject]@{
            Name      = $jar.Name
            Path      = $jar.FullName
            Size      = [math]::Round($jar.Length / 1KB, 1)
            Patterns  = $pats
            Strings   = $strs
            Fullwidth = $fws
            DeepHits  = $deep_s
            Entropy   = $entrp
            HitCount  = $sig.Count
            Sources   = $sources
            ObfResult = $null
        })
    } else { $clean.Add($jar.Name) }
}
Write-Host "  │  100% done                                      " -ForegroundColor DarkMagenta
Write-Host "  └─ $($flagged.Count) flagged  /  $($clean.Count) clean" -ForegroundColor DarkMagenta

Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 3" -ForegroundColor Magenta -NoNewline
Write-Host " · Advanced Obfuscation Detection" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta

 $obfMap = @{}
 $oi     = 0
foreach ($jar in $jars) {
    $oi++
    $pct = [math]::Floor(($oi / $total) * 100)
    $padName = $jar.Name.PadRight(40).Substring(0, 40)
    [Console]::Write("  │  $pct% $padName`r")
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
        $obfResult = Get-ObfuscationScore -Zip $zip
        $zip.Dispose()
        $obfMap[$jar.Name] = $obfResult
    } catch { $obfMap[$jar.Name] = $null }
}
Write-Host "  │  100% done                                      " -ForegroundColor DarkMagenta

foreach ($mod in $flagged) {
    if ($obfMap.ContainsKey($mod.Name)) { $mod.ObfResult = $obfMap[$mod.Name] }
}
foreach ($jar in $jars) {
    if ($clean -contains $jar.Name) {
        $obf = $obfMap[$jar.Name]
        if ($obf -and ($obf.ObfLevel -eq "MODERATE" -or $obf.ObfLevel -eq "HEAVY")) {
            $clean.Remove($jar.Name) | Out-Null
            $flagged.Add([PSCustomObject]@{
                Name      = $jar.Name
                Path      = $jar.FullName
                Size      = [math]::Round($jar.Length / 1KB, 1)
                Patterns  = @()
                Strings   = @()
                Fullwidth = @()
                DeepHits  = @()
                Entropy   = @()
                HitCount  = 0
                Sources   = @()
                ObfResult = $obf
            })
        }
    }
}

 $obfHeavy = ($obfMap.Values | Where-Object { $_ -and $_.ObfLevel -eq "HEAVY" }).Count
Write-Host "  └─ $obfHeavy heavily obfuscated jar(s) detected" -ForegroundColor DarkMagenta

Start-Sleep -Milliseconds 300
Clear-Host

# ═══════════════════════════════════════════════════════════
#  CLASSIFICATION
# ═══════════════════════════════════════════════════════════
 $criticalThreats = [System.Collections.Generic.List[PSObject]]::new()
 $suspiciousFiles = [System.Collections.Generic.List[PSObject]]::new()

foreach ($mod in $flagged) {
    $isBlatant = $false
    if ($mod.HitCount -ge 15) { $isBlatant = $true }
    foreach ($str in $mod.Strings) {
        if ($str -match "SelfDestruct|self destruct|AutoCrystal|ＡｕﾄＣﾞｲｽﾀ｡ﾞ|Dqrkis Client|POT_CHEATS|Donut|AutoAnchor|ＡｕﾄＡｮｃﾞｮﾞ|cancelPacket|dropPacket|spoofPacket|setTimerSpeed|timerSpeed|fakeVersion|spoofVersion|grimBypass|ncpBypass|aacBypass|bypassAC|selfdestruct") {
            $isBlatant = $true; break
        }
    }
    if ($isBlatant) { $criticalThreats.Add($mod) } else { $suspiciousFiles.Add($mod) }
}

 $W = 72

# ═══════════════════════════════════════════════════════════
#  BOX RENDERING HELPERS
# ═══════════════════════════════════════════════════════════
function Write-Border {
    param([string]$Type, [System.ConsoleColor]$Color)
    switch ($Type) {
        'top'   { Write-Host ("  ╔" + ("═" * $W) + "╗") -ForegroundColor $Color }
        'sep'   { Write-Host ("  ╠" + ("═" * $W) + "╣") -ForegroundColor $Color }
        'bot'   { Write-Host ("  ╚" + ("═" * $W) + "╝") -ForegroundColor $Color }
        'blank' { Write-Host ("  ║" + (" " * $W) + "║") -ForegroundColor $Color }
    }
}

function Write-Row {
    param(
        [string]$Label,
        [string]$Value,
        [System.ConsoleColor]$LabelColor  = [System.ConsoleColor]::DarkGray,
        [System.ConsoleColor]$ValueColor  = [System.ConsoleColor]::White,
        [System.ConsoleColor]$BorderColor = [System.ConsoleColor]::DarkGray
    )
    $available = $W - $Label.Length
    if ($available -lt 4) {
        $truncLabel = $Label.Substring(0, [math]::Max(0, $W - 4))
        $Value = ""
        $pad = $W - $truncLabel.Length
        Write-Host "  ║" -ForegroundColor $BorderColor -NoNewline
        Write-Host $truncLabel -ForegroundColor $LabelColor -NoNewline
        Write-Host (" " * [math]::Max(0, $pad) + "║") -ForegroundColor $BorderColor
        return
    }
    if ($Value.Length -gt $available - 3) { $Value = $Value.Substring(0, [math]::Max(0, $available - 4)) + "..." }
    $pad = [math]::Max(0, $W - $Label.Length - $Value.Length)
    Write-Host "  ║" -ForegroundColor $BorderColor -NoNewline
    Write-Host $Label -ForegroundColor $LabelColor -NoNewline
    Write-Host $Value -ForegroundColor $ValueColor -NoNewline
    Write-Host (" " * $pad + "║") -ForegroundColor $BorderColor
}

function Write-RowFull {
    param(
        [string]$Text,
        [System.ConsoleColor]$TextColor   = [System.ConsoleColor]::White,
        [System.ConsoleColor]$BorderColor = [System.ConsoleColor]::DarkGray
    )
    if ($Text.Length -gt $W - 3) { $Text = $Text.Substring(0, [math]::Max(0, $W - 4)) + "..." }
    $pad = [math]::Max(0, $W - $Text.Length)
    Write-Host "  ║" -ForegroundColor $BorderColor -NoNewline
    Write-Host $Text -ForegroundColor $TextColor -NoNewline
    Write-Host (" " * $pad + "║") -ForegroundColor $BorderColor
}

# ═══════════════════════════════════════════════════════════
#  REPORT BANNER
# ═══════════════════════════════════════════════════════════
[Console]::WriteLine("")
W "███    ██ ██  ██████     ███    ███  ██████  ██████                    " ([System.ConsoleColor]::Magenta)
W "████   ██ ██ ██          ████  ████ ██    ██ ██   ██                   " ([System.ConsoleColor]::Magenta)
W "██ ██  ██ ██ ██          ██ ████ ██ ██    ██ ██   ██                   " ([System.ConsoleColor]::DarkMagenta)
W "██  ██ ██ ██ ██          ██  ██  ██ ██    ██ ██   ██                   " ([System.ConsoleColor]::DarkMagenta)
W "██   ████ ██  ██████     ██      ██  ██████  ██████                    " ([System.ConsoleColor]::Magenta)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
W "     █████  ███    ██  █████  ██      ██    ██ ███████ ███████ ██████  " ([System.ConsoleColor]::Magenta)
W "    ██   ██ ████   ██ ██   ██ ██       ██  ██     ███  ██      ██   ██ " ([System.ConsoleColor]::DarkMagenta)
W "    ███████ ██ ██  ██ ███████ ██        ████     ███   █████   ██████  " ([System.ConsoleColor]::DarkMagenta)
W "    ██   ██ ██  ██ ██ ██   ██ ██         ██     ███    ██      ██   ██ " ([System.ConsoleColor]::Magenta)
W "    ██   ██ ██   ████ ██   ██ ███████    ██    ███████ ███████ ██   ██ " ([System.ConsoleColor]::DarkMagenta)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
W "                                                                        " ([System.ConsoleColor]::DarkGray)
[Console]::WriteLine("")
[Console]::ForegroundColor = [System.ConsoleColor]::Magenta
[Console]::WriteLine("                                    [ SCAN RESULTS ]")
[Console]::ForegroundColor = [System.ConsoleColor]::DarkGray
[Console]::WriteLine("   ─────────────────────────────────────────────────────────────────────────────────────────────────────────")
[Console]::WriteLine("")

 $flaggedColor  = if ($flagged.Count -gt 0) { [System.ConsoleColor]::Red } else { [System.ConsoleColor]::Cyan }
 $moduleSummary = ($activeModules -join "  ·  ")

Write-Border 'top' DarkGray
Write-RowFull ("  SCAN REPORT  ·  " + $scanTimestamp) Magenta DarkGray
Write-Border 'sep' DarkGray
Write-Row "  Modules  : " $moduleSummary                           Magenta    White         DarkGray
Write-Row "  Path     : " $modsPath                                DarkGray   Gray          DarkGray
Write-Row "  Files    : " "$($jars.Count) scanned"                DarkGray   White         DarkGray
Write-Row "  Clean    : " "$($clean.Count)"                        DarkGray   Cyan          DarkGray
Write-Row "  Flagged  : " "$($flagged.Count)"                      DarkGray   $flaggedColor DarkGray

if ($mcStatus.Running) {
    Write-Row "  Minecraft: " " RUNNING   PID $($mcStatus.PID)   $($mcStatus.Uptime)   $($mcStatus.RAM) RAM" DarkGray Cyan DarkGray
} else {
    Write-Row "  Minecraft: " " not running" DarkGray DarkGray DarkGray
}
Write-Border 'bot' DarkGray

# ═══════════════════════════════════════════════════════════
#  JVM FINDINGS
# ═══════════════════════════════════════════════════════════
if ($jvmResults.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' Red
    Write-RowFull "  JVM INTEGRITY ISSUES" Red Red
    Write-Border 'sep' Red

    $highJVM = @($jvmResults | Where-Object { $_.Severity -eq "HIGH" })
    $medJVM  = @($jvmResults | Where-Object { $_.Severity -eq "MEDIUM" })
    $lowJVM  = @($jvmResults | Where-Object { $_.Severity -eq "LOW" })

    if ($highJVM.Count -gt 0) {
        Write-RowFull "  HIGH SEVERITY" Red Red
        foreach ($j in $highJVM) {
            Write-Row "  [HIGH]  $($j.Type.PadRight(30))" $j.Detail Red DarkGray Red
        }
    }
    if ($medJVM.Count -gt 0) {
        Write-Border 'sep' Yellow
        Write-RowFull "  MEDIUM SEVERITY" Yellow Yellow
        foreach ($j in $medJVM) {
            Write-Row "  [MED]   $($j.Type.PadRight(30))" $j.Detail Yellow DarkGray Yellow
        }
    }
    if ($lowJVM.Count -gt 0) {
        Write-Border 'sep' DarkGray
        Write-RowFull "  LOW SEVERITY" DarkGray DarkGray
        foreach ($j in $lowJVM) {
            Write-Row "  [LOW]   $($j.Type.PadRight(30))" $j.Detail DarkGray DarkGray DarkGray
        }
    }

    Write-Border 'bot' Red
}

# ═══════════════════════════════════════════════════════════
#  CRITICAL THREATS
# ═══════════════════════════════════════════════════════════
if ($criticalThreats.Count -gt 0) {
    foreach ($mod in $criticalThreats) {
        Write-Host ""
        Write-Border 'top' Red
        Write-RowFull "  ⚠  CRITICAL THREAT DETECTED" Red Red
        Write-Border 'sep' Red
        Write-Row "  File    : " $mod.Name White Red Red
        Write-Row "  Size    : " "$($mod.Size) KB" DarkGray Gray Red
        Write-Row "  Matches : " "$($mod.HitCount) signature(s)" DarkGray Red Red

        if ($mod.ObfResult -and $mod.ObfResult.ObfLevel -ne "None") {
            $obfColor = switch ($mod.ObfResult.ObfLevel) {
                "HEAVY"    { [System.ConsoleColor]::Red }
                "MODERATE"  { [System.ConsoleColor]::Yellow }
                default     { [System.ConsoleColor]::DarkYellow }
            }
            Write-Row "  Obf.    : " $mod.ObfResult.ObfLevel DarkGray $obfColor Red
            foreach ($ind in $mod.ObfResult.Indicators) {
                Write-Row "           " $ind DarkGray DarkYellow Red
            }
        }

        if ($mod.Patterns.Count -gt 0) {
            Write-Border 'sep' DarkRed
            Write-RowFull "  PATTERN MATCHES" DarkRed DarkRed
            foreach ($p in ($mod.Patterns | Select-Object -First 20)) { Write-Row "  [PATH]  " $p DarkGray Red DarkRed }
            if ($mod.Patterns.Count -gt 20) { Write-Row "  [PATH]  " "... and $($mod.Patterns.Count - 20) more" DarkGray DarkRed DarkRed }
        }
        if ($mod.Strings.Count -gt 0) {
            Write-Border 'sep' DarkRed
            Write-RowFull "  CHEAT SIGNATURES" DarkRed DarkRed
            foreach ($s in ($mod.Strings | Select-Object -First 20)) { Write-Row "  [STR]   " $s DarkGray Red DarkRed }
            if ($mod.Strings.Count -gt 20) { Write-Row "  [STR]   " "... and $($mod.Strings.Count - 20) more" DarkGray DarkRed DarkRed }
        }
        if ($mod.Fullwidth.Count -gt 0) {
            Write-Border 'sep' DarkRed
            Write-RowFull "  FULLWIDTH OBFUSCATION" DarkRed DarkRed
            foreach ($f in $mod.Fullwidth) { Write-Row "  [FW]    " $f DarkGray Magenta DarkRed }
        }
        if ($mod.DeepHits.Count -gt 0) {
            Write-Border 'sep' DarkRed
            Write-RowFull "  DEEP SCAN HITS" DarkRed DarkRed
            foreach ($d in ($mod.DeepHits | Select-Object -First 15)) { Write-Row "  [DEEP]  " $d DarkGray Yellow DarkRed }
            if ($mod.DeepHits.Count -gt 15) { Write-Row "  [DEEP]  " "... and $($mod.DeepHits.Count - 15) more" DarkGray DarkRed DarkRed }
        }
        if ($mod.Entropy.Count -gt 0) {
            Write-Border 'sep' DarkRed
            Write-RowFull "  ENTROPY WARNINGS" DarkRed DarkRed
            foreach ($e in ($mod.Entropy | Select-Object -First 10)) { Write-Row "  [ENT]   " $e DarkGray DarkYellow DarkRed }
            if ($mod.Entropy.Count -gt 10) { Write-Row "  [ENT]   " "... and $($mod.Entropy.Count - 10) more" DarkGray DarkRed DarkRed }
        }
        if ($mod.Sources.Count -gt 0) {
            Write-Border 'sep' DarkRed
            Write-RowFull "  EXTRACTED URLS" DarkRed DarkRed
            foreach ($u in ($mod.Sources | Select-Object -First 10)) { Write-Row "  [URL]   " $u DarkGray Cyan DarkRed }
            if ($mod.Sources.Count -gt 10) { Write-Row "  [URL]   " "... and $($mod.Sources.Count - 10) more" DarkGray DarkRed DarkRed }
        }
        Write-Border 'bot' Red
    }
}

# ═══════════════════════════════════════════════════════════
#  SUSPICIOUS FILES
# ═══════════════════════════════════════════════════════════
if ($suspiciousFiles.Count -gt 0) {
    foreach ($mod in $suspiciousFiles) {
        Write-Host ""
        Write-Border 'top' Yellow
        Write-RowFull "  ⚑  SUSPICIOUS FILE" Yellow Yellow
        Write-Border 'sep' Yellow
        Write-Row "  File    : " $mod.Name White Yellow Yellow
        Write-Row "  Size    : " "$($mod.Size) KB" DarkGray Gray Yellow
        Write-Row "  Matches : " "$($mod.HitCount) signature(s)" DarkGray Yellow Yellow

        if ($mod.ObfResult -and $mod.ObfResult.ObfLevel -ne "None") {
            $obfColor = switch ($mod.ObfResult.ObfLevel) {
                "HEAVY"    { [System.ConsoleColor]::Red }
                "MODERATE"  { [System.ConsoleColor]::Yellow }
                default     { [System.ConsoleColor]::DarkYellow }
            }
            Write-Row "  Obf.    : " $mod.ObfResult.ObfLevel DarkGray $obfColor Yellow
            foreach ($ind in $mod.ObfResult.Indicators) {
                Write-Row "           " $ind DarkGray DarkYellow Yellow
            }
        }

        if ($mod.Patterns.Count -gt 0) {
            Write-Border 'sep' DarkYellow
            Write-RowFull "  PATTERN MATCHES" DarkYellow DarkYellow
            foreach ($p in ($mod.Patterns | Select-Object -First 15)) { Write-Row "  [PATH]  " $p DarkGray Yellow DarkYellow }
            if ($mod.Patterns.Count -gt 15) { Write-Row "  [PATH]  " "... and $($mod.Patterns.Count - 15) more" DarkGray DarkYellow DarkYellow }
        }
        if ($mod.Strings.Count -gt 0) {
            Write-Border 'sep' DarkYellow
            Write-RowFull "  CHEAT SIGNATURES" DarkYellow DarkYellow
            foreach ($s in ($mod.Strings | Select-Object -First 15)) { Write-Row "  [STR]   " $s DarkGray Yellow DarkYellow }
            if ($mod.Strings.Count -gt 15) { Write-Row "  [STR]   " "... and $($mod.Strings.Count - 15) more" DarkGray DarkYellow DarkYellow }
        }
        if ($mod.Fullwidth.Count -gt 0) {
            Write-Border 'sep' DarkYellow
            Write-RowFull "  FULLWIDTH OBFUSCATION" DarkYellow DarkYellow
            foreach ($f in $mod.Fullwidth) { Write-Row "  [FW]    " $f DarkGray Magenta DarkYellow }
        }
        if ($mod.DeepHits.Count -gt 0) {
            Write-Border 'sep' DarkYellow
            Write-RowFull "  DEEP SCAN HITS" DarkYellow DarkYellow
            foreach ($d in ($mod.DeepHits | Select-Object -First 10)) { Write-Row "  [DEEP]  " $d DarkGray DarkYellow DarkYellow }
            if ($mod.DeepHits.Count -gt 10) { Write-Row "  [DEEP]  " "... and $($mod.DeepHits.Count - 10) more" DarkGray DarkYellow DarkYellow }
        }
        if ($mod.Entropy.Count -gt 0) {
            Write-Border 'sep' DarkYellow
            Write-RowFull "  ENTROPY WARNINGS" DarkYellow DarkYellow
            foreach ($e in ($mod.Entropy | Select-Object -First 8)) { Write-Row "  [ENT]   " $e DarkGray DarkYellow DarkYellow }
            if ($mod.Entropy.Count -gt 8) { Write-Row "  [ENT]   " "... and $($mod.Entropy.Count - 8) more" DarkGray DarkYellow DarkYellow }
        }
        if ($mod.Sources.Count -gt 0) {
            Write-Border 'sep' DarkYellow
            Write-RowFull "  EXTRACTED URLS" DarkYellow DarkYellow
            foreach ($u in ($mod.Sources | Select-Object -First 8)) { Write-Row "  [URL]   " $u DarkGray Cyan DarkYellow }
            if ($mod.Sources.Count -gt 8) { Write-Row "  [URL]   " "... and $($mod.Sources.Count - 8) more" DarkGray DarkYellow DarkYellow }
        }
        Write-Border 'bot' Yellow
    }
}

# ═══════════════════════════════════════════════════════════
#  CLEAN FILES
# ═══════════════════════════════════════════════════════════
if ($clean.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' DarkGray
    Write-RowFull "  CLEAN FILES" Cyan DarkGray
    Write-Border 'sep' DarkGray
    $colWidth = [math]::Max(20, [math]::Floor(($W - 4) / 3))
    $col = 0
    $lineBuffer = ""
    foreach ($c in ($clean | Sort-Object)) {
        $display = if ($c.Length -gt $colWidth - 1) { $c.Substring(0, $colWidth - 2) + "…" } else { $c }
        $padded = $display.PadRight($colWidth)
        $lineBuffer += $padded
        $col++
        if ($col -ge 3) {
            Write-Row "  " $lineBuffer.TrimEnd() DarkGray Green DarkGray
            $lineBuffer = ""
            $col = 0
        }
    }
    if ($lineBuffer -ne "") {
        Write-Row "  " $lineBuffer.TrimEnd() DarkGray Green DarkGray
    }
    Write-Border 'bot' DarkGray
}

# ═══════════════════════════════════════════════════════════
#  VERDICT FOOTER
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Border 'top' DarkGray
 $verdictText  = ""
 $verdictColor = [System.ConsoleColor]::Cyan

if ($criticalThreats.Count -gt 0) {
    $verdictText  = "  VERDICT  ·  $($criticalThreats.Count) CRITICAL THREAT(S) FOUND — REMOVE IMMEDIATELY"
    $verdictColor = [System.ConsoleColor]::Red
} elseif ($suspiciousFiles.Count -gt 0) {
    $verdictText  = "  VERDICT  ·  $($suspiciousFiles.Count) suspicious file(s) — MANUAL REVIEW RECOMMENDED"
    $verdictColor = [System.ConsoleColor]::Yellow
} elseif ($jvmResults.Count -gt 0) {
    $highJVM = @($jvmResults | Where-Object { $_.Severity -eq "HIGH" })
    if ($highJVM.Count -gt 0) {
        $verdictText  = "  VERDICT  ·  JVM anomalies detected — INVESTIGATE LAUNCH CONFIGURATION"
        $verdictColor = [System.ConsoleColor]::Yellow
    } else {
        $verdictText  = "  VERDICT  ·  Minor JVM flags only — LIKELY CLEAN"
        $verdictColor = [System.ConsoleColor]::Cyan
    }
} else {
    $verdictText  = "  VERDICT  ·  ALL CLEAN — NO THREATS DETECTED"
    $verdictColor = [System.ConsoleColor]::Cyan
}

Write-RowFull $verdictText $verdictColor $verdictColor
Write-Border 'sep' DarkGray

 $summaryParts = @()
if ($criticalThreats.Count -gt 0) { $summaryParts += "$($criticalThreats.Count) critical" }
if ($suspiciousFiles.Count -gt 0) { $summaryParts += "$($suspiciousFiles.Count) suspicious" }
if ($jvmResults.Count -gt 0)      { $summaryParts += "$($jvmResults.Count) JVM issue(s)" }
if ($obfHeavy -gt 0)               { $summaryParts += "$obfHeavy heavily obfuscated" }
if ($clean.Count -gt 0)            { $summaryParts += "$($clean.Count) clean" }

 $summaryLine = if ($summaryParts.Count -gt 0) { ($summaryParts -join "  ·  ") } else { "no findings" }
Write-RowFull "  $summaryLine" DarkGray DarkGray
Write-Border 'bot' DarkGray

Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
 $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
