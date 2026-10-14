import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const _pageBg = Color(0xFF080D18);
const _pagePanel = Color(0xFF111B2D);
const _pageBlue = Color(0xFF3984FF);
const _pagePurple = Color(0xFF895BFF);

class RepositoryDetailsPage extends StatefulWidget {
  const RepositoryDetailsPage({super.key, required this.repository});
  final Map<String, dynamic> repository;

  @override
  State<RepositoryDetailsPage> createState() => _RepositoryDetailsPageState();
}

class _RepositoryDetailsPageState extends State<RepositoryDetailsPage> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> commits = [];
  List<Map<String, dynamic>> entries = [];
  String currentPath = '';

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<List<Map<String, dynamic>>> _list(String path, [Map<String, String>? query]) async {
    final response = await http.get(
      Uri.https('api.github.com', path, query),
      headers: const {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'NEXUS-X-Android',
      },
    ).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception('المستودع غير موجود أو لا يمكن عرضه علنًا.');
      }
      if (response.statusCode == 403 || response.statusCode == 429) {
        throw Exception('قيّد GitHub الطلبات مؤقتًا؛ حاول لاحقًا.');
      }
      throw Exception('تعذر الاتصال بـ GitHub (HTTP ${response.statusCode}).');
    }
    final value = jsonDecode(response.body);
    if (value is! List) throw Exception('استجابة GitHub غير متوقعة.');
    return value.whereType<Map<String, dynamic>>().toList();
  }

  Future<void> refresh() async {
    setState(() { loading = true; error = null; });
    final name = widget.repository['full_name']?.toString() ?? '';
    if (!RegExp(r'^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$').hasMatch(name)) {
      setState(() { loading = false; error = 'اسم المستودع غير صالح.'; });
      return;
    }
    try {
      final result = await Future.wait([
        _list('/repos/$name/branches', {'per_page': '20'}),
        _list('/repos/$name/commits', {'per_page': '10'}),
        _list('/repos/$name/contents${currentPath.isEmpty ? '' : '/$currentPath'}'),
      ]);
      if (!mounted) return;
      setState(() {
        branches = result[0];
        commits = result[1];
        entries = result[2];
      });
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadDirectory(String path) async {
    final name = widget.repository['full_name']?.toString() ?? '';
    setState(() { loading = true; error = null; });
    try {
      final nextEntries = await _list('/repos/$name/contents${path.isEmpty ? '' : '/$path'}');
      if (!mounted) return;
      setState(() { currentPath = path; entries = nextEntries; });
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _open(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.scheme == 'https') {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.repository['full_name']?.toString() ?? 'GitHub';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(title: const Text('تفاصيل المستودع')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(name, textDirection: TextDirection.ltr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.repository['description']?.toString() ?? 'لا يوجد وصف.',
              style: const TextStyle(color: Colors.white60, height: 1.5)),
            const SizedBox(height: 8),
            Text('الفرع الافتراضي: ${widget.repository['default_branch']?.toString() ?? '—'}'),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                onPressed: () => _open(widget.repository['html_url']?.toString() ?? ''),
                icon: const Icon(Icons.open_in_new),
                label: const Text('فتح المستودع'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final cloneUrl = widget.repository['clone_url']?.toString() ?? '';
                  if (cloneUrl.isEmpty) return;
                  await Clipboard.setData(ClipboardData(text: cloneUrl));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رابط Git للمستودع.')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('نسخ رابط Git'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('https://github.com/$name/issues'),
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('المشكلات'),
              ),
              OutlinedButton.icon(
                onPressed: () => _open('https://github.com/$name/pulls'),
                icon: const Icon(Icons.merge_type),
                label: const Text('طلبات الدمج'),
              ),
            ]),
            if (loading) const Center(child: Padding(
              padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            if (error != null) _message(error!, true),
            if (!loading && error == null) ...[
              _heading('الفروع', branches.length),
              if (branches.isEmpty) _muted('لا توجد فروع ظاهرة.'),
              ...branches.map((branch) => Card(
                color: _pagePanel,
                child: ListTile(
                  leading: const Icon(Icons.account_tree, color: _pageBlue),
                  title: Text(branch['name']?.toString() ?? 'فرع'),
                  trailing: const Icon(Icons.open_in_new, size: 17),
                  onTap: () => _open('https://github.com/$name/tree/${Uri.encodeComponent(branch['name']?.toString() ?? '')}'),
                ),
              )),
              _heading('آخر الالتزامات', commits.length),
              if (commits.isEmpty) _muted('لا توجد التزامات ظاهرة.'),
              ...commits.map((item) {
                final detail = item['commit'] is Map ? item['commit'] as Map : const {};
                final sha = item['sha']?.toString() ?? '';
                final message = detail['message']?.toString().split('\n').first ?? 'Commit';
                return Card(
                  color: _pagePanel,
                  child: ListTile(
                    leading: const Icon(Icons.commit, color: _pagePurple),
                    title: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(sha.length > 7 ? sha.substring(0, 7) : sha),
                    onTap: () => _open('https://github.com/$name/commit/$sha'),
                  ),
                );
              }),
              _heading(currentPath.isEmpty ? 'ملفات ومجلدات الجذر' : currentPath, entries.length),
              if (currentPath.isNotEmpty) Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _loadDirectory(currentPath.contains('/') ? currentPath.substring(0, currentPath.lastIndexOf('/')) : ''),
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('المجلد السابق'),
                ),
              ),
              if (entries.isEmpty) _muted('لا توجد ملفات ظاهرة.'),
              ...entries.map((entry) => ListTile(
                dense: true,
                leading: Icon(entry['type'] == 'dir' ? Icons.folder : Icons.insert_drive_file,
                  color: entry['type'] == 'dir' ? _pageBlue : Colors.white54),
                title: Text(entry['name']?.toString() ?? 'عنصر', textDirection: TextDirection.ltr),
                trailing: Icon(entry['type'] == 'dir' ? Icons.chevron_left : Icons.open_in_new, size: 16),
                onTap: () {
                  final entryName = entry['name']?.toString() ?? '';
                  if (entry['type'] == 'dir' && entryName.isNotEmpty) {
                    _loadDirectory(currentPath.isEmpty ? entryName : '$currentPath/$entryName');
                  } else {
                    _open(entry['html_url']?.toString() ?? '');
                  }
                },
              )),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: loading ? null : refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث التفاصيل'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String title, int count) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Text('$title ($count)',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _muted(String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(value, style: const TextStyle(color: Colors.white54)),
  );

  Widget _message(String value, bool isError) => Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _pagePanel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: (isError ? Colors.redAccent : _pageBlue).withValues(alpha: .4)),
    ),
    child: Text(value, style: TextStyle(color: isError ? Colors.redAccent : _pageBlue)),
  );
}
