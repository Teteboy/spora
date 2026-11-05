# Route contract (go_router)

All screens navigate via `context.go()` for tab destinations and `context.push()` for stacked screens.
Current role: `context.read<AuthProvider>().selectedUserType` → `UserType.player | agent | recruiter` (recruiter = Club).

## Entry / auth
`/splash` `/welcome` `/role` `/register` `/login` `/forgot-password` `/email-sent` `/reset-password` `/password-updated` `/verify-email` `/email-confirmed` `/session-expired` `/account-suspended` `/protected-connection`

## Onboarding
`/onboarding/player` `/onboarding/agent` `/onboarding/club`

## Main shell tabs (context.go)
`/home` `/discover` `/highlights` `/opportunities` `/messages`

## Stacked screens (context.push)
`/search` `/filters` `/player/:id` `/agent-profile/:id` `/club/:id` `/my-list` `/video-player`
`/highlights/publish` `/highlights/mine`
`/opportunity/:id` `/opportunity/:id/apply` `/opportunities/publish` `/opportunities/mine` `/opportunity/:id/candidates` `/applications`
`/chat/:id` `/notifications` `/profile-views`
`/premium` `/premium/card` `/premium/momo` `/premium/3ds` `/premium/welcome` `/premium/subscription` `/premium/cancel`
`/settings` `/edit-profile` `/settings/notifications` `/settings/privacy` `/settings/security` `/help` `/report` `/delete-account` `/verification`
`/profile` (own profile tab content also reachable as push)

## Admin module (responsive, web-style)
`/admin` `/admin/login` `/admin/2fa` `/admin/dashboard` `/admin/moderation` `/admin/moderation/:id` `/admin/users` `/admin/users/:id` `/admin/verifications` `/admin/reports` `/admin/minors` `/admin/opportunities` `/admin/subscriptions` `/admin/finances` `/admin/audit` `/admin/super`
