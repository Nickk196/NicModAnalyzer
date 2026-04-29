[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host

# ═══════════════════════════════════════════════════════════
#  BANNER
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host " ███╗   ██╗██╗ ██████╗    ███╗   ███╗ ██████╗ ██████╗      █████╗ ███╗   ██╗ █████╗ ██╗  ██╗   ██╗███████╗███████╗██████╗ " -ForegroundColor Magenta
Write-Host " ████╗  ██║██║██╔════╝    ████╗ ████║██╔═══██╗██╔══██╗    ██╔══██╗████╗  ██║██╔══██╗██║  ╚██╗ ██╔╝╚══███╔╝██╔════╝██╔══██╗" -ForegroundColor Magenta
Write-Host " ██╔██╗ ██║██║██║         ██╔████╔██║██║   ██║██║  ██║    ███████║██╔██╗ ██║███████║██║   ╚████╔╝   ███╔╝ █████╗  ██████╔╝" -ForegroundColor DarkMagenta
Write-Host " ██║╚██╗██║██║██║         ██║╚██╔╝██║██║   ██║██║  ██║    ██╔══██║██║╚██╗██║██╔══██║██║    ╚██╔╝   ███╔╝  ██╔══╝  ██╔══██╗" -ForegroundColor DarkMagenta
Write-Host " ██║ ╚████║██║╚██████╗    ██║ ╚═╝ ██║╚██████╔╝██████╔╝    ██║  ██║██║ ╚████║██║  ██║███████╗██║   ███████╗███████╗██║  ██║" -ForegroundColor Magenta
Write-Host " ╚═╝  ╚═══╝╚═╝ ╚═════╝   ╚═╝     ╚═╝ ╚═════╝ ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "                          [ V4.0 - MOD ANALYZER ]" -ForegroundColor Magenta
Write-Host "   ─────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# ═══════════════════════════════════════════════════════════
#  PATH INPUT
# ═══════════════════════════════════════════════════════════
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

# ═══════════════════════════════════════════════════════════
#  DEEP SCAN PROMPT
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host '  Scan mode: ' -ForegroundColor DarkGray -NoNewline
Write-Host '[1]' -ForegroundColor Magenta -NoNewline
Write-Host ' Standard  ' -ForegroundColor White -NoNewline
Write-Host '[2]' -ForegroundColor Magenta -NoNewline
Write-Host ' Deep (slower, checks all file types + entropy)' -ForegroundColor White
Write-Host '  > ' -ForegroundColor Magenta -NoNewline
$scanModeInput = Read-Host
$deepScan = ($scanModeInput.Trim() -eq '2')

if ($deepScan) {
    Write-Host '  Deep scan enabled.' -ForegroundColor DarkMagenta
} else {
    Write-Host '  Standard scan enabled.' -ForegroundColor DarkGray
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

# ═══════════════════════════════════════════════════════════
#  SUSPICIOUS PATTERNS (filename/class path matching)
# ═══════════════════════════════════════════════════════════
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
    'ElytraSwap', 'FastXP', 'FastExp', 'Refill', 'AirAnchor',
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

# ═══════════════════════════════════════════════════════════
#  CHEAT STRING SIGNATURES
# ═══════════════════════════════════════════════════════════
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
    "ＩｎｖｅｎｔｏﾞｙＴｏｔｅｍ", "Ａｕｔｏ Ｉｎｖｅﾝｵｏｒｙ Ｔｏｔｅｍ", "Ａｕｔｏ Ｔｏｔｅｭ Ｈｉｴ",
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
    "BaseFinder", "invsee", "ItemExploit", "NoFall", "nofall", "FreezePlayer", "Ｆｲｅｅｃ｡ﾞ", "Ｍｏｖｪ ｆﾞｵｅｙ ｔｈﾞｰｵｇ ｗａｬｌｽ", "Ｎｏ Ｃﾞｲﾞ", "Ｆｲｵｪｪﾞｚﾞ Ｐｌｱｴﾙｅｲ",
    "LWFH Crystal", "ＬＷＦＨ Ｃﾞｲｽｿ｡ﾞ", "KeyPearl", "LootYeeter", "ＫｅｙＰｅａｒｌ", "Ｌｏｏｵ Ｙｅｅﾄｪﾞ",
    "FastPlace", "Ｆ｡ｽﾄ Ｐｌ｡ｾｵ", "Ｐｌａｾｅ ｂｌｏｃｋｓ ｆ｡ｽｿｅﾞ", "AutoBreach", "Ａｕｔｏ Ｂﾚｾａｃｷ",
    "setBlockBreakingCooldown", "getBlockBreakingCooldown", "blockBreakingCooldown",
    "onBlockBreaking", "setItemUseCooldown", "setSelectedSlot", "invokeDoAttack", "invokeDoItemUse", "invokeOnMouseButton",
    "onTickMovement", "onPushOutOfBlocks", "onIsGlowing",
    "Automatically switches to sword when hitting with totem", "arrayOfString", "POT_CHEATS", "Dqrkis Client", "Entity.isGlowing",
    "Activate Key", "Ａｃﾞｲｲﾞａｴｅ Ｋｅｙ", "Click Simulation", "Ｃﾞｲｲｸｋ Ｓｲﾑﾑｳﾞ｡ｯｉｮ", "On RMB", "Ｏｎ ＲＭＢ",
    "No Count Glitch", "Ｎｏ Ｃｏｕﾝｔ Ｇﾞｲｲｯﾞｃﾞ", "No Bounce", "NoBounce", "Ｎｏ Ｂｵｳﾞｼｴ", "ＮｏＢｏｕｎｃｅｵｼｴ",
    "Ｒｅﾑｵｮｖｵｽ ｔｈｅ ｃｲｲｽｳｕｌ ｂｏｵｮｃｴ ａｎｲﾑａﾞｵｮ", "Place Delay", "Ｐｌａｾｵ Ｄｅﾙｱ", "Break Delay", "Ｂﾚｅａｋ Ｄｅﾙｱ",
    "Fast Mode", "Ｆ｡ｽﾄ Ｍｵﾄﾟ", "Place Chance", "Ｐｌａｾｵ Ｃｈ｡ﾝｃｴ", "Break Chance", "Ｂﾚｅａｋ Ｃｈ｡ﾝｽｴ",
    "Stop On Kill", "Ｓｔｵｐ Ｏｎ Ｋｲﾙｙ", "Ｄ｡ﾝｶﾞ Ｔｲｯｸ", "damagetick", "Anti Weakness", "Ａｎﾞｨｉ Ｗｅａｋﾝｅｓｽ",
    "Particle Chance", "Ｐ｡ﾒﾞｉｃﾞ Ｃｈ｡ﾝｃｴ", "Trigger Key", "Ｔｒｉｯｶﾞﾞ Ｋ｡｡", "Switch Delay", "Ｓｗｲｉｴｃｨ Ｄｅｌｱ",
    "Totem Slot", "Ｔｏｔｅｵ ｽｬｯ｡", "Smooth Rotations", "Ｓｍｵｵｔｈ ﾝｰｵｔａｵｮｽ", "Rotation Speed", "ﾛｵｰ｡ﾞｲｲﾝｮ ｽｰｵ｡ｴｰｰｄ",
    "Use Easing", "Ｕｾｵ Ｅａｽｲﾝｸ", "Easing Strength", "Ｅａｽｲｸﾞ ｽﾄｬﾞﾞｈ", "While Use", "Ｗｈｲｉｌｅ Ｕｽｪ",
    "Stop on Kill", "Ｓｔｏｐ ｏｎ Ｋｲﾙｌ", "Glowstone Delay", "Ｇｮｵｳｽﾄｰｮｅ Ｄｅｬｱ", "Glowstone Chance", "Ｇｮｵｽｳｯｮｅ Ｃｈ｡ﾝｼｴ",
    "Explode Delay", "Ｅｘｰｌﾞｵｄｅ Ｄｅｬｱ", "Explode Chance", "Ｅｘｰｌﾞｵｄｅ Ｃｈ｡ﾝｽｼｴ", "Explode Slot", "Ｅｘｰｌﾞｵｄｅ Ｓｌｯｱ",
    "Only Charge", "Ｏｎｌｙ Ｃｈａｶﾞ", "Anchor Macro", "Ａｎｃｈｏﾞ Ｍ｡ｃﾞｏ", "Reach Distance", "ﾛｅｱａﾞ Ｄｨｽｱﾝｾｃｴ",
    "Min Height", "Ｍｉｎ Ｈｅｉｲﾞﾈ", "Min Fall Speed", "Ｍｉｵ Ｆａｬｌ Ｓｰｵｅｄ", "Attack Delay", "Ａｔｔａｃｷ Ｄｅｬｱ",
    "Breach Delay", "Ｂﾚｵ｡ｃｨ Ｄｅｌｱ", "Require Elytra", "ﾛｅｸｵｲｵｲｪ Ｅｌｙｔﾞｱ", "Auto Switch Back", "Ａｕｔｏ Ｓｗｲｵａｷ Ｂ｡ｮｸ",
    "Check Line of Sight", "Ｃｈｅｃｷ Ｌｉﾇｅ ｏｆ Ｓｉｇﾞｈｔ", "Only When Falling", "Ｏｎｌｙ Ｗｈｅｎ Ｆａｬｌｉｎｇ",
    "Require Crit", "ﾛｅｸｵｲｵｲｪ Ｃﾞｲｴ", "Show Status Display", "Ｓｈｏｗ Ｓｔａｔｕｓ Ｄｉｽﾞｌｱｹ",
    "Stop On Crystal", "Ｓｔｏｐ Ｏｎ Ｃｒｙｽｿ｡", "Check Shield", "Ｃｈｅｃｋ Ｓｈｉｅｌｄ", "On Pop", "Ｏｎ Ｐｏｐ",
    "Predict Damage", "ﾌﾚｴﾃﾞｾﾄｾ ﾄｳﾞｧｪ", "On Ground", "Ｏｎ Ｇﾛｵｳﾝ", "Check Players", "Ｃｈｅｃｋ Ｐｌａｙｅｒｽ",
    "Predict Crystals", "ﾌﾚｴｃﾞｼｸｴ ﾄﾞｽｿ｡ﾞ", "Check Aim", "Ｃｈｅｃｋ Ａｉｭ", "Check Items", "Ｃｈｅｃｋ Ｉｔｅｍｽ",
    "Activates Above", "Ａｃﾄｲﾀﾄｅｽ Ａｂｏｖｅ", "Blatant", "Ｂｌａﾀ﾿ﾀﾝ", "Force Totem", "ﾌｵﾛｾ ｔｏｔｅｭ",
    "Stay Open For", "Ｓｔｱｸｅ Ｏｐｅｎ Ｆｵｰ", "Auto Inventory Totem", "Ａｕｕｏ Ｉｎｖｅﾝｵｏｒｙ Ｔｏｔｅｭ", "Only On Pop", "Ｏｎｌｙ Ｏｎ Ｐｏｐ",
    "Vertical Speed", "Ｖｅｲｼｶﾬｾﾞ Ｓｰ｡ｰｄ", "Hover Totem", "Ｈｏｖｰﾘﾞ ﾄｵｔｅｭ", "Swap Speed", "Ｓｗｱﾙ ﾄﾐｰｵｄ",
    "Strict One-Tick", "Ｓﾄｲｲｵﾄ Ｏｎｅ－ﾃｨｯ", "Mace Priority", "Ｍ｡ｃｅ Ｐｒｉｏﾘｉｲｙ", "Min Totems", "Ｍｉｎ Ｔｏﾄｪｭｽ",
    "Min Pearls", "Ｍｉｎ Ｐｅａﾒﾞｌｽ", "Totem First", "Ｔｏｔｅｭ Ｆｲｽｴ", "Drop Interval", "Ｄﾞｵｐ Ｉﾀｔｪﾞｖ｡ｙ",
    "Random Pattern", "ﾛ｡ﾝﾄｵｮ Ｐ｡ﾀﾀﾝﾞ", "Loot Yeeter", "ﾛｏｕｕ Ｙｅｅｪｪﾞ", "Horizontal Aim Speed", "ﾈｵﾘｲｚｏﾝｱｰｲｵｌ Ａｲｭ ﾞｰｽｰｅｴﾄ",
    "Vertical Aim Speed", "Ｖｅｲｼｶﾬ Ａｲｭ ﾞｰｽｰｅｴﾄ", "Include Head", "Ｉｎｸﾞｵﾄｪ Ｈ｡ｱｳ", "Web Delay", "Ｗｅｂ Ｄｅｬｱ",
    "Holding Web", "ﾎｵﾙﾄｨﾝｷﾞ ﾂｪｳ", "Not When Affects Player", "Ｎｏｴ Ｗｈｅﾝ ａｆﾂｃｴｕｽ Ｐｌ｡ﾀｬﾞｲ", "Hit Delay", "Ｈｲｲ ﾃ｡ﾞｱｲ",
    "Ｓｗｲｲｃｈ Ｂａｃｷ", "Require Hold Axe", "ﾛｅｸｵｲｵｲｪ ﾛｵﾬｄ Ａｘｪ", "Fake Punch", "ﾌｧﾞｹ Ｐｕﾝｰﾞﾞ",
    "placeInterval", "breakInterval", "stopOnKill", "activateOnRightClick", "holdCrystal",
    "ｐﾟ｡ｾｅＩﾝｔｪﾞｲｖ｡ｙ", "ｂﾞｅａｋＩｎｔｪﾞﾞｲｖ｡ｙ", "ｓｔｏｐＯＯｎＫｋｌﾞ", "ａｃﾞｲ｡ｔｪＯｎＲｉｃｋ",
    "ｄ｡ｾｶﾞｇﾞｔｉｃｋ", "ｈｏﾞﾄＣﾞｲｽ｡", "ｆ｡ｋｪＰｕﾞＰｕﾝｳﾞ", "ｆ｡ｋｪＰＰｕＰｮ", "Ｐｌ｡ｾｵｽ ｡ｮｃｈｏﾞ ｐｏｔｉｏｮｽ",
    "Ｐｌ｡ｾｵｽ ｱﾞｶｺｨｵ， ｃﾞｬｰｾｇｉﾄ， ｐﾞｵｼﾞﾄｰｋｵ， ｡ｮﾄﾞ ｪｸｰｌｵｄｪｽ", "Ａｕｔｏ ｽｗ｡ｐ ｔｏ ｽｐｪ｡ﾞ ｏｮ ｡ｴｴ｡ｃｸ",
    "Macro Key", "Ａｕｔｏ Ｐｏｔ", "Ｍ｡ｸｮｏ Ｋ｡ｙ"
)

# Deep scan extra strings — broader mixin hooks, suspicious reflection, config keys
$deepCheatStrings = @(
    # Mixin hooks that legit mods don't typically use
    "invokeAttackEntity", "invokeUseItem", "invokeStopUsingItem",
    "callAttackEntity", "callUseItem",
    "getReachDistance", "setReachDistance",
    "networkHandler.sendPacket", "sendPacket(new Hand",
    "getAttackCooldownProgress", "resetLastAttackedTicks",
    "setSprinting", "setVelocity", "addVelocity",
    # Reflection/dynamic class loading abuse
    "Class.forName(", "getDeclaredMethod(", "setAccessible(true)",
    "MethodHandles.lookup", "Unsafe.getUnsafe",
    # Config / GUI strings common in clients
    "cheat", "hack", "esp", "wallhack", "killaura", "kill aura",
    "bhop", "bunnyhop", "bunny hop", "speedhack", "speed hack",
    "xray", "x-ray", "freecam", "free cam", "noclip", "no clip",
    "scaffold", "tower", "towerplace", "tower place",
    "velocity", "antikb", "anti kb", "reach", "hitbox",
    "tracers", "cave finder", "cavefinder", "ore esp",
    "fullbright", "full bright", "nuker", "anti-afk", "antiafk",
    # Network-level manipulation
    "C03PacketPlayer", "C09PacketHeldItemChange", "CPacketPlayer",
    "CPacketHeldItemChange", "ServerboundMovePlayerPacket",
    "spoofPacket", "cancelPacket", "dropPacket",
    # Obfuscation/evasion patterns
    "System.exit(0)", "Runtime.getRuntime().exec(",
    "ProcessBuilder", "shutdownNow(", "deleteOnExit(",
    # Timer manipulation
    "Timer.timerSpeed", "timerSpeed", "setTimerSpeed",
    # Module/feature registration patterns from known clients
    "ModuleManager", "FeatureManager", "HackList",
    "getModules()", "isEnabled()", "toggle()",
    "CommandManager.register", "EventBus.subscribe",
    # Screen / GUI injection
    "GuiHacks", "ClickGui", "AltManager", "SessionStealer"
)

$patternRegex   = [regex]::new('(?<![A-Za-z])(' + ($suspiciousPatterns -join '|') + ')(?![A-Za-z])', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$cheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $cheatStrings) { [void]$cheatStringSet.Add($s) }

$deepCheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $deepCheatStrings) { [void]$deepCheatStringSet.Add($s) }

