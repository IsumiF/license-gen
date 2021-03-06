#!/usr/bin/env stack
{- stack
  script
  --resolver lts-6.35
  --package bytestring
  --package text
  --package cipher-aes
  --package random
-}

import           Crypto.Cipher.AES
import           Data.ByteString    (ByteString)
import qualified Data.ByteString    as BS
import           Data.Text          (Text)
import qualified Data.Text          as T
import qualified Data.Text.Encoding as T
import           Data.Word          (Word8)
import           System.Environment
import           System.Random

main :: IO ()
main = do
  [key, filePath] <- getArgs
  let key_bs = T.encodeUtf8 $ T.pack key
  if BS.length key_bs /= 32
    then error "Length of key must be 32 bytes"
    else do
      g <- getStdGen
      let iv = BS.pack . take 16 . randoms $ g
      input <- BS.readFile filePath
      let output = encryptCTR (initAES key_bs) iv input
      BS.writeFile (filePath ++ ".enc") iv
      BS.appendFile (filePath ++ ".enc") output
  return ()
