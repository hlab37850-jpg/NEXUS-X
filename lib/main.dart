import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'repository_details_page.dart';

void main() => runApp(const NexusXApp());
const bg = Color(0xFF080D18);
const panel = Color(0xFF111B2D);
const blue = Color(0xFF3984FF);
const purple = Color(0xFF895BFF);

class NexusXApp extends StatelessWidget {
  const NexusXApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NEXUS X', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: blue, brightness: Brightness.dark)),
    home: const NexusHome());
}

class NexusHome extends StatefulWidget {
  const NexusHome({super.key});
  @override
  State<NexusHome> createState() => _NexusHomeState();
}
class _NexusHomeState extends State<NexusHome> {
  int selected = 0;
  final labels = const ['الرئيسية','المشاريع','الذكاء الاصطناعي','البناء السحابي','الإعدادات'];
  final icons = const [Icons.dashboard_rounded,Icons.folder_copy_rounded,Icons.auto_awesome_rounded,Icons.cloud_queue_rounded,Icons.settings_rounded];
  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl,
    child: Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(18), child: Row(children: [
        Container(width: 44,height: 44,decoration: BoxDecoration(gradient: const LinearGradient(colors:[blue,purple]),borderRadius: BorderRadius.circular(14)),child: const Icon(Icons.hub_rounded)),
        const SizedBox(width: 12),const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [Text('NEXUS X',style: TextStyle(fontWeight: FontWeight.bold)),Text('SMART DEVELOPMENT',style: TextStyle(fontSize: 9,color: Colors.white54,letterSpacing: 1.2))])),
      ])),
      Expanded(child: selected == 1 ? const ProjectsPage()
        : selected == 3 ? const CloudBuildPage()
        : selected == 2 ? const AiWorkspacePage()
        : selected == 4 ? const SettingsPage()
        : _home()),
      Container(
        color: const Color(0xFF0D1422),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: List.generate(labels.length, (i) => Expanded(
            child: InkWell(
              onTap: () => setState(() => selected = i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icons[i], color: selected == i ? blue : Colors.white54, size: 21),
                  const SizedBox(height: 4),
                  Text(labels[i], maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 9, color: selected == i ? blue : Colors.white54)),
                ]),
              ),
            ),
          )),
        ),
      ),
    ]))),
  );
  Widget _home()=>ListView(padding:const EdgeInsets.all(18),children:[
    Container(padding:const EdgeInsets.all(23),decoration:BoxDecoration(
      borderRadius:BorderRadius.circular(24),border:Border.all(color:Colors.white10),
      gradient:const LinearGradient(colors:[Color(0xFF182C50),Color(0xFF17162F),Color(0xFF101827)])),
      child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Icon(Icons.bolt,color:Color(0xFF83B4FF),size:30),SizedBox(height:12),
        Text('حوّل فكرتك إلى تطبيق',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),
        SizedBox(height:8),Text('إدارة المستودعات ومتابعة البناء السحابي من مكان واحد.',style:TextStyle(color:Colors.white70,height:1.5))
      ])),
    const SizedBox(height:22),_homeTile(Icons.folder_open,'مستودعات GitHub','عرض المستودعات العامة الفعلية',()=>setState(()=>selected=1)),
    _homeTile(Icons.cloud_done,'حالة البناء السحابي','قراءة آخر تشغيل من GitHub Actions',()=>setState(()=>selected=3)),
    _homeTile(Icons.auto_awesome,'الذكاء الاصطناعي','التكامل لم يُفعّل بعد',()=>setState(()=>selected=2)),
    const Text('لا يتم عرض بيانات تجريبية على أنها بيانات حقيقية.',style:TextStyle(color:Colors.white38,fontSize:12))
  ]);
  Widget _homeTile(IconData icon,String title,String sub,VoidCallback tap)=>Card(color:panel,child:ListTile(
    leading:Icon(icon,color:blue),title:Text(title),subtitle:Text(sub),trailing:const Icon(Icons.chevron_left),onTap:tap));
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});
  @override
  State<ProjectsPage> createState()=>_ProjectsPageState();
}
class _ProjectsPageState extends State<ProjectsPage>{
  final user=TextEditingController(text:'hlab37850-jpg');
  final filter=TextEditingController();
  List<Map<String,dynamic>> repos=[]; bool loading=false; bool searched=false; String? error;
  String sortBy='آخر تحديث';
  @override void dispose(){user.dispose();filter.dispose();super.dispose();}
  List<Map<String,dynamic>> get visibleRepos {
    final q=filter.text.trim().toLowerCase();
    final result=repos.where((r) {
      if(q.isEmpty)return true;
      final name=r['name']?.toString().toLowerCase()??'';
      final desc=r['description']?.toString().toLowerCase()??'';
      final language=r['language']?.toString().toLowerCase()??'';
      return name.contains(q)||desc.contains(q)||language.contains(q);
    }).toList();
    if(sortBy=='الأكثر نجومًا') result.sort((a,b)=>(b['stargazers_count'] as num? ?? 0).compareTo(a['stargazers_count'] as num? ?? 0));
    if(sortBy=='الاسم أبجديًا') result.sort((a,b)=>(a['name']?.toString()??'').toLowerCase().compareTo((b['name']?.toString()??'').toLowerCase()));
    return result;
  }
  Future<void> load() async {
    final name=user.text.trim();
    if(name.isEmpty){setState(()=>error='أدخل اسم مستخدم GitHub.');return;}
    setState(() { loading = true; error = null; searched = true; });
    try{
      final uri=Uri.https('api.github.com','/users/$name/repos',{'sort':'updated','per_page':'30','type':'owner'});
      final res=await http.get(uri,headers:const {'Accept':'application/vnd.github+json','User-Agent':'NEXUS-X-Android'}).timeout(const Duration(seconds:20));
      if(res.statusCode!=200) throw Exception(githubError(res));
      final data=jsonDecode(res.body);
      if(data is! List) throw Exception('استجابة GitHub غير متوقعة.');
      if(!mounted)return;
      setState(()=>repos=data.whereType<Map<String,dynamic>>().toList());
    } catch (e) { if (mounted) setState(() { repos = []; error = friendly(e); }); }
    finally{if(mounted)setState(()=>loading=false);}
  }
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[
    const Text('مستودعات GitHub',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('بيانات عامة مباشرة من GitHub. المستودعات الخاصة تتطلب مصادقة آمنة غير مفعّلة بعد.',style:TextStyle(color:Colors.white60,height:1.5)),
    const SizedBox(height:16),TextField(controller:user,textDirection:TextDirection.ltr,decoration:field('اسم مستخدم GitHub',Icons.person),onSubmitted:(_)=>load()),
    const SizedBox(height:10),FilledButton.icon(onPressed:loading?null:load,icon:loading?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.sync),label:Text(loading?'جارٍ الاتصال...':'جلب المستودعات')),
    const SizedBox(height:14),
    TextField(controller:filter,decoration:field('بحث بالاسم أو الوصف أو اللغة',Icons.search).copyWith(suffixIcon:filter.text.isEmpty?null:IconButton(icon:const Icon(Icons.clear),onPressed:()=>setState(()=>filter.clear()))),onChanged:(_)=>setState((){})),
    const SizedBox(height:10),
    DropdownButtonFormField<String>(initialValue:sortBy,decoration:field('ترتيب النتائج',Icons.sort),items:const [DropdownMenuItem(value:'آخر تحديث',child:Text('آخر تحديث')),DropdownMenuItem(value:'الأكثر نجومًا',child:Text('الأكثر نجومًا')),DropdownMenuItem(value:'الاسم أبجديًا',child:Text('الاسم أبجديًا'))],onChanged:(v)=>setState(()=>sortBy=v??'آخر تحديث')),
    if(error!=null) msg(error!,true),
    if(searched&&!loading&&error==null&&repos.isEmpty) const Padding(padding:EdgeInsets.all(20),child:Text('لا توجد مستودعات عامة ظاهرة لهذا المستخدم.',textAlign:TextAlign.center)),
    if(repos.isNotEmpty&&visibleRepos.isEmpty) const Padding(padding:EdgeInsets.all(20),child:Text('لا توجد نتائج تطابق البحث.',textAlign:TextAlign.center)),
    ...visibleRepos.map((r){
      final repoName=r['name']?.toString()??'مستودع';
      final desc=r['description']?.toString();
      final details = '${desc == null || desc.isEmpty ? 'لا يوجد وصف' : desc}\n${r['language']?.toString() ?? 'لغة غير محددة'} • ★ ${r['stargazers_count']?.toString() ?? '0'}';
      return Card(color:panel,child:ListTile(leading:const Icon(Icons.code,color:blue),title:Text(repoName),subtitle:Text(details,maxLines:3,overflow:TextOverflow.ellipsis),onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>RepositoryDetailsPage(repository:r))),trailing:const Icon(Icons.chevron_left)));
    })
  ]);
}

