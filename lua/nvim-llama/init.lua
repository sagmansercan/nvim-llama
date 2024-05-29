local M = {}

local http = require 'nvim-llama.http'

M.default_opts = {
    model = 'llama3:latest',
    ollama_host = 'http://127.0.0.1:11434',
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
    local url = M.opts.ollama_host .. '/api/generate'
    local data = {
        model = model,
        prompt = table.concat(prompt, '\n'),
        stream = true,
    }

    notify('Sending request to ' .. M.opts.model .. ' ...', vim.log.levels.INFO)

    -- get current cursor position to open the buffer
    -- local cursor_row = vim.api.nvim_win_get_cursor(0)[1]
    -- local cursor_col = vim.api.nvim_win_get_cursor(0)[2]
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = math.floor((50 * vim.o.columns) / 100),
        height = math.floor((80 * vim.o.lines) / 100),
        col = math.floor((2 * vim.o.columns) / 3),
        row = 7,
        border = 'rounded',
        style = 'minimal',
    })
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })

    -- send the request
    http.post(url, data, function(result)
        local last_line_number = vim.api.nvim_buf_line_count(buf) - 1 -- Zero-based index for lines
        local last_line = vim.api.nvim_buf_get_lines(buf, last_line_number, last_line_number + 1, false)[1] -- Get the last line
        last_line = last_line .. result.response

        vim.api.nvim_buf_set_lines(buf, last_line_number, last_line_number + 1, false, vim.split(last_line, '\n'))
    end)
end

return M
