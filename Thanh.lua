-- Thạnh V4.9 — iOS Full + Settings + Dynamic Island Music HUD (Disc=Saturn + Popup Theme rbxthumb + Rainbow HSV) (FIXED: YmpRequest bind + MP3 header gate)
local Players=game:GetService("Players");local TweenService=game:GetService("TweenService");local SoundService=game:GetService("SoundService")
local UserInputService=game:GetService("UserInputService");local Lighting=game:GetService("Lighting")
local StarterGui=game:GetService("StarterGui");local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace");local TeleportService=game:GetService("TeleportService")
local VirtualUser=game:GetService("VirtualUser");local HttpService=game:GetService("HttpService")
local GuiService=game:GetService("GuiService");local TextChatService=game:GetService("TextChatService")
local LocalPlayer=Players.LocalPlayer;local PlayerGui=LocalPlayer:WaitForChild("PlayerGui")
local Mouse=LocalPlayer:GetMouse();local Camera=Workspace.CurrentCamera
local http_request=request or http_request or (syn and syn.request)
local hasDrawing=(pcall(function() return Drawing.new end));local StartTime=tick()
local FONT=Enum.Font.Gotham;local FONTBOLD=Enum.Font.GothamBold
local CLR={bg=Color3.fromRGB(28,28,30),bg2=Color3.fromRGB(44,44,46),bg3=Color3.fromRGB(58,58,60),bg4=Color3.fromRGB(72,72,74),sep=Color3.fromRGB(56,56,58),text=Color3.fromRGB(255,255,255),text2=Color3.fromRGB(152,152,157),text3=Color3.fromRGB(99,99,102),blue=Color3.fromRGB(10,132,255),green=Color3.fromRGB(48,209,88),purple=Color3.fromRGB(191,90,242),pink=Color3.fromRGB(255,55,95),orange=Color3.fromRGB(255,159,10),red=Color3.fromRGB(255,69,58),white=Color3.fromRGB(255,255,255),black=Color3.fromRGB(0,0,0)}
local FONT_MAP={Gotham=Enum.Font.Gotham,GothamBold=Enum.Font.GothamBold,Arial=Enum.Font.Arial,SourceSans=Enum.Font.SourceSans,Roboto=Enum.Font.Roboto,Code=Enum.Font.Code,Bangers=Enum.Font.Bangers,Fantasy=Enum.Font.Fantasy,Antique=Enum.Font.Antique,SciFi=Enum.Font.SciFi}
local FONT_ORDER={"Gotham","GothamBold","Arial","SourceSans","Roboto","Code","Bangers","Fantasy","Antique","SciFi"}
local Theme={textSize=13,textColorHex="FFFFFF",fontName="Gotham",bgImageId="",bgTransparency=0.04,borderEnabled=true,borderColorHex="FFFFFF",borderThickness=0.8,cornerRadius=28,saturnImageId="rbxassetid://130980521832226",saturnSize=64,musicDiscImageId="rbxassetid://130980521832226",musicThemeImageId="rbxthumb://type=Asset&id=127717372459962&w=420&h=420",saturnLocked=false,musicBgColorHex="08080A",musicTextColorHex="FFFFFF",musicProgColorHex="7D87FF",musicBtnColorHex="6973FF",musicTransparency=0.04,uiScale=1.0,buttonSpacing=8,uiTransparency=0.04,uiPosX=0.5,uiPosY=0.5,fpsColorHex="30D158",fpsSize=14,fpsVisible=true,animationsEnabled=true}
local CONFIG_FILE="ThanhSettings.json"
local function hexToColor(hex)hex=tostring(hex or "FFFFFF"):gsub("#","");return Color3.fromRGB(tonumber(hex:sub(1,2),16) or 255,tonumber(hex:sub(3,4),16) or 255,tonumber(hex:sub(5,6),16) or 255)end
local function normalizeImageId(v)v=tostring(v or ""):gsub("%s","");if v=="" then return "" end;if v:find("^rbxthumb://") or v:find("^rbxassetid://") or v:find("^https?://") then return v end;if tonumber(v) then return "rbxassetid://"..v end;return v end
local function loadConfig()if not (isfile and readfile) then return end;pcall(function()if isfile(CONFIG_FILE) then local d=HttpService:JSONDecode(readfile(CONFIG_FILE));if type(d)=="table" then for k,v in pairs(d) do if Theme[k]~=nil then Theme[k]=v end end end end end)end
local function saveConfig()if not writefile then return false end;return pcall(function()writefile(CONFIG_FILE,HttpService:JSONEncode(Theme))end)end
loadConfig()
local Refs={toggleLabels={},sectionLabels={},addLabelLabels={},mainStroke=nil,mainCorner=nil,fpsLabel=nil,musicHud=nil,musicTitle=nil,musicArtist=nil,musicTime=nil,musicProgFill=nil,musicProgBg=nil,musicBtns={},musicCompactTitle=nil,saturnLockBtn=nil,musicDiscImg=nil,musicBigDiscImg=nil,musicThemeImg=nil}
local function mk(class,parent,props)local o=Instance.new(class);if props then for k,v in pairs(props) do o[k]=v end end;o.Parent=parent;return o end
local function corner(p,r)local rad=(typeof(r)=="UDim") and r or UDim.new(0,r);return mk("UICorner",p,{CornerRadius=rad})end
local function stroke(p,col,th,tr)return mk("UIStroke",p,{Color=col or CLR.white,Thickness=th or 1,Transparency=tr or 0.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})end
local dummyTween={Play=function()end,Pause=function()end,Cancel=function()end,Completed={Wait=function()end,Connect=function()end}}
local function spring(obj,props,dur,style)if not Theme.animationsEnabled then for k,v in pairs(props) do pcall(function()obj[k]=v end)end;return dummyTween end;return TweenService:Create(obj,TweenInfo.new(dur or 0.4,style or Enum.EasingStyle.Back,Enum.EasingDirection.Out),props)end
local function withBlur(name,size)local b=Lighting:FindFirstChild(name);if b then spring(b,{Size=size},0.3,Enum.EasingStyle.Quad):Play();return b end;b=mk("BlurEffect",Lighting,{Name=name,Size=0});spring(b,{Size=size},0.3,Enum.EasingStyle.Quad):Play();return b end
local Character,Humanoid,HumanoidRootPart;local originalTransparency={};local originalParts={}
local espTargetPlayers={};local aimbotTargetPlayers={};local tpSelected=nil
local DexLoaded,F3XLoaded=false,false;local floatBV=nil
local tabFrames,tabButtons={},{};local allToggles,togglesById={},{}
local Hooks={};local lockSaturn=Theme.saturnLocked
local SaturnState={moved=false};local SaturnBaseSize=Theme.saturnSize
local origLighting={Brightness=Lighting.Brightness,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,ColorShift_Top=Lighting.ColorShift_Top,ColorShift_Bottom=Lighting.ColorShift_Bottom,GlobalShadows=Lighting.GlobalShadows,FogEnd=Lighting.FogEnd}
pcall(function()for _,obj in ipairs(PlayerGui:GetChildren()) do if obj:IsA("ScreenGui") and (obj.Name:find("Thanh") or obj.Name=="MyAwesomeGUI_V2" or obj.Name=="ThanhV6_iOS") then obj:Destroy() end end;for _,eff in ipairs(Lighting:GetChildren()) do if eff:IsA("BlurEffect") and (eff.Name=="V2ProBlur" or eff.Name=="V6Blur") then eff:Destroy() end end end)
local ScreenGui=mk("ScreenGui",PlayerGui,{Name="ThanhV6_iOS",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true})
local blur=mk("BlurEffect",Lighting,{Name="V6Blur",Size=0})
local notificationsEnabled=true
local function Notify(text)if not notificationsEnabled then return end;pcall(function()StarterGui:SetCore("SendNotification",{Title="Thạnh V4.9",Text=tostring(text),Duration=2})end)end
local toastCount=0
local function Toast(text,icon)if not notificationsEnabled then return end;toastCount=toastCount+1;local idx=toastCount;local baseY=12+((idx-1)%5)*58
local wrap=mk("Frame",ScreenGui,{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,-60),Size=UDim2.new(0,290,0,46),BackgroundColor3=CLR.black,BackgroundTransparency=0.08,BorderSizePixel=0,ZIndex=2000})
corner(wrap,23);stroke(wrap,CLR.white,0.8,0.85)
local iconBox=mk("Frame",wrap,{Size=UDim2.new(0,34,0,34),Position=UDim2.new(0,6,0.5,-17),BackgroundColor3=CLR.bg3,BorderSizePixel=0,ZIndex=2002})
corner(iconBox,UDim.new(1,0))
mk("TextLabel",iconBox,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=tostring(icon or "*"),TextColor3=CLR.blue,Font=FONTBOLD,TextSize=16,ZIndex=2003})
mk("TextLabel",wrap,{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,48,0,0),BackgroundTransparency=1,Text=tostring(text),TextColor3=CLR.text,Font=FONTBOLD,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=2002})
local scale=mk("UIScale",wrap,{Scale=0})
spring(wrap,{Position=UDim2.new(0.5,0,0,baseY)},0.5):Play();spring(scale,{Scale=1},0.55):Play()
task.delay(2.2,function()spring(wrap,{Position=UDim2.new(0.5,0,0,-60)},0.35,Enum.EasingStyle.Quad):Play();spring(scale,{Scale=0},0.35,Enum.EasingStyle.Quad):Play();task.wait(0.4);wrap:Destroy();toastCount=math.max(0,toastCount-1)end)end
local iOS={}
function iOS.Alert(opts)opts=opts or {}
local backdrop=mk("Frame",ScreenGui,{Size=UDim2.new(1,0,1,0),BackgroundColor3=CLR.black,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1500})
local alert=mk("Frame",backdrop,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,280,0,200),BackgroundColor3=CLR.bg2,BackgroundTransparency=0.03,BorderSizePixel=0,ZIndex=1502,ClipsDescendants=true})
corner(alert,20);stroke(alert,CLR.white,0.8,0.88)
local contentScale=mk("UIScale",alert,{Scale=0.7})
local buttons=opts.buttons or {{text="OK",style="default"}};local btnH=44;local padTop=20
local titleH=(opts.title and opts.title~="") and 26 or 0;local msgH=60
local totalH=padTop+titleH+msgH+12+#buttons*btnH;alert.Size=UDim2.new(0,280,0,totalH)
local yCur=padTop
if titleH>0 then mk("TextLabel",alert,{Size=UDim2.new(1,-32,0,titleH),Position=UDim2.new(0,16,0,yCur),BackgroundTransparency=1,Text=tostring(opts.title),TextColor3=CLR.text,Font=FONTBOLD,TextSize=16,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=1503});yCur=yCur+titleH end
mk("TextLabel",alert,{Size=UDim2.new(1,-32,0,msgH),Position=UDim2.new(0,16,0,yCur),BackgroundTransparency=1,Text=tostring(opts.message or ""),TextColor3=CLR.text2,Font=FONT,TextSize=13,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Center,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=1503})
local btnStartY=totalH-#buttons*btnH
mk("Frame",alert,{Size=UDim2.new(1,0,0,0.5),Position=UDim2.new(0,0,0,btnStartY),BackgroundColor3=CLR.sep,BorderSizePixel=0,ZIndex=1503})
for i,b in ipairs(buttons) do local rowY=btnStartY+(i-1)*btnH
if i>1 then mk("Frame",alert,{Size=UDim2.new(1,0,0,0.5),Position=UDim2.new(0,0,0,rowY),BackgroundColor3=CLR.sep,BorderSizePixel=0,ZIndex=1503})end
local col=CLR.blue;if b.style=="destructive" then col=CLR.red end;if b.style=="cancel" then col=CLR.blue end
local btn=mk("TextButton",alert,{Size=UDim2.new(1,0,0,btnH),Position=UDim2.new(0,0,0,rowY),BackgroundColor3=CLR.bg2,BackgroundTransparency=1,BorderSizePixel=0,Text=tostring(b.text or "OK"),TextColor3=col,Font=(b.style=="cancel") and FONT or FONTBOLD,TextSize=15,ZIndex=1504,AutoButtonColor=false})
btn.MouseButton1Down:Connect(function()btn.BackgroundTransparency=0.85 end);btn.MouseButton1Up:Connect(function()btn.BackgroundTransparency=1 end)
btn.MouseButton1Click:Connect(function()pcall(function()if b.onClick then b.onClick() end end);spring(contentScale,{Scale=0.85},0.2,Enum.EasingStyle.Quad):Play();spring(backdrop,{BackgroundTransparency=1},0.25,Enum.EasingStyle.Quad):Play();task.wait(0.28);backdrop:Destroy()end)end
withBlur("V6Blur",22);spring(backdrop,{BackgroundTransparency=0.5},0.3,Enum.EasingStyle.Quad):Play();spring(contentScale,{Scale=1},0.5):Play();return backdrop end
function iOS.Confirm(opts)opts=opts or {};return iOS.Alert({title=opts.title or "Thông báo",message=opts.message or "",buttons={{text=opts.noText or "Không",style="cancel",onClick=opts.onNo},{text=opts.yesText or "Có",style=opts.destructive and "destructive" or "default",onClick=opts.onYes}}})end
function iOS.ActionSheet(opts)opts=opts or {}
local backdrop=mk("Frame",ScreenGui,{Size=UDim2.new(1,0,1,0),BackgroundColor3=CLR.black,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=1500})
local buttons=opts.buttons or {};local rowH=48;local sheetH=20+(opts.title and 30 or 0)+#buttons*rowH+70
local sheet=mk("Frame",backdrop,{AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.5,0,1,sheetH+20),Size=UDim2.new(0,340,0,sheetH),BackgroundColor3=CLR.bg2,BorderSizePixel=0,ZIndex=1502,ClipsDescendants=true})
corner(sheet,22);stroke(sheet,CLR.white,0.8,0.88)
local y=10
if opts.title then mk("TextLabel",sheet,{Size=UDim2.new(1,-32,0,24),Position=UDim2.new(0,16,0,y),BackgroundTransparency=1,Text=tostring(opts.title),TextColor3=CLR.text2,Font=FONT,TextSize=12,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=1503});y=y+30 end
for i,b in ipairs(buttons) do local rowY=y+(i-1)*rowH
if i>1 then mk("Frame",sheet,{Size=UDim2.new(1,-32,0,0.5),Position=UDim2.new(0,16,0,rowY),BackgroundColor3=CLR.sep,BorderSizePixel=0,ZIndex=1503})end
local btn=mk("TextButton",sheet,{Size=UDim2.new(1,-32,0,rowH),Position=UDim2.new(0,16,0,rowY),BackgroundColor3=CLR.bg2,BackgroundTransparency=1,BorderSizePixel=0,Text=tostring(b.text or ""),TextColor3=(b.style=="destructive") and CLR.red or CLR.text,Font=FONT,TextSize=15,ZIndex=1504,AutoButtonColor=false})
btn.MouseButton1Down:Connect(function()btn.BackgroundTransparency=0.85 end);btn.MouseButton1Up:Connect(function()btn.BackgroundTransparency=1 end)
btn.MouseButton1Click:Connect(function()pcall(function()if b.onClick then b.onClick() end end);spring(sheet,{Position=UDim2.new(0.5,0,1,sheetH+20)},0.25,Enum.EasingStyle.Quad):Play();spring(backdrop,{BackgroundTransparency=1},0.25,Enum.EasingStyle.Quad):Play();task.wait(0.28);backdrop:Destroy()end)end
local cancelY=y+#buttons*rowH+10
local cancel=mk("TextButton",sheet,{Size=UDim2.new(1,-32,0,rowH),Position=UDim2.new(0,16,0,cancelY),BackgroundColor3=CLR.bg3,BorderSizePixel=0,Text=opts.cancelText or "Hủy",TextColor3=CLR.blue,Font=FONTBOLD,TextSize=15,ZIndex=1504,AutoButtonColor=false})
corner(cancel,14)
cancel.MouseButton1Click:Connect(function()spring(sheet,{Position=UDim2.new(0.5,0,1,sheetH+20)},0.25,Enum.EasingStyle.Quad):Play();spring(backdrop,{BackgroundTransparency=1},0.25,Enum.EasingStyle.Quad):Play();task.wait(0.28);backdrop:Destroy()end)
withBlur("V6Blur",22);spring(backdrop,{BackgroundTransparency=0.5},0.3,Enum.EasingStyle.Quad):Play();spring(sheet,{Position=UDim2.new(0.5,0,1,0)},0.55):Play();return backdrop end
_G.iOS=iOS
local Frame=mk("Frame",ScreenGui,{Name="V6Menu",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(Theme.uiPosX,0,Theme.uiPosY,0),Size=UDim2.new(0,500,0,420),BackgroundColor3=CLR.bg,BackgroundTransparency=Theme.uiTransparency,BorderSizePixel=0,ClipsDescendants=true,Visible=false,Active=true,ZIndex=100})
Refs.mainCorner=corner(Frame,Theme.cornerRadius)
Refs.mainStroke=stroke(Frame,hexToColor(Theme.borderColorHex),Theme.borderThickness,0.82);Refs.mainStroke.Enabled=Theme.borderEnabled
local uiScaleObj=mk("UIScale",Frame,{Scale=Theme.uiScale})
local topBar=mk("Frame",Frame,{AnchorPoint=Vector2.new(0,0),Position=UDim2.new(0,10,0,10),Size=UDim2.new(0,40,0,5),BackgroundColor3=CLR.white,BackgroundTransparency=0.7,BorderSizePixel=0,ZIndex=102})
corner(topBar,UDim.new(1,0))
local titleLabel=mk("TextLabel",Frame,{Position=UDim2.new(0,24,0,24),Size=UDim2.new(0,260,0,34),ZIndex=102,BackgroundTransparency=1,Text="Thạnh V4.9",TextColor3=hexToColor(Theme.textColorHex),TextSize=Theme.textSize+7,Font=FONT_MAP[Theme.fontName] or FONTBOLD,TextXAlignment=Enum.TextXAlignment.Left})
local saturnLockBtn=mk("TextButton",Frame,{Position=UDim2.new(1,-82,0,22),Size=UDim2.new(0,34,0,28),ZIndex=103,BackgroundColor3=CLR.bg3,Text=Theme.saturnLocked and "Mở" or "Khóa",TextColor3=CLR.text,Font=FONTBOLD,TextSize=10,AutoButtonColor=false})
corner(saturnLockBtn,8);Refs.saturnLockBtn=saturnLockBtn
local Close=mk("TextButton",Frame,{Position=UDim2.new(1,-46,0,22),Size=UDim2.new(0,28,0,28),ZIndex=103,BackgroundColor3=CLR.red,Text="",AutoButtonColor=false})
corner(Close,UDim.new(1,0))
mk("TextLabel",Close,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="x",TextColor3=CLR.white,Font=FONTBOLD,TextSize=13,ZIndex=104})
saturnLockBtn.MouseButton1Click:Connect(function()Theme.saturnLocked=not Theme.saturnLocked;lockSaturn=Theme.saturnLocked;saturnLockBtn.Text=Theme.saturnLocked and "Mở" or "Khóa";Toast("Saturn "..(Theme.saturnLocked and "đã khóa" or "đã mở khóa"),Theme.saturnLocked and "L" or "U")end)
do local dragToggle,dragInput,dragStartPos,startPos=false,nil,nil,nil
titleLabel.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragToggle=true;dragStartPos=input.Position;startPos=Frame.Position;input.Changed:Connect(function()if input.UserInputState==Enum.UserInputState.End then dragToggle=false end end)end end)
titleLabel.InputChanged:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then dragInput=input end end)
UserInputService.InputChanged:Connect(function(input)if input==dragInput and dragToggle then local delta=input.Position-dragStartPos;Frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y);Theme.uiPosX=Frame.Position.X.Scale;Theme.uiPosY=Frame.Position.Y.Scale end end)end
local tabOrder={"main","esp","aimbot","tp","follow","admin","exploits","gamehubs","server","tools","music","player","utilities","settings"}
local tabDisplay={main="Chính",esp="ESP",aimbot="Aimbot",tp="TP",follow="Bám",admin="Admin",exploits="Exploits",gamehubs="Game Hubs",server="Server",tools="Công cụ",music="Nhạc",player="Nhân vật",utilities="Tiện ích",settings="Cài đặt"}
local TabScroll=mk("ScrollingFrame",Frame,{Size=UDim2.new(0,138,0,330),Position=UDim2.new(0,12,0,66),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,#tabOrder*42+12),ScrollingEnabled=true,Active=true,ZIndex=102})
for i,name in ipairs(tabOrder) do local btn=mk("TextButton",TabScroll,{Size=UDim2.new(1,-10,0,36),Position=UDim2.new(0,5,0,(i-1)*42+4),ZIndex=102,BackgroundColor3=CLR.bg2,BackgroundTransparency=0.35,Text="  "..tabDisplay[name],TextColor3=hexToColor(Theme.textColorHex),TextSize=math.max(Theme.textSize,11),Font=FONT_MAP[Theme.fontName] or FONT,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false});corner(btn,14);tabButtons[name]=btn end
local Content=mk("Frame",Frame,{Position=UDim2.new(0,158,0,66),Size=UDim2.new(0,330,0,340),ZIndex=102,BackgroundColor3=CLR.bg2,BackgroundTransparency=0.4,ClipsDescendants=true})
corner(Content,22)
local ContentScroll=mk("ScrollingFrame",Content,{Size=UDim2.new(1,-16,1,-16),Position=UDim2.new(0,8,0,8),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=CLR.text3,CanvasSize=UDim2.new(0,0,0,0),ScrollingEnabled=true,Active=true,AutomaticCanvasSize=Enum.AutomaticSize.None,ZIndex=103})
local activeTabName=nil
local function createTab(name)local tab=mk("Frame",ContentScroll,{Name=name.."_Tab",Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,Visible=false,ZIndex=104})
local layout=mk("UIListLayout",tab,{Padding=UDim.new(0,Theme.buttonSpacing),SortOrder=Enum.SortOrder.LayoutOrder})
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()local h=layout.AbsoluteContentSize.Y+12;tab.Size=UDim2.new(1,0,0,h);if activeTabName==name and tab.Visible then ContentScroll.CanvasSize=UDim2.new(0,0,0,h+16) end end)
tabFrames[name]=tab;return tab end
for _,name in ipairs(tabOrder) do createTab(name) end
local function selectTab(active)for name,btn in pairs(tabButtons) do if name==active then spring(btn,{BackgroundTransparency=0,BackgroundColor3=CLR.blue},0.25,Enum.EasingStyle.Quad):Play() else spring(btn,{BackgroundTransparency=0.35,BackgroundColor3=CLR.bg2},0.25,Enum.EasingStyle.Quad):Play() end end;activeTabName=active;for tabName,fr in pairs(tabFrames) do fr.Visible=(tabName==active) end;ContentScroll.CanvasPosition=Vector2.new(0,0);local sel=tabFrames[active];if sel then task.defer(function()if activeTabName==active and sel.Parent==ContentScroll then ContentScroll.CanvasSize=UDim2.new(0,0,0,sel.AbsoluteSize.Y+16);ContentScroll.CanvasPosition=Vector2.new(0,0) end end)end end
for name,btn in pairs(tabButtons) do btn.MouseButton1Click:Connect(function()selectTab(name)end)end
selectTab("main")
local function addToggle(tab,text,get,set,id)local row=mk("Frame",tab,{Size=UDim2.new(1,0,0,48),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,ZIndex=105});corner(row,14)
local lbl=mk("TextLabel",row,{Size=UDim2.new(1,-82,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,Text=text,TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=106});table.insert(Refs.toggleLabels,lbl)
local on0=get() and true or false
local track=mk("TextButton",row,{Size=UDim2.new(0,46,0,28),Position=UDim2.new(1,-60,0.5,-14),BackgroundColor3=on0 and CLR.green or CLR.bg4,BorderSizePixel=0,Text="",ZIndex=107,AutoButtonColor=false});corner(track,UDim.new(1,0))
local knob=mk("Frame",track,{Size=UDim2.new(0,24,0,24),Position=on0 and UDim2.new(1,-26,0.5,-12) or UDim2.new(0,2,0.5,-12),BackgroundColor3=CLR.white,BorderSizePixel=0,ZIndex=108});corner(knob,UDim.new(1,0))
mk("UIStroke",knob,{Color=CLR.black,Thickness=0.5,Transparency=0.85})
local function refresh()local s=get() and true or false;spring(track,{BackgroundColor3=s and CLR.green or CLR.bg4},0.25,Enum.EasingStyle.Quad):Play();spring(knob,{Position=s and UDim2.new(1,-26,0.5,-12) or UDim2.new(0,2,0.5,-12)},0.35):Play()end
track.MouseButton1Click:Connect(function()set(not get());refresh();local s=get() and true or false;Toast(text..(s and " BẬT" or " TẮT"),s and "+" or "-")end)
local entry={get=get,set=set,refresh=refresh,default=on0,text=text};table.insert(allToggles,entry);if id then togglesById[id]=entry end;return entry end
local function addButton(tab,text,callback)local btn=mk("TextButton",tab,{Size=UDim2.new(1,0,0,44),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,Text="  "..text,TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=105});corner(btn,14)
btn.MouseButton1Down:Connect(function()btn.BackgroundTransparency=0.6 end);btn.MouseButton1Up:Connect(function()btn.BackgroundTransparency=0.25 end)
if callback then btn.MouseButton1Click:Connect(function()task.spawn(function()local ok,err=pcall(callback);if not ok then warn("[V6] "..tostring(err));Toast("Lỗi: "..tostring(text),"x") end end)end)end;return btn end
local function addInputField(tab,placeholder,callback,isNumeric)local box=mk("TextBox",tab,{Size=UDim2.new(1,0,0,44),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText=placeholder,PlaceholderColor3=CLR.text3,Text="",TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,ZIndex=105});corner(box,14)
if callback then box.FocusLost:Connect(function()if isNumeric then local v=tonumber(box.Text);if v then callback(v) end elseif box.Text~="" then callback(box.Text) end end)end;return box end
local function addInput(tab,ph,cb)return addInputField(tab,ph,cb,true)end
local function addTextInput(tab,ph,cb)return addInputField(tab,ph,cb,false)end
local function addSection(tab,title)local lbl=mk("TextLabel",tab,{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text="  "..title,TextColor3=CLR.blue,Font=FONT_MAP[Theme.fontName] or FONTBOLD,TextSize=math.max(Theme.textSize-1,10),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=105});table.insert(Refs.sectionLabels,lbl);return lbl end
local function addLabel(tab,text,height)local lbl=mk("TextLabel",tab,{Size=UDim2.new(1,0,0,height or 24),BackgroundTransparency=1,Text=text,TextColor3=CLR.text2,Font=FONT_MAP[Theme.fontName] or FONT,TextSize=math.max(Theme.textSize-1,10),TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,ZIndex=105});table.insert(Refs.addLabelLabels,lbl);return lbl end
local function createPlayerSelector(parent,label,callback,multi)
local container=mk("Frame",parent,{Size=UDim2.new(1,0,0,110),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,ZIndex=105});corner(container,14)
mk("TextLabel",container,{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,10,0,4),BackgroundTransparency=1,Text=label,TextColor3=CLR.blue,Font=FONTBOLD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=106})
local selectedLabel=mk("TextLabel",container,{Size=UDim2.new(1,-20,0,14),Position=UDim2.new(0,10,0,22),BackgroundTransparency=1,Text="chưa chọn",TextColor3=CLR.text2,Font=FONT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=106})
local scroll=mk("ScrollingFrame",container,{Size=UDim2.new(1,-20,0,55),Position=UDim2.new(0,10,0,42),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=106,ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0)})
local holder=mk("Frame",scroll,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1})
mk("UIGridLayout",holder,{CellSize=UDim2.new(0,65,0,22),CellPadding=UDim2.new(0,4,0,4)})
local selected,buttons={},{}
local function paint()for _,b in ipairs(buttons) do local on=table.find(selected,b.Text)~=nil;b.BackgroundColor3=on and CLR.blue or CLR.bg4 end;selectedLabel.Text=(#selected==0) and "chưa chọn" or ("đã chọn: "..table.concat(selected,", "))end
local function refresh()for _,c in ipairs(holder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end;buttons={}
local names={};for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(names,p.Name) end end;table.sort(names)
local keep={};for _,n in ipairs(selected) do if table.find(names,n) then table.insert(keep,n) end end;selected=keep
for _,name in ipairs(names) do local btn=mk("TextButton",holder,{Size=UDim2.new(0,65,0,22),BackgroundColor3=CLR.bg4,BorderSizePixel=0,Text=name,TextColor3=CLR.text,Font=FONT,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=107,AutoButtonColor=false});corner(btn,6)
btn.MouseButton1Click:Connect(function()if multi then local idx=table.find(selected,name);if idx then table.remove(selected,idx) else table.insert(selected,name) end;paint();if callback then callback(selected) end else if selected[1]==name then selected={};paint();if callback then callback(nil) end else selected={name};paint();if callback then callback(name) end end end end)
table.insert(buttons,btn)end
paint();local rows=math.max(1,math.ceil(#names/4));local h=rows*26+4;holder.Size=UDim2.new(1,0,0,h);scroll.CanvasSize=UDim2.new(0,0,0,h+8)end
refresh()
Players.PlayerAdded:Connect(function()task.delay(0.2,refresh)end)
Players.PlayerRemoving:Connect(function()task.delay(0.3,refresh)end)
local function setSelection(names)selected={};for _,n in ipairs(names or {}) do table.insert(selected,n) end;paint()end
return container,setSelection,refresh end
local function createModeSelector(parent,labelText,options,callback)
local container=mk("Frame",parent,{Size=UDim2.new(1,0,0,74),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,ZIndex=105});corner(container,14)
mk("TextLabel",container,{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,10,0,4),BackgroundTransparency=1,Text=labelText,TextColor3=CLR.blue,Font=FONTBOLD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=106})
local holder=mk("Frame",container,{Size=UDim2.new(1,-20,0,48),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,ZIndex=106})
mk("UIGridLayout",holder,{CellSize=UDim2.new(0,66,0,22),CellPadding=UDim2.new(0,4,0,4)})
local selectedValue=nil;local optButtons={}
local function paint()for _,ob in ipairs(optButtons) do ob.btn.BackgroundColor3=(ob.value==selectedValue) and CLR.blue or CLR.bg4 end end
for _,opt in ipairs(options) do local btn=mk("TextButton",holder,{Size=UDim2.new(0,66,0,22),BackgroundColor3=CLR.bg4,BorderSizePixel=0,Text=opt.display or opt.value,TextColor3=CLR.text,Font=FONT,TextSize=11,ZIndex=107,AutoButtonColor=false});corner(btn,6)
btn.MouseButton1Click:Connect(function()if selectedValue==opt.value then selectedValue=nil;paint();callback(nil) else selectedValue=opt.value;paint();callback(opt.value) end end)
table.insert(optButtons,{btn=btn,value=opt.value})end
local function setMode(v)selectedValue=v;paint()end
return container,setMode end
local function runScript(name,url)task.spawn(function()local ok,err=pcall(function()loadstring(game:HttpGet(url))()end);if ok then Toast("Đã chạy: "..name,"+") else warn("[V6] "..name..": "..tostring(err));Toast("Lỗi tải script: "..name,"x") end end)end
local function addScriptButtons(tab,list)for _,v in ipairs(list) do addButton(tab,v[1],function()runScript(v[1],v[2])end)end end
local Saturn=mk("ImageButton",ScreenGui,{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(0,Theme.saturnSize,0,Theme.saturnSize),ZIndex=50,BackgroundColor3=Color3.fromRGB(28,32,44),Image=Theme.saturnImageId,AutoButtonColor=false});corner(Saturn,UDim.new(1,0));stroke(Saturn,CLR.blue,2,0.2)
do task.spawn(function()while Saturn and Saturn.Parent do RunService.Heartbeat:Wait();local s=1+math.sin(tick()*2)*0.06;local size=SaturnBaseSize*s;Saturn.Size=UDim2.new(0,size,0,size) end end)
local dragging,dragStart,startPos=false,nil,nil
Saturn.InputBegan:Connect(function(input)if lockSaturn then return end;if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=true;SaturnState.moved=false;dragStart=input.Position;startPos=Saturn.Position end end)
UserInputService.InputChanged:Connect(function(input)if lockSaturn then dragging=false;return end;if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then local delta=input.Position-dragStart;if delta.Magnitude>6 then SaturnState.moved=true end;Saturn.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end)
UserInputService.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end end)end
local fpsLabel=mk("TextLabel",ScreenGui,{Name="FPSLabel",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.42,0),Size=UDim2.new(0,120,0,26),BackgroundTransparency=1,Text="FPS: 0",TextColor3=hexToColor(Theme.fpsColorHex),Font=FONTBOLD,TextSize=Theme.fpsSize,TextXAlignment=Enum.TextXAlignment.Center,Visible=Theme.fpsVisible,ZIndex=999});Refs.fpsLabel=fpsLabel
mk("TextLabel",ScreenGui,{Size=UDim2.new(0,280,0,20),Position=UDim2.new(1,-10,1,-10),AnchorPoint=Vector2.new(1,1),BackgroundTransparency=1,Text="Script bởi @phuoc.thanh1409 - V4.9",TextColor3=CLR.text2,Font=FONT,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,TextYAlignment=Enum.TextYAlignment.Bottom,ZIndex=999})
task.spawn(function()local frames,last=0,tick();while ScreenGui and ScreenGui.Parent do RunService.RenderStepped:Wait();frames=frames+1;local now=tick();if now-last>=1 then fpsLabel.Text="FPS: "..frames;frames=0;last=now end end end)
local function applyText()local color=hexToColor(Theme.textColorHex);local font=FONT_MAP[Theme.fontName] or FONT
for _,lbl in ipairs(Refs.toggleLabels) do lbl.TextColor3=color;lbl.Font=font;lbl.TextSize=Theme.textSize end
for _,lbl in ipairs(Refs.sectionLabels) do lbl.Font=font;lbl.TextSize=math.max(Theme.textSize-1,10) end
for _,lbl in ipairs(Refs.addLabelLabels) do lbl.TextColor3=color;lbl.Font=font;lbl.TextSize=math.max(Theme.textSize-1,10) end
for _,btn in pairs(tabButtons) do btn.TextColor3=color;btn.Font=font;btn.TextSize=math.max(Theme.textSize,11) end
if titleLabel then titleLabel.TextColor3=color;titleLabel.Font=FONT_MAP[Theme.fontName] or FONTBOLD;titleLabel.TextSize=math.max(Theme.textSize+7,18) end end
local function applyTextAll()
    applyText()
    local font=FONT_MAP[Theme.fontName] or FONT
    local color=hexToColor(Theme.textColorHex)
    for _,obj in ipairs(ContentScroll:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.Font=font
            obj.TextSize=Theme.textSize
            obj.TextColor3=color
        end
    end
end
local function applyTheme()Frame.BackgroundTransparency=Theme.uiTransparency;if Theme.bgImageId~="" then local img=Frame:FindFirstChild("ThemeBgImage");if not img then img=mk("ImageLabel",Frame,{Name="ThemeBgImage",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Crop,ZIndex=101});corner(img,Theme.cornerRadius)end;img.Image=Theme.bgImageId;img.ImageTransparency=0.15 end end
local function applyBorder()if Refs.mainStroke then Refs.mainStroke.Enabled=Theme.borderEnabled;Refs.mainStroke.Color=hexToColor(Theme.borderColorHex);Refs.mainStroke.Thickness=Theme.borderThickness end;if Refs.mainCorner then Refs.mainCorner.CornerRadius=UDim.new(0,Theme.cornerRadius) end end
local function applyLayout()if uiScaleObj then uiScaleObj.Scale=Theme.uiScale end;Frame.Position=UDim2.new(Theme.uiPosX,0,Theme.uiPosY,0);for _,tab in pairs(tabFrames) do local layout=tab:FindFirstChildOfClass("UIListLayout");if layout then layout.Padding=UDim.new(0,Theme.buttonSpacing) end end end
local function applyFPS()if Refs.fpsLabel then Refs.fpsLabel.Visible=Theme.fpsVisible;Refs.fpsLabel.TextColor3=hexToColor(Theme.fpsColorHex);Refs.fpsLabel.TextSize=Theme.fpsSize end end
local function applySaturn()if Saturn then Saturn.Image=Theme.saturnImageId;SaturnBaseSize=Theme.saturnSize;Saturn.Size=UDim2.new(0,Theme.saturnSize,0,Theme.saturnSize);lockSaturn=Theme.saturnLocked;if Refs.saturnLockBtn then Refs.saturnLockBtn.Text=Theme.saturnLocked and "Mở" or "Khóa" end end end
local function applyMusic()if not Refs.musicHud then return end;Refs.musicHud.BackgroundColor3=hexToColor(Theme.musicBgColorHex);Refs.musicHud.BackgroundTransparency=Theme.musicTransparency;if Refs.musicTitle then Refs.musicTitle.TextColor3=hexToColor(Theme.musicTextColorHex) end;if Refs.musicCompactTitle then Refs.musicCompactTitle.TextColor3=hexToColor(Theme.musicTextColorHex) end;if Refs.musicArtist then Refs.musicArtist.TextColor3=hexToColor(Theme.musicTextColorHex) end;if Refs.musicTime then Refs.musicTime.TextColor3=hexToColor(Theme.musicTextColorHex) end;if Refs.musicProgFill then Refs.musicProgFill.BackgroundColor3=hexToColor(Theme.musicProgColorHex) end;for _,btn in ipairs(Refs.musicBtns) do pcall(function()btn.BackgroundColor3=hexToColor(Theme.musicBtnColorHex)end)end;if Refs.musicThemeImg then local tid=Theme.musicThemeImageId or "";Refs.musicThemeImg.Image=tid;Refs.musicThemeImg.Visible=(tid~="") end;if Refs.musicDiscImg then Refs.musicDiscImg.Image=Theme.musicDiscImageId or Theme.saturnImageId end;if Refs.musicBigDiscImg then Refs.musicBigDiscImg.Image=Theme.musicDiscImageId or Theme.saturnImageId end end
local MusicHUD=mk("Frame",ScreenGui,{Name="MusicHUD",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,14),Size=UDim2.new(0,260,0,48),BackgroundColor3=hexToColor(Theme.musicBgColorHex),BackgroundTransparency=Theme.musicTransparency,BorderSizePixel=0,ZIndex=300,Visible=false,Active=true,ClipsDescendants=true});corner(MusicHUD,24);stroke(MusicHUD,CLR.white,0.8,0.85);Refs.musicHud=MusicHUD;local musicThemeImg=mk("ImageLabel",MusicHUD,{Name="MusicThemeImage",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image=Theme.musicThemeImageId or "",ScaleType=Enum.ScaleType.Crop,ZIndex=301,ImageTransparency=0.18});corner(musicThemeImg,24);Refs.musicThemeImg=musicThemeImg;musicThemeImg.Visible=(Theme.musicThemeImageId~="" and Theme.musicThemeImageId~=nil)
local HUD_COLLAPSED=UDim2.new(0,260,0,48);local HUD_EXPANDED=UDim2.new(0,360,0,218);local hudExpanded=false;local hudPaused=false

local musicShineClip=mk("Frame",MusicHUD,{Name="MusicShineClip",Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=true,ZIndex=399,Active=false})
corner(musicShineClip,UDim.new(1,0))
local musicShineRotator=mk("Frame",musicShineClip,{Name="MusicShineRotator",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.new(2,0,3,0),Rotation=20,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=399})
local musicShine=mk("Frame",musicShineRotator,{Name="MusicShine",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(-0.2,0,0,0),Size=UDim2.new(0.07,0,1,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.65,BorderSizePixel=0,Rotation=0,ZIndex=399})
corner(musicShine,UDim.new(0,100))
local musicShineGradient=mk("UIGradient",musicShine,{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)})})
local musicShine2=mk("Frame",musicShineRotator,{Name="MusicShine2",AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(-0.3,0,0,0),Size=UDim2.new(0.03,0,1,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.75,BorderSizePixel=0,Rotation=0,ZIndex=399})
corner(musicShine2,UDim.new(0,100))
local musicShine2Gradient=mk("UIGradient",musicShine2,{Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)})})
task.spawn(function()
    while musicShineClip and musicShineClip.Parent do
        task.wait(math.random(3,6))
        musicShine.Position=UDim2.new(-0.2,0,0,0)
        musicShine2.Position=UDim2.new(-0.3,0,0,0)
        local sweepInfo=TweenInfo.new(0.9,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
        local t1=TweenService:Create(musicShine,sweepInfo,{Position=UDim2.new(1.2,0,0,0)})
        local t2=TweenService:Create(musicShine2,sweepInfo,{Position=UDim2.new(1.2,0,0,0)})
        t1:Play();t2:Play();t1.Completed:Wait()
    end
end)
local compactDot=mk("Frame",MusicHUD,{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,8,0.5,-18),BackgroundColor3=Color3.fromRGB(20,20,26),BorderSizePixel=0,ZIndex=302});corner(compactDot,10)
local disc=mk("ImageLabel",compactDot,{Name="MusicDisc",Size=UDim2.new(1,-6,1,-6),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Image=Theme.musicDiscImageId or Theme.saturnImageId,ScaleType=Enum.ScaleType.Crop,ZIndex=303});corner(disc,UDim.new(1,0));Refs.musicDiscImg=disc
local compactThumb=mk("ImageLabel",compactDot,{Name="TrackThumbnail",Size=UDim2.new(1,-6,1,-6),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Crop,ZIndex=304});corner(compactThumb,UDim.new(1,0));compactThumb.Visible=false
task.spawn(function()while disc and disc.Parent do local dt=RunService.Heartbeat:Wait();if disc and disc.Parent then disc.Rotation=(disc.Rotation+dt*90)%360 end end end)
local eqBox=mk("Frame",MusicHUD,{Size=UDim2.new(0,18,0,14),Position=UDim2.new(1,-60,0.5,-7),BackgroundTransparency=1,ZIndex=303})
local eqBars={};for i=1,3 do local b=mk("Frame",eqBox,{Size=UDim2.new(0,3,0,4),Position=UDim2.new(0,(i-1)*5,1,-4),BackgroundColor3=hexToColor(Theme.musicProgColorHex),BorderSizePixel=0,ZIndex=304});corner(b,UDim.new(1,0));table.insert(eqBars,b);task.spawn(function()while b and b.Parent do TweenService:Create(b,TweenInfo.new(0.4+i*0.13,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true,0),{Size=UDim2.new(0,3,0,14),Position=UDim2.new(0,(i-1)*5,0,0)}):Play();task.wait(0.8+i*0.26)end end)end
local compactTitle=mk("TextLabel",MusicHUD,{Name="CompactTitle",Size=UDim2.new(1,-110,1,0),Position=UDim2.new(0,52,0,0),BackgroundTransparency=1,Text="Đang phát",TextColor3=hexToColor(Theme.musicTextColorHex),Font=FONTBOLD,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=302});Refs.musicCompactTitle=compactTitle
local expandBtn=mk("TextButton",MusicHUD,{Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-36,0.5,-15),BackgroundColor3=Color3.fromRGB(35,35,42),BorderSizePixel=0,Text=">",TextColor3=hexToColor(Theme.musicTextColorHex),Font=FONTBOLD,TextSize=18,ZIndex=304,AutoButtonColor=false});corner(expandBtn,UDim.new(1,0))
local expandedLabel=mk("TextLabel",MusicHUD,{Size=UDim2.new(0,200,0,14),Position=UDim2.new(0.5,-100,0,12),BackgroundTransparency=1,Text="ĐANG PHÁT",TextColor3=hexToColor(Theme.musicTextColorHex),Font=FONTBOLD,TextSize=10,TextTransparency=0.35,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=305,Visible=false})
local bigArt=mk("Frame",MusicHUD,{Size=UDim2.new(0,72,0,72),Position=UDim2.new(0,18,0,36),BackgroundColor3=hexToColor(Theme.musicProgColorHex),BackgroundTransparency=0.4,BorderSizePixel=0,ZIndex=305,Visible=false});corner(bigArt,16);stroke(bigArt,hexToColor(Theme.musicProgColorHex),1.5,0.4)
local bigDisc=mk("ImageLabel",bigArt,{Name="MusicBigDisc",Size=UDim2.new(1,-14,1,-14),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Image=Theme.musicDiscImageId or Theme.saturnImageId,ScaleType=Enum.ScaleType.Crop,ZIndex=306});corner(bigDisc,UDim.new(1,0));Refs.musicBigDiscImg=bigDisc
local expandedThumb=mk("ImageLabel",bigArt,{Name="TrackThumbnail",Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Crop,ZIndex=308});corner(expandedThumb,14);expandedThumb.Visible=false
task.spawn(function()while bigDisc and bigDisc.Parent do local dt=RunService.Heartbeat:Wait();if bigDisc and bigDisc.Parent then bigDisc.Rotation=(bigDisc.Rotation+dt*60)%360 end end end)
local musicTitle=mk("TextLabel",MusicHUD,{Size=UDim2.new(1,-116,0,24),Position=UDim2.new(0,102,0,40),BackgroundTransparency=1,Text="",TextColor3=hexToColor(Theme.musicTextColorHex),Font=FONTBOLD,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=305,Visible=false});Refs.musicTitle=musicTitle
local musicArtist=mk("TextLabel",MusicHUD,{Size=UDim2.new(1,-116,0,16),Position=UDim2.new(0,102,0,66),BackgroundTransparency=1,Text="",TextColor3=hexToColor(Theme.musicTextColorHex),Font=FONT,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=0.35,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=305,Visible=false});Refs.musicArtist=musicArtist
local musicProgBg=mk("TextButton",MusicHUD,{Size=UDim2.new(1,-36,0,6),Position=UDim2.new(0,18,0,122),BackgroundColor3=Color3.fromRGB(55,55,65),BackgroundTransparency=0.3,BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=305,Visible=false});corner(musicProgBg,UDim.new(1,0));Refs.musicProgBg=musicProgBg
local musicProgFill=mk("Frame",musicProgBg,{Size=UDim2.new(0,0,1,0),BackgroundColor3=hexToColor(Theme.musicProgColorHex),BorderSizePixel=0,ZIndex=306});corner(musicProgFill,UDim.new(1,0));Refs.musicProgFill=musicProgFill
local progKnob=mk("Frame",musicProgBg,{Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,-6,0.5,-6),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=307,Visible=false});corner(progKnob,UDim.new(1,0))
musicProgFill:GetPropertyChangedSignal("Size"):Connect(function()progKnob.Position=UDim2.new(0,musicProgFill.AbsoluteSize.X-6,0.5,-6)end)
local musicTime=mk("TextLabel",MusicHUD,{Size=UDim2.new(1,-36,0,14),Position=UDim2.new(0,18,0,132),BackgroundTransparency=1,Text="0:00 / 0:00",TextColor3=hexToColor(Theme.musicTextColorHex),Font=FONT,TextSize=10,TextTransparency=0.4,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=305,Visible=false});Refs.musicTime=musicTime
local hudCtrlY=158
local function circleBtn(size,x,glyph,fs)local b=mk("TextButton",MusicHUD,{Size=UDim2.new(0,size,0,size),Position=UDim2.new(0,x,0,hudCtrlY+(52-size)/2),BackgroundColor3=Color3.fromRGB(45,45,55),BackgroundTransparency=0.15,BorderSizePixel=0,Text=glyph,TextColor3=hexToColor(Theme.musicTextColorHex),Font=FONTBOLD,TextSize=fs or 14,AutoButtonColor=false,ZIndex=306,Visible=false});corner(b,UDim.new(1,0));return b end
local hudBack10Btn=circleBtn(40,24,"-10s",11);table.insert(Refs.musicBtns,hudBack10Btn)
local hudPlayBtn=mk("TextButton",MusicHUD,{Size=UDim2.new(0,52,0,52),Position=UDim2.new(0,154,0,hudCtrlY),BackgroundColor3=hexToColor(Theme.musicBtnColorHex),BorderSizePixel=0,Text="Play",TextColor3=Color3.fromRGB(255,255,255),Font=FONTBOLD,TextSize=12,AutoButtonColor=false,ZIndex=307,Visible=false});corner(hudPlayBtn,UDim.new(1,0));stroke(hudPlayBtn,hexToColor(Theme.musicBtnColorHex),1,0.3);table.insert(Refs.musicBtns,hudPlayBtn)
local hudFwd10Btn=circleBtn(40,248,"+10s",11);table.insert(Refs.musicBtns,hudFwd10Btn)
local hudQueueBtn=circleBtn(36,300,"DS",12);table.insert(Refs.musicBtns,hudQueueBtn)

