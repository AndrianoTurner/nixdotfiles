{pkgs, ...}: {
  programs.tmux = {
    enable = true;

    baseIndex = 1;
    mouse = true;
    prefix = "C-a";
    escapeTime = 0;
    keyMode = "vi";

    terminal = "tmux-256color";
    historyLimit = 50000;
    focusEvents = true;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      tmux-which-key

      {
        plugin = gruvbox;
        extraConfig = ''
          set -g @tmux-gruvbox 'dark'
          set -g @tmux-gruvbox-statusbar-alpha 'true'
        '';
      }
    ];

    extraConfig = ''
      # ── Terminal capabilities ─────────────────────────────────

      set -as terminal-features ",alacritty*:RGB:extkeys:clipboard"
      set -as terminal-features ",xterm-ghostty:RGB:extkeys:clipboard"

      set -s extended-keys on
      set -s extended-keys-format csi-u
      set -g xterm-keys on

      # OSC 52 clipboard.
      # Works locally and through SSH.
      set -s set-clipboard external

      # ── General ───────────────────────────────────────────────

      set -g renumber-windows on
      set -g status-position top

      # ── Reload ────────────────────────────────────────────────

      unbind r
      bind r source-file ~/.config/tmux/tmux.conf \; \
        display-message "tmux config reloaded"

      # ── Sessions / windows ────────────────────────────────────

      bind S new-session
      bind K confirm-before kill-session

      bind n new-window -c "#{pane_current_path}"

      bind -n C-Tab select-window -n

      # ── Splits ────────────────────────────────────────────────

      unbind '%'
      unbind '"'
      unbind '-'

      bind '-' split-window -v -c "#{pane_current_path}"
      bind '|' split-window -h -c "#{pane_current_path}"

      # ── Prefix pane navigation ────────────────────────────────

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ── Alt pane navigation ───────────────────────────────────

      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      bind -n M-Left  select-pane -L
      bind -n M-Down  select-pane -D
      bind -n M-Up    select-pane -U
      bind -n M-Right select-pane -R

      # ── Pane management ───────────────────────────────────────

      unbind x

      bind q confirm-before kill-pane

      # ── Copy mode ─────────────────────────────────────────────

      bind -T copy-mode-vi y \
        send-keys -X copy-selection-and-cancel

      bind -T copy-mode-vi Enter \
        send-keys -X copy-selection-and-cancel
    '';
  };
}
