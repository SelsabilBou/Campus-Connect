// admin_panal.dart (sans bouton Open : les tabs ouvrent directement les écrans)
import 'package:flutter/material.dart';
import 'student_management.dart';
import 'teacher_management.dart';
import 'file_upload.dart';
import 'schedule_calender.dart';
import 'auth_service.dart';
import 'admin_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});//constructeur de classe

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  int selectedTab = 0; // 0 Students, 1 Teachers, 2 Files

  @override
  void initState() {
    super.initState();//appelle la version parent de initState
    _guardAdmin();//pour verifier esq rahou admin wla non
  }

  Future<void> _guardAdmin() async {
    final logged = await AuthService.isLoggedIn();// login
    final role = await AuthService.getUserRole();//recuperer le role

    if (!mounted) return;//ki tkoun la page m'affichya ykeml lkhedma normall sinon y7bes

    if (!logged || role != 'Admin') {
      ScaffoldMessenger.of(context).showSnackBar(//affichage d'un message en bas de l'ecran
        const SnackBar(content: Text("Accès refusé")),
      );
      Navigator.pushReplacementNamed(context, '/login');//y3ewd yweli login psq raho mahouch admin
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyChild;
    if (selectedTab == 0) {
      bodyChild = const StudentManagement();
    } else if (selectedTab == 1) {
      bodyChild = const TeacherManagement();
    } else {
      bodyChild = const _FilesTab();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(// degradation de couleur
            begin: Alignment.topLeft,// ybda la degradation mn top left
            end: Alignment.bottomRight,// win yhbs
            colors: [Color(0xFFBFA8FF), Color(0xFF6D28D9)],
          ),
        ),
        child: SafeArea(//ajout automatiquement de padding
          child: Column(
            children: [
              // logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,//hez child lakher
                  children: [
                    TextButton.icon(//bouton de type texte avec icon
                      onPressed: () async {
                        await AuthService.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/welcome',
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Admin',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 40),
              Expanded(//prend tout l'espace vertical
                child: Container
                  (
                  width: double.infinity,//container y7kem tout la largeure disponible
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      _TabsPill(// widget qui designe la barre d'onglet
                        selectedIndex: selectedTab,
                        onChanged: (i) => setState(() => selectedTab = i),
                      ),
                      const SizedBox(height: 16),
                      // on montre directement l'écran correspondant au tab
                      Expanded(child: bodyChild),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabsPill extends StatelessWidget {//declarer un widget stateless pour la barre d'onglet
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TabsPill({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabItem(
              label: 'Students',
              icon: Icons.person,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Teachers',
              icon: Icons.school,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
          Expanded(
            child: _TabItem(
              label: 'Files',
              icon: Icons.folder,
              selected: selectedIndex == 2,
              onTap: () => onChanged(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(//pour avoir un effet de click
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF6D28D9) : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.40),
              blurRadius: 18,
              offset: const Offset(0, 8),
            )
          ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? const Color(0xFF6D28D9) : Colors.black54),//ida selectionne icon violet else icon gris
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilesTab extends StatefulWidget {
  const _FilesTab();

  @override
  State<_FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<_FilesTab> {
  final service = AdminService.instance;//initialiser liste de fichiers vide

  List<Map<String, dynamic>> files = [];
  bool loading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {//charge les fichiers
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      files = await service.fetchFiles(); // lit la table files
    } catch (e) {
      errorMsg = "Erreur lors du chargement des fichiers";
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (loading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: LinearProgressIndicator(minHeight: 3),//affiche une barre de progression lineaire de 3 pixel
          ),
        if (errorMsg != null) ...[
          Text(errorMsg!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadFiles, child: const Text("Retry")),
          const SizedBox(height: 8),
        ],//erreur 'Retry'
        Expanded(
          child: files.isEmpty
              ? const Center(child: Text("No files"))
              : GridView.builder(//gallary view
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,//2 colonnes
              mainAxisSpacing: 12,//espace vertical de 12 pixels
              crossAxisSpacing: 12,//espace horizontal
              childAspectRatio: 1.7,
            ),
            itemCount: files.length,//nombre d'elements=nombre de fichiers
            itemBuilder: (context, index) {
              final f = files[index];//recuperer le fiichier a l'index
              final name = (f['name'] ?? '').toString();//extrait le nom (vide si null)
              final tag = (f['tag'] ?? '').toString();//extrait le tag (vide si null)
              return _FileCard(name: name, tag: tag);//retourne une carte de fichier
            },
          ),
        ),
        const SizedBox(height: 10),
        InkWell(//widget avec effet de clic
          borderRadius: BorderRadius.circular(28),
          onTap: () async {
            await Navigator.push(//navigue vers une nouvelle page et attend le retour
              context,
              MaterialPageRoute(builder: (context) => const FileUploadPage()),// route vers la page d'upload
            );
            await _loadFiles(); // refresh après upload
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF6D28D9),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text(
                'Upload',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScheduleCalendarPage()),
            );
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text(
                'Calendar',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Files + Calendar', style: TextStyle(color: Colors.black45)),
      ],
    );
  }
}

class _FileCard extends StatelessWidget {
  final String name;
  final String tag;

  const _FileCard({required this.name, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(//contenu de file card
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6D28D9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          const Spacer(),//spacer qui pousse le contenu sivant vers le bas,
          const Icon(Icons.insert_drive_file, color: Colors.black45),//icone de fichier grise
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,//maximum 1 ligne
            overflow: TextOverflow.ellipsis,//ajoute des point de suspension si trop long
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