$fullwidthRegex = [regex]::new("[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}", [System.Text.RegularExpressions.RegexOptions]::Compiled)

# ═══════════════════════════════════════════════════════════
#  ENTROPY CALCULATION (deep scan)
# ═══════════════════════════════════════════════════════════
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
#  MINECRAFT PROCESS STATUS
# ═══════════════════════════════════════════════════════════
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

# ═══════════════════════════════════════════════════════════
#  JVM INTEGRITY CHECK (expanded)
# ═══════════════════════════════════════════════════════════
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
            # ----- Java Agents -----
            $agentMatches = [regex]::Matches($cmd, '-javaagent:([^\s"]+)')
            $whitelist = @("jmxremote","yjp","jrebel","newrelic","jacoco","hotswapagent","theseus")
            foreach ($m in $agentMatches) {
                $path = $m.Groups[1].Value.Trim('"').Trim("'")
                $name = [System.IO.Path]::GetFileName($path)
                $safe = $false
                foreach ($w in $whitelist) { if ($name -match $w) { $safe = $true; break } }
                if (-not $safe) { $findings.Add([PSCustomObject]@{ Type = "AGENT"; Detail = $name; Severity = "HIGH" }) }
            }

            # ----- Extended JVM Flag Checks -----
            $flags = @(
                # Original flags
                @{ F = "-Xbootclasspath/p:";        T = "BOOTCLASS_PREPEND";      S = "HIGH";   D = "Prepends untrusted JAR to bootstrap classloader" },
                @{ F = "-Xbootclasspath/a:";        T = "BOOTCLASS_APPEND";       S = "MEDIUM"; D = "Appends JAR to bootstrap classloader" },
                @{ F = "-Dfabric.addMods=";         T = "FABRIC_INJECT";          S = "HIGH";   D = "Injects extra mods via Fabric property" },
                @{ F = "-Dfabric.loadMods=";        T = "FABRIC_MANIPULATE";      S = "MEDIUM"; D = "Overrides Fabric mod loading" },
                @{ F = "-Djava.security.manager=";  T = "SEC_BYPASS";             S = "HIGH";   D = "Disables or replaces Java Security Manager" },
                @{ F = "-Dclient.brand=";           T = "BRAND_SPOOF";            S = "LOW";    D = "Spoofs client brand string" },
                # New flags
                @{ F = "-Xverify:none";             T = "BYTECODE_VERIFY_OFF";    S = "HIGH";   D = "Disables JVM bytecode verification — allows tampered classes" },
                @{ F = "-noverify";                 T = "NOVERIFY";               S = "HIGH";   D = "Alias for -Xverify:none, disables class verification" },
                @{ F = "-XX:+DisableAttachMechanism"; T = "ATTACH_DISABLED";      S = "LOW";    D = "Blocks JVM attach (uncommon, can hide debugging)" },
                @{ F = "-XX:-OmitStackTraceInFastThrow"; T = "STACK_TRACE_FORCED"; S = "LOW";   D = "Minor flag, sometimes used in obfuscated builds" },
                @{ F = "-Djava.class.path=";        T = "CLASSPATH_OVERRIDE";     S = "MEDIUM"; D = "Manually overrides classpath — can inject classes" },
                @{ F = "-Djava.ext.dirs=";          T = "EXT_DIR_OVERRIDE";       S = "HIGH";   D = "Overrides JVM extension directory — deprecated injection vector" },
                @{ F = "-Djava.system.class.loader="; T = "CLASSLOADER_REPLACE";  S = "HIGH";   D = "Replaces the system classloader — severe injection risk" },
                @{ F = "-agentlib:";                T = "NATIVE_AGENT";           S = "HIGH";   D = "Loads a native JVMTI agent library — can hook anything" },
                @{ F = "-agentpath:";               T = "NATIVE_AGENT_PATH";      S = "HIGH";   D = "Loads native agent by path — deep JVM access" },
                @{ F = "-Xshare:off";               T = "CDS_DISABLED";           S = "LOW";    D = "Disables class-data sharing, sometimes used to avoid detection" },
                @{ F = "-Djava.library.path=";      T = "NATIVE_LIB_PATH";        S = "MEDIUM"; D = "Overrides native library search path — can load malicious .dll/.so" },
                @{ F = "-Dsun.misc.URLClassPath.disableJarChecking=true"; T = "JAR_CHECK_DISABLED"; S = "HIGH"; D = "Disables JAR signature checking" },
                @{ F = "-Dlog4j.configurationFile="; T = "LOG4J_CONFIG";          S = "MEDIUM"; D = "Custom log4j config — historical exploit vector" },
                @{ F = "-Dcom.sun.jndi.rmi.object.trustURLCodebase=true"; T = "JNDI_EXPLOIT"; S = "HIGH"; D = "Enables JNDI RMI codebase — Log4Shell-style attack vector" },
                @{ F = "-Dcom.sun.jndi.ldap.object.trustURLCodebase=true"; T = "JNDI_LDAP_EXPLOIT"; S = "HIGH"; D = "Enables JNDI LDAP codebase — Log4Shell variant" },
                @{ F = "-XX:+UnlockDiagnosticVMOptions"; T = "DIAGNOSTIC_UNLOCK"; S = "LOW";   D = "Unlocks diagnostic JVM options — rarely needed in legit clients" },
                @{ F = "-XX:CompileCommand=exclude"; T = "JIT_EXCLUDE";           S = "MEDIUM"; D = "Excludes methods from JIT — can hide code from analysis" },
                @{ F = "-Xdebug";                   T = "DEBUG_MODE";             S = "MEDIUM"; D = "Enables JVM debug mode — suspicious in packaged clients" },
                @{ F = "-Xrunjdwp:";                T = "REMOTE_DEBUG";           S = "HIGH";   D = "Enables remote debugging — allows arbitrary code injection" },
                @{ F = "-agentlib:jdwp";            T = "JDWP_AGENT";             S = "HIGH";   D = "Java Debug Wire Protocol agent — remote code execution risk" },
                @{ F = "-Djdk.attach.allowAttachSelf=true"; T = "SELF_ATTACH";    S = "MEDIUM"; D = "Allows JVM to attach to itself — used by some injection tools" }
            )
            foreach ($fl in $flags) {
                if ($cmd -match [regex]::Escape($fl.F)) {
                    $findings.Add([PSCustomObject]@{ Type = $fl.T; Detail = $fl.D; Severity = $fl.S })
                }
            }
        }
    } catch { }
    return $findings
}

