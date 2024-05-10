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

return {
  default_config = {
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
}
