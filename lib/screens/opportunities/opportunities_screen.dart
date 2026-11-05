import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_provider.dart';
import 'opportunities_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 12 · Recrutement — Opportunités (/opportunities)
class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  OpportunityType? _filter; // null = Toutes
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _isPublisher {
    final t = context.read<AuthProvider>().selectedUserType;
    return t == UserType.agent || t == UserType.recruiter;
  }

  List<Opportunity> get _public =>
      OpportunitiesMock.opportunities.where((o) {
        final isMockState = o.id.endsWith('-applied') || o.id.endsWith('-expired');
        return !isMockState && o.status != OpportunityStatus.draft;
      }).toList();

  List<Opportunity> get _filtered => _public.where((o) {
        if (_filter != null && o.type != _filter) return false;
        if (_query.isNotEmpty) {
          final q = _query.toLowerCase();
          return o.title.toLowerCase().contains(q) ||
              o.publisherName.toLowerCase().contains(q) ||
              o.city.toLowerCase().contains(q);
        }
        return true;
      }).toList();

  /// Suggestions "Pour vous" basées sur le profil joueur (ATT, 19 ans).
  List<Opportunity> get _forYou => _public.where((o) {
        final posMatch =
            o.positions.isEmpty || o.positions.contains(OpportunitiesMock.myPosition);
        final ageMatch = o.ageMin == null ||
            (OpportunitiesMock.myAge >= o.ageMin! &&
                OpportunitiesMock.myAge <= (o.ageMax ?? 99));
        return posMatch && ageMatch && o.status == OpportunityStatus.open;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final featured =
        _public.where((o) => o.featured).cast<Opportunity?>().firstOrNull;
    final list = _filtered.where((o) => !o.featured).toList();

    return Scaffold(
      backgroundColor: AppColors.appBg,
      floatingActionButton: _isPublisher
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/opportunities/publish'),
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: Colors.white),
              label: Text('Publier',
                  style: AppTextStyles.button()),
            )
          : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenMargin, 12, AppDimens.screenMargin, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppDimens.lg),
                    _buildHero(),
                    const SizedBox(height: AppDimens.lg),
                    _buildSearch(),
                    const SizedBox(height: AppDimens.md),
                    _buildChips(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenMargin),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppDimens.sm),
                  if (featured != null && _filter == null && _query.isEmpty)
                    _FeaturedCard(opportunity: featured),
                  if (featured != null && _filter == null && _query.isEmpty)
                    const SizedBox(height: AppDimens.sm),
                  Text('Offre d’exemple · Académie fictive',
                      style: AppTextStyles.caption()),
                  const SizedBox(height: AppDimens.section),
                  if (_forYou.isNotEmpty) ...[
                    Text('Pour vous', style: AppTextStyles.h2()),
                    const SizedBox(height: AppDimens.md),
                    ..._forYou.take(2).map((o) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimens.md),
                          child: _OpportunityCard(opportunity: o),
                        )),
                    const SizedBox(height: AppDimens.sm),
                  ],
                  Text('Toutes les opportunités', style: AppTextStyles.h2()),
                  const SizedBox(height: AppDimens.md),
                  if (list.isEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppDimens.xxl),
                      child: Center(
                        child: Text('Aucune opportunité trouvée',
                            style: AppTextStyles.body()),
                      ),
                    )
                  else
                    ...list.map((o) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppDimens.md),
                          child: _OpportunityCard(opportunity: o),
                        )),
                  const SizedBox(height: AppDimens.huge),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(child: Text('Opportunités', style: AppTextStyles.display())),
        GestureDetector(
          onTap: () => context.push('/messages'),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.messageCircle,
                size: 22, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAF3EE), AppColors.primaryTint],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('La prochaine opportunité est\npeut-être ici.',
              style: AppTextStyles.h1()),
          const SizedBox(height: AppDimens.sm),
          Text('Des projets concrets pour votre avenir.',
              style: AppTextStyles.body()),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _query = v.trim()),
      style: AppTextStyles.body(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Un poste, un club, une ville…',
        hintStyle: AppTextStyles.body(color: AppColors.textHint),
        prefixIcon:
            const Icon(LucideIcons.search, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildChips() {
    final chips = <(String, OpportunityType?)>[
      ('Toutes', null),
      for (final t in OpportunityType.values) (t.label, t),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.sm),
        itemBuilder: (context, i) {
          final (label, type) = chips[i];
          final selected = _filter == type;
          final color = type?.color ?? AppColors.primary;
          return GestureDetector(
            onTap: () => setState(() => _filter = type),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.10)
                    : AppColors.surface,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusPill),
                border: Border.all(
                  color: selected ? color : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: AppTextStyles.bodyStrong(
                    color:
                        selected ? color : AppColors.textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

/// Grande carte "À la une" (image + détails + CTA Postuler).
class _FeaturedCard extends StatelessWidget {
  final Opportunity opportunity;
  const _FeaturedCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusHero),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.elev1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusHero)),
            child: Stack(
              children: [
                _netImage(o.imageUrl ?? '',
                    height: 150, width: double.infinity),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      OppChip(
                          label: o.type.label,
                          color: o.type.color,
                          textColor: o.type.color),
                      const SizedBox(width: AppDimens.sm),
                      const _SolidChip(
                          label: 'À la une',
                          color: AppColors.navy800),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PublisherAvatar(o: o, size: 40),
                    const SizedBox(width: AppDimens.sm),
                    Text(o.publisherName, style: AppTextStyles.bodyStrong()),
                    const SizedBox(width: AppDimens.xs),
                    if (o.publisherVerified)
                      const Icon(LucideIcons.badgeCheck,
                          color: AppColors.primary, size: 18),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),
                Text(o.title, style: AppTextStyles.h1()),
                const SizedBox(height: AppDimens.sm),
                Row(
                  children: [
                    const Icon(LucideIcons.mapPin,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: AppDimens.xs),
                    Expanded(
                      child: Text(
                        '${o.city} · ${OppFmt.range(o.startDate, o.endDate)}',
                        style: AppTextStyles.body(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),
                Wrap(
                  spacing: AppDimens.sm,
                  runSpacing: AppDimens.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (o.ageRange.isNotEmpty)
                      OppChip(
                          label: o.ageRange,
                          color: AppColors.green,
                          textColor: AppColors.clubGreen),
                    if (o.positionsLabel.isNotEmpty)
                      OppChip(
                          label: o.positionsLabel,
                          color: AppColors.primary),
                    Text('${o.places} places',
                        style: AppTextStyles.caption()),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),
                Text('Clôture le ${OppFmt.date(o.deadline)}',
                    style: AppTextStyles.body()),
                const SizedBox(height: AppDimens.md),
                OppGradientButton(
                  label: 'Postuler',
                  onPressed: () =>
                      context.push('/opportunity/${o.id}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte opportunité compacte de la liste.
class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final o = opportunity;
    final closed = o.status == OpportunityStatus.closed;
    return OppCard(
      onTap: () => context.push('/opportunity/${o.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PublisherAvatar(o: o, size: 28),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Text(o.publisherName,
                    style: AppTextStyles.caption(
                        color: AppColors.textSecondary)),
              ),
              if (o.publisherVerified)
                const Icon(LucideIcons.badgeCheck,
                    color: AppColors.primary, size: 16),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Row(
            children: [
              OppChip(
                  label: o.type.label,
                  color: o.type.color,
                  textColor: o.type.color),
              const Spacer(),
              if (closed)
                Text(o.status.label, style: AppTextStyles.caption()),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(o.title, style: AppTextStyles.h3()),
          const SizedBox(height: AppDimens.sm),
          Row(
            children: [
              const Icon(LucideIcons.mapPin,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: AppDimens.xs),
              Expanded(
                child: Text('${o.location} · ${o.places} places',
                    style: AppTextStyles.caption(
                        color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.xs),
          Row(
            children: [
              const Icon(LucideIcons.calendar,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: AppDimens.xs),
              Text('Clôture le ${OppFmt.date(o.deadline)}',
                  style: AppTextStyles.caption(
                      color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          OppGradientButton(
            label: 'Postuler',
            onPressed: () => context.push('/opportunity/${o.id}'),
          ),
        ],
      ),
    );
  }
}

/// Pastille pleine (ex. « À la une » navy à texte blanc).
class _SolidChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SolidChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption(color: Colors.white)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Image réseau : bloc gris pendant le chargement,
/// placeholder navy foncé en cas d'erreur.
Widget _netImage(String url, {double? width, double? height}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : Container(
            width: width, height: height, color: AppColors.muted),
    errorBuilder: (context, error, stack) => Container(
      width: width,
      height: height,
      color: AppColors.navy800,
      alignment: Alignment.center,
      child: const Icon(LucideIcons.imageOff,
          color: AppColors.darkTextMuted, size: 28),
    ),
  );
}

class _PublisherAvatar extends StatelessWidget {
  final Opportunity o;
  final double size;
  const _PublisherAvatar({required this.o, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.shield,
              size: size * 0.42, color: AppColors.clubGreen),
          Text(o.publisherInitials,
              style: AppTextStyles.micro(color: AppColors.clubGreen)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: size * 0.18)),
        ],
      ),
    );
  }
}
