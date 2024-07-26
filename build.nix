{
  pkgs ? import <nixpkgs> {}
}
:
(
  builtins.concatMap

  (runtmux:
    [
      runtmux
      (
        pkgs.makeDesktopItem
        {
          name = "uxterm-runtmux-${runtmux.session-name}";
          desktopName = "Test runtmux(Session ${runtmux.session-name}) in UXterm";
          exec = "${pkgs.xterm}/bin/uxterm -e \"${pkgs.lib.meta.getExe runtmux}\"";
          icon = "org.xfce.terminalemulator";
        }
      )
    ]
  )

  [
    (
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
          (pkgs.lib.meta.getExe pkgs.vim)
        ]

        [
          "/Dev"
          /Dev
        ]
      ];

    }
    )
    (
      pkgs.callPackage
      ./.
      {

        session-name =
          "Ranger";

        session-progs =
        [
          [
            "Ranger"
            /Dev
            (pkgs.lib.meta.getExe pkgs.ranger)
          ]
        ];

      }
    )
  ]
)
