Set-ExecutionPolicy Bypass -Command "
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host

Write-Host '  Nic Mod Analyzer V3.0' -ForegroundColor Magenta
Write-Host ''
Write-Host '  Path ' -ForegroundColor DarkGray -NoNewline
Write-Host '(Enter = default)' -ForegroundColor DarkMagenta
Write-Host '  > ' -ForegroundColor Magenta -NoNewline
 $modsPath = Read-Host

if ([string]::IsNullOrWhiteSpace($modsPath)) {
    $modsPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
}

if (-not (Test-Path $modsPath -PathType Container)) {
    Write-Host '  Invalid path.' -ForegroundColor Red
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
 $suspiciousPatterns = @(
    'AimAssist', 'AnchorTweaks', 'AutoAnchor', 'AutoCrystal', 'AutoDoubleHand',
    'AutoHitCrystal', 'AutoPot', 'AutoTotem', 'AutoArmor', 'InventoryTotem',
    'JumpReset', 'LegitTotem', 'PingSpoof', 'SelfDestruct',
    'ShieldBreaker', 'TriggerBot', 'AxeSpam', 'WebMacro',
    'FastPlace', 'WalskyOptimizer', 'WalksyOptimizer', 'walsky.optimizer',
    'WalksyCrystalOptimizerMod', 'Donut', 'Replace Mod',
    'ShieldDisabler', 'SilentAim', 'Totem Hit', 'Wtap', 'FakeLag',
    'BlockESP', 'dev.krypton', 'Virgin', 'AntiMissClick',
    'LagReach', 'PopSwitch', 'SprintReset', 'ChestSteal', 'AntiBot',
    'ElytraSwap', 'FastXP', 'FastExp', 'Refill',  'AirAnchor',
    'jnativehook', 'FakeInv', 'HoverTotem', 'AutoClicker', 'AutoFirework',
    'PackSpoof', 'Antiknockback', 'catlean', 'Argon',
    'AuthBypass', 'Asteria', 'Prestige', 'AutoEat', 'AutoMine',
    'MaceSwap', 'DoubleAnchor', 'AutoTPA', 'BaseFinder', 'Xenon', 'gypsy',
    'Grim', 'grim',
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
    'LicenseCheckMixin', 'ClientPlayerInteractionManagerAccessor',
    "ClientPlayerEntityMixim", 'dev.gambleclient', 'obfuscatedAuth',
    'phantom-refmap.json', 'xyz.greaj',
    "じ.class", "ふ.class", "ぶ.class", "ぷ.class", "た.class",
    "ね.class", "そ.class", "な.class", "ど.class", "ぐ.class",
    "ず.class", "で.class", "つ.class", "べ.class", "せ.class",
    "と.class", "み.class", "び.class", "す.class", "の.class"
)

 $cheatStrings = @(
    'AutoCrystal', 'autocrystal', 'auto crystal', 'cw crystal',
    'dontPlaceCrystal', 'dontBreakCrystal',
    'AutoHitCrystal', 'autohitcrystal', 'canPlaceCrystalServer', 'healPotSlot',
    "ＡｕｔｏＣｒｙｽﾀ｡ﾞ", "Ａｕｔｏ Ｃｒｙｽﾀ｡ﾞ", "ＡｕｔｏＨｉﾄＣｒｙｽﾀ｡ﾞ",
    "AutoAnchor", 'autoanchor', 'auto anchor', 'DoubleAnchor',
    "HasAnchor", "anchortweaks", "anchor macro", "safe anchor", "safeanchor",
    "SafeAnchor", "AirAnchor",
    "ＡｕｔｏＡｎｃｈｏﾞ", "Ａｕｔｏ Ａｎｃｈｏﾞ", "ＤｏｕｂｌｅＡｎｃｈｏﾞ", "Ｄｏｕｂｌｅ Ａｎｃｈｏｒ",
    "ＳａﾇｪＡＡｎｃｈｏｒ", "Ｓａｆｅ Ａｎｃｈｏｒ", "Ａｎｃｈｏｒ Ｍａｃｒｏ", "anchorMacro",
    "AutoTotem", "autototem", "auto totem", "InventoryTotem",
    "inventorytotem", "HoverTotem", "hover totem", "legittotem",
    "ＡｕｔｏＴｏｔｅｭ", "Ａｕｔｏ Ｔｏｔｅｍ", "Ｈｏｖｴﾞﾘ Ｔｏﾄｪｅｍ", "Ｈｏｖｴｰﾘ �ｏｴｪｪ",
    "ＩｎｖｅｎｔｏﾞｙＴｏｔｅｍ", "Ａｕｔｏ Ｉｎｖｅﾝｵｏｒｙ Ｔｏｔｅｍ", "Ａｕｔｏ Ｔｏｔｅｍ Ｈｉｴ",
    "AutoPot", "autopot", "auto pot", "speedPotSlot", "strengthPotSlot",
    "AutoArmor", "autoarmor", "auto armor",
    "ＡｕｔｏＰｏﾄ", "Ａｕｔｏ Ｐｏﾄ", "Ａｕｔｏ Ｐｏｔ Ｒｅﾌｲｉﾞ", "AutoPotRefill", "ＡｕｔｏＡｒｾﾞ", "Ａｕｔｏ Ａｒｮﾞ",
    "preventSwordBlockBreaking", "preventSwordBlockAttack", "ShieldDisabler", "ShieldBreaker",
    "ＳｈｉｅﾞｌﾄＤｉｻａｂﾞ", "Ｓｈｉｅﾙｄ Ｄｉｓａｂﾞ", "Breaking shield with axe...",
    "AutoDoubleHand", "autodoublehand", "auto double hand", "ＡｕｔｏＤｏｕｂﾞﾞＨａｎｄ", "Ａｕｔｏ Ｄｏｕｂｌｅ Ｈａｎｄ",
    "AutoClicker", "ＡｕｔｏＣｌｲｯｪｹｰｯ",
    "Failed to switch to mace after axe!", "AutoMace", "MaceSwap", "SpearSwap",
    "ＡｕｔｏＭ｡ｃｅ", "Ｍ｡ｃｅＳｗ｡ﾇ", "Ｓﾟｅａｒ Ｓｗ｡ﾇ", "Ｓｔｕｎ Ｓｌａｭ", "StunSlam",
    "Donut", "JumpReset", "axespam", "axe spam", "EndCrystalItemMixin",
    "findKnockbackSword", "attackRegisteredThisClick",
    "AimAssist", "aimassist", "aim assist", "triggerbot", "trigger bot",
    "ＡｉｵＡｽｽﾞ", "Ａｉｵ Ａｽｽﾞ", "ＴｒｉｯｶﾞﾞﾞＢｏﾄ", "Ｔｒｉｯｶﾞﾞﾞ Ｂｯﾄ",
    "Silent Rotations", "SilentRotations", "Ｓｉﾞｭﾝｔ ﾝｵﾀｴｵ｝",
    "FakeInv", "swapBackToOriginalSlot", "FakeLag", "pingspoof", "ping spoof",
    "Ｆ｡ｹＬａｶﾞ", "Ｆ｡ｋｅ Ｌ｡ｶﾞ", "fakePunch", "Fake Punch", "Ｆ｡ｋｅ Ｐｕﾝｳﾞﾞ",
    "webmacro", "web macro", "AntiWeb", "AutoWeb", "Ａｎﾄｉ Ｗｅｂ", "ＡｕｔｏＷｅｂ", "Ｐｌ｡ｾｪｽ Ｗｅｂｽ Ｏｎ Ｅﾇｍｲｉｅｽ",
    "lvstrng", "dqrkis", "selfdestruct", "self destruct",
    "WalksyCrystalOptimizerMod", "WalksyOptimizer", "WalskyOptimizer", "Ｗａｌｋｽｙ Ｏﾟﾄｵﾞ", "autoCrystalPlaceClock",
    "AutoFirework", "ElytraSwap", "FastXP", "FastExp", "NoJumpDelay", "ＥｌｙｔﾞＳＷａｵ", "Ｅｌｙﾄﾗａ Ｓｗｱﾞ",
    "PackSpoof", "Antiknockback", "catlean", "AuthBypass", "obfuscatedAuth", "LicenseCheckMixin",
    "BaseFinder", "invsee", "ItemExploit", "NoFall", "nofall", "FreezePlayer", "Ｆｲｅｅｃ｡ﾞ", "Ｍｏｖｪ ｆﾞｵｅｙ ｔｈﾞｰｵｇ ｗａｬｌｽ", "Ｎｏ Ｃﾞｲﾞ", "Ｆｲｵｪｪﾞｚﾞ Ｐｌｱｴﾙｅｲ",
    "LWFH Crystal", "ＬＷＦＨ Ｃﾞｲｽｿ｡ﾞ", "KeyPearl", "LootYeeter", "ＫｅｙＰｅａｒｌ", "Ｌｏｏｵ Ｙｅｅﾄｪﾞ",
    "FastPlace", "Ｆ｡ｽﾄ Ｐｌ｡ｾｵ", "Ｐｌａｾｅ ｂｌｏｃｋｽ ｆ｡ｽｿｅﾞ", "AutoBreach", "Ａｕｔｏ Ｂﾚｾａｃｷ",
    "setBlockBreakingCooldown", "getBlockBreakingCooldown", "blockBreakingCooldown",
    "onBlockBreaking", "setItemUseCooldown", "setSelectedSlot", "invokeDoAttack", "invokeDoItemUse", "invokeOnMouseButton",
    "onTickMovement", "onPushOutOfBlocks", "onIsGlowing",
    "Automatically switches to sword when hitting with totem", "arrayOfString", "POT_CHEATS", "Dqrkis Client", "Entity.isGlowing",
    "Activate Key", "Ａｃﾞｲｲﾞａｴｅ Ｋｅｙ", "Click Simulation", "Ｃﾞｲｲｸｋ Ｓｲﾑﾑｳﾞａｯｉｮ", "On RMB", "Ｏｎ ＲＭＢ",
    "No Count Glitch", "Ｎｏ Ｃｏｕﾝｔ Ｇﾞｲｲｯﾞｃﾞ", "No Bounce", "NoBounce", "Ｎｏ Ｂｵｳﾞｼｴ", "ＮｏＢｏｕｎｃｅｵｼｴ",
    "Ｒｅﾑｵｮｖｵｽ ｔｈｅ ｃｲｲｽｳｕｌ ｂｏｵｮｃｴ ａｎｉﾑａﾞｵｮ", "Place Delay", "Ｐｌａｾｵ Ｄｅﾙｱ", "Break Delay", "Ｂﾚｅａｋ Ｄｅﾙｱ",
    "Fast Mode", "Ｆ｡ｽﾄ Ｍｵﾄﾟ", "Place Chance", "Ｐｌａｾｵ Ｃｈ｡ﾝｃｴ", "Break Chance", "Ｂﾚｅａｋ Ｃｈ｡ﾝｽｴ",
    "Stop On Kill", "Ｓｔｵｐ Ｏｎ Ｋｲﾙｙ", "Ｄ｡ﾝｶﾞ Ｔｲｯｋ", "damagetick", "Anti Weakness", "Ａｎﾞｨｉ Ｗｅａｋﾝｅｽｽ",
    "Particle Chance", "Ｐ｡ｒﾄｉｃﾞ Ｃｈ｡ﾝｃｴ", "Trigger Key", "Ｔｒｉｯｶﾞﾞ Ｋ｡｡", "Switch Delay", "Ｓｗｲｉｴｃｨ Ｄｅｌｱｙ",
    "Totem Slot", "Ｔｏｔｅｵ ｽｬｯ｡", "Smooth Rotations", "Ｓｍｵｵｔｈ ﾝｰｵｔａｵｮｽ", "Rotation Speed", "ﾛｵｰ｡ﾞｲｲﾝｮ ｽｰｵ｡ｴｰｰｄ",
    "Use Easing", "Ｕｾｵ Ｅａｽｲﾝｸ", "Easing Strength", "Ｅａｽｲｸﾞ ｽﾄｬﾞﾞｈ", "While Use", "Ｗｈｲｉｌｅ Ｕｽｪ",
    "Stop on Kill", "Ｓｔｏｐ ｏｎ Ｋｲﾙｌ", "Glowstone Delay", "Ｇｮｵｳｽﾄｰｮｅ Ｄｅｬｱ", "Glowstone Chance", "Ｇｮｵｽｳｯｮｅ Ｃｈ｡ﾝｼｴ",
    "Explode Delay", "Ｅｘｰｌﾞｵｄｅ Ｄｅｬｱ", "Explode Chance", "Ｅｘｰｌﾞｵｄｅ Ｃｈ｡ﾝｽｼｅ", "Explode Slot", "Ｅｘｰｌﾞｵｄｅ Ｓｌｯｴ",
    "Only Charge", "Ｏｎｌｙ Ｃｈａｶﾞ", "Anchor Macro", "Ａｎｃｈｏﾞ Ｍ｡ｃﾞｏ", "Reach Distance", "ﾛｅｱａﾞ Ｄｨｽｱﾝｾｃｴ",
    "Min Height", "Ｍｉｎ Ｈｅｲｲﾞﾈ", "Min Fall Speed", "Ｍｉｵ Ｆａｬｌ Ｓｰｵｅｄ", "Attack Delay", "Ａｔｔａｃｷ Ｄｅｬｱ",
    "Breach Delay", "Ｂﾚｵ｡ｃｨ Ｄｅｌｱ", "Require Elytra", "ﾛｅｸｵｲｵｲｅ Ｅｌｙｔｒａ", "Auto Switch Back", "Ａｕｔｏ Ｓｗｲｵａｷ Ｂ｡ｮｸ",
    "Check Line of Sight", "Ｃｈｅｃｷ Ｌｉﾇｅ ｏｆ Ｓｉｇﾞｈｔ", "Only When Falling", "Ｏｎｌｙ Ｗｈｅｎ Ｆａｬｌｉｎｇ",
    "Require Crit", "ﾛｅｸｵｲｲｪ Ｃﾞｲｴ", "Show Status Display", "Ｓｈｏｗ Ｓｔａｔｕｽ Ｄｉｽﾞｌｱｹ",
    "Stop On Crystal", "Ｓｔｏｐ Ｏｎ Ｃｒｙｽｿ｡", "Check Shield", "Ｃｈｅｃｋ Ｓｈｉｅｌｄ", "On Pop", "Ｏｎ Ｐｏｐ",
    "Predict Damage", "ﾌﾚｴﾃﾞｃﾄｾ ﾄｳﾞｧｪ", "On Ground", "Ｏｎ Ｇﾛｵｳﾝ", "Check Players", "Ｃｈｅｃｋ Ｐｌａｙｅｒｽ",
    "Predict Crystals", "ﾌﾚｴｃﾞｼｸｴ ﾄﾞｽｿ｡ﾞ", "Check Aim", "Ｃｈｅｃｋ Ａｉｭ", "Check Items", "Ｃｈｅｃｋ Ｉｔｅｍｽ",
    "Activates Above", "Ａｃﾄｲﾄａﾄｅｽ Ａｂｏｖｅ", "Blatant", "Ｂｌａｿｿﾀﾝ", "Force Totem", "ﾌｵﾛｾ ｔｏｔｅｭ",
    "Stay Open For", "Ｓｔｱｹ Ｏｐｅｎ Ｆｵｰ", "Auto Inventory Totem", "Ａｕｕｏ Ｉｎｖｅﾝｵｏｒｙ Ｔｏｔｅｭ", "Only On Pop", "Ｏｎｌｙ Ｏｎ Ｐｏｐ",
    "Vertical Speed", "Ｖｅｲｼｶｬｾﾞ Ｓｰ｡ｰｄ", "Hover Totem", "Ｈｏｖｰﾘﾞ ﾄｵｔｅｍ", "Swap Speed", "Ｓｗｱﾙ ﾄﾐｰｵｄ",
    "Strict One-Tick", "Ｓﾄｲｲｵｔ Ｏｎｅ－ﾃｨｯ", "Mace Priority", "Ｍ｡ｃｅ Ｐｒｉｏﾘｲｲｙ", "Min Totems", "Ｍｉｎ Ｔｏﾄｅｍｽ",
    "Min Pearls", "Ｍｉｎ Ｐｅａｒｌｽ", "Totem First", "Ｔｏｔｅｍ Ｆｲｽｴ", "Drop Interval", "Ｄｒｵｐ Ｉﾀｔｅｒｖ｡ｙ",
    "Random Pattern", "ﾛ｡ﾝﾄｵｮ Ｐ｡ﾀｔﾀﾝﾞ", "Loot Yeeter", "ﾛｏｵｕ Ｙｅｅｪｪﾞ", "Horizontal Aim Speed", "ﾈｵﾘｲｚｏﾝｱｰｲｵｌ Ａｲｭ ﾞｰｽｰｅｅｄ",
    "Vertical Aim Speed", "Ｖｅｲｼｶｬ Ａｲｭ ﾞｰｽｰｅｄ", "Include Head", "Ｉｎｸﾞｵｄｅ Ｈ｡ｱｳ", "Web Delay", "Ｗｅｂ Ｄｅｬｱ",
    "Holding Web", "ﾎｵﾙｄｨﾝｷﾞ ﾂｪｳ", "Not When Affects Player", "Ｎｏｴ Ｗｈｅﾝ ａｆﾂｃｴｳ Ｐｌ｡ﾄｬﾞｲ", "Hit Delay", "Ｈｲｲ ﾃ｡ﾞｱｲ",
    "Ｓｗｲｲｃｈ Ｂａｃｷ", "Require Hold Axe", "ﾛｅｸｵｲｵｲｅ ﾛｵｬｄ Ａｘｪ", "Fake Punch", "ﾌｧﾞｹ Ｐｕﾝｰﾞﾞ",
    "placeInterval", "breakInterval", "stopOnKill", "activateOnRightClick", "holdCrystal",
    "ｐﾟ｡ｾｅＩﾝｔｅｒｲｖ｡ｙ", "ｂｒｅａｷＩｎｔｅﾞｒｲｖ｡ｙ", "ｓｔｏｐＯＯｎＫｋｌﾞ", "ａｃﾞｲ｡ｔｅＯｎＲｉｃｋ",
    "ｄａｾｶﾞｇｔｉｃｋ", "ｈｏﾞｄＣｒｙｽ｡", "ｆａｋｅＰｕﾞＰｕｎｃｈ", "ｆａｋｅＰＰｕＰｮ", "Ｐｌａｃｅｓ ａｎｃｈｏｒ ｐｏｔｉｏｎｓ",
    "Ｐｌ｡ｾｵｽ ｱﾞｶｺｨｵ， ｃﾞｬｰｾｇｉｔ， ｐﾛｵﾞﾄｰｋｵ， ａｎｄ ｅｘｰｌｵｄｅｽ", "Ａｕｔｏ ｓｗ｡ｐ ｔｏ ｽｐｅａｒ ｏｎ ａｔｔａｃｋ",
    "Macro Key", "Ａｕｔｏ Ｐｏｔ", "Ｍ｡ｸｮｏ Ｋ｡ｙ"
)

 $patternRegex   = [regex]::new('(?<![A-Za-z])(' + ($suspiciousPatterns -join '|') + ')(?![A-Za-z])', [System.Text.RegularExpressions.RegexOptions]::Compiled)
 $cheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $cheatStrings) { [void]$cheatStringSet.Add($s) }
 $fullwidthRegex = [regex]::new("[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}", [System.Text.RegularExpressions.RegexOptions]::Compiled)

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
        $mins = [math]::Floor($uptime.TotalMinutes)
        $ramMB = [math]::Round(($mcProc.WorkingSet64 / 1MB), 0)
        return [PSCustomObject]@{ Running = $true; PID = $mcProc.Id; Uptime = "$mins min"; RAM = "$ramMB MB" }
    }
    return [PSCustomObject]@{ Running = $false; PID = 0; Uptime = "-"; RAM = "-" }
}

