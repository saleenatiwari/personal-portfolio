#!/bin/bash
# Double-click this file in Finder to run the portfolio locally (fully offline).
# It starts a tiny static web server and opens the site in your browser.
# The server sends no-cache headers so the browser always loads the latest files
# (fixes "I edited it but the browser still shows the old version").

cd "$(dirname "$0")" || exit 1

PORT=8000
# If 8000 is taken, walk up until we find a free port.
while lsof -i ":$PORT" >/dev/null 2>&1; do
  PORT=$((PORT + 1))
done

echo "Serving portfolio at http://localhost:$PORT  (no-cache — always fresh)"
echo "Leave this window open while viewing the site. Press Ctrl+C to stop."

# Open the browser shortly after the server starts.
( sleep 1; open "http://localhost:$PORT/index.html" ) &

# Static server that tells the browser never to cache, so refreshes are always current.
python3 - "$PORT" <<'PY'
import sys, http.server, socketserver

class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()

port = int(sys.argv[1])
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", port), NoCacheHandler) as httpd:
    httpd.serve_forever()
PY
