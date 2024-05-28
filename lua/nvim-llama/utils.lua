M = {}

M.notify = function(message, level)
    level = level or vim.log.levels.INFO

    if type(level) == 'string' then
        if level == 'i' then
            level = vim.log.levels.INFO
        end
        if level == 'w' then
            level = vim.log.levels.WARN
        end
        if level == 'e' then
            level = vim.log.levels.ERROR
        end
        level = vim.log.levels.INFO
    end
    vim.notify(message, level)

    -- if type(message) == 'string' then
    --     message = { message }
    -- end
    --
    -- for _, msg in ipairs(vim.split(message, '\n')) do
    --     if type(msg) == 'table' then
    --         for _, m in ipairs(msg) do
    --             if type(m) == 'table' then
    --                 for _, n in ipairs(m) do
    --                     vim.notify(n, level)
    --                 end
    --             else
    --                 vim.notify(m, level)
    --             end
    --         end
    --     else
    --         vim.notify(msg, level)
    --     end
    -- end
end

return M
