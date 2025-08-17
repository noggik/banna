repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer.Backpack
repeat task.wait() until game.Players.LocalPlayer.Character
repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui

local Services = setmetatable({}, {__index = function(Self, Index)
	return cloneref(game:GetService(Index))
end})
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local LocalUserId = LocalPlayer.UserId
local HttpService = Services.HttpService
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local VirtualUser = Services.VirtualUser
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService
local TeleportService = Services.TeleportService
local GuiService = Services.GuiService

local anticlip

AllFuncs = {}
Config = Config or {}

NPCList = {}
MobsName = {"Bandit","Shadow Werewolf","Forest Hunter","Pirate Bill","Pirate Officer","Desert Bandit","Desert Guardian","Frozen Warrior","Winter Soldier","Marine Officer","Celestial Bandit","Shadow Master","Prisoner","Dangerous Prisoner","Veteran Gladiator","Veteran Warrior","Magma Soldier","Magma Spy","Fishman","Triton Warrior","Divine Guardian","Shanda","Royal Squadron","Royal Soldier","Pirate Fighter","Pirate Henchman","Experiment #13","Experiment #14"}
BossList = {"King Werewolf", "Mad Clown", "Pharaoh", "Ice King", "Vice Admiral", "Admiral Vulkran" , "Lord Triton", "Wysper", "Thunder God", "Abandoned Experiment", "EX-77 Ironfist", "Wandering Soul"}
QuestNpcLists = {}

local SelectFarmMob = MobsName[1] or nil
local SelectedNPC = NPCList[1] or nil
local SelectedQuestNPC = QuestNpcLists[1] or nil

function LoadSettings()
	if readfile and writefile and isfile and isfolder then
		if not isfolder("Maeo Uan") then
			makefolder("Maeo Uan")
		end
		if not isfolder("Maeo Uan/Vox Seas/") then
			makefolder("Maeo Uan/Vox Seas/")
		end
		if not isfile("Maeo Uan/Vox Seas/" .. LocalPlayer.Name .. ".json") then
			writefile("Maeo Uan/Vox Seas/" .. LocalPlayer.Name .. ".json", HttpService:JSONEncode(Config))
		else
			local Decode = HttpService:JSONDecode(readfile("Maeo Uan/Vox Seas/" .. LocalPlayer.Name .. ".json"))
			for i,v in pairs(Decode) do
				Config[i] = v
			end
		end
	else
		return warn("Executor not support SAVE system")
	end
end
function SaveSettings()
	if readfile and writefile and isfile and isfolder then
		if not isfile("Maeo Uan/Vox Seas/" .. LocalPlayer.Name .. ".json") then
			LoadSettings()
		else
			local Decode = HttpService:JSONDecode(readfile("Maeo Uan/Vox Seas/" .. LocalPlayer.Name .. ".json"))
			local Array = {}
			for i,v in pairs(Config) do
				Array[i] = v
			end
			writefile("Maeo Uan/Vox Seas/" .. LocalPlayer.Name .. ".json", HttpService:JSONEncode(Array))
		end
	else
		return warn("Executor not support SAVE system")
	end
end
type tg_callback = {
	["SetValue"]: (boolean) -> ()
}
type tg_data = {
	["Title"]: string,
	["Default"]: boolean?,
	["Callback"]: ((boolean) -> ())?
}
local function AddToggle(Where: SharedTable, data: tg_data): tg_callback?
	data.Default = data.Default or false
	local threadRunning
	local oldCallback = data.Callback
	data.Callback = function(state: boolean)
		Config[data.Title] = state
		local fn = AllFuncs[data.Title]
		if fn then
			if state then
				threadRunning = task.spawn(fn)
			elseif threadRunning then
				task.cancel(threadRunning)
				threadRunning = nil
			end
		end
		if oldCallback then
			oldCallback(state)
		end
		SaveSettings()
	end
	return Where:Toggle({
		Title = data.Title,
		Value = data.Default,
		Callback = data.Callback
	})
end
type dd_data = {
	Title: string,
	Desc: string?,
	Image: string?,
	List: {string},
	Value: {string} | string | number,
	Multi: boolean?,
	Callback: (any) -> ()
}
local function AddDropdown(Where: any, data: dd_data): any?
	local oldCallback = data.Callback
	data.Callback = function(value)
		Config[data.Title] = value
		SaveSettings()
		if oldCallback then
			oldCallback(value)
		end
	end
	return Where:Dropdown({
		Title = data.Title,
		Desc = data.Desc,
		Image = data.Image,
		List = data.List,
		Value = data.Value,
		Multi = data.Multi or false,
		Callback = data.Callback
	})
end
type sl_data = {
	["Title"]: string,
	["Desc"]: string?,
	["Image"]: string?,
	["Default"]: number?,
	["Min"]: number,
	["Max"]: number,
	["Rounding"]: number,
	["Callback"]: (number) -> any
}
local function AddSlider(Where: SharedTable, data: sl_data): tg_callback?
	Config[data.Title] = data.Default or data.Min
	local old_callback = data.Callback
	data.Callback = function(num)
		Config[data.Title] = num
		SaveSettings()
		return old_callback(num)
	end
	return Where:Slider({
		Title = data.Title,
		Desc = data.Desc,
		Image = data.Image,
		Min = data.Min,
		Max = data.Max,
		Value = data.Default,
		Rounding = data.Rounding,
		Callback = data.Callback
	})
