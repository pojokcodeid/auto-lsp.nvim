local M = {}

M.setup = function(opts)
  opts.format_on_save = opts.format_on_save or true
  opts.virtual_text = opts.virtual_text or false
  opts.timeout_ms = opts.timeout_ms or 5000
  opts.skip_config = opts.skip_config or {}
  opts.ensure_installed = opts.ensure_installed or {}
  opts.automatic_installation = true
  require("auto-lsp.config").setup(opts)
end

return M
