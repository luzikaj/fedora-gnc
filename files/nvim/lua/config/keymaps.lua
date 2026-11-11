-- LazyVim keymaps for RIGHT-HANDED (one-handed) Dvorak, us(dvorak-r).
-- Same scheme as your Helix and Zed keymaps, so all three editors match:
--
--   resting keys   e = ←   h = ↓   t = ↑   d = →
--   k = delete (was d)   j = till char (was t)   l / L = word end (was e / E)
--   E / D = previous / next buffer   Ctrl+t in insert = back to normal
--   z h / z t scroll, z H / z T half page, z u = cursor line to top
--   Space w + e h t d = go to window, + E H T D = move window,
--   Space w k = close window
--
-- Loaded after LazyVim's own keymaps, so these win.

local map = vim.keymap.set
local nxo = { "n", "x", "o" }

-- Movement on the resting keys (h/t move by screen line, like LazyVim's j/k)
map(nxo, "e", "h", { desc = "Left" })
map({ "n", "x" }, "h", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
map({ "n", "x" }, "t", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
map("o", "h", "j", { desc = "Down" })
map("o", "t", "k", { desc = "Up" })
map(nxo, "d", "l", { desc = "Right" })

-- Commands displaced by the movement keys
map({ "n", "x" }, "k", "d", { desc = "Delete (kill)" })
map("n", "kk", "dd", { desc = "Delete line" })
map(nxo, "j", "t", { desc = "Till char" })
map(nxo, "l", "e", { desc = "Word end" })
map(nxo, "L", "E", { desc = "WORD end" })

-- Buffers: E / D = left / right, like e / d
-- (LazyVim's Shift-h / Shift-l are removed, so H goes back to "top of screen".)
pcall(vim.keymap.del, "n", "<S-h>")
pcall(vim.keymap.del, "n", "<S-l>")
map("n", "E", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "D", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Leave insert mode without reaching for Esc (Right Ctrl + t)
map("i", "<C-t>", "<Esc>", { desc = "Normal mode" })

-- Scrolling, as in Helix's view mode
map("n", "zh", "<C-e>", { desc = "Scroll down" })
map("n", "zt", "<C-y>", { desc = "Scroll up" })
map("n", "zH", "<C-d>", { desc = "Half page down" })
map("n", "zT", "<C-u>", { desc = "Half page up" })
map("n", "zu", "zt", { desc = "Cursor line to top" })

-- Windows: Space w (LazyVim's window menu) and Ctrl-w, with e h t d
for key, dir in pairs({ e = "h", h = "j", t = "k", d = "l" }) do
  map("n", "<C-w>" .. key, "<cmd>wincmd " .. dir .. "<cr>", { desc = "Go to window " .. key })
  map("n", "<C-w>" .. key:upper(), "<cmd>wincmd " .. dir:upper() .. "<cr>", { desc = "Move window " .. key })
  map("n", "<leader>w" .. key, "<cmd>wincmd " .. dir .. "<cr>", { desc = "Go to window " .. key })
  map("n", "<leader>w" .. key:upper(), "<cmd>wincmd " .. dir:upper() .. "<cr>", { desc = "Move window " .. key })
end
-- LazyVim's "Space w d" closed the window; d is now "right", so close is on k (kill).
map("n", "<leader>wk", "<C-w>c", { desc = "Close Window", remap = true })
map("n", "<C-w>k", "<C-w>c", { desc = "Close Window", remap = true })
