function load_tests()
    require("./arg_parsing")()
end

function run_tests()
    local frktest = require("@frktest/frktest")
    local console_reporter = require("@frktest/reporters/console_reporter")

    console_reporter.init()
    local success = frktest.run()
    return success
end

load_tests()
local passed = run_tests()

if not passed then
    require("@lune/process").exit(1)
end
