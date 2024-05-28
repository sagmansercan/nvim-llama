M = {}

M.run_command = function(cmd, args, callback)
    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local handle
    local function on_exit(code, signal)
        stdout:close()
        stderr:close()
        if handle then
            handle:close()
        end
        print('Process exited with code', code, 'and signal', signal)
    end

    handle = vim.loop.spawn(cmd, {
        args = args,
        stdio = { nil, stdout, stderr },
    }, vim.schedule_wrap(on_exit))

    local decode_failed_txt = ''

    vim.loop.read_start(stdout, function(err, data)
        assert(not err, err)
        if data then
            for _, line in ipairs(vim.split(data, '\n')) do
                print(line)
                if line == '' then
                    goto continue
                end

                if decode_failed_txt ~= '' then
                    line = decode_failed_txt .. line
                end

                local ok, decoded_line = pcall(vim.json.decode, line)
                if not ok then
                    decode_failed_txt = decode_failed_txt .. line
                    goto continue
                else
                    decode_failed_txt = ''
                end

                vim.schedule(function()
                    callback(decoded_line)
                end)

                ::continue::
            end
        end
    end)

    vim.loop.read_start(stderr, function(err, data)
        assert(not err, err)
        if data then
            print 'stderr:'
            print '>>>'
            print(data)
            print '<<<'
        end
    end)
end

return M
