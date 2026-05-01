[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try { [Console]::SetBufferSize(150, 9999) } catch {}
try { [Console]::SetWindowSize(150, 30) } catch {}
try {
    $r = $Host.UI.RawUI; $b = $r.BufferSize; $b.Width = 150; $b.Height = 9999
    $r.BufferSize = $b; $w = $r.WindowSize; $w.Width = 150; $w.Height = 30; $r.WindowSize = $w
} catch {}
Clear-Host

Write-Host ""
Write-Host "   ┌──────────────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
Write-Host "   │                                                                                      │" -ForegroundColor DarkGray
Write-Host "   │" -ForegroundColor DarkGray -NoNewline; Write-Host "      NicModAnalyzer " -ForegroundColor Magenta -NoNewline
Write-Host "│ " -ForegroundColor DarkGray -NoNewline; Write-Host "v1.1" -ForegroundColor DarkGray -NoNewline
Write-Host "                                               │" -ForegroundColor DarkGray
Write-Host "   │" -ForegroundColor DarkGray -NoNewline; Write-Host "      Minecraft Mod Security Scanner " -ForegroundColor DarkMagenta -NoNewline
Write-Host "│" -ForegroundColor DarkGray
Write-Host "   │                                                                                      │" -ForegroundColor DarkGray
Write-Host "   └──────────────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
Write-Host ""
Write-Host "       " -NoNewline; Write-Host "[ — FULL SCAN ]" -ForegroundColor Magenta
Write-Host "   ─────────────────────────────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  For any errors, contact me on Discord" -ForegroundColor DarkMagenta
Write-Host ""

Write-Host "  Path " -ForegroundColor DarkGray -NoNewline; Write-Host "(leave blank for default)" -ForegroundColor DarkMagenta
Write-Host "  > " -ForegroundColor Magenta -NoNewline; $modsPath = Read-Host
if ([string]::IsNullOrWhiteSpace($modsPath)) {
    $modsPath = "$env:USERPROFILE\AppData\Roaming\.minecraft\mods"
    Write-Host "Continuing with " -NoNewline; Write-Host $modsPath -ForegroundColor White; Write-Host
}
if (-not (Test-Path $modsPath -PathType Container)) {
    Write-Host "❌ Invalid Path!" -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1
}

$activeModules = @("JVM Scan", "String Analysis", "Deep Scan", "Obfuscation", "Disallowed Mods", "Prefetch", "System", "Services", "PC Scan")
Write-Host ""; Write-Host "  Modules  : " -ForegroundColor DarkGray -NoNewline
Write-Host ($activeModules -join "  ·  ") -ForegroundColor Magenta
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ═════════════════════════════════════════════════════════
#  DATA LISTS
# ═════════════════════════════════════════════════════════
$suspiciousPatterns = @(
    'AimAssist','AutoAnchor','AutoCrystal','AutoDoubleHand','AutoHitCrystal','AutoPot','AutoTotem','AutoArmor','InventoryTotem',
    'JumpReset','LegitTotem','PingSpoof','SelfDestruct','ShieldBreaker','TriggerBot','AxeSpam','WebMacro',
    'WalskyOptimizer','WalksyOptimizer','walsky.optimizer','WalksyCrystalOptimizerMod','Donut','Replace Mod',
    'ShieldDisabler','SilentAim','Totem Hit','Wtap','FakeLag','BlockESP','dev.krypton','Virgin','AntiMissClick',
    'LagReach','PopSwitch','SprintReset','ChestSteal','AntiBot','AirAnchor','FakeInv','HoverTotem','AutoClicker',
    'PackSpoof','Antiknockback','catlean','Argon','AuthBypass','Asteria','Prestige','MaceSwap','DoubleAnchor',
    'AutoTPA','BaseFinder','Xenon','gypsy','imgui','imgui.gl3','imgui.glfw','BowAim','Criticals','Fakenick',
    'FakeItem','invsee','ItemExploit','Hellion','hellion','LicenseCheckMixin','ClientPlayerEntityMixim',
    'dev.gambleclient','obfuscatedAuth','phantom-refmap.json','xyz.greaj',
    "じ.class","ふ.class","ぶ.class","ぷ.class","た.class","ね.class","そ.class","な.class","ど.class","ぐ.class",
    "ず.class","で.class","つ.class","べ.class","せ.class","と.class","み.class","び.class","す.class","の.class",
    'org.chainlibs.module.impl.modules.Crystal.Y','org.chainlibs.module.impl.modules.Crystal.bF',
    'org.chainlibs.module.impl.modules.Crystal.bM','org.chainlibs.module.impl.modules.Crystal.bY',
    "org.chainlibs.module.impl.modules.Crystal.bq",'org.chainlibs.module.impl.modules.Crystal.cv',
    'org.chainlibs.module.impl.modules.Crystal.o','org.chainlibs.module.impl.modules.Blatant.I',
    'org.chainlibs.module.impl.modules.Blatant.bR','org.chainlibs.module.impl.modules.Blatant.bx',
    'org.chainlibs.module.impl.modules.Blatant.cj','org.chainlibs.module.impl.modules.Blatant.dk'
)

$script:cheatStrings = @(
    "AutoCrystal","autocrystal","auto crystal","cw crystal","dontPlaceCrystal","dontBreakCrystal",
    "AutoHitCrystal","autohitcrystal","canPlaceCrystalServer","healPotSlot",
    "AutoAnchor","autoanchor","auto anchor","DoubleAnchor","hasGlowstone","HasAnchor",
    "anchortweaks","anchor macro","safe anchor","safeanchor","SafeAnchor","AirAnchor","anchorMacro",
    "AutoTotem","autototem","auto totem","InventoryTotem","inventorytotem","HoverTotem","hover totem","legittotem",
    "AutoPot","autopot","auto pot","speedPotSlot","strengthPotSlot","AutoArmor","autoarmor","auto armor","AutoPotRefill",
    "preventSwordBlockBreaking","preventSwordBlockAttack","ShieldDisabler","ShieldBreaker","Breaking shield with axe...",
    "AutoDoubleHand","autodoublehand","auto double hand","Failed to switch to mace after axe!",
    "AutoMace","MaceSwap","SpearSwap","StunSlam","JumpReset","axespam","axe spam",
    "EndCrystalItemMixin","findKnockbackSword","attackRegisteredThisClick",
    "AimAssist","aimassist","aim assist","triggerbot","trigger bot","Silent Rotations","SilentRotations",
    "FakeInv","swapBackToOriginalSlot","FakeLag","fakePunch","Fake Punch",
    "webmacro","web macro","AntiWeb","AutoWeb","lvstrng","dqrkis",
    "WalksyCrystalOptimizerMod","WalksyOptimizer","WalskyOptimizer","autoCrystalPlaceClock",
    "AutoFirework","ElytraSwap","FastXP","FastExp","NoJumpDelay",
    "PackSpoof","Antiknockback","catlean","AuthBypass","obfuscatedAuth","LicenseCheckMixin",
    "BaseFinder","ItemExploit","FreezePlayer","LWFH Crystal","KeyPearl","LootYeeter","FastPlace","AutoBreach",
    "setBlockBreakingCooldown","getBlockBreakingCooldown","blockBreakingCooldown",
    "onBlockBreaking","setItemUseCooldown","setSelectedSlot","invokeDoAttack","invokeDoItemUse","invokeOnMouseButton",
    "onPushOutOfBlocks","onIsGlowing","Automatically switches to sword when hitting with totem",
    "arrayOfString","POT_CHEATS","Dqrkis Client","Entity.isGlowing","Activate Key","Click Simulation","On RMB",
    "No Count Glitch","No Bounce","NoBounce","Place Delay","Break Delay","Fast Mode","Place Chance",
    "Break Chance","Stop On Kill","damagetick","Anti Weakness","Particle Chance","Trigger Key",
    "Switch Delay","Totem Slot","Smooth Rotations","Use Easing","Easing Strength","While Use",
    "Glowstone Delay","Glowstone Chance","Explode Delay","Explode Chance","Explode Slot","Only Charge",
    "Anchor Macro","Reach Distance","Min Height","Min Fall Speed","Attack Delay","Breach Delay",
    "Require Elytra","Auto Switch Back","Check Line of Sight","Only When Falling","Require Crit",
    "Show Status Display","Stop On Crystal","Check Shield","On Pop","Check Players","Predict Crystals",
    "Check Aim","Check Items","Activates Above","Blatant","Force Totem","Stay Open For",
    "Auto Inventory Totem","Only On Pop","Vertical Speed","Hover Totem","Swap Speed","Strict One-Tick",
    "Mace Priority","Min Totems","Min Pearls","Totem First","Drop Interval","Random Pattern","Loot Yeeter",
    "Horizontal Aim Speed","Vertical Aim Speed","Include Head","Web Delay","Holding Web",
    "Not When Affects Player","Hit Delay","Require Hold Axe","placeInterval","breakInterval","stopOnKill",
    "activateOnRightClick","holdCrystal","Macro Key",
    "KillAura","ClickAura","MultiAura","ForceField","LegitAura","AimBot","AutoAim","SilentAim","AimLock","HeadSnap",
    "CrystalAura","AnchorAura","AnchorFill","AnchorPlace","BedAura","AutoBed","BedBomb","BedPlace",
    "BowAimbot","BowSpam","AutoBow","AutoCrit","CritBypass","AlwaysCrit","CriticalHit",
    "ReachHack","ExtendReach","LongReach","HitboxExpand","AntiKB","NoKnockback","GrimVelocity","GrimDisabler",
    "VelocitySpoof","KBReduce","OffhandTotem","TotemSwitch","AutoWeapon","AutoSword","AutoCity","Burrow","SelfTrap",
    "HoleFiller","AntiSurround","AntiBurrow","WTap","TargetStrafe","AutoGap","AutoPearl",
    "FlyHack","CreativeFlight","BoatFly","PacketFly","AirJump","SpeedHack","BHop","BunnyHop",
    "AntiFall","NoFallDamage","StepHack","FastClimb","AutoStep","HighStep","WaterWalk","LiquidWalk","LavaWalk",
    "NoSlow","NoSlowdown","NoWeb","NoSoulSand","WallHack","ElytraSpeed","InstantElytra",
    "ScaffoldWalk","FastBridge","AutoBridge","Nuker","NukerLegit","InstantBreak","GhostHand","NoSwing",
    "PlaceAssist","AirPlace","AutoPlace","InstantPlace","PlayerESP","MobESP","ItemESP","StorageESP","ChestESP",
    "Tracers","NameTagsHack","XRayHack","OreFinder","CaveFinder","OreESP","NewChunks","TunnelFinder",
    "TargetHUD","ReachDisplay","DoubleClicker","JitterClick","ButterflyClick","CPSBoost",
    "ChestStealer","InvManager","InvMovebypass","AutoSprint","AntiAFK","FakeLatency","FakePing",
    "SpoofRotation","PositionSpoof","GameSpeed","SpeedTimer",
    "GrimBypass","VulcanBypass","MatrixBypass","AACBypass","VerusDisabler","IntaveBypass","WatchdogBypass",
    "PacketMine","PacketWalk","PacketSneak","PacketCancel","PacketDupe","PacketSpam",
    "SelfDestruct","HideClient","SessionStealer","TokenLogger","TokenGrabber","DiscordToken",
    "ReverseShell","C2Server","KeyLogger","StashFinder","TrailFinder",
    "imgui.binding","imgui.gl3","imgui.glfw","JNativeHook","GlobalScreen","NativeKeyListener",
    "client-refmap.json","cheat-refmap.json","phantom-refmap.json",
    "aHR0cDovL2FwaS5ub3ZhY2xpZW50LmxvbC93ZWJob29rLnR4dA==",
    "meteordevelopment","cc/novoline","com/alan/clients","club/maxstats","wtf/moonlight",
    "me/zeroeightsix/kami","net/ccbluex","today/opai","net/minecraft/injection",
    "org/chainlibs/module/impl/modules","xyz/greaj","com/cheatbreaker",
    "doomsdayclient","DoomsdayClient","doomsday.jar","novaclient","api.novaclient.lol",
    "WalksyOptimizer","vape.gg","vapeclient","VapeClient","VapeLite","intent.store","IntentClient",
    "rise.today","riseclient.com","meteor-client","meteorclient","meteordevelopment.meteorclient",
    "liquidbounce","fdp-client","net.ccbluex","novoware","novoclient","aristois","impactclient","azura",
    "pandaware","moonClient","astolfo","futureClient","konas","rusherhack","inertia","exhibition",
    "sessionstealer","tokengrabber","webhookstealer","cookiethief","discordstealer","keylogger",
    "iplogger","cryptominer","reverseShell","backdoormod","exploitmod","ratmod","ransomware",
    "sendWebhook","exfiltrate","connectBack","callHome","grabToken","stealSession","accountstealer",
    "discord/token","grabber/cookie","grab_cookies","stealerutils","sendToWebhook","postDiscord",
    "webhookurl","discordwebhook","Runtime.exec","cmd.exe","powershell.exe",
    "crasher","lagmachine","booksploit","signcrasher","entityspammer","nukermod","worldnuker",
    "tntmod","bedexplode","anchorexplode","injectClass","modifyBytecode","hookMethod",
    "attachAgent","VirtualMachine.attach","FLOW_OBFUSCATION","STRING_ENCRYPTION","RESOURCE_ENCRYPTION",
    "skidfuscator","me/itzsomebody","radon/transform","bozar/","paramorphism","zelix/klassmaster",
    "allatori","dasho","com/icqm/smoke","dev.krypton","dev.gambleclient","com.cheatbreaker",
    "fakeVersion","spoofVersion","brandOverride","overrideBrand","fakeClientBrand","brandSpoof","versionSpoof",
    "net.minecraft.client.ClientBrandRetriever","ServerboundCustomPayloadPacket","MC|Brand","minecraft:brand",
    "cancelPacket","dropPacket","suppressPacket","blockPacket","spoofPacket","injectPacket",
    "sendFakePacket","sendSilentPacket","bypassAC","bypass_ac","evadeAC","evadeAnticheat",
    "isGrimAC","isNoCheat","isAAC","isSpartanAC","isIntave","grimBypass","ncpBypass","aacBypass",
    "spartanBypass","checkAnticheat","detectAnticheat","getAnticheat","GrimBypass","NCPBypass",
    "AACBypass","IntaveBypass","setTimerSpeed","timerSpeed","Timer.timerSpeed","setTickRate",
    "overrideTickRate","fakeTickCount","tickBoost","hitboxExpand","expandHitbox",
    "suppressKnockback","cancelKnockback","noKnockback","setVelocity(0","zeroVelocity","ignoreKnockback",
    "antiKnockback","KnockbackModifier","noVelocity","renderPlayerSpoofed","spoofRender","hideFromRender",
    "fakeGlowing","GlowBypass","glowBypass","baritone.bypass","pathfindBypass","suppressPathfind",
    "bypassLicense","fakeAuth","spoofSession","AltManager","grimac","GrimAC","grim-api","ac.grim",
    "game.grim","setGrimFlag","rotationBypass","fakeYaw","fakePitch","spoofYaw","spoofPitch",
    "ＡｕﾄＣﾞｲｽﾀ｡ﾞ","Ａｕﾄ Ｃﾞｲｽﾀ｡ﾞ","ＡｕﾄＨｲﾄＣﾞｲｽﾀ｡ﾞ","ＡｕﾄＡｮｃﾞｮﾞ","Ａｕﾄ Ａｮｃﾞｮﾞ",
    "＄ｏｕｂﾞﾞｅＡｮｃﾞｮﾞ","＄ｏｕｂﾞﾞｅ Ａｮｃﾞｮﾞ","ＳａﾇｪＡＡｮｃﾞｮﾞ","Ｓａｆｅ Ａｮｃﾞｮﾞ",
    "Ａｮｃﾞｮﾞ Ｍ｡ｃﾞｮﾞ","anchorMacro","ＡｕﾄＴｵﾃｪｭ","Ａｕﾄ Ｔｵﾃｪｭ","Ｈｵｶﾞﾘ Ｔｵﾃｪｭ",
    "ＩｎｶﾝﾄﾝｮﾞｙＴｵﾃｪｭ","ＡｕﾄＰｵﾄ","Ａｕﾄ Ｐｵﾄ","Ａｕﾄ Ｐｵﾄ ２ｪﾌｲﾞ","ＡｕﾄＡｾﾞ",
    "Ｓﾞｲｪﾞﾞ＄ｲｻ｡ｂﾞ","Ｓﾞｲｪﾞﾞ ＄ｲｻ｡ｂﾞ","Ａｕﾄ＄ｵｳｂﾞﾞＨ｡ﾝﾄ","Ａｕﾄ ＄ｵｳｂﾞﾞ Ｈ｡ﾝﾄ",
    "ＡｕﾄＣｲｯｪｹｹーｯ","ＡｕﾄＭ｡ｃｪ","Ｍ｡ｃｪＳｗ｡ﾇ","Ｓﾟｪｱｒ Ｓｗ｡ﾇ","Ｓﾄｰﾝ Ｓﾞ｡ｭ",
    "ＡｲｵＡｽｽﾞ","Ａｲｳ Ａｽｽﾞ","ＴﾞｲｶﾞﾞﾞＢｵﾄ","Ｓｲﾞｭﾝﾄ ﾝｵﾀｴｵ｝","Ｆ｡ｹＬ｡ｶﾞ","Ｆ｡ｋｪ Ｐｵﾝｳﾞﾞ",
    "Ａﾝﾄｲ Ｗｪｂ","ＡｵﾄＷｪｂ","Ｗ｡ﾞｷｽｹ Ｏﾟﾄｵﾞ","ＬＷＦＨ Ｃﾞｲｽﾌ｡ﾞ","Ｌｵｵｵ Ｙｪｪﾄﾞﾞ",
    "Ａｵﾄ Ｂﾚｾ｡ｃﾞ","Ｆｲｵｪｪﾞｽﾞ Ｐﾞｱｴﾞｪｲ"
)

$script:knownCheatFileTokens = @(
    "doomsday","doomsdayclient","doomsday-client","doomsday_client","darik","dariks","dqrkis","dqrk",
    "vape","vapeclient","vape-client","vape_client","vapelite","vape-lite","vapepro",
    "meteor","meteorclient","meteor-client","meteor_client","meteordev","meteor-dev",
    "liquidbounce","liquid-bounce","liquid_bounce","liquidb","liquidbounceclient",
    "wurst","wurst-client","wurst_client","wurstclient","wurst7","sigma","sigmaclient","sigma-client",
    "sigmahack","sigmamod","rise","riseclient","rise-client","risehack","future","futureclient",
    "future-client","futurehack","konas","konasclient","konas-client","konashack","inertia",
    "inertiaclient","inertia-client","inertiahack","exhibition","exhibitionclient","exhibitionhack",
    "pandaware","panda-ware","panda_ware","pandaclient","astolfo","astolfoclient","astolfo-client",
    "astolfohack","rusherhack","rusher-hack","rusher_hack","rushermod","novaclient","nova-client",
    "nova_client","novaware","novahack","impact","impactclient","impact-client","impacthack","aristois",
    "aristois-client","aristoisclient","azura","azuraclient","azura-client","azurahack","moonlight",
    "moonlightclient","moon-client","moonhack","intent","intentclient","intent-client","intentstore",
    "intenthack","prestige","prestigeclient","prestige-client","prestigehack","cheatbreaker",
    "cheat-breaker","cheatbreakerclient","kami","kamiclient","kami-client","kamiblue","kami-blue",
    "fdp","fdpclient","fdp-client","fdphack","xray","xrayclient","xray-mod","xrayhack","xraymod",
    "baritone","baritoneclient","baritonehack","skidfuscator","skid-client","skidclient","skidware",
    "noob","nooby","cheat","hack","hacked","hacker","hackme","inject","injector","loader","payload",
    "bypass","cracked","crack","stealer","grabber","logger","keylog","token","exploit","malware","rat",
    "sabotage","sabotageclient","omega","omegaclient","omega-client","flex","flexclient","flex-client",
    "flexhack","swift","swiftclient","swift-client","swifthack","vertex","vertexclient","vertex-client",
    "vertexhack","vapor","vaporclient","vapor-client","vaporhack","blaze","blazeclient","blaze-client",
    "blazehack","noble","nobleclient","noble-client","noblehack","royal","royalclient","royal-client",
    "royalhack","spirit","spiritclient","spirit-client","spirithack","phantom","phantomclient",
    "phantom-client","phantomhack","ghost","ghostclient","ghost-client","ghosthack","ghostware",
    "shadow","shadowclient","shadow-client","shadowhack","crystal","crystalclient","crystal-client",
    "crystalware","drip","dripclient","drip-client","driphack","dripware","tenacity","tenacityclient",
    "tenacity-client","thunder","thunderclient","thunder-client","thunderhack","storm","stormclient",
    "storm-client","stormhack","abyss","abyssclient","abyss-client","abysshack","raven","ravenclient",
    "raven-client","ravenhack","ravenb","themis","themisclient","themishack","saber","saberclient",
    "saber-client","saberhack","blade","bladeclient","blade-client","bladehack","toxic","toxicclient",
    "toxic-client","toxichack","breach","breachclient","breach-client","breachhack","clarity",
    "clarityclient","clarity-client","motion","motionclient","motion-client","motionhack","flux",
    "fluxclient","flux-client","fluxhack","fluxbe","strafe","strafeclient","strafe-client","strafehack",
    "aura","auraclient","aura-client","aurahack","nemesis","nemesisclient","nemesis-client",
    "nemesishack","nexus","nexusclient","nexus-client","nexushack","crypt","cryptclient","crypt-client",
    "crypthack","cryptware","nodus","nodusclient","nodus-client","nodushack","hyperium","hyperiumclient",
    "hyperiumhack","salwyrr","salwyrrclient","salwyrrhack","bleach","bleachclient","bleachhack",
    "bleach-hack","erosion","erosionclient","erosionhack","entropy","entropyclient","entropyhack",
    "entropy-client","ares","aresclient","ares-client","areshack","areswarez","wolfram","wolframclient",
    "wolfram-client","wolframhack","pyro","pyroclient","pyro-client","pyrohack","kira","kiraclient",
    "kira-client","kirahack","solace","solaceclient","solace-client","solacehack","serenity",
    "serenityclient","serenityhack","polaris","polarisclient","polaris-client","lucid","lucidclient",
    "lucid-client","lucidhack","comet","cometclient","comet-client","comethack","aurora","auroraclient",
    "aurora-client","aurorahack","twilight","twilightclient","twilight-hack","quantum","quantumclient",
    "quantum-client","quantumhack","pulsar","pulsarclient","pulsar-client","pulsarhack","radium",
    "radiumclient","radium-client","radiumhack","prism","prismclient","prism-client","prismhack","zenith",
    "zenithclient","zenith-client","zenithhack","apex","apexclient","apex-client","apexhack","orion",
    "orionclient","orion-client","orionhack","inferno","infernoclient","inferno-client","infernohack",
    "eclipse","eclipseclient","eclipse-client","eclipsehack","rage","rageclient","rage-client",
    "ragehack","ragebot","autoclicker","auto-clicker","auto_clicker","clickbot","clicker","killaura",
    "kill-aura","kill_aura","aurabot","aimbot","aim-bot","aim_bot","aimassist","triggerbot","esp",
    "wallhack","wall-hack","nofallhack","bhop","bunny-hop","speedhack","speed-hack","flyhack","fly-hack",
    "scaffold","scaffoldhack","scaffold-hack","dllinjector","dll-injector","dll_injector","injectorpro",
    "bypassed","bypassclient","bypass-client","bypasshack","nulled","nulledclient","nulled-client",
    "nulledhack","leaked","leakedclient","leaked-client","leakedhack","skid","skidclient","skid-client",
    "skidhack"
)

$deepCheatStrings = @(
    "invokeAttackEntity","invokeUseItem","invokeStopUsingItem","callAttackEntity","callUseItem",
    "getAttackCooldownProgress","resetLastAttackedTicks","ModuleManager","FeatureManager","HackList",
    "CommandManager.register","GuiHacks","ClickGui","AltManager","SessionStealer","spoofPacket",
    "cancelPacket","dropPacket","CPacketHeldItemChange","ServerboundMovePlayerPacket","Timer.timerSpeed",
    "timerSpeed","setTimerSpeed","Runtime.getRuntime().exec(","com.sun.jndi.rmi.object.trustURLCodebase=true",
    "com.sun.jndi.ldap.object.trustURLCodebase=true","-Xrunjdwp:","agentlib:jdwp",
    "dev.gambleclient","xyz.greaj","org.chainlibs","dev.krypton","Dqrkis","dqrkis","lvstrng",
    "getDeclaredMethod(","setAccessible(true)","unsafe.allocateInstance","Unsafe.getUnsafe",
    "setHardTarget","mixinBypass","HttpClient","HttpURLConnection","openConnection","URLConnection",
    "getOutputStream","getInputStream",".execute(","ProcessBuilder","Runtime.exec"
)

$disallowedMods = @{
    "auto-clicker"                   = @{ Names = @("Auto Clicker","AutoClicker","autoclicker","auto-clicker","Auto-Clicker") }
    "freecam"                        = @{ Names = @("Freecam","freecam","FreeCam","Free Cam") }
    "vivecraft"                      = @{ Names = @("Vivecraft","vivecraft","ViveCraft") }
    "geyser"                         = @{ Names = @("Geyser","geyser","GeyserMC","geysermc","GeyserFabric","GeyserForge") }
    "tweakeroo"                      = @{ Names = @("Tweakeroo","tweakeroo") }
    "shoulder-surfing-reloaded"      = @{ Names = @("Shoulder Surfing","ShoulderSurfing","Shoulder Surfing Reloaded") }
    "flours-various-tweaks"          = @{ Names = @("Flour's Various Tweaks","FloursTweaks","flours-tweaks") }
    "inventory-profiles-next"        = @{ Names = @("Inventory Profiles Next","InventoryProfilesNext") }
    "inventory-control-tweaks"       = @{ Names = @("Inventory Control Tweaks","InventoryControlTweaks") }
    "better-third-person"            = @{ Names = @("Better Third Person","BetterThirdPerson") }
    "camera-utils"                   = @{ Names = @("Camera Utils","CameraUtils") }
    "mouse-wheelie"                  = @{ Names = @("Mouse Wheelie","MouseWheelie") }
    "clickcrystals"                  = @{ Names = @("ClickCrystals","clickcrystals") }
    "itemscroller"                   = @{ Names = @("Item Scroller","ItemScroller") }
    "double-hotbar"                  = @{ Names = @("Double Hotbar","DoubleHotbar") }
    "invmove"                        = @{ Names = @("InvMove","invmove") }
    "arrow-shifter"                  = @{ Names = @("Arrow Shifter","ArrowShifter") }
    "clientcommands"                 = @{ Names = @("clientcommands","ClientCommands") }
    "walksycrystaloptimizer"         = @{ Names = @("WalksyCrystalOptimizer") }
    "fluidlogged"                    = @{ Names = @("Fluidlogged","fluidlogged") }
    "quick-elytra"                   = @{ Names = @("Quick Elytra","QuickElytra") }
    "quick-hotkeys"                  = @{ Names = @("Quick Hotkeys","QuickHotkeys") }
    "sort"                           = @{ Names = @("Sort","sort","SortMod") }
    "bridging-mod"                   = @{ Names = @("Bridging Mod","BridgingMod","SlothPixel") }
    "toggle-sneak-sprint"            = @{ Names = @("Toggle Sneak","Toggle Sprint","ToggleSneak","ToggleSprint") }
    "slot-cycler"                    = @{ Names = @("Slot Cycler","SlotCycler") }
    "frostbyte-improved-inventory"   = @{ Names = @("Frostbyte's Improved Inventory","FrostbyteInventory") }
    "inventory-management"           = @{ Names = @("Inventory Management","InventoryManagement") }
    "omniscience"                    = @{ Names = @("Omniscience","omniscience") }
    "switchtotems"                   = @{ Names = @("SwitchTotems","switchtotems") }
    "bedrockify"                     = @{ Names = @("Bedrockify","bedrockify") }
    "d-hand"                         = @{ Names = @("D-hand","Dhand","D Hand") }
    "fast-xp"                        = @{ Names = @("Fast Xp","FastXP","FastXp") }
    "quick-exp"                      = @{ Names = @("Quick Exp","QuickExp") }
    "viafabric"                      = @{ Names = @("ViaFabric","viafabric","ViaFabricPlus","viafabricplus","ViaFabric+") }
    "viaforge"                       = @{ Names = @("ViaForge","viaforge") }
    "dokkos-hotbar-optimizer"        = @{ Names = @("Dokko's Hotbar Optimizer","DokkoHotbar") }
    "no-delay-optimizer"             = @{ Names = @("No Delay Optimizer","NoDelayOptimizer","NoDelay") }
    "hazel-crystal-optimizer"        = @{ Names = @("Hazel Crystal Optimizer","HazelCrystalOptimizer") }
    "no-input-lag-tick-rate"         = @{ Names = @("No Input Lag","NoInputLag","TickRateOptimizer") }
    "multi-key-bindings"             = @{ Names = @("Multi Key Bindings","MultiKeyBindings") }
}

$script:processWhitelist = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@("System","Idle","smss","csrss","wininit","winlogon","services","lsass","svchost","dwm","explorer","taskmgr",
"taskhostw","sihost","ctfmon","RuntimeBroker","ShellExperienceHost","StartMenuExperienceHost","SearchApp",
"SearchIndexer","SearchHost","SearchUI","ApplicationFrameHost","SystemSettingsBroker","SettingsSyncHost",
"WmiPrvSE","WmiApSrv","spoolsv","msdtc","TrustedInstaller","TiWorker","wuauclt","wuaueng","MpCmdRun",
"MsMpEng","NisSrv","SecurityHealthService","SecurityHealthHost","smartscreen","fontdrvhost","conhost",
"conhostv2","dllhost","rundll32","regsvr32","msiexec","userinit","LogonUI","consent","credentialuibroker",
"backgroundTaskHost","audiodg","WUDFHost","WUDFRd","LockApp","PeopleExperienceHost","YourPhone",
"MicrosoftEdge","msedge","chrome","firefox","opera","brave","vivaldi","iexplore","Discord","DiscordPTB",
"DiscordCanary","Spotify","EpicGamesLauncher","EpicWebHelper","Steam","steamwebhelper","steamservice",
"GameOverlayUI","Origin","EADesktop","Minecraft","javaw","java","MinecraftLauncher","MultiMCLauncher",
"prismlauncher","polymc","atlauncher","ftblauncher","curseforge","overwolf","code","idea64","eclipse",
"devenv","dotnet","node","git","powershell","pwsh","cmd","WindowsTerminal","wt","python","python3",
"OneDrive","Teams","Slack","zoom","obs64","7zFM","WinRAR","notepad","notepad++","mspaint","SnippingTool",
"VirtualBox","VBoxSVC","vmware","vmplayer","Razer","RazerCentralService","SteelSeriesEngine","LGHub",
"CORSAIR","iCUE","Logitech","LGHUB","NVDisplay.Container","nvcontainer","AMDRSServ","RadeonSoftware",
"MSIAfterburner","RTSS","Malwarebytes","mbam","avast","avg","bdagent","mcshield","McAfee","eset","egui",
"Dropbox","GoogleUpdate","skype","iTunes","AdobeARMservice","winword","excel","powerpnt","outlook",
"OfficeClickToRun","procexp","procexp64","procmon","Wireshark","EasyAntiCheat","BattlEye","VALORANT",
"LeagueClient","dota2","csgo","cs2","RocketLeague","docker","wslhost","AnyDesk","TeamViewer","Hamachi",
"SystemInformer","CCleaner","Nahimic","Rainmeter","parsec","SignalRgb","OpenRGB","ClaudeDesktop",
"PhoneExperienceHost","UserOOBEBroker","GameInputSvc","sppsvc","SgrmBroker","MoUsoCoreWorker","UsoClient",
"WerFault","WerFaultSecure","TabTip","vmcompute","vmms","jhi_service","LMS","igfxCUIService",
"CrystalDiskInfo","Greenshot","ShareX","NZXT CAM","GameBar","GameBarFTServer","XboxGameBarSpotify"
) | ForEach-Object { [void]$script:processWhitelist.Add($_) }

$script:cheatProcessNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
@("liquidbounce","meteor-client","wurst","vape","vapelite","sigmaclient","sigma","rise","baritone",
"aristois","huzuni","inertia","impact","salhack","killaura","aimbot","xray","freecam","ghostclient",
"nofall","nofalldmg","antibot","autoclicker","jitterclick","butterfly","triggerbot","scaffold","cheat-engine",
"cheatengine","x64dbg","x32dbg","ollydbg","idaq","dnspy","ilspy","jadx","injector","dllinjector",
"extreme-injector","winservicehost","svchost32","svchost64","javaupdater","msupdater","windowsupdater",
"discord-stealer","tokenstealer","grabber","cookiegrabber","rat","asyncrat","quasarrat","dcrat","nanocore",
"njrat","remcos","xworm","cryptominer","miner","xmrig","nbminer","phoenixminer","prestige","prestigeclient",
"flux","remix","pandora","hypnotic","reflex","phantom","ares","atomclient","zephyr","xeclient","vertex",
"rusher","rusherhack","novoline","azuraclient","fdp","fdpclient","pyroclient","drip","entropy","nightx",
"blaze","autocrystal","crystalaura","anchorbot","anchormacro","macroclient","autoanchor"
) | ForEach-Object { [void]$script:cheatProcessNames.Add($_) }

$script:suspiciousProcessPatterns = @(
    '^[a-z]{1,4}\d{3,}$', '^[a-zA-Z0-9]{32}$', '^[a-zA-Z0-9]{16,}$',
    '^tmp[a-zA-Z0-9]+$', '^svc[a-zA-Z0-9]{4,}$', '^win[a-zA-Z0-9]{5,}$',
    '^sys[a-zA-Z0-9]{5,}$', '^upd[a-zA-Z0-9]{4,}$', '^[a-z]{2}\d{4,}$'
)

$script:suspiciousStartupPatterns = @(
    'AppData\\Roaming\\[^\\]+\.exe', 'AppData\\Local\\Temp\\',
    'AppData\\Local\\(?!Discord|Spotify|Programs|Microsoft|Packages|GitHubDesktop|Slack|Notion|Steam|Epic|cursor|Claude)[^\\]+\\[^\\]+\.exe',
    '\\Temp\\.*\.exe', '\\Temp\\.*\.bat', '\\Temp\\.*\.ps1',
    'powershell.*-enc', 'powershell.*hidden', 'cmd.*\/c.*start',
    'wscript.*\.vbs', 'mshta.*\.hta', 'regsvr32.*/s.*/u', 'rundll32.*javascript'
)

$script:knownCheatFolders = @(
    "$env:APPDATA\LiquidBounce","$env:APPDATA\Meteor Client","$env:APPDATA\Wurst","$env:APPDATA\Vape",
    "$env:APPDATA\.vape","$env:APPDATA\Sigma","$env:APPDATA\Rise","$env:APPDATA\Aristois","$env:APPDATA\Huzuni",
    "$env:APPDATA\Inertia","$env:APPDATA\Impact","$env:APPDATA\SalHack","$env:APPDATA\Baritone",
    "$env:APPDATA\GhostClient","$env:APPDATA\AsyncRAT","$env:APPDATA\QuasarRAT","$env:APPDATA\DCRat",
    "$env:APPDATA\xmrig","$env:LOCALAPPDATA\LiquidBounce","$env:LOCALAPPDATA\Meteor","$env:LOCALAPPDATA\Wurst",
    "$env:LOCALAPPDATA\Vape","$env:TEMP\liquidbounce","$env:TEMP\meteor","$env:TEMP\vape",
    "$env:APPDATA\PrestigeClient","$env:APPDATA\Prestige","$env:APPDATA\ArgonClient","$env:APPDATA\Argon",
    "$env:APPDATA\NightX","$env:APPDATA\BlazeMod","$env:APPDATA\RusherHack","$env:APPDATA\rusherhack",
    "$env:APPDATA\Novoline","$env:APPDATA\Azura","$env:APPDATA\FDPClient","$env:APPDATA\fdpclient",
    "$env:APPDATA\Future","$env:APPDATA\.future","$env:APPDATA\Raven","$env:APPDATA\Drip","$env:APPDATA\Pyro",
    "$env:APPDATA\Pyro Client","$env:APPDATA\Entropy","$env:LOCALAPPDATA\PrestigeClient",
    "$env:LOCALAPPDATA\Prestige","$env:LOCALAPPDATA\ArgonClient","$env:LOCALAPPDATA\Argon",
    "$env:LOCALAPPDATA\NightX","$env:LOCALAPPDATA\RusherHack","$env:LOCALAPPDATA\Future",
    "$env:APPDATA\.prestigeclient","$env:APPDATA\prestige-client","$env:APPDATA\Killaura","$env:APPDATA\Aimbot",
    "$env:APPDATA\Flux","$env:APPDATA\Remix","$env:APPDATA\Pandora","$env:APPDATA\Hypnotic","$env:APPDATA\Velocity",
    "$env:APPDATA\Reflex","$env:APPDATA\Azura","$env:APPDATA\Phantom","$env:APPDATA\Ares","$env:APPDATA\AtomClient",
    "$env:APPDATA\Zephyr","$env:APPDATA\XeClient","$env:APPDATA\Vertex","$env:LOCALAPPDATA\PrestigeClient\app-data",
    "$env:TEMP\prestige","$env:TEMP\prestigeclient"
)

$patternRegex      = [regex]::new('(?<![A-Za-z])(' + (($suspiciousPatterns | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')(?![A-Za-z])', [System.Text.RegularExpressions.RegexOptions]::Compiled)
$cheatStringSet    = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $script:cheatStrings) { [void]$cheatStringSet.Add($s) }
$deepCheatStringSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($s in $deepCheatStrings) { [void]$deepCheatStringSet.Add($s) }
$fullwidthRegex    = [regex]::new("[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]{2,}", [System.Text.RegularExpressions.RegexOptions]::Compiled)
$tokenRegex        = [regex]::new('(' + (($script:knownCheatFileTokens | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')', [System.Text.RegularExpressions.RegexOptions]::Compiled)

# ═══════════════════════════════════════════════════════
#  MEMORY SCAN P/INVOKE SETUP
# ═══════════════════════════════════════════════════════
try {
    $memSig = @"
[DllImport("kernel32.dll")] public static extern bool ReadProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int dwSize, out int lpNumberOfBytesRead);
[DllImport("kernel32.dll")] public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);
[DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr hObject);
[DllImport("kernel32.dll")] public static extern bool VirtualQueryEx(IntPtr hProcess, IntPtr lpAddress, out MEMORY_BASIC_INFORMATION lpBuffer, uint dwLength);
[StructLayout(LayoutKind.Sequential)] public struct MEMORY_BASIC_INFORMATION {
    public IntPtr BaseAddress; public IntPtr AllocationBase; public uint AllocationProtect;
    public uint RegionSize; public uint State; public uint Protect; public uint Type;
}
"@
    Add-Type -MemberDefinition $memSig -Name MemAPI -Namespace Win32 -ErrorAction SilentlyContinue
} catch {}

# ═══════════════════════════════════════════════════════
#  HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════
function Get-ShannonEntropy { param([byte[]]$Data)
    if ($Data.Length -eq 0) { return 0.0 }
    $freq = @{}; foreach ($b in $Data) { $freq[$b] = ($freq[$b] -as [int]) + 1 }
    $e = 0.0; $len = $Data.Length
    foreach ($c in $freq.Values) { $p = $c / $len; if ($p -gt 0) { $e -= $p * [Math]::Log($p, 2) } }
    return [Math]::Round($e, 4)
}

function Get-Mod-Info-From-Jar { param([string]$jarPath)
    $r = [PSCustomObject]@{ ModId = $null; Name = $null }
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jarPath)
        foreach ($en in @(
            ($zip.Entries | Where-Object { $_.FullName -match 'fabric\.mod\.json$' } | Select-Object -First 1),
            ($zip.Entries | Where-Object { $_.FullName -match 'quilt\.mod\.json$' }  | Select-Object -First 1)
        )) {
            if (-not $en) { continue }
            try {
                $st = $en.Open(); $buf = New-Object System.IO.MemoryStream; $st.CopyTo($buf); $st.Close()
                $j = [System.Text.Encoding]::UTF8.GetString($buf.ToArray()); $buf.Dispose()
                if ($j -match '"id"\s*:\s*"([^"]+)"')   { $r.ModId = $Matches[1] }
                if ($j -match '"name"\s*:\s*"([^"]+)"') { $r.Name  = $Matches[1] }
            } catch {}
        }
        $tomlEntry = $zip.Entries | Where-Object { $_.FullName -match 'META-INF/mods\.toml$' } | Select-Object -First 1
        if ($tomlEntry -and -not $r.ModId) {
            try {
                $st = $tomlEntry.Open(); $buf = New-Object System.IO.MemoryStream; $st.CopyTo($buf); $st.Close()
                $t = [System.Text.Encoding]::UTF8.GetString($buf.ToArray()); $buf.Dispose()
                if ($t -match 'modId\s*=\s*"([^"]+)"')       { $r.ModId = $Matches[1] }
                if ($t -match 'displayName\s*=\s*"([^"]+)"') { $r.Name  = $Matches[1] }
            } catch {}
        }
        $zip.Dispose()
    } catch {}
    return $r
}

