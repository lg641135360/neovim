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
    cmd = { "cmake", "--preset", opts.preset ~= "" and opts.preset or preset_name }
  else
    cmd = { "cmake", "-S", root, "-B", build_dir(root) }
  end

  vim.notify("Running: " .. table.concat(cmd, " "), vim.log.levels.INFO, { title = "CMake" })

  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      notify_command_result("Configure", result)
      if result.code == 0 then
        vim.notify("compile_commands.json should now be available for clangd. Use :LspRestart clangd if diagnostics are stale.", vim.log.levels.INFO, { title = "CMake" })
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
  end, { nargs = "?", complete = "file", desc = "Configure CMake to generate build/compile_commands.json" })
end

return M
