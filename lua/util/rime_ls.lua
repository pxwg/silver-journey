local M = {}

function M.check_rime_status()
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.name == "rime_ls" then
      return true
    end
  end
  return false
end

-- function is_rime_item(item)
--   if item == nil or item.source_name ~= "LSP" then
--     return false
--   end
--   local client = vim.lsp.get_client_by_id(item.client_id)
--   return client ~= nil and client.name == "rime_ls"
-- end
-- --- @param item blink.cmp.CompletionItem
--
-- function get_n_rime_item_index(n, items)
--   if items == nil then
--     items = require("blink.cmp.completion.list").items
--   end
--   local result = {}
--   if items == nil or #items == 0 then
--     return result
--   end
--   for i, item in ipairs(items) do
--     if is_rime_item(item) then
--       result[#result + 1] = i
--       if #result == n then
--         break
--       end
--     end
--   end
--   return result
-- end
--
-- function is_texlab_item(item)
--   if item == nil or item.source_name ~= "LSP" then
--     return false
--   end
--   local client = vim.lsp.get_client_by_id(item.client_id)
--   return client ~= nil and client.name == "texlab"
-- end

return M
