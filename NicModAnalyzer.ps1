[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host

# ═══════════════════════════════════════════════════════════
#  BANNER
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host " ███▄    █  ██▓ ▄████▄      ███▄ ▄███▓ ▒█████  ▓█████▄     ▄▄▄       ███▄    █  ▄▄▄       ██▓   ▓██   ██▓▒███████▒▓█████  ██▀███  " -ForegroundColor Magenta
Write-Host "  ██ ▀█   █ ▓██▒▒██▀ ▀█     ▓██▒▀█▀ ██▒▒██▒  ██▒▒██▀ ██▌   ▒████▄     ██ ▀█   █ ▒████▄    ▓██▒    ▒██  ██▒▒ ▒ ▒ ▄▀░▓█   ▀ ▓██ ▒ ██▒" -ForegroundColor Magenta
Write-Host " ▓██  ▀█ ██▒▒██▒▒▓█    ▄    ▓██    ▓██░▒██░  ██▒░██   █▌   ▒██  ▀█▄  ▓██  ▀█ ██▒▒██  ▀█▄  ▒██░     ▒██ ██░░ ▒ ▄▀▒░ ▒███   ▓██ ░▄█ ▒" -ForegroundColor DarkMagenta
Write-Host " ▓██▒  ▐▌██▒░██░▒▓▓▄ ▄██▒   ▒██    ▒██ ▒██   ██░░▓█▄   ▌   ░██▄▄▄▄██ ▓██▒  ▐▌██▒░██▄▄▄▄██ ▒██░     ░ ▐██▓░  ▄▀▒   ░▒▓█  ▄ ▒██▀▀█▄  " -ForegroundColor DarkMagenta
Write-Host " ▒██░   ▓██░░██░▒ ▓███▀ ░   ▒██▒   ░██▒░ ████▓▒░░▒████▓     ▓█   ▓██▒▒██░   ▓██░ ▓█   ▓██▒░██████▒ ░ ██▒▓░▒███████▒░▒████▒░██▓ ▒██▒" -ForegroundColor Magenta
Write-Host " ░ ▒░   ▒ ▒ ░▓  ░ ░▒ ▒  ░   ░ ▒░   ░  ░░ ▒░▒░▒░  ▒▒▓  ▒     ▒▒   ▓▒█░░ ▒░   ▒ ▒  ▒▒   ▓▒█░░ ▒░▓  ░  ██▒▒▒ ░▒▒ ▓░▒░▒░░ ▒░ ░░ ▒▓ ░▒▓░" -ForegroundColor DarkGray
Write-Host " ░ ░░   ░ ▒░ ▒ ░  ░  ▒      ░  ░      ░  ░ ▒ ▒░  ░ ▒  ▒      ▒   ▒▒ ░░ ░░   ░ ▒░  ▒   ▒▒ ░░ ░ ▒  ░▓██ ░▒░ ░░▒ ▒ ░ ▒ ░ ░  ░  ░▒ ░ ▒░" -ForegroundColor DarkGray
Write-Host "    ░   ░ ░  ▒ ░░           ░      ░   ░ ░ ░ ▒   ░ ░  ░      ░   ▒      ░   ░ ░   ░   ▒     ░ ░   ▒ ▒ ░░  ░ ░ ░ ░ ░   ░     ░░   ░ " -ForegroundColor DarkGray
Write-Host "          ░  ░  ░ ░                ░       ░ ░     ░              ░  ░         ░       ░  ░    ░  ░  ░  ░░    ░ ░       ░  ░   ░      " -ForegroundColor DarkGray
Write-Host ""
Write-Host "                                    [ V4.3 - MOD ANALYZER ]" -ForegroundColor Magenta
Write-Host "   ─────────────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

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

# ═══════════════════════════════════════════════════════════
#  SCAN MODE SELECTION  (multi-select: type any combo of 1-4)
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  Select scan modules " -ForegroundColor DarkGray -NoNewline
Write-Host "(combine digits, e.g. 13 = JVM + String, 4 = all)" -ForegroundColor DarkMagenta
Write-Host ""
Write-Host "  " -NoNewline
Write-Host "[1]" -ForegroundColor Magenta -NoNewline
Write-Host " JVM Scan                 " -ForegroundColor Gray -NoNewline
Write-Host "Checks Java process args for injected agents & dangerous flags" -ForegroundColor DarkGray
Write-Host "  " -NoNewline
Write-Host "[2]" -ForegroundColor Magenta -NoNewline
Write-Host " String Analysis          " -ForegroundColor Gray -NoNewline
Write-Host "Cheat signatures, bypass strings, fullwidth unicode & packet evasion" -ForegroundColor DarkGray
Write-Host "  " -NoNewline
Write-Host "[3]" -ForegroundColor Magenta -NoNewline
Write-Host " Deep Scan                " -ForegroundColor Gray -NoNewline
Write-Host "Extended strings, anti-cheat evasion, entropy & reflection analysis" -ForegroundColor DarkGray
Write-Host "  " -NoNewline
Write-Host "[4]" -ForegroundColor Magenta -NoNewline
Write-Host " Advanced Obfuscation     " -ForegroundColor Gray -NoNewline
Write-Host "Entropy, short class names, obfuscator markers & more" -ForegroundColor DarkGray
Write-Host "  " -NoNewline
Write-Host "[5]" -ForegroundColor Magenta -NoNewline
Write-Host " Everything               " -ForegroundColor Gray -NoNewline
Write-Host "Run all modules above" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  > " -ForegroundColor Magenta -NoNewline
$scanModeInput = Read-Host

$scanChoice = $scanModeInput.Trim()

$doJVM     = $false
$doStrings = $false
$doDeep    = $false
$doObf     = $false

if ($scanChoice -match '5') {
    $doJVM = $true; $doStrings = $true; $doDeep = $true; $doObf = $true
} else {
    foreach ($ch in $scanChoice.ToCharArray()) {
        switch ($ch) {
            '1' { $doJVM     = $true }
            '2' { $doStrings = $true }
            '3' { $doDeep    = $true }
            '4' { $doObf     = $true }
        }
    }
}

# Default to everything if nothing was selected
if (-not ($doJVM -or $doStrings -or $doDeep -or $doObf)) {
    $doJVM = $true; $doStrings = $true; $doDeep = $true; $doObf = $true
    Write-Host "  Invalid input — running all modules" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Modules  : " -ForegroundColor DarkGray -NoNewline
$activeModules = @()
if ($doJVM)     { $activeModules += "JVM Scan" }
if ($doStrings) { $activeModules += "String Analysis" }
if ($doDeep)    { $activeModules += "Deep Scan" }
if ($doObf)     { $activeModules += "Advanced Obfuscation" }
Write-Host ($activeModules -join "  ·  ") -ForegroundColor Magenta

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
#  CHEAT + BYPASS STRING SIGNATURES  (Module 2 — String Analysis)
#  Bypass detection strings are merged here so they always
#  run alongside cheat signatures in the standard scan.
# ═══════════════════════════════════════════════════════════
$cheatStrings = @(
    # ── Cheat signatures ─────────────────────────────────────────────────────
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
    "webmacro", "web macro", "AntiWeb", "AutoWeb", "Ａｎﾄｉ Ｗｅｂ", "ＡｕｔｏＷｅｂ", "Ｐｌ｡ｾｪｽ Ｗｅｂｽ Ｏｎ Ｅﾇｭｲｉｴｽ",
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
    "No Count Glitch", "Ｎｏ Ｃｏｕﾝｴ Ｇﾞｲｲｯﾞｃﾞ", "No Bounce", "NoBounce", "Ｎｏ Ｂｵｳﾞｼｴ", "ＮｏＢｏｕｎｃｅｵｼｴ",
    "placeInterval", "breakInterval", "stopOnKill", "activateOnRightClick", "holdCrystal",
    "Macro Key", "Ａｕｔｏ Ｐｏｔ", "Ｍ｡ｸｮｏ Ｋ｡ｙ",
    # ── Bypass / evasion signatures (merged from former Module 2) ─────────────
    "setVersion", "fakeVersion", "spoofVersion", "clientVersion",
    "brandOverride", "overrideBrand", "setBrand", "fakeClientBrand", "brandSpoof", "versionSpoof",
    "net.minecraft.client.ClientBrandRetriever",
    "ServerboundCustomPayloadPacket", "MC|Brand", "minecraft:brand",
    "cancelPacket", "dropPacket", "suppressPacket", "blockPacket",
    "spoofPacket", "injectPacket", "sendFakePacket", "sendSilentPacket",
    "packetListener", "PacketListener", "onPacketSend", "onPacketReceive",
    "PacketEvent", "PacketSendEvent", "PacketReceiveEvent",
    "ClientConnection", "interceptPacket", "NetworkHandler", "sendPacket", "receivePacket",
    "bypassAC", "bypass_ac", "evadeAC", "evadeAnticheat",
    "isGrimAC", "isNoCheat", "isAAC", "isSpartanAC", "isIntave",
    "grimBypass", "ncpBypass", "aacBypass", "spartanBypass",
    "checkAnticheat", "detectAnticheat", "getAnticheat",
    "GrimBypass", "NCPBypass", "AACBypass", "IntaveBypass",
    "setTimerSpeed", "timerSpeed", "Timer.timerSpeed",
    "tickRate", "setTickRate", "overrideTickRate", "fakeTickCount", "tickBoost",
    "reachDistance", "setReachDistance", "extendReach",
    "attackRange", "setAttackRange", "hitboxExpand", "expandHitbox", "getEntityReachDistance",
    "suppressKnockback", "cancelKnockback", "noKnockback",
    "setVelocity(0", "zeroVelocity", "ignoreKnockback",
    "antiKnockback", "KnockbackModifier", "noVelocity",
    "renderPlayerSpoofed", "spoofRender", "hideFromRender",
    "fakeGlowing", "setGlowing(false", "suppressGlow", "GlowBypass", "glowBypass",
    "baritone.bypass", "pathfindBypass", "suppressPathfind",
    "dev.gambleclient", "xyz.greaj", "dev.krypton",
    "org.chainlibs", "Dqrkis", "dqrkis", "lvstrng",
    "Asteria", "Argon", "catlean",
    "bypassLicense", "fakeAuth", "spoofSession", "SessionStealer", "AltManager",
    "grimac", "GrimAC", "grim-api", "ac.grim", "game.grim", "setGrimFlag",
    "smoothRotations", "SmoothRotations", "rotationBypass",
    "silentRotation", "SilentRotation", "fakeYaw", "fakePitch",
    "setYaw(", "setPitch(", "spoofYaw", "spoofPitch"
)

# ═══════════════════════════════════════════════════════════
#  DEEP SCAN STRINGS  (Module 3 — Deep Scan)
#  Includes the original deep strings PLUS the more technical
#  reflection/mixin bypass strings formerly in Module 2.
# ═══════════════════════════════════════════════════════════
$deepCheatStrings = @(
    # ── Original deep strings ─────────────────────────────────────────────────
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
    # ── Reflection & mixin-based bypass (formerly Module 2) ──────────────────
    "getDeclaredMethod(", "setAccessible(true)",
    "MethodHandles.lookup",
    "sun.reflect.Reflection",
    "unsafe.allocateInstance", "Unsafe.getUnsafe",
    "jdk.internal.reflect",
    "MixinEnvironment.getDefaultEnvironment",
    "IMixinConfig", "MixinTransformer",
    "SpongeAPI", "IMixinTransformer",
    "setHardTarget", "mixinBypass",
    "getGameVersion", "getGameVersion"
)

# ── Compile pattern regex and lookup sets ─────────────────────────────────────
$patternRegex = [regex]::new('(?<![A-Za-z])(' + ($suspiciousPatterns -join '|') + ')(?![A-Za-z])', [System.Text.RegularExpressions.RegexOptions]::Compiled)

$cheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $cheatStrings) { [void]$cheatStringSet.Add($s) }

$deepCheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $deepCheatStrings) { [void]$deepCheatStringSet.Add($s) }

