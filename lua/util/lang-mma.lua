local M = {}

function M.spin_notify()
  if notify_state then
    vim.notify("Completed!", "info", {
      id = "lsp_progress",
      title = "LSP Progress",
      icon = "✔",
    })
    _G.notify_state = false
  else
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    local function update_spinner()
      if notify_state then
        vim.notify("Wolfram-Lsp Launching", "info", {
          id = "lsp_progress",
          title = "LSP Progress",
          icon = spinner[math.floor(vim.loop.hrtime() / (1e6 * 80)) % #spinner + 1],
        })
        vim.defer_fn(update_spinner, 80)
      end
    end
    _G.notify_state = true
    update_spinner()
  end
end

function M.check_lsps()
  local clients = vim.lsp.get_active_clients()
  for _, client in ipairs(clients) do
    if client.name ~= "wolfram-lsp" then
      return true
    end
  end
  return false
end

function M.check_wolfarm()
  local start_time = vim.loop.now()
  local timer = vim.loop.new_timer()
  local timer_closed = false

  local function close_timer()
    if not timer_closed then
      timer:stop()
      timer:close()
      timer_closed = true
    end
  end

  M.spin_notify() -- First call before starting the timer
  timer:start(
    0,
    50, -- 将轮询周期改为50毫秒
    vim.schedule_wrap(function()
      if vim.loop.now() - start_time >= 3000 then
        close_timer()
        M.spin_notify() -- Second call after LSP is enabled
      elseif M.check_lsps() then
        close_timer()
        vim.b.lsp_disabled = true
        M.spin_notify() -- Second call after LSP is disabled
      end
    end)
  )
end

return M
