DailyReward = {
    opcode = 155,
    storageLastClaim = 100104,
    storageConsecutive = 100100,
    storageLastDay = 100101,
    storageLastMonth = 100102,

    -- Lista completa de todos os itens confirmados
    pools = {
        senzus = {
            { id = 56744, clientId = 51689, count = 2,  name = "Brown Senzu" },
            { id = 56817, clientId = 51762, count = 2,  name = "Purple Senzu" },
            { id = 56745, clientId = 51690, count = 3,  name = "Blue Sky Senzu" },
            { id = 56697, clientId = 51642, count = 4,  name = "Yellow Senzu" },
            { id = 49694, clientId = 44639, count = 5,  name = "Red Senzu" },
            { id = 49695, clientId = 44640, count = 1,  name = "Senzu Especial A" },
            { id = 49696, clientId = 44641, count = 1,  name = "Senzu Especial B" },
            { id = 49693, clientId = 44638, count = 10, name = "Senzu Pack" },
            { id = 56818, clientId = 51763, count = 1,  name = "Mega Senzu" }
        },
        rare = {
            { id = 56406, clientId = 51351, count = 1, name = "Skill Potion 30min" },
            { id = 56407, clientId = 51352, count = 1, name = "Exp Potion 30min" },
            { id = 9971,  clientId = 9971,  count = 2, name = "Gold Ingot" }
        },
        ultra = {
            { id = 9971,  clientId = 9971,  count = 10, name = "Gold Ingot Cluster" },
            { id = 56406, clientId = 51351, count = 5,  name = "Skill Potion Pack" },
            { id = 56407, clientId = 51352, count = 5,  name = "Exp Potion Pack" }
        }
    },

    months = {},
    bonusItems = {}
}

function DailyReward.getDaysInMonth(month, year)
    local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 and year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
        return 29
    end
    return days[month] or 30
end

function DailyReward.setDayClaimed(mask, day)
    return mask + (2 ^ (day - 1))
end

function DailyReward.isDayClaimed(mask, day)
    return math.floor(mask / 2 ^ (day - 1)) % 2 == 1
end

-- FUNÇÃO MESTRE: Retorna o item fixo para um dia específico baseado em cálculo matemático
-- Isso garante que o item NUNCA mude entre reinicios do servidor.
function DailyReward.getItemForDate(day, month)
    local pool = DailyReward.pools.senzus
    if day % 7 == 0 then pool = DailyReward.pools.rare end
    if day % 15 == 0 then pool = DailyReward.pools.ultra end

    -- Fórmula determinística: (dia + (mês * 31)) cria um índice único e fixo para cada dia do ano
    local index = ((day + (month * 31)) % #pool) + 1
    local item = pool[index]

    return { id = item.id, clientId = item.clientId, count = item.count, name = item.name }
end

-- Gera os bônus de forma fixa também
function DailyReward.getBonusForStreak(streak)
    local pool = DailyReward.pools.rare
    if streak >= 20 then pool = DailyReward.pools.ultra end

    local index = (streak % #pool) + 1
    return pool[index]
end

-- Inicializa as tabelas de bônus fixas para o sistema usar
local bonusDays = { 5, 10, 15, 20, 25, 30 }
for _, streak in ipairs(bonusDays) do
    DailyReward.bonusItems[streak] = DailyReward.getBonusForStreak(streak)
end

-- Nota: Não precisamos mais pre-gerar 'months' em um loop gigante,
-- pois o servidor vai chamar DailyReward.getItemForDate(d, m) em tempo real,
-- e o resultado será sempre o mesmo para aquela data.