local function setMusicThumbnail(url)
    local imageId = ""
    if type(url) == "string" and url ~= "" then
        if url:match("^rbxassetid://") or url:match("^rbxthumb://") or url:match("^https?://") then
            imageId = url
        end
    end
    compactThumb.Image = imageId
    expandedThumb.Image = imageId
    local showThumb = (imageId ~= "" and _G.ShowThumbnail ~= false and _G.ShowThumbnail ~= nil)
    if _G.ShowThumbnail == nil then showThumb = false end
    compactThumb.Visible = showThumb
    expandedThumb.Visible = showThumb
    disc.Visible = not showThumb
    bigDisc.Visible = not showThumb
    compactThumb.ZIndex = 304
    expandedThumb.ZIndex = 308
end

local function setHudExpanded(expand)hudExpanded=expand;MusicHUD:TweenSize(expand and HUD_EXPANDED or HUD_COLLAPSED,Enum.EasingDirection.Out,Enum.EasingStyle.Back,0.35,true);corner(MusicHUD,expand and 28 or 24);if musicThemeImg then corner(musicThemeImg,expand and 28 or 24) end;corner(musicShineClip,UDim.new(1,0));compactDot.Visible=not expand;eqBox.Visible=not expand;compactTitle.Visible=not expand;expandBtn.Text=expand and "v" or ">";expandedLabel.Visible=expand;bigArt.Visible=expand;musicTitle.Visible=expand;musicArtist.Visible=expand;musicProgBg.Visible=expand;progKnob.Visible=expand;musicTime.Visible=expand;hudBack10Btn.Visible=expand;hudPlayBtn.Visible=expand;hudFwd10Btn.Visible=expand;hudQueueBtn.Visible=expand end
expandBtn.MouseButton1Click:Connect(function()setHudExpanded(not hudExpanded)end)
compactTitle.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then setHudExpanded(true) end end)
compactDot.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then setHudExpanded(true) end end)
musicProgBg.InputBegan:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then local snd=_G.ThanhSound;if snd and (snd.TimeLength or 0)>0 then local x=math.clamp((input.Position.X-musicProgBg.AbsolutePosition.X)/math.max(musicProgBg.AbsoluteSize.X,1),0,1);pcall(function()snd.TimePosition=x*snd.TimeLength end) end end end)
Hooks.setHudExpanded=setHudExpanded;Hooks.hudHide=function()MusicHUD.Visible=false end;Hooks.musicHud=MusicHUD
applyText();applyTheme();applyBorder();applyLayout();applyFPS();applySaturn()
-- _G state
_G.Invisible=false;_G.InfiniteJump=false;_G.NoClip=false;_G.Aimbot=false;_G.Aimbot2=false;_G.ESP=false;_G.ESPStud=false;_G.ESPHealth=false;_G.ESPName=false
_G.FullbrightEnabled=false;_G.XRayEnabled=false;_G.SpinEnabled=false;_G.SpinSpeed=1;_G.ZoomEnabled=false;_G.ZoomLevel=1
_G.EnableSpeed=true;_G.EnableJump=true;_G.EnableGravity=true;_G.WalkSpeed=16;_G.JumpPower=50;_G.Gravity=Workspace.Gravity
_G.originalWalkSpeed=16;_G.originalJumpPower=50;_G.originalGravity=Workspace.Gravity;_G.AntiAFK=true
_G.GhostVisual=false;_G.NoFog=false;_G.AntiFling=false;_G.ClickTP=false;_G.AnchorChar=false;_G.FloatChar=false;_G.RainbowChar=false
_G.AimbotWallCheck=false;_G.AimbotTeamCheck=false;_G.ShowThumbnail=true;_G.ShowMusicHUD=true
_G.FollowPlayer=false;_G.FollowMode="Behind";_G.FollowDistance=5;_G.TargetPlayer="None";_G.FollowTP=false;_G.FollowSpeed=5
_G.OrbitActive=false;_G.OrbitTarget=nil;_G.OrbitAngle=0;_G.OrbitDistance=10;_G.OrbitSpeed=1
_G.WallClimb=false;_G.AntiRagdoll=false;_G.NoSit=false;_G.NoBatidao=false
_G.Bhop=false;_G.HitboxExpander=false;_G.HitboxSize=10;_G.ShowHitbox=false
_G.AirWalk=false;_G.AntiVoid=false;_G.AlwaysDay=false;_G.ChatSpam=false;_G.SpamText="Thạnh V4.9";_G.AntiPaused=false
-- TAB CHÍNH
local mainTab=tabFrames["main"];addSection(mainTab,"Chính")
addButton(mainTab,"Bay (Fly GUI)",function()runScript("Fly GUI","https://raw.githubusercontent.com/linhmcfake/Script/refs/heads/main/FLYGUIV4")end)
addToggle(mainTab,"Tàng hình",function()return _G.Invisible end,function(v)_G.Invisible=v;for k,t in pairs(originalTransparency) do if k and k.Parent then k.Transparency=v and 1 or t end end end,"invisible")
addToggle(mainTab,"Xuyên tường",function()return _G.NoClip end,function(v)_G.NoClip=v;if Character then for _,part in pairs(Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=not v end end end end,"noclip")
addToggle(mainTab,"Fullbright",function()return _G.FullbrightEnabled end,function(v)_G.FullbrightEnabled=v;if v then Lighting.Brightness=2;Lighting.Ambient=Color3.new(1,1,1);Lighting.OutdoorAmbient=Color3.new(1,1,1);Lighting.GlobalShadows=false else Lighting.Brightness=origLighting.Brightness;Lighting.Ambient=origLighting.Ambient;Lighting.OutdoorAmbient=origLighting.OutdoorAmbient;Lighting.GlobalShadows=origLighting.GlobalShadows end end,"fullbright")
addToggle(mainTab,"X-Ray",function()return _G.XRayEnabled end,function(v)_G.XRayEnabled=v;if v then for _,part in pairs(Workspace:GetDescendants()) do if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then originalParts[part]={part.Transparency,part.Material};part.Transparency=0.5;part.Material=Enum.Material.ForceField end end else for part,props in pairs(originalParts) do if part and part.Parent then part.Transparency=props[1];part.Material=props[2] end end;originalParts={} end end,"xray")
addToggle(mainTab,"Spin",function()return _G.SpinEnabled end,function(v)_G.SpinEnabled=v end,"spin")
addInput(mainTab,"Tốc độ spin",function(v)_G.SpinSpeed=v end)
addToggle(mainTab,"Ghost Visual",function()return _G.GhostVisual end,function(v)_G.GhostVisual=v;if LocalPlayer.Character then for _,part in pairs(LocalPlayer.Character:GetDescendants()) do if (part:IsA("BasePart") and part.Name~="HumanoidRootPart") or part:IsA("Decal") then part.Transparency=v and 0.6 or 0 end end end end,"ghost")
addToggle(mainTab,"No Fog",function()return _G.NoFog end,function(v)_G.NoFog=v;Lighting.FogEnd=v and 100000 or origLighting.FogEnd end,"nofog")
addToggle(mainTab,"Zoom",function()return _G.ZoomEnabled end,function(v)_G.ZoomEnabled=v;if not v and Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=70 end end,"zoom")
addInput(mainTab,"Mức zoom",function(v)_G.ZoomLevel=math.max(0.1,v)end)
addSection(mainTab,"Di chuyển")
addToggle(mainTab,"Bật Speed",function()return _G.EnableSpeed end,function(v)_G.EnableSpeed=v;if not v and Humanoid then Humanoid.WalkSpeed=_G.originalWalkSpeed end end,"enablespeed")
addInput(mainTab,"Tốc độ chạy (16)",function(v)_G.WalkSpeed=v;if _G.EnableSpeed and Humanoid then Humanoid.WalkSpeed=v end end)
addToggle(mainTab,"Bật Jump",function()return _G.EnableJump end,function(v)_G.EnableJump=v;if not v and Humanoid then Humanoid.JumpPower=_G.originalJumpPower end end,"enablejump")
addInput(mainTab,"Sức nhảy (50)",function(v)_G.JumpPower=v;if _G.EnableJump and Humanoid then Humanoid.JumpPower=v end end)
addToggle(mainTab,"Bật Gravity",function()return _G.EnableGravity end,function(v)_G.EnableGravity=v;if not v then Workspace.Gravity=_G.originalGravity end end,"enablegravity")
addInput(mainTab,"Trọng lực",function(v)_G.Gravity=v;if _G.EnableGravity then Workspace.Gravity=v end end)
addToggle(mainTab,"Nhảy vô hạn",function()return _G.InfiniteJump end,function(v)_G.InfiniteJump=v end,"infjump")
-- ESP
local espModes={{Name="Highlight",Mode="Highlight",Line=false,Team=false},{Name="Box",Mode="Box",Line=false,Team=false},{Name="Highlight + Line",Mode="Highlight",Line=true,Team=false},{Name="Box + Line",Mode="Box",Line=true,Team=false},{Name="Highlight + Team",Mode="Highlight",Line=false,Team=true},{Name="Box + Team",Mode="Box",Line=true,Team=true},{Name="Highlight + Line + Team",Mode="Highlight",Line=true,Team=true},{Name="Box + Line + Team",Mode="Box",Line=true,Team=true}}
local espModeIndex=2
local function randomPlayer()local list={};for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(list,p) end end;if #list==0 then return nil end;return list[math.random(1,#list)]end
local espTab=tabFrames["esp"];addSection(espTab,"ESP")
addToggle(espTab,"ESP",function()return _G.ESP end,function(v)_G.ESP=v end,"esp")
addToggle(espTab,"Hiển thị Stud",function()return _G.ESPStud end,function(v)_G.ESPStud=v end,"espstud")
addToggle(espTab,"Hiển thị Tên",function()return _G.ESPName end,function(v)_G.ESPName=v end,"espname")
addToggle(espTab,"Hiển thị Máu",function()return _G.ESPHealth end,function(v)_G.ESPHealth=v end,"esphealth")
local espModeBtn;espModeBtn=addButton(espTab,"Chế độ ESP: "..espModes[espModeIndex].Name,function()espModeIndex=espModeIndex%#espModes+1;espModeBtn.Text="  Chế độ ESP: "..espModes[espModeIndex].Name;Toast("Chế độ ESP: "..espModes[espModeIndex].Name,"~")end)
local _,espSetSel=createPlayerSelector(espTab,"TARGET ESP (chọn nhiều, trống = tất cả)",function(names)espTargetPlayers={};if names then for _,name in ipairs(names) do local target=Players:FindFirstChild(name);if target then table.insert(espTargetPlayers,target) end end end end,true)
addButton(espTab,"Random Target ESP",function()local p=randomPlayer();if p then espTargetPlayers={p};espSetSel({p.Name});Toast("ESP target: "..p.Name,"?") else Toast("Không có người chơi khác","!") end end)
addButton(espTab,"Xóa Target ESP",function()espTargetPlayers={};espSetSel({});Toast("ESP: tất cả người chơi","x")end)
-- AIMBOT
local aimbotTab=tabFrames["aimbot"];addSection(aimbotTab,"Aimbot")
addToggle(aimbotTab,"Aimbot (xoay người)",function()return _G.Aimbot end,function(v)_G.Aimbot=v end,"aimbot")
addToggle(aimbotTab,"Aimbot (camera)",function()return _G.Aimbot2 end,function(v)_G.Aimbot2=v end,"aimbot2")
addToggle(aimbotTab,"Wall Check",function()return _G.AimbotWallCheck end,function(v)_G.AimbotWallCheck=v end,"wallcheck")
addToggle(aimbotTab,"Team Check",function()return _G.AimbotTeamCheck end,function(v)_G.AimbotTeamCheck=v end,"teamcheck")
local _,aimSetSel=createPlayerSelector(aimbotTab,"TARGET AIMBOT (chọn nhiều, trống = gần nhất)",function(names)aimbotTargetPlayers={};if names then for _,name in ipairs(names) do local target=Players:FindFirstChild(name);if target then table.insert(aimbotTargetPlayers,target) end end end end,true)
addButton(aimbotTab,"Random Target Aimbot",function()local p=randomPlayer();if p then aimbotTargetPlayers={p};aimSetSel({p.Name});Toast("Aimbot target: "..p.Name,"?") else Toast("Không có người chơi khác","!") end end)
addButton(aimbotTab,"Xóa Target Aimbot",function()aimbotTargetPlayers={};aimSetSel({});Toast("Aimbot: người gần nhất","x")end)
-- TP
local tpTab=tabFrames["tp"];addSection(tpTab,"Dịch chuyển")
createPlayerSelector(tpTab,"CHỌN NGƯỜI CHƠI",function(name)tpSelected=name end,false)
local function getTpTarget()if not tpSelected then Toast("Chọn người chơi trước","!");return nil end;local target=Players:FindFirstChild(tpSelected);if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and HumanoidRootPart then return target end;Toast("Không tìm thấy người chơi","!");return nil end
addButton(tpTab,"TP Đến",function()local t=getTpTarget();if t then HumanoidRootPart.CFrame=t.Character.HumanoidRootPart.CFrame;Toast("TP tới "..tpSelected,">") end end)
addButton(tpTab,"TP Dưới Đất",function()local t=getTpTarget();if t then local pos=t.Character.HumanoidRootPart.Position;local ray=Ray.new(pos+Vector3.new(0,50,0),Vector3.new(0,-100,0));local _,hitPos=Workspace:FindPartOnRay(ray,t.Character);if hitPos then HumanoidRootPart.CFrame=CFrame.new(hitPos+Vector3.new(0,3,0)) end end end)
addButton(tpTab,"TP Trước Mặt",function()local t=getTpTarget();if t then local cf=t.Character.HumanoidRootPart.CFrame;HumanoidRootPart.CFrame=CFrame.new(cf.Position+cf.LookVector*5,cf.Position) end end)
addButton(tpTab,"TP Phía Sau",function()local t=getTpTarget();if t then local cf=t.Character.HumanoidRootPart.CFrame;HumanoidRootPart.CFrame=CFrame.new(cf.Position-cf.LookVector*5,cf.Position) end end)
addButton(tpTab,"Theo dõi (Spectate)",function()if not tpSelected then Toast("Chọn người chơi trước","!");return end;local target=Players:FindFirstChild(tpSelected);local cam=Workspace.CurrentCamera;if target and target.Character and target.Character:FindFirstChild("Humanoid") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then cam.CameraSubject=(cam.CameraSubject==target.Character.Humanoid) and LocalPlayer.Character.Humanoid or target.Character.Humanoid end end)
-- BÁM
local followTab=tabFrames["follow"];addSection(followTab,"Bám")
addToggle(followTab,"Tự động bám",function()return _G.FollowPlayer end,function(v)_G.FollowPlayer=v end,"follow")
local startOrbit
local followSelector,followSetSel,followRefresh=createPlayerSelector(followTab,"NGƯỜI CHƠI MỤC TIÊU",function(name)_G.TargetPlayer=name or "None";if _G.FollowMode=="Orbit Target" and name then startOrbit() end end,false)
addButton(followTab,"Làm mới danh sách",function()followRefresh();Toast("Đã làm mới","~")end)
local orbitBox=mk("Frame",followTab,{Size=UDim2.new(1,0,0,84),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,ZIndex=105});corner(orbitBox,14)
mk("TextLabel",orbitBox,{Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,10,0,4),BackgroundTransparency=1,Text="CÀI ĐẶT ORBIT (chọn mode Orbit)",TextColor3=CLR.blue,Font=FONTBOLD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=106})
local distLabel=mk("TextLabel",orbitBox,{Size=UDim2.new(0.5,0,0,24),Position=UDim2.new(0,10,0,26),BackgroundTransparency=1,Text="Khoảng cách: 10",TextColor3=CLR.text2,Font=FONT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=106})
local distInput=mk("TextBox",orbitBox,{Size=UDim2.new(0.3,0,0,24),Position=UDim2.new(0.62,0,0,26),BackgroundColor3=CLR.bg4,BorderSizePixel=0,Text="10",TextColor3=CLR.text,Font=FONT,TextSize=12,ZIndex=106});corner(distInput,6)
local speedLabel=mk("TextLabel",orbitBox,{Size=UDim2.new(0.5,0,0,24),Position=UDim2.new(0,10,0,54),BackgroundTransparency=1,Text="Tốc độ: 1",TextColor3=CLR.text2,Font=FONT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=106})
local speedInput=mk("TextBox",orbitBox,{Size=UDim2.new(0.3,0,0,24),Position=UDim2.new(0.62,0,0,54),BackgroundColor3=CLR.bg4,BorderSizePixel=0,Text="1",TextColor3=CLR.text,Font=FONT,TextSize=12,ZIndex=106});corner(speedInput,6)
distInput:GetPropertyChangedSignal("Text"):Connect(function()local v=tonumber(distInput.Text);if v then _G.OrbitDistance=v;distLabel.Text="Khoảng cách: "..v end end)
speedInput:GetPropertyChangedSignal("Text"):Connect(function()local v=tonumber(speedInput.Text);if v then _G.OrbitSpeed=v;speedLabel.Text="Tốc độ: "..v end end)
local function stopOrbit()if _G.OrbitActive then _G.OrbitActive=false;_G.OrbitTarget=nil;Toast("Dừng orbit","x") end end
local followSetMode
startOrbit=function()local name=(_G.TargetPlayer~="None") and _G.TargetPlayer or tpSelected;local target=name and Players:FindFirstChild(name);if target then _G.OrbitTarget=target;_G.OrbitActive=true;_G.OrbitAngle=0;Toast("Orbit bắt đầu: "..target.Name,"o") else Toast("Chọn người chơi trước","!") end end
local modeOptions={{value="Behind",display="Phía sau"},{value="Above",display="Phía trên"},{value="Under",display="Phía dưới"},{value="Inside",display="Bên trong"},{value="Orbit Target",display="Orbit"}}
local _,setModeFn=createModeSelector(followTab,"CHỌN CHẾ ĐỘ BÁM",modeOptions,function(value)if value then _G.FollowMode=value;Toast("Chế độ bám: "..value,"~");if value=="Orbit Target" then startOrbit() else stopOrbit() end else _G.FollowMode="Behind";followSetMode("Behind");stopOrbit() end end)
followSetMode=setModeFn;followSetMode("Behind")
addToggle(followTab,"Bám TP (dịch chuyển tức thời)",function()return _G.FollowTP end,function(v)_G.FollowTP=v end,"followtp")
addInput(followTab,"Tốc độ bám",function(v)_G.FollowSpeed=v;Toast("Tốc độ bám: "..v,"~")end)
-- ADMIN
local adminTab=tabFrames["admin"];addSection(adminTab,"Admin")
addScriptButtons(adminTab,{{"Delta Infinite Yield","https://gist.githubusercontent.com/lxnnydev/c533c374ca4c1dcef4e1e10e33fa4a0c/raw/03e74f184f801dad77d3ebe1e2f18c6ac87ca612/delta___IY.gistfile1.txt.lua"},{"Infinite Yield","https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"},{"Nameless Admin","https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source"},{"Orca Admin","https://scriptblox.com/raw/Universal-Script-Orca-7620"},{"Reviz Admin","https://scriptblox.com/raw/Universal-Script-Reviz-3841"},{"Cmd-X","https://scriptblox.com/raw/Universal-Script-CMD-X-Admin-Commands-Script-3837"},{"Dark Dex V3","https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua"},{"Nameless Admin V2","https://scriptblox.com/raw/Universal-Script-Nameless-Admin-V2-UNFINISHED-source-code-9359"},{"Dex Explorer","https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"},{"Simple Spy","https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"}})
-- EXPLOITS
local exploitsTab=tabFrames["exploits"];addSection(exploitsTab,"Exploits")
addScriptButtons(exploitsTab,{{"Arceus X Mobile","https://scriptblox.com/raw/Universal-Script-Arceus-X-Script-Credit-to-AnyaDev-WORKS-WITH-ALL-SCRIPTS-8561"},{"Fluxus Coral Mobile","https://scriptblox.com/raw/Universal-Script-Fluxus-Coral-ReMake-Beta-by-AnyaDev-8562"},{"Evon V2 Mobile","https://raw.githubusercontent.com/KevinScripts2024/Gjdiddkslwodi/main/Vjvidie7fi3oe"},{"Krypton Mobile","https://raw.githubusercontent.com/KevinScripts2024/Ajdkfoepdpfpf0/main/FNUGGEYSJWIWOROD"},{"Codex Mobile","https://raw.githubusercontent.com/KevinScripts2024/Nuggey/main/Davabataxq"},{"Trigon Mobile","https://raw.githubusercontent.com/KevinScripts2024/Omg/main/Triaglan"},{"Vega X Mobile","https://raw.githubusercontent.com/KevinScripts2024/OMGSUSIDSKEKWKAI3O/main/Cjdkwowiwi"},{"Delta X Mobile","https://raw.githubusercontent.com/KevinScripts2024/Deltozoz/main/Rick%20rolled"},{"Hydrogen Mobile","https://raw.githubusercontent.com/KevinScripts2024/Gjcjsjsidicuskdkfofofidkckfkwpw9er8fudidpapq0/main/Zhcifodoelsjaisdoocc9x9x0"},{"Kato Mobile","https://raw.githubusercontent.com/KevinScripts2024/Gdcucisuduvifnslzivv8dmebshd/main/Fjcjzicuveuwjd9dksjdf6r8ejej"},{"Flooded V Mobile","https://raw.githubusercontent.com/KevinScripts2024/Dudidwkoff7wueoeiddj/main/Ahdufidwid8fudkdkgoel"},{"Punk Team Mobile","https://raw.githubusercontent.com/KevinScripts2024/Hufuddixidke8vogd/main/Vdurigofeod8f"},{"Cubix Mobile","https://raw.githubusercontent.com/KevinScripts2024/BarkOffCubix/main/Laughs"},{"Appleware Mobile","https://raw.githubusercontent.com/KevinScripts2024/Ohio/main/Xhdjskdkdiduvudke"},{"Techno Mobile","https://raw.githubusercontent.com/KevinScripts2024/Ucdjlsidufudekdififoek/main/Djdkgirueidiciswheh"},{"Synapse X PC","https://raw.githubusercontent.com/AZYsGithub/Chillz-s-scripts/main/Synapse-X-Remake.lua"},{"Netflix CE 2.0 PC","https://raw.githubusercontent.com/KevinScripts2024/Dhdusgdjyxuskxiv7didj/main/Ejdifydjakwidd7cisjsjsks8suwjdkdod"},{"Arceus X PC","https://raw.githubusercontent.com/KevinScripts2024/AMONJDJDJDJGUSSYDUDJXJDISKSJ/main/ADJXDIOSDIFUEKEPDODP"},{"Codex PC","https://raw.githubusercontent.com/KevinScripts2024/maxJJEDJDJSKwellDJDIFKDKEKK/main/Dhdjifudiekeksixi"},{"Krnl PC","https://raw.githubusercontent.com/wtfplayer/redemption/main/krnlnoui.lua"},{"Fluxus PC","https://raw.githubusercontent.com/anyahubs/executer/main/flux.lua"},{"Electron PC","https://raw.githubusercontent.com/KevinScripts2024/Elec/main/PC"},{"JJsploit PC","https://raw.githubusercontent.com/KevinScripts2024/Fjcjdugifisshnrjdjdigrjejdiga3irifhsh/main/XSDEHUDDUSJWKEKRO"},{"Krampus PC","https://raw.githubusercontent.com/KevinScripts2024/HmmGuestoDeNoche/main/Ufosjsfieoeif"},{"Nathans Custom","https://raw.githubusercontent.com/Makeruwu/Scfipg/main/Executor2%2C3"},{"Neptune Custom","https://pastebin.com/raw/y3jhxS5r"},{"Saturn Custom","https://github.com/AnAvaragelilmemer/saturn/blob/main/main.lua?raw=true"},{"Syctro Custom","https://raw.githubusercontent.com/anyahubs/executer/main/S_UI.lua"},{"Chat Executor","https://raw.githubusercontent.com/zephyr10101/chat-executor/main/chat-executor"}})
-- GAME HUBS
local gamehubsTab=tabFrames["gamehubs"];addSection(gamehubsTab,"Game Hubs")
addLabel(gamehubsTab,"Coming soon!",32)
-- SERVER
local serverTab=tabFrames["server"];addSection(serverTab,"Server")
addButton(serverTab,"Vào lại server",function()TeleportService:Teleport(game.PlaceId,LocalPlayer)end)
addButton(serverTab,"Reset nhân vật",function()if Character then Character:BreakJoints() end end)
addSection(serverTab,"Nhân vật")
addToggle(serverTab,"Lơ lửng",function()return _G.FloatChar end,function(v)_G.FloatChar=v;if v then if HumanoidRootPart then if floatBV then floatBV:Destroy() end;floatBV=mk("BodyPosition",HumanoidRootPart,{MaxForce=Vector3.new(0,math.huge,0),P=5000,D=1000,Position=HumanoidRootPart.Position}) end else if floatBV then floatBV:Destroy();floatBV=nil end end end,"float")
addToggle(serverTab,"Cầu vồng",function()return _G.RainbowChar end,function(v)_G.RainbowChar=v end,"rainbow")
addButton(serverTab,"Xóa nón/tóc",function()if LocalPlayer.Character then for _,v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end;Toast("Đã xóa","x") end end)
addToggle(serverTab,"Chống Fling",function()return _G.AntiFling end,function(v)_G.AntiFling=v end,"antifling")
addToggle(serverTab,"Click TP",function()return _G.ClickTP end,function(v)_G.ClickTP=v end,"clicktp")
addToggle(serverTab,"Đóng băng",function()return _G.AnchorChar end,function(v)_G.AnchorChar=v end,"anchor")
addToggle(serverTab,"Anti-AFK",function()return _G.AntiAFK end,function(v)_G.AntiAFK=v end,"antiafk")
addSection(serverTab,"Reset")
addButton(serverTab,"Reset tất cả",function()for _,t in ipairs(allToggles) do if (t.get() and true or false)~=t.default then pcall(t.set,t.default) end;pcall(t.refresh) end;_G.FollowPlayer=false;_G.OrbitActive=false;_G.OrbitTarget=nil;_G.FollowMode="Behind";_G.TargetPlayer="None";followSetMode("Behind");_G.WalkSpeed=16;_G.JumpPower=50;_G.Gravity=_G.originalGravity;Workspace.Gravity=_G.originalGravity;if Humanoid then Humanoid.WalkSpeed=16;Humanoid.JumpPower=50 end;if HumanoidRootPart then HumanoidRootPart.Anchored=false end;if Hooks.ClearAllESP then Hooks.ClearAllESP() end;espTargetPlayers={};aimbotTargetPlayers={};for k,v in pairs(origLighting) do pcall(function()Lighting[k]=v end)end;local cam=Workspace.CurrentCamera;if cam then cam.FieldOfView=70;if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then cam.CameraSubject=LocalPlayer.Character.Humanoid end end;for k,t in pairs(originalTransparency) do if k and k.Parent then k.Transparency=t end end;if Hooks.hudHide then Hooks.hudHide() end;Toast("Đã reset tất cả","R")end)
-- TOOLS
local toolsTab=tabFrames["tools"];addSection(toolsTab,"Công cụ")
addButton(toolsTab,"Infinity Yield",function()runScript("Infinity Yield","https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")end)
addButton(toolsTab,"Dex Explorer",function()if not DexLoaded then DexLoaded=true;runScript("Dex Explorer","https://gist.githubusercontent.com/BROgenesis/958c1fee7d8ad100da7f7d020d5d67f3/raw/8dc95caca1b46aa9f4d9dd2433f6be3d9bc69e45/Dex++") else Toast("Dex đã được tải","!") end end)
addButton(toolsTab,"F3X",function()if not F3XLoaded then F3XLoaded=true;pcall(function()loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)()end);Toast("Đã tải F3X","+") else Toast("F3X đã được tải","!") end end)
addButton(toolsTab,"Fix Lag",function()runScript("Fix Lag","https://raw.githubusercontent.com/TIKTOK-BOYCHOIGAME/PH-ICH-U/refs/heads/main/FIXLAGV2.BOYCHOIGAME")end)
addButton(toolsTab,"Give Đèn Pin",function()local tool=Instance.new("Tool");tool.Name="Đèn Pin";tool.RequiresHandle=true;tool.CanBeDropped=true;local handle=mk("Part",tool,{Name="Handle",Size=Vector3.new(0.4,1,0.4),Material=Enum.Material.Metal,Color=Color3.fromRGB(50,50,50)});mk("SpecialMesh",handle,{MeshType=Enum.MeshType.Cylinder,Scale=Vector3.new(0.5,1,0.5)});local light=mk("SpotLight",handle,{Brightness=5,Range=120,Angle=45,Shadows=true,Enabled=true,Color=Color3.fromRGB(255,255,230)});local enabled=true;tool.Activated:Connect(function()enabled=not enabled;light.Enabled=enabled;Toast(enabled and "Đèn BẬT" or "Đèn TẮT","L")end);tool.Parent=LocalPlayer.Backpack;Toast("Đã give","L")end)
addButton(toolsTab,"Boombox",function()_G.boomboxb=game:GetObjects("rbxassetid://740618400")[1];_G.boomboxb.Parent=LocalPlayer.Backpack;loadstring(_G.boomboxb.Client.Source)();loadstring(_G.boomboxb.Server.Source)();Toast("Đã thêm Boombox","+")end)
addScriptButtons(toolsTab,{{"Frontflip","https://pastefy.app/P46RU0Xa/raw"},{"Freecam Mobile","https://rawscripts.net/raw/Universal-Script-FREECAM-script-80365"},{"Freecam PC","https://pastefy.app/HJvXBu3t/raw"},{"Float","https://pastefy.app/Pf763YoR/raw"},{"Time Rewind PC","https://raw.githubusercontent.com/MSTTOPPER/Scripts/refs/heads/main/FlashBack"},{"Time Rewind Mobile","https://pastefy.app/hwrdB21v/raw"},{"Shift Lock","https://scriptblox.com/raw/Universal-Script-Mobile-Shiftlock-12348"},{"Follow Player","https://pastefy.app/DeshOdt2/raw"},{"TP Tool","https://pastefy.app/Do0IUkH7/raw"},{"God Mode","https://pastefy.app/A4x1Mcdi/raw"},{"Invisible Man","https://rawscripts.net/raw/Universal-Script-Awesome-Invisible-man-21074"},{"Xe V1","https://pastefy.app/UqDEIOpO/raw"},{"Xe V2","https://rawscripts.net/raw/Universal-Script-FE-Vehicle-Script-V2-88610"},{"Tạo Clone","https://pastefy.app/dSJmDUEJ/raw"},{"Shader","https://rawscripts.net/raw/Universal-Script-Simple-Shader-37434"},{"Sey Gex Troll","https://raw.githubusercontent.com/3LD4D0/FE-TROLLING-PLAYER-R6-R15/6eff8792afed57458d5114478b453a6f6bce5799/Fe%20trolling%20Player%20R6%20AND%20R15"},{"Touch Fling","https://raw.githubusercontent.com/CoiledTom/Fling-touch/refs/heads/main/Fling"},{"SCP096 Fling","https://pastefy.app/YsJgITXR/raw"},{"Tàng hình FE","https://pastefy.app/qoVnBsUJ/raw"},{"Better Fly","https://rawscripts.net/raw/Universal-Script-Better-Fly-GUI-44304"},{"Auto Clicker","https://rawscripts.net/raw/Universal-Script-Auto-clicker-38704"},{"FlyGuiV3 (từ v2.5)","https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"},{"Fly Trê Trâu (từ v3.6)","https://pastefy.app/nQXY1S9e/raw"},{"Jerk Tool (từ v3.6)","https://pastefy.app/pLBS72Zr/raw"},{"Shrink Ray (từ v3.6)","https://pastefy.app/67hLpwbu/raw"},{"Boombox 2 (từ v3.6)","https://pastefy.app/oB4zidgr/raw"},{"Boombox Menu (từ v3.6)","https://pastefy.app/G7A5PEZi/raw"},{"TP Menu (từ v3.6)","https://pastefy.app/PW0EARrY/raw"},{"Save Spawn (từ v3.6)","https://pastefy.app/GjJryiqh/raw"},{"Fling 2 (từ v3.6)","https://pastefy.app/JEOrp2ik/raw"}})
-- NHÂN VẬT
local hitboxOrig={};local airWalkPart=nil
local function restoreHitboxes()for hrp,data in pairs(hitboxOrig) do if hrp and hrp.Parent then pcall(function()hrp.Size=data.Size;hrp.Transparency=data.Transparency;hrp.Material=data.Material;hrp.Color=data.Color end)end end;hitboxOrig={}end
local playerTab=tabFrames["player"];addSection(playerTab,"Nhân vật")
addToggle(playerTab,"Leo tường",function()return _G.WallClimb end,function(v)_G.WallClimb=v end,"wallclimb")
addButton(playerTab,"Ép ngồi",function()if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit=true end end)
addToggle(playerTab,"Chống ngã",function()return _G.AntiRagdoll end,function(v)_G.AntiRagdoll=v;if not v and Humanoid then pcall(function()Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true);Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)end)end end,"antiragdoll")
addToggle(playerTab,"Không ngồi",function()return _G.NoSit end,function(v)_G.NoSit=v end,"nosit")
addToggle(playerTab,"Không bị đẩy",function()return _G.NoBatidao end,function(v)_G.NoBatidao=v end,"nobatidao")
addSection(playerTab,"Tính năng")
addToggle(playerTab,"Hitbox Expander",function()return _G.HitboxExpander end,function(v)_G.HitboxExpander=v;if not v then restoreHitboxes() end end,"hitbox")
addInput(playerTab,"Kích thước hitbox (10)",function(v)_G.HitboxSize=math.clamp(v,1,100)end)
addToggle(playerTab,"Hiện hitbox",function()return _G.ShowHitbox end,function(v)_G.ShowHitbox=v end,"showhitbox")
addToggle(playerTab,"Bhop (giữ Space)",function()return _G.Bhop end,function(v)_G.Bhop=v end,"bhop")
addToggle(playerTab,"Air Walk",function()return _G.AirWalk end,function(v)_G.AirWalk=v;if not v and airWalkPart then airWalkPart:Destroy();airWalkPart=nil end end,"airwalk")
addToggle(playerTab,"Anti Void",function()return _G.AntiVoid end,function(v)_G.AntiVoid=v end,"antivoid")
addToggle(playerTab,"Always Day",function()return _G.AlwaysDay end,function(v)_G.AlwaysDay=v end,"alwaysday")
addTextInput(playerTab,"Nội dung chat spam",function(t)_G.SpamText=t end)
addToggle(playerTab,"Chat Spam",function()return _G.ChatSpam end,function(v)_G.ChatSpam=v end,"chatspam")
-- VUI
local funTab=playerTab;addSection(funTab,"Vui")
addScriptButtons(funTab,{{"Script Emotes","https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"},{"Clints Dancezzz","https://rawscripts.net/raw/Universal-Script-Clints-Dancezzz-216578"}})
-- TIỆN ÍCH
local utilitiesTab=tabFrames["utilities"];addSection(utilitiesTab,"Tiện ích")
local hanoiLabel=addLabel(utilitiesTab,"Giờ Hà Nội: 00:00:00")
local uptimeLabel=addLabel(utilitiesTab,"Thời gian bạn chơi: 00:00:00")
local serverUptimeLabel=addLabel(utilitiesTab,"Server Uptime: 00:00:00")
task.spawn(function()while ScreenGui and ScreenGui.Parent do local t=os.date("!*t",os.time()+7*3600);hanoiLabel.Text=string.format("Giờ Hà Nội: %02d:%02d:%02d",t.hour,t.min,t.sec);local u=tick()-StartTime;uptimeLabel.Text=string.format("Thời gian bạn chơi: %02d:%02d:%02d",math.floor(u/3600),math.floor((u%3600)/60),math.floor(u%60));local s=Workspace.DistributedGameTime;serverUptimeLabel.Text=string.format("Server Uptime: %02d:%02d:%02d",math.floor(s/3600),math.floor((s%3600)/60),math.floor(s%60));task.wait(1)end end)
addToggle(utilitiesTab,"Anti-Paused",function()return _G.AntiPaused end,function(v)_G.AntiPaused=v;pcall(function()GuiService.GameplayPausedNotificationEnabled=not v end)end,"antipaused")
addButton(utilitiesTab,"Fix Lag V2",function()runScript("Fix Lag V2","https://raw.githubusercontent.com/TIKTOK-BOYCHOIGAME/PH-ICH-U/refs/heads/main/FIXLAGV2.BOYCHOIGAME")end)
addButton(utilitiesTab,"Copy tọa độ",function()local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart");if hrp and setclipboard then local pos=hrp.Position;setclipboard(string.format("%.1f, %.1f, %.1f",pos.X,pos.Y,pos.Z));Toast("Đã copy tọa độ","+") else Toast("Không copy được","!") end end)
addButton(utilitiesTab,"Shift Lock GUI",function()runScript("Shift Lock GUI","https://rawscripts.net/raw/Universal-Script-Shift-Lock-121871")end)
-- SETTINGS
local settingsTab=tabFrames["settings"]

local function addHexInput(tab,labelText,getHex,setHex)
    addLabel(tab,labelText,18)
    local row=mk("Frame",tab,{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,ZIndex=105})
    local swatch=mk("TextButton",row,{Size=UDim2.new(1,0,1,0),BackgroundColor3=hexToColor(getHex()),BorderSizePixel=0,Text="Chạm để chọn màu",TextColor3=Color3.new(1,1,1),Font=FONTBOLD,TextSize=12,ZIndex=106,AutoButtonColor=false})
    corner(swatch,12);stroke(swatch,Color3.new(1,1,1),1,0.75)
    local panel=mk("Frame",tab,{Size=UDim2.new(1,0,0,190),BackgroundColor3=CLR.bg2,BackgroundTransparency=0.05,BorderSizePixel=0,Visible=false,ZIndex=110});corner(panel,14)
    local sv=mk("TextButton",panel,{Size=UDim2.new(1,-20,0,112),Position=UDim2.new(0,10,0,10),BackgroundColor3=Color3.fromHSV(0,1,1),BorderSizePixel=0,Text="",ZIndex=111,AutoButtonColor=false});corner(sv,8)
    local white=mk("Frame",sv,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=112});corner(white,8)
    local whiteGrad=mk("UIGradient",white,{Rotation=0,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})})
    local black=mk("Frame",sv,{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=113});corner(black,8)
    local blackGrad=mk("UIGradient",black,{Rotation=90,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)})})
    local selector=mk("Frame",sv,{Size=UDim2.new(0,12,0,12),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=115});corner(selector,UDim.new(1,0));stroke(selector,Color3.new(1,1,1),2,0)
    local hue=mk("TextButton",panel,{Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,10,0,130),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Text="",ZIndex=111,AutoButtonColor=false});corner(hue,UDim.new(1,0))
    mk("UIGradient",hue,{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0.00,Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.16,Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.66,Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1.00,Color3.fromRGB(255,0,0))
    }),Transparency=NumberSequence.new(0),Rotation=0})
    local hueMark=mk("Frame",hue,{Size=UDim2.new(0,4,1,0),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=113})
    local rainbowBtn=mk("TextButton",panel,{Size=UDim2.new(0,100,0,24),Position=UDim2.new(0,10,1,-30),BackgroundColor3=CLR.bg4,BorderSizePixel=0,Text="Cầu vồng: TẮT",TextColor3=CLR.white,Font=FONTBOLD,TextSize=11,ZIndex=114,AutoButtonColor=false});corner(rainbowBtn,8)
    local rainbowOn=false
    local done=mk("TextButton",panel,{Size=UDim2.new(0,66,0,24),Position=UDim2.new(1,-76,1,-30),BackgroundColor3=CLR.blue,BorderSizePixel=0,Text="Xong",TextColor3=CLR.white,Font=FONTBOLD,TextSize=11,ZIndex=114});corner(done,8)
    local h,sat,val=hexToColor(getHex()):ToHSV()
    local function paint()
        sv.BackgroundColor3=Color3.fromHSV(h,1,1)
        whiteGrad.Color=ColorSequence.new(Color3.new(1,1,1),Color3.new(1,1,1))
        selector.Position=UDim2.new(sat,0,1-val,0)
        hueMark.Position=UDim2.new(h,0,0,0)
        local c=Color3.fromHSV(h,sat,val)
        swatch.BackgroundColor3=c;swatch.Text="Màu đã chọn"
        setHex(string.format("%02X%02X%02X",math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5)))
    end
    rainbowBtn.MouseButton1Click:Connect(function()rainbowOn=not rainbowOn;rainbowBtn.Text=rainbowOn and "Cầu vồng: BẬT" or "Cầu vồng: TẮT";rainbowBtn.BackgroundColor3=rainbowOn and CLR.blue or CLR.bg4;if rainbowOn then task.spawn(function()while rainbowOn and panel and panel.Parent do h=(h+0.012)%1;paint();task.wait(0.05) end end) end end)
    local function dragPick(button,mode)
        local active=false
        button.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                active=true
                local function update(pos)
                    local p=button.AbsolutePosition;local z=button.AbsoluteSize
                    local x=math.clamp((pos.X-p.X)/math.max(z.X,1),0,1)
                    local y=math.clamp((pos.Y-p.Y)/math.max(z.Y,1),0,1)
                    if mode=="sv" then sat=x;val=1-y else h=x;if rainbowOn then rainbowOn=false;rainbowBtn.Text="Cầu vồng: TẮT";rainbowBtn.BackgroundColor3=CLR.bg4 end end
                    paint()
                end
                update(input.Position)
                local changed,ended
                changed=UserInputService.InputChanged:Connect(function(move)
                    if active and (move.UserInputType==Enum.UserInputType.MouseMovement or move.UserInputType==Enum.UserInputType.Touch) then update(move.Position) end
                end)
                ended=UserInputService.InputEnded:Connect(function(fin)
                    if fin.UserInputType==Enum.UserInputType.MouseButton1 or fin.UserInputType==Enum.UserInputType.Touch then active=false;if changed then changed:Disconnect()end;if ended then ended:Disconnect()end end
                end)
            end
        end)
    end
    dragPick(sv,"sv");dragPick(hue,"h")
    swatch.MouseButton1Click:Connect(function()panel.Visible=not panel.Visible end)
    done.MouseButton1Click:Connect(function()panel.Visible=false end)
    paint()