$fullwidthRegex = [regex]::new("[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}", [System.Text.RegularExpressions.RegexOptions]::Compiled)

# ═══════════════════════════════════════════════════════════
#  ENTROPY CALCULATION
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
#  OBFUSCATION ANALYSIS (Module 4)
# ═══════════════════════════════════════════════════════════
function Get-ObfuscationScore {
    param([System.IO.Compression.ZipArchive]$Zip)
    $result = [PSCustomObject]@{
        Score        = 0
        Indicators   = [System.Collections.Generic.List[string]]::new()
        ObfLevel     = "None"
    }

    $classEntries = @($Zip.Entries | Where-Object { $_.FullName -match '\.class$' })
    $totalClasses = $classEntries.Count
    if ($totalClasses -eq 0) { return $result }

    # 1. Short class name ratio
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

    # 2. Known obfuscator markers
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

    # 3. Single-char package paths
    $deepPaths = @($classEntries | Where-Object {
        $parts = $_.FullName.Split('/')
        $parts.Count -ge 3 -and ($parts[0..($parts.Count-2)] | Where-Object { $_.Length -le 1 -and $_ -cmatch '^[a-z]$' }).Count -ge 2
    })
    if ($deepPaths.Count -gt 5) {
        $result.Score += 25
        $result.Indicators.Add("Obfuscated package tree: $($deepPaths.Count) classes in single-char packages")
    }

    # 4. Missing SourceFile attributes
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

    # 5. Unicode/invisible identifiers
    $suspiciousUniRx = [regex]::new(
        '[\u00AD\u200B\u200C\u200D\u2060\uFEFF]|[\uE000-\uF8FF]|[\u0001-\u001F\u007F-\u009F]',
        [System.Text.RegularExpressions.RegexOptions]::Compiled
    )
    $unicodeNames = @($classEntries | Where-Object { $suspiciousUniRx.IsMatch($_.FullName) })
    if ($unicodeNames.Count -gt 0) {
        $result.Score += 35
        $result.Indicators.Add("Invisible/PUA identifier chars: $($unicodeNames.Count) class(es) with zero-width or private-use codepoints")
    }

    # 6. String encryption markers
    $encryptedStringMarkers = @("decrypt", "deobf", "StringEncryption", "StringDecryptor",
                                 "decryptString", "stringPool", "StringPool", "\$\$decrypt")
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
        $mins   = [math]::Floor($uptime.TotalMinutes)
        $ramMB  = [math]::Round(($mcProc.WorkingSet64 / 1MB), 0)
        return [PSCustomObject]@{ Running = $true; PID = $mcProc.Id; Uptime = "$mins min"; RAM = "$ramMB MB" }
    }
    return [PSCustomObject]@{ Running = $false; PID = 0; Uptime = "-"; RAM = "-" }
}

