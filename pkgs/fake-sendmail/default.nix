defnix: let
  inherit (defnix.pkgs) coreutils;

  inherit (defnix.build-support) ghc run-script;

  fakeSendmailScript = builtins.toFile "fakeSendmailScript.hs" ''
    import Prelude hiding (log)
    import System.Environment
    import System.IO

    main :: IO ()
    main = do
      log "invoked"
      args <- getArgs
      log ("arguments: " ++ show args)
      input <- hGetContents stdin
      mapM_ logStdin (lines input)
      log "done!"

    log :: String -> IO ()
    log message = hPutStrLn stderr ("fakeSendmail: " ++ message)

    logStdin :: String -> IO ()
    logStdin message = log ("stdin: " ++ message)
  '';
in run-script "fakeSendmail" {
  PATH = "${coreutils}/bin";
} ''
  mkdir -p $out/bin/
  ${ghc} ${fakeSendmailScript} --make -outputdir . -o $out/bin/sendmail
''
