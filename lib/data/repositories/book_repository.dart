import '../../domain/models/book_graph.dart';
import '../../domain/models/story_page.dart';
import '../../domain/models/choice.dart';

/// Repository interface for accessing book data
abstract class BookRepository {
  Future<BookGraph> getBook(String bookId);
  Future<StoryPage?> getPage(String bookId, String pageId);
}

/// Mock implementation with hardcoded story data
class MockBookRepository implements BookRepository {
  // Simulating network delay
  static const _delay = Duration(milliseconds: 300);

  @override
  Future<BookGraph> getBook(String bookId) async {
    await Future.delayed(_delay);
    return _createMockBook();
  }

  @override
  Future<StoryPage?> getPage(String bookId, String pageId) async {
    await Future.delayed(_delay);
    final book = _createMockBook();
    return book.getPage(pageId);
  }

  /// Creates the mock book with 10 pages
  /// Page 3 demonstrates branching to pages 4, 5, 6
  BookGraph _createMockBook() {
    return BookGraph(
      id: 'book_001',
      title: 'Die interaktive Geschichte',
      author: 'AppStories Team',
      startPageId: 'page_1',
      pages: {
        'page_1': const StoryPage(
          id: 'page_1',
          title: 'Kapitel Eins: Der Ruf der Unzeit',
          content: '''Der Wind kam aus keiner Richtung. Er strich durch die Kronen der Bäume, ohne Blätter zu bewegen, und flüsterte Namen, die niemand je laut ausgesprochen hatte. In dieser Stunde, wenn der Himmel zwischen Blau und Nacht zögerte, begann die Insel zu lauschen.

Lio stand auf der Klippe und zählte die Atemzüge des Meeres. Eins für die Wellen, die sich erinnerten. Eins für die Sterne, die sich verirrten. Unter ihm funkelte die Lagune wie ein zerbrochener Spiegel, und irgendwo darin lachte etwas, das älter war als Zeit und jünger als ein Versprechen. Lio grinste. Er liebte diese Stunde, weil sie ihm gehörte.

Er sprang.

Nicht hinab, sondern fort. Die Luft fing ihn auf wie eine vertraute Hand, und für einen Herzschlag schien es, als trüge der Wind ihn weiter, nur um zu sehen, ob er es noch konnte. Lio drehte sich, lachte und ließ sich treiben, bis seine Füße wieder Boden fanden—auf einer Wurzel, die dort gestern noch nicht gewesen war.

Die Insel veränderte sich gern.

Im Wald leuchteten Pilze in Farben, die keine Namen trugen. Sie warfen Schatten, die nicht zum Licht passten, und die Schatten tuschelten. Lio hörte nicht hin. Er kannte die Regeln: Wer zuhört, bleibt stehen. Wer stehen bleibt, wird alt. Und alt werden war etwas für andere Orte.

Ein Pfeifen zerschnitt die Stille—kurz, scharf, absichtlich falsch. Lio hielt an. Das Pfeifen kannte er. Es bedeutete Ärger oder Abenteuer, manchmal beides. Er folgte dem Klang zu einer Lichtung, wo die Gräser sich verbeugten, als er näherkam.

Dort stand Mira.

Sie war neu, das sah man sofort. Neu war ein Geruch, ein Stolpern im Blick, ein Zögern zwischen Schritt und Gedanke. Mira hielt einen zerknitterten Zettel in der Hand, als sei er ein Rettungsring. Ihre Schuhe waren staubig von Wegen, die hier nicht existierten.

„Du bist spät", sagte Lio, ohne zu wissen, warum er das sagte.

„Ich weiß nicht einmal, wo ich bin", antwortete Mira und klang überrascht, dass ihre Stimme hier funktionierte.

Die Insel atmete. Ein fernes Pochen ging durch den Boden, als hätte jemand ein Herz angestoßen. Lio spürte es bis in die Fingerspitzen. Neu bedeutete Veränderung. Veränderung bedeutete Geschichten.

„Dann bist du genau richtig", sagte er. „Aber du musst etwas lernen."

„Was?"

Er deutete auf den Himmel. Die Sterne hatten begonnen, ihre Plätze zu tauschen. „Hier gewinnt niemand Zeit", sagte Lio. „Man verliert sie nur anders."

Mira sah hinauf, und für einen Moment vergaß sie den Zettel. Der Wind kam näher, neugierig wie ein Kind. Und irgendwo hinter den Bäumen regte sich etwas, das beschlossen hatte, diese Begegnung nicht unbeachtet zu lassen.

Die Unzeit hatte gerufen. Und die Insel hatte geantwortet.''',
          displayOrder: 1,
          isPlaceholder: false,
        ),
        'page_2': const StoryPage(
          id: 'page_2',
          title: 'Kapitel 2: Der Weg',
          content: '''
[Platzhalter-Inhalt]

Du gehst weiter auf dem Pfad...
          ''',
          displayOrder: 2,
          isPlaceholder: true,
        ),
        'page_3': StoryPage(
          id: 'page_3',
          title: 'Kapitel 3: Die Entscheidung',
          content: '''
[Branching-Demo]

Du kommst an eine Kreuzung mit drei Wegen.

Ein altes Schild zeigt in verschiedene Richtungen:
• Nach Norden: Der Bergpfad
• Nach Osten: Der Flusslauf
• Nach Westen: Der dunkle Wald

Welchen Weg wählst du?
          ''',
          displayOrder: 3,
          isPlaceholder: true,
          choices: const [
            Choice(
              id: 'choice_3a',
              text: 'A: Bergpfad (Norden)',
              nextPageId: 'page_4',
              description: 'Der steile Weg nach oben verspricht eine gute Aussicht',
            ),
            Choice(
              id: 'choice_3b',
              text: 'B: Flusslauf (Osten)',
              nextPageId: 'page_5',
              description: 'Das Rauschen des Wassers klingt beruhigend',
            ),
            Choice(
              id: 'choice_3c',
              text: 'C: Dunkler Wald (Westen)',
              nextPageId: 'page_6',
              description: 'Ein mysteriöser Pfad für Abenteuerlustige',
            ),
          ],
        ),
        'page_4': const StoryPage(
          id: 'page_4',
          title: 'Kapitel 4: Der Bergpfad',
          content: '[Platzhalter] Du hast den Bergpfad gewählt...',
          displayOrder: 4,
          isPlaceholder: true,
        ),
        'page_5': const StoryPage(
          id: 'page_5',
          title: 'Kapitel 5: Der Flusslauf',
          content: '[Platzhalter] Du folgst dem Fluss...',
          displayOrder: 5,
          isPlaceholder: true,
        ),
        'page_6': const StoryPage(
          id: 'page_6',
          title: 'Kapitel 6: Der dunkle Wald',
          content: '[Platzhalter] Du betrittst den dunklen Wald...',
          displayOrder: 6,
          isPlaceholder: true,
        ),
        'page_7': const StoryPage(
          id: 'page_7',
          title: 'Kapitel 7',
          content: '[Platzhalter-Inhalt]',
          displayOrder: 7,
          isPlaceholder: true,
        ),
        'page_8': const StoryPage(
          id: 'page_8',
          title: 'Kapitel 8',
          content: '[Platzhalter-Inhalt]',
          displayOrder: 8,
          isPlaceholder: true,
        ),
        'page_9': const StoryPage(
          id: 'page_9',
          title: 'Kapitel 9',
          content: '[Platzhalter-Inhalt]',
          displayOrder: 9,
          isPlaceholder: true,
        ),
        'page_10': const StoryPage(
          id: 'page_10',
          title: 'Kapitel 10: Das Ende',
          content: '[Platzhalter] Das Ende der Geschichte...',
          displayOrder: 10,
          isPlaceholder: true,
        ),
      },
    );
  }
}

