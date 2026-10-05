import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/navigation_provider.dart';

class AdminHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const AdminHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final auth = context.watch<AuthProvider>();

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              nav.isSidebarCollapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
              color: AppTheme.textSecondary,
            ),
            onPressed: () => nav.toggleSidebar(),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Server status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'API CONNECTED',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (trailing != null) trailing!,
          const SizedBox(width: 12),
          // Admin Profile Avatar
          PopupMenuButton<String>(
            color: AppTheme.bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.border),
            ),
            offset: const Offset(0, 50),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user?.name ?? 'Admin',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      auth.user?.email ?? '',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined, size: 18, color: AppTheme.textSecondary),
                    SizedBox(width: 10),
                    Text('Settings', style: TextStyle(color: AppTheme.textPrimary)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, size: 18, color: AppTheme.error),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(color: AppTheme.error)),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'settings') {
                nav.setTab(AdminNavTab.settings);
              } else if (val == 'logout') {
                auth.logout();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primary.withOpacity(0.25),
                    child: Text(
                      auth.user?.name.isNotEmpty == true ? auth.user!.name[0].toUpperCase() : 'A',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    auth.user?.name.split(' ').first ?? 'Admin',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
