table = {
    "a",
    "b",
    ["zee"] = "c",
    "d",
}

table.test = "tst"

function table.read ()

end

for k, v in pairs (table) do
    print (k, v)
end