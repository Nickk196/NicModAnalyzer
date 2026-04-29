[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host

 $Banner = @"
    _   _ _   _ _____ _____ ____  
   | | | | \ | |_   _| ____/ ___| 
   | | | |  \| | | | |  _| \___ \ 
   | |_| | |\  | | | | |___ ___) |
    \___/|_| \_| |_| |_____|____/ 

         M O D   A N A L Y Z E R
                V 4.0
"@
Write-Host $Banner -ForegroundColor Magenta
Write-Host "  ─────────────────────────────────────" -ForegroundColor DarkMagenta
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
    "ＳａﾇｪＡＡｎｃｈｏﾞ", "Ｓａｆｅ Ａｎｃｈｏﾞ", "Ａｎｃｈｏｒ Ｍａｃｒｏ", "anchorMacro",
    "AutoTotem", "autototem", "auto totem", "InventoryTotem",
    "inventorytotem", "HoverTotem", "hover totem", "legittotem",
    "ＡｕｔｏＴｏｔｅｭ", "Ａｕｔｏ Ｔｏｔｅｍ", "Ｈｏｖｴﾞﾘ Ｔｏﾄｪｅｍ", "Ｈｏｖｴｰﾘ oｴｪｪ",
    "ＩｎｖｅｎｔｏﾞｙＴｏｔｅｍ", "Ａｕｔｏ Ｉｎｖｅﾝｵｏｒｙ Ｔｏｔｅｍ", "Ａｕｔｏ Ｔｏｔｅｍ Ｈｉｴ",
    "AutoPot", "autopot", "auto pot", "speedPotSlot", "strengthPotSlot",
    "AutoArmor", "autoarmor", "auto armor",
    "ＡｕｔｏＰｏﾄ", "Ａｕｔｏ Ｐｏﾄ", "Ａｕｔｏ Ｐｏｔ Ｒｅﾌｉﾞ", "AutoPotRefill", "ＡｕｔｏＡｒｾﾞ", "Ａｕｔｏ Ａｒｮﾞ",
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
    "AutoFirework", "ElytraSwap", "FastXP", "FastExp", "NoJumpDelay", "ＥｌｙﾞＳＷａｵ", "Ｅｌｙﾄﾗａ Ｓｗｱﾞ",
    "PackSpoof", "Antiknockback", "catlean", "AuthBypass", "obfuscatedAuth", "LicenseCheckMixin",
    "BaseFinder", "invsee", "ItemExploit", "NoFall", "nofall", "FreezePlayer", "Ｆｲｅｅｃ｡ﾞ", "Ｍｏｖｪ ｆﾞｵｅｙ ｔｈﾞｰｵｇ ｗａｬｌｽ", "Ｎｏ Ｃﾞｲﾞ", "Ｆｲｵｪｪﾞｽﾞ Ｐｌｱｴﾙｅｲ",
    "LWFH Crystal", "ＬＷＦＨ Ｃﾞｲｽｿ｡ﾞ", "KeyPearl", "LootYeeter", "ＫｅｙＰｅａｒｌ", "Ｌｏｏｵ Ｙｅｅﾄｪﾞ",
    "FastPlace", "Ｆ｡ｽﾄ Ｐｌ｡ｾｵ", "Ｐｌａｾｅ ｂｌｏｃｋｓ ｆ｡ｽｿｅﾞ", "AutoBreach", "Ａｕｔｏ Ｂﾚｾ｡ｃｷ",
    "setBlockBreakingCooldown", "getBlockBreakingCooldown", "blockBreakingCooldown",
    "onBlockBreaking", "setItemUseCooldown", "setSelectedSlot", "invokeDoAttack", "invokeDoItemUse", "invokeOnMouseButton",
    "onTickMovement", "onPushOutOfBlocks", "onIsGlowing",
    "Automatically switches to sword when hitting with totem", "arrayOfString", "POT_CHEATS", "Dqrkis Client", "Entity.isGlowing",
    "Activate Key", "Ａｃﾞｲｲﾞａｴｅ Ｋｅｙ", "Click Simulation", "Ｃﾞｲｲｸｋ Ｓｲﾑﾑｳﾞ｡ｯｉｮ", "On RMB", "Ｏｎ ＲＭＢ",
    "No Count Glitch", "Ｎｏ Ｃｏｕﾝｔ Ｇﾞｲｲｯﾞｃﾞ", "No Bounce", "NoBounce", "Ｎｏ Ｂｵｳﾞｼｴ", "ＮｏＢｏｕｎｃｪｵｼｴ",
    "Ｒｪﾑｵｮｖｵｽ ｔｈｪ ｃｲｲｽｳｕｌ ｂｏｵｮｃｪ ｡ｮｲﾑ｡ﾞｵｮ", "Place Delay", "Ｐｌ｡ｾｵ Ｄｪﾙｱ", "Break Delay", "Ｂﾚｪ｡ｋ Ｄｪﾙｱ",
    "Fast Mode", "Ｆ｡ｽﾄ Ｍｵﾄﾟ", "Place Chance", "Ｐｌ｡ｾｵ Ｃｈ｡ﾝｃｪ", "Break Chance", "Ｂﾚｪ｡ｋ Ｃｈ｡ﾝｽｪ",
    "Stop On Kill", "Ｓｔｵｐ Ｏｎ Ｋｲﾙｙ", "Ｄ｡ﾝｶﾞ Ｔｲｯｋ", "damagetick", "Anti Weakness", "Ａｮﾞｨｉ Ｗｪ｡ｋﾞｪｽｽ",
    "Particle Chance", "Ｐ｡ﾒﾞｉｃﾞ Ｃｈ｡ﾝｃｪ", "Trigger Key", "Ｔﾞｨｯｶﾞﾞ Ｋ｡｡", "Switch Delay", "Ｓｗｲｉｪｃｨ Ｄｪﾙｱ",
    "Totem Slot", "Ｔｏｔｪｭ ｽｬｯ｡", "Smooth Rotations", "Ｓｭｵｵｔｈ ﾝｰｵｔ｡ｵｮｽ", "Rotation Speed", "ﾛｵｰ｡ﾞｲｲﾝｮ ｽｰｵ｡ｪｰｰｄ",
    "Use Easing", "Ｕｾｵ Ｅ｡ｽｲﾝｸ", "Easing Strength", "Ｅ｡ｽｲｸﾞ ｽﾄｬﾞﾞｈ", "While Use", "Ｗｈｲｬｪ Ｕｽｪ",
    "Stop on Kill", "Ｓｔｏｐ ｏｎ Ｋｲﾙｬ", "Glowstone Delay", "Ｇｮｵｳｽﾄｰｮｪ Ｄｪﾬｱ", "Glowstone Chance", "Ｇｮｵｽｳｯｮｪ Ｃｈ｡ﾝｼｪ",
    "Explode Delay", "Ｅｘｰｬﾞｵﾄｪ Ｄｪﾬｱ", "Explode Chance", "Ｅｘｰｬﾞｵﾄｪ Ｃｈ｡ﾝｽｼｪ", "Explode Slot", "Ｅｘｰｬﾞｵﾄｪ Ｓｬｯｱ",
    "Only Charge", "Ｏｮｬｙ Ｃｈ｡ｶﾞ", "Anchor Macro", "Ａｮｃｈｏﾞ Ｍ｡ｃﾞｏ", "Reach Distance", "ﾛｪｱ｡ ﾄｨｽ｡ﾝｾｃｪ",
    "Min Height", "Ｍｉｮ Ｈｪｲｲﾞﾈ", "Min Fall Speed", "Ｍｉｵ Ｆ｡ｬｬ Ｓｰｵｪﾄ", "Attack Delay", "Ａｴｴ｡ｃｷ Ｄｪﾬｱ",
    "Breach Delay", "Ｂﾚｪｵ｡ｃｨ Ｄｪﾬｱ", "Require Elytra", "ﾛｪｸｵｲｵｲｪ Ｅｬｹﾞｱ", "Auto Switch Back", "Ａｕｴｏ Ｓｗｲｵ｡ｷ Ｂ｡ｮｸ",
    "Check Line of Sight", "Ｃｈｪｃｋ Ｌｉﾇｪ ｏｆ Ｓｉｸﾞｈｴ", "Only When Falling", "Ｏｮｬｙ Ｗｈｪｮ Ｆ｡ｬｬｉｮｸ",
    "Require Crit", "ﾛｪｸｵｲｵｲｪ Ｃﾞｲｪ", "Show Status Display", "Ｓｈｏｗ Ｓｴ｡ｴｕｽ Ｄｉｽﾞｬ｡ｷｪ",
    "Stop On Crystal", "Ｓｴｏｐ Ｏｮ Ｃﾞｲｽｏ｡", "Check Shield", "Ｃｈｪｃｋ Ｓｈｉｪｬﾞ", "On Pop", "Ｏｮ Ｐｏｐ",
    "Predict Damage", "ﾌﾚｪﾄｪｾﾄｪ ﾄｳﾞ｡ﾞｪ", "On Ground", "Ｏｮ Ｇﾞｏｕｮﾞ", "Check Players", "Ｃｈｪｃｋ Ｐｬ｡ｹｪﾞｽ",
    "Predict Crystals", "ﾌﾚｪｃﾞｼｸｪ ﾄﾞｽｏ｡ﾞ", "Check Aim", "Ｃｈｪｃｋ Ａｉｭ", "Check Items", "Ｃｈｪｃｋ Ｉｴｪｭｽ",
    "Activates Above", "Ａｃｴｉｴ｡ｴｪｽ Ａｂｏｖｪ", "Blatant", "Ｂｬ｡ﾀ﾿ﾀﾝ", "Force Totem", "ﾌｵﾞｏｾ ｴｏｴｪｭ",
    "Stay Open For", "Ｓｴ｡ｷｪ Ｏｐｪｮ Ｆｵｰ", "Auto Inventory Totem", "Ａｕｕｏ Ｉｮｖｪｮｵｮｙ Ｔｏｴｪｭ", "Only On Pop", "Ｏｮｬｙ Ｏｮ Ｐｏｐ",
    "Vertical Speed", "Ｖｪｲｼｶﾬｾﾞ Ｓｰ｡ｰﾄ", "Hover Totem", "Ｈｏｖｰﾘﾞ ﾄｵｴｪｭ", "Swap Speed", "Ｓｗｱﾞ ﾄﾐｰｵﾄ",
    "Strict One-Tick", "Ｓﾄｲｲｵﾄ Ｏｮｪ－ﾃｨｯ", "Mace Priority", "Ｍ｡ｃｪ Ｐﾞｉｏﾞｉｉｙ", "Min Totems", "Ｍｉｮ Ｔｏｴｪｭｽ",
    "Min Pearls", "Ｍｉｮ Ｐｪ｡ﾞｬｪｽ", "Totem First", "Ｔｏｴｪｭ Ｆｲｽｪ", "Drop Interval", "Ｄﾞｵｐ Ｉﾀｴﾞｖ｡ｙ",
    "Random Pattern", "ﾛ｡ﾝﾄｵｮ Ｐ｡ﾀﾀﾝﾞ", "Loot Yeeter", "ﾛｏｕｕ Ｙｪｪｪﾞ", "Horizontal Aim Speed", "ﾈｵﾞｉｚｏﾞｱｰｲｵｬ Ａｲｭ ﾞｰｽｰｪｴﾄ",
    "Vertical Aim Speed", "Ｖｪｲｼｶﾬ Ａｲｭ ﾞｰｽｰｪｴﾄ", "Include Head", "Ｉｮｸﾞｵﾄｪ Ｈ｡ｱｳ", "Web Delay", "Ｗｪｂ Ｄｪﾬｱ",
    "Holding Web", "ﾎｵﾞﾄｨﾝｷﾞ ﾂｪｳ", "Not When Affects Player", "Ｎｏｪ Ｗｈｪｮ ｡ｆﾂｃｪｕｽ Ｐｬ｡ﾀｬﾞｲ", "Hit Delay", "Ｈｲｲ ﾃ｡ﾞｱｲ",
    "Ｓｗｲｲｃｈ Ｂ｡ｃｷ", "Require Hold Axe", "ﾛｪｸｵｲｵｲｪ ﾛｵﾬﾄ Ａｘｪ", "Fake Punch", "ﾌｧﾞｋｪ Ｐｕﾝｰﾞﾞ",
    "placeInterval", "breakInterval", "stopOnKill", "activateOnRightClick", "holdCrystal",
    "ｐﾟ｡ｾｪＩﾝｴﾞｲｖ｡ｙ", "ｂﾞｪ｡ｋＩｮｴﾞﾞｲｖ｡ｙ", "ｓｴｵｐＯＯｮＫｋｬﾞ", "｡ｃﾞｲ｡ｴｪＯｮＲｉｃｋ",
    "ｄ｡ｾｶﾞｇﾞｴｉｃｋ", "ｈｏﾞﾄＣﾞｲｽ｡", "ｆ｡ｋｪＰｕﾞＰｕﾝｳﾞ", "ｆ｡ｋｪＰＰｕＰｮ", "Ｐｬ｡ｾｵｽ ｡ｮｃｈｏﾞ ｐｏｴｉｏｮｽ",
    "Ｐｬ｡ｾｵｽ ｱﾞｶｺｨｵ， ｃﾞｬｰｾｇｉﾄ， ｐﾞｵｼﾞﾄｰｋｵ， ｡ｮﾄﾞ ｪｘｰｬｵﾄｪｽ", "Ａｕｴｏ ｽｗ｡ｐ ｴｏ ｽｐｪ｡ﾞ ｏｮ ｡ｴ｡ｃｋ",
    "Macro Key", "Ａｕｴｏ Ｐｏｴ", "Ｍ｡ｸｮｏ Ｋ｡ｙ"
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
    param([int]$Pid)
    $findings = [System.Collections.Generic.List[PSObject]]::new()
    $javaProc = Get-Process -Id $Pid -ErrorAction SilentlyContinue
    if (-not $javaProc) { return $findings }
    try {
        $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $Pid" -ErrorAction Stop
        $cmd = $wmi.CommandLine
        if ($cmd) {
            $agentMatches = [regex]::Matches($cmd, '-javaagent:([^\s"]+)')
            $nativeAgentMatches = [regex]::Matches($cmd, '-agentpath:([^\s"]+)')
            $whitelist = @("jmxremote","yjp","jrebel","newrelic","jacoco","hotswapagent","theseus")
            
            foreach ($m in $agentMatches) {
                $path = $m.Groups[1].Value.Trim('"').Trim("'")
                $name = [System.IO.Path]::GetFileName($path)
                $safe = $false
                foreach ($w in $whitelist) { if ($name -match $w) { $safe = $true; break } }
                if (-not $safe) { $findings.Add([PSCustomObject]@{ Type = "JAVA_AGENT"; Detail = $name; Severity = "HIGH" }) }
            }

            foreach ($m in $nativeAgentMatches) {
                $path = $m.Groups[1].Value.Trim('"').Trim("'")
                $name = [System.IO.Path]::GetFileName($path)
                $findings.Add([PSCustomObject]@{ Type = "NATIVE_AGENT"; Detail = $name; Severity = "CRITICAL" })
            }

            $flags = @(
                @{ F = "-Xbootclasspath/p:"; T = "BOOTCLASS_PREPEND"; S = "HIGH" },
                @{ F = "-Xbootclasspath/a:"; T = "BOOTCLASS_APPEND";  S = "MEDIUM" },
                @{ F = "-Dfabric.addMods=";  T = "FABRIC_INJECT";    S = "HIGH" },
                @{ F = "-Dfabric.loadMods="; T = "FABRIC_MANIPULATE"; S = "MEDIUM" },
                @{ F = "-Djava.security.manager="; T = "SEC_BYPASS";  S = "HIGH" },
                @{ F = "-Dclient.brand=";   T = "BRAND_SPOOF";      S = "LOW" },
                @{ F = "-Djdk.attach.allowAttachSelf"; T = "SELF_ATTACH"; S = "HIGH" },
                @{ F = "--add-opens java.base/java.lang.reflect"; T = "DEEP_REFLECT_BYPASS"; S = "MEDIUM" },
                @{ F = "--add-opens java.base/sun.misc"; T = "UNSAFE_ACCESS"; S = "HIGH" }
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

function Get-DeepMemoryScan {
    param([int]$Pid)
    $findings = [System.Collections.Generic.List[PSObject]]::new()
    try {
        $proc = Get-Process -Id $Pid -ErrorAction Stop
        $suspiciousMods = @("jnativehook", "imgui", "dwm_overlay", "GameOverlay", " cheat", " hack", "inject")
        $standardMods = @("jimage", "msvcr", "msvcp", "jvm", "java", "windowscodecs", "ntdll", "kernel32", "ADVAPI32", "SECDLL", "CRYPTBASE", "clr", "coreclr", " SYSTEM32", " SysWOW64", "OpenCL", "opengl32", "vcruntime", "ucrtbase", "dxgi", "d3d", "igdumdim", "nvoglv", "atio", "wlanapi", "ws2_32", "wininet", "secur32", "SspiCli", "RpcRtRemote", "dbgeng", "gdi32", "user32", "shell32", "ole32", "mswsock", "DNSAPI", "IPHLPAPI", "NSI", "winnsi", "MPR", "credssp", "winhttp", "webio", "rasapi32", "rtutils", "wsdapi", "umpdc", "ncrypt", "ntmarta", "wevtapi", "tdh", "fastprox", "wbemcomn", "wbemsvc", "WMICNTFY", "framedyn", "clbcatq", "MMDevApi", "AudioSes", "devenum", "msdmo", "wdmaud", "ksuser", "AVRT", "powrprof", "profapi", "umpdc", "devobj", "setupapi", "cfgmgr32", "bcrypt", "bcryptprimitives", "KernelBase", "msasn1", "crypt32", "dpapi", "userenv", "imm32", "inputhost", "CoreUIComponents", "CoreMessaging", "procthread", "shcore", "uxtheme", "dwmapi", "propsys", "combase", "taskschd", "mssprx", "ntasn1", "ncryptsslp", "sspicli", "kernelbase", "apphelp", "acgenral", "dbghelp", "psapi", "version", "bcryptprimitives")
        
        foreach ($mod in $proc.Modules) {
            $modName = $mod.ModuleName.ToLower()
            $isStandard = $false
            foreach ($std in $standardMods) { if ($modName -match $std) { $isStandard = $true; break } }
            
            if (-not $isStandard) {
                foreach ($sus in $suspiciousMods) {
                    if ($modName -match $sus) {
                        $findings.Add([PSCustomObject]@{ Type = "MEMORY_INJECTION"; Detail = $mod.ModuleName; Severity = "CRITICAL" })
                        break
                    }
                }
            }
        }
    } catch {
        $findings.Add([PSCustomObject]@{ Type = "MEMORY_SCAN"; Detail = "Failed (Run as Admin?)"; Severity = "LOW" })
    }
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

Write-Host "  ─────────────────────────────────────" -ForegroundColor DarkGray
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
Write-Host "  [JVM ARGS]..." -ForegroundColor DarkMagenta -NoNewline
 $jvmResults = if ($mcStatus.Running) { Test-JvmIntegrity -Pid $mcStatus.PID } else { @() }
if ($jvmResults.Count -gt 0) {
    Write-Host " issues" -ForegroundColor Red
    foreach ($j in $jvmResults) { Write-Host "    ! [$($j.Severity)] $($j.Type) -> $($j.Detail)" -ForegroundColor DarkRed }
} else {
    Write-Host " clean" -ForegroundColor DarkCyan
}

Write-Host "  [DEEP SCAN]..." -ForegroundColor DarkMagenta -NoNewline
 $memResults = if ($mcStatus.Running) { Get-DeepMemoryScan -Pid $mcStatus.PID } else { @() }
if ($memResults.Count -gt 0) {
    Write-Host " issues" -ForegroundColor Red
    foreach ($m in $memResults) { 
        if ($m.Severity -eq "LOW") { Write-Host "    ~ $($m.Detail)" -ForegroundColor DarkYellow }
        else { Write-Host "    ! [$($m.Severity)] $($m.Type) -> $($m.Detail)" -ForegroundColor DarkRed }
    }
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
Write-Host "  done." -ForegroundColor DarkMagenta
Start-Sleep -Milliseconds 300
Clear-Host

 $criticalThreats = [System.Collections.Generic.List[PSObject]]::new()
 $suspiciousFiles = [System.Collections.Generic.List[PSObject]]::new()

foreach ($mod in $flagged) {
    $isBlatant = $false
    if ($mod.HitCount -ge 15) { $isBlatant = $true }
    foreach ($str in $mod.Strings) {
        if ($str -match "SelfDestruct|self destruct|Blatant|Ｂｬ｡ﾀ﾿ﾀ|AutoCrystal|ＡｕｴｏＣﾞｲｽﾀ｡ﾞ|Dqrkis Client|POT_CHEATS|Donut|AutoAnchor|ＡｕｕｏＡｮｃｈｏﾞ") {
            $isBlatant = $true; break
        }
    }
    if ($isBlatant) { $criticalThreats.Add($mod) } else { $suspiciousFiles.Add($mod) }
}

Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║       Nic Mod Analyzer V4.0 - Scan Report                ║" -ForegroundColor Magenta
Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Host "  $scanTimestamp  |  $($jars.Count) scanned  |  $($clean.Count) clean  |  " -ForegroundColor DarkGray -NoNewline
Write-Host "$($flagged.Count) flagged" -ForegroundColor $(if ($flagged.Count -gt 0) { "Red" } else { "DarkCyan" })

 $allRunChecks = @($jvmResults) + @($memResults)
if ($allRunChecks.Count -gt 0) {
    Write-Host ""
    foreach ($j in $allRunChecks) { 
        if ($j.Severity -eq "LOW") { Write-Host "  [RUNTIME] ~ $($j.Detail)" -ForegroundColor DarkYellow }
        else { Write-Host "  [RUNTIME] ! [$($j.Severity)] $($j.Type) -> $($j.Detail)" -ForegroundColor Red }
    }
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
 $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
