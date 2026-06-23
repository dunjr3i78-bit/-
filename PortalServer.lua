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
local TimerActive = false

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
				
				-- 첫 번째 사람이 들어오면 타이머 시작
				if #Players == 1 then
					TimerActive = true
					CoolTime = StartTime
				end
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
	
	-- 모든 사람이 나가면 타이머 멈춤
	if #Players == 0 then
		TimerActive = false
		CoolTime = StartTime
	end
end)

while wait(1) do
	if #Players > MaxPlayer then
		local Kick = Players[math.random(1, #Players)]
		table.remove(Players, 1)

		for i, v in pairs(game.Players:GetPlayers()) do
			if v.Name == Kick then
				local HumanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
				if HumanoidRootPart then
					HumanoidRootPart.Position = Out.Position
				end
			end
		end
	end

	-- 타이머가 활성화되어 있을 때만 카운트다운
	if TimerActive and #Players > 0 then
		CoolTime = CoolTime - 1
		
		SurfaceGui.Frame.Timer.Text = CoolTime
		SurfaceGui.Frame.Player.Text = #Players.." / "..MaxPlayer

		local Size = #Players/MaxPlayer
		SurfaceGui.Frame.Frame.Frame.Size = UDim2.new(Size, 0, 1, 0)

		if CoolTime <= 0 then
			Teleport = true
			CoolTime = StartTime
			TimerActive = false

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
					for i = #Players, 1, -1 do
						table.remove(Players, i)
					end
				end)
				
				wait(3)
			end

			Teleport = false
		end
	else
		-- 사람이 없으면 UI 초기화
		if #Players == 0 then
			SurfaceGui.Frame.Timer.Text = StartTime
			SurfaceGui.Frame.Player.Text = "0 / "..MaxPlayer
			SurfaceGui.Frame.Frame.Frame.Size = UDim2.new(0, 0, 1, 0)
		end
	end
end
