local frkcli = require("../src/frkcli")
local process = require("@lune/process")

local cli = frkcli.new_subcommands("math-cli", "An example of a cli implementing math operations with subcommands")

-- the return of add_subcommand() is the same object as the return of cli.new()
local command_add = cli:add_subcommand("add", "add 2 numbers")
command_add:add_positional("a", { help = "first number" })
command_add:add_positional("b", { help = "first number" })

local command_sub = cli:add_subcommand("sub", "subtract two numbers")
command_sub:add_positional("a", { help = "first number" })
command_sub:add_positional("b", { help = "first number" })

local command_round = cli:add_subcommand("round", "round a number")
command_round:add_positional("a", { help = "the number to round" })
command_round:add_option("dir", {
    help = "the rounding direction, [(down), up]",
    default = "down",
})

local res, err = cli:parse(process.args)
if err ~= nil then
    error(err)
end
assert(res ~= nil)

if res.command == "add" then
    local a = tonumber(res.result.values["a"])
    local b = tonumber(res.result.values["b"])
    if a == nil then
        error(`arg 'a' is not a numbr, got: {a}`)
    end
    if b == nil then
        error(`arg 'b' is not a number, got: {b}`)
    end
    print(`{a} + {b} = {a + b}`)
elseif res.command == "sub" then
    local a = tonumber(res.result.values["a"])
    local b = tonumber(res.result.values["b"])
    if a == nil then
        error(`arg 'a' is not a numbr, got: {a}`)
    end
    if b == nil then
        error(`arg 'b' is not a number, got: {b}`)
    end
    print(`{a} - {b} = {a - b}`)
elseif res.command == "round" then
    local a = tonumber(res.result.values["a"])
    if a == nil then
        error(`arg 'a' is not a numbr, got: {a}`)
    end
    local dir = res.result.values["dir"]
    local rounded
    if dir == "down" then
        rounded = math.floor(a)
    elseif dir == "up" then
        rounded = math.ceil(a)
    else
        error(`unexpected value for option 'dir': {dir}. Valid values are [down, up]`)
    end
    print(`round({a}, {dir}) = {rounded}`)
else
    error("this error should not be possible, command validation is done in parse")
end