# ═══════════════════════════════════════════════════════════
#  MOD SIGNATURE SCAN
# ═══════════════════════════════════════════════════════════
function Get-ModSignature {
    param([string]$Path, [bool]$Deep = $false)
    $hits = [System.Collections.Generic.HashSet[string]]::new()
    $entropyWarnings = [System.Collections.Generic.List[string]]::new()
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

        # Determine which extensions to scan
        $scanExtensions = '\.(class|json)$|MANIFEST\.MF'
        if ($Deep) { $scanExtensions = '\.(class|json|toml|yml|yaml|txt|cfg|properties|xml|html|js|ts|kt|groovy)$|MANIFEST\.MF' }

        foreach ($entry in $flat) {
            if ($entry.FullName -match $scanExtensions) {
                try {
                    $st = $entry.Open(); $buf = New-Object System.IO.MemoryStream
                    $st.CopyTo($buf); $st.Close()
                    $raw = $buf.ToArray(); $buf.Dispose()
                    $a = [System.Text.Encoding]::ASCII.GetString($raw)
                    $u = [System.Text.Encoding]::UTF8.GetString($raw)

                    # Standard patterns
                    foreach ($m in $patternRegex.Matches($a)) { [void]$hits.Add("P|$($m.Value)") }
                    foreach ($cs in $cheatStringSet) {
                        if ($a.Contains($cs)) { [void]$hits.Add("S|$cs"); continue }
                        if ($u.Contains($cs))  { [void]$hits.Add("S|$cs") }
                    }
                    foreach ($m in $fullwidthRegex.Matches($u)) { [void]$hits.Add("F|$($m.Value)") }

                    # Deep scan extras
                    if ($Deep) {
                        foreach ($ds in $deepCheatStringSet) {
                            if ($a.Contains($ds)) { [void]$hits.Add("D|$ds"); continue }
                            if ($u.Contains($ds))  { [void]$hits.Add("D|$ds") }
                        }
                        # Entropy check on .class files only (packed/encrypted = high entropy)
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
        }
        foreach ($n in $nested) { try { $n.Dispose() } catch { } }
        $zip.Dispose()
    } catch { }

    # Fullwidth deduplication
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
    # Add entropy warnings as hits
    foreach ($ew in $entropyWarnings) { [void]$cleaned.Add("E|$ew") }
    return $cleaned
}

# ═══════════════════════════════════════════════════════════
#  URL SOURCE EXTRACTION
# ═══════════════════════════════════════════════════════════
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

# ═══════════════════════════════════════════════════════════
#  MAIN SCAN LOOP
# ═══════════════════════════════════════════════════════════
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
Write-Host "  $($jars.Count) files  |  Mode: $(if ($deepScan) { 'DEEP' } else { 'STANDARD' })" -ForegroundColor DarkGray
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
    Write-Host " issues found" -ForegroundColor Red
    foreach ($j in $jvmResults) {
        $col = switch ($j.Severity) { "HIGH" { "Red" } "MEDIUM" { "Yellow" } default { "DarkGray" } }
        Write-Host "    [$($j.Severity)] $($j.Type)" -ForegroundColor $col -NoNewline
        Write-Host " — $($j.Detail)" -ForegroundColor DarkGray
    }
} else {
    Write-Host " clean" -ForegroundColor DarkCyan
}

Write-Host ""
$total   = $jars.Count; $i = 0
$flagged = [System.Collections.Generic.List[PSObject]]::new()
$clean   = [System.Collections.Generic.List[string]]::new()

foreach ($jar in $jars) {
    $i++
    $pct = [math]::Floor(($i / $total) * 100)
    Write-Host "  scanning $pct% " -ForegroundColor DarkMagenta -NoNewline
    Write-Host "$($jar.Name)" -ForegroundColor DarkGray -NoNewline
    Write-Host "`r" -NoNewline

    $sig = Get-ModSignature -Path $jar.FullName -Deep $deepScan
    if ($sig.Count -gt 0) {
        $pats    = @($sig | Where-Object { $_ -match '^P\|' } | ForEach-Object { $_.Substring(2) })
        $strs    = @($sig | Where-Object { $_ -match '^S\|' } | ForEach-Object { $_.Substring(2) })
        $fws     = @($sig | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
        $deep_s  = @($sig | Where-Object { $_ -match '^D\|' } | ForEach-Object { $_.Substring(2) })
        $entrp   = @($sig | Where-Object { $_ -match '^E\|' } | ForEach-Object { $_.Substring(2) })
        $sources = Get-ModSources -Path $jar.FullName
        $flagged.Add([PSCustomObject]@{
            Name     = $jar.Name
            Size     = [math]::Round($jar.Length / 1KB, 1)
            Patterns = $pats
            Strings  = $strs
            Fullwidth= $fws
            DeepHits = $deep_s
            Entropy  = $entrp
            HitCount = $sig.Count
            Sources  = $sources
        })
    } else { $clean.Add($jar.Name) }
}
Write-Host "  done.              " -ForegroundColor DarkMagenta
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
        if ($str -match "SelfDestruct|self destruct|Blatant|Ｂｌａﾀ﾿ﾀ|AutoCrystal|ＡｕｔｏＣｒｙｽﾀ｡ﾞ|Dqrkis Client|POT_CHEATS|Donut|AutoAnchor|ＡｕｕｏＡｎｃｈｏﾞ") {
            $isBlatant = $true; break
        }
    }
    if ($isBlatant) { $criticalThreats.Add($mod) } else { $suspiciousFiles.Add($mod) }
}

