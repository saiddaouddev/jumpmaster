class HomeCarouselItem {
  final int id;
  final String imageUrl;
  final bool showButton;
  final String? buttonText;
  final String? buttonUrl;

  HomeCarouselItem({
    required this.id,
    required this.imageUrl,
    required this.showButton,
    this.buttonText,
    this.buttonUrl,
  });

  factory HomeCarouselItem.fromJson(Map<String, dynamic> json) {
    return HomeCarouselItem(
      id: json['id'],
      imageUrl: json['image_url'],
      showButton: json['show_button'] ?? false,
      buttonText: json['button_text'],
      buttonUrl: json['button_url'],
    );
  }
}
