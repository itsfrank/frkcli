local frktest = require("@frktest/frktest")
local test = frktest.test
local chk = frktest.assert.check
local req = frktest.assert.require

local frkcli = require("@frkcli/frkcli")

return function()
    test.suite("arg names", function()
        local testdata = {
            {
                opt_name = "foo",
                arg_name = "--foo",
            },
            {
                opt_name = "--foo",
                arg_name = "--foo",
            },
            {
                opt_name = "-foo",
                arg_name = "-foo",
            },
            { -- i guess you can do this if you want??
                opt_name = "---foo",
                arg_name = "---foo",
            },
        }

        for _, tt in testdata do
            test.case("option with name: " .. tt.opt_name, function()
                local cli = frkcli.new("t")
                cli:add_option(tt.opt_name, { default = "not found" })

                local res, err = cli:parse({ tt.arg_name, "bar" })
                chk.equal(err, nil)
                req.not_nil(res)

                chk.table.equal(res.values, { foo = "bar" })
            end)
            test.case("flag with name: " .. tt.opt_name, function()
                local cli = frkcli.new("t")
                cli:add_flag(tt.opt_name)

                local res, err = cli:parse({ tt.arg_name })
                chk.equal(err, nil)
                req.not_nil(res)

                chk.table.equal(res.flags, { foo = true })
            end)
        end
    end)

    test.suite("creation errors", function()
        test.case("position and option with same name", function()
            chk.should_error(function()
                local cli = frkcli.new("t")
                cli:add_positional("a")
                cli:add_option("a")
            end)
        end)
        test.case("flags cant have defaults", function()
            chk.should_error(function()
                local cli = frkcli.new("t")
                cli:add_flag("f", { default = false })
            end)
        end)
        test.case("positionals cant have dashes", function()
            chk.should_error(function()
                local cli = frkcli.new("t")
                cli:add_positional("--foo")
            end)
        end)
    end)

    test.suite("arg parsing errors", function()
        local cli = frkcli.new("test_cli")
        cli:add_positional("p1")
        cli:add_option("o1")

        local testdata = {
            {
                name = "no args",
                args_in = {},
                err_exp = "required positional arg 'p1' was not found",
            },
            {
                name = "missing positional",
                args_in = { "--o1", "foo" },
                err_exp = "required positional arg 'p1' was not found",
            },
            {
                name = "missing option",
                args_in = { "foo" },
                err_exp = "required option arg 'o1' was not found",
            },
            {
                name = "missing option data",
                args_in = { "foo", "--o1" },
                err_exp = "no value provided for option '--o1'",
            },
        }

        for _, tt in testdata do
            test.case(tt.name, function()
                local res, err = cli:parse(tt.args_in)

                chk.equal(res, nil)
                req.not_nil(err)
                chk.equal(err, tt.err_exp)
            end)
        end
    end)

    test.suite("default arg parsing", function()
        local cli = frkcli.new("test_cli")
        cli:add_positional("p1", { default = "p1" })
        cli:add_option("o1", { default = "o1" })
        cli:add_flag("f")

        local testdata = {
            {
                name = "no args",
                args_in = {},
                res_exp = {
                    flags = { f = false },
                    values = { p1 = "p1", o1 = "o1" },
                    fwd_args = {},
                },
            },
            {
                name = "pos only",
                args_in = { "foo" },
                res_exp = {
                    flags = { f = false },
                    values = { p1 = "foo", o1 = "o1" },
                    fwd_args = {},
                },
            },
            {
                name = "opt only",
                args_in = { "--o1", "foo" },
                res_exp = {
                    flags = { f = false },
                    values = { p1 = "p1", o1 = "foo" },
                    fwd_args = {},
                },
            },
            {
                name = "flag only",
                args_in = { "--f" },
                res_exp = {
                    flags = { f = true },
                    values = { p1 = "p1", o1 = "o1" },
                    fwd_args = {},
                },
            },
            {
                name = "all",
                args_in = { "foo", "--o1", "bar", "--f" },
                res_exp = {
                    flags = { f = true },
                    values = { p1 = "foo", o1 = "bar" },
                    fwd_args = {},
                },
            },
            {
                name = "all positional in middle",
                args_in = { "--o1", "bar", "foo", "--f" },
                res_exp = {
                    flags = { f = true },
                    values = { p1 = "foo", o1 = "bar" },
                    fwd_args = {},
                },
            },
        }

        for _, tt in testdata do
            test.case(tt.name, function()
                local res, err = cli:parse(tt.args_in)

                chk.equal(err, nil)
                req.not_nil(res)

                chk.table.equal(res, tt.res_exp)
            end)
        end
    end)
end