function Get-MinecraftStatus {
    $mc = $null
    $jp = @(Get-Process javaw -EA 0) + @(Get-Process java -EA 0)
    foreach ($p in $jp) {
        try {
            $w = Get-WmiObject Win32_Process -Filter "ProcessId=$($p.Id)" -EA Stop
            if ($w.CommandLine -match "net\.minecraft|Minecraft") { $mc = $p; break }
        } catch {}
    }
    if ($mc) {
        $up  = (Get-Date) - $mc.StartTime
        $m   = [math]::Floor($up.TotalMinutes)
        $ram = [math]::Round($mc.WorkingSet64 / 1MB, 0)
        return [PSCustomObject]@{ Running = $true; PID = $mc.Id; Uptime = "$m min"; RAM = "$ram MB" }
    }
    return [PSCustomObject]@{ Running = $false; PID = 0; Uptime = "-"; RAM = "-" }
}

# ═══════════════════════════════════════════════════════
#  ENHANCED OBFUSCATION SCAN
# ═══════════════════════════════════════════════════════
function Invoke-ObfuscationFlags { param([string]$FilePath)
    $flags = [System.Collections.Generic.List[string]]::new()
    $outerModId = $null
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)
        $modInfo    = Get-Mod-Info-From-Jar -jarPath $FilePath
        $outerModId = $modInfo.ModId
        $classes    = @($zip.Entries | Where-Object { $_.FullName -match '\.class$' })
        $totalClassCount = $classes.Count
        if ($totalClassCount -eq 0) { $zip.Dispose(); return $flags }

        $obfuscatedCount = 0; $numericClassCount = 0; $unicodeClassCount = 0
        foreach ($c in $classes) {
            $parts = $c.FullName.Split('/')
            $isObf = ($parts[0..($parts.Count - 2)] | Where-Object { $_.Length -le 1 -and $_ -cmatch '^[a-z]$' }).Count -ge 2
            if ($isObf) { $obfuscatedCount++ }
            $cn = [System.IO.Path]::GetFileNameWithoutExtension($c.Name)
            if ($cn -cmatch '^\d+$')          { $numericClassCount++ }
            if ($cn -match '[^\x00-\x7F]')    { $unicodeClassCount++ }
        }

        $obfPct = if ($totalClassCount -ge 10) { [math]::Round(($obfuscatedCount / $totalClassCount) * 100) } else { 0 }
        $numPct = if ($totalClassCount -ge 5)  { [math]::Round(($numericClassCount / $totalClassCount) * 100) } else { 0 }
        $uniPct = if ($totalClassCount -ge 5)  { [math]::Round(($unicodeClassCount / $totalClassCount) * 100) } else { 0 }

        $runtimeExecFound = $false; $httpDownloadFound = $false; $httpExfilFound = $false
        $sampled = $classes | Select-Object -First ([math]::Min(30, $totalClassCount))
        foreach ($ce in $sampled) {
            try {
                $st = $ce.Open(); $buf = New-Object System.IO.MemoryStream; $st.CopyTo($buf); $st.Close()
                $raw = $buf.ToArray(); $buf.Dispose()
                $a = [System.Text.Encoding]::ASCII.GetString($raw)
                if ($a -match 'Runtime\.exec')              { $runtimeExecFound  = $true }
                if ($a -match 'openConnection|getOutputStream') { $httpDownloadFound = $true }
                if ($a -match 'setRequestMethod.*POST')     { $httpExfilFound    = $true }
            } catch {}
        }

        if ($runtimeExecFound -and $obfPct -ge 25) { $flags.Add("Runtime.exec() in obfuscated code — can run arbitrary OS commands") }
        if ($httpDownloadFound)                     { $flags.Add("HTTP file download — fetches and writes files from a remote server at runtime") }
        if ($httpExfilFound)                        { $flags.Add("HTTP POST exfiltration — sends system data to an external server") }
        if ($totalClassCount -ge 10 -and $obfPct -ge 25) { $flags.Add("Heavy obfuscation — $obfPct% of classes use single-letter path segments") }
        if ($numPct -ge 20) { $flags.Add("Numeric class names — $numPct% of classes have numeric-only names") }
        if ($uniPct -ge 10) { $flags.Add("Unicode class names — $uniPct% of classes use non-ASCII characters") }

        $knownLegitModIds = @("vmp-fabric","vmp","lithium","sodium","iris","fabric-api","modmenu","ferrite-core",
            "lazydfu","starlight","entityculling","memoryleakfix","krypton","c2me-fabric","smoothboot-fabric",
            "immediatelyfast","noisium","threadtweak","indium","rendervis","entity_texture_features",
            "citresewn","sodium-extra","rei","jei","journeymap","xaerominimap","xaeroworldmap","lithium",
            "phosphor","appleskin","modelfix","dynamic-fps","betterthirdperson","fpsreducer")
        $dangerCount = ($flags | Where-Object { $_ -match "Runtime\.exec|HTTP file download|HTTP POST|Heavy obfuscation" }).Count
        if ($outerModId -and ($knownLegitModIds -contains $outerModId) -and $dangerCount -gt 0) {
            $flags.Add("Fake mod identity — claims to be '$outerModId' but contains dangerous code")
        }

        $obfuscatorSigs = @{
            "Allatori"     = "Allatori"
            "Zelix"        = "Zelix"
            "ProGuard"     = "Obfuscated-By: ProGuard"
            "Stringer"     = "Stringer Java Obfuscator"
            "Skidfuscator" = "skidfuscator"
            "Radon"        = "Obfuscated-By: Radon"
            "BisGuard"     = "BisGuard"
            "Paramorphism" = "paramorphism"
        }
        foreach ($entry in ($zip.Entries | Where-Object { $_.FullName -match 'MANIFEST\.MF$|\.json$|\.toml$' })) {
            try {
                $st = $entry.Open(); $buf = New-Object System.IO.MemoryStream; $st.CopyTo($buf); $st.Close()
                $txt = [System.Text.Encoding]::UTF8.GetString($buf.ToArray()); $buf.Dispose()
                foreach ($kv in $obfuscatorSigs.GetEnumerator()) {
                    if ($txt -match [regex]::Escape($kv.Value)) { $flags.Add("Obfuscator marker: $($kv.Key)") }
                }
            } catch {}
        }

        $encMarkers = @("decrypt","deobf","StringEncryption","StringDecryptor","decryptString","stringPool","StringPool")
        $encCount = 0
        foreach ($ce in ($classes | Select-Object -First 20)) {
            try {
                $st = $ce.Open(); $buf = New-Object System.IO.MemoryStream; $st.CopyTo($buf); $st.Close()
                $a = [System.Text.Encoding]::ASCII.GetString($buf.ToArray()); $buf.Dispose()
                foreach ($m in $encMarkers) { if ($a -match $m) { $encCount++; break } }
            } catch {}
        }
        if ($encCount -ge 5) { $flags.Add("String encryption detected in $encCount class(es)") }

        $zip.Dispose()
    } catch {}
    return $flags
}

