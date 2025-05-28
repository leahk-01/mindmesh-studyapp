import 'package:exam_project/screens/add_friends_screen.dart';
import 'package:exam_project/screens/chat_hub_screen.dart';
import 'package:exam_project/screens/create_group_screen.dart';
import 'package:exam_project/screens/note_view_screen.dart';
import 'package:exam_project/screens/notebook_screen.dart';
import 'package:exam_project/screens/notes_in_folder_screen.dart';
import 'package:exam_project/screens/shared_note_viewer.dart';
import 'package:exam_project/screens/shared_notes_screen.dart';
import 'package:go_router/go_router.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/subject_selection.dart';
import 'screens/dashboard.dart';
import 'screens/subject_detail.dart';
import 'screens/note_editor.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),
    GoRoute(path: '/subjects', builder: (_, __) => SubjectSelectionScreen()),
    GoRoute(path: '/add-friends', builder: (_, __) =>const AddFriendsScreen()),
    GoRoute(path: '/chat-hub', builder: (_, __) =>  ChatHubScreen(),),
    GoRoute(path: '/dashboard', builder: (_, __) => DashboardScreen()),
    GoRoute(path: '/folderscreen', builder:(_, __)=>NotebookScreen()),
    GoRoute(path: '/subject/:id', builder: (_, state) => SubjectDetailScreen(subjectId: state.pathParameters['id']!)),
    GoRoute(path: '/note', builder: (_, __) => NoteEditorScreen()),
    GoRoute(path: '/create-group', builder: (_, __) => const CreateGroupScreen(),),
    GoRoute(path: '/note/new', builder: (context, state) => NoteEditorScreen(folderId: state.extra as String),),
    GoRoute(path: '/note/:id', builder: (context, state) => NoteEditorScreen(noteId: state.pathParameters['id']),),
    GoRoute(
      path: '/shared',
      builder: (context, state) => const SharedNotesScreen(),
    ),
    GoRoute(
      path: '/shared-note/:id',
      builder: (context, state) =>
          SharedNoteViewerScreen(noteId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/folder/:id',
      builder: (context, state) {
        final folderId = state.pathParameters['id']!;
        return NotesInFolderScreen(folderId: folderId);
      },
    ),

    GoRoute(
      path: '/note/edit/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return NoteEditorScreen(noteId: noteId);
      },
    ),
    GoRoute(
      path: '/note/view/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return NoteViewScreen(noteId: noteId);
      },
    ),







  ],
);
