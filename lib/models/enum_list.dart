enum LocationItem { binongPermai, bintaro, kalibata, karawaci, kemanggisanBaru }

extension LocationItemExtension on LocationItem {
  String get displayName {
    switch (this) {
      case LocationItem.binongPermai:
        return "Binong Permai";
      case LocationItem.bintaro:
        return "Bintaro";
      case LocationItem.kalibata:
        return "Kalibata";
      case LocationItem.karawaci:
        return "Karawaci";
      case LocationItem.kemanggisanBaru:
        return "Kemanggisan Baru";
    }
  }
}

enum UrgencyItem { low, medium, high }

extension UrgencyExtension on UrgencyItem {
  String get displayName {
    switch (this) {
      case UrgencyItem.low:
        return "Low";
      case UrgencyItem.medium:
        return "Medium";
      case UrgencyItem.high:
        return "High";
    }
  }
}

enum StatusItem { pending, onProgress, resolved }

extension StatusExtension on StatusItem {
  String get displayName {
    switch (this) {
      case StatusItem.pending:
        return "Pending";
      case StatusItem.onProgress:
        return "On Progress";
      case StatusItem.resolved:
        return "Resolved";
    }
  }
}

enum CategoryItem { waste, water, electricity, gas, other }

extension CategoryExtension on CategoryItem {
  String get displayName {
    switch (this) {
      case CategoryItem.waste:
        return "Waste";
      case CategoryItem.water:
        return "Water";
      case CategoryItem.electricity:
        return "Electricity";
      case CategoryItem.gas:
        return "Gas";
      case CategoryItem.other:
        return "Other";
    }
  }
}

enum RoleItem { admin, leader, member }

extension RoleExtension on RoleItem {
  String get displayName {
    switch (this) {
      case RoleItem.admin:
        return "admin";
      case RoleItem.leader:
        return "leader";
      case RoleItem.member:
        return "member";
    }
  }
}