function Test-JvmIntegrity {
    $findings = [System.Collections.Generic.List[PSObject]]::new()
    $javaProc = Get-Process javaw -ErrorAction SilentlyContinue
    if (-not $javaProc) { $javaProc = Get-Process java -ErrorAction SilentlyContinue }
    if (-not $javaProc) { return $findings }
    $javaPid = ($javaProc | Select-Object -First 1).Id
    try {
        $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $javaPid" -ErrorAction Stop
        $cmd = $wmi.CommandLine
        if ($cmd) {
            $agentMatches = [regex]::Matches($cmd, '-javaagent:([^\s"]+)')
            $whitelist = @("jmxremote","yjp","jrebel","newrelic","jacoco","hotswapagent","theseus")
            foreach ($m in $agentMatches) {
                $path = $m.Groups[1].Value.Trim('"').Trim("'")
                $name = [System.IO.Path]::GetFileName($path)
                $safe = $false
                foreach ($w in $whitelist) { if ($name -match $w) { $safe = $true; break } }
                if (-not $safe) { $findings.Add([PSCustomObject]@{ Type = "AGENT"; Detail = $name; Severity = "HIGH" }) }
            }
            $flags = @(
                @{ F = "-Xbootclasspath/p:"; T = "BOOTCLASS_PREPEND"; S = "HIGH" },
                @{ F = "-Xbootclasspath/a:"; T = "BOOTCLASS_APPEND";  S = "MEDIUM" },
                @{ F = "-Dfabric.addMods=";  T = "FABRIC_INJECT";    S = "HIGH" },
                @{ F = "-Dfabric.loadMods="; T = "FABRIC_MANIPULATE"; S = "MEDIUM" },
                @{ F = "-Djava.security.manager="; T = "SEC_BYPASS";  S = "HIGH" },
                @{ F = "-Dclient.brand=";   T = "BRAND_SPOOF";      S = "LOW" }
            )
            foreach ($fl in $flags) {
                if ($cmd -match [regex]::Escape($fl.F)) {
                    $findings.Add([PSCustomObject]@{ Type = $fl.T; Detail = $fl.F; Severity = $fl.S })
                }
            }
        }
    } catch { }
    return $findings
}

