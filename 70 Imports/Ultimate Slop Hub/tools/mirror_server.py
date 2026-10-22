# Receives script sources POSTed from Studio (execute_luau + HttpService) and
# writes them to games/<Game>/src/<Explorer path>.luau. Run: python tools/mirror_server.py "Stat Sim"
import json, os, sys
from http.server import BaseHTTPRequestHandler, HTTPServer

GAME = sys.argv[1] if len(sys.argv) > 1 else "Stat Sim"
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "games", GAME, "src")
EXT = {"Script": ".server.luau", "LocalScript": ".client.luau", "ModuleScript": ".luau"}

class H(BaseHTTPRequestHandler):
    def do_POST(self):
        data = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        written = 0
        for key, source in data.items():
            path, cls = key.rsplit("|", 1)
            parts = path.split(".")
            target = os.path.join(ROOT, *parts[:-1], parts[-1] + EXT.get(cls, ".luau"))
            os.makedirs(os.path.dirname(target), exist_ok=True)
            with open(target, "w", encoding="utf-8", newline="\n") as f:
                f.write(source)
            written += 1
        self.send_response(200)
        self.end_headers()
        self.wfile.write(("wrote %d" % written).encode())

HTTPServer(("127.0.0.1", 8765), H).serve_forever()
