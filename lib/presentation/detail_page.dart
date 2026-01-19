import 'package:flutter/material.dart';
import 'package:uas_3012310037/data/model/destinations.dart';
import 'package:uas_3012310037/data/model/review.dart';
import 'package:uas_3012310037/data/repository/destinations_repository.dart';
import 'package:uas_3012310037/data/service/httpservice.dart';

class DetailDestinationPage extends StatefulWidget {
  final destinations place;
  final String imageUrl;

  const DetailDestinationPage({
    super.key,
    required this.place,
    required this.imageUrl,
  });

  @override
  State<DetailDestinationPage> createState() => _DetailDestinationPageState();
}

class _DetailDestinationPageState extends State<DetailDestinationPage> {
  late DestinationsRepository _repository;
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final httpService = HttpService();
    _repository = DestinationsRepository(httpService: httpService);
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final data = await _repository.getReviews(widget.place.id);
      if (mounted) {
        setState(() {
          _reviews = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddReviewDialog() {
    final TextEditingController commentCtr = TextEditingController();
    double _tempRating = 5.0;
    bool _isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Tulis Ulasan"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          index < _tempRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _tempRating = index + 1.0;
                          });
                        },
                      );
                    }).expand((widget) => [widget, const SizedBox(width: 4)]).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentCtr,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Bagaimana pengalamanmu?",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (commentCtr.text.isEmpty) return;

                        setDialogState(() => _isSubmitting = true);

                        try {
                          await _repository.submitReview(
                            widget.place.id,
                            {
                              'comment': commentCtr.text,
                              'rating': _tempRating,
                            },
                          );

                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Ulasan terkirim!")),
                            );
                            _fetchReviews();
                          }
                        } catch (e) {
                          if (mounted) {
                            setDialogState(() => _isSubmitting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Gagal mengirim ulasan")),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text("Kirim", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteReview(int reviewId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Ulasan"),
            content: const Text("Yakin ingin menghapus ulasan ini?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Batal")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child:
                      const Text("Hapus", style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final success = await _repository.deleteReview(reviewId);
      if (success && mounted) {
        _fetchReviews();
      }
    }
  }

  void _editReview(Review review) {
    final TextEditingController editCtr =
        TextEditingController(text: review.comment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Ulasan"),
        content: TextField(
          controller: editCtr,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _repository.updateReview(
                  review.id, editCtr.text, review.rating);
              if (success && mounted) {
                _fetchReviews();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF)),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReviewDialog,
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text("Ulas", style: TextStyle(color: Colors.white)),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.place.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF6C63FF), size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.place.address,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.place.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ulasan Pengunjung",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${widget.place.rating} / 5.0",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _reviews.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text("Belum ada ulasan.",
                                    style: TextStyle(color: Colors.grey)),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _reviews.length,
                                itemBuilder: (context, index) {
                                  final review = _reviews[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  radius: 16,
                                                  child: const Icon(Icons.person,
                                                      size: 20,
                                                      color: Colors.white),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  review.user,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            if (review.isMyReview)
                                              PopupMenuButton<String>(
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _editReview(review);
                                                  } else if (value ==
                                                      'delete') {
                                                    _deleteReview(review.id);
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                  const PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.edit,
                                                            size: 18,
                                                            color: Colors.blue),
                                                        SizedBox(width: 8),
                                                        Text('Edit'),
                                                      ],
                                                    ),
                                                  ),
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.delete,
                                                            size: 18,
                                                            color: Colors.red),
                                                        SizedBox(width: 8),
                                                        Text('Hapus'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                child: const Icon(Icons.more_vert,
                                                    color: Colors.grey),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children:
                                              List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex < review.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review.comment,
                                          style: TextStyle(
                                              color: Colors.grey[700],
                                              height: 1.4),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}