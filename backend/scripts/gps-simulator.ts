/**
 * Giả lập thiết bị GPS: phát toạ độ xe cho các chuyến đang chạy (IN_PROGRESS)
 * bằng cách POST vào chính ingest endpoint `POST /api/tracking/:vehicleId`.
 *
 * Đây là bản thay thế phần cứng: khi có hộp đen GSM/OBD-II thật, chỉ cần thiết
 * bị POST cùng payload + header `x-device-key` vào endpoint này — backend không
 * đổi gì. Chạy song song `npm run dev` khi demo:
 *   npm run sim:gps
 *
 * Đọc booking IN_PROGRESS qua Prisma (chỉ để biết xe nào đang chạy), rồi mô
 * phỏng mỗi xe men theo một tuyến waypoints quanh Hà Nội với tốc độ ~40 km/h.
 */
import { prisma } from "@/db/prisma";
import { getEnv } from "@/lib/config/env";

// Tuyến demo: vòng quanh hồ Hoàn Kiếm → phố cổ (lat, lng).
const ROUTE: Array<[number, number]> = [
  [21.0287, 105.8524],
  [21.0312, 105.8535],
  [21.0338, 105.8521],
  [21.0349, 105.8489],
  [21.0331, 105.8462],
  [21.0301, 105.8458],
  [21.0278, 105.8482],
  [21.0271, 105.8511],
];

const TICK_MS = 2500;
const SPEED_KMH = 40;
const RESCAN_EVERY_TICKS = 12; // quét lại booking active mỗi ~30s

interface SimCar {
  vehicleId: string;
  seg: number; // chỉ số waypoint hiện tại
  t: number; // tiến độ 0..1 trên đoạn [seg, seg+1]
  offset: number; // lệch nhỏ để nhiều xe không chồng khít
}

function haversineMeters(a: [number, number], b: [number, number]): number {
  const R = 6371000;
  const dLat = ((b[0] - a[0]) * Math.PI) / 180;
  const dLng = ((b[1] - a[1]) * Math.PI) / 180;
  const lat1 = (a[0] * Math.PI) / 180;
  const lat2 = (b[0] * Math.PI) / 180;
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

// Nội suy tuyến tính; nhích `t` theo quãng đường đi được mỗi tick.
function advance(car: SimCar): [number, number] {
  const from = ROUTE[car.seg];
  const to = ROUTE[(car.seg + 1) % ROUTE.length];
  const segMeters = haversineMeters(from, to);
  const stepMeters = (SPEED_KMH * 1000 / 3600) * (TICK_MS / 1000);
  car.t += segMeters > 0 ? stepMeters / segMeters : 1;
  while (car.t >= 1) {
    car.t -= 1;
    car.seg = (car.seg + 1) % ROUTE.length;
  }
  const a = ROUTE[car.seg];
  const b = ROUTE[(car.seg + 1) % ROUTE.length];
  return [
    a[0] + (b[0] - a[0]) * car.t + car.offset,
    a[1] + (b[1] - a[1]) * car.t + car.offset,
  ];
}

async function loadActiveCars(existing: Map<string, SimCar>): Promise<void> {
  const active = await prisma.booking.findMany({
    where: { status: "IN_PROGRESS" },
    select: { vehicleId: true },
    distinct: ["vehicleId"],
  });
  const ids = new Set(active.map((b) => b.vehicleId));
  // Thêm xe mới vào chuyến.
  let i = existing.size;
  for (const id of ids) {
    if (!existing.has(id)) {
      existing.set(id, {
        vehicleId: id,
        seg: i % ROUTE.length,
        t: 0,
        offset: (i % 5) * 0.0004,
      });
      i++;
    }
  }
  // Bỏ xe đã kết thúc chuyến.
  for (const id of existing.keys()) {
    if (!ids.has(id)) existing.delete(id);
  }
}

async function post(
  baseUrl: string,
  key: string,
  car: SimCar,
): Promise<void> {
  const [lat, lng] = advance(car);
  try {
    const res = await fetch(`${baseUrl}/api/tracking/${car.vehicleId}`, {
      method: "POST",
      headers: { "content-type": "application/json", "x-device-key": key },
      body: JSON.stringify({ lat, lng, speedKmh: SPEED_KMH }),
    });
    if (!res.ok) {
      console.warn(`  ✗ ${car.vehicleId}: HTTP ${res.status}`);
    }
  } catch (err) {
    console.warn(`  ✗ ${car.vehicleId}: ${(err as Error).message}`);
  }
}

async function main(): Promise<void> {
  const env = getEnv();
  const key = env.TRACKING_DEVICE_KEY;
  const baseUrl =
    process.env.TRACKING_INGEST_BASE_URL ?? "http://localhost:8001";
  if (!key) {
    console.error("TRACKING_DEVICE_KEY chưa đặt trong .env — không thể gửi.");
    process.exit(1);
  }

  console.log(`GPS simulator → ${baseUrl}  (tick ${TICK_MS}ms)`);
  const cars = new Map<string, SimCar>();
  let tick = 0;

  // Vòng lặp vô hạn: mỗi tick gửi 1 điểm/xe; định kỳ quét lại chuyến active.
  for (;;) {
    if (tick % RESCAN_EVERY_TICKS === 0) {
      await loadActiveCars(cars);
      console.log(`[rescan] ${cars.size} xe đang trong chuyến`);
    }
    await Promise.all([...cars.values()].map((c) => post(baseUrl, key, c)));
    tick++;
    await new Promise((r) => setTimeout(r, TICK_MS));
  }
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
