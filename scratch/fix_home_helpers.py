with open('lib/presentation/screens/home/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace LauncherHelper.launchUrlSafe with launchUrl
content = content.replace("LauncherHelper.launchUrlSafe('https://instagram.com/glowbaybd')", "launchUrl(Uri.parse('https://instagram.com/glowbaybd'), mode: LaunchMode.externalApplication)")

# Remove the incorrectly placed helper methods from the end
marker = "  Widget _buildMiniStepCard(String num, String title, String subtitle) {"
idx_marker = content.find(marker)
if idx_marker != -1:
    helpers_text = content[idx_marker:content.rfind("}")]
    content = content[:idx_marker] + "}\n"

# Now find where `class _TrustBadgePill` starts
target_pill = "class _TrustBadgePill extends StatelessWidget {"
idx_pill = content.find(target_pill)
if idx_pill != -1:
    # Find the closing brace of _HomeScreenState right before target_pill
    idx_brace = content.rfind("}", 0, idx_pill)
    if idx_brace != -1:
        content = content[:idx_brace] + "\n" + helpers_text + "\n" + content[idx_brace:]
        print("Successfully moved helpers inside _HomeScreenState")

with open('lib/presentation/screens/home/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Saved home_screen.dart with fixed placement")
