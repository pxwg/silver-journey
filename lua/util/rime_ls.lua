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

return M
