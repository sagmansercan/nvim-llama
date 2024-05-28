M = {}
local U = require 'nvim-llama.utils'
local C = require 'nvim-llama.cli'

M.post = function(url, data, callback)
    local body = vim.fn.json_encode(data)
    local headers = {
        'Content-Type: application/json',
        'Content-Length: ' .. #body,
    }

    local cmd = 'curl'
    local args = {}
    table.insert(args, '-X')
    table.insert(args, 'POST')
    table.insert(args, '-s')
    table.insert(args, '-H')
    for _, header in ipairs(headers) do
        table.insert(args, header)
    end
    table.insert(args, '-d')
    table.insert(args, body)
    table.insert(args, url)

    C.run_command(cmd, args, callback)
end

return M
