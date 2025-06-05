import 'package:flutter/material.dart';
import 'package:project_tpm_prak/favoriteLogic.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Detail extends StatefulWidget {
  final String id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isFav = false;
  // Ubah dari 'late' menjadi nullable
  YoutubePlayerController? _youtubeController;
  bool _isPlayerReady = false;
  final Favoritelogic _favoriteLogic = Favoritelogic();

  @override
  void initState() {
    super.initState();
    _favoriteLogic.initialize(); // Inisialisasi favorit logic
    // Tidak perlu inisialisasi di sini karena akan dilakukan di FutureBuilder
  }

  Future<Movie> fetchMovieDetails() async {
    return ApiService.getMoviesDetail(widget.id).then(Movie.fromJson);
  }

  void initializeYoutubePlayer(String youtubeUrl) {
    String? videoId = YoutubePlayer.convertUrlToId(youtubeUrl);
    if (videoId != null && videoId.isNotEmpty) {
      // Hanya inisialisasi jika belum diinisialisasi atau jika videoId berubah
      if (_youtubeController == null ||
          _youtubeController!.initialVideoId != videoId) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            disableDragSeek: false,
            loop: false,
            isLive: false,
            forceHD: false,
            enableCaption: true,
          ),
        );
        _isPlayerReady =
            false; // Reset status ready saat video baru diinisialisasi
      }
    } else {
      debugPrint('Invalid YouTube URL or video ID: $youtubeUrl');
      _youtubeController =
          null; // Pastikan controller null jika URL tidak valid
      _isPlayerReady = false;
    }
  }

  void _launchUrlExternal(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) throw 'Could not launch $url';
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka link: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak valid')),
      );
    }
  }

  @override
  void deactivate() {
    // Pastikan _youtubeController tidak null sebelum memanggil pause()
    _youtubeController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    // Pastikan _youtubeController tidak null sebelum memanggil dispose()
    _youtubeController?.dispose();
    super.dispose();
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData) {
            return const Center(
                child: Text('No Data', style: TextStyle(color: Colors.white)));
          }

          final movie = snapshot.data!;
          final isFav = _favoriteLogic.isFavorited(widget.id);

          // Inisialisasi atau perbarui YouTubeController di sini
          // Panggil initializeYoutubePlayer setiap kali data movie berubah
          initializeYoutubePlayer(movie.trailerUrl);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    movie.posterUrl,
                    errorBuilder: (_, __, ___) => const Icon(Icons.movie,
                        size: 150, color: Colors.white70),
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        movie.title,
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      alignment: Alignment.bottomRight,
                      onPressed: () {
                        _favoriteLogic.toggleFavorite(widget.id);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(!isFav
                                ? 'Ditambahkan ke favorit!'
                                : 'Dihapus dari favorit!'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
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
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 16),
                const Text('Synopsis:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(movie.synopsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
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
                const Text('Cast:',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: movie.cast
                      .map((actor) => Chip(
                            label: Text(actor,
                                style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.blueGrey.withOpacity(0.4),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                // Tampilkan YoutubePlayer hanya jika _youtubeController tidak null
                if (_youtubeController != null &&
                    movie.trailerUrl.isNotEmpty &&
                    YoutubePlayer.convertUrlToId(movie.trailerUrl) != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trailer:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      YoutubePlayer(
                        controller:
                            _youtubeController!, // Gunakan operator ! karena sudah dicheck null
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: Colors.amber,
                        progressColors: const ProgressBarColors(
                          playedColor: Colors.amber,
                          handleColor: Colors.amberAccent,
                        ),
                        onReady: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!_isPlayerReady) {
                              setState(() {
                                _isPlayerReady = true;
                              });
                            }
                          });
                        },
                        bottomActions: [
                          CurrentPosition(),
                          ProgressBar(),
                          const RemainingDuration(),
                          FullScreenButton(),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () =>
                            _launchUrlExternal(context, movie.trailerUrl),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text("Open Trailer in Browser"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Trailer tidak tersedia atau URL tidak valid.')),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text("Trailer Not Available"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
