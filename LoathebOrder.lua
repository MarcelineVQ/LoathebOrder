local function extract_healers(input)
  local healers = {}
  local start_pos = 1
  local end_pos = 0
  for healer,next_pos in string.gfind(input, "%s*(%w+)%s*>%s*()") do
    table.insert(healers, healer)
    end_pos = next_pos
  end

  -- item after the last >
  if end_pos ~= 0 and end_pos <= string.len(input) then
    local _,_,name = string.find(string.sub(input,end_pos), "(%w+)")
    table.insert(healers, name)
  end

  return healers
end

local loathebFrame = CreateFrame("Frame")
loathebFrame:RegisterEvent("CHAT_MSG_RAID") -- arg1 msg, arg2 player
loathebFrame:RegisterEvent("CHAT_MSG_RAID_LEADER") -- arg1 msg, arg2 player
loathebFrame:RegisterEvent("CHAT_MSG_RAID_WARNING") -- arg1 msg, arg2 player
loathebFrame:SetScript("OnEvent", function ()
  if (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_WARNING" or event == "CHAT_MSG_RAID_LEADER")
     and string.find(arg1,">") then
    if string.find(string.lower(arg1),"loatheb") then
      local healers = extract_healers(arg1)

      -- Drop last if order is cyclical
      if healers[table.getn(healers)] == healers[1] then table.remove(healers) end

      for i,healer in ipairs(healers) do
        if string.lower(healer) == string.lower(UnitName("player")) then
          next_healer = (i == table.getn(healers)) and healers[1] or healers[i+1]
          break
        end
      end
    end
  end
end)

function loathebHealedMacro()
  -- Report if you're not on the healer list!
  if next_healer then
    SendChatMessage(UnitName("player").." Healed >>>> ".. next_healer.." Next","YELL")
  else
    DEFAULT_CHAT_FRAME:AddMessage("You have not been assigned to a Loatheb direct healing rotation.")
  end
end

SLASH_LOADTHEBORDER1 = "/loathebhealed";
SlashCmdList["LOADTHEBORDER"] = loathebHealedMacro
