# -*- coding: utf-8 -*-

import struct
import time
from mod_python import apache

SLEEP_TIME=1800
BOARDS={
  "192.168.77.31": "board.raw",
  "board.lan"    : "board.raw",
  "192.168.77.34": "board2.raw",
  "board2.lan"   : "board2.raw",
  None           : "board.raw",
}

def getsleep(amount = 60, minimum = 10):
    """Get sleep time, e.g.:
       amount=60: get sleep time until next full minute
       amount=3600: get sleep time until next full hour
       minimum: sleep at least this time; shift to next minute/hour/...
    """
    t = time.time()
    return int(((t + amount + minimum)//amount*amount) - t)

def index(req):
    who = req.get_remote_host(apache.REMOTE_NOLOOKUP)
    board = BOARDS.get(who, BOARDS[None])

    with open("/var/www/html/board/" + board, "r") as f:
        return struct.pack("!H", getsleep(SLEEP_TIME)) + f.read()
