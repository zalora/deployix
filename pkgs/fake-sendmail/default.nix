lib: lib.composable [ "build-support" "pkgs" ] (

build-support@{ ghc, output-to-argument, system, write-script }:

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
in output-to-argument (derivation {
  name = "fakeSendmail";

  inherit system;

  PATH = "${coreutils}/bin:${ghc}/bin";

  builder = write-script "compile.sh" ''
    #!${sh}

    mkdir -p $out/bin/
    ghc ${fakeSendmailScript} --make -o $out/bin/sendmail
  '';
}))
