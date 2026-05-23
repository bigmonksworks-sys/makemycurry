class NearbyBranchModel {
  int? id;
  String? name;
  String? email;
  String? longitude;
  String? latitude;
  String? address;
  double? coverage;
  int? status;
  String? image;
  double? distanceKm;
  int? estimatedDeliveryTime;
  bool? isAvailable;
  String? imageFullPath;

  NearbyBranchModel({
    this.id,
    this.name,
    this.email,
    this.longitude,
    this.latitude,
    this.address,
    this.coverage,
    this.status,
    this.image,
    this.distanceKm,
    this.estimatedDeliveryTime,
    this.isAvailable,
    this.imageFullPath,
  });

  NearbyBranchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    address = json['address'];
    coverage = json['coverage'] != null ? double.tryParse(json['coverage'].toString()) : null;
    status = json['status'];
    image = json['image'];
    distanceKm = json['distance_km'] != null ? double.tryParse(json['distance_km'].toString()) : null;
    estimatedDeliveryTime = json['estimated_delivery_time'];
    isAvailable = json['is_available'];
    imageFullPath = json['image_full_path'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['longitude'] = longitude;
    data['latitude'] = latitude;
    data['address'] = address;
    data['coverage'] = coverage;
    data['status'] = status;
    data['image'] = image;
    data['distance_km'] = distanceKm;
    data['estimated_delivery_time'] = estimatedDeliveryTime;
    data['is_available'] = isAvailable;
    data['image_full_path'] = imageFullPath;
    return data;
  }
}
