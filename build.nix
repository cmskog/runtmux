{
  pkgs ? import <nixpkgs> {}
}
:

pkgs.callPackage
./.
{

  session-name =
    "A session";

  tmux-config =
    pkgs.writeText
    "tmux.conf"
    ''
    set-option -g prefix C-a
    unbind-key C-b
    bind-key C-a send-prefix

    set-option -g status-left "[#S] "
    set-option -g status-left-length 20
    set-option -g status-right " %a %Y-%m-%d %H:%M %Z(%z)"

    set-option -g status-style "fg=#ffff00 bold"
    set-option -ag status-style "bg=#0000ff"

    #
    # START Ctrl keys
    #

    # Start editor
    #
    bind-key	-T prefix	C-e \
      new-window -n Vim ${pkgs.vim}/bin/vim
    '';

  session-progs =
  [
    [
      "Edit"
      /Dev
      "${pkgs.lib.meta.getExe pkgs.vim}"
    ]

    [
      "/Dev"
      /Dev
    ]
  ];

}
