#!/bin/bash
cd "$(dirname "$0")"
URL="http://localhost:8080/TubeFlow_All_In_One.html"
echo "TubeFlow is running at $URL"
echo "This runs only on your computer. Close this window to stop."
(sleep 1; open "$URL" 2>/dev/null || xdg-open "$URL") &
if command -v python3 >/dev/null 2>&1; then python3 -m http.server 8080
else ruby -run -e httpd . -p 8080; fi
