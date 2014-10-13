lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ ghc, system, run-script }:

pkgs@{ coreutils, sh }:

let
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
  PATH = "${coreutils}/bin:${ghc}/bin";
} ''
  mkdir -p $out/bin/
  ghc ${fakeSendmailScript} --make -outputdir . -o $out/bin/sendmail
'')
