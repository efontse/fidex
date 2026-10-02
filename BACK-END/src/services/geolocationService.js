class GeolocationService {
  /**
   * Mock address coordinates dictionary for realistic testing
   */
  static KNOWN_LOCATIONS = {
    'lagos': { lat: 6.5244, lng: 3.3792 },
    'ibadan': { lat: 7.3775, lng: 3.9470 },
    'abuja': { lat: 9.0765, lng: 7.3986 },
    'kano': { lat: 12.0022, lng: 8.5920 },
    'farm zone a': { lat: 7.1500, lng: 3.8200 },
    'green valley farm': { lat: 7.2100, lng: 3.9100 },
    'central depot': { lat: 6.5500, lng: 3.3500 },
    'metro market': { lat: 6.4500, lng: 3.4200 }
  };

  /**
   * Locate an address using Geolocation API
   * @param {string} address
   */
  static async locate(address) {
    if (!address || typeof address !== 'string') {
      return {
        lat: 6.5244,
        lng: 3.3792,
        formattedAddress: 'Default Hub, Lagos'
      };
    }

    const lower = address.toLowerCase();
    for (const [key, coords] of Object.entries(this.KNOWN_LOCATIONS)) {
      if (lower.includes(key)) {
        return {
          lat: coords.lat,
          lng: coords.lng,
          formattedAddress: address
        };
      }
    }

    // Deterministic pseudo-coordinates based on string hash for other arbitrary addresses
    let hash = 0;
    for (let i = 0; i < address.length; i++) {
      hash = address.charCodeAt(i) + ((hash << 5) - hash);
    }
    const lat = 6.4 + ((Math.abs(hash) % 1000) / 1000) * 1.5;
    const lng = 3.2 + ((Math.abs(hash * 31) % 1000) / 1000) * 1.5;

    return {
      lat: parseFloat(lat.toFixed(4)),
      lng: parseFloat(lng.toFixed(4)),
      formattedAddress: address
    };
  }

  /**
   * Calculate great-circle distance between two coordinate pairs using Haversine formula (in kilometers)
   * @param {{ lat: number, lng: number }} a
   * @param {{ lat: number, lng: number }} b
   */
  static getDistance(a, b) {
    if (!a || !b || a.lat === undefined || b.lat === undefined) {
      return 12.5; // default fallback km
    }

    const toRad = (value) => (value * Math.PI) / 180;
    const R = 6371; // Earth radius in kilometers

    const dLat = toRad(b.lat - a.lat);
    const dLng = toRad(b.lng - a.lng);

    const lat1 = toRad(a.lat);
    const lat2 = toRad(b.lat);

    const sinDLat = Math.sin(dLat / 2);
    const sinDLng = Math.sin(dLng / 2);

    const calc =
      sinDLat * sinDLat +
      Math.sin(dLng / 2) * Math.sin(dLng / 2) * Math.cos(lat1) * Math.cos(lat2);

    const c = 2 * Math.atan2(Math.sqrt(calc), Math.sqrt(1 - calc));
    const distanceKm = R * c;

    return parseFloat(distanceKm.toFixed(2));
  }

  /**
   * Calculate complete delivery route between pickup and dropoff
   */
  static async calculateDeliveryRoute(pickupAddress, dropoffAddress) {
    const pickup = await this.locate(pickupAddress);
    const dropoff = await this.locate(dropoffAddress);
    const distanceKm = this.getDistance(pickup, dropoff);

    // Rough delivery time estimation (avg speed: 35 km/h in urban/peri-urban traffic + 15 min handling)
    const estimatedMinutes = Math.round((distanceKm / 35) * 60 + 15);

    return {
      pickup,
      dropoff,
      distanceKm,
      estimatedMinutes
    };
  }
}

module.exports = GeolocationService;