end
type bt_data = {
	Title: string,
	Description: string?,
	Image: string?,
	Callback: any
}
local function AddButton(Where: SharedTable, data: bt_data)
	local DataConverted = {
		Title = data.Title,
		Desc = data.Description,
		Image = data.Image,
		Callback = data.Callback
	}
	return Where:Button(DataConverted)
end
type para_data = {
	Title: string,
	Content: string?,
	Image: string?
}
local function AddLabel(Where: SharedTable, data: para_data)
	local DataConverted = {
		Title = data.Title,
		Desc = data.Content,
		Image = data.Image
	}
	return Where:Label(DataConverted)
end

task.spawn(function()
	while task.wait() do
		pcall(function()
			local isFarming = Config["Tp Select Location"] 
				or Config["Tp Select Npc"] or Config["Auto Farm Select Mob"] 
				or Config["Auto Sea Beast"] or Config["Auto Farm Boss"]
				or Config["Tp Select Quest Npc"]
			if not anticlip and isFarming then
				for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = false
					end
				end
				if not LocalPlayer.Character:FindFirstChildOfClass("Highlight") then
					local Highlight = Instance.new("Highlight", LocalPlayer.Character)
					Highlight.FillColor = Color3.fromRGB(252, 15, 255)
				end
				if not LocalPlayer.Character.PrimaryPart:FindFirstChild("Velocity") then
					local v = Instance.new("BodyVelocity",LocalPlayer.Character.PrimaryPart)
					v.Name = "Velocity"
					v.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
					v.Velocity = Vector3.new(0,0,0)
				end
			else
				if LocalPlayer.Character.PrimaryPart:FindFirstChild("Velocity") then
					LocalPlayer.Character.PrimaryPart:FindFirstChild("Velocity"):Destroy()
				end
				if LocalPlayer.Character:FindFirstChildOfClass("Highlight") then
					LocalPlayer.Character:FindFirstChildOfClass("Highlight"):Destroy()
				end
			end
		end)
	end
end)


EquipWeapon = function(...)
	local Get = { ... }
	if Get[1] and Get[1] ~= "" then
		if LocalPlayer.Backpack:FindFirstChild(tostring(Get[1])) then
			local tool = LocalPlayer.Backpack:FindFirstChild(tostring(Get[1]))
			task.wait()
			LocalPlayer.Character.Humanoid:EquipTool(tool)
		end
	end
end




