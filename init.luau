local placeId = game.PlaceId

local baseUrl = "https://raw.githubusercontent.com/Alexandretop64/mini-script/main/"

local places = {
    [6243699076] = "The mimic/books/lobby"
}

local scriptPath = places[placeId]

if scriptPath then
    loadstring(game:HttpGet(baseUrl .. scriptPath .. ".luau"))()
else
    warn("Script não encontrado para esse PlaceId")
end