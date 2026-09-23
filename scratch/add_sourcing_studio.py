with open('lib/presentation/screens/home/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

sourcing_studio_code = """
              // Mobile Web Section 16: Mid Sourcing Studio Showcase Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF7A00).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFF7A00).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, color: Color(0xFFFF7A00), size: 12),
                              SizedBox(width: 4),
                              Text('100% AUTHENTIC SOURCING', style: TextStyle(color: Color(0xFFFF7A00), fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Direct Air Cargo From Malaysia Hub',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '100% genuine skincare and beauty products dispatched directly from Kuala Lumpur to Dhaka.',
                          style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, height: 1.35),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  showSearch(context: context, delegate: SmartSearchDelegate());
                                },
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search, color: Colors.white, size: 15),
                                      SizedBox(width: 6),
                                      Text('Search by Name', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualSearchScreen(initialSource: ImageSource.camera)));
                                },
                                child: Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF2A6D), Color(0xFFFF7A00)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt_outlined, color: Colors.white, size: 15),
                                      SizedBox(width: 6),
                                      Text('Search by Photo', style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
"""

target = """              // 8.5. Recently Viewed Section (If any products viewed)"""

if target in content:
    content = content.replace(target, sourcing_studio_code + "\n" + target, 1)
    with open('lib/presentation/screens/home/home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Successfully added Mid Sourcing Studio Card")
else:
    print("Target not found")
