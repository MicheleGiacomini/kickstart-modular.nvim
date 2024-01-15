-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '[w', function(opts)
    if opts==nil then opts = {} end
    opts.severity = {min=vim.diagnostic.severity.WARN}
    vim.diagnostic.goto_prev(opts)
  end, { desc = 'Go to previous warning message' })
vim.keymap.set('n', ']w', function(opts)
    if opts==nil then opts = {} end
    opts.severity = {min=vim.diagnostic.severity.WARN}
    vim.diagnostic.goto_next(opts)
  end, { desc = 'Go to next warnign message' })
vim.keymap.set('n', '[e', function(opts)
    if opts==nil then opts = {} end
    opts.severity = {min=vim.diagnostic.severity.ERROR}
    vim.diagnostic.goto_prev(opts)
  end, { desc = 'Go to previous error message' })
vim.keymap.set('n', ']e', function(opts)
    if opts==nil then opts = {} end
    opts.severity = {min=vim.diagnostic.severity.ERROR}
    vim.diagnostic.goto_next(opts)
  end, { desc = 'Go to next error message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Window management
vim.keymap.set('n', '<leader>ws', '<C-w>s', {desc = 'Split window hor'})
vim.keymap.set('n', '<leader>wv', '<C-w>v', {desc = 'Split window ver'})
vim.keymap.set('n', '<leader>wc', '<C-w>c', {desc = 'Close window'})
vim.keymap.set('n', '<leader>wh', '<C-w>h', {desc = 'Move left'})
vim.keymap.set('n', '<leader>wj', '<C-w>j', {desc = 'Move down'})
vim.keymap.set('n', '<leader>wk', '<C-w>k', {desc = 'Move up'})
vim.keymap.set('n', '<leader>wl', '<C-w>l', {desc = 'Move right'})
vim.keymap.set('n', '<leader>w+', '<C-w>+', {desc = 'Increase height'})
vim.keymap.set('n', '<leader>w-', '<C-w>-', {desc = 'Decrease height'})
vim.keymap.set('n', '<leader>w>', '<C-w>>', {desc = 'Increase width'})
vim.keymap.set('n', '<leader>w<', '<C-w><', {desc = 'Decrease width'})
vim.keymap.set('n', '<leader>wR', '<C-w>R', {desc = 'Rotate windows'})
vim.keymap.set('n', '<leader>w=', '<C-w>=', {desc = 'Equalize windows'})
vim.keymap.set('n', '<leader>wo', '<C-w>o', {desc = 'Close other windows'})

-- Buffer management
vim.keymap.set('n', '<leader>bk', ':bd<CR>', {desc = 'Close buffer'})
vim.keymap.set('n', '<leader>bK', ':bd!<CR>', {desc = 'Force close buffer'})
vim.keymap.set('n', '<leader>bs', ':w<CR>', {desc = 'Save buffer'})
vim.keymap.set('n', '<leader>bS', ':wa<CR>', {desc = 'Save all buffers'})
vim.keymap.set('n', '<leader>bp', ':bprevious<CR>', {desc = 'Previous buffer'})
vim.keymap.set('n', '<leader>bn', ':bnext<CR>', {desc = 'Next buffer'})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[Telescope]]
-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- vim: ts=2 sts=2 sw=2 et
