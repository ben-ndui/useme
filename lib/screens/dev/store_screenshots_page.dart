import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:useme/config/useme_theme.dart';

/// Page pour générer les screenshots des stores.
/// Accéder via /dev/screenshots en mode debug.
class StoreScreenshotsPage extends StatefulWidget {
  const StoreScreenshotsPage({super.key});

  @override
  State<StoreScreenshotsPage> createState() => _StoreScreenshotsPageState();
}

class _StoreScreenshotsPageState extends State<StoreScreenshotsPage> {
  int _currentIndex = 0;
  bool _captureMode = false;

  final List<ScreenshotData> _screenshots = [
    ScreenshotData(
      title: 'Trouve le studio\nparfait',
      subtitle: 'Découvre les meilleurs studios près de chez toi',
      gradientColors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
      mockScreenType: MockScreenType.discovery,
    ),
    ScreenshotData(
      title: 'Réserve en\nquelques clics',
      subtitle: 'Choisis ton créneau et ton ingénieur',
      gradientColors: [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
      mockScreenType: MockScreenType.booking,
    ),
    ScreenshotData(
      title: 'Gère tes\nsessions',
      subtitle: 'Suivi en temps réel de ton planning',
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      mockScreenType: MockScreenType.sessions,
    ),
    ScreenshotData(
      title: 'Communique\ndirectement',
      subtitle: 'Chat intégré avec le studio',
      gradientColors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
      mockScreenType: MockScreenType.messaging,
    ),
    ScreenshotData(
      title: 'Pilote ton\nstudio',
      subtitle: 'Dashboard intuitif pour les pros',
      gradientColors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      mockScreenType: MockScreenType.dashboard,
    ),
    ScreenshotData(
      title: 'Gère ton\néquipe',
      subtitle: "Plannings et disponibilités de tes ingés",
      gradientColors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
      mockScreenType: MockScreenType.team,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Force portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    if (_captureMode) {
      return _buildCaptureScreen(_screenshots[_currentIndex]);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a2e),
        title: Text(
          'Screenshot ${_currentIndex + 1}/${_screenshots.length}',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Mode capture',
            onPressed: () => setState(() => _captureMode = true),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AspectRatio(
                  aspectRatio: 1290 / 2796, // iPhone 15 Pro Max
                  child: _buildScreenshot(_screenshots[_currentIndex]),
                ),
              ),
            ),
          ),
          // Navigation
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildCaptureScreen(ScreenshotData data) {
    return GestureDetector(
      onTap: () => setState(() => _captureMode = false),
      child: _buildScreenshot(data),
    );
  }

  Widget _buildScreenshot(ScreenshotData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: data.gradientColors,
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Device mockup
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: _IPhoneMockup(
                  child: _buildMockScreen(data.mockScreenType),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockScreen(MockScreenType type) {
    switch (type) {
      case MockScreenType.discovery:
        return const _DiscoveryMockScreen();
      case MockScreenType.booking:
        return const _BookingMockScreen();
      case MockScreenType.sessions:
        return const _SessionsMockScreen();
      case MockScreenType.messaging:
        return const _MessagingMockScreen();
      case MockScreenType.dashboard:
        return const _DashboardMockScreen();
      case MockScreenType.team:
        return const _TeamMockScreen();
    }
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_screenshots.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive ? UseMeTheme.primaryColor : Colors.white24,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentIndex > 0
                        ? () => setState(() => _currentIndex--)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Précédent'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _currentIndex < _screenshots.length - 1
                        ? () => setState(() => _currentIndex++)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: UseMeTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Suivant'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Instructions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pour capturer les screenshots :', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('1. Lancer sur simulateur iPhone 15 Pro Max'),
            SizedBox(height: 8),
            Text('2. Appuyer sur l\'icône plein écran (⛶)'),
            SizedBox(height: 8),
            Text('3. Cmd+S pour capturer l\'écran'),
            SizedBox(height: 8),
            Text('4. Taper l\'écran pour revenir'),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Text('Dimensions requises :', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• iPhone 6.7" : 1290 × 2796 px'),
            Text('• iPhone 6.5" : 1284 × 2778 px'),
            Text('• iPhone 5.5" : 1242 × 2208 px'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

class ScreenshotData {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final MockScreenType mockScreenType;

  const ScreenshotData({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.mockScreenType,
  });
}

enum MockScreenType { discovery, booking, sessions, messaging, dashboard, team }

/// Realistic iPhone mockup with Dynamic Island
class _IPhoneMockup extends StatelessWidget {
  final Widget child;

  const _IPhoneMockup({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2a2a2a),
          width: 3,
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // Screen content
            Positioned.fill(child: child),
            // Dynamic Island
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 120,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            // Home indicator
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MOCK SCREENS
// ============================================================================

class _DiscoveryMockScreen extends StatelessWidget {
  const _DiscoveryMockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 60),
          _MockStatusBar(),
          const SizedBox(height: 8),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500], size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rechercher un studio...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Section title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Studios à proximité',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: UseMeTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Studio cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _StudioCard(
                  name: 'Studio Acoustik',
                  rating: 4.9,
                  reviews: 127,
                  distance: '1.2 km',
                  tags: ['Recording', 'Mix'],
                  isPartner: true,
                ),
                SizedBox(height: 12),
                _StudioCard(
                  name: 'Sound Factory',
                  rating: 4.7,
                  reviews: 89,
                  distance: '2.5 km',
                  tags: ['Mix', 'Mastering'],
                  isPartner: false,
                ),
                SizedBox(height: 12),
                _StudioCard(
                  name: 'Melody Records',
                  rating: 4.8,
                  reviews: 156,
                  distance: '3.1 km',
                  tags: ['Recording', 'Production'],
                  isPartner: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingMockScreen extends StatelessWidget {
  const _BookingMockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 60),
          _MockStatusBar(),
          const SizedBox(height: 8),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Studio Acoustik',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Recording Session',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Calendar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.chevron_left, color: Colors.grey[400]),
                      const Text(
                        'Décembre 2024',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                        .map((d) => SizedBox(
                              width: 36,
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CalendarDay('23', false, false),
                      _CalendarDay('24', false, false),
                      _CalendarDay('25', true, false),
                      _CalendarDay('26', false, true),
                      _CalendarDay('27', false, true),
                      _CalendarDay('28', false, false),
                      _CalendarDay('29', false, false),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Time slots section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Créneaux disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Time slots
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _TimeSlot('10:00', false, true),
                _TimeSlot('12:00', false, true),
                _TimeSlot('14:00', true, true),
                _TimeSlot('16:00', false, true),
                _TimeSlot('18:00', false, false),
              ],
            ),
          ),
          const Spacer(),
          // Book button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Réserver ce créneau',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SessionsMockScreen extends StatelessWidget {
  const _SessionsMockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _MockStatusBar(dark: false),
          const SizedBox(height: 8),
          // Title
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Mes Sessions',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Text(
                      'À venir',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Passées',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Sessions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _SessionCard(
                  studio: 'Studio Acoustik',
                  service: 'Recording Session',
                  date: 'Aujourd\'hui',
                  time: '14:00 - 18:00',
                  status: 'Confirmée',
                  statusColor: Colors.green,
                ),
                SizedBox(height: 12),
                _SessionCard(
                  studio: 'Sound Factory',
                  service: 'Mix & Master',
                  date: 'Demain',
                  time: '10:00 - 12:00',
                  status: 'En attente',
                  statusColor: Colors.orange,
                ),
                SizedBox(height: 12),
                _SessionCard(
                  studio: 'Melody Records',
                  service: 'Production',
                  date: 'Ven. 27 Déc',
                  time: '15:00 - 19:00',
                  status: 'Confirmée',
                  statusColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagingMockScreen extends StatelessWidget {
  const _MessagingMockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 60),
          _MockStatusBar(),
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Text(
                      'SA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Studio Acoustik',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      Text(
                        'En ligne',
                        style: TextStyle(color: Colors.green, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  _MessageBubble(
                    text: 'Salut ! Ta session est confirmée pour demain à 14h 🎵',
                    isMe: false,
                    time: '10:32',
                  ),
                  SizedBox(height: 12),
                  _MessageBubble(
                    text: 'Super merci ! J\'apporte mon micro ou vous avez tout ?',
                    isMe: true,
                    time: '10:35',
                  ),
                  SizedBox(height: 12),
                  _MessageBubble(
                    text: 'On a tout le matos nécessaire, viens les mains dans les poches 😎',
                    isMe: false,
                    time: '10:36',
                  ),
                  SizedBox(height: 12),
                  _MessageBubble(
                    text: 'Parfait, à demain alors !',
                    isMe: true,
                    time: '10:38',
                  ),
                ],
              ),
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.add, color: Colors.grey[600], size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Écrire un message...',
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DashboardMockScreen extends StatelessWidget {
  const _DashboardMockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _MockStatusBar(dark: false),
          const SizedBox(height: 8),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'SA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Studio Acoustik',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bonjour !',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined, size: 22),
                ),
              ],
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '12',
                    label: 'Sessions',
                    icon: Icons.calendar_today,
                    color: UseMeTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '3.2k€',
                    label: 'Revenus',
                    icon: Icons.euro,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '4.9',
                    label: 'Note',
                    icon: Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Today's sessions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Sessions du jour',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Voir tout',
                  style: TextStyle(
                    color: UseMeTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _DashboardSessionCard(
                  title: 'Session Recording',
                  time: '14:00',
                  artist: 'DJ Nova',
                  engineer: 'Alex Martin',
                ),
                SizedBox(height: 10),
                _DashboardSessionCard(
                  title: 'Mix & Master',
                  time: '18:00',
                  artist: 'The Waves',
                  engineer: 'Sophie Dubois',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMockScreen extends StatelessWidget {
  const _TeamMockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _MockStatusBar(dark: false),
          const SizedBox(height: 8),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Mon Équipe',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Inviter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Team members
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _TeamMemberCard(
                  name: 'Alex Martin',
                  role: 'Ingénieur son',
                  available: true,
                  sessions: 8,
                ),
                SizedBox(height: 12),
                _TeamMemberCard(
                  name: 'Sophie Dubois',
                  role: 'Ingénieur mix',
                  available: true,
                  sessions: 5,
                ),
                SizedBox(height: 12),
                _TeamMemberCard(
                  name: 'Lucas Bernard',
                  role: 'Producteur',
                  available: false,
                  sessions: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REUSABLE COMPONENTS
// ============================================================================

class _MockStatusBar extends StatelessWidget {
  final bool dark;
  const _MockStatusBar({this.dark = true});

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.black : Colors.black54;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: color,
            ),
          ),
          Row(
            children: [
              Icon(Icons.signal_cellular_4_bar, size: 16, color: color),
              const SizedBox(width: 4),
              Icon(Icons.wifi, size: 16, color: color),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, size: 16, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudioCard extends StatelessWidget {
  final String name;
  final double rating;
  final int reviews;
  final String distance;
  final List<String> tags;
  final bool isPartner;

  const _StudioCard({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.tags,
    required this.isPartner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.music_note, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPartner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PARTNER',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      ' $rating',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Flexible(
                      child: Text(
                        ' ($reviews) • $distance',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: UseMeTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: UseMeTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final String day;
  final bool selected;
  final bool available;

  const _CalendarDay(this.day, this.selected, this.available);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: selected
            ? UseMeTheme.primaryColor
            : available
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: selected
                ? Colors.white
                : available
                    ? Colors.green[700]
                    : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String time;
  final bool selected;
  final bool available;

  const _TimeSlot(this.time, this.selected, this.available);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? UseMeTheme.primaryColor
            : available
                ? Colors.white
                : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected
              ? UseMeTheme.primaryColor
              : available
                  ? Colors.grey[300]!
                  : Colors.grey[200]!,
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: selected
              ? Colors.white
              : available
                  ? Colors.black87
                  : Colors.grey[400],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String studio;
  final String service;
  final String date;
  final String time;
  final String status;
  final Color statusColor;

  const _SessionCard({
    required this.studio,
    required this.service,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                studio,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            service,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isMe
                ? LinearGradient(
                    colors: [UseMeTheme.primaryColor, UseMeTheme.secondaryColor],
                  )
                : null,
            color: isMe ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isMe ? Colors.white70 : Colors.grey[500],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DashboardSessionCard extends StatelessWidget {
  final String title;
  final String time;
  final String artist;
  final String engineer;

  const _DashboardSessionCard({
    required this.title,
    required this.time,
    required this.artist,
    required this.engineer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: UseMeTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.music_note, color: UseMeTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Text(
                  '$time • $artist',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                Text(
                  'avec $engineer',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final bool available;
  final int sessions;

  const _TeamMemberCard({
    required this.name,
    required this.role,
    required this.available,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      UseMeTheme.primaryColor.withValues(alpha: 0.2),
                      UseMeTheme.secondaryColor.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    name.split(' ').map((n) => n[0]).join(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: UseMeTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: available ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                Text(
                  role,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sessions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: UseMeTheme.primaryColor,
                ),
              ),
              Text(
                'sessions',
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
