return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup({
        -- size can be a number or function which is passed the current terminal
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true, -- hide the number column in toggleterm buffers
        shade_filetypes = {},
        autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
        shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
        shading_factor = 2, -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
        persist_size = true,
        persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
        direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float',
        close_on_exit = true, -- close the terminal window when the process exits
        shell = vim.o.shell, -- change the default shell
        auto_scroll = true, -- automatically scroll to the bottom on terminal output
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          -- The border key is *almost* the same as 'nvim_open_win'
          -- see :h nvim_open_win for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          border = 'curved', -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open
          -- like `size`, width and height can be a number or function which is passed the current terminal
          width = 120,
          height = 30,
          winblend = 3,
        },
        winbar = {
          enabled = false,
          name_formatter = function(term) --  term: Terminal
            return term.name
          end
        },
      })

      -- Custom terminal instances
      local Terminal = require('toggleterm.terminal').Terminal
      
      -- Lazygit integration
      local lazygit = Terminal:new({
        cmd = 'lazygit',
        dir = 'git_dir',
        direction = 'float',
        float_opts = {
          border = 'curved',
          width = 150,
          height = 40,
        },
        -- function to run on opening the terminal
        on_open = function(term)
          vim.cmd('startinsert!')
          vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', {noremap = true, silent = true})
        end,
        -- function to run on closing the terminal
        on_close = function(term)
          vim.cmd('startinsert!')
        end,
      })

      -- Node.js REPL
      local node = Terminal:new({
        cmd = 'node',
        direction = 'float',
        float_opts = {
          border = 'curved',
          width = 100,
          height = 25,
        },
      })

      -- Python REPL
      local python = Terminal:new({
        cmd = 'python3',
        direction = 'float',
        float_opts = {
          border = 'curved',
          width = 100,
          height = 25,
        },
      })

      -- Bottom terminal for quick commands
      local bottom_terminal = Terminal:new({
        direction = 'horizontal',
        size = 15,
      })

      -- Functions to toggle terminals
      function _LAZYGIT_TOGGLE()
        lazygit:toggle()
      end

      function _NODE_TOGGLE()
        node:toggle()
      end

      function _PYTHON_TOGGLE()
        python:toggle()
      end

      function _BOTTOM_TERMINAL_TOGGLE()
        bottom_terminal:toggle()
      end

      -- Key mappings
      local opts = {noremap = true, silent = true}
      
      -- Terminal toggle mappings
      vim.keymap.set('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', {desc = 'Toggle floating terminal'})
      vim.keymap.set('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', {desc = 'Toggle horizontal terminal'})
      vim.keymap.set('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', {desc = 'Toggle vertical terminal'})
      vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<cr>', {desc = 'Toggle terminal'})
      
      -- Custom terminal mappings
      vim.keymap.set('n', '<leader>tg', '<cmd>lua _LAZYGIT_TOGGLE()<CR>', {desc = 'Toggle Lazygit'})
      vim.keymap.set('n', '<leader>tn', '<cmd>lua _NODE_TOGGLE()<CR>', {desc = 'Toggle Node REPL'})
      vim.keymap.set('n', '<leader>tp', '<cmd>lua _PYTHON_TOGGLE()<CR>', {desc = 'Toggle Python REPL'})
      vim.keymap.set('n', '<leader>tb', '<cmd>lua _BOTTOM_TERMINAL_TOGGLE()<CR>', {desc = 'Toggle bottom terminal'})
      
      -- Terminal mode mappings (to exit terminal mode)
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)

      -- Send selection to terminal
      function _G.set_terminal_keymaps()
        local opts = {buffer = 0}
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      end

      -- Automatically set terminal keymaps when entering a terminal buffer
      vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    end,
    keys = {
      { '<C-\\>', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
      { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Toggle floating terminal' },
      { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle horizontal terminal' },
      { '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', desc = 'Toggle vertical terminal' },
      { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
    },
  },
}

