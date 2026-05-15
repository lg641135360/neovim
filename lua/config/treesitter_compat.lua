local M = {}

local html_script_type_languages = {
  importmap = "json",
  module = "javascript",
  ["application/ecmascript"] = "javascript",
  ["text/ecmascript"] = "javascript",
}

local non_filetype_match_injection_language_aliases = {
  ex = "elixir",
  pl = "perl",
  sh = "bash",
  uxn = "uxntal",
  ts = "typescript",
}

local function get_parser_from_markdown_info_string(injection_alias)
  local match = vim.filetype.match({ filename = "a." .. injection_alias })
  return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
end

local function errwrite(str)
  vim.api.nvim_err_writeln(str)
end

local function valid_args(name, pred, count, strict_count)
  local arg_count = #pred - 1

  if strict_count then
    if arg_count ~= count then
      errwrite(string.format("%s must have exactly %d arguments", name, count))
      return false
    end
  elseif arg_count < count then
    errwrite(string.format("%s must have at least %d arguments", name, count))
    return false
  end

  return true
end

local function first_capture_node(match, capture_id)
  local node = match[capture_id]
  if type(node) == "table" then
    return node[1]
  end
  return node
end

function M.setup()
  if vim.g.nvim_treesitter_query_predicates_compat_applied then
    return
  end

  local ok = pcall(require, "nvim-treesitter.query_predicates")
  if not ok then
    return
  end

  local query = require("vim.treesitter.query")
  local opts = vim.fn.has("nvim-0.10") == 1 and { force = true, all = false } or true

  query.add_predicate("nth?", function(match, _pattern, _bufnr, pred)
    if not valid_args("nth?", pred, 2, true) then
      return
    end

    local node = first_capture_node(match, pred[2])
    local n = tonumber(pred[3])
    if node and node:parent() and node:parent():named_child_count() > n then
      return node:parent():named_child(n) == node
    end

    return false
  end, opts)

  query.add_predicate("is?", function(match, _pattern, bufnr, pred)
    if not valid_args("is?", pred, 2) then
      return
    end

    local locals = require("nvim-treesitter.locals")
    local node = first_capture_node(match, pred[2])
    local types = { unpack(pred, 3) }

    if not node then
      return true
    end

    local _, _, kind = locals.find_definition(node, bufnr)
    return vim.tbl_contains(types, kind)
  end, opts)

  query.add_predicate("kind-eq?", function(match, _pattern, _bufnr, pred)
    if not valid_args(pred[1], pred, 2) then
      return
    end

    local node = first_capture_node(match, pred[2])
    local types = { unpack(pred, 3) }

    if not node then
      return true
    end

    return vim.tbl_contains(types, node:type())
  end, opts)

  query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
    local capture_id = pred[2]
    local node = first_capture_node(match, capture_id)
    if not node then
      return
    end

    local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
    local configured = html_script_type_languages[type_attr_value]
    if configured then
      metadata["injection.language"] = configured
    else
      local parts = vim.split(type_attr_value, "/", {})
      metadata["injection.language"] = parts[#parts]
    end
  end, opts)

  query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
    local capture_id = pred[2]
    local node = first_capture_node(match, capture_id)
    if not node then
      return
    end

    local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
    metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
  end, opts)

  query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
    local id = pred[2]
    local node = first_capture_node(match, id)
    if not node then
      return
    end

    local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
    if not metadata[id] then
      metadata[id] = {}
    end
    metadata[id].text = string.lower(text)
  end, opts)

  vim.g.nvim_treesitter_query_predicates_compat_applied = true
end

return M