# ═══════════════════════════════════════════════════════════
#  REPORT BANNER
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host " ███╗   ██╗██╗ ██████╗    ███╗   ███╗ ██████╗ ██████╗      █████╗ ███╗   ██╗ █████╗ ██╗  ██╗   ██╗███████╗███████╗██████╗ " -ForegroundColor Magenta
Write-Host " ████╗  ██║██║██╔════╝    ████╗ ████║██╔═══██╗██╔══██╗    ██╔══██╗████╗  ██║██╔══██╗██║  ╚██╗ ██╔╝╚══███╔╝██╔════╝██╔══██╗" -ForegroundColor Magenta
Write-Host " ██╔██╗ ██║██║██║         ██╔████╔██║██║   ██║██║  ██║    ███████║██╔██╗ ██║███████║██║   ╚████╔╝   ███╔╝ █████╗  ██████╔╝" -ForegroundColor DarkMagenta
Write-Host " ██║╚██╗██║██║██║         ██║╚██╔╝██║██║   ██║██║  ██║    ██╔══██║██║╚██╗██║██╔══██║██║    ╚██╔╝   ███╔╝  ██╔══╝  ██╔══██╗" -ForegroundColor DarkMagenta
Write-Host " ██║ ╚████║██║╚██████╗    ██║ ╚═╝ ██║╚██████╔╝██████╔╝    ██║  ██║██║ ╚████║██║  ██║███████╗██║   ███████╗███████╗██║  ██║" -ForegroundColor Magenta
Write-Host " ╚═╝  ╚═══╝╚═╝ ╚═════╝   ╚═╝     ╚═╝ ╚═════╝ ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝" -ForegroundColor Magenta
Write-Host "   ─────────────────── SCAN REPORT ────────────────────" -ForegroundColor DarkMagenta
Write-Host ""

