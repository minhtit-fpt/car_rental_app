class Vehicle {
  const Vehicle({
    required this.id,
    required this.name,
    required this.year,
    required this.type,
    required this.pricePerDay,
    required this.rating,
    required this.reviewCount,
    required this.ownerName,
    required this.emoji,
    this.isElectric = false,
    this.location = '',
  });

  final String id;
  final String name;
  final int year;
  final String type;
  final double pricePerDay;
  final double rating;
  final int reviewCount;
  final String ownerName;
  final String emoji;
  final bool isElectric;
  final String location;
}

/// Static mock data matching the Figma design
const List<Vehicle> kMockVehicles = [
  Vehicle(
    id: '1',
    name: 'Tesla Model 3',
    year: 2024,
    type: 'Sedan',
    pricePerDay: 890,
    rating: 4.9,
    reviewCount: 128,
    ownerName: 'Minh T.',
    emoji: '🚗',
    isElectric: true,
    location: 'Hà Nội',
  ),
  Vehicle(
    id: '2',
    name: 'BMW X5 xDrive',
    year: 2023,
    type: 'SUV',
    pricePerDay: 1250,
    rating: 4.8,
    reviewCount: 94,
    ownerName: 'Linh N.',
    emoji: '🚙',
    location: 'TP. Hồ Chí Minh',
  ),
  Vehicle(
    id: '3',
    name: 'Mercedes C300',
    year: 2024,
    type: 'Sedan',
    pricePerDay: 1100,
    rating: 4.7,
    reviewCount: 76,
    ownerName: 'Đức P.',
    emoji: '🏎️',
    location: 'Đà Nẵng',
  ),
  Vehicle(
    id: '4',
    name: 'Toyota Camry',
    year: 2023,
    type: 'Sedan',
    pricePerDay: 550,
    rating: 4.6,
    reviewCount: 210,
    ownerName: 'Hoa L.',
    emoji: '🚗',
    location: 'Hà Nội',
  ),
  Vehicle(
    id: '5',
    name: 'Hyundai Tucson',
    year: 2024,
    type: 'SUV',
    pricePerDay: 650,
    rating: 4.5,
    reviewCount: 183,
    ownerName: 'Nam V.',
    emoji: '🚙',
    location: 'TP. Hồ Chí Minh',
  ),
  Vehicle(
    id: '6',
    name: 'Kia EV6',
    year: 2024,
    type: 'Sedan',
    pricePerDay: 780,
    rating: 4.8,
    reviewCount: 62,
    ownerName: 'Trang M.',
    emoji: '⚡',
    isElectric: true,
    location: 'Đà Nẵng',
  ),
  Vehicle(
    id: '7',
    name: 'Ford Ranger',
    year: 2023,
    type: 'Pickup',
    pricePerDay: 720,
    rating: 4.4,
    reviewCount: 97,
    ownerName: 'Khoa B.',
    emoji: '🛻',
    location: 'Cần Thơ',
  ),
  Vehicle(
    id: '8',
    name: 'Lexus RX 350',
    year: 2024,
    type: 'SUV',
    pricePerDay: 1450,
    rating: 4.9,
    reviewCount: 45,
    ownerName: 'Phương T.',
    emoji: '🚘',
    location: 'Hà Nội',
  ),
];