class CloudBuildPage extends StatefulWidget {
  const CloudBuildPage({super.key});
  @override State<CloudBuildPage> createState()=>_CloudBuildPageState();
}
class _CloudBuildPageState extends State<CloudBuildPage>{
  final owner=TextEditingController(text:'hlab37850-jpg');
  final repo=TextEditingController(text:'NEXUS-X');
  Map<String,dynamic>? run; List<Map<String,dynamic>> recentRuns=[]; List<Map<String,dynamic>> jobs=[]; bool jobsLoading=false; String? jobsError; bool loading=false;bool checked=false;String? error;
  @override void dispose(){owner.dispose();repo.dispose();super.dispose();}
  Future<void> load()async{
    if(owner.text.trim().isEmpty||repo.text.trim().isEmpty){setState(()=>error='أدخل المالك واسم المستودع.');return;}
    setState(() { loading = true; checked = true; error = null; run = null; recentRuns = []; jobs = []; jobsError = null; jobsLoading = false; });
    try{
      final uri=Uri.https('api.github.com','/repos/${owner.text.trim()}/${repo.text.trim()}/actions/runs',{'per_page':'10'});
      final res=await http.get(uri,headers:const {'Accept':'application/vnd.github+json','User-Agent':'NEXUS-X-Android'}).timeout(const Duration(seconds:20));
      if(res.statusCode!=200)throw Exception(githubError(res));
      final data=jsonDecode(res.body);
      if(data is! Map<String,dynamic>)throw Exception('استجابة GitHub غير متوقعة.');
      final runs=data['workflow_runs'];
      final list = runs is List ? runs.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList() : <Map<String, dynamic>>[];
      if(mounted)setState(() { run = list.isNotEmpty ? list.first : null; recentRuns = list.length > 1 ? list.skip(1).toList() : []; });
      if(list.isNotEmpty && list.first['id'] != null) await loadJobDetails(list.first['id']);
    }catch(e){if(mounted)setState(()=>error=friendly(e));}
    finally{if(mounted)setState(()=>loading=false);}
  }
  Future<void> loadJobDetails(Object runId) async {
    if(!mounted)return;
    setState(() { jobsLoading=true; jobsError=null; jobs=[]; });
    try {
      final uri=Uri.https('api.github.com','/repos/${owner.text.trim()}/${repo.text.trim()}/actions/runs/$runId/jobs',{'per_page':'50'});
      final res=await http.get(uri,headers:const {'Accept':'application/vnd.github+json','User-Agent':'NEXUS-X-Android'}).timeout(const Duration(seconds:20));
      if(res.statusCode!=200)throw Exception(githubError(res));
      final data=jsonDecode(res.body);
      if(data is! Map<String,dynamic>)throw Exception('استجابة تفاصيل البناء غير متوقعة.');
      final raw=data['jobs'];
      if(mounted)setState(()=>jobs=raw is List?raw.whereType<Map>().map((item)=>Map<String,dynamic>.from(item)).toList():<Map<String,dynamic>>[]);
    } catch(e) { if(mounted)setState(()=>jobsError=friendly(e)); }
    finally { if(mounted)setState(()=>jobsLoading=false); }
  }
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(18),children:[
    const Text('البناء السحابي',style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
    const SizedBox(height:8),const Text('قراءة مباشرة لآخر تشغيل GitHub Actions، دون سجل وهمي أو تخزين لرموز الدخول.',style:TextStyle(color:Colors.white60,height:1.5)),
    const SizedBox(height:16),TextField(controller:owner,textDirection:TextDirection.ltr,decoration:field('مالك المستودع',Icons.person)),
    const SizedBox(height:10),TextField(controller:repo,textDirection:TextDirection.ltr,decoration:field('اسم المستودع',Icons.folder)),
    const SizedBox(height:10),FilledButton.icon(onPressed:loading?null:load,icon:loading?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.cloud_sync),label:Text(loading?'جارٍ الفحص...':'فحص آخر بناء')),
    if(error!=null)msg(error!,true),
    if(checked&&!loading&&error==null&&run==null)msg('لا توجد تشغيلات بناء مسجلة لهذا المستودع.'),
    if(run!=null)_runCard(run!),
    if(jobsLoading) const Padding(padding:EdgeInsets.all(18),child:Center(child:CircularProgressIndicator())),
    if(jobsError!=null) msg('تعذر تحميل خطوات البناء: $jobsError',true),
    if(jobs.isNotEmpty) ...[
      const SizedBox(height:14),
      const Text('تفاصيل الوظائف والخطوات',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      ...jobs.map(_jobCard),
    ],
    if(recentRuns.isNotEmpty) ...[
      const SizedBox(height:18),
      const Text('سجل عمليات البناء السابقة',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
      const SizedBox(height:8),
      ...recentRuns.map(_historyCard),
    ],
    const SizedBox(height:12),
    OutlinedButton.icon(onPressed:()=>openExternal('https://github.com/${owner.text.trim()}/${repo.text.trim()}/actions/workflows/build.yml'),icon:const Icon(Icons.open_in_browser),label:const Text('فتح GitHub لتشغيل بناء جديد')),
    const Text('سجّل الدخول في GitHub ثم اختر Run workflow. لا تدخل رمز وصول في التطبيق؛ يلزم امتلاك المستودع أو صلاحية Actions.',style:TextStyle(color:Colors.white38,fontSize:12,height:1.5))
  ]);
  Widget _runCard(Map<String,dynamic> r){
    final status=r['status']?.toString()??'unknown';final conclusion=r['conclusion']?.toString();
    final head = r['head_commit'] is Map ? Map<String, dynamic>.from(r['head_commit'] as Map) : <String, dynamic>{};
    final commitMessage = head['message']?.toString().split('\n').first ?? '';
    final sha = r['head_sha']?.toString() ?? '';
    final created = DateTime.tryParse(r['created_at']?.toString() ?? '');
    final createdLabel = created == null ? '—' : created.toLocal().toString().split('.').first;
    final color=status=='completed'?(conclusion=='success'?const Color(0xFF27C9A5):const Color(0xFFFF647C)):blue;
    final result=status!='completed'?(status=='in_progress'?'قيد التنفيذ':status=='queued'?'في الانتظار':status):conclusionText(conclusion);
    return Card(color:panel,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Icon(status=='completed'&&conclusion=='success'?Icons.check_circle:status=='completed'?Icons.error:Icons.pending,color:color),const SizedBox(width:8),Expanded(child:Text(r['name']?.toString()??'GitHub Actions',style:const TextStyle(fontWeight:FontWeight.bold)))]),
      const SizedBox(height:12),_row('النتيجة',result,color),_row('رقم التشغيل', '#${r['run_number']?.toString() ?? '—'}', Colors.white70),
      _row('الفرع',r['head_branch']?.toString()??'—',Colors.white70),_row('الحدث',r['event']?.toString()??'—',Colors.white70),
      _row('الالتزام',sha.isEmpty?'—':sha.substring(0,sha.length>7?7:sha.length),Colors.white70),
      _row('وقت التشغيل',createdLabel,Colors.white70),
      if(commitMessage.isNotEmpty) Padding(padding:const EdgeInsets.only(top:4,bottom:10),child:Text('رسالة الالتزام: $commitMessage',style:const TextStyle(color:Colors.white60,height:1.4))),
      if((r['html_url']?.toString()??'').isNotEmpty)OutlinedButton.icon(onPressed:()=>openExternal(r['html_url'].toString()),icon:const Icon(Icons.open_in_new),label:const Text('عرض سجل GitHub'))
    ])));
  }
  Widget _jobCard(Map<String,dynamic> job) {
    final status=job['status']?.toString()??'unknown';
    final conclusion=job['conclusion']?.toString();
    final success=status=='completed'&&conclusion=='success';
    final color=success?const Color(0xFF27C9A5):status=='completed'?const Color(0xFFFF647C):blue;
    final label=status!='completed'?(status=='in_progress'?'قيد التنفيذ':status=='queued'?'في الانتظار':status):conclusionText(conclusion);
    final steps=job['steps'] is List?(job['steps'] as List).whereType<Map>().toList():<Map>[];
    return Card(color:panel,child:ExpansionTile(
      leading:Icon(success?Icons.check_circle:status=='completed'?Icons.error_outline:Icons.pending,color:color),
      title:Text(job['name']?.toString()??'وظيفة بناء'),
      subtitle:Text('$label • ${steps.length} خطوة'),
      children:steps.map((raw) {
        final step=Map<String,dynamic>.from(raw);
        final stepStatus=step['status']?.toString()??'unknown';
        final stepConclusion=step['conclusion']?.toString();
        final stepSuccess=stepStatus=='completed'&&stepConclusion=='success';
        final stepColor=stepSuccess?const Color(0xFF27C9A5):stepStatus=='completed'?const Color(0xFFFF647C):blue;
        final stepLabel=stepStatus!='completed'?(stepStatus=='in_progress'?'قيد التنفيذ':stepStatus=='queued'?'في الانتظار':stepStatus):conclusionText(stepConclusion);
        return ListTile(dense:true,leading:Icon(stepSuccess?Icons.check_circle_outline:stepStatus=='completed'?Icons.cancel_outlined:Icons.more_time,color:stepColor,size:20),title:Text(step['name']?.toString()??'خطوة'),subtitle:Text(stepLabel),trailing:step['number'] is num?Text('#${step['number']}'):null);
      }).toList(),
    ));
  }
  Widget _historyCard(Map<String,dynamic> item) {
    final status = item['status']?.toString() ?? 'unknown';
    final conclusion = item['conclusion']?.toString();
    final success = status == 'completed' && conclusion == 'success';
    final color = success ? const Color(0xFF27C9A5) : status == 'completed' ? const Color(0xFFFF647C) : blue;
    final label = status != 'completed' ? (status == 'in_progress' ? 'قيد التنفيذ' : status == 'queued' ? 'في الانتظار' : status) : conclusionText(conclusion);
    final sha = item['head_sha']?.toString() ?? '';
    return Card(color:panel,child:ListTile(
      leading: Icon(success ? Icons.check_circle : status == 'completed' ? Icons.error_outline : Icons.pending, color:color),
      title: Text('${item['name']?.toString() ?? 'GitHub Actions'} • #${item['run_number']?.toString() ?? '—'}'),
      subtitle: Text('$label${sha.isNotEmpty ? ' • ${sha.substring(0, sha.length > 7 ? 7 : sha.length)}' : ''}${item['created_at'] != null ? ' • ${item['created_at'].toString().replaceFirst('T', ' ').replaceFirst('Z', '')}' : ''}'),
      trailing: const Icon(Icons.open_in_new,size:18),
      onTap: () => openExternal(item['html_url']?.toString() ?? ''),
    ));
  }
  Widget _row(String label,String value,Color color)=>Padding(padding:const EdgeInsets.only(bottom:8),child:Row(children:[SizedBox(width:90,child:Text(label,style:const TextStyle(color:Colors.white54))),Expanded(child:Text(value,style:TextStyle(color:color)))]));
}