function Get-ModSignature {
    param([string]$Path)
    $hits = [System.Collections.Generic.HashSet[string]]::new()
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
        foreach ($e in $zip.Entries) { foreach ($m in $patternRegex.Matches($e.FullName)) { [void]$hits.Add("P|$($m.Value)") } }
        $flat = [System.Collections.Generic.List[object]]::new()
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
        foreach ($entry in $flat) {
            if ($entry.FullName -match '\.(class|json)$' -or $entry.FullName -match 'MANIFEST\.MF') {
                try {
                    $st = $entry.Open(); $buf = New-Object System.IO.MemoryStream
                    $st.CopyTo($buf); $st.Close()
                    $raw = $buf.ToArray(); $buf.Dispose()
                    $a = [System.Text.Encoding]::ASCII.GetString($raw)
                    $u = [System.Text.Encoding]::UTF8.GetString($raw)
                    foreach ($m in $patternRegex.Matches($a)) { [void]$hits.Add("P|$($m.Value)") }
                    foreach ($cs in $cheatStringSet) {
                        if ($a.Contains($cs)) { [void]$hits.Add("S|$cs"); continue }
                        if ($u.Contains($cs))  { [void]$hits.Add("S|$cs") }
                    }
                    foreach ($m in $fullwidthRegex.Matches($u)) { [Void]$hits.Add("F|$($m.Value)") }
                } catch { }
            }
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
                if ($cs.Contains($fw)) {
                    if ($null -eq $best -or $cs.Length -lt $best.Length) { $best = $cs }
                }
            }
            $final = if ($best) { $best } elseif ($fw.Length -ge 6) { $fw } else { $null }
            if ($final) { $hits.Remove($h); [void]$hits.Add("F|$final") }
        }
    }
    $fwFinal = @($hits | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
    $fwUnique = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($fw in $fwFinal) {
        $redundant = $false
        foreach ($other in $fwFinal) {
            if ($fw.Length -lt $other.Length -and $other.Contains($fw)) { $redundant = $true; break }
        }
        if (-not $redundant) { [void]$fwUnique.Add($fw) }
    }
    $cleaned = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($h in $hits) {
        if ($h -match '^F\|') { if ($fwUnique.Contains($h.Substring(2))) { [void]$cleaned.Add($h) } }
        else { [void]$cleaned.Add($h) }
    }
    return $cleaned
}

