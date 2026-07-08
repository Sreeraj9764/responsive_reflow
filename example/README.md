# responsive_reflow examples

Three runnable apps that share the same pages ([lib/shared/](lib/shared/)) but
wire them up differently — proof that reflow layouts are router-agnostic.

| Entrypoint | Run | Demonstrates |
| --- | --- | --- |
| [lib/main.dart](lib/main.dart) | `flutter run` | **Basics, no router packages.** `ReflowAdaptiveScaffold.sectioned` (bottom bar → rail → sidebar), adaptive inbox (push on compact, `secondaryBody` pane on expanded+), dashboard grid with per-breakpoint `columns`, settings form with `ConstrainedContent` + keyboard insets, `context.reflow`, spacing tokens, `ReflowPointerModeDetector`. |
| [lib/go_router_app/main.dart](lib/go_router_app/main.dart) | `flutter run -t lib/go_router_app/main.dart` | **go_router.** `StatefulShellRoute.indexedStack` inside the adaptive scaffold, `goBranch` retap-reset, and a deep-linkable inbox: `/inbox/3` renders a full detail screen on compact windows and a secondary pane on expanded+ — same URL, different layout. |
| [lib/auto_route_app/main.dart](lib/auto_route_app/main.dart) | `flutter run -t lib/auto_route_app/main.dart` | **auto_route.** `AutoTabsRouter` mapped to the scaffold's `currentIndex`/`onDestinationSelected`, plus a self-contained adaptive inbox screen. |

The auto_route app needs code generation once:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## What to try

Run on desktop or web and resize the window through all breakpoints:

- Navigation reflows bottom bar → rail → sidebar; the selected tab (and each
  tab's stack, in the router apps) survives every transition.
- In the inbox, select a conversation on a wide window (pane), then shrink the
  window — in the go_router app the same `/inbox/:id` URL becomes a pushed
  detail screen.
- The dashboard grid recomputes columns per breakpoint; the info card inside
  it adapts to its *parent* constraints, not the window.
- Focus a settings text field on mobile — the Save FAB hides while the
  keyboard is up (inset-driven, not device-driven).
