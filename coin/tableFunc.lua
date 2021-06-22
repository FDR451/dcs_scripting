myTable = {
    name = "name1",
    repFunc = {
        func = nil,
        args = nil,
    }
}
function hello ()
    print ("hello")
end

function storeHello ()
    myTable.repFunc.func = hello
end

function runStoredFunc()
    myTable.repFunc.func(myTable.repFunc.args)
end

function helloString (args)
    print ("hello " .. args.string1 .. ", " .. args.string2) 
end

function storeHelloString ()
    myTable.repFunc.func = helloString
    myTable.repFunc.args = {string1 = "asdf2", string2 = "qwer2"}
end

myTable2 = {}

function addToTable(number)
    myTable2[number] = {string = "hello"}
end

function readMyTable2()
    for k, v in pairs (myTable2) do
        print (k, v.string)
    end
end


do
    --storeHello()
    storeHelloString()
    runStoredFunc()
    --helloString("asdf", "qwer")

    addToTable(3)
    addToTable(5)
    readMyTable2()




end