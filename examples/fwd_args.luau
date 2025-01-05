-- note: with lune, you have to use '--' after the script name, e.g.:
--     > lune run fwd_args.luau -- "my prefix:" -- a b c d

local frkcli = require("../src/frkcli")
local process = require("@lune/process")

local cli = frkcli.new("string_prefixer", "prefixes arg args passed after '--'")

cli:add_positional("prefix", {
    help = "The prefix to apply to args after '--'",
})

local parsed, err = cli:parse(process.args)

if err ~= nil then
    print(`error while parsing args: {err}`)
    process.exit(1)
end
assert(parsed)

local prefix: string = parsed.values.prefix

for _, v in parsed.fwd_args do
    print(`{prefix}{v}`)
end