# ═══════════════════════════════════════════════════════
#  ENHANCED JVM SCAN  (argument injection + memory + agents)
# ═══════════════════════════════════════════════════════
function Test-JvmIntegrity {
    $findings    = [System.Collections.Generic.List[PSObject]]::new()
    $foundFlags  = [System.Collections.Generic.HashSet[string]]::new()
    $javaProcs   = @(Get-Process javaw -EA 0) + @(Get-Process java -EA 0)
    if ($javaProcs.Count -eq 0) { return $findings }

    # ── All JVM argument patterns: [regex, flag-key, severity, description]
    $suspiciousPatternsList = @(
        # Fabric mod injection
        @('-Dfabric\.addMods=',                  'FABRIC_ADD_MODS',              'HIGH',   'Injects extra Fabric mod JARs at runtime'),
        @('-Dfabric\.loadMods=',                 'FABRIC_LOAD_MODS',             'HIGH',   'Overrides Fabric mod loading mechanism'),
        @('-Dfabric\.classPathGroups=',          'FABRIC_CLASSPATH_GROUPS',      'HIGH',   'Manipulates Fabric classpath groups'),
        @('-Dfabric\.gameJarPath=',              'FABRIC_GAME_JAR_PATH',         'MEDIUM', 'Redirects Minecraft game JAR path'),
        @('-Dfabric\.skipMcProvider=',           'FABRIC_SKIP_MC_PROVIDER',      'HIGH',   'Skips Minecraft provider checks'),
        @('-Dfabric\.development=',              'FABRIC_DEV_MODE',              'LOW',    'Enables Fabric development mode'),
        @('-Dfabric\.allowUnsupportedVersion=',  'FABRIC_UNSUPPORTED_VERSION',   'MEDIUM', 'Allows unsupported Minecraft versions'),
        @('-Dfabric\.remapClasspathFile=',       'FABRIC_REMAP_CLASSPATH',       'HIGH',   'Redirects remap classpath file'),
        @('-Dfabric\.skipIntermediary=',         'FABRIC_SKIP_INTERMEDIARY',     'HIGH',   'Skips intermediary mappings'),
        @('-Dfabric\.configDir=',                'FABRIC_CONFIG_DIR',            'MEDIUM', 'Changes Fabric config directory'),
        @('-Dfabric\.loader\.config=',           'FABRIC_LOADER_CONFIG',         'MEDIUM', 'Redirects Fabric loader config'),
        @('-Dfabric\.log\.level=',               'FABRIC_LOG_LEVEL',             'LOW',    'Changes Fabric log level'),
        @('-Dfabric\.debug\.dumpClasspath=',     'FABRIC_DEBUG_DUMP',            'LOW',    'Enables debug classpath dumping'),
        @('-Dfabric\.log\.config=',              'FABRIC_LOG_CONFIG',            'LOW',    'Redirects log config file'),
        @('-Dfabric\.dli\.config=',              'FABRIC_DLI_CONFIG',            'MEDIUM', 'Changes data loader injector config'),
        @('-Dfabric\.mixin\.configs=',           'FABRIC_MIXIN_CONFIGS',         'HIGH',   'Injects custom Mixin configs'),
        @('-Dfabric\.mixin\.hotSwap=',           'FABRIC_MIXIN_HOTSWAP',         'HIGH',   'Enables Mixin hot-swapping (runtime code injection)'),
        @('-Dfabric\.mixin\.debug\.export=',     'FABRIC_MIXIN_DEBUG_EXPORT',    'LOW',    'Exports debug Mixin info'),
        @('-Dfabric\.mixin\.debug\.verbose=',    'FABRIC_MIXIN_DEBUG_VERBOSE',   'LOW',    'Enables verbose Mixin logging'),
        @('-Dfabric\.gameVersion=',              'FABRIC_GAME_VERSION',          'MEDIUM', 'Overrides Fabric game version'),
        @('-Dfabric\.forceVersion=',             'FABRIC_FORCE_VERSION',         'HIGH',   'Forces a specific game version'),
        @('-Dfabric\.autoDetectVersion=',        'FABRIC_AUTO_DETECT_VERSION',   'LOW',    'Enables version auto-detection'),
        @('-Dfabric\.launcher\.name=',           'FABRIC_LAUNCHER_NAME',         'LOW',    'Overrides launcher name'),
        @('-Dfabric\.launcher\.brand=',          'FABRIC_LAUNCHER_BRAND',        'LOW',    'Overrides launcher brand'),
        @('-Dfabric\.mods\.toml\.path=',         'FABRIC_MODS_TOML_PATH',        'HIGH',   'Redirects Fabric mods.toml path'),
        @('-Dfabric\.customModList=',            'FABRIC_CUSTOM_MOD_LIST',       'HIGH',   'Injects custom mod list'),
        @('-Dfabric\.resolve\.modFiles=',        'FABRIC_RESOLVE_MODFILES',      'MEDIUM', 'Forces mod file resolution'),
        @('-Dfabric\.skipDependencyResolution=', 'FABRIC_SKIP_DEP_RESOLUTION',   'HIGH',   'Skips dependency resolution'),
        @('-Dfabric\.loader\.entrypoints=',      'FABRIC_LOADER_ENTRYPOINTS',    'HIGH',   'Injects custom entrypoints'),
        @('-Dfabric\.language\.providers=',      'FABRIC_LANGUAGE_PROVIDERS',    'HIGH',   'Injects custom language providers'),
        # Forge mod injection
        @('-Dforge\.addMods=',                   'FORGE_ADD_MODS',               'HIGH',   'Injects extra Forge mod JARs at runtime'),
        @('-Dforge\.mods=',                      'FORGE_MODS',                   'HIGH',   'Overrides Forge mod list'),
        @('-Dfml\.coreMods\.load=',              'FORGE_COREMODS',               'HIGH',   'Loads Forge core mods via JVM flag'),
        @('-Dforge\.coreMods\.dir=',             'FORGE_COREMODS_DIR',           'HIGH',   'Redirects core mods directory'),
        @('-Dforge\.modDir=',                    'FORGE_MOD_DIR',                'HIGH',   'Redirects mod directory'),
        @('-Dforge\.modsDirectories=',           'FORGE_MODS_DIRECTORIES',       'HIGH',   'Adds extra mod directories'),
        @('-Dfml\.customModList=',               'FORGE_CUSTOM_MOD_LIST',        'HIGH',   'Injects custom Forge mod list'),
        @('-Dforge\.disableModScan=',            'FORGE_DISABLE_MODSCAN',        'HIGH',   'Disables Forge mod scanning'),
        @('-Dforge\.modList=',                   'FORGE_MOD_LIST',               'HIGH',   'Overrides Forge mod list'),
        @('-Dforge\.forceVersion=',              'FORGE_FORCE_VERSION',          'HIGH',   'Forces Forge version'),
        @('-Dforge\.disableUpdateCheck=',        'FORGE_DISABLE_UPDATE',         'MEDIUM', 'Disables Forge update checks'),
        @('-Dforge\.logging\.mojang\.level=',    'FORGE_MOJANG_LOG_LEVEL',       'LOW',    'Changes Mojang log level'),
        @('-Dforge\.mixin\.hotSwap=',            'FORGE_MIXIN_HOTSWAP',          'HIGH',   'Enables Forge Mixin hot-swapping'),
        @('-Dforge\.resourcePack=',              'FORGE_RESOURCE_PACK',          'MEDIUM', 'Injects resource pack'),
        @('-Dforge\.defaultResourcePack=',       'FORGE_DEFAULT_RESOURCE_PACK',  'MEDIUM', 'Injects default resource pack'),
        @('-Dforge\.texturePacks=',              'FORGE_TEXTURE_PACKS',          'MEDIUM', 'Injects texture packs'),
        @('-Dforge\.assetIndex=',                'FORGE_ASSET_INDEX',            'MEDIUM', 'Overrides asset index'),
        @('-Dforge\.assetsDir=',                 'FORGE_ASSETS_DIR',             'MEDIUM', 'Redirects assets directory'),
        # Security bypasses
        @('-Djava\.security\.manager=',          'SECURITY_MANAGER_DISABLED',    'HIGH',   'Disables Java Security Manager'),
        @('-Djava\.security\.policy=',           'SECURITY_POLICY_OVERRIDE',     'HIGH',   'Overrides security policy (possible permissions bypass)'),
        # Classpath manipulation
        @('-Xbootclasspath',                     'BOOTCLASSPATH_MODIFY',         'HIGH',   'Modifies boot classpath (critical system classes)'),
        @('-Djava\.system\.class\.loader=',      'CUSTOM_CLASSLOADER',           'HIGH',   'Replaces system classloader'),
        @('-Djava\.class\.path=',               'CLASSPATH_OVERRIDE',            'HIGH',   'Overrides Java classpath'),
        @('-cp\s+[^ ].*\.jar',                  'CLASSPATH_JAR_INJECTION',       'HIGH',   'Injects JAR via -cp classpath flag'),
        # Debug / remote access
        @('-Xrunjdwp:',                          'REMOTE_DEBUG',                 'HIGH',   'Remote debugging enabled (possible RCE)'),
        @('agentlib:jdwp',                       'JDWP_AGENT',                   'HIGH',   'JDWP agent attached — debugger can execute arbitrary code'),
        @('-agentlib:',                          'NATIVE_AGENT',                 'HIGH',   'Loads native JVMTI agent'),
        @('-agentpath:',                         'NATIVE_AGENT_PATH',            'HIGH',   'Loads native agent by path'),
        # Known cheat client brand spoofing
        @('-D(client|launcher)\.brand=(Wurst|Aristois|Impact|Future|Lambda|Rusher|Konas|Phobos|Salhack|Meteor|Async|Wolfram|Huzuni|Rise|Flux|Gamesense|Intent|Remix|Vape|Ghost|Inertia|Sigma|Novoline|Ares|Prestige|Entropy)', 'CHEAT_CLIENT_BRAND', 'HIGH', 'Cheat client brand spoofed in JVM arguments')
    )

    $agentWhitelist = @("jmxremote","yjp","jrebel","newrelic","jacoco","hotswapagent","theseus","lunar","appney")

    $memTerms = @(
        "liquidbounce","meteorclient","wurst-client","killaura","silentaura","autocrystal",
        "crystalaura","baritone","rise-client","vape-client","aimassist","triggerbot","scaffoldhack",
        "bunnyhop","freecam","webhookstealer","tokengrabber","reverseShell","connectBack",
        "WalksyOptimizer","dqrkis","LWFH Crystal","AutoCrystal","AutoAnchor","SelfDestruct","PacketMine"
    )

    foreach ($javaProc in $javaProcs) {
        $javaPid = $javaProc.Id
        try {
            $wmi = Get-WmiObject Win32_Process -Filter "ProcessId = $javaPid" -EA Stop
            $cmd = $wmi.CommandLine
            if (-not $cmd) { continue }
            if (-not ($cmd -match "net\.minecraft|Minecraft")) { continue }

            # ── javaagent check
            $agentMatches = [regex]::Matches($cmd, '-javaagent:([^\s"]+)')
            foreach ($m in $agentMatches) {
                $agPath = $m.Groups[1].Value.Trim('"').Trim("'")
                $agName = [System.IO.Path]::GetFileName($agPath)
                $safe = $false
                foreach ($w in $agentWhitelist) { if ($agName -match $w) { $safe = $true; break } }
                if (-not $safe) {
                    $key = "AGENT|$agName"
                    if (-not $foundFlags.Contains($key)) {
                        [void]$foundFlags.Add($key)
                        $findings.Add([PSCustomObject]@{ Type = "JAVA_AGENT"; Detail = "Untrusted javaagent: $agName"; Severity = "HIGH"; PID = $javaPid })
                    }
                }
            }

            # ── Pattern checks
            foreach ($sf in $suspiciousPatternsList) {
                if ($cmd -match $sf[0]) {
                    $key = "$($sf[1])|$javaPid"
                    if (-not $foundFlags.Contains($key)) {
                        [void]$foundFlags.Add($key)
                        $findings.Add([PSCustomObject]@{ Type = $sf[1]; Detail = $sf[3]; Severity = $sf[2]; PID = $javaPid })
                    }
                }
            }

            # ── URL-encoded injection
            if ($cmd -match '(%3B|%26%26|%7C%7C|%7C|%60|%24|%3C|%3E)') {
                $key = "URL_ENCODE|$javaPid"
                if (-not $foundFlags.Contains($key)) {
                    [void]$foundFlags.Add($key)
                    $findings.Add([PSCustomObject]@{ Type = "ENCODED_INJECTION"; Detail = "URL-encoded shell metacharacters in JVM args — possible command injection"; Severity = "HIGH"; PID = $javaPid })
                }
            }

            # ── Localhost listener check (vanilla MC never opens listen sockets)
            try {
                $netConn = Get-NetTCPConnection -OwningProcess $javaPid -EA Stop |
                    Where-Object { $_.LocalAddress -eq '127.0.0.1' -and $_.State -eq 'Listen' }
                if ($netConn) {
                    $ports = $netConn.LocalPort -join ', '
                    $key   = "LOCAL_LISTEN|$javaPid"
                    if (-not $foundFlags.Contains($key)) {
                        [void]$foundFlags.Add($key)
                        $findings.Add([PSCustomObject]@{ Type = "LOCAL_LISTEN"; Detail = "Java opened server socket(s) on port(s): $ports — vanilla MC never opens listen sockets"; Severity = "HIGH"; PID = $javaPid })
                    }
                }
            } catch {}

            # ── Memory scan for live cheat strings
            try {
                $handle = [Win32.MemAPI]::OpenProcess(0x10 -bor 0x400, $false, $javaPid)
                if ($handle -ne [IntPtr]::Zero) {
                    $addr       = [IntPtr]::Zero
                    $mbi        = New-Object Win32.MemAPI+MEMORY_BASIC_INFORMATION
                    $mbiSize    = [System.Runtime.InteropServices.Marshal]::SizeOf($mbi)
                    $scanLimit  = 0
                    while ([Win32.MemAPI]::VirtualQueryEx($handle, $addr, [ref]$mbi, [uint32]$mbiSize) -and $scanLimit -lt 512) {
                        $scanLimit++
                        if ($mbi.State -eq 0x1000 -and ($mbi.Protect -band 0x04) -ne 0 -and $mbi.RegionSize -lt 10MB) {
                            $buf  = New-Object byte[] ([int][Math]::Min($mbi.RegionSize, 65536))
                            $read = 0
                            if ([Win32.MemAPI]::ReadProcessMemory($handle, $mbi.BaseAddress, $buf, $buf.Length, [ref]$read) -and $read -gt 0) {
                                $str = [System.Text.Encoding]::ASCII.GetString($buf, 0, $read)
                                foreach ($term in $memTerms) {
                                    if ($str.IndexOf($term, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                                        $key = "MEM|$term"
                                        if (-not $foundFlags.Contains($key)) {
                                            [void]$foundFlags.Add($key)
                                            $findings.Add([PSCustomObject]@{ Type = "MEMORY_SIGNATURE"; Detail = "'$term' found LIVE in JVM heap — cheat is currently loaded and running"; Severity = "HIGH"; PID = $javaPid })
                                        }
                                    }
                                }
                            }
                        }
                        try { $addr = [IntPtr]($mbi.BaseAddress.ToInt64() + $mbi.RegionSize) } catch { break }
                    }
                    [Win32.MemAPI]::CloseHandle($handle) | Out-Null
                }
            } catch {}
        } catch {}
    }
    return $findings
}

# ═══════════════════════════════════════════════════════
#  MOD SIGNATURE SCAN
# ═══════════════════════════════════════════════════════
function Get-ModSignature { param([string]$Path, [bool]$ScanStrings = $true, [bool]$ScanDeep = $true)
    $hits = [System.Collections.Generic.HashSet[string]]::new()
    $entropyWarnings = [System.Collections.Generic.List[string]]::new()
    try {
        $zip  = [System.IO.Compression.ZipFile]::OpenRead($Path)
        foreach ($e in $zip.Entries) {
            foreach ($m in $patternRegex.Matches($e.FullName)) { [void]$hits.Add("P|$($m.Value)") }
        }
        $flat   = [System.Collections.Generic.List[object]]::new()
        $nested = [System.Collections.Generic.List[object]]::new()
        foreach ($e in $zip.Entries) { $flat.Add($e) }
        foreach ($nj in ($zip.Entries | Where-Object { $_.FullName -match "^META-INF/jars/.+\.jar$" })) {
            try {
                $ns = $nj.Open(); $ms = New-Object System.IO.MemoryStream; $ns.CopyTo($ms); $ns.Close(); $ms.Position = 0
                $iz = [System.IO.Compression.ZipArchive]::new($ms, [System.IO.Compression.ZipArchiveMode]::Read)
                $nested.Add($iz); foreach ($ie in $iz.Entries) { $flat.Add($ie) }
            } catch {}
        }
        $scanExt = '\.(class|json|toml|yml|yaml|txt|cfg|properties|xml|html|js|ts|kt|groovy)$|MANIFEST\.MF'
        foreach ($entry in $flat) {
            if ($entry.FullName -notmatch $scanExt) { continue }
            try {
                $st  = $entry.Open(); $buf = New-Object System.IO.MemoryStream; $st.CopyTo($buf); $st.Close()
                $raw = $buf.ToArray(); $buf.Dispose()
                $a   = [System.Text.Encoding]::ASCII.GetString($raw)
                $u   = [System.Text.Encoding]::UTF8.GetString($raw)
                foreach ($m in $patternRegex.Matches($a)) { [void]$hits.Add("P|$($m.Value)") }
                if ($ScanStrings) {
                    foreach ($cs in $cheatStringSet) { if ($a.Contains($cs) -or $u.Contains($cs)) { [void]$hits.Add("S|$cs") } }
                    foreach ($m in $fullwidthRegex.Matches($u)) { [void]$hits.Add("F|$($m.Value)") }
                }
                if ($ScanDeep) {
                    foreach ($ds in $deepCheatStringSet) { if ($a.Contains($ds) -or $u.Contains($ds)) { [void]$hits.Add("D|$ds") } }
                    if ($entry.FullName -match '\.class$' -and $raw.Length -gt 512) {
                        $ent = Get-ShannonEntropy -Data $raw
                        if ($ent -gt 7.2) {
                            $sn = [System.IO.Path]::GetFileName($entry.FullName)
                            $entropyWarnings.Add("HIGH_ENTROPY:$sn($ent)")
                        }
                    }
                }
            } catch {}
        }
        foreach ($n in $nested) { try { $n.Dispose() } catch {} }
        $zip.Dispose()
    } catch {}

    # Full-width deduplication
    $fwPool = @($script:cheatStrings | Where-Object { $_ -cmatch "[\uFF21-\uFF3A\uFF41-\uFF5A\uFF10-\uFF19]" })
    foreach ($h in @($hits)) {
        if ($h -match '^F\|') {
            $fw   = $h.Substring(2); if ($fw.Length -lt 3) { continue }
            $best = $null
            foreach ($cs in $fwPool) { if ($cs.Contains($fw)) { if ($null -eq $best -or $cs.Length -lt $best.Length) { $best = $cs } } }
            $final = if ($best) { $best } elseif ($fw.Length -ge 6) { $fw } else { $null }
            if ($final) { $hits.Remove($h); [void]$hits.Add("F|$final") }
        }
    }
    $fwFinal  = @($hits | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
    $fwUnique = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($fw in $fwFinal) {
        $red = $false
        foreach ($other in $fwFinal) { if ($fw.Length -lt $other.Length -and $other.Contains($fw)) { $red = $true; break } }
        if (-not $red) { [void]$fwUnique.Add($fw) }
    }
    $cleaned = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($h in $hits) {
        if ($h -match '^F\|') { if ($fwUnique.Contains($h.Substring(2))) { [void]$cleaned.Add($h) } }
        else { [void]$cleaned.Add($h) }
    }
    foreach ($ew in $entropyWarnings) { [void]$cleaned.Add("E|$ew") }
    return $cleaned
}

function Get-ModSources { param([string]$Path)
    $urls = [System.Collections.Generic.List[string]]::new()
    $bl   = @("w3\.org","jsonschema\.org","fabricmc\.net","quiltmc\.net","oracle\.com","mojang\.com","minecraft\.net")
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -match '\.(json|toml|yml|yaml)$|MANIFEST\.MF') {
                try {
                    $st  = $entry.Open(); $buf = New-Object System.IO.MemoryStream; $st.CopyTo($buf); $st.Close()
                    $raw = [System.Text.Encoding]::UTF8.GetString($buf.ToArray()); $buf.Dispose()
                    $rm  = [regex]::Matches($raw, "https?://[^\s<>]+")
                    foreach ($m in $rm) {
                        $url   = $m.Value.TrimEnd('\', ',', ')', '}', '"')
                        $isBl  = $false
                        foreach ($b in $bl) { if ($url -match $b) { $isBl = $true; break } }
                        if (-not $isBl -and $url -notmatch '\.(png|jpg|jpeg|gif|svg)$') { $urls.Add($url) }
                    }
                } catch {}
            }
        }
        $zip.Dispose()
    } catch {}
    return @($urls | Select-Object -Unique)
}

