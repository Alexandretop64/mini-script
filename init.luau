local placeFolders = {
    [6243699076] = "Themimic/books/lobby/",
    [6296321810] = "Themimic/books/B1C1/",
    [7068737459] = "Themimic/books/Gamemode/",
}

local placeId: number = game.PlaceId
local templateCode: string = "https://raw.githubusercontent.com/Alexandretop64/mini-script/refs/heads/main/"

local folderPath = placeFolders[placeId]

if folderPath then
    local url = templateCode .. folderPath .. "main.luau"
    loadstring(game:HttpGet(url))()
end
