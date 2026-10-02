class AppAssetImages {
  static const String pisciculture = 'assets/images/pisciculture_farm_1790249306744.jpg';
  static const String horticulture = 'assets/images/horticulture_farm_1790249338963.jpg';
  static const String apiculture = 'assets/images/apiculture_farm_1790249367494.jpg';
  static const String dairy = 'assets/images/dairy_farm_1790249443487.jpg';
  static const String poultry = 'assets/images/poultry_farm_1790249523691.jpg';

  static const List<String> farmingFields = [
    'Horticulture',
    'Pisciculture',
    'Apiculture',
    'Dairy Farming',
    'Poultry Farm',
    'Cereals',
    'Vegetables',
    'Fruits',
    'Seeds & Seedlings',
    'Fertilizers & Agricultural Inputs',
    'Agricultural Equipment',
  ];

  static String getImageForSector(String? sector) {
    if (sector == null) return horticulture;
    final lower = sector.toLowerCase();
    if (lower.contains('pisci') || lower.contains('fish') || lower.contains('aqua')) {
      return pisciculture;
    }
    if (lower.contains('apic') || lower.contains('bee') || lower.contains('honey')) {
      return apiculture;
    }
    if (lower.contains('dairy') || lower.contains('milk') || lower.contains('cheese')) {
      return dairy;
    }
    if (lower.contains('poultry') || lower.contains('chicken') || lower.contains('egg')) {
      return poultry;
    }
    return horticulture;
  }

  static String getSectorIconEmoji(String sector) {
    final lower = sector.toLowerCase();
    if (lower.contains('pisci') || lower.contains('fish')) return '🐟';
    if (lower.contains('apic') || lower.contains('bee')) return '🍯';
    if (lower.contains('dairy') || lower.contains('milk')) return '🥛';
    if (lower.contains('poultry') || lower.contains('chicken')) return '🐔';
    if (lower.contains('cereal') || lower.contains('grain') || lower.contains('rice') || lower.contains('wheat')) return '🌾';
    if (lower.contains('vegetable') || lower.contains('veggie')) return '🥦';
    if (lower.contains('fruit')) return '🍊';
    if (lower.contains('seed')) return '🌱';
    if (lower.contains('fertilizer') || lower.contains('input')) return '🧪';
    if (lower.contains('equipment') || lower.contains('tool')) return '🚜';
    return '🥬'; // Horticulture default
  }
}
