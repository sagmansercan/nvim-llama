local M = {}

M.default_opts = {
    model = 'llama3:latest',
}

M.opts = {}

-- example function
function M.setup(opts)
    opts = opts or {}
    M.opts = vim.tbl_extend('force', M.default_opts, opts)
    vim.api.nvim_command 'command! -range=% -nargs=* ExplainCode lua require("nvim-llama").explain_code(<f-args>)'
end

local function notify(message, level)
    vim.api.nvim_notify(message, level, {})
end

local function http_post_request(url, data, callback)
    local payload = vim.fn.json_encode(data)
    local headers = {
        'Content-Type: application/json',
        'Content-Length: ' .. #payload,
    }

    -- local response_body = {}
    local curl_job = vim.system({
        'curl',
        '-X',
        'POST',
        '-s',
        '-H',
        headers[1],
        '-H',
        headers[2],
        '-d',
        payload,
        url,
    }, {
        timeout = 60 * 1000,
        stdout = function(err, response_data)
            if response_data then
                -- table.insert(response_body, response_data)
                vim.schedule(function()
                    -- local result = table.concat(response_body, '\n')
                    callback(response_data, false)
                end)
            end
        end,
        stderr = function(err)
            vim.schedule(function()
                if err then
                    notify(err, vim.log.levels.ERROR)
                end
            end)
        end,
    }, function(system_completed_obj)
        vim.schedule(function()
            if system_completed_obj.code == 0 then
                notify('Request completed', vim.log.levels.INFO)
                return
            end
            if system_completed_obj.code == 124 then
                notify('Request timed out', vim.log.levels.ERROR)
                return
            end
            notify('Request failed with unhandled code ' .. system_completed_obj.code, vim.log.levels.ERROR)
        end)
    end)
end

local function write_to_buffer(buf, result, explanation)
    local result_table = vim.split(result, '\n')
    for _, line in ipairs(result_table) do
        local decoded = vim.fn.json_decode(line)
        if decoded and decoded.response then
            local decoded_split = vim.split(decoded.response, '\n')
            for _, response in ipairs(decoded_split) do
                explanation = explanation .. response
            end
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { explanation })
        end
    end
end

-- Function to run ollama with the selected code and explain what it does
function M.explain_code()
    local selected_lines = vim.fn.getline("'<", "'>")
    -- check type
    if type(selected_lines) == 'string' then
        selected_lines = vim.split(selected_lines, '\n')
    end

    local prompt = {}
    table.insert(prompt, 'Explain the below code:')
    table.insert(prompt, '---')
    for _, line in ipairs(selected_lines) do
        table.insert(prompt, line)
    end

    -- Construct the command to send to OLLaMa
    local model = M.opts.model
    local url = 'http://127.0.0.1:11434/api/generate'
    local data = {
        model = model,
        prompt = table.concat(prompt, '\n'),
        stream = false,
    }

    notify('Sending request to ' .. M.opts.model .. ' ...', vim.log.levels.INFO)

    -- get current cursor position to open the buffer
    local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = vim.o.columns - 80,
        height = vim.o.lines - 40,
        col = cursor_col,
        row = cursor_row,
        border = 'rounded',
    })
    http_post_request(url, data, function(result)
        local parsed_result = vim.fn.json_decode(result)
        if parsed_result and parsed_result.response then
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(parsed_result.response, '\n'))
        else
            if parsed_result.done then
                write_to_buffer(buf, result, { 'END' })
                notify('Request completed', vim.log.levels.INFO)
            end
            notify('Failed to get response from ollama', vim.log.levels.WARN)
        end
    end)
end

return M