function Find-DisallowedMods { param([string]$Path, [array]$JarFiles)
    $found = [System.Collections.Generic.List[PSObject]]::new()
    foreach ($file in $JarFiles) {
        $fn = $file.Name.ToLower()
        $mi = Get-Mod-Info-From-Jar -jarPath $file.FullName
        foreach ($slug in $disallowedMods.Keys) {
            $md     = $disallowedMods[$slug]
            $isDis  = $false; $src = ""
            if ($mi.ModId -and $mi.ModId.ToLower() -match [regex]::Escape($slug.ToLower()))                            { $isDis = $true; $src = "mod ID" }
            elseif ($mi.Name -and $mi.Name.ToLower() -match [regex]::Escape($slug.ToLower().Replace('-', ' ')))        { $isDis = $true; $src = "mod name" }
            else {
                foreach ($name in $md.Names) {
                    $nl = $name.ToLower(); $ns = $nl -replace '\s', ''; $sl = $slug.ToLower()
                    if ($fn -eq "$nl.jar" -or $fn -eq "$ns.jar" -or $fn -eq "$sl.jar" -or $fn -match [regex]::Escape($ns)) {
                        $isDis = $true; $src = "filename"; break
                    }
                }
            }
            if ($isDis) {
                $found.Add([PSCustomObject]@{
                    FileName    = $file.Name
                    ModName     = $md.Names[0]
                    Slug        = $slug
                    MatchedBy   = $src
                    DetectedId  = if ($mi.ModId) { $mi.ModId } else { "-" }
                    DetectedName = if ($mi.Name)  { $mi.Name }  else { "-" }
                }); break
            }
        }
    }
    return $found
}