end
local function addNumInput(tab,labelText,cur,minV,maxV,setFn)addLabel(tab,labelText,18)
local box=mk("TextBox",tab,{Size=UDim2.new(1,0,0,40),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,ClearTextOnFocus=false,Text=tostring(cur),TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,ZIndex=105});corner(box,12)
box.FocusLost:Connect(function()local v=tonumber(box.Text);if v then v=math.clamp(v,minV or 0,maxV or 99999);setFn(v);box.Text=tostring(v);Toast("Đã áp dụng","+") else box.Text=tostring(cur) end end)end
addSection(settingsTab,"Văn bản")
addNumInput(settingsTab,"Cỡ chữ (10-20)",Theme.textSize,10,20,function(v)Theme.textSize=v;applyTextAll()end)
addHexInput(settingsTab,"Màu chữ",function()return Theme.textColorHex end,function(hex)Theme.textColorHex=hex;applyTextAll()end)
addLabel(settingsTab,"Font chữ",18)
local fontRow=mk("Frame",settingsTab,{Size=UDim2.new(1,0,0,88),BackgroundTransparency=1,ZIndex=105})
mk("UIGridLayout",fontRow,{CellSize=UDim2.new(0,76,0,26),CellPadding=UDim2.new(0,4,0,4)})
local fontBtns={}
for _,fname in ipairs(FONT_ORDER) do local b=mk("TextButton",fontRow,{BackgroundColor3=(Theme.fontName==fname) and CLR.blue or CLR.bg4,BorderSizePixel=0,Text=fname,TextColor3=CLR.white,Font=FONT_MAP[fname] or FONT,TextSize=10,ZIndex=106,AutoButtonColor=false});corner(b,6)
b.MouseButton1Click:Connect(function()Theme.fontName=fname;applyTextAll();for _,fb in ipairs(fontBtns) do fb.BackgroundColor3=(fb.Text==fname) and CLR.blue or CLR.bg4 end;Toast("Font: "..fname,"~")end)
table.insert(fontBtns,b)end
addSection(settingsTab,"Nền")
addLabel(settingsTab,"Image ID nền (số hoặc rbxassetid://, trống = tắt)",32)
local bgImgBox=mk("TextBox",settingsTab,{Size=UDim2.new(1,0,0,40),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,ClearTextOnFocus=false,Text=Theme.bgImageId,TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,ZIndex=105});corner(bgImgBox,12)
bgImgBox.FocusLost:Connect(function()local v=bgImgBox.Text:gsub("%s","");if v~="" and tonumber(v) then v="rbxassetid://"..v end;Theme.bgImageId=v;if v=="" then local img=Frame:FindFirstChild("ThemeBgImage");if img then img:Destroy() end else applyTheme() end;Toast(v=="" and "Đã tắt ảnh nền" or "Đã đổi ảnh nền","+")end)
addNumInput(settingsTab,"Độ trong suốt nền UI (0-1)",Theme.uiTransparency,0,1,function(v)Theme.uiTransparency=v;Frame.BackgroundTransparency=v end)
addSection(settingsTab,"Viền")
addToggle(settingsTab,"Bật viền",function()return Theme.borderEnabled end,function(v)Theme.borderEnabled=v;applyBorder()end)
addHexInput(settingsTab,"Màu viền",function()return Theme.borderColorHex end,function(hex)Theme.borderColorHex=hex;applyBorder()end)
addNumInput(settingsTab,"Độ dày viền (0-5)",Theme.borderThickness,0,5,function(v)Theme.borderThickness=v;applyBorder()end)
addNumInput(settingsTab,"Bo góc (0-40)",Theme.cornerRadius,0,40,function(v)Theme.cornerRadius=v;applyBorder()end)
addSection(settingsTab,"Saturn")
addLabel(settingsTab,"Image ID Saturn (số hoặc rbxassetid://)",18)
local satImgBox=mk("TextBox",settingsTab,{Size=UDim2.new(1,0,0,40),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,ClearTextOnFocus=false,Text=Theme.saturnImageId,TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,ZIndex=105});corner(satImgBox,12)
satImgBox.FocusLost:Connect(function()local v=satImgBox.Text:gsub("%s","");if v~="" and tonumber(v) then v="rbxassetid://"..v end;if v~="" then Theme.saturnImageId=v;applySaturn();Toast("Đã đổi ảnh Saturn","+") else satImgBox.Text=Theme.saturnImageId end end)
addNumInput(settingsTab,"Kích thước Saturn (32-128)",Theme.saturnSize,32,128,function(v)Theme.saturnSize=v;applySaturn()end)
addToggle(settingsTab,"Khóa Saturn (không di chuyển)",function()return Theme.saturnLocked end,function(v)Theme.saturnLocked=v;lockSaturn=v;if Refs.saturnLockBtn then Refs.saturnLockBtn.Text=v and "Mở" or "Khóa" end end)
addSection(settingsTab,"Music Popup")
addHexInput(settingsTab,"Màu nền popup nhạc",function()return Theme.musicBgColorHex end,function(hex)Theme.musicBgColorHex=hex;applyMusic()end)
addHexInput(settingsTab,"Màu chữ popup nhạc",function()return Theme.musicTextColorHex end,function(hex)Theme.musicTextColorHex=hex;applyMusic()end)
addHexInput(settingsTab,"Màu thanh tiến trình",function()return Theme.musicProgColorHex end,function(hex)Theme.musicProgColorHex=hex;applyMusic()end)
addHexInput(settingsTab,"Màu nút điều khiển",function()return Theme.musicBtnColorHex end,function(hex)Theme.musicBtnColorHex=hex;applyMusic()end)
addNumInput(settingsTab,"Độ trong suốt popup nhạc (0-1)",Theme.musicTransparency,0,1,function(v)Theme.musicTransparency=v;applyMusic()end)
addLabel(settingsTab,"ID ảnh đĩa nhạc (số / rbxassetid:// / rbxthumb://)",18)
local discImgBox=mk("TextBox",settingsTab,{Size=UDim2.new(1,0,0,40),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,ClearTextOnFocus=false,Text=Theme.musicDiscImageId or Theme.saturnImageId,TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,ZIndex=105});corner(discImgBox,12)
discImgBox.FocusLost:Connect(function()local v=normalizeImageId(discImgBox.Text);if v~="" then Theme.musicDiscImageId=v;applyMusic();Toast("Đã đổi ảnh đĩa nhạc","+") else discImgBox.Text=Theme.musicDiscImageId end end)
addLabel(settingsTab,"ID ảnh theme popup nhạc (rbxthumb://... / số / rbxassetid://, trống = tắt)",32)
local themeImgBox=mk("TextBox",settingsTab,{Size=UDim2.new(1,0,0,40),BackgroundColor3=CLR.bg3,BackgroundTransparency=0.25,BorderSizePixel=0,ClearTextOnFocus=false,Text=Theme.musicThemeImageId or "",TextColor3=hexToColor(Theme.textColorHex),Font=FONT_MAP[Theme.fontName] or FONT,TextSize=Theme.textSize,ZIndex=105});corner(themeImgBox,12)
themeImgBox.FocusLost:Connect(function()local v=normalizeImageId(themeImgBox.Text);Theme.musicThemeImageId=v;applyMusic();Toast(v=="" and "Đã tắt theme popup" or "Đã đổi theme popup","+") end)
addSection(settingsTab,"Bố cục UI")
addNumInput(settingsTab,"Kích thước UI (0.7-1.3)",Theme.uiScale,0.7,1.3,function(v)Theme.uiScale=v;applyLayout()end)
addNumInput(settingsTab,"Khoảng cách nút (4-20)",Theme.buttonSpacing,4,20,function(v)Theme.buttonSpacing=v;applyLayout()end)
addNumInput(settingsTab,"Vị trí X (0-1, 0.5 = giữa)",Theme.uiPosX,0,1,function(v)Theme.uiPosX=v;applyLayout()end)
addNumInput(settingsTab,"Vị trí Y (0-1, 0.5 = giữa)",Theme.uiPosY,0,1,function(v)Theme.uiPosY=v;applyLayout()end)
addSection(settingsTab,"FPS")
addToggle(settingsTab,"Hiện FPS",function()return Theme.fpsVisible end,function(v)Theme.fpsVisible=v;applyFPS()end)
addHexInput(settingsTab,"Màu FPS",function()return Theme.fpsColorHex end,function(hex)Theme.fpsColorHex=hex;applyFPS()end)
addNumInput(settingsTab,"Cỡ chữ FPS (10-28)",Theme.fpsSize,10,28,function(v)Theme.fpsSize=v;applyFPS()end)
addSection(settingsTab,"Hệ thống")
addToggle(settingsTab,"Hiện thông báo",function()return notificationsEnabled end,function(v)notificationsEnabled=v end)
addToggle(settingsTab,"Bật hiệu ứng chuyển động",function()return Theme.animationsEnabled end,function(v)Theme.animationsEnabled=v end)
addButton(settingsTab,"Lưu cài đặt",function()local ok=saveConfig();Toast(ok and "Đã lưu cài đặt" or "Không lưu được (executor chặn writefile)",ok and "+" or "x")end)
addButton(settingsTab,"Khôi phục mặc định",function()
    local d={textSize=13,textColorHex="FFFFFF",fontName="Gotham",bgImageId="",bgTransparency=0.04,borderEnabled=true,borderColorHex="FFFFFF",borderThickness=0.8,cornerRadius=28,saturnImageId="rbxassetid://130980521832226",saturnSize=64,saturnLocked=false,musicDiscImageId="rbxassetid://130980521832226",musicThemeImageId="rbxthumb://type=Asset&id=127717372459962&w=420&h=420",musicBgColorHex="08080A",musicTextColorHex="FFFFFF",musicProgColorHex="7D87FF",musicBtnColorHex="6973FF",musicTransparency=0.04,uiScale=1.0,buttonSpacing=8,uiTransparency=0.04,uiPosX=0.5,uiPosY=0.5,fpsColorHex="30D158",fpsSize=14,fpsVisible=true,animationsEnabled=true}
    for k,v in pairs(d) do Theme[k]=v end
    if discImgBox then discImgBox.Text=Theme.musicDiscImageId end
    if themeImgBox then themeImgBox.Text=Theme.musicThemeImageId end
    if satImgBox then satImgBox.Text=Theme.saturnImageId end
    if bgImgBox then bgImgBox.Text=Theme.bgImageId end
    local img=Frame:FindFirstChild("ThemeBgImage");if img then img:Destroy() end
    applyTextAll();applyTheme();applyBorder();applyLayout();applyFPS();applySaturn();applyMusic()
    lockSaturn=Theme.saturnLocked;SaturnBaseSize=Theme.saturnSize
    if Refs.saturnLockBtn then Refs.saturnLockBtn.Text="Khóa" end
    Toast("Đã khôi phục mặc định","R")
end)

