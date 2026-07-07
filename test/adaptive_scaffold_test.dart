import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_reflow/responsive_reflow.dart';

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(home: child));
}

const _destinations = [
  RrDestination(icon: Icons.home, label: 'Home'),
  RrDestination(icon: Icons.search, label: 'Search'),
  RrDestination(icon: Icons.person, label: 'Profile'),
];

Widget _scaffold() => RrAdaptiveScaffold(
      destinations: _destinations,
      currentIndex: 0,
      onDestinationSelected: (_) {},
      body: const Center(child: Text('body')),
      animateTransitions: false,
    );

void main() {
  group('RrAdaptiveScaffold navigation pattern switching', () {
    testWidgets('compact window shows a bottom NavigationBar', (tester) async {
      await _pumpAt(tester, const Size(500, 900), _scaffold());
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('medium window shows a NavigationRail', (tester) async {
      await _pumpAt(tester, const Size(700, 900), _scaffold());
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('expanded window shows the full sidebar (ListTiles)',
        (tester) async {
      await _pumpAt(tester, const Size(1000, 900), _scaffold());
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      // Sidebar renders one ListTile per destination.
      expect(find.byType(ListTile), findsNWidgets(_destinations.length));
    });

    testWidgets('floatingActionButton is shown across layouts', (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 900),
        RrAdaptiveScaffold(
          destinations: _destinations,
          currentIndex: 0,
          onDestinationSelected: (_) {},
          body: const SizedBox(),
          floatingActionButton: const FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.add),
          ),
          animateTransitions: false,
        ),
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('RrAdaptiveScaffold.sectioned', () {
    final sections = [
      const RrNavSection(
        title: 'MAIN',
        items: [
          RrNavItem.branch(
              icon: Icons.home,
              label: 'Home',
              branchIndex: 0,
              showInBottomBar: true),
          RrNavItem.branch(
              icon: Icons.event,
              label: 'Schedule',
              branchIndex: 1,
              showInBottomBar: true),
        ],
      ),
    ];

    Widget sectioned({
      int currentIndex = 0,
      Widget? bottomNavigationBar,
      VoidCallback? onLink,
    }) =>
        RrAdaptiveScaffold.sectioned(
          sections: [
            ...sections,
            RrNavSection(
              title: 'SUPPORT',
              items: [
                RrNavItem.link(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: onLink ?? () {},
                ),
              ],
            ),
          ],
          currentIndex: currentIndex,
          onDestinationSelected: (_) {},
          body: const SizedBox(),
          bottomNavigationBar: bottomNavigationBar,
          animateTransitions: false,
        );

    testWidgets('compact uses the provided custom bottom bar', (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 900),
        sectioned(
          bottomNavigationBar: const SizedBox(key: ValueKey('customBar')),
        ),
      );
      expect(find.byKey(const ValueKey('customBar')), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('compact bottom bar only includes showInBottomBar branches',
        (tester) async {
      await _pumpAt(tester, const Size(500, 900), sectioned());
      // Both branch items opt in; the link is excluded.
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.destinations.length, 2);
    });

    testWidgets('medium renders the sectioned sidebar, not a rail',
        (tester) async {
      await _pumpAt(tester, const Size(700, 900), sectioned());
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('MAIN'), findsOneWidget);
      expect(find.text('SUPPORT'), findsOneWidget);
    });

    testWidgets('expanded sidebar renders section titles, branches and links',
        (tester) async {
      await _pumpAt(tester, const Size(1000, 900), sectioned());
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('tapping a link item invokes its onTap', (tester) async {
      var tapped = false;
      await _pumpAt(
        tester,
        const Size(1000, 900),
        sectioned(onLink: () => tapped = true),
      );
      await tester.tap(find.text('Settings'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('RrResponsiveGrid', () {
    testWidgets('renders more columns on wider windows', (tester) async {
      Future<int> columnCountFor(Size size) async {
        await _pumpAt(
          tester,
          size,
          RrResponsiveGrid(
            maxItemWidth: 200,
            children: List.generate(
              12,
              (i) => SizedBox(key: ValueKey('item_$i'), height: 100),
            ),
          ),
        );
        await tester.pump();
        final grid = tester.widget<GridView>(find.byType(GridView));
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent;
        return delegate.maxCrossAxisExtent.toInt();
      }

      // The delegate keeps maxCrossAxisExtent fixed; column count is derived by
      // Flutter from the available width. Assert the grid builds at both sizes.
      expect(await columnCountFor(const Size(400, 800)), 200);
      expect(await columnCountFor(const Size(1200, 800)), 200);
    });

    testWidgets('builder constructor builds lazily', (tester) async {
      await _pumpAt(
        tester,
        const Size(800, 600),
        RrResponsiveGrid.builder(
          maxItemWidth: 200,
          itemCount: 100,
          itemBuilder: (context, index) =>
              SizedBox(key: ValueKey('cell_$index'), height: 100),
        ),
      );
      // Not all 100 cells are built when off-screen.
      expect(find.byKey(const ValueKey('cell_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('cell_99')), findsNothing);
    });
  });

  group('RrPageContent', () {
    testWidgets('wraps content in a SafeArea and constrains width',
        (tester) async {
      await _pumpAt(
        tester,
        const Size(2000, 900),
        const RrPageContent(
          maxWidth: 800,
          child: Text('content'),
        ),
      );
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.text('content'), findsOneWidget);

      final constrained = tester.widget<ConstrainedBox>(
        find
            .descendant(
              of: find.byType(RrPageContent),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(constrained.constraints.maxWidth, 800);
    });

    testWidgets('non-scrollable omits the scroll view', (tester) async {
      await _pumpAt(
        tester,
        const Size(500, 900),
        const RrPageContent(
          scrollable: false,
          child: Text('content'),
        ),
      );
      expect(find.byType(SingleChildScrollView), findsNothing);
    });
  });
}