# ═══════════════════════════════════════════════════════
#  PREFETCH FORENSICS
# ═══════════════════════════════════════════════════════
function Invoke-PrefetchForensics {
    $r = [PSCustomObject]@{
        DeletedEvidence  = [System.Collections.Generic.List[string]]::new()
        ClearedCommands  = [System.Collections.Generic.List[string]]::new()
        JavaPrefetchJars = [System.Collections.Generic.List[PSObject]]::new()
        ModifiedExts     = [System.Collections.Generic.List[PSObject]]::new()
        MissingJars      = [System.Collections.Generic.List[string]]::new()
        DcomLaunchHits   = [System.Collections.Generic.List[string]]::new()
        EvidenceFound    = $false
        PrefetchAccessible = $false
    }
    $logonTime = (Get-CimInstance -ClassName Win32_OperatingSystem -EA SilentlyContinue).LastBootUpTime
    if (-not $logonTime) { $logonTime = (Get-Date).AddHours(-24) }
    $pf = "C:\Windows\Prefetch"
    try {
        $testAccess = Get-ChildItem -Path $pf -Filter *.pf -EA Stop | Select-Object -First 1
        $r.PrefetchAccessible = $true
    } catch {
        $r.DeletedEvidence.Add("Prefetch folder not accessible (admin required)")
        $r.EvidenceFound = $true; return $r
    }
    try {
        $eventLogs = @('Security', 'Microsoft-Windows-PowerShell/Operational', 'System')
        foreach ($log in $eventLogs) {
            try {
                $events = Get-WinEvent -LogName $log -MaxEvents 200 -EA SilentlyContinue |
                    Where-Object { ($_.Id -eq 4660 -or $_.Id -eq 4656) -and $_.Message -match "Prefetch.*\.pf" -and $_.TimeCreated -gt $logonTime }
                if ($events.Count -gt 0) {
                    foreach ($event in ($events | Select-Object -First 5)) {
                        $r.DeletedEvidence.Add("Event Log [$log]: ID $($event.Id) at $($event.TimeCreated)")
                    }
                    $r.EvidenceFound = $true
                }
            } catch {}
        }
    } catch {}
    try {
        $psHist = "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
        $clearPatterns = @("del.*prefetch","remove.*\.pf","clear.*prefetch","powershell.*prefetch","Remove-Item.*prefetch")
        if (Test-Path $psHist) {
            $hist = Get-Content $psHist -Tail 200 -EA SilentlyContinue
            foreach ($pattern in $clearPatterns) {
                $matches2 = $hist | Select-String -Pattern $pattern -EA SilentlyContinue
                if ($matches2) {
                    foreach ($m in ($matches2 | Select-Object -First 3)) { $r.ClearedCommands.Add($m.Line.Trim()) }
                    $r.EvidenceFound = $true; break
                }
            }
        }
    } catch {}
    try {
        $allPf   = Get-ChildItem -Path $pf -Filter *.pf -EA SilentlyContinue
        $javaPf  = $allPf | Where-Object { $_.Name -match "java|javaw" -and $_.LastWriteTime -gt $logonTime }
        if ($javaPf.Count -gt 0) {
            foreach ($pfFile in $javaPf) {
                try {
                    $rawBytes  = [System.IO.File]::ReadAllBytes($pfFile.FullName)
                    $asciiStr  = [System.Text.Encoding]::ASCII.GetString($rawBytes)
                    $jarMatches = [regex]::Matches($asciiStr, '[A-Za-z]:\\[^\x00-\x1F"<>|]*\.jar')
                    foreach ($jm in $jarMatches) {
                        $jp = $jm.Value -replace '\\VOLUME\{[^}]+\}', 'C:'
                        if (Test-Path $jp) {
                            try {
                                $fb = Get-Content $jp -Encoding Byte -TotalCount 4 -EA Stop
                                if ($fb[0] -eq 0x50 -and $fb[1] -eq 0x4B -and $fb[2] -eq 0x03 -and $fb[3] -eq 0x04) {
                                    if ($jp -notmatch '\.jar$') {
                                        $r.ModifiedExts.Add([PSCustomObject]@{ PrefetchFile = $pfFile.Name; JarPath = $jp; Issue = "Valid JAR with modified extension" })
                                        $r.EvidenceFound = $true
                                    } else {
                                        $r.JavaPrefetchJars.Add([PSCustomObject]@{ PrefetchFile = $pfFile.Name; JarPath = $jp; Status = "Valid JAR" })
                                    }
                                }
                            } catch {}
                        } else {
                            $r.MissingJars.Add($jp); $r.EvidenceFound = $true
                        }
                    }
                } catch {}
            }
        }
    } catch {}
    try {
        Get-CimInstance -ClassName Win32_Process -EA SilentlyContinue |
            Where-Object { $_.CommandLine -match "-jar" -and $_.CommandLine -match "java|javaw" } |
            ForEach-Object {
                $r.DcomLaunchHits.Add("PID $($_.ProcessId): $($_.CommandLine.Substring(0,[math]::Min(200,$_.CommandLine.Length)))")
                $r.EvidenceFound = $true
            }
    } catch {}
    return $r
}

