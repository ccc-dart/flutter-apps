import 'package:flutter/material.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widgets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// 首頁：導覽各種元件分類
// ---------------------------------------------------------------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoEntry>[
      _DemoEntry('Buttons 按鈕', Icons.smart_button, const ButtonsDemo()),
      _DemoEntry('Text & Typography 文字', Icons.text_fields, const TextDemo()),
      _DemoEntry('Input 輸入元件', Icons.input, const InputDemo()),
      _DemoEntry('Layout 版面配置', Icons.dashboard, const LayoutDemo()),
      _DemoEntry('Card & List 卡片與列表', Icons.list_alt, const CardListDemo()),
      _DemoEntry('Navigation 導覽', Icons.menu_book, const NavigationDemo()),
      _DemoEntry(
          'Feedback 訊息回饋', Icons.notifications, const FeedbackDemo()),
      _DemoEntry('Progress 進度指示', Icons.hourglass_bottom,
          const ProgressDemo()),
      _DemoEntry('Animation 動畫', Icons.animation, const AnimationDemo()),
      _DemoEntry('Image & Icon 圖片圖示', Icons.image, const ImageIconDemo()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 視覺化元件展示')),
      body: ListView.separated(
        itemCount: demos.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final demo = demos[index];
          return ListTile(
            leading: Icon(demo.icon, color: Theme.of(context).colorScheme.primary),
            title: Text(demo.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => demo.page),
            ),
          );
        },
      ),
    );
  }
}

class _DemoEntry {
  final String title;
  final IconData icon;
  final Widget page;
  _DemoEntry(this.title, this.icon, this.page);
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------
class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buttons 按鈕')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('ElevatedButton'),
          ElevatedButton(onPressed: () {}, child: const Text('Elevated Button')),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('帶圖示'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: null, child: const Text('停用 (Disabled)')),
          const Divider(height: 40),

