class Review {
  final int id;
  final String user;
  final double rating;
  final String comment;
  final bool isMyReview;

  Review({
    required this.id,
    required this.user,
    required this.rating,
    required this.comment,
    required this.isMyReview,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String userName = 'Anonymous';
    if (json['user'] != null) {
      if (json['user'] is Map) {
        userName = json['user']['name'] ?? 'Anonymous';
      } else if (json['user'] is String) {
        userName = json['user'];
      }
    } else if (json['name'] != null) {
      userName = json['name'];
    }

    double ratingVal = 0.0;
    if (json['rating'] != null) {
      ratingVal = double.tryParse(json['rating'].toString()) ?? 0.0;
    }

    return Review(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      user: userName,
      rating: ratingVal,
      comment: json['comment'] ?? '',
      isMyReview: json['is_me'] ?? false, 
    );
  }
}