# ═══════════════════════════════════════════════════════
#  SYSTEM FORENSICS
# ═══════════════════════════════════════════════════════
function Run-SystemChecks {
    $results = [System.Collections.Generic.List[PSObject]]::new()
    # Hosts file
    try {
        $hc = Get-Content "$env:SystemRoot\System32\drivers\etc\hosts" -EA SilentlyContinue
        $suspHosts = @("modrinth.com","curseforge.com","minecraft.net","mojang.com","hypixel.net","badlion.net","lunarclient.com","watchdog","anticheat","nocheatplus","aac","vulcan","grim")
        foreach ($line in $hc) {
            if ($line -match '^\s*[^#]') {
                foreach ($h in $suspHosts) {
                    if ($line -match $h) { $results.Add([PSCustomObject]@{ Check = "Hosts File"; Status = "FAIL"; Detail = "Blocking: $($line.Trim())" }) }
                }
            }
        }
    } catch {}
    # Defender exclusions
    try {
        $mpExc  = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" -EA Stop
        $javaExc = $mpExc.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } |
            Select-Object -ExpandProperty Name |
            Where-Object { $_ -match 'java|minecraft|jdk|jre|mod|\.minecraft|launcher' }
        if ($javaExc) { foreach ($e in $javaExc) { $results.Add([PSCustomObject]@{ Check = "Defender Exclusions"; Status = "FAIL"; Detail = "Excluded: $e" }) } }
    } catch {}
    # IFEO hijacking
    try {
        $ifeoPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
        if (Test-Path $ifeoPath) {
            Get-ChildItem $ifeoPath -EA SilentlyContinue | ForEach-Object {
                $prop = Get-ItemProperty -Path $_.PSPath -Name "Debugger" -EA SilentlyContinue
                if ($prop -and $prop.Debugger -notmatch 'vsjitdebugger|drwatson|ntsd') {
                    $results.Add([PSCustomObject]@{ Check = "IFEO Hijack"; Status = "FAIL"; Detail = "$($_.PSChildName) -> $($prop.Debugger)" })
                }
            }
        }
    } catch {}
    # PS Script Block Logging
    try {
        $psKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
        if (Test-Path $psKey) {
            $psLog = (Get-ItemProperty $psKey -EA SilentlyContinue).EnableScriptBlockLogging
            if ($psLog -eq 0) { $results.Add([PSCustomObject]@{ Check = "PS Logging"; Status = "WARN"; Detail = "Script Block Logging DISABLED via policy" }) }
        }
    } catch {}
    # Security log clearing
    try {
        $logEv = Get-WinEvent -FilterHashtable @{ LogName = 'Security'; Id = 1102; StartTime = (Get-Date).AddDays(-30) } -MaxEvents 1 -EA Stop
        if ($logEv) { $results.Add([PSCustomObject]@{ Check = "Security Log"; Status = "WARN"; Detail = "Event log recently cleared (ID 1102)" }) }
    } catch {}
    # Scheduled tasks
    try {
        $stRaw = schtasks /query /fo CSV /nh 2>$null | ConvertFrom-Csv -Header TaskName, NextRun, Status -EA SilentlyContinue
        $suspTasks = $stRaw | Where-Object {
            $_.TaskName -notmatch 'Microsoft|Adobe|Google|Mozilla|Steam|NVIDIA|Intel|AMD' -and
            $_.TaskName -match 'update|sync|helper|service|loader|check|runner|updater|java'
        }
        if ($suspTasks) { foreach ($t in ($suspTasks | Select-Object -First 5)) { $results.Add([PSCustomObject]@{ Check = "Scheduled Tasks"; Status = "WARN"; Detail = $t.TaskName }) } }
    } catch {}
    # Firewall
    try {
        $fw = Get-NetFirewallProfile -EA Stop | Where-Object { $_.Enabled -eq $false }
        if ($fw) { $results.Add([PSCustomObject]@{ Check = "Firewall"; Status = "WARN"; Detail = "Disabled on: $($fw.Name -join ', ')" }) }
    } catch {}
    # Prefetch suspicious names
    try {
        $prefFlags = Get-ChildItem "$env:SystemRoot\Prefetch" -Filter "*.pf" -EA SilentlyContinue |
            Where-Object { $_.Name -match 'CHEAT|HACK|INJECT|STEALER|MINER|PAYLOAD|EXPLOIT|LOADER|LIQUIDBOUNCE|WURST|METEOR|VAPE|RISE|SIGMA|BARITONE' }
        if ($prefFlags) { foreach ($p in $prefFlags) { $results.Add([PSCustomObject]@{ Check = "Prefetch"; Status = "WARN"; Detail = $p.Name }) } }
    } catch {}
    # Startup registry
    $runKeys = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    foreach ($rk in $runKeys) {
        if (Test-Path $rk) {
            try {
                $props = Get-ItemProperty $rk -EA SilentlyContinue
                $props.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' } | ForEach-Object {
                    $val = $_.Value.ToString()
                    foreach ($pat in $script:suspiciousStartupPatterns) {
                        if ($val -match $pat) {
                            $results.Add([PSCustomObject]@{ Check = "Startup Registry"; Status = "WARN"; Detail = "$($_.Name) = $val" }); break
                        }
                    }
                }
            } catch {}
        }
    }
    return $results
}

# ═══════════════════════════════════════════════════════
#  SERVICE CHECK
# ═══════════════════════════════════════════════════════
function Run-ServiceCheck {
    $results  = [System.Collections.Generic.List[PSObject]]::new()
    $svcTable = @(
        @("SysMain",    "Superfetch/SysMain",                 "Running"),
        @("PcaSvc",     "Program Compatibility Assistant",    "Running"),
        @("EventLog",   "Windows Event Log",                  "Running"),
        @("Schedule",   "Task Scheduler",                     "Running"),
        @("WinDefend",  "Windows Defender Antivirus",         "Running"),
        @("MpsSvc",     "Windows Firewall",                   "Running"),
        @("wscsvc",     "Security Center",                    "Running"),
        @("Appinfo",    "Application Information (UAC)",      "Running"),
        @("DcomLaunch", "DCOM Server Process Launcher",       "Running"),
        @("PlugPlay",   "Plug and Play",                      "Running")
    )
    $svcNames  = $svcTable | ForEach-Object { $_[0] }
    $allSvcs   = Get-Service -Name $svcNames -EA SilentlyContinue
    $svcLookup = @{}
    foreach ($s in $allSvcs) { $svcLookup[$s.Name] = $s.Status.ToString() }
    foreach ($svc in $svcTable) {
        $status = if ($svcLookup.ContainsKey($svc[0])) { $svcLookup[$svc[0]] } else { "Not Found" }
        if ($status -ne $svc[2]) {
            $results.Add([PSCustomObject]@{ Name = $svc[1]; Status = $status; Expected = $svc[2] })
        }
    }
    return $results
}