          const _SectionTitle('TextButton'),
          TextButton(onPressed: () {}, child: const Text('Text Button')),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
            label: const Text('帶圖示'),
          ),
          const Divider(height: 40),

          const _SectionTitle('OutlinedButton'),
          OutlinedButton(onPressed: () {}, child: const Text('Outlined Button')),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download),
            label: const Text('下載'),
          ),
          const Divider(height: 40),

          const _SectionTitle('IconButton'),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
          IconButton.filled(onPressed: () {}, icon: const Icon(Icons.star)),
          IconButton.filledTonal(
              onPressed: () {}, icon: const Icon(Icons.settings)),
          IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.share)),
          const Divider(height: 40),

          const _SectionTitle('FloatingActionButton'),
          Row(
            children: [
              FloatingActionButton.small(
                  onPressed: () {}, child: const Icon(Icons.add)),
              const SizedBox(width: 12),
              FloatingActionButton(
                  onPressed: () {}, child: const Icon(Icons.edit)),
              const SizedBox(width: 12),
              FloatingActionButton.large(
                  onPressed: () {}, child: const Icon(Icons.play_arrow)),
              const SizedBox(width: 12),
              FloatingActionButton.extended(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('新增'),
              ),
            ],
          ),
          const Divider(height: 40),

          const _SectionTitle('ButtonStyleButton（其他樣式）'),
          FilledButton(onPressed: () {}, child: const Text('Filled Button')),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: () {}, child: const Text('Filled Tonal')),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send),
            label: const Text('傳送'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Text & Typography
// ---------------------------------------------------------------------------
class TextDemo extends StatelessWidget {
  const TextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Text & Typography 文字')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Material TextTheme'),
          Text('displayLarge', style: textTheme.displayLarge),
          Text('displayMedium', style: textTheme.displayMedium),
          Text('headlineLarge', style: textTheme.headlineLarge),
          Text('headlineMedium', style: textTheme.headlineMedium),
          Text('titleLarge', style: textTheme.titleLarge),
          Text('titleMedium', style: textTheme.titleMedium),
          Text('bodyLarge', style: textTheme.bodyLarge),
          Text('bodyMedium（預設）', style: textTheme.bodyMedium),
          Text('bodySmall', style: textTheme.bodySmall),
          Text('labelLarge', style: textTheme.labelLarge),
          const Divider(height: 40),

          const _SectionTitle('基本屬性'),
          const Text('粗體', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('斜體', style: TextStyle(fontStyle: FontStyle.italic)),
          const Text('底線', style: TextStyle(decoration: TextDecoration.underline)),
          const Text('刪除線',
              style: TextStyle(decoration: TextDecoration.lineThrough)),
          const Text('紅色 18px',
              style: TextStyle(color: Colors.red, fontSize: 18)),
          const Text('字距放大',
              style: TextStyle(letterSpacing: 4, wordSpacing: 8)),
          const SizedBox(height: 8),
          const Text(
            '這是一段比較長的文字，用於展示 maxLines 與 ellipsis 效果。這是一段比較長的文字，用於展示 maxLines 與 ellipsis 效果。',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 40),

          const _SectionTitle('RichText 混合樣式'),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '你今天吃了 '),
                TextSpan(
                    text: '3',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
                TextSpan(text: ' 餐嗎？'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input
// ---------------------------------------------------------------------------
class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  bool _switchVal = true;
  bool _checkboxVal = false;
  String _radioVal = 'a';
  double _sliderVal = 30;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input 輸入元件')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('TextField 文字輸入'),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: '姓名',
              hintText: '請輸入姓名',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '密碼',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: Icon(Icons.visibility),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '備註',
              border: OutlineInputBorder(),
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('Switch 開關'),
          SwitchListTile(
            title: const Text('啟用通知'),
            value: _switchVal,
            onChanged: (v) => setState(() => _switchVal = v),
          ),
          const Divider(height: 24),

          const _SectionTitle('Checkbox 核取方塊'),
          CheckboxListTile(
            title: const Text('我同意條款'),
            value: _checkboxVal,
            onChanged: (v) => setState(() => _checkboxVal = v ?? false),
          ),
          const Divider(height: 24),

          const _SectionTitle('Radio 單選'),
          RadioGroup<String>(
            groupValue: _radioVal,
            onChanged: (v) => setState(() => _radioVal = v ?? 'a'),
            child: Column(
              children: [
                for (final val in ['a', 'b', 'c'])
                  RadioListTile<String>(
                    title: Text('選項 $val'),
                    value: val,
                  ),
              ],
            ),
          ),
          const Divider(height: 24),

          const _SectionTitle('Slider 滑桿'),
          Text('數值：${_sliderVal.round()}'),
          Slider(
            value: _sliderVal,
            min: 0,
            max: 100,
            divisions: 10,
            label: _sliderVal.round().toString(),
            onChanged: (v) => setState(() => _sliderVal = v),
          ),
          const Divider(height: 40),

          const _SectionTitle('Date / Time Picker 觸發'),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                    initialDate: DateTime.now(),
                  );
                  if (date != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('選擇了 $date')),
                    );
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('選擇日期'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('選擇了 $time')),
                    );
                  }
                },
                icon: const Icon(Icons.access_time),
                label: const Text('選擇時間'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Layout
// ---------------------------------------------------------------------------
class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box(Color color, String label) => Container(
          width: 60,
          height: 60,
          color: color,
          alignment: Alignment.center,
          child: Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Layout 版面配置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Row 水平排列'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [box(Colors.red, 'A'), box(Colors.green, 'B'), box(Colors.blue, 'C')],
          ),
          const Divider(height: 40),

          const _SectionTitle('Column 垂直排列'),
          Row(
            children: [
              const SizedBox(width: 100, child: Text('mainAxisAlignment\nspaceEvenly')),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    box(Colors.orange, '1'),
                    box(Colors.purple, '2'),
                    box(Colors.teal, '3'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 40),

          const _SectionTitle('Stack 疊層'),
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                box(Colors.blueGrey, '底層'),
                Positioned(top: 10, right: 10, child: box(Colors.red, '右上')),
                Positioned(bottom: 10, left: 10, child: box(Colors.green, '左下')),
                const Center(child: Icon(Icons.star, size: 40, color: Colors.yellow)),
              ],
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('Wrap 自動換行'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              12,
              (i) => Chip(
                label: Text('Chip $i'),
                avatar: Icon(Icons.tag, size: 16, color: Colors.teal.shade700),
              ),
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('Expanded / Flexible'),
          Row(
            children: [
              Expanded(flex: 2, child: box(Colors.redAccent, 'flex 2')),
              const SizedBox(width: 4),
              Expanded(flex: 1, child: box(Colors.blueAccent, 'flex 1')),
            ],
          ),
          const Divider(height: 40),

          const _SectionTitle('Padding / Align / Center'),
          Container(
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(12),
            child: const Align(
              alignment: Alignment.bottomRight,
              child: FlutterLogo(size: 48),
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('GridView 網格'),
          SizedBox(
            height: 220,
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(
                9,
                (i) => Container(
                  color: Colors.primaries[i % Colors.primaries.length].shade300,
                  alignment: Alignment.center,
                  child: Text('$i',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('Table 表格'),
          Table(
            border: TableBorder.all(color: Colors.grey),
            children: const [
              TableRow(children: [Text(' A '), Text(' B '), Text(' C ')]),
              TableRow(children: [Text(' 1 '), Text(' 2 '), Text(' 3 ')]),
              TableRow(children: [Text(' 4 '), Text(' 5 '), Text(' 6 ')]),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card & List
// ---------------------------------------------------------------------------
class CardListDemo extends StatelessWidget {
  const CardListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card & List 卡片與列表')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Card 卡片'),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('張三'),
              subtitle: const Text('軟體工程師'),
              trailing: IconButton(
                  icon: const Icon(Icons.more_vert), onPressed: () {}),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 6,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(' Elevated Card ',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('這是一張有陰影與主題色的卡片。'),
                ],
              ),
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('ListTile 列表項目'),
          Card(
            child: Column(
              children: const [
                ListTile(leading: Icon(Icons.wifi), title: Text('Wi‑Fi')),
                Divider(height: 1),
                ListTile(leading: Icon(Icons.bluetooth), title: Text('Bluetooth')),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.battery_full),
                  title: Text('電池'),
                  trailing: Switch(value: true, onChanged: null),
                ),
              ],
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('ExpansionTile 可展開列表'),
          Card(
            child: Column(
              children: [
                ExpansionTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('檔案 1'),
                  children: [
                    ListTile(title: const Text('子項目 A'), onTap: () {}),
                    ListTile(title: const Text('子項目 B'), onTap: () {}),
                  ],
                ),
                ExpansionTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text('檔案 2'),
                  children: [
                    ListTile(title: const Text('子項目 C'), onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('Dismissible 滑動刪除'),
          Card(
            child: Dismissible(
              key: const ValueKey('dismiss'),
              background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
              onDismissed: (_) {},
              child: const ListTile(
                leading: Icon(Icons.mail),
                title: Text('向左滑動刪除這則訊息'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation
// ---------------------------------------------------------------------------
class NavigationDemo extends StatelessWidget {
  const NavigationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation 導覽')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('底部 NavigationBar（獨立頁面）'),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _NavBarDemoPage())),
            child: const Text('開啟 NavigationBar Demo'),
          ),
          const Divider(height: 40),

          const _SectionTitle('Drawer 抽屜'),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _DrawerDemoPage())),
            child: const Text('開啟 Drawer Demo'),
          ),
          const Divider(height: 40),

          const _SectionTitle('BottomSheet 底部面板'),
          ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (ctx) => SizedBox(
                height: 220,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('這是 BottomSheet'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('關閉')),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('顯示 BottomSheet'),
          ),
          const Divider(height: 40),

          const _SectionTitle('TabBar 標籤頁（獨立頁面）'),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const _TabDemoPage())),
            child: const Text('開啟 TabBar Demo'),
          ),
        ],
      ),
    );
  }
}

class _NavBarDemoPage extends StatefulWidget {
  const _NavBarDemoPage();
  @override
  State<_NavBarDemoPage> createState() => _NavBarDemoPageState();
}

class _NavBarDemoPageState extends State<_NavBarDemoPage> {
  int _index = 0;
  static const _pages = [
    Center(child: Icon(Icons.home, size: 80)),
    Center(child: Icon(Icons.search, size: 80)),
    Center(child: Icon(Icons.person, size: 80)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NavigationBar')),
      body: Center(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: '首頁'),
          NavigationDestination(icon: Icon(Icons.search), label: '搜尋'),
          NavigationDestination(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

class _DrawerDemoPage extends StatelessWidget {
  const _DrawerDemoPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drawer 抽屜')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text('選單標題',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('首頁'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: const Center(child: Text('點擊左上角 ☰ 開啟抽屜')),
    );
  }
}

class _TabDemoPage extends StatelessWidget {
  const _TabDemoPage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('TabBar'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.photo), text: '圖片'),
              Tab(icon: Icon(Icons.videocam), text: '影片'),
              Tab(icon: Icon(Icons.audiotrack), text: '音樂'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Icon(Icons.photo, size: 80)),
            Center(child: Icon(Icons.videocam, size: 80)),
            Center(child: Icon(Icons.audiotrack, size: 80)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Feedback
// ---------------------------------------------------------------------------
class FeedbackDemo extends StatelessWidget {
  const FeedbackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback 訊息回饋')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('SnackBar'),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('這是一則 SnackBar 訊息')),
            ),
            child: const Text('顯示 SnackBar'),
          ),
          const Divider(height: 40),

          const _SectionTitle('AlertDialog'),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('確認'),
                content: const Text('你確定要刪除嗎？'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('確定')),
                ],
              ),
            ),
            child: const Text('顯示 AlertDialog'),
          ),
          const Divider(height: 40),

          const _SectionTitle('SimpleDialog'),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => SimpleDialog(
                title: const Text('選擇顏色'),
                children: ['紅', '綠', '藍']
                    .map((c) => SimpleDialogOption(
                          onPressed: () => Navigator.pop(ctx, c),
                          child: Text(c),
                        ))
                    .toList(),
              ),
            ),
            child: const Text('顯示 SimpleDialog'),
          ),
          const Divider(height: 40),

          const _SectionTitle('MaterialBanner'),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                content: const Text('這是一則 MaterialBanner'),
                actions: [
                  TextButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .hideCurrentMaterialBanner(),
                      child: const Text('關閉')),
                ],
              ),
            ),
            child: const Text('顯示 MaterialBanner'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------
class ProgressDemo extends StatefulWidget {
  const ProgressDemo({super.key});

  @override
  State<ProgressDemo> createState() => _ProgressDemoState();
}

class _ProgressDemoState extends State<ProgressDemo> {
  double _linear = 0.5;
  double _circular = 0.7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress 進度指示')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('CircularProgressIndicator'),
          Center(
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                CircularProgressIndicator(value: _circular, strokeWidth: 8),
                const SizedBox(height: 12),
                const CircularProgressIndicator.adaptive(),
              ],
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('LinearProgressIndicator'),
          LinearProgressIndicator(value: _linear),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
          const Divider(height: 40),

          const _SectionTitle('控制進度'),
          Text('圓形進度：${(_circular * 100).round()}%'),
          Slider(
            value: _circular,
            onChanged: (v) => setState(() => _circular = v),
          ),
          Text('線性進度：${(_linear * 100).round()}%'),
          Slider(
            value: _linear,
            onChanged: (v) => setState(() => _linear = v),
          ),
          const Divider(height: 40),

          const _SectionTitle('LinearBotomStepper（步驟指示）'),
          const LinearProgressIndicator(value: 2 / 3, minHeight: 6),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('步驟 1'), Text('步驟 2'), Text('步驟 3')],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animation
// ---------------------------------------------------------------------------
class AnimationDemo extends StatefulWidget {
  const AnimationDemo({super.key});

  @override
  State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> {
  bool _big = false;
  double _opacity = 1.0;
  double _rotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation 動畫')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('AnimatedContainer'),
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _big = !_big),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: _big ? 200 : 100,
                height: _big ? 200 : 100,
                decoration: BoxDecoration(
                  color: _big ? Colors.pink : Colors.teal,
                  borderRadius: BorderRadius.circular(_big ? 24 : 8),
                  boxShadow: _big
                      ? [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 4)]
                      : [],
                ),
                alignment: Alignment.center,
                child: const Text('點我', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const Divider(height: 40),

          const _SectionTitle('AnimatedOpacity'),
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 500),
              child: const FlutterLogo(size: 100),
            ),
          ),
          Slider(
            value: _opacity,
            onChanged: (v) => setState(() => _opacity = v),
          ),
          const Divider(height: 40),

          const _SectionTitle('AnimatedRotation'),
          Center(
            child: IconButton(
              iconSize: 60,
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  setState(() => _rotation += 0.5 * 3.14159 * 2),
            ),
          ),
          AnimatedRotation(
            turns: _rotation,
            duration: const Duration(milliseconds: 600),
            child: const Icon(Icons.arrow_upward, size: 48),
          ),
          const Divider(height: 40),

          const _SectionTitle('AnimatedSwitcher'),
          Center(
            child: _AnimatedSwitcherDemo(),
          ),
          const Divider(height: 40),

          const _SectionTitle('Hero 過場動畫（點擊前往下一頁）'),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _HeroDetailPage()),
            ),
            child: const Hero(
              tag: 'logo',
              child: FlutterLogo(size: 80),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSwitcherDemo extends StatefulWidget {
  @override
  State<_AnimatedSwitcherDemo> createState() => _AnimatedSwitcherDemoState();
}

class _AnimatedSwitcherDemoState extends State<_AnimatedSwitcherDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Text(
            '$_count',
            key: ValueKey(_count),
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: const Text('+1（切換數字時有縮放動畫）'),
        ),
      ],
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hero Detail')),
      body: const Center(
        child: Hero(tag: 'logo', child: FlutterLogo(size: 200)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image & Icon
// ---------------------------------------------------------------------------
class ImageIconDemo extends StatelessWidget {
  const ImageIconDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image & Icon 圖片圖示')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Icon 內建圖示'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              Icon(Icons.home, size: 36),
              Icon(Icons.favorite, size: 36, color: Colors.red),
              Icon(Icons.star, size: 36, color: Colors.amber),
              Icon(Icons.settings, size: 36),
              Icon(Icons.camera_alt, size: 36),
              Icon(Icons.music_note, size: 36),
              Icon(Icons.email, size: 36),
              Icon(Icons.phone, size: 36),
              Icon(Icons.location_on, size: 36, color: Colors.green),
              Icon(Icons.notifications, size: 36, color: Colors.orange),
            ],
          ),
          const Divider(height: 40),

          const _SectionTitle('Icon 置於背景'),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
              CircleAvatar(radius: 28, backgroundColor: Colors.red, child: Icon(Icons.favorite, color: Colors.white)),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.star, color: Colors.white),
              ),
            ],
          ),
          const Divider(height: 40),

          const _SectionTitle('FlutterLogo'),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlutterLogo(size: 60),
              FlutterLogo(size: 60, style: FlutterLogoStyle.horizontal),
              FlutterLogo(size: 60, style: FlutterLogoStyle.markOnly),
            ],
          ),
          const Divider(height: 40),

          const _SectionTitle('CircleAvatar'),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(child: Text('甲')),
              CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text('乙', style: TextStyle(color: Colors.white)),
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.teal,
                child: Icon(Icons.pets, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 共用小工具
// ---------------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