class AiWorkspacePage extends StatefulWidget {
  const AiWorkspacePage({super.key});
  @override
  State<AiWorkspacePage> createState() => _AiWorkspacePageState();
}

class _AiWorkspacePageState extends State<AiWorkspacePage> {
  final goal = TextEditingController();
  final constraints = TextEditingController(
    text: 'حافظ على التصميم الحالي، لا تحذف الميزات الموجودة، لا تضف بيانات تجريبية، واختبر التغييرات قبل اعتمادها.',
  );
  String task = 'إصلاح أخطاء البناء';
  bool generated = false;
  final tasks = const [
    'إصلاح أخطاء البناء',
    'إضافة ميزة جديدة',
    'مراجعة مشروع Flutter',
    'تحليل واجهة من صورة',
    'إصلاح مشكلة تسجيل الدخول',
    'اختبارات وضمان الجودة',
  ];

  @override
  void dispose() {
    goal.dispose();
    constraints.dispose();
    super.dispose();
  }

  String get prompt => '''
أنت مهندس برمجيات خبير تعمل على مشروع قائم، وليس مشروعًا جديدًا.
المهمة: \${task}
وصف المطلوب:
\${goal.text.trim()}
شروط إلزامية:
\${constraints.text.trim()}

طريقة التنفيذ:
1. افحص ملفات المشروع وسجل الأخطاء قبل التعديل.
2. حدد السبب الجذري بدقة، ولا تخمّن ولا تخفِ الأخطاء.
3. نفّذ التغيير بأقل نطاق ممكن مع الحفاظ على البنية والتصميم والميزات الحالية.
4. لا تستخدم بيانات وهمية أو مفاتيح API أو رموز وصول سرية داخل التطبيق.
5. أضف أو حدّث الاختبارات المناسبة.
6. شغّل flutter pub get ثم flutter analyze ثم flutter test ثم flutter build apk --debug.
7. لا تعلن النجاح إلا بعد نجاح كل خطوة، واذكر الملفات التي تغيرت ونتائج الأوامر الفعلية.
8. إذا تعذّر تنفيذ خطوة، اذكر السبب بوضوح ولا تدّعِ اكتمال المهمة.
'''.trim();