Write-Host "  $scanTimestamp  |  $($jars.Count) scanned  |  $($clean.Count) clean  |  " -ForegroundColor DarkGray -NoNewline
Write-Host "$($flagged.Count) flagged" -ForegroundColor $(if ($flagged.Count -gt 0) { "Red" } else { "DarkCyan" })
Write-Host "  Mode: $(if ($deepScan) { 'DEEP SCAN' } else { 'STANDARD SCAN' })" -ForegroundColor DarkMagenta

# ═══════════════════════════════════════════════════════════
#  JVM FINDINGS
# ═══════════════════════════════════════════════════════════
if ($jvmResults.Count -gt 0) {
    Write-Host ""
    Write-Host "  ┌─ JVM ISSUES ──────────────────────────────────────────" -ForegroundColor Red
    foreach ($j in $jvmResults) {
        $col = switch ($j.Severity) { "HIGH" { "Red" } "MEDIUM" { "Yellow" } default { "DarkGray" } }
        Write-Host "  │  [$($j.Severity)] $($j.Type)" -ForegroundColor $col -NoNewline
        Write-Host " — $($j.Detail)" -ForegroundColor DarkGray
    }
    Write-Host "  └──────────────────────────────────────────────────────" -ForegroundColor Red
}

# ═══════════════════════════════════════════════════════════
#  CRITICAL THREATS
# ═══════════════════════════════════════════════════════════
if ($criticalThreats.Count -gt 0) {
    Write-Host ""
    foreach ($mod in $criticalThreats) {
        Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Red
        Write-Host "  ║      !!! CHEAT DETECTED !!!                               ║" -ForegroundColor White
        Write-Host "  ║      FILE : $($mod.Name)" -ForegroundColor Yellow
        Write-Host "  ║      SIZE : $($mod.Size) KB  |  HITS: $($mod.HitCount)" -ForegroundColor DarkGray
        if ($mod.Sources -and $mod.Sources.Count -gt 0) {
            Write-Host "  ║      URL  : $($mod.Sources[0])" -ForegroundColor DarkGray
        }
        $allHits = @($mod.Strings) + @($mod.Fullwidth) | Where-Object { $_ }
        if ($allHits.Count -gt 0) {
            Write-Host "  ║      SIGNATURES:" -ForegroundColor Red
            $show = $allHits | Select-Object -First 4
            foreach ($h in $show) { Write-Host "  ║        >> $h" -ForegroundColor Red }
            if ($allHits.Count -gt 4) { Write-Host "  ║        + $($allHits.Count - 4) more" -ForegroundColor DarkRed }
        }
        if ($mod.DeepHits -and $mod.DeepHits.Count -gt 0) {
            Write-Host "  ║      DEEP HITS:" -ForegroundColor DarkRed
            foreach ($d in ($mod.DeepHits | Select-Object -First 3)) { Write-Host "  ║        ~~ $d" -ForegroundColor DarkRed }
        }
        if ($mod.Entropy -and $mod.Entropy.Count -gt 0) {
            Write-Host "  ║      HIGH ENTROPY FILES:" -ForegroundColor DarkRed
            foreach ($e in $mod.Entropy) { Write-Host "  ║        !! $e" -ForegroundColor DarkRed }
        }
        Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Red
        Write-Host ""
    }
}