local TeleportLocations = {
	["Air Jump"] = CFrame.new(3272.91992, 80.2837372, -4168.47998, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	["Ashforge Bastion"] = CFrame.new(4050.42139, -1407.29724, -8088.87695, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	["Central Town"] = CFrame.new(2039.75745, 92.8296509, 593.561279, -0.965929747, 0, -0.258804798, 0, 1, 0, 0.258804798, 0, -0.965929747),
	["Coliseum"] = CFrame.new(-4136.40332, -0.184899807, -2431.8689, -0.709507823, 0, 0.704697609, 0, 1, 0, -0.704697609, 0, -0.709507823),
	["Dark Arena"] = CFrame.new(-5394.69531, 20.9786854, 2131.09082, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	["Foosha Village"] = CFrame.new(1666.15942, 60.3700294, -980.832397, 0.199607015, -0, -0.979876101, 0, 1, -0, 0.979876101, 0, 0.199607015),
	["Fountain"] = CFrame.new(11044.1777, 297.897278, 767.625977, 0.999829352, 0, 0.0184721258, 0, 1, 0, -0.0184721258, 0, 0.999829352),
	["Frost Island"] = CFrame.new(-778.603271, 121.59742, -200.19017, -0.982488275, 0, -0.186325014, 0, 1, 0, 0.186325014, 0, -0.982488275),
	["Marine Ford"] = CFrame.new(-758.341919, 106.421036, -4891.03418, 0.676866055, -0.112547696, 0.727451265, 0.111930445, 0.992487133, 0.0494056679, -0.727546513, 0.04798292, 0.684378386),
	["Marine Island"] = CFrame.new(5084.67041, 143.451065, -2849.65405, -0.171070218, -5.55732222e-05, -0.985259056, 5.55732222e-05, 1, -6.60538353e-05, 0.985259056, -6.60538353e-05, -0.171070218),
	["Orange Town"] = CFrame.new(-837.747681, 121.598526, 2921.83789, -0.933674097, -0.0474138446, 0.354972303, -0.0323541872, 0.9983114, 0.0482446924, -0.356660366, 0.0335599631, -0.933631539),
	["Prison"] = CFrame.new(1693.58179, 242.269333, 3870.13647, 0.983647585, 0, 0.180103794, 0, 1, 0, -0.180103794, 0, 0.983647585),
	["Sandstorm Island"] = CFrame.new(6091.81641, 165.458588, 5296.30908, 0.190516412, -0, -0.981684029, 0, 1, -0, 0.981684029, 0, 0.190516412),
	["Sharkman Park"] = CFrame.new(10841.7529, 149.405914, -3429.22998, -0.735953927, -0.0155594973, 0.676852763, -0.0172527134, 0.999842227, 0.00422520144, -0.676811755, -0.00856799446, -0.736106277),
	["Shipwreck"] = CFrame.new(342.212341, 1.07004738, 6059.96191, -0.429489255, -0.268271863, -0.862304628, 1.65551901e-05, 0.954854667, -0.297073364, 0.903072059, -0.127604067, -0.410095334),
	["Skypie Down"] = CFrame.new(7948.78564, 395.485016, -5113.61133, -0.782074213, 0, 0.623185515, 0, 1, 0, -0.623185515, 0, -0.782074213),
	["Skypie Upper"] = CFrame.new(6926.26758, 1000.80078, -5739.48047, 0.474434793, -0, -0.880290687, 0, 1, -0, 0.880290687, 0, 0.474434793),
	["Vulcan Island"] = CFrame.new(4158.97412, 133.766876, -9205.94336, -0.999776363, 0, 0.0211477112, 0, 1, 0, -0.0211477112, 0, -0.999776363),
	["Werewolf's Island"] = CFrame.new(5910.94678, 126.9077, 655.520508, 0.40539825, -0, -0.914140165, 0, 1, -0, 0.914140165, 0, 0.40539825),
}
local LocationList = {}
for locationName, _ in pairs(TeleportLocations) do
	table.insert(LocationList, locationName)
end

local SelectedLocation = LocationList[1] or nil

function TP(P)
	local Distance = (P.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude 
	local Speed = 200
	tweenService, tweenInfo = game:GetService("TweenService"), TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear)
	tween = tweenService:Create(game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart, tweenInfo, {CFrame = P})
	tween:Play()
end

local methodss = function()
	if Config['Method'] and Config['Distance'] then
		if Config['Method'] == "Behind" then
			return CFrame.new(0, 0,Config['Distance'])
		elseif Config['Method'] == "Below" then
			return CFrame.new(0,-Config['Distance'],0) * CFrame.Angles(math.rad(90), 0, 0)
		elseif Config['Method'] == "Over" then
			return CFrame.new(0,Config['Distance'], 0) * CFrame.Angles(math.rad(-90), 0, 0)
		end
	end
end

local MultiAttack = function(Mob: Path)
	local args = {
		[1] = "DealDamage",
		[2] = {
			["Results"] = {
				[1] = Mob,[2] = Mob,[3] = Mob,[4] = Mob,[5] = Mob,
				[6] = Mob,[7] = Mob,[8] = Mob,[9] = Mob,[10] = Mob,
			},
			["Combo"] = 4,
		}
	}
	ReplicatedStorage:WaitForChild("BetweenSides"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("CombatEvent"):FireServer(unpack(args))
end

function MultiAttack100Hit(Mob)
	local args = {
		[1] = "DealDamage",
		[2] = {
			["Results"] = {
				[1] = Mob,[2] = Mob,[3] = Mob,[4] = Mob,[5] = Mob,
				[6] = Mob,[7] = Mob,[8] = Mob,[9] = Mob,[10] = Mob,
				[11] = Mob,[12] = Mob,[13] = Mob,[14] = Mob,[15] = Mob,
				[16] = Mob,[17] = Mob,[18] = Mob,[19] = Mob,[20] = Mob,
				[21] = Mob,[22] = Mob,[23] = Mob,[24] = Mob,[25] = Mob,
				[26] = Mob,[27] = Mob,[28] = Mob,[29] = Mob,[30] = Mob,
				[31] = Mob,[32] = Mob,[33] = Mob,[34] = Mob,[35] = Mob,
				[36] = Mob,[37] = Mob,[38] = Mob,[39] = Mob,[40] = Mob,
				[41] = Mob,[42] = Mob,[43] = Mob,[44] = Mob,[45] = Mob,
				[46] = Mob,[47] = Mob,[48] = Mob,[49] = Mob,[50] = Mob,
				[51] = Mob,[52] = Mob,[53] = Mob,[54] = Mob,[55] = Mob,
				[56] = Mob,[57] = Mob,[58] = Mob,[59] = Mob,[60] = Mob,
				[61] = Mob,[62] = Mob,[63] = Mob,[64] = Mob,[65] = Mob,
				[66] = Mob,[67] = Mob,[68] = Mob,[69] = Mob,[70] = Mob,
				[71] = Mob,[72] = Mob,[73] = Mob,[74] = Mob,[75] = Mob,
				[76] = Mob,[77] = Mob,[78] = Mob,[79] = Mob,[80] = Mob,
				[81] = Mob,[82] = Mob,[83] = Mob,[84] = Mob,[85] = Mob,
				[86] = Mob,[87] = Mob,[88] = Mob,[89] = Mob,[90] = Mob,
				[91] = Mob,[92] = Mob,[93] = Mob,[94] = Mob,[95] = Mob,
				[96] = Mob,[97] = Mob,[98] = Mob,[99] = Mob,[100] = Mob,
			},
			["Combo"] = 4,
		}
	}
	game:GetService("ReplicatedStorage"):WaitForChild("BetweenSides"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("CombatEvent"):FireServer(unpack(args))
end

AllFuncs["Tp Select Location"] = function()
	while Config["Tp Select Location"] do
		local targetLocation = TeleportLocations[SelectedLocation]
		if targetLocation and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			TP(targetLocation)
		end
		wait(0.1)
	end
end

for _,v in next, workspace.IgnoreList.Int.NPCs.Shops:GetChildren() do
	if v:IsA("Folder") then
		if v:FindFirstChildOfClass("Model") then
			for _,NpcShop in next, v:GetChildren() do
				if NpcShop:IsA("Model") then
					table.insert(NPCList, NpcShop.Name)
				end
			end
		end
	end
end


AllFuncs["Tp Select Npc"] = function()
	while Config["Tp Select Npc"] do task.wait()
		xpcall(function()
			for _,v in next, workspace.IgnoreList.Int.NPCs.Shops:GetChildren() do
				if v:IsA("Folder") then
					if v:FindFirstChildOfClass("Model") then
						for _,NpcShop in next, v:GetChildren() do
							if NpcShop:IsA("Model") and NpcShop.Name == SelectedNPC then
								TP(NpcShop.HumanoidRootPart.CFrame * CFrame.new(0,0,-2))
							end
						end
					end
				end
			end
		end, print)
	end
end

AllFuncs["Tp Select Quest Npc"] = function()
	while Config["Tp Select Quest Npc"] do task.wait()
		xpcall(function()
			for _,v in next, workspace.IgnoreList.Int.NPCs.Quests:GetChildren() do
				if v:IsA("Folder") then
					if v:FindFirstChildOfClass("Model") then
						for _,NpcQuest in next, v:GetChildren() do
							if NpcQuest:IsA("Model") and NpcQuest.Name == SelectedQuestNPC then
								TP(NpcQuest.HumanoidRootPart.CFrame * CFrame.new(0,0,-2))
							end
						end
					end
				end
			end
		end, print)
	end
end



--for _,v in next, workspace.Playability.Enemys:GetChildren() do
--	if v:IsA("Folder") then
--		for _,Mob in next, v:GetChildren() do
--			local NameMob = Mob.Name:gsub("%d+$", "")

--			if not table.find(MobsName, NameMob) then
--				table.insert(MobsName, NameMob)
--			end
--		end
--	end
--end

AllFuncs["Auto Farm Select Mob"] = function()
	while Config["Auto Farm Select Mob"] do task.wait()
		xpcall(function()
			for _,v in next, workspace.Playability.Enemys:GetChildren() do
				if v:IsA("Folder") then
					for _,Mob in next, v:GetChildren() do
						if Mob:IsA("Model") then
							if Mob.Name:match("^" .. SelectFarmMob .. "%d*$") then
								repeat task.wait()
									MultiAttack(Mob)

									TP(Mob.HumanoidRootPart.CFrame * methodss())
								until not Mob:GetAttribute("Respawned")
							end
						end
					end
				end
			end
		end, print)
	end
end

AllFuncs["Auto Skill"] = function()
	while Config["Auto Skill"] do task.wait()
		xpcall(function()
			for _,Skill in next, Config["Skill"] do
				game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[Skill], false, game)
				task.wait(0.1)
				game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode[Skill], false, game)
			end
		end, print)
	end
end

AllFuncs["Auto Sea Beast"] = function()
	while Config["Auto Sea Beast"] do task.wait()
		pcall(function()
			if workspace.Playability.SpecialEnemys:FindFirstChild("Sea Beast") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Playability.SpecialEnemys["Sea Beast"].HitboxPartHead.CFrame * methodss()
			end
		end)
	end
end





AllFuncs["Auto Farm Boss"] = function()
	while Config["Auto Farm Boss"] do task.wait()
		pcall(function()

			if Config["Select Boss"] then
				for _,v in next, workspace.Playability.Enemys:GetChildren() do
					if v:IsA("Folder") then
						for _,Mob in next, v:GetChildren() do
							if Mob:IsA("Model") then
								if Mob.Name:match("^" .. Config["Select Boss"] .. "%d*$") then
									repeat task.wait()
										MultiAttack(Mob)

										TP(Mob.HumanoidRootPart.CFrame * methodss())
									until not Mob:GetAttribute("Respawned")
								end
							end
						end
					end
				end
			end

		end)
	end
end

--Auto Quest

function GetQuest(NpcName: string, QuestName: string)
	local args = {
		[1] = "Quests",
		[2] = {
			["NpcName"] = NpcName,
			["QuestName"] = QuestName
		}
	}

	ReplicatedStorage:WaitForChild("BetweenSides"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("DialogueEvent"):FireServer(unpack(args))
end



AllFuncs["Auto Quest"] = function()
	while Config["Auto Quest"] do task.wait()
		pcall(function()

			if not string.find(LocalPlayer.PlayerGui.MainUI.MainFrame.CurrentQuest.Objective.Text, SelectFarmMob) then
				ReplicatedStorage:WaitForChild("BetweenSides"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("QuestEvent"):FireServer("CancelQuest")
			end

			if SelectFarmMob == "Bandit" then
				GetQuest("Bandits Hunter", "Defeat Bandits")
			elseif SelectFarmMob == "Shadow Werewolf" then
				GetQuest("Mark Hunter", "Defeat Shadow Werewolfs")
			elseif SelectFarmMob == "Forest Hunter" then
				GetQuest("Mark Hunter", "Defeat Forest Hunters")
			elseif SelectFarmMob == "Pirate Bill" then
				GetQuest("Joy Pirate Hunter", "Defeat Pirate Bills")
			elseif SelectFarmMob == "Pirate Officer" then
				GetQuest("Joy Pirate Hunter", "Defeat Pirate Officer")
			elseif SelectFarmMob == "Desert Bandit" then
				GetQuest("Paul", "Defeat Desert Bandits")
			elseif SelectFarmMob == "Desert Guardian" then
				GetQuest("Paul", "Defeat Desert Guardians")
			elseif SelectFarmMob == "Frozen Warrior" then
				GetQuest("Ryan Snow", "Defeat Frozen Warriors")
			elseif SelectFarmMob == "Winter Soldier" then
				GetQuest("Ryan Snow", "Defeat Winter Soldiers")
			elseif SelectFarmMob == "Marine Officer" then
				GetQuest("Olliver", "Defeat Marine Officers")
			elseif SelectFarmMob == "Celestial Bandit" then
				GetQuest("Pedro", "Defeat Celestial Bandits")
			elseif SelectFarmMob == "Shadow Master" then
				GetQuest("Pedro", "Defeat Shadow Masters")
			elseif SelectFarmMob == "Prisoner" then
				GetQuest("Jonas", "Defeat Prisoners")
			elseif SelectFarmMob == "Dangerous Prisoner" then
				GetQuest("Jonas", "Defeat Dangerous Prisoners")
			elseif SelectFarmMob == "Veteran Gladiator" then
				GetQuest("Dex", "Defeat Veteran Gladiators")
			elseif SelectFarmMob == "Veteran Warrior" then
				GetQuest("Dex", "Defeat Veteran Warrior")
			elseif SelectFarmMob == "Magma Soldier" then
				GetQuest("Clay", "Defeat Magma Soldiers")
			elseif SelectFarmMob == "Magma Spy" then
				GetQuest("Clay", "Defeat Magma Spys")
			elseif SelectFarmMob == "Fishman" then
				GetQuest("King Tritan", "Defeat Fishmans")
			elseif SelectFarmMob == "Triton Warrior" then
				GetQuest("King Tritan", "Defeat Triton Warriors")
			elseif SelectFarmMob == "Divine Guardian" then
				GetQuest("Jhon", "Defeat Divine Guardians")
			elseif SelectFarmMob == "Shanda" then
				GetQuest("Jhon", "Defeat Shandas")
			elseif SelectFarmMob == "Royal Squadron" then
				GetQuest("Sam", "Defeat Royal Squadrons")
			elseif SelectFarmMob == "Royal Soldier" then
				GetQuest("Sam", "Defeat Royal Soldier")
			elseif SelectFarmMob == "Pirate Fighter" then
				GetQuest("Arthur", "Defeat Pirate Fighters")
			elseif SelectFarmMob == "Pirate Henchman" then
				GetQuest("Arthur", "Defeat Pirate Henchmans")
			elseif SelectFarmMob == "Experiment #13" then
				GetQuest("Scientist", "Defeat Experiment #13")
			elseif SelectFarmMob == "Experiment #14" then
				GetQuest("Scientist", "Defeat Experiment #14")
			end
		end)
	end
end

AllFuncs["Auto Boss Quest"] = function()
	while Config["Auto Boss Quest"] do task.wait()
		xpcall(function()

			if not string.find(LocalPlayer.PlayerGui.MainUI.MainFrame.CurrentQuest.Objective.Text, Config["Select Boss"]) then
				ReplicatedStorage:WaitForChild("BetweenSides"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("QuestEvent"):FireServer("CancelQuest")
			end

			if Config["Select Boss"] == "King Werewolf" then
				GetQuest("Mark Hunter", "Defeat King Werewolf")
			elseif Config["Select Boss"] == "Mad Clown" then
				GetQuest("Joy Pirate Hunter", "Defeat Mad Clown")
			elseif Config["Select Boss"] == "Pharaoh" then
				GetQuest("Paul", "Defeat Pharaoh")
			elseif Config["Select Boss"] == "Ice King" then
				GetQuest("Ryan Snow", "Defeat Ice King")
			elseif Config["Select Boss"] == "Vice Admiral" then
				GetQuest("Olliver", "Defeat Vice Admiral")
			elseif Config["Select Boss"] == "Admiral Vulkran" then
				GetQuest("Clay", "Defeat Admiral Vulkran")
			elseif Config["Select Boss"] == "Lord Triton" then
				GetQuest("King Tritan", "Defeat Lord Triton")
			elseif Config["Select Boss"] == "Wysper" then
				GetQuest("Jhon", "Defeat Wysper")
			elseif Config["Select Boss"] == "Thunder God" then
				GetQuest("Sam", "Defeat Thunder God")
			elseif Config["Select Boss"] == "Abandoned Experiment" then
				GetQuest("Arthur", "Defeat Abandoned Experiment")
			elseif Config["Select Boss"] == "EX-77 Ironfist" then
				GetQuest("Scientist", "Defeat EX-77 Ironfist")
			end
		end, print)
	end
end



AllFuncs["Auto Chest"] = function()
	while Config["Auto Chest"] do task.wait()
		pcall(function()
			for _, chest in pairs(workspace.IgnoreList.Int.Chests:GetChildren()) do
				if chest:IsA("BasePart") and not chest:GetAttribute("InCooldown") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = chest.CFrame + Vector3.new(0, 5, 0)
					task.wait(0.5)
					break
				end
			end
		end)
	end
end

AllFuncs["Auto Use Ken"] = function()
	while Config["Auto Use Ken"] do task.wait()
		pcall(function()
			if not LocalPlayer.Character:GetAttribute("Kenbushoku") then
				ReplicatedStorage:WaitForChild("BetweenSides"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("MiscPowersEvent"):FireServer("Kenbushoku")
				task.wait(0.5)	
			end
		end)
	end
end

AllFuncs["Auto Use Buso"] = function()
	while Config["Auto Use Buso"] do task.wait()
		pcall(function()
			if not LocalPlayer.Character:GetAttribute("Busoshoku") then
				ReplicatedStorage:WaitForChild("BetweenSides"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("MiscPowersEvent"):FireServer("Busoshoku")
				task.wait(0.5)	
			end
		end)
	end
end



AllFuncs["Auto Blackbeard"] = function()
	while Config["Auto Blackbeard"] do task.wait()
		pcall(function()
			if workspace.Playability.SpecialEnemys:FindFirstChild("Blackbeard") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Playability.SpecialEnemys.Blackbeard.HumanoidRootPart.CFrame
				MultiAttack100Hit(workspace.Playability.SpecialEnemys.Blackbeard)
			end
		end)
	end
end


Weapon = {}

for _,v in next, LocalPlayer.Backpack:GetChildren() do
	if v:IsA("Tool") then
		table.insert(Weapon, v.Name)
	end
end

for _,v in next, LocalPlayer.Character:GetChildren() do
	if v:IsA("Tool") then
		table.insert(Weapon, v.Name)
	end
end

local function UpdateWeaponList()
	local weaponList = {}
	for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
		if tool:IsA("Tool") then
			table.insert(weaponList, tool.Name)
		end
	end
	if LocalPlayer.Character then
		for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(weaponList, tool.Name)
			end
		end
	end
	return weaponList
end


for _,v in next, workspace.IgnoreList.Int.NPCs.Quests:GetChildren() do
	if v:IsA("Folder") then
		if v:FindFirstChildOfClass("Model") then
			for _,QuestNpc in next, v:GetChildren() do
				if QuestNpc:IsA("Model") then
					table.insert(QuestNpcLists, QuestNpc.Name)
				end
			end
		end
	end
end




AllFuncs["Auto Equip"] = function()
	while Config["Auto Equip"] do task.wait()
		pcall(function()
			if Config["Select Weapon"] then
				for _,v in next, Config["Select Weapon"] do
					for _,ItemBackpack in next, LocalPlayer.Backpack:GetChildren() do
						if ItemBackpack:IsA("Tool") and ItemBackpack.Name == v then
							EquipWeapon(ItemBackpack.Name)
							task.wait()
						end
					end
				end
			end
		end)
	end
end



local function UpdateFruitList()
	local FruitList = {}
	for _, imageButton in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.AnotherMenus.FruitShopFrame.ScrollingFrame:GetChildren()) do
		if imageButton:IsA("ImageButton") and imageButton:FindFirstChild("FruitName") then
			local fruitName = imageButton.FruitName.Text
			local status = imageButton.Name == "InStockFrame" and "✅" or "❌"
			table.insert(FruitList, fruitName .. " " .. status)
		end
	end
	return FruitList
end




local function openFruitShop()
	local targetCFrame = CFrame.new(2021.43323, 27.757513, -1059.82874, -0.513770759, -4.67244554e-08, -0.857927501, -4.77656421e-08, 1, -2.58575081e-08, 0.857927501, 2.76946253e-08, -0.513770759)
	TP(targetCFrame)
	task.wait(2)

	local fruitDealer = workspace.IgnoreList.Int.NPCs.Shops["Foosha Village"]["Fruit Dealer (Foosha Village)"]
	local camera = workspace.CurrentCamera
	local VIM = game:GetService("VirtualInputManager")
	local head = fruitDealer:FindFirstChild("Head")

	if head then
		camera.CFrame = CFrame.lookAt(camera.CFrame.Position, head.Position)
		wait(0.1)
		VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
		VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
		wait(1)
		VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
		VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
		wait(1)

		local interact = function(path)
			repeat task.wait() game:GetService("GuiService").SelectedObject = path until game:GetService("GuiService").SelectedObject == path
			VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
			VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
			repeat task.wait() game:GetService("GuiService").SelectedObject = nil until game:GetService("GuiService").SelectedObject == nil
		end

		interact(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.MainFrame.Dialogue.Option1)
		camera.CameraType = Enum.CameraType.Custom
	end
end

local FruitMap = {
	["Kilo"] = 1, ["Divide"] = 2, ["Elastic"] = 3, ["Boom"] = 4, ["Dust"] = 5,
	["Blaze"] = 6, ["Shine"] = 7, ["Frozen"] = 8, ["Eclipse"] = 9, ["Vulcanic"] = 10,
	["Zen"] = 11, ["Mirror"] = 12, ["Orbit"] = 13, ["Poison"] = 14
}

AllFuncs["Auto Buy Fruit"] = function()
	while Config["Auto Buy Fruit"] do
		task.wait(1)
		pcall(function()
			if Config["Selected Fruit"] then
				local selectedFruit = Config["Selected Fruit"]:match("^(.-)%s*[✅❌]?$")

				for _, frame in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.AnotherMenus.FruitShopFrame.ScrollingFrame:GetChildren()) do
					if frame:IsA("ImageButton") and frame.Name == "InStockFrame" and frame:FindFirstChild("FruitName") then
						local fruitText = frame.FruitName.Text

						if fruitText == selectedFruit then
							local fruitId = FruitMap[fruitText]
							if fruitId then
								local Event = game:GetService("ReplicatedStorage").BetweenSides.Remotes.Events.FruitShopEvent
								Event:FireServer("Buy", fruitId)
								task.wait(5)
							end
						end
					end
				end
			end
		end)
	end
end

local FruitBuyList = {}
for fruitName, _ in pairs(FruitMap) do
	table.insert(FruitBuyList, fruitName)
end

AllFuncs["Auto Buy Fruit"] = function()
	while Config["Auto Buy Fruit"] do
		task.wait(5)
		pcall(function()
			if Config["Select Fruit to Buy"] then
				local selectedFruit = Config["Select Fruit to Buy"]

				for _, imageButton in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.AnotherMenus.FruitShopFrame.ScrollingFrame:GetChildren()) do
					if imageButton:IsA("ImageButton") and imageButton.Name == "InStockFrame" then
						if imageButton:FindFirstChild("FruitName") then
							local fruitNameText = imageButton.FruitName.Text

							if fruitNameText == selectedFruit then
								local fruitId = FruitMap[selectedFruit]
								if fruitId then
									local Event = game:GetService("ReplicatedStorage").BetweenSides.Remotes.Events.FruitShopEvent
									Event:FireServer("Buy", fruitId)
									task.wait(1)
								end
								break
							end
						end
					end
				end
			end
		end)
	end
end


LoadSettings()


local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Dummyrme/Library/refs/heads/main/Free.lua'))()
local Window = Library:Window({
	Title = 'Vox Sea | By Maeo Uan',
	Desc = 'Made By Candy, Xin',
	Icon = 97389610434708,
	Theme = 'Amethyst',
	Config = {
		Keybind = Enum.KeyCode.LeftControl,
		Size = UDim2.new(0, 530,0, 400)
	},
	CloseUIButton = {
		Enabled = true,
		Text = 'Hide'
	}
})
local Tabs = {
	Main = Window:Tab({Title = 'Main', Icon = 'align-left'}),
	Automathic = Window:Tab({Title = 'Automathic', Icon = 'align-left'}),
	TP = Window:Tab({Title = 'TP', Icon = 'map-pin'}),
	Setting = Window:Tab({Title = 'Setting', Icon = 'hammer'}),
}



Tabs.Main:Section({Title = 'Farming'})

AddDropdown(Tabs.Main, {
	Title = "Select Mob",
	Desc = "Choose Mob For Auto Farm",
	List = MobsName,
	Value = Config["Select Mob"],
	Callback = function(value)
		SelectFarmMob = value
	end
})

AddDropdown(Tabs.Main, {
	Title = "Select Method",
	Desc = "Choose Method For Auto Farm",
	List = {"Over", "Behind", "Below"},
	Value = Config["Select Method"],
	Callback = function(value)
		Config["Method"] = value
	end
})

AddSlider(Tabs.Main, {
	Title = "Distance",
	Desc = "",
	Image = "",
	Default = Config["Distance"],
	Min = 0,
	Max = 100,
	Value = 10,
	Rounding = 0,
	Callback = function(bool)
		Config["Distance"] = bool
	end
})

AddToggle(Tabs.Main, {
	Title = "Auto Farm Select Mob",
	Default = Config["Auto Farm Select Mob"],
	Callback = function(bool)

	end
})

AddToggle(Tabs.Main, {
	Title = "Auto Quest",
	Default = Config["Auto Quest"],
	Callback = function(bool)

	end
})

Tabs.Main:Section({Title = 'Haki'})

AddToggle(Tabs.Main, {
	Title = "Auto Use Buso",
	Default = Config["Auto Use Buso"],
	Callback = function(bool)

	end
})

AddToggle(Tabs.Main, {
	Title = "Auto Use Ken",
	Default = Config["Auto Use Ken"],
	Callback = function(bool)

	end
})

Tabs.Main:Section({Title = 'Boss'})



AddDropdown(Tabs.Main, {
	Title = "Select Boss",
	Desc = "Choose Boss For Auto Farm Boss",
	List = BossList,
	Multi = false,
	Value = Config["Select Boss"],
	Callback = function(value)
		Config["Select Boss"] = value
	end
})

AddToggle(Tabs.Main, {
	Title = "Auto Boss Quest",
	Default = Config["Auto Boss Quest"],
	Callback = function(bool)

	end
})

AddToggle(Tabs.Main, {
	Title = "Auto Farm Boss",
	Default = Config["Auto Farm Boss"],
	Callback = function(bool)

	end
})



Tabs.Main:Section({Title = 'Skill'})

AddDropdown(Tabs.Main, {
	Title = "Select Skill",
	Desc = "Choose Skill For Auto Farm",
	List = {"Z", "X", "C", "V", "F"},
	Multi = true,
	Value = Config["Select Skill"],
	Callback = function(value)
		Config["Skill"] = value
	end
})

AddToggle(Tabs.Main, {
	Title = "Auto Skill",
	Default = Config["Auto Skill"],
	Callback = function(bool)

	end
})



Tabs.Main:Section({Title = 'Equip Weapon'})

WeaponDropdown = AddDropdown(Tabs.Main, {
	Title = "Select Weapon",
	Desc = "Choose Weapon For Auto Farm",
	List = UpdateWeaponList(),
	Multi = true,
	Value = Config["Select Weapon"],
	Callback = function(value)
		Config["Select Weapon"] = value
	end
})

AddButton(Tabs.Main, {
	Title = "🔄 Refresh Weapons",
	Description = "Reload weapon list",
	Callback = function()
		local Weapons = UpdateWeaponList()
		WeaponDropdown:Clear()
		for _,v in next, Weapons do
			WeaponDropdown:Add(v)
		end
		
	end
})

--



AddToggle(Tabs.Main, {
	Title = "Auto Equip",
	Default = Config["Auto Equip"],
	Callback = function(bool)

	end
})



Tabs.Automathic:Section({Title = 'Chest'})

AddToggle(Tabs.Automathic, {
	Title = "Auto Chest",
	Default = Config["Auto Chest"],
	Callback = function(bool)

	end
})

Tabs.Automathic:Section({Title = 'Fruit'})



task.spawn(function()
	while true do
		task.wait(300)
		--FruitDropdown:SetList(UpdateFruitList())
	end
end)

AddDropdown(Tabs.Automathic, {
	Title = "Select Fruit to Buy",
	Desc = "Choose fruit to buy automatically",
	List = FruitBuyList,
	Value = Config["Select Fruit to Buy"],
	Callback = function(value)
		Config["Select Fruit to Buy"] = value
	end
})

AddToggle(Tabs.Automathic, {
	Title = "Auto Buy Fruit",
	Default = Config["Auto Buy Fruit"],
	Callback = function(bool)
	end
})
Tabs.Automathic:Section({Title = 'ใช้ Open Fruit shop ก่อน Auto Buy ทุกครั้ง'})


AddButton(Tabs.Automathic, {
	Title = "Open Fruit Shop",
	Callback = openFruitShop
})






Tabs.TP:Section({Title = 'Teleport Location'})

AddDropdown(Tabs.TP, {
	Title = "Select Island Location",
	Desc = "Choose teleport destination",
	List = LocationList,
	Value = Config["Select Island Location"],
	Callback = function(value)
		SelectedLocation = value
	end
})

AddToggle(Tabs.TP, {
	Title = "Tp Select Location",
	Default = Config["Tp Select Location"],
	Callback = function(bool)
	end
})


AddDropdown(Tabs.TP, {
	Title = "Select Npc",
	Desc = "Select NPC to teleport",
	List = NPCList,
	Value = Config["Select Npc"],
	Callback = function(value)
		SelectedNPC = value
	end
})

AddToggle(Tabs.TP, {
	Title = "Tp Select Npc",
	Default = Config["Tp Select Npc"],
	Callback = function(bool)
	end
})

AddDropdown(Tabs.TP, {
	Title = "Select Quest Npc",
	Desc = "Select Quest Npc to teleport",
	List = QuestNpcLists,
	Value = Config["Select Quest Npc"],
	Callback = function(value)
		SelectedQuestNPC = value
	end
})

AddToggle(Tabs.TP, {
	Title = "Tp Select Quest Npc",
	Default = Config["Tp Select Quest Npc"],
	Callback = function(bool)
	end
})




Tabs.Setting:Section({Title = 'Settings'})

AddButton(Tabs.Setting, {
	Title = "Remove Fog",
	Desc = "",
	Callback = function()
		game:GetService("Lighting").Atmosphere:Destroy()
	end
})

AddButton(Tabs.Setting, {
	Title = "Remove Effect",
	Desc = "",
	Callback = function()
		pcall(function()
			ReplicatedStorage.Assets.FX.Combat:Destroy()
			ReplicatedStorage.Assets.FX.DamageIndicator:Destroy()
			ReplicatedStorage.Assets.FX.WaterSplash:Destroy()
			ReplicatedStorage.Assets.FX.WaterSplash2:Destroy()
			ReplicatedStorage.Assets.FX.DamageCounter:Destroy()
			ReplicatedStorage.Assets.FX.Misc:Destroy()
		end)
	end
})


LocalPlayer.Idled:Connect(function()
	game:GetService("VirtualUser"):CaptureController()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)