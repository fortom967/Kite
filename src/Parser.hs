{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE LambdaCase #-}

module Parser (
    parseH,
    request,
    host,
    keys,
) where

import Control.Applicative
import Control.Monad
import Data.Char
import Data.Maybe

-- | NewType Declaration

-------------------------------------------

newtype Parser s = Parser
    { parse :: String -> Maybe (s, String)
    }
    deriving (Functor)

--------------------------------------------

-- | Instances

-----------------------------------------------------

instance Applicative Parser where
    pure x = Parser $ \i -> Just (x, i)
    (<*>) (Parser a) (Parser b) = Parser $ \i -> do
        (f, i') <- a i
        (a, i'') <- b i'
        Just (f a, i'')

instance Monad Parser where
    (>>=) (Parser a) f = Parser $ \i -> do
        (b, i') <- a i
        parse (f b) i'

instance Alternative Parser where
    empty = Parser (const Nothing)
    (<|>) (Parser a) (Parser b) = Parser $
        \i -> a i <|> b i

-----------------------------------------------------

-- Parsers

-----------------------------------------------------

item :: Parser Char
item = Parser $ \case
    (i : is) -> Just (i, is)
    _ -> Nothing

satisfy :: (Char -> Bool) -> Parser Char
satisfy pred = do
    c <- item
    if pred c then return c else empty

satS :: (String -> Bool) -> Parser String
satS pred = do
    c <- many item
    if pred c then return c else empty

char :: Char -> Parser Char
char c = satisfy (== c)

string :: String -> Parser String
string = mapM char

-- acceptp = const . (,) <$> many (satisfy isAlpha) <*> char '/' <*> many (satisfy isAlpha)

request =
    (\x _ y _ z _ -> (x, y, z))
        <$> method
        <*> ws
        <*> query
        <*> ws
        <*> version
        <*> char '\r'
  where
    method = string "GET" <|> string "POST" <|> string "DELETE"
    query = many (satisfy (\x -> isAlpha x || (x == '/') || x == '.'))
    version = many (satisfy (\x -> isAlpha x || isDigit x || (x == '/') || x == '.'))

host =
    (\h _ i _ p _ -> (h, i, p))
        <$> string "Host"
        <*> string ": "
        <*> ip
        <*> char ':'
        <*> port
        <*> char '\r'
  where
    ip = string "localhost" <|> many (satisfy (\x -> isDigit x || x == '.'))
    port = many (satisfy isDigit)

keys =
    (\x _ y _ -> (x, y, ""))
        <$> stringLiteral
        <*> string ": "
        <*> stringLiteral
        <*> char '\r'

stringLiteral =
    many
        ( satisfy (\x -> isAscii x && x /= ':' && x /= '\r')
        )

stringL = many (satisfy isAlpha <|> char '/')
ws = satisfy isSpace

eof = Parser $ const (Just (("", "", ""), ""))

------------------------------------------------------

readf = do
    readFile "request.txt"

-- d = fmap parseH readf

parseH t =
    fst <$> fromJust (mapM k t)
  where
    k = parse $ keys <|> request <|> host <|> eof