import 'package:flutter/material.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Detail extends StatefulWidget {
  final String id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isFav = false;

  Future<Movie> fetchMovieDetails() async {
    return ApiService.getMoviesDetail(widget.id).then(Movie.fromJson);
  }

  void _launchTrailer(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault, // atau coba inAppBrowserView
        );
        if (!launched) throw 'Could not launch';
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka trailer')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak valid')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Movie Detail"),
      ),
      body: FutureBuilder<Movie>(
        future: fetchMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text('No Data', style: TextStyle(color: Colors.white)));
          }

          final movie = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(movie.posterUrl,
                      errorBuilder: (_, __, ___) => const Icon(Icons.movie)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        style:
                            const TextStyle(fontSize: 22, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      alignment: Alignment.bottomRight,
                      onPressed: () {
                        // Toggle favorite status
                      },
                      icon: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        color: isFav ? Colors.amber : Colors.grey,
                      ),
                      tooltip:
                          isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                    ),
                  ],
                ),
                Text(movie.genre,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Text(movie.synopsis,
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                Text('Director: ${movie.director}',
                    style: const TextStyle(color: Colors.white)),
                Text('Duration: ${movie.duration} min',
                    style: const TextStyle(color: Colors.white)),
                Text('Language: ${movie.language}',
                    style: const TextStyle(color: Colors.white)),
                Text('Release: ${movie.releaseDate}',
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: movie.cast
                      .map((actor) => Chip(label: Text(actor)))
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (movie.trailerUrl.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _launchTrailer(context, movie.trailerUrl),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Watch Trailer"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
