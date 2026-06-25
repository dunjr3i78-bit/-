local Walls = script.Parent:WaitForChild("Walls")  -- 벽들이 들어있는 폴더

-- 설정
local DayDuration = 3 * 60  -- 낮: 3분 (180초)
local NightDuration = 1 * 60  -- 밤: 1분 (60초)
local CycleDuration = DayDuration + NightDuration  -- 전체 1일: 4분 (240초)

local CurrentDay = 0
local ElapsedTime = 0
local IsNight = false

-- 벽 그룹 설정 (3일, 6일마다 사라질 벽들)
-- 예: Wall_Day3, Wall_Day6
local WallGroups = {
	{day = 3, folder = Walls:WaitForChild("Wall_Day3")},
	{day = 6, folder = Walls:WaitForChild("Wall_Day6")}
}

local function RemoveWallGroup(wallFolder)
	for i, part in pairs(wallFolder:GetChildren()) do
		if part:IsA("BasePart") then
			part:Destroy()
		end
	end
	print("벽이 확장되었습니다!")
end

local function UpdateDay()
	CurrentDay = math.floor(ElapsedTime / CycleDuration) + 1
	IsNight = (ElapsedTime % CycleDuration) >= DayDuration
	
	-- 3일, 6일마다 해당 벽 제거
	for i, wallGroup in pairs(WallGroups) do
		if CurrentDay == wallGroup.day then
			RemoveWallGroup(wallGroup.folder)
		end
	end
end

-- 메인 루프
while true do
	wait(1)
	ElapsedTime = ElapsedTime + 1
	UpdateDay()
	
	-- 디버그: 현재 상태 출력 (선택사항)
	local TimeOfDay = IsNight and "밤" or "낮"
	print("현재 일수: "..CurrentDay.." | 시간: "..TimeOfDay)
end
