# fish: one-handed setup (fedora-setup.sh). Lives in ~/.config/fish/conf.d/.
#
# Autosuggestions (grey text) are built into fish:
#   Right arrow or Ctrl+F  accept the whole suggestion
#   Alt+Right              accept one word
# z NAME     jump to a folder you've used before (zoxide); zi = pick from a list
# Ctrl+R     search history (fzf)   Ctrl+T  pick a file   Alt+C  cd into a folder
# y          yazi, the file manager; quit with q and the shell stays in its folder

status is-interactive; or exit

set -g fish_greeting

if type -q zoxide
    zoxide init fish | source
end

if type -q fzf
    fzf --fish | source
end

# LazyVim is the editor for git commits, sudoedit and the like.
set -gx EDITOR nvim
set -gx VISUAL nvim

# Short commands for one hand
abbr -a v nvim
abbr -a g git
abbr -a lg lazygit
abbr -a k kubectl

# y: yazi, and stay in the folder you left it in (q quits there; Q quits back).
function y --description 'yazi, then cd to where it was left'
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    command rm -f -- "$tmp"
end
