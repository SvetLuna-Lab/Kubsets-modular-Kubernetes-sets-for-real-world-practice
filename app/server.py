import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(os.getenv("PORT", "8080"))

class Handler(BaseHTTPRequestHandler):
    def _send(self, code: int, body: str, content_type: str = "text/plain; charset=utf-8"):
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.end_headers()
        self.wfile.write(body.encode("utf-8"))

    def do_GET(self):
        if self.path == "/health":
            self._send(200, "ok\n")
            return

        if self.path == "/env":
            lines = [
                f"NAMESPACE={os.getenv('NAMESPACE','')}",
                f"APP_NAME={os.getenv('APP_NAME','')}",
                f"DB_HOST={os.getenv('DB_HOST','')}",
                f"DB_PORT={os.getenv('DB_PORT','')}",
                f"DB_NAME={os.getenv('DB_NAME','')}",
                f"DB_USER={os.getenv('DB_USER','')}",
            ]
            self._send(200, "\n".join(lines) + "\n")
            return

        self._send(404, "not found\n")

def main():
    srv = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"listening on :{PORT}", flush=True)
    srv.serve_forever()

if __name__ == "__main__":
    main()
