local M = {}

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
  return
end

local lspvitualtext = false
local icons = require("auto-lsp.icons")
local format_on_save = false
local timeout_ms = 5000
-- setter
M.setFormtatOnSave = function(on_save)
  format_on_save = on_save
end
M.setVirtualText = function(vit)
  lspvitualtext = vit
end
M.setTimeoutMs = function(ms)
  timeout_ms = ms
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities.textDocument.completion.completionItem.snippetSupport = true
M.capabilities = cmp_nvim_lsp.default_capabilities(M.capabilities)

M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = icons.diagnostics.Error },
    { name = "DiagnosticSignWarn", text = icons.diagnostics.Warning },
    { name = "DiagnosticSignHint", text = icons.diagnostics.Hint },
    { name = "DiagnosticSignInfo", text = icons.diagnostics.Info },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    virtual_text = lspvitualtext, -- disable virtual text
    signs = {
      active = signs, -- show signs
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function attach_navic(client, bufnr)
  vim.g.navic_silence = true
  local status_ok, navic = pcall(require, "nvim-navic")
  if not status_ok then
    return
  end
  navic.attach(client, bufnr)
end

function FORMAT_FILTER(client)
  local filetype = vim.bo.filetype
  local n = require("null-ls")
  local s = require("null-ls.sources")
  local method = n.methods.FORMATTING
  local available_formatters = s.get_available(filetype, method)

  if #available_formatters > 0 then
    return client.name == "null-ls"
  elseif client.supports_method("textDocument/formatting") then
    return true
  else
    return false
  end
end

-- stylua: ignore
local function lsp_keymaps(bufnr, on_save)
  local map = function(keys, func, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
  end

  map("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", "Goto declaration", "n")
  map("gd", "<cmd>lua vim.lsp.buf.definition()<CR>", "Goto definition", "n")
  map("<C-LeftMouse>", "<cmd>lua vim.lsp.buf.definition()<CR>", "Goto definition", "n")
  map("K", "<cmd>lua vim.lsp.buf.hover()<CR>", "Hover", "n")
  map("gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", "Goto implementation", "n")
  map("gr", "<cmd>lua vim.lsp.buf.references()<CR>", "References", "n")
  map("gl", "<cmd>lua vim.diagnostic.open_float()<CR>", "Show line diagnostics", "n")
  map("<leader>l", "", " LSP", "n")
  map("<leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", "Format", "n")
  map("<leader>li", "<cmd>LspInfo<cr>", "Information", "n")
  map("<leader>lI", "<cmd>Mason<cr>", "Mason Information", "n")
  map("<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action", "n")
  map("<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", "Next Diagnostic", "n")
  map("<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", "Prev Diagnostic", "n")
  map("<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename", "n")
  map("<leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature help", "n")
  map("<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", "Quickfix", "n")
  if on_save then
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = timeout_ms or 5000, filter = FORMAT_FILTER })
      end,
    })
  else
    vim.schedule(function()
      pcall(function()
        vim.api.nvim_clear_autocmds({ group = "LspFormatting" })
      end)
    end)
  end
end

M.on_attach = function(client, bufnr)
  attach_navic(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end

  if client.supports_method("textDocument/inlayHint") then
    -- vim.lsp.inlay_hint.enable(bufnr, true)
    vim.lsp.inlay_hint.enable(true)
  end

  local on_save = format_on_save
  -- disable if conform active
  local status, _ = pcall(require, "conform")
  if status then
    on_save = false
  end
  lsp_keymaps(bufnr, on_save)
  local status_ok, illuminate = pcall(require, "illuminate")
  if not status_ok then
    return
  end
  illuminate.on_attach(client)
end

return M