# ═══════════════════════════════════════════════════════════
#  JVM INTEGRITY CHECK  (Module 1)
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
                @{ F = "-Xbootclasspath/p:";        T = "BOOTCLASS_PREPEND";      S = "HIGH";   D = "Prepends untrusted JAR to bootstrap classloader" },
                @{ F = "-Xbootclasspath/a:";        T = "BOOTCLASS_APPEND";       S = "MEDIUM"; D = "Appends JAR to bootstrap classloader" },
                @{ F = "-Dfabric.addMods=";         T = "FABRIC_INJECT";          S = "HIGH";   D = "Injects extra mods via Fabric property" },
                @{ F = "-Dfabric.loadMods=";        T = "FABRIC_MANIPULATE";      S = "MEDIUM"; D = "Overrides Fabric mod loading" },
                @{ F = "-Djava.security.manager=";  T = "SEC_BYPASS";             S = "HIGH";   D = "Disables or replaces Java Security Manager" },
                @{ F = "-Dclient.brand=";           T = "BRAND_SPOOF";            S = "LOW";    D = "Spoofs client brand string" },
                @{ F = "-Xverify:none";             T = "BYTECODE_VERIFY_OFF";    S = "HIGH";   D = "Disables JVM bytecode verification" },
                @{ F = "-noverify";                 T = "NOVERIFY";               S = "HIGH";   D = "Alias for -Xverify:none, disables class verification" },
                @{ F = "-Djava.system.class.loader="; T = "CLASSLOADER_REPLACE";  S = "HIGH";   D = "Replaces the system classloader" },
                @{ F = "-agentlib:";                T = "NATIVE_AGENT";           S = "HIGH";   D = "Loads a native JVMTI agent — can hook anything" },
                @{ F = "-agentpath:";               T = "NATIVE_AGENT_PATH";      S = "HIGH";   D = "Loads native agent by path — deep JVM access" },
                @{ F = "-Djava.library.path=";      T = "NATIVE_LIB_PATH";        S = "MEDIUM"; D = "Overrides native library search path" },
                @{ F = "-Dsun.misc.URLClassPath.disableJarChecking=true"; T = "JAR_CHECK_DISABLED"; S = "HIGH"; D = "Disables JAR signature checking" },
                @{ F = "-Dcom.sun.jndi.rmi.object.trustURLCodebase=true"; T = "JNDI_EXPLOIT"; S = "HIGH"; D = "Enables JNDI RMI codebase — Log4Shell attack vector" },
                @{ F = "-Dcom.sun.jndi.ldap.object.trustURLCodebase=true"; T = "JNDI_LDAP_EXPLOIT"; S = "HIGH"; D = "Enables JNDI LDAP codebase — Log4Shell variant" },
                @{ F = "-Xdebug";                   T = "DEBUG_MODE";             S = "MEDIUM"; D = "Enables JVM debug mode" },
                @{ F = "-Xrunjdwp:";                T = "REMOTE_DEBUG";           S = "HIGH";   D = "Enables remote debugging — arbitrary code injection risk" },
                @{ F = "-agentlib:jdwp";            T = "JDWP_AGENT";             S = "HIGH";   D = "JDWP agent — remote code execution risk" }
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
#  $ScanStrings — activates cheat+bypass string set (Module 2)
#  $ScanDeep    — activates deep strings + entropy   (Module 3)
# ═══════════════════════════════════════════════════════════
function Get-ModSignature {
    param(
        [string]$Path,
        [bool]$ScanStrings = $false,
        [bool]$ScanDeep    = $false
    )
    $hits            = [System.Collections.Generic.HashSet[string]]::new()
    $entropyWarnings = [System.Collections.Generic.List[string]]::new()

    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)

        # ── Entry path pattern scan (always active when this function is called) ──
        foreach ($e in $zip.Entries) {
            foreach ($m in $patternRegex.Matches($e.FullName)) { [void]$hits.Add("P|$($m.Value)") }
        }

        # ── Build flat entry list including nested JARs ──────────────────────
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

        # ── File extension filter (broader when deep scan is active) ─────────
        $scanExtensions = '\.(class|json)$|MANIFEST\.MF'
        if ($ScanDeep) {
            $scanExtensions = '\.(class|json|toml|yml|yaml|txt|cfg|properties|xml|html|js|ts|kt|groovy)$|MANIFEST\.MF'
        }

        foreach ($entry in $flat) {
            if ($entry.FullName -notmatch $scanExtensions) { continue }
            try {
                $st  = $entry.Open()
                $buf = New-Object System.IO.MemoryStream
                $st.CopyTo($buf); $st.Close()
                $raw = $buf.ToArray(); $buf.Dispose()
                $a   = [System.Text.Encoding]::ASCII.GetString($raw)
                $u   = [System.Text.Encoding]::UTF8.GetString($raw)

                # Suspicious pattern names
                foreach ($m in $patternRegex.Matches($a)) { [void]$hits.Add("P|$($m.Value)") }

                # ── Module 2: String Analysis (cheat + bypass signatures) ──────
                if ($ScanStrings) {
                    foreach ($cs in $cheatStringSet) {
                        if ($a.Contains($cs) -or $u.Contains($cs)) { [void]$hits.Add("S|$cs") }
                    }
                    # Fullwidth unicode
                    foreach ($m in $fullwidthRegex.Matches($u)) { [void]$hits.Add("F|$($m.Value)") }
                }

                # ── Module 3: Deep Scan + Entropy ────────────────────────────
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

    # ── Fullwidth dedup / consolidation ──────────────────────────────────────
    $fwPool = @($script:cheatStrings | Where-Object { $_ -cmatch "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]" })
    foreach ($h in @($hits)) {
        if ($h -match '^F\|') {
            $fw   = $h.Substring(2)
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
# ═══════════════════════════════════════════════════════════
function Get-ModSources {
    param([string]$Path)
    $urls      = [System.Collections.Generic.List[string]]::new()
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

# ───────────────────────────────────────────────────────────
#  PHASE 1 — JVM Scan
# ───────────────────────────────────────────────────────────
$jvmResults = [System.Collections.Generic.List[PSObject]]::new()
if ($doJVM) {
    Write-Host ""
    Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
    Write-Host "Phase 1" -ForegroundColor Magenta -NoNewline
    Write-Host " · JVM Scan" -ForegroundColor DarkGray
    Write-Host "  │" -ForegroundColor DarkMagenta
    Write-Host "  │  checking... " -ForegroundColor DarkGray -NoNewline
    $jvmResults = Test-JvmIntegrity
    if ($jvmResults.Count -gt 0) {
        Write-Host "$($jvmResults.Count) issue(s) found" -ForegroundColor Red
    } else {
        Write-Host "clean" -ForegroundColor Cyan
    }
    Write-Host "  └─ done" -ForegroundColor DarkMagenta
}

# ───────────────────────────────────────────────────────────
#  PHASE 2 — String Analysis + Deep Scan
# ───────────────────────────────────────────────────────────
$total   = $jars.Count
$i       = 0
$flagged = [System.Collections.Generic.List[PSObject]]::new()
$clean   = [System.Collections.Generic.List[string]]::new()

if ($doStrings -or $doDeep) {
    Write-Host ""
    Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
    Write-Host "Phase 2" -ForegroundColor Magenta -NoNewline
    $phaseModules = @()
    if ($doStrings) { $phaseModules += "String Analysis" }
    if ($doDeep)    { $phaseModules += "Deep Scan" }
    Write-Host (" · " + ($phaseModules -join " + ")) -ForegroundColor DarkGray
    Write-Host "  │" -ForegroundColor DarkMagenta

    foreach ($jar in $jars) {
        $i++
        $pct = [math]::Floor(($i / $total) * 100)
        Write-Host "  │  $pct% " -ForegroundColor DarkMagenta -NoNewline
        Write-Host "$($jar.Name)                    " -ForegroundColor DarkGray -NoNewline
        Write-Host "`r" -NoNewline

        $sig = Get-ModSignature -Path $jar.FullName -ScanStrings $doStrings -ScanDeep $doDeep

        if ($sig.Count -gt 0) {
            $pats   = @($sig | Where-Object { $_ -match '^P\|' } | ForEach-Object { $_.Substring(2) })
            $strs   = @($sig | Where-Object { $_ -match '^S\|' } | ForEach-Object { $_.Substring(2) })
            $fws    = @($sig | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
            $deep_s = @($sig | Where-Object { $_ -match '^D\|' } | ForEach-Object { $_.Substring(2) })
            $entrp  = @($sig | Where-Object { $_ -match '^E\|' } | ForEach-Object { $_.Substring(2) })
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
    Write-Host "  │  100% done                              " -ForegroundColor DarkMagenta
    Write-Host "  └─ $($flagged.Count) flagged  /  $($clean.Count) clean" -ForegroundColor DarkMagenta
} else {
    foreach ($jar in $jars) { $clean.Add($jar.Name) }
}

# ───────────────────────────────────────────────────────────
#  PHASE 3 — Advanced Obfuscation Detection
# ───────────────────────────────────────────────────────────
if ($doObf) {
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
        Write-Host "  │  $pct% " -ForegroundColor DarkMagenta -NoNewline
        Write-Host "$($jar.Name)                    " -ForegroundColor DarkGray -NoNewline
        Write-Host "`r" -NoNewline
        try {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
            $obfResult = Get-ObfuscationScore -Zip $zip
            $zip.Dispose()
            $obfMap[$jar.Name] = $obfResult
        } catch { $obfMap[$jar.Name] = $null }
    }
    Write-Host "  │  100% done                              " -ForegroundColor DarkMagenta

    foreach ($mod in $flagged) {
        if ($obfMap.ContainsKey($mod.Name)) { $mod.ObfResult = $obfMap[$mod.Name] }
    }
    foreach ($jar in $jars) {
        if ($clean -contains $jar.Name) {
            $obf = $obfMap[$jar.Name]
            if ($obf -and $obf.ObfLevel -ne "None") {
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
}

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
    foreach ($str in $mod.Strings) {
        if ($str -match "cancelPacket|dropPacket|spoofPacket|setTimerSpeed|timerSpeed|fakeVersion|spoofVersion|grimBypass|ncpBypass|aacBypass|bypassAC") {
            $isBlatant = $true; break
        }
    }
    if ($isBlatant) { $criticalThreats.Add($mod) } else { $suspiciousFiles.Add($mod) }
}

# ═══════════════════════════════════════════════════════════
#  HELPER — fixed-width box printer
# ═══════════════════════════════════════════════════════════
$W = 72

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
    $maxVal = $W - $Label.Length - 1
    if ($Value.Length -gt $maxVal) { $Value = $Value.Substring(0, $maxVal - 3) + "..." }
    $pad = $W - $Label.Length - $Value.Length
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
    if ($Text.Length -gt $W) { $Text = $Text.Substring(0, $W - 3) + "..." }
    $pad = $W - $Text.Length
    Write-Host "  ║" -ForegroundColor $BorderColor -NoNewline
    Write-Host $Text -ForegroundColor $TextColor -NoNewline
    Write-Host (" " * $pad + "║") -ForegroundColor $BorderColor
}

# ═══════════════════════════════════════════════════════════
#  REPORT BANNER
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host " ███▄    █  ██▓ ▄████▄      ███▄ ▄███▓ ▒█████  ▓█████▄     ▄▄▄       ███▄    █  ▄▄▄       ██▓   ▓██   ██▓▒███████▒▓█████  ██▀███  " -ForegroundColor Magenta
Write-Host "  ██ ▀█   █ ▓██▒▒██▀ ▀█     ▓██▒▀█▀ ██▒▒██▒  ██▒▒██▀ ██▌   ▒████▄     ██ ▀█   █ ▒████▄    ▓██▒    ▒██  ██▒▒ ▒ ▒ ▄▀░▓█   ▀ ▓██ ▒ ██▒" -ForegroundColor Magenta
Write-Host " ▓██  ▀█ ██▒▒██▒▒▓█    ▄    ▓██    ▓██░▒██░  ██▒░██   █▌   ▒██  ▀█▄  ▓██  ▀█ ██▒▒██  ▀█▄  ▒██░     ▒██ ██░░ ▒ ▄▀▒░ ▒███   ▓██ ░▄█ ▒" -ForegroundColor DarkMagenta
Write-Host " ▓██▒  ▐▌██▒░██░▒▓▓▄ ▄██▒   ▒██    ▒██ ▒██   ██░░▓█▄   ▌   ░██▄▄▄▄██ ▓██▒  ▐▌██▒░██▄▄▄▄██ ▒██░     ░ ▐██▓░  ▄▀▒   ░▒▓█  ▄ ▒██▀▀█▄  " -ForegroundColor DarkMagenta
Write-Host " ▒██░   ▓██░░██░▒ ▓███▀ ░   ▒██▒   ░██▒░ ████▓▒░░▒████▓     ▓█   ▓██▒▒██░   ▓██░ ▓█   ▓██▒░██████▒ ░ ██▒▓░▒███████▒░▒████▒░██▓ ▒██▒" -ForegroundColor Magenta
Write-Host " ░ ▒░   ▒ ▒ ░▓  ░ ░▒ ▒  ░   ░ ▒░   ░  ░░ ▒░▒░▒░  ▒▒▓  ▒     ▒▒   ▓▒█░░ ▒░   ▒ ▒  ▒▒   ▓▒█░░ ▒░▓  ░  ██▒▒▒ ░▒▒ ▓░▒░▒░░ ▒░ ░░ ▒▓ ░▒▓░" -ForegroundColor DarkGray
Write-Host " ░ ░░   ░ ▒░ ▒ ░  ░  ▒      ░  ░      ░  ░ ▒ ▒░  ░ ▒  ▒      ▒   ▒▒ ░░ ░░   ░ ▒░  ▒   ▒▒ ░░ ░ ▒  ░▓██ ░▒░ ░░▒ ▒ ░ ▒ ░ ░  ░  ░▒ ░ ▒░" -ForegroundColor DarkGray
Write-Host "    ░   ░ ░  ▒ ░░           ░      ░   ░ ░ ░ ▒   ░ ░  ░      ░   ▒      ░   ░ ░   ░   ▒     ░ ░   ▒ ▒ ░░  ░ ░ ░ ░ ░   ░     ░░   ░ " -ForegroundColor DarkGray
Write-Host "          ░  ░  ░ ░                ░       ░ ░     ░              ░  ░         ░       ░  ░    ░  ░  ░  ░░    ░ ░       ░  ░   ░      " -ForegroundColor DarkGray
Write-Host ""
Write-Host "                                    [ SCAN RESULTS ]" -ForegroundColor Magenta
Write-Host "   ─────────────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""

# ── Summary bar ───────────────────────────────────────────────────────────────
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
    Write-Row "  Minecraft: " "RUNNING   PID $($mcStatus.PID)   $($mcStatus.Uptime)   $($mcStatus.RAM) RAM" DarkGray Cyan DarkGray
} else {
    Write-Row "  Minecraft: " "not running" DarkGray DarkGray DarkGray
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
    foreach ($j in $jvmResults) {
        $sev = $j.Severity.PadRight(6)
        $lc  = switch ($j.Severity) { "HIGH" { [System.ConsoleColor]::Red } "MEDIUM" { [System.ConsoleColor]::Yellow } default { [System.ConsoleColor]::DarkGray } }
        Write-Row "  [$sev]  $($j.Type.PadRight(26))" $j.Detail $lc DarkGray Red
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
        Write-RowFull "  CHEAT DETECTED" Red Red
        Write-Border 'sep' Red
        Write-Row "  File     : " $mod.Name                        DarkGray Yellow Red
        Write-Row "  Size     : " "$($mod.Size) KB"                DarkGray Gray   Red
        Write-Row "  Hits     : " "$($mod.HitCount)"               DarkGray White  Red

        if ($mod.Sources -and $mod.Sources.Count -gt 0) {
            Write-Row "  Source   : " $mod.Sources[0]              DarkGray DarkGray Red
        }

        $allHits = @($mod.Strings) + @($mod.Fullwidth) | Where-Object { $_ }
        if ($allHits.Count -gt 0) {
            Write-Border 'sep' Red
            Write-RowFull "  Cheat Signatures" DarkGray Red
            foreach ($h in ($allHits | Select-Object -First 5)) {
                Write-Row "    · " $h DarkGray Red Red
            }
            if ($allHits.Count -gt 5) { Write-RowFull "    + $($allHits.Count - 5) more matches" DarkGray Red }
        }

        if ($mod.DeepHits -and $mod.DeepHits.Count -gt 0) {
            Write-Border 'sep' Red
            Write-RowFull "  Deep Scan Hits" DarkGray Red
            foreach ($d in ($mod.DeepHits | Select-Object -First 4)) {
                Write-Row "    · " $d DarkGray DarkGray Red
            }
        }

        if ($mod.Entropy -and $mod.Entropy.Count -gt 0) {
            Write-Border 'sep' Red
            Write-RowFull "  High Entropy Classes" DarkGray Red
            foreach ($e in $mod.Entropy) {
                Write-Row "    · " $e DarkGray DarkGray Red
            }
        }

        if ($mod.ObfResult -and $mod.ObfResult.ObfLevel -ne "None") {
            Write-Border 'sep' Red
            $obfColor = switch ($mod.ObfResult.ObfLevel) { "HEAVY" { [System.ConsoleColor]::Red } "MODERATE" { [System.ConsoleColor]::Yellow } default { [System.ConsoleColor]::DarkGray } }
            Write-Row "  Obfuscation : " "$($mod.ObfResult.ObfLevel)  (score: $($mod.ObfResult.Score))" DarkGray $obfColor Red
            foreach ($ind in $mod.ObfResult.Indicators) {
                Write-Row "    · " $ind DarkGray DarkGray Red
            }
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
        Write-RowFull "  SUSPICIOUS — manual decompile recommended" Yellow Yellow
        Write-Border 'sep' Yellow
        Write-Row "  File     : " $mod.Name                        DarkGray White  Yellow
        Write-Row "  Size     : " "$($mod.Size) KB"                DarkGray Gray   Yellow
        Write-Row "  Hits     : " "$($mod.HitCount)"               DarkGray White  Yellow

        if ($mod.Sources -and $mod.Sources.Count -gt 0) {
            Write-Row "  Source   : " $mod.Sources[0]              DarkGray DarkGray Yellow
        }

        $allHits = @($mod.Strings) + @($mod.Fullwidth) | Where-Object { $_ }
        if ($allHits.Count -gt 0) {
            Write-Border 'sep' Yellow
            Write-RowFull "  Cheat Signatures" DarkGray Yellow
            foreach ($h in ($allHits | Select-Object -First 4)) {
                Write-Row "    · " $h DarkGray Yellow Yellow
            }
        }

        if ($mod.DeepHits -and $mod.DeepHits.Count -gt 0) {
            Write-Border 'sep' Yellow
            Write-RowFull "  Deep Scan Hits" DarkGray Yellow
            foreach ($d in ($mod.DeepHits | Select-Object -First 3)) {
                Write-Row "    · " $d DarkGray DarkGray Yellow
            }
        }

        if ($mod.Entropy -and $mod.Entropy.Count -gt 0) {
            Write-Border 'sep' Yellow
            Write-RowFull "  High Entropy Classes" DarkGray Yellow
            foreach ($e in $mod.Entropy) {
                Write-Row "    · " $e DarkGray DarkGray Yellow
            }
        }

        if ($mod.ObfResult -and $mod.ObfResult.ObfLevel -ne "None") {
            Write-Border 'sep' Yellow
            $obfColor = switch ($mod.ObfResult.ObfLevel) { "HEAVY" { [System.ConsoleColor]::Red } "MODERATE" { [System.ConsoleColor]::Yellow } default { [System.ConsoleColor]::DarkGray } }
            Write-Row "  Obfuscation : " "$($mod.ObfResult.ObfLevel)  (score: $($mod.ObfResult.Score))" DarkGray $obfColor Yellow
            foreach ($ind in $mod.ObfResult.Indicators) {
                Write-Row "    · " $ind DarkGray DarkGray Yellow
            }
        }

        Write-Border 'bot' Yellow
    }
}

# ═══════════════════════════════════════════════════════════
#  CLEAN MODS
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Border 'top' DarkGray
Write-RowFull "  CLEAN MODS  ($($clean.Count))" Cyan DarkGray
Write-Border 'sep' DarkGray

if ($clean.Count -gt 0) {
    $colCount = 2
    $rows = [math]::Ceiling($clean.Count / $colCount)
    for ($r = 0; $r -lt $rows; $r++) {
        $left  = $clean[$r]
        $right = if (($r + $rows) -lt $clean.Count) { $clean[$r + $rows] } else { "" }
        if ($left.Length  -gt 33) { $left  = $left.Substring(0,30)  + "..." }
        if ($right.Length -gt 33) { $right = $right.Substring(0,30) + "..." }
        $cell  = ("  " + $left.PadRight(35) + $right).PadRight($W)
        Write-RowFull $cell DarkGray DarkGray
    }
} else {
    Write-RowFull "  (none)" DarkGray DarkGray
}

Write-Border 'bot' DarkGray

# ═══════════════════════════════════════════════════════════
#  BAN VERDICT
# ═══════════════════════════════════════════════════════════
Write-Host ""

if ($criticalThreats.Count -gt 0) {
    $verdictColor  = [System.ConsoleColor]::Red
    $verdictLabel  = "BAN RECOMMENDED"
    $verdictReason = "Critical cheat signatures detected in $($criticalThreats.Count) mod(s). Evidence is strong."
} elseif ($suspiciousFiles.Count -ge 3) {
    $verdictColor  = [System.ConsoleColor]::Red
    $verdictLabel  = "BAN RECOMMENDED"
    $verdictReason = "$($suspiciousFiles.Count) suspicious mods found. High probability of cheating."
} elseif ($suspiciousFiles.Count -gt 0 -or $jvmResults.Count -gt 0) {
    $verdictColor  = [System.ConsoleColor]::Yellow
    $verdictLabel  = "MANUAL REVIEW RECOMMENDED"
    $verdictReason = "Suspicious indicators found. Decompile flagged mod(s) before deciding."
} else {
    $verdictColor  = [System.ConsoleColor]::Cyan
    $verdictLabel  = "NO BAN — CLEAN"
    $verdictReason = "No cheat signatures detected. Player appears to be clean."
}

Write-Border 'top' $verdictColor
Write-RowFull "  VERDICT" $verdictColor $verdictColor
Write-Border 'sep' $verdictColor
Write-RowFull "  $verdictLabel" $verdictColor $verdictColor
Write-RowFull "  $verdictReason" White $verdictColor

if ($criticalThreats.Count -gt 0) {
    Write-Border 'sep' $verdictColor
    Write-RowFull "  Cheats confirmed:" DarkGray $verdictColor
    foreach ($mod in $criticalThreats) {
        Write-Row "    · " $mod.Name DarkGray Red $verdictColor
    }
}
if ($suspiciousFiles.Count -gt 0) {
    Write-Border 'sep' $verdictColor
    Write-RowFull "  Suspicious mods:" DarkGray $verdictColor
    foreach ($mod in $suspiciousFiles) {
        Write-Row "    · " $mod.Name DarkGray Yellow $verdictColor
    }
}

Write-Border 'bot' $verdictColor

# ═══════════════════════════════════════════════════════════
#  FOOTER
# ═══════════════════════════════════════════════════════════
Write-Host ""
Write-Host ("  " + "─" * $W) -ForegroundColor DarkGray
Write-Host "  Scan complete. Thank you for using NicModAnalyzer!" -ForegroundColor Magenta
Write-Host ("  " + "─" * $W) -ForegroundColor DarkGray
Write-Host "  Special thanks to Tonynoh   ·   Credits to MeowModAnalyzer" -ForegroundColor DarkMagenta
Write-Host ("  " + "─" * $W) -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
