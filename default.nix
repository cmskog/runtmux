{
  coreutils,
  lib,
  tmux,
  writeTextFile,
  runtimeShell,

  # callPackage arguments
  session-name,
  tmux-config ? null,
  session-progs ? []
}:

assert builtins.isString session-name;
assert (builtins.stringLength session-name) > 0;

# We should do some checks on tmux-config
assert builtins.traceVerbose
       ("Type of tmux-config:" + (builtins.typeOf tmux-config))
       true;

assert builtins.isList session-progs;
assert
  builtins.all
  (l:
    (builtins.isList l)
    && ((builtins.length l) >= 2)
    && (builtins.isString (builtins.elemAt l 0))
    && (builtins.isPath (builtins.elemAt l 1))
    && (
         ((builtins.length l) == 2)
         ||
         (
           ((builtins.length l) == 3)
           # Do some check on program argument
           &&
           (
             builtins.traceVerbose
             (
               "Type of element in index 3:"
               + (builtins.typeOf (builtins.elemAt l 2))
             )
             true
           )
         )
       )
  )
  session-progs;

writeTextFile {
  name = "runtmux";
  executable = true;
  destination = "/bin/runtmux";
  derivationArgs =
  {
    passthru =
    {
      inherit session-name;
    };
  };
  text =
    (
      let
        tmux-prog = lib.meta.getExe tmux;
      in
        ''
        #! ${runtimeShell}

        set \
          -o errexit \
          -o nounset \
          -o pipefail
        shopt -s shift_verbose

        if ${tmux-prog} has-session -t "${session-name}" >& /dev/null
        then
          exec ${tmux-prog} \
            attach-session -t "${session-name}"
        else
          exec ${tmux-prog} ${
                             if tmux-config != null
                             then
                               "-f \"${tmux-config}\""
                             else
                               ""
                            } \
            new-session -s "${session-name}" \
          ${
            builtins.toString
            (
              let
                unpruned =
                  builtins.concatLists
                    (builtins.map
                      (p:
                        [
                          "new-window -d"

                          (
                            "-n "
                            + (builtins.elemAt p 0)
                            + " -c "
                            + (builtins.toString (builtins.elemAt p 1))
                            + (
                               if (builtins.length p) == 3
                               then
                                 " " + (builtins.toString (builtins.elemAt p 2))
                               else
                                 ""
                              )
                          )

                          "\\;"
                        ]
                      )
                      session-progs
                    );
              in
                lib.lists.drop 1 (lib.lists.take ((builtins.length unpruned) - 1) unpruned)
            )
          }
        fi''
    );
}
