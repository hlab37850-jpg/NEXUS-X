import 'package:flutter/material.dart';

void main() {
  runApp(const NexusXApp());
}

const Color background = Color(0xFF080D18);
const Color panel = Color(0xFF111B2D);
const Color blue = Color(0xFF3984FF);
const Color purple = Color(0xFF895BFF);

class NexusXApp extends StatelessWidget {
  const NexusXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEXUS X',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: blue,
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const NexusHome(),
    );
  }
}

class NexusHome extends StatefulWidget {
  const NexusHome({super.key});

  @override
  State<NexusHome> createState() => _NexusHomeState();
}

class _NexusHomeState extends State<NexusHome> {
  int selected = 0;

  final pages = const [
    'الرئيسية',
    'المشاريع',
    'الذكاء الاصطناعي',
    'البناء السحابي',
    'الإعدادات',
  ];

  final descriptions = const [
    'مركز التحكم في بيئة التطوير',
    'إدارة مشاريعك ومستودعاتك',
    'مساحة تحليل الأفكار والكود',
    'متابعة بناء تطبيقات Android',
    'إعدادات الاتصال والتفضيلات',
  ];

  final icons = const [
    Icons.dashboard_rounded,
    Icons.folder_copy_rounded,
    Icons.auto_awesome_rounded,
    Icons.cloud_queue_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hero(),
                      const SizedBox(height: 25),
                      Text(
                        pages[selected],
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        descriptions[selected],
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 18),
                      if (selected == 0) ...[
                        _feature(
                          Icons.folder_open_rounded,
                          'المشاريع',
                          'اربط مستودع GitHub لعرض المشاريع الفعلية.',
                          blue,
                          () => setState(() => selected = 1),
                        ),
                        _feature(
                          Icons.auto_awesome,
                          'الذكاء الاصطناعي',
                          'جهّز اتصال مزود الذكاء الاصطناعي لبدء التحليل.',
                          purple,
                          () => setState(() => selected = 2),
                        ),
                        _feature(
                          Icons.cloud_done_rounded,
                          'البناء السحابي',
                          'شغّل GitHub Actions بعد رفع ملفات المشروع.',
                          const Color(0xFF27C9A5),
                          () => setState(() => selected = 3),
                        ),
                      ] else
                        _emptyState(),
                      const SizedBox(height: 20),
                      const Text(
                        'NEXUS X  •  بيئة تطويرك',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _navigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                colors: [blue, purple],
              ),
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEXUS X',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'SMART DEVELOPMENT',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => selected = 4),
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF182C50),
            Color(0xFF17162F),
            Color(0xFF101827),
          ],
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFF83B4FF), size: 30),
          const SizedBox(height: 13),
          const Text(
            'حوّل فكرتك إلى تطبيق',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 9),
          const Text(
            'إدارة الكود والمستودعات وتشغيل البناء السحابي من مساحة واحدة.',
            style: TextStyle(color: Colors.white70, height: 1.6),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => setState(() => selected = 2),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('ابدأ الآن'),
          ),
        ],
      ),
    );
  }

  Widget _feature(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: panel,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19),
        side: const BorderSide(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(13),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.white60, height: 1.5),
          ),
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icons[selected], size: 43, color: blue),
          const SizedBox(height: 14),
          Text(
            selected == 1
                ? 'لم يتم ربط مستودع بعد'
                : selected == 2
                    ? 'لم يتم إعداد مزود الذكاء الاصطناعي'
                    : selected == 3
                        ? 'لا توجد نتائج بناء مسجلة'
                        : 'إعدادات NEXUS X',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            selected == 4
                ? 'ستضاف إعدادات الاتصال والأمان في المرحلة التالية.'
                : 'هذه مساحة فارغة بانتظار ربط الخدمة الفعلية. لا توجد بيانات تجريبية.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, height: 1.6),
          ),
          if (selected == 3) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.info_outline),
              label: const Text('حالة البناء غير متصلة بعد'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _navigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1422),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(pages.length, (index) {
          final active = selected == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => selected = index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icons[index],
                      size: 21,
                      color: active ? blue : Colors.white54,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      pages[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: active ? blue : Colors.white54,
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
