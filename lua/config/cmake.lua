local M = {}

local preset_name = "nvim-debug"

local function path_exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

local function find_project_root()
  local start = vim.api.nvim_buf_get_name(0)
  if start == "" then
    start = vim.fn.getcwd()
  end

  local stat = vim.uv.fs_stat(start)
  if stat and stat.type == "file" then
    start = vim.fs.dirname(start)
  end

  local root = vim.fs.root(start, { "CMakeLists.txt" })
  return root or vim.fn.getcwd()
end

local function preset_path(root)
  return vim.fs.joinpath(root, "CMakeUserPresets.json")
end

local function read_json_file(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if decoded_ok and type(decoded) == "table" then
    return decoded
  end

  return nil
end

local function user_presets(root)
  local file = preset_path(root)
  if not path_exists(file) then
    return nil
  end

  return read_json_file(file)
end

local function preset_names(presets, key)
  local names = {}
  local items = type(presets) == "table" and presets[key] or nil
  if type(items) ~= "table" then
    return names
  end

  for _, item in ipairs(items) do
    if type(item) == "table" and type(item.name) == "string" and item.name ~= "" then
      table.insert(names, item.name)
    end
  end

  return names
end

local function find_named_preset(presets, key, name)
  local items = type(presets) == "table" and presets[key] or nil
  if type(items) ~= "table" then
    return nil
  end

  for _, item in ipairs(items) do
    if type(item) == "table" and item.name == name then
      return item
    end
  end

  return nil
end

local function resolve_configure_preset(root, requested)
  local presets = user_presets(root)
  if type(presets) ~= "table" then
    return requested ~= "" and requested or preset_name
  end

  if requested ~= "" then
    if find_named_preset(presets, "configurePresets", requested) then
      return requested
    end

    local build_preset = find_named_preset(presets, "buildPresets", requested)
    if type(build_preset) == "table" and type(build_preset.configurePreset) == "string" and build_preset.configurePreset ~= "" then
      return build_preset.configurePreset
    end

    return requested
  end

  if find_named_preset(presets, "configurePresets", preset_name) then
    return preset_name
  end

  return preset_names(presets, "configurePresets")[1] or preset_name
end

local function complete_presets()
  local presets = user_presets(find_project_root())
  local seen = {}
  local names = {}

  for _, key in ipairs({ "configurePresets", "buildPresets" }) do
    for _, name in ipairs(preset_names(presets, key)) do
      if not seen[name] then
        seen[name] = true
        table.insert(names, name)
      end
    end
  end

  table.sort(names)
  return names
end

local function build_dir(root)
  return vim.fs.joinpath(root, "build")
end

local function notify_command_result(label, result)
  local level = result.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
  local output = vim.trim(table.concat({ result.stdout or "", result.stderr or "" }, "\n"))
  local message = result.code == 0 and (label .. " finished") or (label .. " failed with exit code " .. result.code)

  if output ~= "" then
    message = message .. "\n" .. output
  end

  vim.notify(message, level, { title = "CMake" })
end

function M.init_user_preset(opts)
  opts = opts or {}
  local root = find_project_root()
  local file = preset_path(root)

  if path_exists(file) and not opts.force then
    vim.notify("CMakeUserPresets.json already exists: " .. file, vim.log.levels.INFO, { title = "CMake" })
    return
  end

  local preset = ([=[
{
  "version": 4,
  "configurePresets": [
    {
      "name": "%s",
      "displayName": "Nvim Debug",
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build"
    }
  ],
  "buildPresets": [
    {
      "name": "%s",
      "configurePreset": "%s"
    }
  ]
}
]=]):format(preset_name, preset_name, preset_name)

  local ok, err = pcall(vim.fn.writefile, vim.split(preset, "\n", { plain = true }), file)
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR, { title = "CMake" })
    return
  end

  vim.notify("Created " .. file, vim.log.levels.INFO, { title = "CMake" })
end

function M.configure(opts)
  opts = opts or {}
  local root = find_project_root()
  local user_presets = preset_path(root)
  local cmd

  if path_exists(user_presets) then
    cmd = { "cmake", "--preset", resolve_configure_preset(root, opts.preset or "") }
  else
    cmd = { "cmake", "-S", root, "-B", build_dir(root) }
  end

  vim.notify("Running: " .. table.concat(cmd, " "), vim.log.levels.INFO, { title = "CMake" })

  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      notify_command_result("Configure", result)
      if result.code == 0 then
        vim.notify("compile_commands.json should now be available for clangd. Use :lua =vim.lsp.get_clients({bufnr=0}) to check active clients; if clangd is active, run :lsp restart clangd.", vim.log.levels.INFO, { title = "CMake" })
      end
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("CMakeUserPresetInit", function(opts)
    M.init_user_preset({ force = opts.bang })
  end, { bang = true, desc = "Create a local CMakeUserPresets.json for Neovim" })

  vim.api.nvim_create_user_command("CMakeConfigure", function(opts)
    M.configure({ preset = opts.args })
  end, { nargs = "?", complete = complete_presets, desc = "Configure CMake to generate build/compile_commands.json" })
end

return M
