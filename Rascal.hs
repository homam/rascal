--
-- RASCAL, a Haskell cli reddit client
-- Copyright (c) 2013 Sylvain Soliman <Sylvain.Soliman@gmail.com>
-- MIT License, see LICENSE.txt
--

{-# LANGUAGE OverloadedStrings #-}
-- allow Text objects directly as strings

import Control.Applicative

import Data.Aeson
import Network.Curl.Aeson
import Network.Curl.Opts

version :: String
version = "1.0"

userAgent :: String
userAgent = "rascal/" ++ version ++ " by soli"

data Link = Link {
   domain :: String,
   author :: String,
   score :: Int,
   url :: String,
   title :: String,
   numComments :: Int
} deriving(Show)

data Listing = Listing [Link] deriving (Show)

instance FromJSON Link where
   parseJSON (Object o) = do
      datum <- o .: "data"
      Link <$> datum .: "domain"
           <*> datum .: "author"
           <*> datum .: "score"
           <*> datum .: "url"
           <*> datum .: "title"
           <*> datum .: "numComments"
   parseJSON _ = empty

instance FromJSON Listing where
   parseJSON (Object o) = do
      datum <- o .: "data"
      Listing <$> datum .: "children"
   parseJSON _ = empty

-- ensure no burst above 30 requests/min
main ::  IO ()
main = do
   t <- curlAeson parseJSON "GET" "http://www.reddit.com/r/scrolls/new.json"
      [CurlUserAgent userAgent] noData :: IO Listing
   print t
