import 'package:flutter/material.dart';
import 'package:project_tpm_prak/detail.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/searchPage.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'map_page.dart';
import 'dart:math';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController _pageController = PageController(viewportFraction: 0.85);

  Future<List<Movie>> fetchAllMovies() async {
    final rawList = await ApiService.fetchMovies('');
    return rawList.map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> fetchFeaturedMovies() async {
    final rawList = await ApiService.fetchMovies('');
    return rawList.map((e) => Movie.fromJson(e)).take(5).toList();
  }

  Future<List<Movie>> _fetchRandomFeaturedMovies() async {
    try {
      final rawList = await ApiService.fetchMovies('');
      final allMovies = rawList.map((e) => Movie.fromJson(e)).toList();
      allMovies.shuffle(Random());
      return allMovies.take(5).toList();
    } catch (e) {
      print('Error loading random featured movies: $e');
      return [];
    }
  }

  Widget _carouselBanner() {
    return FutureBuilder<List<Movie>>(
      future: _fetchRandomFeaturedMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.blueGrey[700]!),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const SizedBox(
              height: 180,
              child: Center(
                  child: Text("Gagal memuat film unggulan.",
                      style: TextStyle(color: Colors.red))));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
              height: 180,
              child: Center(
                  child: Text("Tidak ada film unggulan ditemukan.",
                      style: TextStyle(color: Colors.white))));
        }

        final featuredMovies = snapshot.data!;
        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: featuredMovies.length,
            itemBuilder: (context, index) {
              final movie = featuredMovies[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  try {
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      value = (_pageController.page! - index).abs();
                      value = (1 - (value * 0.3)).clamp(0.0, 1.0);
                    }
                  } catch (_) {}

                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Detail(id: movie.id),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        )
                      ],
                      image: DecorationImage(
                        image: NetworkImage(movie.posterUrl),
                        fit: BoxFit.cover,
                        // Tambahkan errorBuilder untuk gambar yang gagal dimuat
                        onError: (exception, stackTrace) {
                          print('Error loading image: $exception');
                        },
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(12)),
                        color: Colors
                            .black45, // Transparansi untuk teks di atas gambar
                      ),
                      child: Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Search title movies...',
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.white),
        ),
        style: const TextStyle(color: Colors.white),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Searchpage())),
      ),
    );
  }

  Widget _durationBadge(int duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(9),
          bottomRight: Radius.circular(9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$duration min',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _ratingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(9),
          bottomLeft: Radius.circular(9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            '$rating',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movie App'),
          actions: [
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'Buka Peta Bioskop',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _searchBar(),
            _carouselBanner(),
            Expanded(
              child: FutureBuilder<List<Movie>>(
                future: fetchAllMovies(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No movies found.'));
                  } else {
                    final movies = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: GridView.builder(
                        itemCount: movies.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1 / 1.3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(9),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Detail(id: movie.id),
                                  ),
                                );
                              },
                              child: Card(
                                color: Colors.white10,
                                elevation: 8,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(9)),
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              movie.posterUrl,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.white,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              child: _durationBadge(
                                                  movie.duration),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: _ratingBadge(movie.rating),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          movie.title,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
