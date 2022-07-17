{-# LANGUAGE ScopedTypeVariables #-}

module Util (
    handle,
    forever,
    sendAll,
    takeExtension,
    unpackStr,
    packStr,
    msg,
    d,
    recv,
    b,
    Family (AF_INET),
    SockAddr (..),
    Socket,
    SocketOption (..),
    SocketType (..),
    accept,
    bind,
    close,
    listen,
    setSocketOption,
    socket,
    tupleToHostAddress,
) where

import Control.Exception (SomeException, handle)
import Control.Monad (
    forever,
 )
import qualified Data.ByteString as B
import Data.Char (
    chr,
    ord,
 )
import Network.Socket (
    Family (AF_INET),
    SockAddr (..),
    Socket,
    SocketOption (..),
    SocketType (..),
    accept,
    bind,
    close,
    listen,
    setSocketOption,
    socket,
    tupleToHostAddress,
 )
import Network.Socket.ByteString (
    recv,
    sendAll,
 )
import System.FilePath (
    takeExtension,
 )

packStr = B.pack . map (fromIntegral . ord)

unpackStr = map (chr . fromIntegral) . B.unpack

msg :: String
msg =
    "HTTP/1.1 200 OK\n"

d = "<a href='#'>download</a>"

b = lines . unpackStr