-- MUSIC (PATCHED: YmpRequest bound to mreq + MP3 header gate + multi-mirror)
local function buildMusicTab()
    local musicTab=tabFrames["music"]
    local API_URL="https://ymp-api.ddns.net"
    local CACHE_FOLDER="ThanhMusic";local MUSIC_FOLDER=CACHE_FOLDER.."/Musics"
    local CACHE_IMG=CACHE_FOLDER.."/Cache";local DATA_FILE=CACHE_FOLDER.."/Data.json"
    local function hasFile(p)local ok,r=pcall(isfile,p);return ok and r end
    pcall(function()if not isfolder(CACHE_FOLDER) then makefolder(CACHE_FOLDER) end;if not isfolder(MUSIC_FOLDER) then makefolder(MUSIC_FOLDER) end;if not isfolder(CACHE_IMG) then makefolder(CACHE_IMG) end;if not isfile(DATA_FILE) then writefile(DATA_FILE,'{"history":[]}') end end)
    local requestFn=request or http_request or syn_request or (syn and syn.request) or (http and http.request)
    local function mreq(opt)
        if requestFn then
            local ok,r=pcall(requestFn,opt)
            if ok and r then return r end
        end
        if opt.Method=="GET" then
            local ok,b=pcall(game.HttpGet,game,opt.Url)
            if ok and b then return {Body=b,body=b,StatusCode=200} end
        end
        return nil
    end
    local YmpRequest=mreq
    local function isMp3Blob(s)
        if type(s)~="string" or #s<4 then return false end
        local h3=s:sub(1,3); local b1,b2=s:byte(1),s:byte(2)
        return h3=="ID3" or (b1==0xFF and (b2==0xFB or b2==0xFA or b2==0xF3 or b2==0xF2 or b2==0xF1))
    end
    local function searchYT(query)local url=API_URL.."/search/youtube/free/"..HttpService:UrlEncode(query);local ok,r=pcall(game.HttpGet,game,url);if not ok then return nil end;if string.lower(r):find("no results") then return {} end;local ok2,d=pcall(HttpService.JSONDecode,HttpService,r);if ok2 and d and d.results then return d.results end;return nil end
    local function apiInfo(vid)local ok,r=pcall(game.HttpGet,game,API_URL.."/info?url=https://youtu.be/"..vid);if not ok then return nil end;local ok2,d=pcall(HttpService.JSONDecode,HttpService,r);if ok2 and d and d.Name then return d.Name,d.Author,d.Thumbnail end;return nil end
