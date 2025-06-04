import 'package:flutter/material.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class Detail extends StatelessWidget {
  final String id;
  const Detail({super.key, required this.id});

  Future<Movie> fetchMovieDetails() => ApiService.getMoviesDetail(id).then(Movie.fromJson);

  void _launchTrailer(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open trailer')),
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
            return const Center(child: Text('No Data', style: TextStyle(color: Colors.white)));
          }

          final movie = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(movie.posterUrl, errorBuilder: (_, __, ___) => const Icon(Icons.movie)),
                const SizedBox(height: 12),
                Text(movie.title, style: const TextStyle(fontSize: 22, color: Colors.white)),
                Text(movie.genre, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Text(movie.synopsis, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                Text('Director: ${movie.director}', style: const TextStyle(color: Colors.white)),
                Text('Duration: ${movie.duration} min', style: const TextStyle(color: Colors.white)),
                Text('Language: ${movie.language}', style: const TextStyle(color: Colors.white)),
                Text('Release: ${movie.releaseDate}', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: movie.cast.map((actor) => Chip(label: Text(actor))).toList(),
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
