local TeleportService = game:GetService("TeleportService")
local RemoteEvent = game.ReplicatedStorage:WaitForChild("Teleport")

local SurfaceGui = script.Parent.Gui:WaitForChild("SurfaceGui")

local TouchPart = script.Parent:WaitForChild("TouchPart")
local In = script.Parent:WaitForChild("In")
local Out = script.Parent:WaitForChild("Out")

--설정
local Id = 83150008176639
local CoolTime = 20
local MaxPlayer = 5
--]

local StartTime = CoolTime

local Players = {}
local Teleport = false

TouchPart.Touched:Connect(function(hit)
	local Humanoid = hit.Parent:FindFirstChild("Humanoid")
	local Value = false
	
	if hit and hit.Parent and Humanoid then
		local HumanoidRootPart = hit.Parent:FindFirstChild("HumanoidRootPart")
		
		if #Players < MaxPlayer and Teleport == false then
			local Player = game.Players:GetPlayerFromCharacter(hit.Parent)
			
			for i, v in pairs(Players) do
				if v == Player.Name then
					Value = true
				end
			end
			
			if not Value then
				RemoteEvent:FireClient(Player, false)
				table.insert(Players, Player.Name)

				HumanoidRootPart.Position = In.Position
			end
		end
	end
end)

RemoteEvent.OnServerEvent:Connect(function(Player)
	local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
	HumanoidRootPart.Position = Out.Position
	
	for i, v in pairs(Players) do
		if v == Player.Name then
			table.remove(Players, i)
		end
	end
end)

while wait(1) do
	if #Players > MaxPlayer then
		local Kick = Players[math.random(1, #Players)]
		table.remove(Players, Players[Kick])

		for i, v in pairs(game.Players:GetPlayers()) do
			if v == Kick.Name then
				local HumanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
				HumanoidRootPart.Position = Out.Position
			end
		end
	end

	CoolTime = CoolTime - 1
	SurfaceGui.Frame.Timer.Text = CoolTime
	SurfaceGui.Frame.Player.Text = #Players.." / "..MaxPlayer

	local Size = #Players/MaxPlayer
	SurfaceGui.Frame.Frame.Frame.Size = UDim2.new(Size, 0, 1, 0)

	if CoolTime <= 0 then
		Teleport = true
		CoolTime = StartTime

		if #Players > 0 then
			local TelPlayers = {}

			for i, PlayerName in pairs(Players) do
				local Player = game.Players[PlayerName]
				if Player then
					table.insert(TelPlayers, Player)
					RemoteEvent:FireClient(Player, true)
				end
			end

			local ReserveServer = TeleportService:ReserveServer(Id)
			TeleportService:TeleportToPrivateServer(Id, ReserveServer, TelPlayers)

			pcall(function()
				for i, v in pairs(Players) do
					table.remove(Players, 1)
				end
			end)
			
			wait(3)
		end

		Teleport = false
	end
end