# ═══════════════════════════════════════════════════════
#  PC SCAN
# ═══════════════════════════════════════════════════════
function Run-PCscan {
    $r = [PSCustomObject]@{
        FlaggedProcs   = [System.Collections.Generic.List[PSObject]]::new()
        UnknownProcs   = [System.Collections.Generic.List[PSObject]]::new()
        StartupFlags   = [System.Collections.Generic.List[PSObject]]::new()
        CheatFolders   = [System.Collections.Generic.List[string]]::new()
        FilesystemJars = [System.Collections.Generic.List[PSObject]]::new()
    }
    # Process scan
    foreach ($proc in (Get-Process -EA SilentlyContinue)) {
        $name = $proc.Name
        if ($script:processWhitelist.Contains($name)) { continue }
        $path = ""; try { $path = $proc.MainModule.FileName } catch {}
        $nameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($name)
        if ($script:cheatProcessNames.Contains($nameNoExt) -or $script:cheatProcessNames.Contains($name)) {
            $r.FlaggedProcs.Add([PSCustomObject]@{ Name = $name; PID = $proc.Id; Path = $path; Reason = "Known cheat/malware process name" }); continue
        }
        $isSuspName = $false
        foreach ($pat in $script:suspiciousProcessPatterns) { if ($nameNoExt -match $pat) { $isSuspName = $true; break } }
        $isSuspPath = $false; $pathReason = ""
        if ($path) {
            if ($path -match '\\Temp\\')                                                                              { $isSuspPath = $true; $pathReason = "Running from Temp folder" }
            elseif ($path -match 'AppData\\Roaming\\(?!\.minecraft|Minecraft|Discord|Spotify|Code|cursor)')          { $isSuspPath = $true; $pathReason = "Running from AppData\Roaming" }
        }
        if ($isSuspName -and $isSuspPath)    { $r.FlaggedProcs.Add([PSCustomObject]@{ Name = $name; PID = $proc.Id; Path = $path; Reason = "Suspicious name + path ($pathReason)" }) }
        elseif ($isSuspPath)                 { $r.FlaggedProcs.Add([PSCustomObject]@{ Name = $name; PID = $proc.Id; Path = $path; Reason = $pathReason }) }
        elseif ($isSuspName)                 { $r.UnknownProcs.Add([PSCustomObject]@{ Name = $name; PID = $proc.Id; Path = $path; Reason = "Unrecognized process name pattern" }) }
    }
    # Cheat folders
    foreach ($folder in $script:knownCheatFolders) { if (Test-Path $folder) { $r.CheatFolders.Add($folder) } }
    # Filesystem JAR scan (key locations only)
    $scanRoots = [System.Collections.Generic.List[string]]::new()
    $mcRoots   = @(
        "$env:APPDATA\.minecraft\mods", "$env:APPDATA\PrismLauncher\instances", "$env:APPDATA\prismlauncher\instances",
        "$env:APPDATA\ATLauncher\instances", "$env:APPDATA\MultiMC\instances", "$env:APPDATA\ftblauncher\instances",
        "$env:LOCALAPPDATA\curseforge\minecraft\Instances", "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents", $env:TEMP
    )
    foreach ($root in $mcRoots) { if ([System.IO.Directory]::Exists($root)) { [void]$scanRoots.Add($root) } }
    $skipDirs = @("C:\Windows","C:\Program Files","C:\Program Files (x86)",
        "$env:LOCALAPPDATA\Microsoft","$env:APPDATA\Microsoft","$env:USERPROFILE\.gradle",
        "$env:USERPROFILE\.m2","$env:LOCALAPPDATA\lunarclient","$env:APPDATA\lunarclient")
    $skipSegs = @(".paper-remapped","\libraries\net\minecraft","\.gradle\","\.m2\repository\",
        "\.vscode\extensions","\.lunarclient\offline","\.lunarclient\launcher")
    $allJars = [System.Collections.Generic.List[string]]::new()
    $seen    = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($root in $scanRoots) {
        if (-not [System.IO.Directory]::Exists($root)) { continue }
        $queue = [System.Collections.Generic.Queue[string]]::new(); $queue.Enqueue($root)
        while ($queue.Count -gt 0) {
            $dir = $queue.Dequeue()
            try {
                foreach ($f in [System.IO.Directory]::EnumerateFiles($dir, '*.jar')) {
                    $skip = $false
                    foreach ($sd in $skipDirs)  { if ($f.StartsWith($sd, [System.StringComparison]::OrdinalIgnoreCase)) { $skip = $true; break } }
                    if (-not $skip) { foreach ($seg in $skipSegs) { if ($f.IndexOf($seg, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) { $skip = $true; break } } }
                    if (-not $skip -and $seen.Add($f)) { [void]$allJars.Add($f) }
                }
            } catch {}
            try {
                foreach ($sub in [System.IO.Directory]::EnumerateDirectories($dir)) {
                    if (([System.IO.File]::GetAttributes($sub) -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) { $queue.Enqueue($sub) }
                }
            } catch {}
        }
    }
    foreach ($jarPath in $allJars) {
        $fn = [System.IO.Path]::GetFileName($jarPath).ToLower()
        $m  = $tokenRegex.Match($fn)
        if ($m.Success) { $r.FilesystemJars.Add([PSCustomObject]@{ Path = $jarPath; MatchedToken = $m.Value }) }
    }
    return $r
}

# ═══════════════════════════════════════════════════════
#  REPORT HELPERS
# ═══════════════════════════════════════════════════════
$W = 72
function Write-Border { param([string]$Type, [System.ConsoleColor]$Color)
    switch ($Type) {
        'top' { Write-Host ("  ╔" + ("═" * $W) + "╗") -ForegroundColor $Color }
        'sep' { Write-Host ("  ╠" + ("═" * $W) + "╣") -ForegroundColor $Color }
        'bot' { Write-Host ("  ╚" + ("═" * $W) + "╝") -ForegroundColor $Color }
    }
}
function Write-Row { param([string]$Label, [string]$Value,
    [System.ConsoleColor]$LabelColor = [System.ConsoleColor]::DarkGray,
    [System.ConsoleColor]$ValueColor = [System.ConsoleColor]::White,
    [System.ConsoleColor]$BC         = [System.ConsoleColor]::DarkGray)
    $avail = $W - $Label.Length
    if ($avail -lt 4) {
        $tl = $Label.Substring(0, [math]::Max(0, $W - 4)); $p = $W - $tl.Length
        Write-Host "  ║" -ForegroundColor $BC -NoNewline
        Write-Host $tl   -ForegroundColor $LabelColor -NoNewline
        Write-Host (" " * [math]::Max(0, $p) + "║") -ForegroundColor $BC; return
    }
    if ($Value.Length -gt $avail - 3) { $Value = $Value.Substring(0, [math]::Max(0, $avail - 4)) + "..." }
    $p = [math]::Max(0, $W - $Label.Length - $Value.Length)
    Write-Host "  ║"   -ForegroundColor $BC -NoNewline
    Write-Host $Label  -ForegroundColor $LabelColor -NoNewline
    Write-Host $Value  -ForegroundColor $ValueColor -NoNewline
    Write-Host (" " * $p + "║") -ForegroundColor $BC
}
function Write-RowFull { param([string]$Text,
    [System.ConsoleColor]$TC = [System.ConsoleColor]::White,
    [System.ConsoleColor]$BC = [System.ConsoleColor]::DarkGray)
    if ($Text.Length -gt $W - 3) { $Text = $Text.Substring(0, [math]::Max(0, $W - 4)) + "..." }
    $p = [math]::Max(0, $W - $Text.Length)
    Write-Host "  ║"  -ForegroundColor $BC -NoNewline
    Write-Host $Text  -ForegroundColor $TC -NoNewline
    Write-Host (" " * $p + "║") -ForegroundColor $BC
}

# ═══════════════════════════════════════════════════════
#  MAIN SCAN  (Phase order: JVM → Mods → Obf → Ban → Prefetch → System → Svc → PC)
# ═══════════════════════════════════════════════════════
try { $jars = Get-ChildItem -Path $modsPath -Filter *.jar -EA Stop } catch {
    Write-Host "  Cannot read directory." -ForegroundColor Red
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 1
}
if ($jars.Count -eq 0) {
    Write-Host "  No JAR files found." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown"); exit 0
}

$scanTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$mcStatus      = Get-MinecraftStatus

Write-Host ""
Write-Host "  $scanTimestamp" -ForegroundColor DarkGray
Write-Host "  $modsPath"      -ForegroundColor DarkGray
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

# ── Phase 1: JVM Integrity + Memory + Argument Injection
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 1" -ForegroundColor Magenta -NoNewline
Write-Host " · JVM Integrity + Memory Scan + Argument Injection" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
Write-Host "  │  scanning... " -ForegroundColor DarkGray -NoNewline
$jvmResults = Test-JvmIntegrity
$memSigs    = @($jvmResults | Where-Object { $_.Type -eq "MEMORY_SIGNATURE" })
if ($jvmResults.Count -gt 0) {
    $hc  = @($jvmResults | Where-Object { $_.Severity -eq "HIGH" }).Count
    $mc2 = @($jvmResults | Where-Object { $_.Severity -eq "MEDIUM" }).Count
    $parts = @(); if ($hc -gt 0) { $parts += "$hc HIGH" }; if ($mc2 -gt 0) { $parts += "$mc2 MEDIUM" }
    $msg = "$($jvmResults.Count) issue(s) ($($parts -join ', '))"
    if ($memSigs.Count -gt 0) { $msg += " — $($memSigs.Count) LIVE memory hit(s)" }
    Write-Host $msg -ForegroundColor Red
} else { Write-Host "clean" -ForegroundColor Cyan }
Write-Host "  └─ done" -ForegroundColor DarkMagenta

# ── Phase 2: String Analysis + Deep Scan + Filename Tokens
$total   = $jars.Count; $i = 0
$flagged = [System.Collections.Generic.List[PSObject]]::new()
$clean   = [System.Collections.Generic.List[string]]::new()
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 2" -ForegroundColor Magenta -NoNewline
Write-Host " · String Analysis + Deep Scan + Filename Tokens" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
foreach ($jar in $jars) {
    $i++; $pct  = [math]::Floor(($i / $total) * 100)
    $padN = $jar.Name.PadRight(40).Substring(0, [math]::Min(40, $jar.Name.Length))
    [Console]::Write("  │  $pct% $padN`r")
    $sig     = Get-ModSignature -Path $jar.FullName -ScanStrings $true -ScanDeep $true
    $fnMatch = $tokenRegex.Match($jar.Name.ToLower())
    if ($sig.Count -gt 0 -or $fnMatch.Success) {
        $pats   = @($sig | Where-Object { $_ -match '^P\|' } | ForEach-Object { $_.Substring(2) })
        $strs   = @($sig | Where-Object { $_ -match '^S\|' } | ForEach-Object { $_.Substring(2) })
        $fws    = @($sig | Where-Object { $_ -match '^F\|' } | ForEach-Object { $_.Substring(2) })
        $deep_s = @($sig | Where-Object { $_ -match '^D\|' } | ForEach-Object { $_.Substring(2) })
        $entrp  = @($sig | Where-Object { $_ -match '^E\|' } | ForEach-Object { $_.Substring(2) })
        $sources = Get-ModSources -Path $jar.FullName
        $flagged.Add([PSCustomObject]@{
            Name          = $jar.Name
            Path          = $jar.FullName
            Size          = [math]::Round($jar.Length / 1KB, 1)
            Patterns      = $pats
            Strings       = $strs
            Fullwidth     = $fws
            DeepHits      = $deep_s
            Entropy       = $entrp
            HitCount      = $sig.Count
            Sources       = $sources
            ObfResult     = $null
            FilenameToken = if ($fnMatch.Success) { $fnMatch.Value } else { $null }
        })
    } else { $clean.Add($jar.Name) }
}
Write-Host "  │  100% done                                      " -ForegroundColor DarkMagenta
Write-Host "  └─ $($flagged.Count) flagged  /  $($clean.Count) clean" -ForegroundColor DarkMagenta

# ── Phase 3: Advanced Obfuscation Detection
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 3" -ForegroundColor Magenta -NoNewline
Write-Host " · Advanced Obfuscation Detection" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
$oi = 0
foreach ($jar in $jars) {
    $oi++; $pct  = [math]::Floor(($oi / $total) * 100)
    $padN = $jar.Name.PadRight(40).Substring(0, [math]::Min(40, $jar.Name.Length))
    [Console]::Write("  │  $pct% $padN`r")
    $oFlags   = Invoke-ObfuscationFlags -FilePath $jar.FullName
    $existing = $flagged | Where-Object { $_.Name -eq $jar.Name } | Select-Object -First 1
    if ($existing)          { $existing.ObfResult = $oFlags }
    elseif ($oFlags.Count -gt 0) {
        $flagged.Add([PSCustomObject]@{
            Name = $jar.Name; Path = $jar.FullName; Size = [math]::Round($jar.Length / 1KB, 1)
            Patterns = @(); Strings = @(); Fullwidth = @(); DeepHits = @(); Entropy = @()
            HitCount = 0; Sources = @(); ObfResult = $oFlags; FilenameToken = $null
        })
        $clean.Remove($jar.Name) | Out-Null
    }
}
Write-Host "  │  100% done                                      " -ForegroundColor DarkMagenta
$obfHeavy = ($flagged | Where-Object { $_.ObfResult -and $_.ObfResult.Count -gt 0 }).Count
Write-Host "  └─ $obfHeavy jar(s) with obfuscation flags" -ForegroundColor DarkMagenta

# ── Phase 4: Disallowed Mods
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 4" -ForegroundColor Magenta -NoNewline
Write-Host " · Disallowed Mods Detection" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
Write-Host "  │  scanning... " -ForegroundColor DarkGray -NoNewline
$disallowedFound = Find-DisallowedMods -Path $modsPath -JarFiles $jars
if ($disallowedFound.Count -gt 0) { Write-Host "$($disallowedFound.Count) disallowed mod(s)" -ForegroundColor Red }
else                               { Write-Host "clean" -ForegroundColor Cyan }
Write-Host "  └─ done" -ForegroundColor DarkMagenta

# ── Phase 5: Prefetch Forensics
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 5" -ForegroundColor Magenta -NoNewline
Write-Host " · Prefetch Forensic Analysis" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
Write-Host "  │  analyzing... " -ForegroundColor DarkGray -NoNewline
$prefetchResults = Invoke-PrefetchForensics
if ($prefetchResults.EvidenceFound) {
    $ic = $prefetchResults.DeletedEvidence.Count + $prefetchResults.ClearedCommands.Count +
          $prefetchResults.ModifiedExts.Count    + $prefetchResults.MissingJars.Count +
          $prefetchResults.DcomLaunchHits.Count
    Write-Host "$ic forensic indicator(s)" -ForegroundColor Red
} else { Write-Host "clean" -ForegroundColor Cyan }
Write-Host "  └─ done" -ForegroundColor DarkMagenta

# ── Phase 6: System Forensics
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 6" -ForegroundColor Magenta -NoNewline
Write-Host " · System Forensics" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
Write-Host "  │  checking... " -ForegroundColor DarkGray -NoNewline
$sysResults = Run-SystemChecks
if ($sysResults.Count -gt 0) { Write-Host "$($sysResults.Count) issue(s)" -ForegroundColor Red }
else                          { Write-Host "clean" -ForegroundColor Cyan }
Write-Host "  └─ done" -ForegroundColor DarkMagenta

# ── Phase 7: Windows Service Check
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 7" -ForegroundColor Magenta -NoNewline
Write-Host " · Windows Service Check" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
Write-Host "  │  checking... " -ForegroundColor DarkGray -NoNewline
$svcResults = Run-ServiceCheck
if ($svcResults.Count -gt 0) { Write-Host "$($svcResults.Count) service(s) flagged" -ForegroundColor Red }
else                          { Write-Host "all OK" -ForegroundColor Cyan }
Write-Host "  └─ done" -ForegroundColor DarkMagenta

# ── Phase 8: Full PC Scan
Write-Host ""
Write-Host "  ┌─ " -ForegroundColor DarkMagenta -NoNewline
Write-Host "Phase 8" -ForegroundColor Magenta -NoNewline
Write-Host " · Full PC Scan" -ForegroundColor DarkGray
Write-Host "  │" -ForegroundColor DarkMagenta
Write-Host "  │  scanning... " -ForegroundColor DarkGray -NoNewline
$pcResults = Run-PCscan
$pcTotal   = $pcResults.FlaggedProcs.Count + $pcResults.StartupFlags.Count + $pcResults.CheatFolders.Count + $pcResults.FilesystemJars.Count
if ($pcTotal -gt 0) {
    Write-Host "$pcTotal finding(s) — proc:$($pcResults.FlaggedProcs.Count)  start:$($pcResults.StartupFlags.Count)  folders:$($pcResults.CheatFolders.Count)  jars:$($pcResults.FilesystemJars.Count)" -ForegroundColor Red
} else { Write-Host "clean" -ForegroundColor Cyan }
Write-Host "  └─ done" -ForegroundColor DarkMagenta

Start-Sleep -Milliseconds 300; Clear-Host

# ═══════════════════════════════════════════════════════
#  CLASSIFICATION
# ═══════════════════════════════════════════════════════
$criticalThreats  = [System.Collections.Generic.List[PSObject]]::new()
$suspiciousFiles  = [System.Collections.Generic.List[PSObject]]::new()
foreach ($mod in $flagged) {
    $isBlatant = $false
    if ($mod.HitCount -ge 15) { $isBlatant = $true }
    foreach ($str in $mod.Strings) {
        if ($str -match "SelfDestruct|AutoCrystal|Dqrkis Client|POT_CHEATS|Donut|cancelPacket|dropPacket|spoofPacket|setTimerSpeed|timerSpeed|fakeVersion|spoofVersion|grimBypass|ncpBypass|aacBypass|bypassAC|selfdestruct|Runtime\.exec|reverseShell|sendWebhook|TokenGrabber|SessionStealer") {
            $isBlatant = $true; break
        }
    }
    if ($mod.FilenameToken -and $mod.HitCount -eq 0) {
        foreach ($t in @("vape","meteor","liquidbounce","wurst","sigma","rise","future","rusherhack","impact","aristois","baritone","dqrkis","doomsday")) {
            if ($mod.FilenameToken -match $t) { $isBlatant = $true; break }
        }
    }
    if ($mod.ObfResult -and ($mod.ObfResult | Where-Object { $_ -match "Runtime\.exec|HTTP POST|Fake mod identity" }).Count -gt 0) { $isBlatant = $true }
    if ($isBlatant) { $criticalThreats.Add($mod) } else { $suspiciousFiles.Add($mod) }
}

# ═══════════════════════════════════════════════════════
#  FULL REPORT
# ═══════════════════════════════════════════════════════
Write-Host ""
Write-Host "   ┌──────────────────────────────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
Write-Host "   │" -ForegroundColor DarkGray -NoNewline
Write-Host "      NicModAnalyzer " -ForegroundColor Magenta -NoNewline
Write-Host "│ " -ForegroundColor DarkGray -NoNewline
Write-Host "SCAN RESULTS" -ForegroundColor Magenta -NoNewline
Write-Host "                                   │" -ForegroundColor DarkGray
Write-Host "   └──────────────────────────────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray
Write-Host ""

$fC = if ($flagged.Count -gt 0) { [System.ConsoleColor]::Red } else { [System.ConsoleColor]::Cyan }
Write-Border 'top' DarkGray
Write-RowFull ("  SCAN REPORT  ·  " + $scanTimestamp) Magenta DarkGray
Write-Border 'sep' DarkGray
Write-Row "  Modules   : " ($activeModules -join "  ·  ") Magenta White DarkGray
Write-Row "  Path      : " $modsPath DarkGray Gray DarkGray
Write-Row "  Files     : " "$($jars.Count) scanned" DarkGray White DarkGray
Write-Row "  Clean     : " "$($clean.Count)" DarkGray Cyan DarkGray
Write-Row "  Flagged   : " "$($flagged.Count)" DarkGray $fC DarkGray
Write-Row "  Disallowed: " "$($disallowedFound.Count)" DarkGray $(if ($disallowedFound.Count -gt 0) { [System.ConsoleColor]::Red } else { [System.ConsoleColor]::Cyan }) DarkGray
$pcIssueCount = $pcResults.FlaggedProcs.Count + $pcResults.StartupFlags.Count + $pcResults.CheatFolders.Count + $pcResults.FilesystemJars.Count + $sysResults.Count + $svcResults.Count
Write-Row "  System    : " "$pcIssueCount issue(s)" DarkGray $(if ($pcIssueCount -gt 0) { [System.ConsoleColor]::Red } else { [System.ConsoleColor]::Cyan }) DarkGray
if ($mcStatus.Running) {
    Write-Row "  Minecraft : " " RUNNING   PID $($mcStatus.PID)   $($mcStatus.Uptime)   $($mcStatus.RAM) RAM" DarkGray Cyan DarkGray
} else {
    Write-Row "  Minecraft : " " not running" DarkGray DarkGray DarkGray
}
Write-Border 'bot' DarkGray

# ── JVM Issues
if ($jvmResults.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' Red
    Write-RowFull "  JVM INTEGRITY ISSUES" Red Red
    Write-Border 'sep' Red
    foreach ($j in ($jvmResults | Where-Object { $_.Severity -eq "HIGH" }))   { Write-Row "  [HIGH]  $($j.Type.PadRight(28))" $j.Detail Red DarkGray Red }
    foreach ($j in ($jvmResults | Where-Object { $_.Severity -eq "MEDIUM" })) { Write-Row "  [MED]   $($j.Type.PadRight(28))" $j.Detail Yellow DarkGray Yellow }
    foreach ($j in ($jvmResults | Where-Object { $_.Severity -eq "LOW" }))    { Write-Row "  [LOW]   $($j.Type.PadRight(28))" $j.Detail DarkGray DarkGray DarkGray }
    Write-Border 'bot' Red
}

# ── Critical threats
if ($criticalThreats.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' Red
    Write-RowFull "  ⛔  CRITICAL — CONFIRMED CHEAT / MALWARE ($($criticalThreats.Count) file(s))" Red Red
    foreach ($mod in $criticalThreats) {
        Write-Border 'sep' Red
        Write-Row "  [!!!] " $mod.Name White Red Red
        Write-Row "        " "Size: $($mod.Size) KB   Hits: $($mod.HitCount)" DarkGray DarkGray Red
        if ($mod.FilenameToken) { Write-Row "        " "Filename token: $($mod.FilenameToken)" DarkGray Red Red }
        $allHits = @($mod.Strings) + @($mod.Patterns) + @($mod.DeepHits) + @($mod.Fullwidth)
        foreach ($h in ($allHits | Select-Object -First 6)) { Write-Row "        " "• $h" DarkGray Red Red }
        if ($mod.ObfResult) { foreach ($o in ($mod.ObfResult | Select-Object -First 3)) { Write-Row "        " "[OBF] $o" DarkGray Yellow Red } }
        if ($mod.Sources.Count -gt 0) { foreach ($s in ($mod.Sources | Select-Object -First 2)) { Write-Row "        " "[URL] $s" DarkGray DarkYellow Red } }
    }
    Write-Border 'bot' Red
}

# ── Suspicious files
if ($suspiciousFiles.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' Yellow
    Write-RowFull "  ⚠  SUSPICIOUS FILES ($($suspiciousFiles.Count) file(s))" Yellow Yellow
    foreach ($mod in $suspiciousFiles) {
        Write-Border 'sep' DarkYellow
        Write-Row "  [?]  " $mod.Name White Yellow Yellow
        Write-Row "       " "Size: $($mod.Size) KB   Hits: $($mod.HitCount)" DarkGray DarkGray Yellow
        if ($mod.FilenameToken) { Write-Row "       " "Filename token: $($mod.FilenameToken)" DarkGray Yellow Yellow }
        $allHits = @($mod.Strings) + @($mod.Patterns) + @($mod.DeepHits) + @($mod.Fullwidth)
        foreach ($h in ($allHits | Select-Object -First 4)) { Write-Row "       " "• $h" DarkGray DarkGray Yellow }
        if ($mod.ObfResult) { foreach ($o in ($mod.ObfResult | Select-Object -First 2)) { Write-Row "       " "[OBF] $o" DarkGray DarkYellow Yellow } }
        if ($mod.Entropy.Count -gt 0) { Write-Row "       " "[ENT] High entropy classes detected" DarkGray DarkYellow Yellow }
    }
    Write-Border 'bot' Yellow
}

# ── Disallowed mods
if ($disallowedFound.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' Yellow
    Write-RowFull "  ⛔  DISALLOWED MODS DETECTED" Yellow Yellow
    Write-Border 'sep' Yellow
    foreach ($dm in $disallowedFound) {
        Write-Row "  [BAN]  " $dm.FileName White Yellow Yellow
        Write-Row "         " "Mod: $($dm.ModName)  ·  Matched by: $($dm.MatchedBy)" DarkGray DarkYellow Yellow
        if ($dm -ne $disallowedFound[-1]) { Write-Border 'sep' DarkYellow }
    }
    Write-Border 'bot' Yellow
}

# ── Prefetch forensics
if ($prefetchResults.EvidenceFound) {
    Write-Host ""
    Write-Border 'top' Red
    Write-RowFull "  🔍  PREFETCH FORENSIC FINDINGS" Red Red
    Write-Border 'sep' Red
    if ($prefetchResults.DeletedEvidence.Count -gt 0) {
        foreach ($ev in ($prefetchResults.DeletedEvidence | Select-Object -First 12)) { Write-Row "  [DEL]  " $ev DarkGray Red Red }
    }
    if ($prefetchResults.ClearedCommands.Count -gt 0) {
        Write-Border 'sep' Red
        foreach ($cmd2 in ($prefetchResults.ClearedCommands | Select-Object -First 5)) { Write-Row "  [CMD]  " $cmd2 DarkGray Red Red }
    }
    if ($prefetchResults.ModifiedExts.Count -gt 0) {
        Write-Border 'sep' Red
        foreach ($me in $prefetchResults.ModifiedExts) { Write-Row "  [MOD]  " $me.JarPath DarkGray Red Red }
    }
    if ($prefetchResults.MissingJars.Count -gt 0) {
        Write-Border 'sep' DarkRed
        foreach ($mj in ($prefetchResults.MissingJars | Select-Object -First 12)) { Write-Row "  [MISS] " $mj DarkGray Red DarkRed }
    }
    if ($prefetchResults.DcomLaunchHits.Count -gt 0) {
        Write-Border 'sep' Red
        foreach ($dh in ($prefetchResults.DcomLaunchHits | Select-Object -First 5)) { Write-Row "  [PROC] " $dh DarkGray Red Red }
    }
    Write-Border 'bot' Red
}

# ── System forensics
if ($sysResults.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' Red
    Write-RowFull "  🔒  SYSTEM FORENSICS" Red Red
    Write-Border 'sep' Red
    foreach ($sr in $sysResults) {
        $sc = switch ($sr.Status) { "FAIL" { [System.ConsoleColor]::Red } "WARN" { [System.ConsoleColor]::Yellow } default { [System.ConsoleColor]::DarkGray } }
        Write-Row "  [$($sr.Status.PadRight(4))] " "$($sr.Check): $($sr.Detail)" $sc $(if ($sr.Status -eq "FAIL") { [System.ConsoleColor]::Red } else { [System.ConsoleColor]::DarkGray }) Red
    }
    Write-Border 'bot' Red
}

# ── Service check
if ($svcResults.Count -gt 0) {
    Write-Host ""
    Write-Border 'top' Yellow
    Write-RowFull "  ⚙  SERVICE STATUS ISSUES" Yellow Yellow
    Write-Border 'sep' Yellow
    foreach ($sv in $svcResults) {
        Write-Row "  [!!]  " "$($sv.Name)  [$($sv.Status) / expected: $($sv.Expected)]" Yellow DarkGray Yellow
    }
    Write-Border 'bot' Yellow
}

# ── PC scan
if ($pcTotal -gt 0) {
    Write-Host ""
    Write-Border 'top' Red
    Write-RowFull "  🖥  FULL PC SCAN" Red Red
    Write-Border 'sep' Red
    if ($pcResults.FlaggedProcs.Count -gt 0) {
        Write-RowFull "  FLAGGED PROCESSES ($($pcResults.FlaggedProcs.Count))" Red Red
        foreach ($p in ($pcResults.FlaggedProcs | Select-Object -First 10)) {
            Write-Row "  [PROC] " "$($p.Name) [PID $($p.PID)] — $($p.Reason)" DarkGray Red Red
        }
    }
    if ($pcResults.UnknownProcs.Count -gt 0) {
        Write-Border 'sep' Yellow
        Write-RowFull "  UNKNOWN PROCESSES ($($pcResults.UnknownProcs.Count))" Yellow Yellow
        foreach ($p in ($pcResults.UnknownProcs | Select-Object -First 5)) {
            Write-Row "  [?]    " "$($p.Name) [PID $($p.PID)] — $($p.Reason)" DarkGray Yellow Yellow
        }
    }
    if ($pcResults.StartupFlags.Count -gt 0) {
        Write-Border 'sep' Red
        Write-RowFull "  SUSPICIOUS STARTUP ($($pcResults.StartupFlags.Count))" Red Red
        foreach ($sf in ($pcResults.StartupFlags | Select-Object -First 5)) {
            Write-Row "  [START]" "$($sf.Name) — $($sf.Value)" DarkGray Red Red
        }
    }
    if ($pcResults.CheatFolders.Count -gt 0) {
        Write-Border 'sep' Red
        Write-RowFull "  CHEAT FOLDERS ($($pcResults.CheatFolders.Count))" Red Red
        foreach ($cf in ($pcResults.CheatFolders | Select-Object -First 10)) {
            Write-Row "  [DIR]  " $cf DarkGray Red Red
        }
    }
    if ($pcResults.FilesystemJars.Count -gt 0) {
        Write-Border 'sep' Red
        Write-RowFull "  FILESYSTEM CHEAT JARs ($($pcResults.FilesystemJars.Count))" Red Red
        foreach ($jar in ($pcResults.FilesystemJars | Select-Object -First 15)) {
            Write-Row "  [JAR]  " $jar.Path DarkGray Red Red
        }
        if ($pcResults.FilesystemJars.Count -gt 15) {
            Write-Row "  [...]  " "and $($pcResults.FilesystemJars.Count - 15) more" DarkGray Red Red
        }
    }
    Write-Border 'bot' Red
}

# ── All clear banner (if nothing found)
$totalIssues = $jvmResults.Count + $flagged.Count + $disallowedFound.Count + $prefetchResults.DeletedEvidence.Count + $sysResults.Count + $svcResults.Count + $pcTotal
if ($totalIssues -eq 0) {
    Write-Host ""
    Write-Border 'top' Cyan
    Write-RowFull "  ✅  ALL CLEAR — No issues detected across all 8 phases" Cyan Cyan
    Write-Border 'bot' Cyan
}

# ── Footer
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor DarkGray
Write-Host "  ║" -ForegroundColor DarkGray -NoNewline; Write-Host "                    Analysis Complete!                     " -ForegroundColor Green -NoNewline;   Write-Host "║" -ForegroundColor DarkGray
Write-Host "  ║" -ForegroundColor DarkGray -NoNewline; Write-Host "      Special thanks to Tonynoh for helping me            " -ForegroundColor Magenta -NoNewline; Write-Host "║" -ForegroundColor DarkGray
Write-Host "  ║" -ForegroundColor DarkGray -NoNewline; Write-Host "      Credits to MeowModAnalyzer                          " -ForegroundColor Cyan -NoNewline;    Write-Host "║" -ForegroundColor DarkGray
Write-Host "  ║" -ForegroundColor DarkGray -NoNewline; Write-Host "      Discord : mecz.exe                                   " -ForegroundColor Yellow -NoNewline; Write-Host "║" -ForegroundColor DarkGray
Write-Host "  ╚══════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
