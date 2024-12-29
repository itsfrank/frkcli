local frkcli = require("../src/frkcli")
local process = require("@lune/process")

local cli = frkcli.new("sample_cli", "An exmaple cli using frkcli")

cli:add_positional("p1", {
    help = "A positional arg",
})

cli:add_positional("p2", {
    help = "A positional arg, that is optional",
    required = false,
    default = "hello",
})

cli:add_flag("foo", {
    aliases = { "-f" },
})

cli:add_option("opt", {
    help = "an option",
})

cli:add_option("optopt", {
    help = "an optional option",
    required = false,
    default = "goodbye",
})

local parsed, err = cli:parse(process.args)

if err ~= nil then
    print(`error while parsing args: {err}`)
    process.exit(1)
end
assert(parsed)

for k, v in parsed.values do
    print(`[{k}]: {v}`)
end
for k, v in parsed.flags do
    print(`[{k}]: {v}`)
end
