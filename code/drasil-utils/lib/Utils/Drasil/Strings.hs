-- Contains a function that removes special characters from a string.
module Utils.Drasil.Strings where

import Utils.Drasil.Lists (replaceAll)

-- TODO: This can probably become a bit more comprehensive,
-- anything other than a-z, A-Z, or 0-9 could probably be replaced.

-- | Replace occurences of special characters (@",~`-=!@#$%^&*+[]\\;'/|\"<>? "@) with underscores (@"_"@).
toPlainName :: String -> String
toPlainName = replaceAll ",~`-=!@#$%^&*+[]\\;'/|\"<>? " '_'