local shaK={1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298}
local D_API='https://p.savenow.to'
local D_REF='https://en.loader.to/'
local D_KEY='dfcb6d76f2f6a9894gjkege8a4ab232222'
local D_TMO=200
local powTok,powExp,flag21=nil,0,false
local function rr(a,b)return bit32.rrotate(a,b)end
local function sum(...)local t=table.pack(...)local s=0 for i=1,select('#',...)do s=bit32.band(s+select(i,table.unpack(t,1,t.n)),4294967295)end return s end
local function sha256(s)
  local n=#s local b={string.byte(s,1,n)} local l=n*8
  b[#b+1]=128 while#b%64~=56 do b[#b+1]=0 end
  local hi=math.floor(l/4294967296)local lo=l%4294967296
  for i=24,0,-8 do b[#b+1]=bit32.band(bit32.rshift(hi,i),255)end
  for i=24,0,-8 do b[#b+1]=bit32.band(bit32.rshift(lo,i),255)end
  local h0,h1,h2,h3,h4,h5,h6,h7=1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225
  for i=1,#b,64 do
    local w={}
    for j=0,15 do local off=i+j*4 w[j+1]=bit32.bor(bit32.lshift(b[off],24),bit32.lshift(b[off+1],16),bit32.lshift(b[off+2],8),b[off+3])end
    for j=17,64 do local a1=w[j-15]local a2=w[j-2]local s0=bit32.bxor(rr(a1,7),rr(a1,18),bit32.rshift(a1,3))local s1=bit32.bxor(rr(a2,17),rr(a2,19),bit32.rshift(a2,10))w[j]=sum(w[j-16],s0,w[j-7],s1)end
    local a,b2,c,d,e,f,g,h=h0,h1,h2,h3,h4,h5,h6,h7
    for j=1,64 do
      local s1=bit32.bxor(rr(e,6),rr(e,11),rr(e,25))local ch=bit32.bxor(bit32.band(e,f),bit32.band(bit32.bnot(e),g))local t1=sum(h,s1,ch,shaK[j],w[j])
      local s0=bit32.bxor(rr(a,2),rr(a,13),rr(a,22))local maj=bit32.bxor(bit32.band(a,b2),bit32.band(a,c),bit32.band(b2,c))
      local t2=sum(s0,maj)
      h=g g=f f=e e=sum(d,t1)d=c c=b2 b2=a a=sum(t1,t2)
    end
    h0=sum(h0,a)h1=sum(h1,b2)h2=sum(h2,c)h3=sum(h3,d)h4=sum(h4,e)h5=sum(h5,f)h6=sum(h6,g)h7=sum(h7,h)
  end
  return string.format('%08x%08x%08x%08x%08x%08x%08x%08x',h0,h1,h2,h3,h4,h5,h6,h7)
end
local function solve(salt,diff)
  local n=tonumber(diff)if not n then return nil end
  local target=string.rep('0',n)local prefix=tostring(salt)..':'local i=0
  while true do
    local start=os.clock()local timeout=false
    while sha256(prefix..tostring(i)):sub(1,n)~=target do
      i+=1 if os.clock()-start>0.003 then timeout=true break end
    end
    if timeout then task.wait()else break end
  end
  return tostring(i)
end
local function hdr(auth,json)
  local h={accept='*/*',['accept-language']='en-US,en;q=0.9',referer=D_REF}
  if json then h['content-type']='application/json'end
  if auth then h.authorization='Bearer '..auth end
  return h
end
local function parseBody(r)
  if not r then return nil end
  local b=r.Body or r.body
  if type(b)~='string'then return nil end
  local ok,d=pcall(HttpService.JSONDecode,HttpService,b)
  if not ok or type(d)~='table'then return nil end
  return d
end
local function getPowToken()
  local now=os.time()
  if powTok and now<powExp-30 then return powTok end
  if flag21 then local s=os.clock()while flag21 do if os.clock()-s>=10 then break end task.wait()end if powTok and os.time()<powExp-30 then return powTok end end
  flag21=true
  local ok,tok,exp=pcall(function()
    local r1=YmpRequest({Url=D_API..'/api/pow/challenge',Method='GET',Headers=hdr()})
    local d1=parseBody(r1)
    if not d1 or not d1.salt or not d1.difficulty or not d1.expires_at or not d1.signature then return nil end
    local nonce=solve(d1.salt,d1.difficulty)
    if not nonce then return nil end
    local r2=YmpRequest({Url=D_API..'/api/pow/verify',Method='POST',Headers=hdr(nil,true),Body=HttpService:JSONEncode({salt=d1.salt,difficulty=d1.difficulty,expires_at=d1.expires_at,signature=d1.signature,nonce=nonce})})
    local d2=parseBody(r2)
    if not d2 or d2.success~=true or type(d2.token)~='string'then return nil end
    return d2.token,tonumber(d2.expires_at)or tonumber(d1.expires_at)or os.time()+300
  end)
  flag21=false
  if not ok or type(tok)~='string'then return nil end
  powTok=tok powExp=tonumber(exp)or os.time()+300
  return powTok
end
local function doDownload(url,fmt)
  local start=os.clock()
  local tok=getPowToken()
  local full=D_API..'/api/v2/download?format='..HttpService:UrlEncode(fmt)..'&url='..HttpService:UrlEncode(url)..'&apikey='..D_KEY
  local h=hdr(tok)
  local ok,r=pcall(function()return YmpRequest({Url=full,Method='GET',Headers=h})end)
  if not ok then return'error'end
  local d=parseBody(r)
  if not d or d.success==false or type(d.progress_url)~='string'then return'error'end
  local purl=d.progress_url
  task.wait(2) local final
  while true do
    final=nil
    if os.clock()-start>D_TMO then break end
    local ok2,r2=pcall(function()return YmpRequest({Url=purl,Method='GET',Headers=h})end)
    if ok2 then
      local d2=parseBody(r2)
      if d2 then
        if d2.progress==1000 and type(d2.download_url)=='string'then final=d2 break end
        task.wait(2)
      else task.wait(2)end
    else task.wait(2)end
  end
  if not final then return'error'end
  local links={}
  if type(final.download_url)=='string'then links[#links+1]=final.download_url end
  if#links==0 then return'error'end
  local parts=table.create(math.min(#links,4))
  for i=1,math.min(#links,4)do parts[i]='Download'..i..': '..links[i]end
  return table.concat(parts,'\n')
end
DownloadMusic=function(u) return doDownload(u,'mp3') end
    local function downloadMusicDirect(yid)
        local raw=doDownload("https://youtu.be/"..tostring(yid),"mp3")
        if type(raw)~="string" or raw=="error" or raw=="rate" then
            warn("[Thạnh Music] API tải nhạc không trả về link MP3 hợp lệ: "..tostring(raw))
            return nil
        end
        local link=string.match(raw,"Download%d+:%s*(https?://%S+)")
        if not link then
            warn("[Thạnh Music] Không tìm thấy download URL trong phản hồi API.")
            return nil
        end
        return link
    end

    local function readData()local ok,r=pcall(function()return HttpService:JSONDecode(readfile(DATA_FILE))end);if ok and r then return r end;return {history={}}end
    local function writeData(d)pcall(function()writefile(DATA_FILE,HttpService:JSONEncode(d))end)end
    local function addHistory(entry)local d=readData();d.history=d.history or {};for i,x in ipairs(d.history) do if x.id==entry.id then table.remove(d.history,i);break end end;table.insert(d.history,1,entry);while #d.history>80 do table.remove(d.history) end;writeData(d)end
    local function removeHistory(id)local d=readData();d.history=d.history or {};for i,x in ipairs(d.history) do if x.id==id then table.remove(d.history,i);break end end;writeData(d)end
    local function getSongName(id)local d=readData();for _,x in ipairs(d.history or {}) do if x.id==id then return x.name or id end end;return id end
    local Sound=mk("Sound",SoundService,{Name="ThanhMusicSound",Volume=0.5,Looped=false});_G.ThanhSound=Sound
    local pitchFx=mk("PitchShiftSoundEffect",Sound,{Octave=1})
    local editPitch,editSpeed=1.0,1.0
    local editPresets={{name="Gốc",pitch=1.0,speed=1.0},{name="Slowed",pitch=0.85,speed=0.85},{name="Sped Up",pitch=1.15,speed=1.2},{name="Nightcore",pitch=1.3,speed=1.3},{name="Bass",pitch=0.75,speed=1.0},{name="Chipmunk",pitch=1.5,speed=1.0},{name="Vapor",pitch=0.8,speed=0.8},{name="8D",pitch=1.0,speed=1.0}}
    local editIndex=1
    local function applyEdit()pcall(function()pitchFx.Octave=editPitch end);pcall(function()Sound.PlaybackSpeed=editSpeed end)end
    local currentPlayingId=nil;local isDownloading=false;local paused=false
    local function formatTime(sec)sec=math.floor(sec or 0);return string.format("%d:%02d",math.floor(sec/60),sec%60)end
    local function setHudTitle(title,artist)title=tostring(title or "");if Refs.musicTitle then Refs.musicTitle.Text=title~="" and title or "Đang phát" end;if Refs.musicCompactTitle then Refs.musicCompactTitle.Text=title~="" and title or "Đang phát" end;if Refs.musicArtist then Refs.musicArtist.Text=tostring(artist or "") end end
    hudPlayBtn.MouseButton1Click:Connect(function()if not Sound.SoundId or Sound.SoundId=="" then Toast("Chưa có bài nào","!");return end;if Sound.IsPlaying and not hudPaused then Sound:Pause();hudPaused=true;hudPlayBtn.Text="Play";Toast("Tạm dừng","|") else Sound:Resume();hudPaused=false;hudPlayBtn.Text="Pause";Toast("Đang phát",">") end end)
    hudBack10Btn.MouseButton1Click:Connect(function()pcall(function()Sound.TimePosition=math.max(0,Sound.TimePosition-10)end)end)
    hudFwd10Btn.MouseButton1Click:Connect(function()pcall(function()local l=Sound.TimeLength or 0;Sound.TimePosition=(l>0) and math.min(l,Sound.TimePosition+10) or (Sound.TimePosition+10)end)end)
    hudQueueBtn.MouseButton1Click:Connect(function()if viewMode=="search" then viewMode="history" else viewMode="search" end;if renderHistoryList then renderHistoryList() end end)
    task.spawn(function()while MusicHUD and MusicHUD.Parent do RunService.Heartbeat:Wait();if MusicHUD.Visible then local curr,total=Sound.TimePosition or 0,Sound.TimeLength or 0;if total>0 then if Refs.musicProgFill then Refs.musicProgFill.Size=UDim2.new(math.clamp(curr/total,0,1),0,1,0) end;if Refs.musicTime then Refs.musicTime.Text=formatTime(curr).." / "..formatTime(total) end else if Refs.musicProgFill then Refs.musicProgFill.Size=UDim2.new(0,0,1,0) end;if Refs.musicTime then Refs.musicTime.Text="0:00 / 0:00" end end;if hudPlayBtn then hudPlayBtn.Text=(Sound.IsPlaying and not hudPaused) and "Pause" or "Play" end;if compactDot and compactDot.Visible then compactDot.BackgroundColor3=Sound.IsPlaying and hexToColor(Theme.musicProgColorHex) or Color3.fromRGB(35,35,42) end end end end)
    local function stopAll()pcall(function()Sound:Stop();Sound.SoundId="" end);hudPaused=false;paused=false;if hudPlayBtn then hudPlayBtn.Text="Play" end;setHudTitle("","");if Refs.musicProgFill then Refs.musicProgFill.Size=UDim2.new(0,0,1,0) end;currentPlayingId=nil end
    Hooks.stopMusic=stopAll
    local function playFromCache(id)
        if isDownloading then Toast("Đang tải, chờ","!");return end
        local path=MUSIC_FOLDER.."/"..id..".mp3"
        if not hasFile(path) then Toast("File không tồn tại","!");return end
        if type(getcustomasset)~="function" then warn("[Thạnh Music] Executor không có getcustomasset.");Toast("Executor thiếu getcustomasset","!");return end

        local okRead,fdata=pcall(readfile,path)
        if not okRead or not isMp3Blob(fdata) then
            warn("[Thạnh Music] File cache không phải MP3 hợp lệ, đang xóa để tải lại.")
            Toast("File hỏng, đã xóa — tải lại","x")
            pcall(delfile,path)
            removeHistory(id)
            return
        end

        local ok,asset=pcall(getcustomasset,path)
        if not ok or type(asset)~="string" or asset=="" then warn("[Thạnh Music] getcustomasset lỗi: "..tostring(asset));Toast("Lỗi asset","!");return end

        pcall(function() Sound:Stop() end)
        Sound.SoundId=asset
        Sound.Volume=0.5
        applyEdit()

        local played,playErr=pcall(function() Sound:Play() end)
        if not played then warn("[Thạnh Music] Sound:Play lỗi: "..tostring(playErr));Toast("Không gọi được Play","!");return end

        local started=os.clock()
        while not Sound.IsLoaded and os.clock()-started<12 do task.wait(0.1) end
        if not Sound.IsLoaded then
            warn("[Thạnh Music] Sound chưa load sau 12 giây. Xóa file và yêu cầu tải lại.")
            Toast("File âm thanh hỏng, đã xóa","x")
            pcall(delfile,path)
            removeHistory(id)
            return
        end
        if (Sound.TimeLength or 0)<=0 then
            warn("[Thạnh Music] TimeLength=0, file không hợp lệ.")
            Toast("File âm thanh không hợp lệ","!")
            pcall(delfile,path)
            removeHistory(id)
            return
        end

        hudPaused=false;paused=false
        if hudPlayBtn then hudPlayBtn.Text="Pause" end
        currentPlayingId=id
        local name=getSongName(id)
        local histItem=nil
        for _,h in ipairs(readData().history or {}) do if tostring(h.id)==tostring(id) then histItem=h;break end end
        setMusicThumbnail(histItem and (histItem.thumb or histItem.thumbnail) or "")
        setHudTitle(name,"")
        MusicHUD.Visible=true
        if Hooks.setHudExpanded then Hooks.setHudExpanded(false) end
        Toast("Phát: "..name,">")
    end
    local function downloadSong(item,thenPlay)
        if isDownloading then Toast("Đang tải bài khác","!");return end
        if not item or not item.id then return end
        local id=item.id
        local path=MUSIC_FOLDER.."/"..id..".mp3"
        local entry={id=id,name=item.name or id,author=item.author or "",thumb=item.thumbnail or item.thumb or ""}
        if hasFile(path) then
            local okRead,fdata=pcall(readfile,path)
            if okRead and isMp3Blob(fdata) then
                addHistory(entry)
                if thenPlay then playFromCache(id) end
                return
            end
            pcall(delfile,path)
            removeHistory(id)
            Toast("File cũ hỏng, tải lại...","!")
        end
        isDownloading=true
        local songName=item.name or id
        Toast("Đang tải "..songName,"v")
        task.spawn(function()
            local raw=doDownload("https://youtu.be/"..tostring(id),"mp3")
            if type(raw)~="string" or raw=="error" or raw=="rate" then
                warn("[Thạnh Music] API không trả về link MP3: "..tostring(raw))
                isDownloading=false
                Toast("Lỗi tải","x")
                return
            end
            local links={}
            for i,u in string.gmatch(raw,'Download(%d+):%s*(https?://%S+)') do
                links[tonumber(i)]=u
            end
            local data=nil
            for i=1,4 do
                local link=links[i]
                if link then
                    for _=1,2 do
                        local ok,r=pcall(game.HttpGet,game,link)
                        if ok and isMp3Blob(r) then data=r;break end
                        if ok and type(r)=="string" and #r>0 then
                            warn("[Thạnh Music] Mirror "..i.." không phải MP3 (header: "..tostring(r:sub(1,3)).."), thử tiếp.")
                        end
                        task.wait(0.4)
                    end
                    if data then break end
                end
            end
            if not data then
                isDownloading=false
                Toast("Không có mirror MP3 hợp lệ","x")
                return
            end
            pcall(function()
                if not isfolder(MUSIC_FOLDER) then makefolder(MUSIC_FOLDER) end
                writefile(path,data)
            end)
            addHistory(entry)
            isDownloading=false
            if thenPlay then playFromCache(id) else Toast("Đã lưu: "..songName,"+") end
        end)
    end
    addSection(musicTab,"Nhạc")
    local searchRow=mk("Frame",musicTab,{Size=UDim2.new(1,0,0,42),BackgroundTransparency=1,ZIndex=105})
    local searchBox=mk("TextBox",searchRow,{Size=UDim2.new(1,-70,1,0),BackgroundColor3=Color3.fromRGB(52,52,58),BackgroundTransparency=0.3,BorderSizePixel=0,ClearTextOnFocus=false,PlaceholderText="Tên bài hoặc link YouTube...",PlaceholderColor3=Color3.fromRGB(150,150,160),Text="",TextColor3=Color3.fromRGB(255,255,255),Font=FONT,TextSize=12,ZIndex=106});corner(searchBox,12)
    local searchBtn=mk("TextButton",searchRow,{Size=UDim2.new(0,64,1,0),Position=UDim2.new(1,-64,0,0),BackgroundColor3=Color3.fromRGB(88,101,242),BorderSizePixel=0,Text="Tìm",TextColor3=Color3.fromRGB(255,255,255),Font=FONTBOLD,TextSize=12,ZIndex=106});corner(searchBtn,12)
    local statusLabel=mk("TextLabel",musicTab,{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(150,150,160),Font=FONT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=105})
    local viewToggleBtn=mk("TextButton",musicTab,{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.fromRGB(52,52,58),BackgroundTransparency=0.3,BorderSizePixel=0,Text="Bấm để xem Đã lưu",TextColor3=Color3.fromRGB(240,240,245),Font=FONTBOLD,TextSize=11,ZIndex=105});corner(viewToggleBtn,12)
    local listScroll=mk("ScrollingFrame",musicTab,{Size=UDim2.new(1,0,0,180),BackgroundColor3=Color3.fromRGB(42,42,48),BackgroundTransparency=0.4,BorderSizePixel=0,ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),ZIndex=105});corner(listScroll,12)
    local listLayout=mk("UIListLayout",listScroll,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()listScroll.CanvasSize=UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y+10)end)
    local viewMode="search";local renderHistoryList
    local function clearList()for _,child in ipairs(listScroll:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end end
    local function makeCard(item,hasMp3)
        local card=mk("Frame",listScroll,{Size=UDim2.new(1,-6,0,72),BackgroundColor3=Color3.fromRGB(60,60,68),BorderSizePixel=0,ZIndex=106});corner(card,12)
        if _G.ShowThumbnail then local thumb=mk("ImageLabel",card,{Size=UDim2.new(0,60,0,56),Position=UDim2.new(0,8,0.5,-28),BackgroundColor3=Color3.fromRGB(25,27,40),BorderSizePixel=0,ScaleType=Enum.ScaleType.Crop,Image="",ZIndex=107});corner(thumb,8)
            task.spawn(function()local u=item.thumb or item.thumbnail;if u and type(u)=="string" and u:sub(1,4)=="http" then local ok,b=pcall(game.HttpGet,game,u);if ok and b then local pth=CACHE_IMG.."/th_"..tostring(item.id)..".jpg";pcall(function()writefile(pth,b)end);local ok2,a=pcall(getcustomasset,pth);if ok2 and a and thumb.Parent then thumb.Image=a end end end end)end
        mk("TextLabel",card,{Size=UDim2.new(1,-148,0,22),Position=UDim2.new(0,76,0,6),BackgroundTransparency=1,Text=tostring(item.name or item.id):sub(1,42),TextColor3=Color3.fromRGB(255,255,255),Font=FONT,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=107})
        mk("TextLabel",card,{Size=UDim2.new(1,-148,0,16),Position=UDim2.new(0,76,0,30),BackgroundTransparency=1,Text=tostring(item.author or ""):sub(1,32),TextColor3=Color3.fromRGB(180,180,180),Font=FONT,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=107})
        local mainBtn=mk("TextButton",card,{Size=UDim2.new(0,60,0,30),Position=UDim2.new(1,-68,0,4),BackgroundColor3=Color3.fromRGB(88,101,242),BorderSizePixel=0,Text=hasMp3 and "Nghe" or "Phát",TextColor3=Color3.fromRGB(255,255,255),Font=FONTBOLD,TextSize=12,ZIndex=107});corner(mainBtn,8)
        local subBtn=mk("TextButton",card,{Size=UDim2.new(0,60,0,30),Position=UDim2.new(1,-68,0,38),BackgroundColor3=hasMp3 and Color3.fromRGB(200,50,50) or Color3.fromRGB(52,52,58),BorderSizePixel=0,Text=hasMp3 and "Xóa" or "Lưu",TextColor3=Color3.fromRGB(255,255,255),Font=FONTBOLD,TextSize=11,ZIndex=107});corner(subBtn,8)
        if hasMp3 then mainBtn.MouseButton1Click:Connect(function()playFromCache(item.id)end);subBtn.MouseButton1Click:Connect(function()pcall(function()local p=MUSIC_FOLDER.."/"..item.id..".mp3";if hasFile(p) then delfile(p) end end);removeHistory(item.id);Toast("Đã xóa","x");if renderHistoryList then renderHistoryList() end end) else mainBtn.MouseButton1Click:Connect(function()downloadSong(item,true)end);subBtn.MouseButton1Click:Connect(function()downloadSong(item,false)end) end
    end
    local function renderSearchResults(results)clearList();local count=0;for _,item in ipairs(results) do if item.id then count=count+1;if count>30 then break end;makeCard(item,false) end end end
    local function emptyNote(text)local e=mk("TextLabel",listScroll,{Size=UDim2.new(1,-10,0,60),BackgroundColor3=Color3.fromRGB(52,52,58),BackgroundTransparency=0.5,Text=text,TextColor3=Color3.fromRGB(200,200,200),Font=FONT,TextSize=12,TextWrapped=true,ZIndex=106});corner(e,12)end
    renderHistoryList=function()clearList();local hist=readData().history or {};if #hist==0 then emptyNote("Chưa có gì, tải bài đầu tiên đi");return end;local shown=0;for _,item in ipairs(hist) do if hasFile(MUSIC_FOLDER.."/"..item.id..".mp3") then makeCard(item,true);shown=shown+1 end end;if shown==0 then emptyNote("Không có file trong cache") end end
    viewToggleBtn.MouseButton1Click:Connect(function()if viewMode=="search" then viewMode="history";viewToggleBtn.Text="Bấm để về Tìm";renderHistoryList() else viewMode="search";viewToggleBtn.Text="Bấm để xem Đã lưu";clearList() end end)
    local function doSearch()if isDownloading then Toast("Đang tải, chờ","!");return end;viewMode="search";viewToggleBtn.Text="Bấm để xem Đã lưu";local query=searchBox.Text:gsub("^%s*(.-)%s*$","%1");if query=="" then return end;local yid=query:match("youtu%.be/([%w_-]+)") or query:match("youtube%.com/watch%?v=([%w_-]+)");if yid then statusLabel.Text="Đang lấy info...";task.spawn(function()local name,author,thumb=apiInfo(yid);setMusicThumbnail(thumb or "");renderSearchResults({{id=yid,name=name or yid,author=author or "",thumbnail=thumb or ""}});statusLabel.Text="Đã lấy info" end);return end;statusLabel.Text="Đang tìm...";clearList();task.spawn(function()local results=searchYT(query);if not results then statusLabel.Text="Lỗi mạng";Toast("Lỗi mạng","!");return end;if #results==0 then statusLabel.Text="Không có kết quả";Toast("Trống","!");return end;statusLabel.Text=tostring(#results).." kết quả";renderSearchResults(results) end)end
    searchBtn.MouseButton1Click:Connect(doSearch)
    searchBox.FocusLost:Connect(function(e)if e then doSearch() end end)
    addSection(musicTab,"Chỉnh nhạc")
    local editStatusLabel=mk("TextLabel",musicTab,{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text="Preset: Gốc  |  Pitch 1.00  |  Speed 1.00",TextColor3=Color3.fromRGB(120,200,255),Font=FONTBOLD,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=105})
    local function updateEditStatus()local name=editPresets[editIndex] and editPresets[editIndex].name or "Tùy chỉnh";editStatusLabel.Text=string.format("Preset: %s  |  Pitch %.2f  |  Speed %.2f",name,editPitch,editSpeed)end
    local presetRow=mk("Frame",musicTab,{Size=UDim2.new(1,0,0,64),BackgroundTransparency=1,ZIndex=105})
    mk("UIGridLayout",presetRow,{CellSize=UDim2.new(0,68,0,28),CellPadding=UDim2.new(0,4,0,4)})
    local presetButtons={}
    for i,preset in ipairs(editPresets) do local btn=mk("TextButton",presetRow,{Size=UDim2.new(0,68,0,28),BackgroundColor3=i==1 and Color3.fromRGB(88,101,242) or Color3.fromRGB(60,60,68),BorderSizePixel=0,Text=preset.name,TextColor3=Color3.fromRGB(255,255,255),Font=FONT,TextSize=11,ZIndex=106,AutoButtonColor=false});corner(btn,8)
    btn.MouseButton1Click:Connect(function()editIndex=i;editPitch=preset.pitch;editSpeed=preset.speed;applyEdit();for j,b in ipairs(presetButtons) do b.BackgroundColor3=(j==editIndex) and Color3.fromRGB(88,101,242) or Color3.fromRGB(60,60,68) end;updateEditStatus();Toast("Preset: "..preset.name,"~")end)
    presetButtons[i]=btn end
    addInput(musicTab,"Pitch tùy chỉnh (0.5-2.0)",function(v)if v>=0.5 and v<=2.0 then editPitch=v;editIndex=0;applyEdit();updateEditStatus();Toast("Pitch "..v,"~") else Toast("Pitch 0.5-2.0","!") end end)
    addInput(musicTab,"Speed tùy chỉnh (0.5-2.0)",function(v)if v>=0.5 and v<=2.0 then editSpeed=v;editIndex=0;applyEdit();updateEditStatus();Toast("Speed "..v,"~") else Toast("Speed 0.5-2.0","!") end end)
    addToggle(musicTab,"Hát lặp lại",function()return Sound.Looped end,function(v)Sound.Looped=v end)
    addToggle(musicTab,"Hiện thumbnail",function()return _G.ShowThumbnail end,function(v)_G.ShowThumbnail=v;setMusicThumbnail(compactThumb.Image);if viewMode=="history" then renderHistoryList() end end)
    addToggle(musicTab,"Hiện popup nhạc",function()return _G.ShowMusicHUD end,function(v)_G.ShowMusicHUD=v;if v and Sound.SoundId~="" then MusicHUD.Visible=true elseif not v then MusicHUD.Visible=false end end)
    addButton(musicTab,"Reset về gốc",function()editIndex=1;editPitch=1.0;editSpeed=1.0;applyEdit();for j,b in ipairs(presetButtons) do b.BackgroundColor3=(j==1) and Color3.fromRGB(88,101,242) or Color3.fromRGB(60,60,68) end;updateEditStatus();Toast("Đã reset","~")end)
    addButton(musicTab,"Dừng phát",function()stopAll();paused=false;Toast("Đã dừng","=")end)
    addButton(musicTab,"XÓA TẤT CẢ LỊCH SỬ",function()pcall(function()if isfolder(MUSIC_FOLDER) then for _,f in ipairs(listfiles(MUSIC_FOLDER)) do pcall(function()delfile(f)end)end end end);pcall(function()if isfolder(CACHE_IMG) then for _,f in ipairs(listfiles(CACHE_IMG)) do pcall(function()delfile(f)end)end end end);writeData({history={}});stopAll();paused=false;Toast("Đã xóa tất cả","x");if viewMode=="history" then renderHistoryList() end end)
end
buildMusicTab()
-- ESP ENGINE
local espLines={}
local function hideESPData(d)for _,l in ipairs(d.lines) do l.Visible=false end;d.name.Visible=false;d.health.Visible=false;d.stud.Visible=false;d.tline.Visible=false;if d.hl then d.hl.Enabled=false end end
local function CreateESPForPlayer(player)if not hasDrawing or espLines[player] then return end;local lines={};for i=1,8 do local l=Drawing.new("Line");l.Thickness=2;l.Color=Color3.fromRGB(0,200,255);l.Visible=false;lines[i]=l end;local function txt(size,col)local t=Drawing.new("Text");t.Size=size;t.Center=true;t.Outline=true;t.Color=col;t.Visible=false;return t end;local tline=Drawing.new("Line");tline.Thickness=1.5;tline.Color=Color3.fromRGB(255,255,255);tline.Visible=false;espLines[player]={lines=lines,name=txt(14,Color3.fromRGB(255,255,255)),health=txt(12,Color3.fromRGB(0,255,100)),stud=txt(11,Color3.fromRGB(200,200,200)),tline=tline,hl=nil}end
local function RemoveESPForPlayer(player)local d=espLines[player];if not d then return end;for _,l in ipairs(d.lines) do pcall(function()l:Remove()end)end;for _,k in ipairs({"name","health","stud","tline"}) do pcall(function()d[k]:Remove()end)end;if d.hl then pcall(function()d.hl:Destroy()end)end;espLines[player]=nil end
local function ClearAllESP()for p in pairs(espLines) do RemoveESPForPlayer(p) end end
Hooks.ClearAllESP=ClearAllESP
local function UpdateESP()if not hasDrawing then return end;if not _G.ESP then for _,d in pairs(espLines) do hideESPData(d) end;return end;local cam=Workspace.CurrentCamera;if not cam then return end;local mode=espModes[espModeIndex];local myChar=LocalPlayer.Character;local myHrp=myChar and myChar:FindFirstChild("HumanoidRootPart");local vp=cam.ViewportSize
for _,player in ipairs(Players:GetPlayers()) do if player~=LocalPlayer then local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid");local show=hrp and hum and hum.Health>0
if show and mode.Team and LocalPlayer.Team and player.Team and LocalPlayer.Team==player.Team then show=false end
if show and #espTargetPlayers>0 and not table.find(espTargetPlayers,player) then show=false end
if not show then if espLines[player] then hideESPData(espLines[player]) end else if not espLines[player] then CreateESPForPlayer(player) end;local d=espLines[player];if d then if mode.Mode=="Highlight" then if not d.hl then d.hl=mk("Highlight",Workspace,{Name="ThanhESP",FillColor=Color3.fromRGB(255,0,0),OutlineColor=Color3.fromRGB(255,255,255),FillTransparency=0.5,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop})end;d.hl.Adornee=char;d.hl.Enabled=true elseif d.hl then d.hl.Enabled=false end
local pos,onScreen=cam:WorldToViewportPoint(hrp.Position);if onScreen and pos.Z>0 then local dist=myHrp and (hrp.Position-myHrp.Position).Magnitude or 0;local x,y=pos.X,pos.Y;local sizeY=cam:WorldToViewportPoint(hrp.Position+Vector3.new(0,3.5,0)).Y-cam:WorldToViewportPoint(hrp.Position-Vector3.new(0,3.5,0)).Y;if math.abs(sizeY)<18 then sizeY=18 end;sizeY=math.abs(sizeY);local sizeX=sizeY/1.5;local left,right,top,bottom=x-sizeX/2,x+sizeX/2,y-sizeY/2,y+sizeY/2;local len=sizeX/3;local ls=d.lines
ls[1].From,ls[1].To=Vector2.new(left,top),Vector2.new(left+len,top);ls[2].From,ls[2].To=Vector2.new(left,top),Vector2.new(left,top+len);ls[3].From,ls[3].To=Vector2.new(right,top),Vector2.new(right-len,top);ls[4].From,ls[4].To=Vector2.new(right,top),Vector2.new(right,top+len);ls[5].From,ls[5].To=Vector2.new(left,bottom),Vector2.new(left+len,bottom);ls[6].From,ls[6].To=Vector2.new(left,bottom),Vector2.new(left,bottom-len);ls[7].From,ls[7].To=Vector2.new(right,bottom),Vector2.new(right-len,bottom);ls[8].From,ls[8].To=Vector2.new(right,bottom),Vector2.new(right,bottom-len)
local boxOn=(mode.Mode=="Box");for _,l in ipairs(ls) do l.Visible=boxOn end
if mode.Line then d.tline.From=Vector2.new(vp.X/2,vp.Y);d.tline.To=Vector2.new(x,y);d.tline.Visible=true else d.tline.Visible=false end
if _G.ESPName then d.name.Text=player.Name;d.name.Position=Vector2.new(x,top-20);d.name.Visible=true else d.name.Visible=false end
if _G.ESPHealth then d.health.Text=math.floor(hum.Health/math.max(hum.MaxHealth,1)*100).."%";d.health.Position=Vector2.new(x,bottom+18);d.health.Visible=true else d.health.Visible=false end
if _G.ESPStud then d.stud.Text=math.floor(dist).." stud";d.stud.Position=Vector2.new(x,bottom+34);d.stud.Visible=true else d.stud.Visible=false end
else for _,l in ipairs(d.lines) do l.Visible=false end;d.name.Visible=false;d.health.Visible=false;d.stud.Visible=false;d.tline.Visible=false end end end end end end
RunService.RenderStepped:Connect(function()pcall(UpdateESP)end)
Players.PlayerAdded:Connect(function(p)if p~=LocalPlayer then CreateESPForPlayer(p) end end)
Players.PlayerRemoving:Connect(function(p)RemoveESPForPlayer(p)end)
-- AIMBOT / CHARACTER / LOOPS
local function GetClosest()if not HumanoidRootPart then return nil end;local target,dist=nil,math.huge;local myPos=HumanoidRootPart.Position;local myTeam=LocalPlayer.Team
for _,player in ipairs(Players:GetPlayers()) do if player~=LocalPlayer and player.Character then local hrp=player.Character:FindFirstChild("HumanoidRootPart");local hum=player.Character:FindFirstChildOfClass("Humanoid");if hrp and hum and hum.Health>0 then local skip=false;if _G.AimbotTeamCheck and myTeam and player.Team and myTeam==player.Team then skip=true end;if not skip and #aimbotTargetPlayers>0 and not table.find(aimbotTargetPlayers,player) then skip=true end;if not skip then local d=(hrp.Position-myPos).Magnitude;if _G.AimbotWallCheck and d>0 then local ray=Ray.new(myPos,(hrp.Position-myPos).Unit*d);local hitPart=Workspace:FindPartOnRay(ray,LocalPlayer.Character);if hitPart and not hitPart:IsDescendantOf(player.Character) then skip=true end end;if not skip and d<dist then dist=d;target=player end end end end end;return target end
local function RefreshCharacter(char)Character=char;Humanoid=char:WaitForChild("Humanoid");HumanoidRootPart=char:WaitForChild("HumanoidRootPart");pcall(function()Humanoid.UseJumpPower=true end);if _G.EnableSpeed then Humanoid.WalkSpeed=_G.WalkSpeed end;if _G.EnableJump then Humanoid.JumpPower=_G.JumpPower end;originalTransparency={};for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Decal") then originalTransparency[v]=v.Transparency end end;if _G.NoClip then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end;floatBV=nil;if _G.FloatChar then floatBV=mk("BodyPosition",HumanoidRootPart,{MaxForce=Vector3.new(0,math.huge,0),P=5000,D=1000,Position=HumanoidRootPart.Position})end end
LocalPlayer.CharacterAdded:Connect(RefreshCharacter)
if LocalPlayer.Character then task.spawn(RefreshCharacter,LocalPlayer.Character) end
local function setNoCollide(char)for _,p in pairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide=false end end end
RunService.Stepped:Connect(function()
    if Humanoid then
        if _G.EnableSpeed and Humanoid.WalkSpeed~=_G.WalkSpeed then Humanoid.WalkSpeed=_G.WalkSpeed end
        if _G.EnableJump then Humanoid.UseJumpPower=true;if Humanoid.JumpPower~=_G.JumpPower then Humanoid.JumpPower=_G.JumpPower end end
        if _G.AntiRagdoll then pcall(function()Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false);Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)end)end
        if _G.NoSit and Humanoid.Sit then Humanoid.Sit=false end
    end
    if _G.EnableGravity and Workspace.Gravity~=_G.Gravity then Workspace.Gravity=_G.Gravity end
    if Character and _G.NoClip then for _,v in pairs(Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end
    if HumanoidRootPart then if _G.AnchorChar then HumanoidRootPart.Anchored=true else HumanoidRootPart.Anchored=false end end
    if Character and _G.SpinEnabled and HumanoidRootPart then HumanoidRootPart.CFrame=HumanoidRootPart.CFrame*CFrame.Angles(0,math.rad(_G.SpinSpeed*2),0) end
    if _G.FloatChar and floatBV and floatBV.Parent and HumanoidRootPart then floatBV.Position=HumanoidRootPart.Position end
    if _G.RainbowChar and LocalPlayer.Character then local color=Color3.fromHSV(tick()%5/5,1,1);for _,v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.Color=color end end end
    if _G.ZoomEnabled and Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=70/math.max(_G.ZoomLevel,0.1) end
    if _G.AntiFling then for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then for _,part in pairs(p.Character:GetChildren()) do if part:IsA("BasePart") then part.CanCollide=false end end end end end
end)
RunService.Heartbeat:Connect(function(dt)
    local char=Character;local hrp,hum=HumanoidRootPart,Humanoid
    if not (char and char.Parent and hrp and hrp.Parent and hum) then return end
    if hum.Health<=0 then return end
    if _G.Aimbot then local target=GetClosest();local thrp=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart");if thrp then local tp=thrp.Position;hrp.CFrame=CFrame.new(hrp.Position,Vector3.new(tp.X,hrp.Position.Y,tp.Z)) end end
    if _G.Aimbot2 then local cam=Workspace.CurrentCamera;local target=GetClosest();local thrp=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart");if cam and thrp then cam.CFrame=CFrame.new(cam.CFrame.Position,thrp.Position) end end
    if _G.NoBatidao then hrp.Velocity=Vector3.new(0,0,0) end
    if _G.OrbitActive then local t=_G.OrbitTarget;local thrp=t and t.Character and t.Character:FindFirstChild("HumanoidRootPart");if thrp then _G.OrbitAngle=_G.OrbitAngle+_G.OrbitSpeed*dt*2;local tp=thrp.Position;local np=tp+Vector3.new(math.cos(_G.OrbitAngle)*_G.OrbitDistance,0,math.sin(_G.OrbitAngle)*_G.OrbitDistance);setNoCollide(char);hrp.CFrame=CFrame.new(np,tp);hrp.Velocity=Vector3.new(0,0,0) end
    elseif _G.FollowPlayer and _G.TargetPlayer and _G.TargetPlayer~="None" then local t=Players:FindFirstChild(_G.TargetPlayer);local thrp=t and t.Character and t.Character:FindFirstChild("HumanoidRootPart");if thrp then local tp=thrp.Position;local dist=_G.FollowDistance or 5;local mode=_G.FollowMode;local goal
        if mode=="Behind" then goal=CFrame.new((thrp.CFrame*CFrame.new(0,0,dist)).Position,tp)
        elseif mode=="Above" then goal=CFrame.new((thrp.CFrame*CFrame.new(0,dist,0)).Position,tp)
        elseif mode=="Under" then goal=CFrame.new((thrp.CFrame*CFrame.new(0,-dist,0)).Position,tp)
        elseif mode=="Inside" then setNoCollide(char);goal=thrp.CFrame
        elseif mode=="Orbit Target" then setNoCollide(char);local ang=tick()*_G.OrbitSpeed;local np=tp+Vector3.new(math.cos(ang)*_G.OrbitDistance,0,math.sin(ang)*_G.OrbitDistance);goal=CFrame.new(np,tp) end
        if goal then if _G.FollowTP then hrp.CFrame=goal else hrp.CFrame=hrp.CFrame:Lerp(goal,math.min(math.max(_G.FollowSpeed,0.1)*dt,1)) end;hrp.Velocity=Vector3.new(0,0,0) end
    end end
    if _G.WallClimb then local ray=Ray.new(hrp.Position,hrp.CFrame.LookVector*3);local part=Workspace:FindPartOnRay(ray,char);if part then hrp.Velocity=Vector3.new(hrp.Velocity.X,30,hrp.Velocity.Z) end end
    if _G.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then if hum.FloorMaterial~=Enum.Material.Air then hum.Jump=true end end
    if _G.HitboxExpander then for _,p in pairs(Players:GetPlayers()) do local targ=p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart");if targ then if not hitboxOrig[targ] then hitboxOrig[targ]={Size=targ.Size,Transparency=targ.Transparency,Material=targ.Material,Color=targ.Color} end;local s=_G.HitboxSize;if targ.Size.X~=s then targ.Size=Vector3.new(s,s,s) end;if _G.ShowHitbox then targ.Transparency=0.5;targ.Material=Enum.Material.ForceField;targ.Color=Color3.new(1,0,0) else targ.Transparency=1 end;targ.CanCollide=false end end end
    if _G.AirWalk then if not airWalkPart or not airWalkPart.Parent then airWalkPart=mk("Part",Workspace,{Name="ThanhAirWalk",Size=Vector3.new(5,1,5),Anchored=true,Transparency=1})end;airWalkPart.CFrame=hrp.CFrame*CFrame.new(0,-3.5,0) end
    if _G.AntiVoid then if hrp.Position.Y<(Workspace.FallenPartsDestroyHeight+50) then local spawnPos=Vector3.new(0,50,0);local spawnLocation=Workspace:FindFirstChildWhichIsA("SpawnLocation",true);if spawnLocation then spawnPos=spawnLocation.Position+Vector3.new(0,5,0) end;hrp.CFrame=CFrame.new(spawnPos);hrp.Velocity=Vector3.new(0,0,0) end end
end)
task.spawn(function()while ScreenGui and ScreenGui.Parent do if _G.AlwaysDay then pcall(function()Lighting.TimeOfDay="12:00:00" end)end;task.wait(0.1)end end)
task.spawn(function()while ScreenGui and ScreenGui.Parent do task.wait(3);if _G.ChatSpam then pcall(function()if TextChatService.ChatVersion==Enum.ChatVersion.TextChatService then local ch=TextChatService.TextChannels:FindFirstChild("RBXGeneral");if ch then ch:SendAsync(_G.SpamText) end else game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(_G.SpamText,"All") end end)end end end)
UserInputService.JumpRequest:Connect(function()if _G.InfiniteJump and Humanoid then Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)
LocalPlayer.Idled:Connect(function()if _G.AntiAFK then pcall(function()VirtualUser:CaptureController();VirtualUser:ClickButton2(Vector2.new())end)end end)
do local tapStart,tapTime=nil,0
local function doClickTP()pcall(function()local hit=Mouse.Hit;if hit and HumanoidRootPart then HumanoidRootPart.CFrame=CFrame.new(hit.Position+Vector3.new(0,4,0))end end)end
UserInputService.InputBegan:Connect(function(input,gp)if gp then return end;if input.UserInputType==Enum.UserInputType.Touch then tapStart=input.Position;tapTime=tick();return end;if input.UserInputType==Enum.UserInputType.MouseButton1 then if _G.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then doClickTP()end;return end;if input.UserInputType~=Enum.UserInputType.Keyboard then return end;local k=input.KeyCode;if k==Enum.KeyCode.F then runScript("FlyGuiV3","https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt") elseif k==Enum.KeyCode.V then local t=togglesById["invisible"];t.set(not t.get());t.refresh();Toast("Tàng hình: "..(_G.Invisible and "BẬT" or "TẮT"),"V") elseif k==Enum.KeyCode.N then local t=togglesById["noclip"];t.set(not t.get());t.refresh();Toast("Xuyên tường: "..(_G.NoClip and "BẬT" or "TẮT"),"N") elseif k==Enum.KeyCode.J then local t=togglesById["infjump"];t.set(not t.get());t.refresh();Toast("Nhảy vô hạn: "..(_G.InfiniteJump and "BẬT" or "TẮT"),"J") end end)
UserInputService.InputEnded:Connect(function(input)if input.UserInputType==Enum.UserInputType.Touch and tapStart then local moved=(input.Position-tapStart).Magnitude;if _G.ClickTP and moved<10 and (tick()-tapTime)<0.25 then doClickTP() end;tapStart=nil end end)end
local isAnimating=false
local function openMenu()if isAnimating or Frame.Visible then return end;isAnimating=true;Frame.Visible=true;Saturn.Visible=false;if uiScaleObj then uiScaleObj.Scale=Theme.uiScale*0.85 end;Frame.BackgroundTransparency=1;spring(blur,{Size=14},0.35,Enum.EasingStyle.Quad):Play();if uiScaleObj then spring(uiScaleObj,{Scale=Theme.uiScale},0.5):Play()end;spring(Frame,{BackgroundTransparency=Theme.uiTransparency},0.3,Enum.EasingStyle.Quad):Play();task.wait(0.5);isAnimating=false end
local function closeMenu()if isAnimating or not Frame.Visible then return end;isAnimating=true;spring(blur,{Size=0},0.35,Enum.EasingStyle.Quad):Play();spring(Frame,{BackgroundTransparency=1},0.25,Enum.EasingStyle.Quad):Play();if uiScaleObj then spring(uiScaleObj,{Scale=Theme.uiScale*0.85},0.3,Enum.EasingStyle.Quad):Play()end;saveConfig();task.wait(0.3);Frame.Visible=false;Frame.BackgroundTransparency=Theme.uiTransparency;if uiScaleObj then uiScaleObj.Scale=Theme.uiScale end;Saturn.Visible=true;isAnimating=false end
Hooks.closeMenu=closeMenu
Saturn.MouseButton1Click:Connect(function()if SaturnState.moved then SaturnState.moved=false;return end;if Frame.Visible then closeMenu() else openMenu() end end)
Close.MouseButton1Click:Connect(function()closeMenu();Toast("Đã đóng","x")end)
task.delay(0.9,function()iOS.Confirm({title="Thông báo",message="Thanh có tuất không?",yesText="Có",noText="Không",onYes=function()Toast("Đã chọn Có","+")end,onNo=function()Toast("Sai rồi, phải chọn Có","x");task.delay(0.6,function()pcall(function()LocalPlayer:Kick("Phải chọn có mới đúng")end)end)end})end)
Toast("Thạnh V4.9 đã load","+")