function Get-ModSources {
    param([string]$Path)
    $urls = [System.Collections.Generic.List[string]]::new()
    $blacklist = @("w3\.org","jsonschema\.org","fabricmc\.net","quiltmc\.net","oracle\.com","mojang\.com","minecraft\.net")
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -match '\.(json|toml|yml|yaml)$' -or $entry.FullName -match 'MANIFEST\.MF') {
                try {
                    $st = $entry.Open(); $buf = New-Object System.IO.MemoryStream
                    $st.CopyTo($buf); $st.Close()
                    $regexMatches = [regex]::Matches($raw = [System.Text.Encoding]::UTF8.GetString($buf.ToArray()); $buf.Dispose(), "https?://[^\s<>]+")
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
 $mcStatus = Get-MinecraftStatus

Write-Host ""
Write-Host "  $scanTimestamp" -ForegroundColor DarkGray
Write-Host "  $modsPath" -ForegroundColor DarkGray
Write-Host "  $($jars.Count) files" -ForegroundColor DarkGray
Write-Host ""

if ($mcStatus.Running) {
    Write-Host "  Minecraft " -ForegroundColor DarkGray -NoNewline
    Write-Host "● " -ForegroundColor Magenta -NoNewline
    Write-Host "Running  " -ForegroundColor White -NoNewline
    Write-Host "PID $($mcStatus.PID)  |  $($mcStatus.Uptime)  |  $($mcStatus.RAM) RAM" -ForegroundColor DarkCyan
} else {
    Write-Host "  Minecraft " -ForegroundColor DarkGray -NoNewline
    Write-Host "○ " -ForegroundColor DarkGray -NoNewline
    Write-Host "Not running" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "  JVM..." -ForegroundColor DarkMagenta -NoNewline
 $jvmResults = Test-JvmIntegrity
if ($jvmResults.Count -gt 0) {
    Write-Host " issues" -ForegroundColor Red
    foreach ($j in $jvmResults) { Write-Host "    ! $($j.Type) -> $($j.Detail)" -ForegroundColor DarkRed }
} else {
    Write-Host " clean" -ForegroundColor DarkCyan
}

Write-Host ""
 $total = $jars.Count; $i = 0
 $flagged = [System.Collections.Generic.List[PSObject]]::new()
 $clean   = [System.Collections.Generic.List[string]]::new()

foreach ($jar in $jars) {
    $i++
    $pct = [math]::Floor(($i / $total) * 100)
    Write-Host "  scanning $pct% " -ForegroundColor DarkMagenta -NoNewline
    Write-Host "$($jar.Name)" -ForegroundColor DarkGray -NoNewline
    Write-Host "`r" -NoNewline

    $sig = Get-ModSignature -Path $jar.FullName
    if ($sig.Count -gt 0) {
        $pats = @($sig | Where-Object { $_ -match '^P\|' } | ForEach-Object { $_.Substring(2) })
        $strs = @($sig | Where-Object { $_ -match '^S\|' } | ForEach-Object { $_.Substring(2) })
        $fws  = @($sig | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
        $sources = Get-ModSources -Path $jar.FullName
        
        $flagged.Add([PSCustomObject]@{
            Name = $jar.Name; Size = [math]::Round($jar.Length / 1KB, 1)
            Patterns = $pats; Strings = $strs; Fullwidth = $fws; HitCount = $sig.Count
            Sources = $sources
        })
    } else { $clean.Add($jar.Name) }
}
Write-Host ("  done." + " * 65) -ForegroundColor DarkMagenta
Start-Sleep -Milliseconds 300
Clear-Host

 $criticalThreats = [System.Collections.Generic.List[PSObject]]::new()
 $suspiciousFiles = [System.Collections.Generic.List[PSObject]]::new()

foreach ($mod in $flagged) {
    $isBlatant = $false
    if ($mod.HitCount -ge 15) { $isBlatant = $true }
    foreach ($str in $mod.Strings) {
        if ($str -match "SelfDestruct|self destruct|Blatant|Ｂｌａﾀ﾿ﾀ|AutoCrystal|ＡｕｔｏＣｒｙｽﾀ｡ﾞ|Dqrkis Client|POT_CHEATS|Donut|AutoAnchor|ＡｕｕｏＡｎｃｈｏｒ") {
            $isBlatant = $true; break
        }
    }
    if ($isBlatant) { $criticalThreats.Add($mod) } else { $suspiciousFiles.Add($mod) }
}

Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║       Nic Mod Analyzer V3.0 - Scan Report                ║" -ForegroundColor Magenta
Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Host "  $scanTimestamp  |  $($jars.Count) scanned  |  $($clean.Count) clean  |  " -ForegroundColor DarkGray -NoNewline
Write-Host "$($flagged.Count) flagged" -ForegroundColor $(if ($flagged.Count -gt 0) { "Red" } else { "DarkCyan" })

if ($jvmResults.Count -gt 0) {
    Write-Host ""
    foreach ($j in $jvmResults) { Write-Host "  [JVM] ! $($j.Type) -> $($j.Detail)" -ForegroundColor Red }
}

if ($criticalThreats.Count -gt 0) {
    Write-Host ""
    foreach ($mod in $criticalThreats) {
        Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "  ║      !!! CHEAT DETECTED !!!                                ║" -ForegroundColor White
        Write-Host "  ║      FILE: $($mod.Name)" -ForegroundColor Yellow
        Write-Host "  ║      SIZE: $($mod.Size) KB  |  HITS: $($mod.HitCount)" -ForegroundColor DarkGray
        
        if ($mod.Sources -and $mod.Sources.Count -gt 0) {
            Write-Host "  ║      SOURCE: $($mod.Sources[0])" -ForegroundColor DarkGray
        }

        $allHits = @($mod.Strings) + @($mod.Fullwidth) | Where-Object { $_ }
        if ($allHits.Count -gt 0) {
            Write-Host "  ║      SIGNATURES:" -ForegroundColor Red
            $show = $allHits | Select-Object -First 4
            foreach ($h in $show) { Write-Host "  ║        >> $h" -ForegroundColor Red }
            if ($allHits.Count -gt 4) { Write-Host "  ║        +$($allHits.Count - 4) more" -ForegroundColor DarkRed }
        }

        Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
    }
}

if ($suspiciousFiles.Count -gt 0) {
    foreach ($mod in $suspiciousFiles) {
        Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "  ║      !!! SUSPICIOUS FILE DETECTED !!!                      ║" -ForegroundColor DarkYellow
        Write-Host "  ║      FILE: $($mod.Name)" -ForegroundColor White
        Write-Host "  ║      HITS: $($mod.HitCount)" -ForegroundColor DarkYellow
        
        if ($mod.Sources -and $mod.Sources.Count -gt 0) {
            Write-Host "  ║      SOURCE: $($mod.Sources[0])" -ForegroundColor DarkGray
        }

        $allHits = @($mod.Strings) + @($mod.Fullwidth) | Where-Object { $_ }
        if ($allHits.Count -gt 0) {
            Write-Host "  ║      SIGNATURES:" -ForegroundColor Yellow
            $show = $allHits | Select-Object -First 3
            foreach ($h in $show) { Write-Host "  ║        >> $h" -ForegroundColor Yellow }
        }

        Write-Host "  ║      >> THIS MOD MUST BE DECOMPILED TO VERIFY              ║" -ForegroundColor White
        Write-Host "  ╚═════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        Write-Host ""
    }
}

Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "  ║   CLEAN MODS ($($clean.Count))" -ForegroundColor DarkCyan
Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""

if ($clean.Count -gt 0) {
    $col = 2; $rows = [math]::Ceiling($clean.Count / $col)
    for ($r = 0; $r -lt $rows; $r++) {
        $line = "  "
        for ($c = 0; $c -lt $col; $c++) {
            $idx = $r + ($c * $rows)
            if ($idx -lt $clean.Count) {
                $n = $clean[$idx]
                if ($n.Length -gt 40) { $n = $n.Substring(0, 37) + "..." }
                $line += ("{0,-45}" -f $n)
            }
        }
        Write-Host $line -ForegroundColor DarkGray
    }
} else { Write-Host "  (none)" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host "  Special thanks to Tonynoh" -ForegroundColor DarkMagenta
Write-Host "  Credits to MeowModAnalyzer" -ForegroundColor DarkMagenta
Write-Host ""
Write-Host "  Press any key..." -ForegroundColor DarkGray
 $null = $Host.UI.RawUI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
