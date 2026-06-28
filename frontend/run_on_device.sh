#!/usr/bin/env bash
# Chạy app trên MÁY THẬT cùng Wi-Fi với máy dev.
# Tự dò IP LAN của máy này; hoặc truyền tay: ./run_on_device.sh 192.168.0.123
#
# Trước khi chạy, bật 2 service bind ra LAN (0.0.0.0):
#   backend:    cd backend && npm run dev          # Next.js đã tự bind 0.0.0.0:8001
#   ai-service: cd ai-service && uvicorn app.main:app --port 8000 --host 0.0.0.0
set -euo pipefail

IP="${1:-$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)}"
if [ -z "${IP:-}" ]; then
  echo "✗ Không dò được IP LAN. Truyền tay: ./run_on_device.sh 192.168.0.123" >&2
  exit 1
fi

echo "→ IP máy dev: $IP   (backend :8001, ai-service :8000)"
echo "  Đảm bảo điện thoại cùng Wi-Fi và 2 service đang chạy với --host 0.0.0.0."
exec flutter run \
  --dart-define=API_BASE_URL="http://$IP:8001" \
  --dart-define=AI_BASE_URL="http://$IP:8000"
