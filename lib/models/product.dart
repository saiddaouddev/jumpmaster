class HomeProduct {
  final String name;
    double price=0;
  final String imageUrl;
  final String url;

  HomeProduct.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = double.parse(json['price'].toString()),
        imageUrl = json['image_url'],
        url = json['url'];
}
