local util = require 'lspconfig.util'

local root_files = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  'pyrightconfig.json',
  '.git',
}

local function exepath(expr)
  local ep = vim.fn.exepath(expr)
  return ep ~= '' and ep or nil
end

local function get_python_path(workspace)
  local path = util.path
  -- 1. Use activated virtualenv.
  if vim.env.VIRTUAL_ENV then
    return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
  end

  -- 2. Find and use virtualenv in workspace directory.
  for _, pattern in ipairs { '*', '.*' } do
    local match = vim.fn.glob(path.join(workspace, pattern, 'pyvenv.cfg'))
    if vim.fn.empty(match) ~= 1 then
      return path.join(path.dirname(match), 'bin', 'python')
    end
  end

  -- 3. Find and use virtualenv managed by Poetry.
  if exepath 'poetry' and path.is_file(path.join(workspace, 'poetry.lock')) then
    local output = vim.fn.trim(vim.fn.system 'poetry env info -p')
    if path.is_dir(output) then
      return path.join(output, 'bin', 'python')
    end
  end

  -- 4. Find and use virtualenv managed by Pipenv.
  if exepath 'pipenv' and path.is_file(path.join(workspace, 'Pipfile')) then
    local output = vim.fn.trim(vim.fn.system('cd ' .. workspace .. '; pipenv --py'))
    if path.is_dir(output) then
      return output
    end
  end

  -- 5. Fallback to system Python.

  return exepath 'python3' or exepath 'python' or 'python'
end

return {
  default_config = {
    before_init = function(_, config)
      if not config.settings.python then
        config.settings.python = {}
      end
      if not config.settings.python.pythonPath then
        config.settings.python.pythonPath = get_python_path(config.root_dir)
      end
    end,
    cmd = {
      'npx',
      '@delance/runtime',
      'delance-langserver',
      '--stdio',
    },
    filetypes = { 'python' },
    single_file_support = true,
    root_dir = function(fname)
      return util.root_pattern(unpack(root_files))(fname)
    end,
    settings = {
      python = {
        analysis = {
          inlayHints = {
            variableTypes = true,
            functionReturnTypes = true,

            callArgumentNames = true,
            pytestParameters = true,
          },
        },
      },
    },
  },
  commands = {},
}
