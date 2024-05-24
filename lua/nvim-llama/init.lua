local M = {}

-- example function
function M.setup()
    print 'Nvim-llama loaded successfully!'
    vim.api.nvim_command 'command! -range=% -nargs=* ExplainCode lua require("nvim-llama").explain_code(<f-args>)'
end

-- Function to run ollama with the selected code and explain what it does
function M.explain_code()
    local selected_lines = vim.fn.getline("'<", "'>")
    local code = table.concat(selected_lines, '\n')

    -- Construct the command to send to OLLaMa
    local command = 'ollama run llama3:latest "EXPLAIN CODE: \n' .. code .. '"'
    local result = vim.fn.system(command)
    result = result:gsub('[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]', '')

    -- Create a new buffer and set its contents to the result of the command
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, '\n'))
    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = vim.o.columns - 20,
        height = vim.o.lines - 10,
        col = 10,
        row = 5,
        border = 'rounded',
    })
end

return M