  Future<void> copyPrompt() async {
    await Clipboard.setData(ClipboardData(text: prompt));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ التعليمات. الصقها في نموذج الذكاء الاصطناعي الذي تستخدمه.')),
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text('مساحة الذكاء الاصطناعي',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text(
        'أنشئ تعليمات دقيقة لمهمة التطوير وانسخها إلى مزود الذكاء الاصطناعي الذي تختاره. هذه الصفحة لا تدّعي الاتصال بنموذج خارجي.',
        style: TextStyle(color: Colors.white60, height: 1.5)),
      const SizedBox(height: 18),
      DropdownButtonFormField<String>(
        initialValue: task,
        isExpanded: true,
        decoration: field('نوع المهمة', Icons.auto_awesome),
        items: tasks.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: (value) => setState(() { if (value != null) task = value; generated = false; }),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: goal,
        minLines: 3,
        maxLines: 6,
        decoration: field('اشرح المطلوب بالتفصيل', Icons.edit_note).copyWith(
          hintText: 'مثال: أصلح سبب فشل البناء دون تغيير تصميم الشاشات.',
          alignLabelWithHint: true,
        ),
        onChanged: (_) => setState(() => generated = false),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: constraints,
        minLines: 3,
        maxLines: 6,
        decoration: field('القيود التي يجب احترامها', Icons.rule).copyWith(alignLabelWithHint: true),
        onChanged: (_) { if (generated) setState(() => generated = false); },
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: goal.text.trim().isEmpty ? null : () => setState(() => generated = true),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('إنشاء التعليمات'),
      ),
      if (generated) ...[
        const SizedBox(height: 18),
        const Text('التعليمات الجاهزة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(14)),
          child: SelectableText(prompt, style: const TextStyle(height: 1.5)),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: copyPrompt, icon: const Icon(Icons.copy), label: const Text('نسخ التعليمات')),
      ],
    ],
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(18),
    children: [
      const Text('الإعدادات والمعلومات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('روابط المشروع والخصوصية وحدود التكاملات الحالية.',
        style: TextStyle(color: Colors.white60, height: 1.5)),
      const SizedBox(height: 16),
      Card(color: panel, child: const ListTile(
        leading: Icon(Icons.hub, color: blue),
        title: Text('NEXUS X'),
        subtitle: Text('الإصدار 1.0.0 • تطبيق Flutter عربي RTL'),
      )),
      Card(color: panel, child: const ListTile(
        leading: Icon(Icons.shield_outlined, color: blue),
        title: Text('الخصوصية والأمان'),
        subtitle: Text('لا يخزّن التطبيق رمز GitHub شخصيًا ولا يرسل بيانات إلى نموذج ذكاء اصطناعي. استعلامات المستودعات العامة تُرسل إلى واجهة GitHub API.'),
        isThreeLine: true,
      )),
      Card(color: panel, child: ListTile(
        leading: const Icon(Icons.code, color: blue),
        title: const Text('مستودع التطبيق'),
        subtitle: const Text('hlab37850-jpg/NEXUS-X'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => openExternal('https://github.com/hlab37850-jpg/NEXUS-X'),
      )),
      Card(color: panel, child: ListTile(
        leading: const Icon(Icons.cloud_done, color: blue),
        title: const Text('عمليات البناء السحابي'),
        subtitle: const Text('عرض السجل وإدارة تشغيلات GitHub Actions'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => openExternal('https://github.com/hlab37850-jpg/NEXUS-X/actions'),
      )),
      Card(color: panel, child: ListTile(
        leading: const Icon(Icons.bug_report_outlined, color: blue),
        title: const Text('الإبلاغ عن مشكلة'),
        subtitle: const Text('فتح صفحة المشكلات في GitHub'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => openExternal('https://github.com/hlab37850-jpg/NEXUS-X/issues/new'),
      )),
      msg('المستودعات الخاصة وتشغيل البناء من داخل التطبيق يحتاجان إلى مصادقة آمنة وصلاحيات GitHub. لا تضع رمز وصول شخصيًا داخل التطبيق.'),
    ],
  );
}

class EmptyPage extends StatelessWidget{
  const EmptyPage({required this.icon,required this.title,required this.message,super.key});
  final IconData icon;final String title;final String message;
  @override Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(24),child:Card(color:panel,child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
    Icon(icon,color:blue,size:42),const SizedBox(height:14),Text(title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.bold)),const SizedBox(height:10),Text(message,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white60,height:1.6))
  ])))));
}
InputDecoration field(String label,IconData icon)=>InputDecoration(labelText:label,prefixIcon:Icon(icon),filled:true,fillColor:panel,border:OutlineInputBorder(borderRadius:BorderRadius.circular(15)));
Widget msg(String text,[bool isError=false])=>Padding(padding:const EdgeInsets.only(top:12),child:Container(width:double.infinity,padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(14),border:Border.all(color:(isError?const Color(0xFFFF647C):blue).withValues(alpha:.4))),child:Text(text,style:TextStyle(color:isError?const Color(0xFFFF647C):blue))));
String githubError(http.Response r){if(r.statusCode==404)return 'المستخدم أو المستودع غير موجود، أو أنه خاص.';if(r.statusCode==403||r.statusCode==429)return 'قيّد GitHub الطلبات مؤقتًا؛ حاول لاحقًا.';return 'تعذر الاتصال بـ GitHub (HTTP ${r.statusCode}).';}
String friendly(Object e)=>e.toString().replaceFirst('Exception: ','');
String conclusionText(String? c)=>switch(c){'success'=>'نجاح','failure'=>'فشل','cancelled'=>'أُلغي','timed_out'=>'انتهت المهلة','action_required'=>'يتطلب إجراء','skipped'=>'تم تجاوزه',_=>c??'اكتمل دون نتيجة محددة'};
Future<void> openExternal(String value)async{final uri=Uri.tryParse(value);if(uri!=null&&uri.hasScheme)await launchUrl(uri,mode:LaunchMode.externalApplication);}
