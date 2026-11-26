-- ----------------------------------------------------
-- Dеоbfuѕсаtеԁ Ѕuссеѕsfullу Ву LеaκD
-- https://leakd.fr
-- ----------------------------------------------------

getgenv().__RoChessSource = [[
local RS = game:GetService('ReplicatedStorage')
local UIS = game:GetService('UserInputService')
local env = getgenv()
if env.RoChessAssistant then pcall(env.RoChessAssistant.stop) end
if not game:IsLoaded() then game.Loaded:Wait() end
local discordInvite = 'https://discord.gg/SmCXfG33gZ'
local function copyDiscordInvite()
    if type(setclipboard) == 'function' then
        local ok = pcall(setclipboard, discordInvite)
        if ok then return 'Invite copied; open it to join Discord' end
    end
    return discordInvite
end
local function openDiscordInvite()
    local openers = {env.openurl, env.open_url, env.openbrowser}
    if type(syn) == 'table' then openers[4] = syn.open_url end
    for _, opener in pairs(openers) do
        if type(opener) == 'function' then
            local ok, result = pcall(opener, discordInvite)
            if ok and result ~= false then return true end
        end
    end
    return false
end
assert(RS:WaitForChild('ChessClient', 60), 'RoChess modules not found')
assert(RS:WaitForChild('Chess', 60), 'RoChess engine not found')
local App = require(RS.ChessClient.App)
local Engine = require(RS.Chess.Engine)
local Bot = require(RS.Chess.Bot)
local mobile = env.ChessMobilePreview == true or (UIS.TouchEnabled and not UIS.KeyboardEnabled)
local bracketSource = game:HttpGet('https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua')
bracketSource = bracketSource:gsub('MouseButton1Click', 'Activated')
local Bracket = assert(loadstring(bracketSource))()
env.__RoBracketLib = nil
local screen = assert(Bracket.ScreenAsset, 'Bracket screen unavailable')
screen.Parent = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')
screen.ResetOnSpawn = false
local state = {alive=true, hints=true, auto=false, arrows=true, seconds=1, delay=0.5, depth=20, revision=0}
local Http = game:GetService('HttpService')
local configPath = 'RoChessAssistant.settings.json'
local defaults = {hints=true, auto=false, arrows=true, seconds=1, delay=0.5, depth=20, reexecute=true, turnAlert=false, autoLimit=0, pauseUnfocused=true, bookmark='', smartSearch=true, smartMax=6}
local saved = env.__RoChessSettings
if not saved and type(readfile) == 'function' then
    local ok, data = pcall(function() return Http:JSONDecode(readfile(configPath)) end)
    if ok and type(data) == 'table' then saved = data end
end
saved = type(saved) == 'table' and saved or {}
for key, default in pairs(defaults) do
    local value = saved[key]
    if type(value) == type(default) then state[key] = value else state[key] = default end
end
for key, range in pairs({seconds={0.2,5}, delay={0.1,5}, depth={2,30}}) do
    local value = state[key]
    state[key] = value == value and math.clamp(value, range[1], range[2]) or defaults[key]
end
state.smartMax = math.clamp(state.smartMax == state.smartMax and state.smartMax or 6, 1, 12)
state.depth = math.floor(state.depth)
state.autoLimit = math.floor(math.clamp(state.autoLimit == state.autoLimit and state.autoLimit or 0, 0, 50))
state.autoMoves = 0
state.focused = true
state.startedAt = os.clock()
state.searches = 0
state.searchSeconds = 0
state.totalPlayed = 0
local persistenceError
local function saveSettings()
    local data = {}
    for key in pairs(defaults) do data[key] = state[key] end
    env.__RoChessSettings = data
    if type(writefile) == 'function' then
        local ok, err = pcall(function() writefile(configPath, Http:JSONEncode(data)) end)
        persistenceError = not ok and tostring(err) or nil
    else
        persistenceError = 'File saving unavailable; settings carry across queued hops only'
    end
    return data
end
local queueTeleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
env.RoChessAssistant = state
local window = Bracket:Window({Name='RoChess Assistant', Enabled=true, Color=Color3.fromRGB(90,180,255), Size=UDim2.fromOffset(520,530), Position=UDim2.new(0,25,0.5,-265)})
local mobileConnections = {}
local launcherGui
local function bind(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(mobileConnections, connection)
    return connection
end
local function touchTab(tab)
    if not mobile then return tab end
    for _, method in ipairs({'Label','Button','Toggle','Slider'}) do
        local original = tab[method]
        tab[method] = function(self, options)
            options.Side = 'Left'
            return original(self, options)
        end
    end
    tab.Slider = function(self, options)
        local value = options.Value
        local step = options.Precise == 0 and 1 or 0.1
        local display = self:Label({Text=options.Name..': '..tostring(value)..(options.Unit or '')})
        local function change(delta)
            value = math.clamp(math.round((value+delta)/step)*step, options.Min, options.Max)
            display:SetText(options.Name..': '..string.format(options.Precise == 0 and '%.0f' or '%.1f',value)..(options.Unit or ''))
            options.Callback(value)
        end
        self:Button({Name='-  '..options.Name, Callback=function() change(-step) end})
        self:Button({Name='+  '..options.Name, Callback=function() change(step) end})
        return display
    end
    return tab
end
local function setupMobile()
    if not mobile then return end
    local panel = screen:FindFirstChild('Window')
    if not panel then return end
    launcherGui = Instance.new('ScreenGui')
    launcherGui.Name = 'ChessMobileLauncher'
    launcherGui.ResetOnSpawn = false
    launcherGui.DisplayOrder = screen.DisplayOrder+10
    launcherGui.Parent = screen.Parent
    local button = Instance.new('TextButton')
    button.Name = 'ToggleAssistant'
    button.Size = UDim2.fromOffset(150,48)
    button.Position = UDim2.new(1,-162,0,8)
    button.BackgroundColor3 = Color3.fromRGB(27,45,66)
    button.TextColor3 = Color3.new(1,1,1)
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.Parent = launcherGui
    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0,12)
    corner.Parent = button
    local function caption() button.Text = screen.Enabled and 'Close UI' or 'Open UI' end
    bind(button.Activated,function() screen.Enabled=not screen.Enabled; caption() end)
    bind(screen:GetPropertyChangedSignal('Enabled'),caption)
    caption()
    local function fit()
        local camera=workspace.CurrentCamera
        if not camera then return end
        local size=camera.ViewportSize
        panel.AnchorPoint=Vector2.new(0.5,0)
        panel.Position=UDim2.new(0.5,0,0,64)
        panel.Size=UDim2.fromOffset(math.min(430,math.max(240,size.X-24)),math.min(600,math.max(160,size.Y-120)))
    end
    for _, object in ipairs(panel:GetDescendants()) do
        if object.Name == 'RightSide' and object:IsA('GuiObject') then object.Visible=false end
        if object.Name == 'LeftSide' and object:IsA('GuiObject') then object.Size=UDim2.new(1,-12,object.Size.Y.Scale,object.Size.Y.Offset) end
        if object:IsA('TextLabel') or object:IsA('TextButton') or object:IsA('TextBox') then object.TextSize=16 end
        if object:IsA('GuiButton') then
            local constraint=Instance.new('UISizeConstraint')
            constraint.MinSize=Vector2.new(0,44)
            constraint.Parent=object
        end
        if object:IsA('ScrollingFrame') then object.ScrollingEnabled=true; object.ScrollBarThickness=6 end
        if object.Name=='Resize' or object.Name=='Drag' then if object:IsA('GuiObject') then object.Active=false end end
    end
    local tabs=panel:FindFirstChild('TabButtonContainer')
    local content=panel:FindFirstChild('TabContainer')
    if tabs and content then
        tabs.Size=UDim2.new(tabs.Size.X.Scale,tabs.Size.X.Offset,0,46)
        local top=tabs.Position.Y.Offset+48
        content.Position=UDim2.new(content.Position.X.Scale,content.Position.X.Offset,0,top)
        content.Size=UDim2.new(content.Size.X.Scale,content.Size.X.Offset,1,-top-6)
    end
    local cameraConnection
    local function watchCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then cameraConnection=bind(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),fit) end
        fit()
    end
    bind(workspace:GetPropertyChangedSignal('CurrentCamera'),watchCamera)
    watchCamera()
end
local function cleanupMobile()
    for _, connection in ipairs(mobileConnections) do connection:Disconnect() end
    if launcherGui then launcherGui:Destroy() end
end
local main = touchTab(window:Tab({Name='Moves'}))
local settings = touchTab(window:Tab({Name='Settings'}))
local gameTab = touchTab(window:Tab({Name='Game'}))
local toolsTab = touchTab(window:Tab({Name='Tools'}))
local status = main:Label({Text='Waiting for a game', Side='Left'})
local moveLabel = main:Label({Text='Best move: --', Side='Left'})
local evalLabel = main:Label({Text='Your evaluation: --', Side='Left'})
local detail = main:Label({Text='Depth: --', Side='Left'})
local reasonLabel = main:Label({Text='Move details: --',Side='Left'})
local lineLabel = main:Label({Text='Continuation: not calculated',Side='Left'})
local function describeMove(san)
    local facts={}
    if san:find('O%-O%-O') then table.insert(facts,'Castles queenside')
    elseif san:find('O%-O') then table.insert(facts,'Castles kingside') end
    if san:find('x',1,true) then table.insert(facts,'Captures a piece or pawn') end
    local promotion=san:match('=([QRBN])')
    if promotion then table.insert(facts,'Promotes to '..({Q='queen',R='rook',B='bishop',N='knight'})[promotion]) end
    if san:find('#',1,true) then table.insert(facts,'Delivers checkmate')
    elseif san:find('+',1,true) then table.insert(facts,'Gives check') end
    if #facts==0 then return 'Quiet move; see continuation for the follow-up' end
    return table.concat(facts,' | ')
end
local function calculateLine(fen,firstMove,cancelled,seconds,depth)
    local position=Engine.new(fen)
    local ucis,sans={},{}
    for ply=1,3 do
        if cancelled() then return nil end
        local uci=firstMove
        if ply>1 then
            local result=Bot.analyse(position:getFen(),{},seconds,depth,{slice=0.005,cancelled=cancelled})
            uci=result.best
        end
        if cancelled() then return nil end
        if not uci then break end
        local move=position:moveFromUci(uci)
        if not move then break end
        table.insert(sans,position:moveToSan(move))
        table.insert(ucis,uci)
        position:playUci(uci)
    end
    return {sans=sans,ucis=ucis}
end

local function label(widget, text)
    pcall(function()
        if widget.SetText then widget:SetText(text) elseif widget.ChangeText then widget:ChangeText(text) end
    end)
end
local gameInfo = gameTab:Label({Text='No active game',Side='Left'})
local materialInfo = gameTab:Label({Text='Material: --',Side='Left'})
local checkInfo = gameTab:Label({Text='Check: --',Side='Left'})
local moveHistory = gameTab:Label({Text='Recent moves: --',Side='Left'})
local autoProgress = gameTab:Label({Text='Autoplay moves: 0',Side='Right'})
local function pgnText(session)
    local function escape(value)
        return tostring(value or ''):gsub('\\','\\\\'):gsub('"','\\"'):gsub('[\r\n]',' ')
    end
    local tags={'[Event "RoChess game"]','[White "'..escape(session.white and session.white.display or 'White')..'"]','[Black "'..escape(session.black and session.black.display or 'Black')..'"]','[Result "*"]'}
    if session.startFen then
        table.insert(tags,'[SetUp "1"]')
        table.insert(tags,'[FEN "'..escape(session.startFen)..'"]')
    end
    local side,number='w',1
    if session.startFen then
        local parts=string.split(session.startFen,' ')
        side=parts[2] or 'w';number=tonumber(parts[6]) or 1
    end
    local moves={}
    for i,san in ipairs(session.sans or {}) do
        if side=='w' then table.insert(moves,tostring(number)..'.')
        elseif i==1 then table.insert(moves,tostring(number)..'...') end
        table.insert(moves,san)
        if side=='b' then number+=1 end
        side=side=='w' and 'b' or 'w'
    end
    table.insert(moves,'*')
    return table.concat(tags,'\n')..'\n\n'..table.concat(moves,' ')
end
local function updateGameInfo()
    local session=App.session
    if not session or session.kind=='idle' then
        label(gameInfo,'No active game');label(materialInfo,'Material: --');label(checkInfo,'Check: --');label(moveHistory,'Recent moves: --');return
    end
    local color=session.myColor
    label(gameInfo,'Mode: '..tostring(session.kind)..' | You: '..(color==1 and 'White' or color==-1 and 'Black' or 'Spectator'))
    local values={1,3,3,5,9,0}
    local white,black=0,0
    for _,piece in ipairs(session.engine:boardArray()) do
        if piece>0 then white+=values[piece] or 0 elseif piece<0 then black+=values[-piece] or 0 end
    end
    label(materialInfo,string.format('Material W %d / B %d | Your balance: %+.0f',white,black,(white-black)*(color or 1)))
    label(checkInfo,session.engine:inCheck() and ((session.engine.side==1 and 'White' or 'Black')..' is in check') or 'No check')
    local recent={}
    for i=math.max(1,#session.sans-7),#session.sans do table.insert(recent,session.sans[i]) end
    label(moveHistory,'Recent moves: '..(#recent>0 and table.concat(recent,' ') or '--'))
    label(autoProgress,'Autoplay moves: '..state.autoMoves..(state.autoLimit>0 and (' / '..state.autoLimit) or ' (unlimited)'))
    local turnKey=tostring(session)..':'..session.engine:getFen()
    if state.turnAlert and not session.over and session.kind~='analysis' and session.myColor==session.engine.side and state.alertKey~=turnKey then
        state.alertKey=turnKey
        pcall(function() game:GetService('StarterGui'):SetCore('SendNotification',{Title='RoChess: your turn',Text='You are playing '..(color==1 and 'White' or 'Black'),Duration=4}) end)
    end
end
local function clearArrow()
    if App.board then pcall(function() App.board:setArrow('assistant', nil, nil) end) end
end
local function invalidate()
    state.revision += 1
    state.result = nil
    state.key = nil
    clearArrow()
    label(moveLabel, 'Best move: --')
    label(evalLabel, 'Your evaluation: --')
    label(detail, 'Depth: --')
    state.line=nil
    label(reasonLabel,'Move details: --')
    label(lineLabel,'Continuation: not calculated')
end
local autoToggle
local function autoOff()
    state.auto = false
    if autoToggle and autoToggle.Value ~= false then
        pcall(function()
            if autoToggle.SetValue then autoToggle:SetValue(false)
            elseif autoToggle.ChangeValue then autoToggle:ChangeValue(false) end
        end)
        autoToggle.Value = false
    end
    saveSettings()
end
function state.stop()
    cleanupMobile()
    saveSettings()
    state.alive = false
    state.auto = false
    state.revision += 1
    clearArrow()
    if state.connection then state.connection:Disconnect() end
    if state.teleportConnection then state.teleportConnection:Disconnect() end
    if state.teleportFailed then state.teleportFailed:Disconnect() end
    pcall(function() screen:Destroy() end)
end
local function snapshot()
    local s = App.session
    if not s or s.kind == 'idle' then return nil, 'Waiting for a game' end
    if s.over then return nil, 'Game finished' end
    if s.viewPly ~= #s.ucis then return nil, 'Viewing history; return to latest move' end
    if s.kind ~= 'online' and s.kind ~= 'bot' and s.kind ~= 'analysis' and s.kind ~= 'puzzle' and s.kind ~= 'rush' then
        return nil, 'Unsupported mode: '..tostring(s.kind)
    end
    return s, s.engine:getFen()
end
local function draw()
    clearArrow()
    local r = state.result
    if state.arrows and r and r.best and App.board then
        App.board:setArrow('assistant', Engine.algToIndex64(r.best:sub(1,2)), Engine.algToIndex64(r.best:sub(3,4)), Color3.fromRGB(90,220,130), 0.15)
    end
end
local function playerColor(s)
    if s.myColor == 1 or s.myColor == -1 then return s.myColor end
    if s.kind == 'analysis' then return s.engine.side end
    return nil
end
local function ownTurn(s)
    local color = playerColor(s)
    return color ~= nil and (s.kind == 'analysis' or s.engine.side == color)
end
local function play()
    if state.auto and state.pauseUnfocused and not state.focused then return false end
    local s, key = snapshot()
    local r = state.result
    if not s or not r or state.session ~= s or state.key ~= key then return false end
    if not ownTurn(s) then return false end
    if s.kind ~= 'analysis' and not s:isMyTurn() then return false end
    if not r.best or not s.engine:moveFromUci(r.best) then return false end
    if state.failedKey==key and state.failedSession==s and (state.failedAttempts or 0)>=3 then
        label(status,'Autoplay paused: move failed 3 times; press Recalculate');return false
    end
    if os.clock()<(state.retryAt or 0) then return false end
    if state.sentSession == s and state.sentKey == key then return false end
    state.sentSession, state.sentKey = s, key
    local promo = ({q=5,r=4,b=3,n=2})[r.best:sub(5,5)]
    local ok, accepted = pcall(App.onBoardMove, Engine.algToIndex64(r.best:sub(1,2)), Engine.algToIndex64(r.best:sub(3,4)), promo, false)
    local advanced=App.session==s and s.engine:getFen()~=key
    if (not ok or accepted==false) and not advanced then
        state.sentSession,state.sentKey=nil,nil
        if state.failedSession~=s or state.failedKey~=key then state.failedAttempts=0 end
        state.failedSession,state.failedKey=s,key
        state.failedAttempts=(state.failedAttempts or 0)+1
        state.retryAt=os.clock()+1.5
        state.lastError=ok and 'Move not accepted yet' or tostring(accepted)
        label(status,'Autoplay retry '..state.failedAttempts..'/3: '..state.lastError:sub(1,70))
        return false
    end
    state.failedAttempts=0
    state.failedKey=nil
    state.retryAt=nil
    state.lastError=nil
    state.totalPlayed += 1
    if state.auto then
        state.autoMoves += 1
        if state.autoLimit > 0 and state.autoMoves >= state.autoLimit then autoOff() end
    end
    invalidate()
    return true
end
main:Toggle({Name='Show suggestions', Side='Right', Value=state.hints, Callback=function(v) state.hints=v; saveSettings(); invalidate() end})
autoToggle = main:Toggle({Name='Autoplay (your turn)', Side='Right', Value=state.auto, Callback=function(v) state.auto=v; if v then state.autoMoves=0;state.failedAttempts=0;state.failedKey=nil;state.sentKey=nil;state.retryAt=nil end; saveSettings(); state.readyAt=os.clock()+state.delay end})
main:Toggle({Name='Move arrow', Side='Right', Value=state.arrows, Callback=function(v) state.arrows=v; saveSettings(); draw() end})
main:Button({Name='Play suggested move once', Side='Right', Callback=play})
main:Button({Name='Recalculate', Side='Right', Callback=function() state.sentKey=nil;state.failedAttempts=0;state.failedKey=nil;state.retryAt=nil;invalidate() end})
main:Button({Name='STOP autoplay [End]', Side='Right', Callback=autoOff})
settings:Toggle({Name='Adaptive thinking',Side='Left',Value=state.smartSearch,Callback=function(v) state.smartSearch=v;saveSettings();invalidate() end})
settings:Slider({Name='Adaptive maximum',Side='Left',Min=1,Max=12,Value=state.smartMax,Precise=1,Unit='s',Callback=function(v) state.smartMax=v;saveSettings();invalidate() end})
settings:Slider({Name='Think time', Side='Left', Min=0.2, Max=5, Value=state.seconds, Precise=1, Unit='s', Callback=function(v) state.seconds=v; saveSettings(); invalidate() end})
settings:Slider({Name='Maximum depth', Side='Left', Min=2, Max=30, Value=state.depth, Precise=0, Callback=function(v) state.depth=v; saveSettings(); invalidate() end})
settings:Slider({Name='Move delay', Side='Left', Min=0.1, Max=5, Value=state.delay, Precise=1, Unit='s', Callback=function(v) state.delay=v; saveSettings(); state.readyAt=os.clock()+v end})
settings:Toggle({Name='Re-execute after hop', Side='Right', Value=state.reexecute, Callback=function(v) state.reexecute=v; saveSettings() end})
local persistenceLabel = settings:Label({Text='', Side='Right'})
settings:Button({Name='Copy Discord invite', Side='Right', Callback=function()
    label(persistenceLabel, copyDiscordInvite())
end})
settings:Button({Name='Save settings now', Side='Right', Callback=function()
    saveSettings()
    label(persistenceLabel, persistenceError or 'Settings saved')
end})
settings:Button({Name='Flip board', Side='Right', Callback=function() App.flip() end})
settings:Button({Name='Copy current FEN', Side='Right', Callback=function()
    if App.session and setclipboard then setclipboard(App.session.engine:getFen()); label(status,'FEN copied') end
end})
settings:Button({Name='Copy suggested move', Side='Right', Callback=function()
    if state.result and state.result.best and setclipboard then setclipboard(state.result.best); label(status,'Move copied') end
end})
settings:Label({Text='RightShift: hide/show UI\nEnd: stop autoplay\nPositive evaluation favors your color\nUses RoChess local engine', Side='Right'})
settings:Button({Name='Unload assistant', Side='Right', Callback=state.stop})
gameTab:Button({Name='Return to latest move',Side='Right',Callback=function()
    autoOff()
    local session=App.session
    if session then session.viewPly=#session.ucis; App.render(); invalidate() end
end})
gameTab:Button({Name='Copy game as PGN',Side='Right',Callback=function()
    if not App.session or App.session.kind=='idle' then label(status,'Start a game first');return end
    if type(setclipboard)~='function' then label(status,'Clipboard unavailable');return end
    local ok=pcall(setclipboard,pgnText(App.session))
    label(status,ok and 'PGN copied (result unspecified)' or 'Could not copy PGN')
end})
gameTab:Button({Name='Save position snapshot',Side='Right',Callback=function()
    if not App.session or App.session.kind=='idle' then return end
    local data={fen=App.session.engine:getFen(),moves=table.clone(App.session.sans),color=App.session.myColor}
    local path='RoChess-position-'..tostring(os.time())..'.json'
    if type(writefile)~='function' then label(status,'File saving unavailable');return end
    local ok=pcall(writefile,path,Http:JSONEncode(data))
    label(status,ok and ('Saved '..path) or 'Position save failed')
end})
gameTab:Toggle({Name='Notify on your turn',Side='Right',Value=state.turnAlert,Callback=function(v) state.turnAlert=v;saveSettings() end})
gameTab:Slider({Name='Autoplay move limit (0 = unlimited)',Side='Right',Min=0,Max=50,Value=state.autoLimit,Precise=0,Callback=function(v) state.autoLimit=v;saveSettings() end})
gameTab:Button({Name='Reset autoplay counter',Side='Right',Callback=function() state.autoMoves=0;updateGameInfo() end})
state.exportPGN=pgnText
local toolStatus = toolsTab:Label({Text='Tools ready',Side='Left'})
local statistics = toolsTab:Label({Text='Statistics: --',Side='Left'})
local bookmarkLabel = toolsTab:Label({Text=state.bookmark~='' and 'Position bookmark saved' or 'No bookmark saved',Side='Left'})
local function copyText(text, message)
    if type(setclipboard)~='function' then label(toolStatus,'Clipboard unavailable');return false end
    local ok=pcall(setclipboard,text)
    label(toolStatus,ok and message or 'Clipboard failed')
    return ok
end
local function activeGame()
    local session=App.session
    if not session or session.kind=='idle' then label(toolStatus,'Start a game first');return nil end
    return session
end
local function gameReport(session)
    local color=session.myColor==1 and 'White' or session.myColor==-1 and 'Black' or 'Spectator'
    local lines={'RoChess game report','Mode: '..tostring(session.kind),'Your color: '..color,'Played plies: '..tostring(#(session.ucis or {})),'FEN: '..session.engine:getFen(),'Moves (UCI): '..table.concat(session.ucis or {},' ')}
    if state.session==session and state.key==session.engine:getFen() and state.result and state.result.best then
        table.insert(lines,'Suggested move: '..state.result.best)
        table.insert(lines,'Search depth: '..tostring(state.result.depth or 0))
    end
    return table.concat(lines,'\n')
end
toolsTab:Button({Name='Bookmark current position',Side='Right',Callback=function()
    local session=activeGame();if not session then return end
    state.bookmark=session.engine:getFen();saveSettings()
    label(bookmarkLabel,'Position bookmark saved');label(toolStatus,'Saved current FEN as your bookmark')
end})
toolsTab:Button({Name='Copy bookmarked FEN',Side='Right',Callback=function()
    if state.bookmark=='' then label(toolStatus,'No bookmark saved');return end
    copyText(state.bookmark,'Bookmarked FEN copied')
end})
toolsTab:Button({Name='Clear bookmark',Side='Right',Callback=function()
    state.bookmark='';saveSettings();label(bookmarkLabel,'No bookmark saved')
end})
toolsTab:Button({Name='Copy move list (UCI)',Side='Right',Callback=function()
    local session=activeGame();if session then copyText(table.concat(session.ucis or {},' '),'UCI move list copied') end
end})
toolsTab:Button({Name='Copy game report',Side='Right',Callback=function()
    local session=activeGame();if session then copyText(gameReport(session),'Game report copied') end
end})
toolsTab:Toggle({Name='Pause autoplay when unfocused',Side='Right',Value=state.pauseUnfocused,Callback=function(v) state.pauseUnfocused=v;saveSettings() end})
toolsTab:Button({Name='Reset session statistics',Side='Right',Callback=function()
    state.startedAt=os.clock();state.searches=0;state.searchSeconds=0;state.totalPlayed=0
end})
toolsTab:Button({Name='Hide UI',Side='Right',Callback=function() screen.Enabled=false end})
bind(UIS.WindowFocusReleased,function() state.focused=false end)
bind(UIS.WindowFocused,function() state.focused=true;state.readyAt=os.clock()+state.delay end)
local function updateStatistics()
    local elapsed=math.floor(os.clock()-state.startedAt)
    label(statistics,string.format('Session %d:%02d | Searches %d\nSearch time %.1fs | Moves played %d',math.floor(elapsed/60),elapsed%60,state.searches,state.searchSeconds,state.totalPlayed))
end
state.gameReport=gameReport
main:Button({Name='Show opponent reply + my response',Side='Right',Callback=function()
    if state.lineBusy then return end
    local session,fen=snapshot()
    if not session or not state.result or not state.result.best or state.session~=session or state.key~=fen then
        label(lineLabel,'Wait for a current suggestion first');return
    end
    local first=state.result.best
    local revision=state.revision
    state.lineBusy=true
    label(lineLabel,'Calculating likely replies...')
    task.spawn(function()
        local function cancelled()
            return not state.alive or state.revision~=revision or App.session~=session or session.engine:getFen()~=fen
        end
        local ok,result=pcall(calculateLine,fen,first,cancelled,math.min(state.seconds,2),state.depth)
        state.lineBusy=false
        if cancelled() then return end
        if not ok then label(lineLabel,'Continuation failed: '..tostring(result):sub(1,70));return end
        if not result or #result.sans==0 then label(lineLabel,'No continuation available');return end
        state.line=result
        local text={'You: '..result.sans[1]}
        if result.sans[2] then table.insert(text,'Opponent: '..result.sans[2]) end
        if result.sans[3] then table.insert(text,'You next: '..result.sans[3]) end
        label(lineLabel,table.concat(text,'\n'))
    end)
end})
main:Button({Name='Copy calculated continuation',Side='Right',Callback=function()
    if not state.line then label(lineLabel,'Calculate a continuation first');return end
    if type(setclipboard)=='function' then pcall(setclipboard,table.concat(state.line.sans,' ')..'\n'..table.concat(state.line.ucis,' ')) end
end})
state.calculateLine=calculateLine
state.describeMove=describeMove
setupMobile()
state.connection = UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.End then autoOff() end
    if processed or UIS:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        pcall(function() screen.Enabled = not screen.Enabled end)
    end
end)
local function searchBudget(session,now)
    local seconds=state.seconds
    local reason='Manual budget'
    if state.smartSearch then
        local pieces=0
        for _,piece in ipairs(session.engine:boardArray()) do if piece~=0 then pieces+=1 end end
        local legal=#session.engine:legalMoves()
        if legal==1 then seconds=0.15;reason='Only one legal move'
        elseif session.engine:inCheck() then seconds=math.max(seconds*2,3);reason='In check'
        elseif pieces<=12 then seconds=math.max(seconds*2.5,4);reason='Endgame'
        elseif legal>=30 then seconds=math.max(seconds*1.75,3);reason='Many candidate moves'
        else seconds=math.max(seconds,2);reason='Adaptive search' end
        seconds=math.min(seconds,state.smartMax)
    end
    local delay=state.delay
    local remaining
    if session.clocks and session.myColor and session.kind~='analysis' then
        remaining=session.clocks[session.myColor]
        if type(remaining)=='number' then
            remaining=remaining/1000
            if session.engine.side==session.myColor and (session.turnStart or 0)>0 then
                remaining-=math.max(0,now-session.turnStart)
            end
            remaining=math.max(0,remaining)
            delay=math.min(delay,math.max(0,remaining*0.02))
            local cap=math.max(0.05,math.min(remaining*0.08,remaining-delay-0.4))
            if cap<seconds then seconds=cap;reason='Clock-limited search' end
        end
    end
    return seconds,delay,reason,remaining
end
state.searchBudget=searchBudget
local function tick()
    updateStatistics()
    updateGameInfo()
    local s, key = snapshot()
    if state.observedSession ~= App.session then
        state.observedSession = App.session
        invalidate()
    end
    if not s then
        if state.key or state.result then invalidate() end
        label(status, key)
        return
    end
    if not state.hints and not state.auto then label(status,'Suggestions paused'); return end
    local color = playerColor(s)
    if not ownTurn(s) then
        if state.key or state.result then invalidate() end
        label(status, color and ('You are '..(color == 1 and 'White' or 'Black')..' | Waiting for opponent') or 'Waiting for your assigned color')
        return
    end
    if state.lineBusy then return end
    if state.session ~= s or state.key ~= key or state.color ~= color or not state.result then
        invalidate()
        state.session, state.key, state.color = s, key, color
        local revision = state.revision
        label(status, 'Analysing...')
        local thinkSeconds, moveDelay, searchReason = searchBudget(s,workspace:GetServerTimeNow())
        label(status,string.format('%s: %.2fs',searchReason,thinkSeconds))
        local searchStarted = os.clock()
        local result = Bot.analyse(s.startFen, table.clone(s.ucis), thinkSeconds, state.depth, {
            slice=0.005,
            cancelled=function()
                return not state.alive or state.revision ~= revision or App.session ~= s or s.engine:getFen() ~= key or playerColor(s) ~= color or not ownTurn(s)
            end,
        })
        if not state.alive or state.revision ~= revision or App.session ~= s or s.engine:getFen() ~= key or playerColor(s) ~= color or not ownTurn(s) then
            state.key = nil
            return
        end
        state.searches += 1
        state.searchSeconds += os.clock()-searchStarted
        state.result = result
        local _,latestDelay=searchBudget(s,workspace:GetServerTimeNow())
        state.readyAt = os.clock()+math.min(moveDelay,latestDelay)
        if not result.best then label(status, result.terminal or 'No legal move'); return end
        local m = s.engine:moveFromUci(result.best)
        local san = m and s.engine:moveToSan(m) or result.best
        label(moveLabel, 'Your best: '..san..' ('..result.best..')')
        label(reasonLabel,describeMove(san))
        local mate = result.mate and result.mate * color
        label(evalLabel, mate and ((mate > 0 and 'You mate in ' or 'Opponent mates in ')..tostring(math.abs(mate))) or string.format('Your evaluation: %+.2f', (result.score or 0)*color/100))
        label(detail, string.format('Depth %d | Nodes %d | %.2fs\n%s', result.depth or 0, result.nodes or 0,os.clock()-searchStarted,searchReason))
        draw()
        state.drawnAt = os.clock()
    end
    if state.result and state.result.best and os.clock() - (state.drawnAt or 0) >= 0.5 then
        draw()
        state.drawnAt = os.clock()
    end
    label(status, 'You are '..(color == 1 and 'White' or 'Black')..' | '..(state.auto and 'Autoplay enabled' or 'Your turn'))
    if state.auto and state.pauseUnfocused and not state.focused then
        label(status,'Autoplay paused: Roblox is unfocused')
    elseif state.auto and state.result and os.clock() >= (state.readyAt or math.huge) then play() end
end
state.tick = tick
state.play = play
state.observedSession = App.session
state.worker = task.spawn(function()
    while state.alive do
        local ok, err = pcall(tick)
        if not ok then
            state.lastError=tostring(err)
            state.retryAt=os.clock()+2
            state.key=nil
            label(status, 'Error: '..tostring(err):sub(1,100))
            warn('[RoChess Assistant] '..tostring(err))
            task.wait(2)
        end
        task.wait(0.15)
    end
end)
saveSettings()
label(persistenceLabel, persistenceError or (type(queueTeleport) == 'function' and 'Settings autosave | Hop resume ready' or 'Settings autosave | Teleport queue unavailable'))
local queued = false
state.teleportConnection = game:GetService('Players').LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then queued=false; return end
    if not state.alive or not state.reexecute or queued then return end
    if type(queueTeleport) ~= 'function' or type(env.__RoChessSource) ~= 'string' then
        label(persistenceLabel, 'Hop resume unavailable in this executor')
        return
    end
    local data = saveSettings()
    local payload = 'local source='..string.format('%q', env.__RoChessSource)..';getgenv().__RoChessSource=source;getgenv().__RoChessSettings=game:GetService("HttpService"):JSONDecode('..string.format('%q', Http:JSONEncode(data))..');assert(loadstring(source))()'
    local ok, err = pcall(queueTeleport, payload)
    queued = ok
    if not ok then label(persistenceLabel, 'Hop queue failed: '..tostring(err)) end
end)
state.teleportFailed = game:GetService('TeleportService').TeleportInitFailed:Connect(function(player)
    if player == game:GetService('Players').LocalPlayer then queued=false end
end)
print('[RoChess Assistant] Loaded with saved settings. RightShift toggles UI; End stops autoplay.')

]]

-- https://leakd.fr
assert(loadstring([[
local RS = game:GetService('ReplicatedStorage')
local UIS = game:GetService('UserInputService')
local env = getgenv()
if env.RoChessAssistant then pcall(env.RoChessAssistant.stop) end
if not game:IsLoaded() then game.Loaded:Wait() end
local discordInvite = 'https://discord.gg/SmCXfG33gZ'
local function copyDiscordInvite()
    if type(setclipboard) == 'function' then
        local ok = pcall(setclipboard, discordInvite)
        if ok then return 'Invite copied; open it to join Discord' end
    end
    return discordInvite
end
local function openDiscordInvite()
    local openers = {env.openurl, env.open_url, env.openbrowser}
    if type(syn) == 'table' then openers[4] = syn.open_url end
    for _, opener in pairs(openers) do
        if type(opener) == 'function' then
            local ok, result = pcall(opener, discordInvite)
            if ok and result ~= false then return true end
        end
    end
    return false
end
task.spawn(function()
    if openDiscordInvite() then return end
    local callback = Instance.new('BindableFunction')
    callback.OnInvoke = function(button)
        if button == 'Copy invite' then
            local message = copyDiscordInvite()
            pcall(function()
                game:GetService('StarterGui'):SetCore('SendNotification', {
                    Title='Discord invite', Text=message, Duration=12
                })
            end)
        end
    end
    for attempt = 1, 10 do
        local ok = pcall(function()
            game:GetService('StarterGui'):SetCore('SendNotification', {
                Title='Discord: open link manually', Text=discordInvite, Duration=20,
                Button1='Copy invite', Button2='Dismiss', Callback=callback
            })
        end)
        if ok then break end
        task.wait(1)
    end
    task.delay(25, function() callback:Destroy() end)
end)
assert(RS:WaitForChild('ChessClient', 60), 'RoChess modules not found')
assert(RS:WaitForChild('Chess', 60), 'RoChess engine not found')
local App = require(RS.ChessClient.App)
local Engine = require(RS.Chess.Engine)
local Bot = require(RS.Chess.Bot)
local mobile = env.ChessMobilePreview == true or (UIS.TouchEnabled and not UIS.KeyboardEnabled)
local bracketSource = game:HttpGet('https://raw.githubusercontent.com/AlexR32/Bracket/main/BracketV32.lua')
bracketSource = bracketSource:gsub('MouseButton1Click', 'Activated')
local Bracket = assert(loadstring(bracketSource))()
env.__RoBracketLib = nil
local screen = assert(Bracket.ScreenAsset, 'Bracket screen unavailable')
screen.Parent = game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui')
screen.ResetOnSpawn = false
local state = {alive=true, hints=true, auto=false, arrows=true, seconds=1, delay=0.5, depth=20, revision=0}
local Http = game:GetService('HttpService')
local configPath = 'RoChessAssistant.settings.json'
local defaults = {hints=true, auto=false, arrows=true, seconds=1, delay=0.5, depth=20, reexecute=true, turnAlert=false, autoLimit=0, pauseUnfocused=true, bookmark='', smartSearch=true, smartMax=6}
local saved = env.__RoChessSettings
if not saved and type(readfile) == 'function' then
    local ok, data = pcall(function() return Http:JSONDecode(readfile(configPath)) end)
    if ok and type(data) == 'table' then saved = data end
end
saved = type(saved) == 'table' and saved or {}
for key, default in pairs(defaults) do
    local value = saved[key]
    if type(value) == type(default) then state[key] = value else state[key] = default end
end
for key, range in pairs({seconds={0.2,5}, delay={0.1,5}, depth={2,30}}) do
    local value = state[key]
    state[key] = value == value and math.clamp(value, range[1], range[2]) or defaults[key]
end
state.smartMax = math.clamp(state.smartMax == state.smartMax and state.smartMax or 6, 1, 12)
state.depth = math.floor(state.depth)
state.autoLimit = math.floor(math.clamp(state.autoLimit == state.autoLimit and state.autoLimit or 0, 0, 50))
state.autoMoves = 0
state.focused = true
state.startedAt = os.clock()
state.searches = 0
state.searchSeconds = 0
state.totalPlayed = 0
local persistenceError
local function saveSettings()
    local data = {}
    for key in pairs(defaults) do data[key] = state[key] end
    env.__RoChessSettings = data
    if type(writefile) == 'function' then
        local ok, err = pcall(function() writefile(configPath, Http:JSONEncode(data)) end)
        persistenceError = not ok and tostring(err) or nil
    else
        persistenceError = 'File saving unavailable; settings carry across queued hops only'
    end
    return data
end
local queueTeleport = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
env.RoChessAssistant = state
local window = Bracket:Window({Name='RoChess Assistant', Enabled=true, Color=Color3.fromRGB(90,180,255), Size=UDim2.fromOffset(520,530), Position=UDim2.new(0,25,0.5,-265)})
local mobileConnections = {}
local launcherGui
local function bind(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(mobileConnections, connection)
    return connection
end
local function touchTab(tab)
    if not mobile then return tab end
    for _, method in ipairs({'Label','Button','Toggle','Slider'}) do
        local original = tab[method]
        tab[method] = function(self, options)
            options.Side = 'Left'
            return original(self, options)
        end
    end
    tab.Slider = function(self, options)
        local value = options.Value
        local step = options.Precise == 0 and 1 or 0.1
        local display = self:Label({Text=options.Name..': '..tostring(value)..(options.Unit or '')})
        local function change(delta)
            value = math.clamp(math.round((value+delta)/step)*step, options.Min, options.Max)
            display:SetText(options.Name..': '..string.format(options.Precise == 0 and '%.0f' or '%.1f',value)..(options.Unit or ''))
            options.Callback(value)
        end
        self:Button({Name='-  '..options.Name, Callback=function() change(-step) end})
        self:Button({Name='+  '..options.Name, Callback=function() change(step) end})
        return display
    end
    return tab
end
local function setupMobile()
    if not mobile then return end
    local panel = screen:FindFirstChild('Window')
    if not panel then return end
    launcherGui = Instance.new('ScreenGui')
    launcherGui.Name = 'ChessMobileLauncher'
    launcherGui.ResetOnSpawn = false
    launcherGui.DisplayOrder = screen.DisplayOrder+10
    launcherGui.Parent = screen.Parent
    local button = Instance.new('TextButton')
    button.Name = 'ToggleAssistant'
    button.Size = UDim2.fromOffset(150,48)
    button.Position = UDim2.new(1,-162,0,8)
    button.BackgroundColor3 = Color3.fromRGB(27,45,66)
    button.TextColor3 = Color3.new(1,1,1)
    button.TextSize = 18
    button.Font = Enum.Font.GothamBold
    button.Parent = launcherGui
    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0,12)
    corner.Parent = button
    local function caption() button.Text = screen.Enabled and 'Close UI' or 'Open UI' end
    bind(button.Activated,function() screen.Enabled=not screen.Enabled; caption() end)
    bind(screen:GetPropertyChangedSignal('Enabled'),caption)
    caption()
    local function fit()
        local camera=workspace.CurrentCamera
        if not camera then return end
        local size=camera.ViewportSize
        panel.AnchorPoint=Vector2.new(0.5,0)
        panel.Position=UDim2.new(0.5,0,0,64)
        panel.Size=UDim2.fromOffset(math.min(430,math.max(240,size.X-24)),math.min(600,math.max(160,size.Y-120)))
    end
    for _, object in ipairs(panel:GetDescendants()) do
        if object.Name == 'RightSide' and object:IsA('GuiObject') then object.Visible=false end
        if object.Name == 'LeftSide' and object:IsA('GuiObject') then object.Size=UDim2.new(1,-12,object.Size.Y.Scale,object.Size.Y.Offset) end
        if object:IsA('TextLabel') or object:IsA('TextButton') or object:IsA('TextBox') then object.TextSize=16 end
        if object:IsA('GuiButton') then
            local constraint=Instance.new('UISizeConstraint')
            constraint.MinSize=Vector2.new(0,44)
            constraint.Parent=object
        end
        if object:IsA('ScrollingFrame') then object.ScrollingEnabled=true; object.ScrollBarThickness=6 end
        if object.Name=='Resize' or object.Name=='Drag' then if object:IsA('GuiObject') then object.Active=false end end
    end
    local tabs=panel:FindFirstChild('TabButtonContainer')
    local content=panel:FindFirstChild('TabContainer')
    if tabs and content then
        tabs.Size=UDim2.new(tabs.Size.X.Scale,tabs.Size.X.Offset,0,46)
        local top=tabs.Position.Y.Offset+48
        content.Position=UDim2.new(content.Position.X.Scale,content.Position.X.Offset,0,top)
        content.Size=UDim2.new(content.Size.X.Scale,content.Size.X.Offset,1,-top-6)
    end
    local cameraConnection
    local function watchCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then cameraConnection=bind(workspace.CurrentCamera:GetPropertyChangedSignal('ViewportSize'),fit) end
        fit()
    end
    bind(workspace:GetPropertyChangedSignal('CurrentCamera'),watchCamera)
    watchCamera()
end
local function cleanupMobile()
    for _, connection in ipairs(mobileConnections) do connection:Disconnect() end
    if launcherGui then launcherGui:Destroy() end
end
local main = touchTab(window:Tab({Name='Moves'}))
local settings = touchTab(window:Tab({Name='Settings'}))
local gameTab = touchTab(window:Tab({Name='Game'}))
local toolsTab = touchTab(window:Tab({Name='Tools'}))
local status = main:Label({Text='Waiting for a game', Side='Left'})
local moveLabel = main:Label({Text='Best move: --', Side='Left'})
local evalLabel = main:Label({Text='Your evaluation: --', Side='Left'})
local detail = main:Label({Text='Depth: --', Side='Left'})
local reasonLabel = main:Label({Text='Move details: --',Side='Left'})
local lineLabel = main:Label({Text='Continuation: not calculated',Side='Left'})
local function describeMove(san)
    local facts={}
    if san:find('O%-O%-O') then table.insert(facts,'Castles queenside')
    elseif san:find('O%-O') then table.insert(facts,'Castles kingside') end
    if san:find('x',1,true) then table.insert(facts,'Captures a piece or pawn') end
    local promotion=san:match('=([QRBN])')
    if promotion then table.insert(facts,'Promotes to '..({Q='queen',R='rook',B='bishop',N='knight'})[promotion]) end
    if san:find('#',1,true) then table.insert(facts,'Delivers checkmate')
    elseif san:find('+',1,true) then table.insert(facts,'Gives check') end
    if #facts==0 then return 'Quiet move; see continuation for the follow-up' end
    return table.concat(facts,' | ')
end
local function calculateLine(fen,firstMove,cancelled,seconds,depth)
    local position=Engine.new(fen)
    local ucis,sans={},{}
    for ply=1,3 do
        if cancelled() then return nil end
        local uci=firstMove
        if ply>1 then
            local result=Bot.analyse(position:getFen(),{},seconds,depth,{slice=0.005,cancelled=cancelled})
            uci=result.best
        end
        if cancelled() then return nil end
        if not uci then break end
        local move=position:moveFromUci(uci)
        if not move then break end
        table.insert(sans,position:moveToSan(move))
        table.insert(ucis,uci)
        position:playUci(uci)
    end
    return {sans=sans,ucis=ucis}
end

local function label(widget, text)
    pcall(function()
        if widget.SetText then widget:SetText(text) elseif widget.ChangeText then widget:ChangeText(text) end
    end)
end
local gameInfo = gameTab:Label({Text='No active game',Side='Left'})
local materialInfo = gameTab:Label({Text='Material: --',Side='Left'})
local checkInfo = gameTab:Label({Text='Check: --',Side='Left'})
local moveHistory = gameTab:Label({Text='Recent moves: --',Side='Left'})
local autoProgress = gameTab:Label({Text='Autoplay moves: 0',Side='Right'})
local function pgnText(session)
    local function escape(value)
        return tostring(value or ''):gsub('\\','\\\\'):gsub('"','\\"'):gsub('[\r\n]',' ')
    end
    local tags={'[Event "RoChess game"]','[White "'..escape(session.white and session.white.display or 'White')..'"]','[Black "'..escape(session.black and session.black.display or 'Black')..'"]','[Result "*"]'}
    if session.startFen then
        table.insert(tags,'[SetUp "1"]')
        table.insert(tags,'[FEN "'..escape(session.startFen)..'"]')
    end
    local side,number='w',1
    if session.startFen then
        local parts=string.split(session.startFen,' ')
        side=parts[2] or 'w';number=tonumber(parts[6]) or 1
    end
    local moves={}
    for i,san in ipairs(session.sans or {}) do
        if side=='w' then table.insert(moves,tostring(number)..'.')
        elseif i==1 then table.insert(moves,tostring(number)..'...') end
        table.insert(moves,san)
        if side=='b' then number+=1 end
        side=side=='w' and 'b' or 'w'
    end
    table.insert(moves,'*')
    return table.concat(tags,'\n')..'\n\n'..table.concat(moves,' ')
end
local function updateGameInfo()
    local session=App.session
    if not session or session.kind=='idle' then
        label(gameInfo,'No active game');label(materialInfo,'Material: --');label(checkInfo,'Check: --');label(moveHistory,'Recent moves: --');return
    end
    local color=session.myColor
    label(gameInfo,'Mode: '..tostring(session.kind)..' | You: '..(color==1 and 'White' or color==-1 and 'Black' or 'Spectator'))
    local values={1,3,3,5,9,0}
    local white,black=0,0
    for _,piece in ipairs(session.engine:boardArray()) do
        if piece>0 then white+=values[piece] or 0 elseif piece<0 then black+=values[-piece] or 0 end
    end
    label(materialInfo,string.format('Material W %d / B %d | Your balance: %+.0f',white,black,(white-black)*(color or 1)))
    label(checkInfo,session.engine:inCheck() and ((session.engine.side==1 and 'White' or 'Black')..' is in check') or 'No check')
    local recent={}
    for i=math.max(1,#session.sans-7),#session.sans do table.insert(recent,session.sans[i]) end
    label(moveHistory,'Recent moves: '..(#recent>0 and table.concat(recent,' ') or '--'))
    label(autoProgress,'Autoplay moves: '..state.autoMoves..(state.autoLimit>0 and (' / '..state.autoLimit) or ' (unlimited)'))
    local turnKey=tostring(session)..':'..session.engine:getFen()
    if state.turnAlert and not session.over and session.kind~='analysis' and session.myColor==session.engine.side and state.alertKey~=turnKey then
        state.alertKey=turnKey
        pcall(function() game:GetService('StarterGui'):SetCore('SendNotification',{Title='RoChess: your turn',Text='You are playing '..(color==1 and 'White' or 'Black'),Duration=4}) end)
    end
end
local function clearArrow()
    if App.board then pcall(function() App.board:setArrow('assistant', nil, nil) end) end
end
local function invalidate()
    state.revision += 1
    state.result = nil
    state.key = nil
    clearArrow()
    label(moveLabel, 'Best move: --')
    label(evalLabel, 'Your evaluation: --')
    label(detail, 'Depth: --')
    state.line=nil
    label(reasonLabel,'Move details: --')
    label(lineLabel,'Continuation: not calculated')
end
local autoToggle
local function autoOff()
    state.auto = false
    if autoToggle and autoToggle.Value ~= false then
        pcall(function()
            if autoToggle.SetValue then autoToggle:SetValue(false)
            elseif autoToggle.ChangeValue then autoToggle:ChangeValue(false) end
        end)
        autoToggle.Value = false
    end
    saveSettings()
end
function state.stop()
    cleanupMobile()
    saveSettings()
    state.alive = false
    state.auto = false
    state.revision += 1
    clearArrow()
    if state.connection then state.connection:Disconnect() end
    if state.teleportConnection then state.teleportConnection:Disconnect() end
    if state.teleportFailed then state.teleportFailed:Disconnect() end
    pcall(function() screen:Destroy() end)
end
local function snapshot()
    local s = App.session
    if not s or s.kind == 'idle' then return nil, 'Waiting for a game' end
    if s.over then return nil, 'Game finished' end
    if s.viewPly ~= #s.ucis then return nil, 'Viewing history; return to latest move' end
    if s.kind ~= 'online' and s.kind ~= 'bot' and s.kind ~= 'analysis' and s.kind ~= 'puzzle' and s.kind ~= 'rush' then
        return nil, 'Unsupported mode: '..tostring(s.kind)
    end
    return s, s.engine:getFen()
end
local function draw()
    clearArrow()
    local r = state.result
    if state.arrows and r and r.best and App.board then
        App.board:setArrow('assistant', Engine.algToIndex64(r.best:sub(1,2)), Engine.algToIndex64(r.best:sub(3,4)), Color3.fromRGB(90,220,130), 0.15)
    end
end
local function playerColor(s)
    if s.myColor == 1 or s.myColor == -1 then return s.myColor end
    if s.kind == 'analysis' then return s.engine.side end
    return nil
end
local function ownTurn(s)
    local color = playerColor(s)
    return color ~= nil and (s.kind == 'analysis' or s.engine.side == color)
end
local function play()
    if state.auto and state.pauseUnfocused and not state.focused then return false end
    local s, key = snapshot()
    local r = state.result
    if not s or not r or state.session ~= s or state.key ~= key then return false end
    if not ownTurn(s) then return false end
    if s.kind ~= 'analysis' and not s:isMyTurn() then return false end
    if not r.best or not s.engine:moveFromUci(r.best) then return false end
    if state.failedKey==key and state.failedSession==s and (state.failedAttempts or 0)>=3 then
        label(status,'Autoplay paused: move failed 3 times; press Recalculate');return false
    end
    if os.clock()<(state.retryAt or 0) then return false end
    if state.sentSession == s and state.sentKey == key then return false end
    state.sentSession, state.sentKey = s, key
    local promo = ({q=5,r=4,b=3,n=2})[r.best:sub(5,5)]
    local ok, accepted = pcall(App.onBoardMove, Engine.algToIndex64(r.best:sub(1,2)), Engine.algToIndex64(r.best:sub(3,4)), promo, false)
    local advanced=App.session==s and s.engine:getFen()~=key
    if (not ok or accepted==false) and not advanced then
        state.sentSession,state.sentKey=nil,nil
        if state.failedSession~=s or state.failedKey~=key then state.failedAttempts=0 end
        state.failedSession,state.failedKey=s,key
        state.failedAttempts=(state.failedAttempts or 0)+1
        state.retryAt=os.clock()+1.5
        state.lastError=ok and 'Move not accepted yet' or tostring(accepted)
        label(status,'Autoplay retry '..state.failedAttempts..'/3: '..state.lastError:sub(1,70))
        return false
    end
    state.failedAttempts=0
    state.failedKey=nil
    state.retryAt=nil
    state.lastError=nil
    state.totalPlayed += 1
    if state.auto then
        state.autoMoves += 1
        if state.autoLimit > 0 and state.autoMoves >= state.autoLimit then autoOff() end
    end
    invalidate()
    return true
end
main:Toggle({Name='Show suggestions', Side='Right', Value=state.hints, Callback=function(v) state.hints=v; saveSettings(); invalidate() end})
autoToggle = main:Toggle({Name='Autoplay (your turn)', Side='Right', Value=state.auto, Callback=function(v) state.auto=v; if v then state.autoMoves=0;state.failedAttempts=0;state.failedKey=nil;state.sentKey=nil;state.retryAt=nil end; saveSettings(); state.readyAt=os.clock()+state.delay end})
main:Toggle({Name='Move arrow', Side='Right', Value=state.arrows, Callback=function(v) state.arrows=v; saveSettings(); draw() end})
main:Button({Name='Play suggested move once', Side='Right', Callback=play})
main:Button({Name='Recalculate', Side='Right', Callback=function() state.sentKey=nil;state.failedAttempts=0;state.failedKey=nil;state.retryAt=nil;invalidate() end})
main:Button({Name='STOP autoplay [End]', Side='Right', Callback=autoOff})
settings:Toggle({Name='Adaptive thinking',Side='Left',Value=state.smartSearch,Callback=function(v) state.smartSearch=v;saveSettings();invalidate() end})
settings:Slider({Name='Adaptive maximum',Side='Left',Min=1,Max=12,Value=state.smartMax,Precise=1,Unit='s',Callback=function(v) state.smartMax=v;saveSettings();invalidate() end})
settings:Slider({Name='Think time', Side='Left', Min=0.2, Max=5, Value=state.seconds, Precise=1, Unit='s', Callback=function(v) state.seconds=v; saveSettings(); invalidate() end})
settings:Slider({Name='Maximum depth', Side='Left', Min=2, Max=30, Value=state.depth, Precise=0, Callback=function(v) state.depth=v; saveSettings(); invalidate() end})
settings:Slider({Name='Move delay', Side='Left', Min=0.1, Max=5, Value=state.delay, Precise=1, Unit='s', Callback=function(v) state.delay=v; saveSettings(); state.readyAt=os.clock()+v end})
settings:Toggle({Name='Re-execute after hop', Side='Right', Value=state.reexecute, Callback=function(v) state.reexecute=v; saveSettings() end})
local persistenceLabel = settings:Label({Text='', Side='Right'})
settings:Button({Name='Copy Discord invite', Side='Right', Callback=function()
    label(persistenceLabel, copyDiscordInvite())
end})
settings:Button({Name='Save settings now', Side='Right', Callback=function()
    saveSettings()
    label(persistenceLabel, persistenceError or 'Settings saved')
end})
settings:Button({Name='Flip board', Side='Right', Callback=function() App.flip() end})
settings:Button({Name='Copy current FEN', Side='Right', Callback=function()
    if App.session and setclipboard then setclipboard(App.session.engine:getFen()); label(status,'FEN copied') end
end})
settings:Button({Name='Copy suggested move', Side='Right', Callback=function()
    if state.result and state.result.best and setclipboard then setclipboard(state.result.best); label(status,'Move copied') end
end})
settings:Label({Text='RightShift: hide/show UI\nEnd: stop autoplay\nPositive evaluation favors your color\nUses RoChess local engine', Side='Right'})
settings:Button({Name='Unload assistant', Side='Right', Callback=state.stop})
gameTab:Button({Name='Return to latest move',Side='Right',Callback=function()
    autoOff()
    local session=App.session
    if session then session.viewPly=#session.ucis; App.render(); invalidate() end
end})
gameTab:Button({Name='Copy game as PGN',Side='Right',Callback=function()
    if not App.session or App.session.kind=='idle' then label(status,'Start a game first');return end
    if type(setclipboard)~='function' then label(status,'Clipboard unavailable');return end
    local ok=pcall(setclipboard,pgnText(App.session))
    label(status,ok and 'PGN copied (result unspecified)' or 'Could not copy PGN')
end})
gameTab:Button({Name='Save position snapshot',Side='Right',Callback=function()
    if not App.session or App.session.kind=='idle' then return end
    local data={fen=App.session.engine:getFen(),moves=table.clone(App.session.sans),color=App.session.myColor}
    local path='RoChess-position-'..tostring(os.time())..'.json'
    if type(writefile)~='function' then label(status,'File saving unavailable');return end
    local ok=pcall(writefile,path,Http:JSONEncode(data))
    label(status,ok and ('Saved '..path) or 'Position save failed')
end})
gameTab:Toggle({Name='Notify on your turn',Side='Right',Value=state.turnAlert,Callback=function(v) state.turnAlert=v;saveSettings() end})
gameTab:Slider({Name='Autoplay move limit (0 = unlimited)',Side='Right',Min=0,Max=50,Value=state.autoLimit,Precise=0,Callback=function(v) state.autoLimit=v;saveSettings() end})
gameTab:Button({Name='Reset autoplay counter',Side='Right',Callback=function() state.autoMoves=0;updateGameInfo() end})
state.exportPGN=pgnText
local toolStatus = toolsTab:Label({Text='Tools ready',Side='Left'})
local statistics = toolsTab:Label({Text='Statistics: --',Side='Left'})
local bookmarkLabel = toolsTab:Label({Text=state.bookmark~='' and 'Position bookmark saved' or 'No bookmark saved',Side='Left'})
local function copyText(text, message)
    if type(setclipboard)~='function' then label(toolStatus,'Clipboard unavailable');return false end
    local ok=pcall(setclipboard,text)
    label(toolStatus,ok and message or 'Clipboard failed')
    return ok
end
local function activeGame()
    local session=App.session
    if not session or session.kind=='idle' then label(toolStatus,'Start a game first');return nil end
    return session
end
local function gameReport(session)
    local color=session.myColor==1 and 'White' or session.myColor==-1 and 'Black' or 'Spectator'
    local lines={'RoChess game report','Mode: '..tostring(session.kind),'Your color: '..color,'Played plies: '..tostring(#(session.ucis or {})),'FEN: '..session.engine:getFen(),'Moves (UCI): '..table.concat(session.ucis or {},' ')}
    if state.session==session and state.key==session.engine:getFen() and state.result and state.result.best then
        table.insert(lines,'Suggested move: '..state.result.best)
        table.insert(lines,'Search depth: '..tostring(state.result.depth or 0))
    end
    return table.concat(lines,'\n')
end
toolsTab:Button({Name='Bookmark current position',Side='Right',Callback=function()
    local session=activeGame();if not session then return end
    state.bookmark=session.engine:getFen();saveSettings()
    label(bookmarkLabel,'Position bookmark saved');label(toolStatus,'Saved current FEN as your bookmark')
end})
toolsTab:Button({Name='Copy bookmarked FEN',Side='Right',Callback=function()
    if state.bookmark=='' then label(toolStatus,'No bookmark saved');return end
    copyText(state.bookmark,'Bookmarked FEN copied')
end})
toolsTab:Button({Name='Clear bookmark',Side='Right',Callback=function()
    state.bookmark='';saveSettings();label(bookmarkLabel,'No bookmark saved')
end})
toolsTab:Button({Name='Copy move list (UCI)',Side='Right',Callback=function()
    local session=activeGame();if session then copyText(table.concat(session.ucis or {},' '),'UCI move list copied') end
end})
toolsTab:Button({Name='Copy game report',Side='Right',Callback=function()
    local session=activeGame();if session then copyText(gameReport(session),'Game report copied') end
end})
toolsTab:Toggle({Name='Pause autoplay when unfocused',Side='Right',Value=state.pauseUnfocused,Callback=function(v) state.pauseUnfocused=v;saveSettings() end})
toolsTab:Button({Name='Reset session statistics',Side='Right',Callback=function()
    state.startedAt=os.clock();state.searches=0;state.searchSeconds=0;state.totalPlayed=0
end})
toolsTab:Button({Name='Hide UI',Side='Right',Callback=function() screen.Enabled=false end})
bind(UIS.WindowFocusReleased,function() state.focused=false end)
bind(UIS.WindowFocused,function() state.focused=true;state.readyAt=os.clock()+state.delay end)
local function updateStatistics()
    local elapsed=math.floor(os.clock()-state.startedAt)
    label(statistics,string.format('Session %d:%02d | Searches %d\nSearch time %.1fs | Moves played %d',math.floor(elapsed/60),elapsed%60,state.searches,state.searchSeconds,state.totalPlayed))
end
state.gameReport=gameReport
main:Button({Name='Show opponent reply + my response',Side='Right',Callback=function()
    if state.lineBusy then return end
    local session,fen=snapshot()
    if not session or not state.result or not state.result.best or state.session~=session or state.key~=fen then
        label(lineLabel,'Wait for a current suggestion first');return
    end
    local first=state.result.best
    local revision=state.revision
    state.lineBusy=true
    label(lineLabel,'Calculating likely replies...')
    task.spawn(function()
        local function cancelled()
            return not state.alive or state.revision~=revision or App.session~=session or session.engine:getFen()~=fen
        end
        local ok,result=pcall(calculateLine,fen,first,cancelled,math.min(state.seconds,2),state.depth)
        state.lineBusy=false
        if cancelled() then return end
        if not ok then label(lineLabel,'Continuation failed: '..tostring(result):sub(1,70));return end
        if not result or #result.sans==0 then label(lineLabel,'No continuation available');return end
        state.line=result
        local text={'You: '..result.sans[1]}
        if result.sans[2] then table.insert(text,'Opponent: '..result.sans[2]) end
        if result.sans[3] then table.insert(text,'You next: '..result.sans[3]) end
        label(lineLabel,table.concat(text,'\n'))
    end)
end})
main:Button({Name='Copy calculated continuation',Side='Right',Callback=function()
    if not state.line then label(lineLabel,'Calculate a continuation first');return end
    if type(setclipboard)=='function' then pcall(setclipboard,table.concat(state.line.sans,' ')..'\n'..table.concat(state.line.ucis,' ')) end
end})
state.calculateLine=calculateLine
state.describeMove=describeMove
setupMobile()
state.connection = UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.End then autoOff() end
    if processed or UIS:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        pcall(function() screen.Enabled = not screen.Enabled end)
    end
end)
local function searchBudget(session,now)
    local seconds=state.seconds
    local reason='Manual budget'
    if state.smartSearch then
        local pieces=0
        for _,piece in ipairs(session.engine:boardArray()) do if piece~=0 then pieces+=1 end end
        local legal=#session.engine:legalMoves()
        if legal==1 then seconds=0.15;reason='Only one legal move'
        elseif session.engine:inCheck() then seconds=math.max(seconds*2,3);reason='In check'
        elseif pieces<=12 then seconds=math.max(seconds*2.5,4);reason='Endgame'
        elseif legal>=30 then seconds=math.max(seconds*1.75,3);reason='Many candidate moves'
        else seconds=math.max(seconds,2);reason='Adaptive search' end
        seconds=math.min(seconds,state.smartMax)
    end
    local delay=state.delay
    local remaining
    if session.clocks and session.myColor and session.kind~='analysis' then
        remaining=session.clocks[session.myColor]
        if type(remaining)=='number' then
            remaining=remaining/1000
            if session.engine.side==session.myColor and (session.turnStart or 0)>0 then
                remaining-=math.max(0,now-session.turnStart)
            end
            remaining=math.max(0,remaining)
            delay=math.min(delay,math.max(0,remaining*0.02))
            local cap=math.max(0.05,math.min(remaining*0.08,remaining-delay-0.4))
            if cap<seconds then seconds=cap;reason='Clock-limited search' end
        end
    end
    return seconds,delay,reason,remaining
end
state.searchBudget=searchBudget
local function tick()
    updateStatistics()
    updateGameInfo()
    local s, key = snapshot()
    if state.observedSession ~= App.session then
        state.observedSession = App.session
        invalidate()
    end
    if not s then
        if state.key or state.result then invalidate() end
        label(status, key)
        return
    end
    if not state.hints and not state.auto then label(status,'Suggestions paused'); return end
    local color = playerColor(s)
    if not ownTurn(s) then
        if state.key or state.result then invalidate() end
        label(status, color and ('You are '..(color == 1 and 'White' or 'Black')..' | Waiting for opponent') or 'Waiting for your assigned color')
        return
    end
    if state.lineBusy then return end
    if state.session ~= s or state.key ~= key or state.color ~= color or not state.result then
        invalidate()
        state.session, state.key, state.color = s, key, color
        local revision = state.revision
        label(status, 'Analysing...')
        local thinkSeconds, moveDelay, searchReason = searchBudget(s,workspace:GetServerTimeNow())
        label(status,string.format('%s: %.2fs',searchReason,thinkSeconds))
        local searchStarted = os.clock()
        local result = Bot.analyse(s.startFen, table.clone(s.ucis), thinkSeconds, state.depth, {
            slice=0.005,
            cancelled=function()
                return not state.alive or state.revision ~= revision or App.session ~= s or s.engine:getFen() ~= key or playerColor(s) ~= color or not ownTurn(s)
            end,
        })
        if not state.alive or state.revision ~= revision or App.session ~= s or s.engine:getFen() ~= key or playerColor(s) ~= color or not ownTurn(s) then
            state.key = nil
            return
        end
        state.searches += 1
        state.searchSeconds += os.clock()-searchStarted
        state.result = result
        local _,latestDelay=searchBudget(s,workspace:GetServerTimeNow())
        state.readyAt = os.clock()+math.min(moveDelay,latestDelay)
        if not result.best then label(status, result.terminal or 'No legal move'); return end
        local m = s.engine:moveFromUci(result.best)
        local san = m and s.engine:moveToSan(m) or result.best
        label(moveLabel, 'Your best: '..san..' ('..result.best..')')
        label(reasonLabel,describeMove(san))
        local mate = result.mate and result.mate * color
        label(evalLabel, mate and ((mate > 0 and 'You mate in ' or 'Opponent mates in ')..tostring(math.abs(mate))) or string.format('Your evaluation: %+.2f', (result.score or 0)*color/100))
        label(detail, string.format('Depth %d | Nodes %d | %.2fs\n%s', result.depth or 0, result.nodes or 0,os.clock()-searchStarted,searchReason))
        draw()
        state.drawnAt = os.clock()
    end
    if state.result and state.result.best and os.clock() - (state.drawnAt or 0) >= 0.5 then
        draw()
        state.drawnAt = os.clock()
    end
    label(status, 'You are '..(color == 1 and 'White' or 'Black')..' | '..(state.auto and 'Autoplay enabled' or 'Your turn'))
    if state.auto and state.pauseUnfocused and not state.focused then
        label(status,'Autoplay paused: Roblox is unfocused')
    elseif state.auto and state.result and os.clock() >= (state.readyAt or math.huge) then play() end
end
state.tick = tick
state.play = play
state.observedSession = App.session
state.worker = task.spawn(function()
    while state.alive do
        local ok, err = pcall(tick)
        if not ok then
            state.lastError=tostring(err)
            state.retryAt=os.clock()+2
            state.key=nil
            label(status, 'Error: '..tostring(err):sub(1,100))
            warn('[RoChess Assistant] '..tostring(err))
            task.wait(2)
        end
        task.wait(0.15)
    end
end)
saveSettings()
label(persistenceLabel, persistenceError or (type(queueTeleport) == 'function' and 'Settings autosave | Hop resume ready' or 'Settings autosave | Teleport queue unavailable'))
local queued = false
state.teleportConnection = game:GetService('Players').LocalPlayer.OnTeleport:Connect(function(teleportState)
    if teleportState == Enum.TeleportState.Failed then queued=false; return end
    if not state.alive or not state.reexecute or queued then return end
    if type(queueTeleport) ~= 'function' or type(env.__RoChessSource) ~= 'string' then
        label(persistenceLabel, 'Hop resume unavailable in this executor')
        return
    end
    local data = saveSettings()
    local payload = 'local source='..string.format('%q', env.__RoChessSource)..';getgenv().__RoChessSource=source;getgenv().__RoChessSettings=game:GetService("HttpService"):JSONDecode('..string.format('%q', Http:JSONEncode(data))..');assert(loadstring(source))()'
    local ok, err = pcall(queueTeleport, payload)
    queued = ok
    if not ok then label(persistenceLabel, 'Hop queue failed: '..tostring(err)) end
end)
state.teleportFailed = game:GetService('TeleportService').TeleportInitFailed:Connect(function(player)
    if player == game:GetService('Players').LocalPlayer then queued=false end
end)
print('[RoChess Assistant] Loaded with saved settings. RightShift toggles UI; End stops autoplay.')

]]))()

-- https://leakd.fr