# ═══════════════════════════════════════════════════════════
#  SUSPICIOUS FILES
# ═══════════════════════════════════════════════════════════
if ($suspiciousFiles.Count -gt 0) {
    foreach ($mod in $suspiciousFiles) {
        Write-Host "  ╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
        Write-Host "  ║      !!! SUSPICIOUS FILE DETECTED !!!                     ║" -ForegroundColor DarkYellow
        Write-Host "  ║      FILE : $($mod.Name)" -ForegroundColor White
        Write-Host "  ║      HITS : $($mod.HitCount)" -ForegroundColor DarkYellow
        if ($mod.Sources -and $mod.Sources.Count -gt 0) {
            Write-Host "  ║      URL  : $($mod.Sources[0])" -ForegroundColor DarkGray
        }
        $allHits = @($mod.Strings) + @($mod.Fullwidth) | Where-Object { $_ }
        if ($allHits.Count -gt 0) {
            Write-Host "  ║      SIGNATURES:" -ForegroundColor Yellow
            $show = $allHits | Select-Object -First 3
            foreach ($h in $show) { Write-Host "  ║        >> $h" -ForegroundColor Yellow }
        }
        if ($mod.DeepHits -and $mod.DeepHits.Count -gt 0) {
            Write-Host "  ║      DEEP HITS:" -ForegroundColor DarkYellow
            foreach ($d in ($mod.DeepHits | Select-Object -First 2)) { Write-Host "  ║        ~~ $d" -ForegroundColor DarkYellow }
        }
        if ($mod.Entropy -and $mod.Entropy.Count -gt 0) {
            Write-Host "  ║      HIGH ENTROPY:" -ForegroundColor DarkYellow
            foreach ($e in $mod.Entropy) { Write-Host "  ║        !! $e" -ForegroundColor DarkYellow }
        }
        Write-Host "  ║      >> THIS MOD MUST BE DECOMPILED TO VERIFY            ║" -ForegroundColor White
        Write-Host "  ╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
        Write-Host ""
    }
}

# ═══════════════════════════════════════════════════════════
#  CLEAN MODS
# ═══════════════════════════════════════════════════════════
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

# ═══════════════════════════════════════════════════════════
#  FOOTER
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  ═══════════════════════════════════════════════════════════" -ForegroundColor DarkMagenta
Write-Host "  Special thanks to Tonynoh" -ForegroundColor DarkMagenta
Write-Host "  Credits to MeowModAnalyzer" -ForegroundColor DarkMagenta
Write-Host ""
Write-Host "  Press any key..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
