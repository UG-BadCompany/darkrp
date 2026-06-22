-- by p1ng :D

vox.scoreboard.ranks = vox.scoreboard.ranks or {}

function vox.scoreboard:GetRankData(rank)
    local rankData = vox.scoreboard.ranks[rank]
    if (rankData) then
        if (CLIENT) then
            local effectID = rankData.effectID
            local effectData, effectIndex = vox.scoreboard:FindNameEffect(effectID)

            rankData.effect = effectIndex
        end

        return rankData
    end
end
