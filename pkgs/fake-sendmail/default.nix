lib: lib.composable [ ] (
let
  pkgs = import <nixpkgs> {};

  fakeSendmailScript = pkgs.writeText "fakeSendmailScript.hs" ''
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
in
pkgs.stdenv.mkDerivation {
  name = "fakeSendmail";
  buildInputs = [ pkgs.haskellPackages.ghcPlain ];
  buildCommand = ''
    ghc ${fakeSendmailScript} --make -o ./sendmail
    mkdir -p $out/bin
    cp sendmail $out/bin/
  '';
})
