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
    pricePerDay: 89,
    rating: 4.9,
    reviewCount: 128,
    ownerName: 'Minh T.',
    emoji: '🚗',
    isElectric: true,
    location: 'Hanoi',
  ),
  Vehicle(
    id: '2',
    name: 'BMW X5 xDrive',
    year: 2023,
    type: 'SUV',
    pricePerDay: 125,
    rating: 4.8,
    reviewCount: 94,
    ownerName: 'Linh N.',
    emoji: '🚙',
    location: 'Ho Chi Minh',
  ),
  Vehicle(
    id: '3',
    name: 'Mercedes C300',
    year: 2024,
    type: 'Sedan',
    pricePerDay: 110,
    rating: 4.7,
    reviewCount: 76,
    ownerName: 'Duc P.',
    emoji: '🏎️',
    location: 'Da Nang',
  ),
  Vehicle(
    id: '4',
    name: 'Toyota Camry',
    year: 2023,
    type: 'Sedan',
    pricePerDay: 55,
    rating: 4.6,
    reviewCount: 210,
    ownerName: 'Hoa L.',
    emoji: '🚗',
    location: 'Hanoi',
  ),
  Vehicle(
    id: '5',
    name: 'Hyundai Tucson',
    year: 2024,
    type: 'SUV',
    pricePerDay: 65,
    rating: 4.5,
    reviewCount: 183,
    ownerName: 'Nam V.',
    emoji: '🚙',
    location: 'Ho Chi Minh',
  ),
  Vehicle(
    id: '6',
    name: 'Kia EV6',
    year: 2024,
    type: 'Sedan',
    pricePerDay: 78,
    rating: 4.8,
    reviewCount: 62,
    ownerName: 'Trang M.',
    emoji: '⚡',
    isElectric: true,
    location: 'Da Nang',
  ),
  Vehicle(
    id: '7',
    name: 'Ford Ranger',
    year: 2023,
    type: 'Pickup',
    pricePerDay: 72,
    rating: 4.4,
    reviewCount: 97,
    ownerName: 'Khoa B.',
    emoji: '🛻',
    location: 'Can Tho',
  ),
  Vehicle(
    id: '8',
    name: 'Lexus RX 350',
    year: 2024,
    type: 'SUV',
    pricePerDay: 145,
    rating: 4.9,
    reviewCount: 45,
    ownerName: 'Phuong T.',
    emoji: '🚘',
    location: 'Hanoi',
  ),
];
