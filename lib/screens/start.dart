import 'package:flutter/material.dart';
import 'package:hackheroes_flutter/services/api.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Aktualne Wyzwanie",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22A45D),
                      ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildChallengeCard(),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      // leading: IconButton(
      //   icon: Icon(
      //     _isSidebarOpen ? Icons.close : Icons.menu,
      //     color: Colors.black,
      //   ),
      //   onPressed: () {
      //     setState(() {
      //       _isSidebarOpen = !_isSidebarOpen;
      //     });
      //   },
      // ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: const Text(
              'JD',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Provider.of<ApiService>(context).user.email,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard() {
    final Challenge challenge = Provider.of<ApiService>(context).challenge;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Text(
                    challenge.category.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Text(
                  _getTimeRemaining(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                )
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                Text(
                  challenge.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey[800], fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 42),
              ],
            ),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _shuffleChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22A45D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  label: const Text("Potwierdź Wyzwanie"),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _confirmChallenge,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF22A45D),
                    side: const BorderSide(color: Color(0xFF22A45D), width: 2),
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Wylosuj ponownie"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getTimeRemaining() {
    final date = Provider.of<ApiService>(context).user.currentChallengeDate;
    if (date == null) {
      return "00:00:00";
    }

    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final remaining = endOfDay.difference(now);
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
      }
    });

    return "$hours:$minutes:$seconds";
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.flash_on),
          label: 'Aktualne Wyzwanie',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historia',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard),
          label: 'Nagrody',
        ),
      ],
      selectedItemColor: const Color(0xFF22A45D),
      unselectedItemColor: Colors.grey,
    );
  }

  void _shuffleChallenge() {
    // Logic for shuffling the challenge can be implemented here.
  }

  void _confirmChallenge() {
    // Logic for confirming the challenge can be implemented here.
  }
}
