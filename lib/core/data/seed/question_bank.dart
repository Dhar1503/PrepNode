import '../dtos/content_dto.dart';

/// Practice question bank.
///
/// PROVENANCE — read before adding to this file.
///
/// These are NOT transcribed from any specific TNPSC past paper. They are
/// syllabus-aligned practice questions whose answers are objectively
/// checkable: computed arithmetic, constitutional articles, dated events,
/// and standard scientific constants. `source` says exactly that, and every
/// row carries `verificationStatus: 'unverified'` so the app's existing
/// badge tells the user the truth rather than implying an official paper.
///
/// The rule this file was written under: never guess an answer. A question
/// whose key is uncertain is left out entirely — a wrong key teaches an
/// aspirant an incorrect fact, which is worse than a smaller bank. That is
/// why there are no current-affairs questions here (they go stale and
/// cannot be checked at write time) and no "which district is largest"
/// style questions whose answers change with administrative reorganisation.
class QuestionBank {
  QuestionBank._();

  static const _source =
      'PrepNode practice bank — syllabus-aligned, not from a specific past paper';

  static QuestionDto _q({
    required String id,
    required String subjectId,
    required String topicId,
    required String question,
    required String a,
    required String b,
    required String c,
    required String d,
    required String answer,
    required String explanation,
    String difficulty = 'medium',
  }) {
    return QuestionDto(
      questionId: id,
      examId: 'tnpsc-group2',
      subjectId: subjectId,
      topicId: topicId,
      year: 2026,
      questionText: question,
      optionA: a,
      optionB: b,
      optionC: c,
      optionD: d,
      correctAnswer: answer,
      explanation: explanation,
      difficulty: difficulty,
      createdAt: DateTime.now(),
      source: _source,
      verificationStatus: 'unverified',
    );
  }

  static const _gs = 'subject-general-studies';
  static const _apt = 'subject-aptitude';
  static const _tamil = 'subject-general-tamil';
  static const _english = 'subject-general-english';

  static List<QuestionDto> all() => [
        ..._aptitude(),
        ..._polity(),
        ..._history(),
        ..._tamilNaduHistory(),
        ..._geography(),
        ..._economy(),
        ..._science(),
        ..._tamilLanguage(),
        ..._englishLanguage(),
        ..._topUps(),
      ];

  /// Extra questions added so that no topic carries fewer than three.
  ///
  /// Mock tests are generated per topic, so a topic holding one question
  /// produces a one-question "test" that is not worth a user's time. The
  /// question_bank_test enforces the floor; these fill it.
  static List<QuestionDto> _topUps() => [
        _q(
          id: 'qb-top-001',
          subjectId: _gs,
          topicId: 'topic-directive-principles',
          question: 'Which Article directs the State to secure a Uniform Civil '
              'Code for all citizens?',
          a: 'Article 39',
          b: 'Article 44',
          c: 'Article 48',
          d: 'Article 51',
          answer: 'B',
          explanation: 'Article 44 of the Directive Principles asks the State '
              'to endeavour to secure a Uniform Civil Code throughout India.',
        ),
        _q(
          id: 'qb-top-002',
          subjectId: _gs,
          topicId: 'topic-indian-constitution',
          question: 'How many Schedules does the Constitution of India '
              'currently contain?',
          a: 'Eight',
          b: 'Ten',
          c: 'Twelve',
          d: 'Fourteen',
          answer: 'C',
          explanation: 'The Constitution began with eight Schedules; four more '
              'were added by later amendments, bringing the total to twelve.',
        ),
        _q(
          id: 'qb-top-003',
          subjectId: _gs,
          topicId: 'topic-judiciary',
          question: 'Which writ is issued to compel a public official to '
              'perform a duty they have failed to perform?',
          a: 'Habeas Corpus',
          b: 'Mandamus',
          c: 'Prohibition',
          d: 'Certiorari',
          answer: 'B',
          explanation: 'Mandamus means "we command" and orders a public '
              'authority to carry out a duty it is legally bound to perform.',
        ),
        _q(
          id: 'qb-top-004',
          subjectId: _gs,
          topicId: 'topic-tn-freedom-movement',
          question: 'By which title was the poet Subramania Bharati popularly '
              'known?',
          a: 'Mahakavi',
          b: 'Kappalottiya Tamilan',
          c: 'Thanthai',
          d: 'Perunthalaivar',
          answer: 'A',
          explanation: 'Bharati is called Mahakavi (great poet). '
              '"Kappalottiya Tamilan" refers to V. O. Chidambaram Pillai.',
        ),
        _q(
          id: 'qb-top-005',
          subjectId: _gs,
          topicId: 'topic-social-reformers-tn',
          question: 'In which year was the Justice Party (South Indian Liberal '
              'Federation) founded?',
          a: '1906',
          b: '1916',
          c: '1920',
          d: '1925',
          answer: 'B',
          explanation: 'The South Indian Liberal Federation, known as the '
              'Justice Party after its newspaper, was founded in November '
              '1916 in Madras.',
        ),
        _q(
          id: 'qb-top-006',
          subjectId: _gs,
          topicId: 'topic-physical-geography',
          question: 'The ozone layer is found in which layer of the '
              'atmosphere?',
          a: 'Troposphere',
          b: 'Stratosphere',
          c: 'Mesosphere',
          d: 'Thermosphere',
          answer: 'B',
          explanation: 'Ozone is concentrated in the stratosphere, where it '
              'absorbs most of the Sun\'s ultraviolet radiation. Weather '
              'occurs in the troposphere below it.',
        ),
        _q(
          id: 'qb-top-007',
          subjectId: _gs,
          topicId: 'topic-planning',
          question: 'During which period did India observe a "Plan Holiday"?',
          a: '1962 to 1965',
          b: '1966 to 1969',
          c: '1971 to 1974',
          d: '1978 to 1980',
          answer: 'B',
          explanation: 'After the 1965 war and successive droughts, the Fourth '
              'Plan was postponed and three annual plans ran from 1966 to '
              '1969 instead.',
          difficulty: 'hard',
        ),
        _q(
          id: 'qb-top-008',
          subjectId: _gs,
          topicId: 'topic-agriculture-economy',
          question: 'The Blue Revolution in India is associated with which '
              'sector?',
          a: 'Poultry',
          b: 'Fisheries',
          c: 'Oilseeds',
          d: 'Horticulture',
          answer: 'B',
          explanation: 'The Blue Revolution refers to the rapid growth of '
              'fisheries and aquaculture. Oilseeds were the Yellow Revolution '
              'and horticulture the Golden Revolution.',
        ),
        _q(
          id: 'qb-top-009',
          subjectId: _tamil,
          topicId: 'topic-tamil-grammar',
          question: 'Tholkappiyam is divided into how many main sections '
              '(adhikarams)?',
          a: 'Two',
          b: 'Three',
          c: 'Four',
          d: 'Five',
          answer: 'B',
          explanation: 'Its three sections are Ezhuthadhikaram (letters), '
              'Solladhikaram (words) and Poruladhikaram (subject matter).',
        ),
        // topic-tn-history and topic-indian-economy each hold exactly one
        // question in seed_data.dart itself, which would otherwise generate
        // a one-question mock test for each.
        _q(
          id: 'qb-top-012',
          subjectId: _gs,
          topicId: 'topic-tn-history',
          question: 'Which Chola ruler led a naval expedition to Southeast '
              'Asia?',
          a: 'Rajaraja Chola I',
          b: 'Rajendra Chola I',
          c: 'Karikala Chola',
          d: 'Kulothunga Chola I',
          answer: 'B',
          explanation: 'Rajendra Chola I sent a naval expedition against the '
              'Srivijaya empire and took the title Kadaram Kondan.',
        ),
        _q(
          id: 'qb-top-013',
          subjectId: _gs,
          topicId: 'topic-tn-history',
          question: 'The Kallanai (Grand Anicut) across the Cauvery was built '
              'by which ruler?',
          a: 'Karikala Chola',
          b: 'Rajaraja Chola I',
          c: 'Nedunjeliyan',
          d: 'Cheran Senguttuvan',
          answer: 'A',
          explanation: 'Karikala Chola built the Kallanai in the 2nd century '
              'CE. It is among the oldest water-diversion structures still in '
              'use.',
        ),
        _q(
          id: 'qb-top-014',
          subjectId: _gs,
          topicId: 'topic-indian-economy',
          question: 'In which year did India begin its New Economic Policy of '
              'liberalisation?',
          a: '1985',
          b: '1991',
          c: '1995',
          d: '2000',
          answer: 'B',
          explanation: 'Facing a balance of payments crisis, India began '
              'liberalisation, privatisation and globalisation reforms in '
              '1991.',
        ),
        _q(
          id: 'qb-top-015',
          subjectId: _gs,
          topicId: 'topic-indian-economy',
          question: 'What does GDP stand for?',
          a: 'Gross Domestic Product',
          b: 'General Domestic Product',
          c: 'Gross Development Product',
          d: 'Grand Domestic Produce',
          answer: 'A',
          explanation: 'Gross Domestic Product is the total market value of '
              'all final goods and services produced within a country in a '
              'given period.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-top-011',
          subjectId: _tamil,
          topicId: 'topic-tamil-grammar',
          question: 'How many letters are there in the Tamil alphabet in '
              'total?',
          a: '216',
          b: '231',
          c: '247',
          d: '252',
          answer: 'C',
          explanation: '12 uyir (vowels) + 18 mei (consonants) + 1 aytham + '
              '216 uyirmei (compound letters) = 247.',
        ),
        _q(
          id: 'qb-top-010',
          subjectId: _tamil,
          topicId: 'topic-sangam-literature',
          question: 'Pattuppattu, the Sangam collection, consists of how many '
              'poems?',
          a: 'Five',
          b: 'Eight',
          c: 'Ten',
          d: 'Eighteen',
          answer: 'C',
          explanation: 'Pattuppattu means "ten songs" and comprises ten long '
              'poems. Ettuthogai is the companion set of eight anthologies.',
        ),
      ];

  // ==================== APTITUDE ====================
  // Every answer here is computed, so it can be checked by working the
  // problem rather than trusting a source.

  static List<QuestionDto> _aptitude() => [
        _q(
          id: 'qb-apt-001',
          subjectId: _apt,
          topicId: 'topic-number-system',
          question: 'What is the HCF of 36 and 60?',
          a: '6',
          b: '12',
          c: '18',
          d: '24',
          answer: 'B',
          explanation: '36 = 2² x 3² and 60 = 2² x 3 x 5. The common factors '
              'are 2² x 3 = 12.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-002',
          subjectId: _apt,
          topicId: 'topic-number-system',
          question: 'What is the LCM of 12 and 18?',
          a: '30',
          b: '36',
          c: '54',
          d: '72',
          answer: 'B',
          explanation: '12 = 2² x 3 and 18 = 2 x 3². LCM takes the highest '
              'power of each prime: 2² x 3² = 36.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-003',
          subjectId: _apt,
          topicId: 'topic-number-system',
          question: 'Which is the smallest prime number greater than 90?',
          a: '91',
          b: '93',
          c: '95',
          d: '97',
          answer: 'D',
          explanation: '91 = 7 x 13, 93 = 3 x 31 and 95 = 5 x 19, so all three '
              'are composite. 97 has no factor other than 1 and itself.',
        ),
        _q(
          id: 'qb-apt-004',
          subjectId: _apt,
          topicId: 'topic-number-system',
          question: 'What is the sum of the first 20 natural numbers?',
          a: '190',
          b: '200',
          c: '210',
          d: '220',
          answer: 'C',
          explanation: 'Sum = n(n+1)/2 = 20 x 21 / 2 = 210.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-005',
          subjectId: _apt,
          topicId: 'topic-number-system',
          question: 'What is the square root of 1156?',
          a: '32',
          b: '34',
          c: '36',
          d: '38',
          answer: 'B',
          explanation: '34 x 34 = 1156. A quick check: the number ends in 6, '
              'so its root ends in 4 or 6, and 1156 lies between 30² = 900 '
              'and 40² = 1600.',
        ),
        _q(
          id: 'qb-apt-006',
          subjectId: _apt,
          topicId: 'topic-number-system',
          question: 'What is the value of 2 raised to the power 10?',
          a: '512',
          b: '1000',
          c: '1024',
          d: '2048',
          answer: 'C',
          explanation: '2^10 = 1024. (2^9 = 512 and 2^11 = 2048.)',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-007',
          subjectId: _apt,
          topicId: 'topic-number-system',
          question: 'What is the cube of 12?',
          a: '1296',
          b: '1728',
          c: '1584',
          d: '2196',
          answer: 'B',
          explanation: '12 x 12 x 12 = 144 x 12 = 1728.',
        ),
        _q(
          id: 'qb-apt-008',
          subjectId: _apt,
          topicId: 'topic-algebra',
          question: 'If 5x = 45, what is the value of x?',
          a: '5',
          b: '7',
          c: '9',
          d: '11',
          answer: 'C',
          explanation: 'Dividing both sides by 5 gives x = 45 / 5 = 9.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-009',
          subjectId: _apt,
          topicId: 'topic-algebra',
          question: 'If a : b = 2 : 3 and b : c = 4 : 5, what is a : c?',
          a: '2 : 5',
          b: '8 : 15',
          c: '3 : 4',
          d: '6 : 10',
          answer: 'B',
          explanation: 'Make b common: a : b = 8 : 12 and b : c = 12 : 15, so '
              'a : b : c = 8 : 12 : 15 and a : c = 8 : 15.',
          difficulty: 'hard',
        ),
        _q(
          id: 'qb-apt-010',
          subjectId: _apt,
          topicId: 'topic-algebra',
          question: 'A sum of Rs. 64 is divided in the ratio 3 : 5. What is '
              'the larger share?',
          a: 'Rs. 24',
          b: 'Rs. 32',
          c: 'Rs. 40',
          d: 'Rs. 45',
          answer: 'C',
          explanation: 'Total parts = 3 + 5 = 8, so one part = 64 / 8 = 8. The '
              'larger share is 5 x 8 = Rs. 40.',
        ),
        _q(
          id: 'qb-apt-011',
          subjectId: _apt,
          topicId: 'topic-algebra',
          question: '30% of a number is 45. What is the number?',
          a: '120',
          b: '135',
          c: '150',
          d: '165',
          answer: 'C',
          explanation: 'If 0.30x = 45 then x = 45 / 0.30 = 150.',
        ),
        _q(
          id: 'qb-apt-012',
          subjectId: _apt,
          topicId: 'topic-algebra',
          question: 'What is 15% of 240?',
          a: '32',
          b: '36',
          c: '38',
          d: '42',
          answer: 'B',
          explanation: '10% of 240 is 24 and 5% is 12, so 15% = 24 + 12 = 36.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-013',
          subjectId: _apt,
          topicId: 'topic-algebra',
          question: 'What is the simple interest on Rs. 5,000 at 8% per annum '
              'for 2 years?',
          a: 'Rs. 400',
          b: 'Rs. 800',
          c: 'Rs. 1,000',
          d: 'Rs. 1,600',
          answer: 'B',
          explanation: 'SI = PRT/100 = 5000 x 8 x 2 / 100 = Rs. 800.',
        ),
        _q(
          id: 'qb-apt-014',
          subjectId: _apt,
          topicId: 'topic-algebra',
          question: 'What is the compound interest on Rs. 1,000 at 10% per '
              'annum for 2 years, compounded annually?',
          a: 'Rs. 200',
          b: 'Rs. 210',
          c: 'Rs. 220',
          d: 'Rs. 231',
          answer: 'B',
          explanation: 'Amount = 1000 x (1.1)² = Rs. 1,210, so the interest is '
              '1210 - 1000 = Rs. 210.',
          difficulty: 'hard',
        ),
        _q(
          id: 'qb-apt-015',
          subjectId: _apt,
          topicId: 'topic-geometry',
          question: 'What is the area of a circle of radius 7 cm? (Take pi = 22/7)',
          a: '154 sq cm',
          b: '144 sq cm',
          c: '176 sq cm',
          d: '198 sq cm',
          answer: 'A',
          explanation: 'Area = pi r² = (22/7) x 7 x 7 = 22 x 7 = 154 sq cm.',
        ),
        _q(
          id: 'qb-apt-016',
          subjectId: _apt,
          topicId: 'topic-geometry',
          question: 'What is the perimeter of a rectangle 12 cm long and 8 cm '
              'wide?',
          a: '20 cm',
          b: '40 cm',
          c: '48 cm',
          d: '96 cm',
          answer: 'B',
          explanation: 'Perimeter = 2(length + breadth) = 2(12 + 8) = 40 cm. '
              '(96 sq cm would be the area.)',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-017',
          subjectId: _apt,
          topicId: 'topic-geometry',
          question: 'Two angles of a triangle measure 45 degrees and 65 '
              'degrees. What is the third angle?',
          a: '60 degrees',
          b: '70 degrees',
          c: '80 degrees',
          d: '90 degrees',
          answer: 'B',
          explanation: 'The angles of a triangle sum to 180 degrees, so the '
              'third is 180 - 45 - 65 = 70 degrees.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-018',
          subjectId: _apt,
          topicId: 'topic-geometry',
          question: 'What is the volume of a cube of side 5 cm?',
          a: '25 cubic cm',
          b: '75 cubic cm',
          c: '125 cubic cm',
          d: '150 cubic cm',
          answer: 'C',
          explanation: 'Volume of a cube = side³ = 5 x 5 x 5 = 125 cubic cm.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-019',
          subjectId: _apt,
          topicId: 'topic-data-interpretation',
          question: 'What is the average of 10, 20, 30, 40 and 50?',
          a: '25',
          b: '30',
          c: '35',
          d: '40',
          answer: 'B',
          explanation: 'Sum = 150 and there are 5 values, so the average is '
              '150 / 5 = 30.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-020',
          subjectId: _apt,
          topicId: 'topic-data-interpretation',
          question: 'A train travels at 60 km/h. How far does it travel in 30 '
              'minutes?',
          a: '20 km',
          b: '30 km',
          c: '40 km',
          d: '60 km',
          answer: 'B',
          explanation: '30 minutes is half an hour, so distance = 60 x 0.5 = '
              '30 km.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-021',
          subjectId: _apt,
          topicId: 'topic-data-interpretation',
          question: 'In a class of 50 students, 60% passed. How many failed?',
          a: '15',
          b: '20',
          c: '25',
          d: '30',
          answer: 'B',
          explanation: '60% of 50 = 30 passed, so 50 - 30 = 20 failed.',
        ),
        _q(
          id: 'qb-apt-022',
          subjectId: _apt,
          topicId: 'topic-logical-reasoning',
          question: 'Complete the series: 2, 6, 12, 20, 30, ___',
          a: '38',
          b: '40',
          c: '42',
          d: '44',
          answer: 'C',
          explanation: 'The differences are 4, 6, 8, 10, so the next '
              'difference is 12 and the next term is 30 + 12 = 42.',
        ),
        _q(
          id: 'qb-apt-023',
          subjectId: _apt,
          topicId: 'topic-logical-reasoning',
          question: 'Complete the series: 3, 9, 27, 81, ___',
          a: '162',
          b: '216',
          c: '243',
          d: '324',
          answer: 'C',
          explanation: 'Each term is multiplied by 3, so the next term is '
              '81 x 3 = 243.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-apt-024',
          subjectId: _apt,
          topicId: 'topic-logical-reasoning',
          question: 'If in a code MONDAY is written as NPOEBZ, how is FRIDAY '
              'written?',
          a: 'GSJEBZ',
          b: 'GSJFBZ',
          c: 'GSKEBZ',
          d: 'GTJEBZ',
          answer: 'A',
          explanation: 'Each letter moves forward by one: F->G, R->S, I->J, '
              'D->E, A->B, Y->Z, giving GSJEBZ.',
          difficulty: 'hard',
        ),
        _q(
          id: 'qb-apt-025',
          subjectId: _apt,
          topicId: 'topic-logical-reasoning',
          question: 'A is the brother of B. B is the daughter of C. How is A '
              'related to C?',
          a: 'Son',
          b: 'Daughter',
          c: 'Father',
          d: 'Nephew',
          answer: 'A',
          explanation: 'B is C\'s daughter and A is B\'s brother, so A is also '
              'C\'s child — specifically the son.',
        ),
      ];

  // ==================== POLITY ====================

  static List<QuestionDto> _polity() => [
        _q(
          id: 'qb-pol-001',
          subjectId: _gs,
          topicId: 'topic-fundamental-rights',
          question: 'Which Article of the Indian Constitution guarantees '
              'equality before the law?',
          a: 'Article 12',
          b: 'Article 14',
          c: 'Article 19',
          d: 'Article 21',
          answer: 'B',
          explanation: 'Article 14 guarantees equality before the law and '
              'equal protection of the laws within the territory of India.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-pol-002',
          subjectId: _gs,
          topicId: 'topic-fundamental-rights',
          question: 'Which Article guarantees protection of life and personal '
              'liberty?',
          a: 'Article 19',
          b: 'Article 20',
          c: 'Article 21',
          d: 'Article 22',
          answer: 'C',
          explanation: 'Article 21 states that no person shall be deprived of '
              'life or personal liberty except according to procedure '
              'established by law.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-pol-003',
          subjectId: _gs,
          topicId: 'topic-fundamental-rights',
          question: 'Which Article did Dr. B. R. Ambedkar call the "heart and '
              'soul" of the Constitution?',
          a: 'Article 14',
          b: 'Article 21',
          c: 'Article 32',
          d: 'Article 51A',
          answer: 'C',
          explanation: 'Article 32 provides the right to constitutional '
              'remedies — the right to move the Supreme Court to enforce '
              'Fundamental Rights.',
        ),
        _q(
          id: 'qb-pol-004',
          subjectId: _gs,
          topicId: 'topic-fundamental-rights',
          question: 'Right to Education was inserted as Article 21A by which '
              'Constitutional Amendment?',
          a: '73rd Amendment',
          b: '74th Amendment',
          c: '86th Amendment',
          d: '93rd Amendment',
          answer: 'C',
          explanation: 'The 86th Amendment Act, 2002 inserted Article 21A, '
              'making free and compulsory education a Fundamental Right for '
              'children aged 6 to 14.',
        ),
        _q(
          id: 'qb-pol-005',
          subjectId: _gs,
          topicId: 'topic-directive-principles',
          question: 'The Directive Principles of State Policy are contained in '
              'which Part of the Constitution?',
          a: 'Part III',
          b: 'Part IV',
          c: 'Part IVA',
          d: 'Part V',
          answer: 'B',
          explanation: 'Part IV (Articles 36 to 51) contains the Directive '
              'Principles. Part III holds Fundamental Rights and Part IVA the '
              'Fundamental Duties.',
        ),
        _q(
          id: 'qb-pol-006',
          subjectId: _gs,
          topicId: 'topic-directive-principles',
          question: 'From which country\'s constitution were the Directive '
              'Principles of State Policy borrowed?',
          a: 'United States',
          b: 'Ireland',
          c: 'Canada',
          d: 'Australia',
          answer: 'B',
          explanation: 'The Directive Principles were adopted from the Irish '
              'Constitution, which had in turn drawn on the Spanish '
              'Constitution.',
        ),
        _q(
          id: 'qb-pol-007',
          subjectId: _gs,
          topicId: 'topic-indian-constitution',
          question: 'Fundamental Duties were added to the Constitution by '
              'which Amendment?',
          a: '24th Amendment',
          b: '42nd Amendment',
          c: '44th Amendment',
          d: '52nd Amendment',
          answer: 'B',
          explanation: 'The 42nd Amendment Act, 1976 added Part IVA with '
              'Article 51A, on the recommendation of the Swaran Singh '
              'Committee.',
        ),
        _q(
          id: 'qb-pol-008',
          subjectId: _gs,
          topicId: 'topic-indian-constitution',
          question: 'The words "Socialist", "Secular" and "Integrity" were '
              'added to the Preamble by which Amendment?',
          a: '42nd Amendment',
          b: '44th Amendment',
          c: '52nd Amendment',
          d: '61st Amendment',
          answer: 'A',
          explanation: 'The 42nd Amendment Act, 1976 changed the Preamble\'s '
              'description of India to a "Sovereign Socialist Secular '
              'Democratic Republic".',
        ),
        _q(
          id: 'qb-pol-009',
          subjectId: _gs,
          topicId: 'topic-parliament',
          question: 'What is the maximum permitted strength of the Rajya Sabha?',
          a: '238',
          b: '245',
          c: '250',
          d: '270',
          answer: 'C',
          explanation: 'The Constitution caps the Rajya Sabha at 250 members — '
              'up to 238 representing States and Union Territories, plus 12 '
              'nominated by the President.',
        ),
        _q(
          id: 'qb-pol-010',
          subjectId: _gs,
          topicId: 'topic-parliament',
          question: 'A Money Bill can be introduced only in which House?',
          a: 'Rajya Sabha',
          b: 'Lok Sabha',
          c: 'Either House',
          d: 'A joint sitting',
          answer: 'B',
          explanation: 'Under Article 110, a Money Bill can be introduced only '
              'in the Lok Sabha, and only on the recommendation of the '
              'President.',
        ),
        _q(
          id: 'qb-pol-011',
          subjectId: _gs,
          topicId: 'topic-parliament',
          question: 'What is the normal term of the Lok Sabha?',
          a: '4 years',
          b: '5 years',
          c: '6 years',
          d: '7 years',
          answer: 'B',
          explanation: 'The Lok Sabha has a five-year term unless dissolved '
              'earlier. Rajya Sabha members serve six years and it is never '
              'dissolved.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-pol-012',
          subjectId: _gs,
          topicId: 'topic-judiciary',
          question: 'What is the retirement age of a Supreme Court judge in '
              'India?',
          a: '60 years',
          b: '62 years',
          c: '65 years',
          d: '70 years',
          answer: 'C',
          explanation: 'Supreme Court judges retire at 65. High Court judges '
              'retire at 62.',
        ),
        _q(
          id: 'qb-pol-013',
          subjectId: _gs,
          topicId: 'topic-judiciary',
          question: 'Which writ is issued to produce a detained person before '
              'a court?',
          a: 'Mandamus',
          b: 'Habeas Corpus',
          c: 'Certiorari',
          d: 'Quo Warranto',
          answer: 'B',
          explanation: 'Habeas Corpus literally means "you may have the body" '
              'and requires a detained person to be produced before the court '
              'to test the legality of the detention.',
        ),
        _q(
          id: 'qb-pol-014',
          subjectId: _gs,
          topicId: 'topic-union-state-executive',
          question: 'Who appoints the Governor of a State?',
          a: 'The Prime Minister',
          b: 'The President',
          c: 'The Chief Minister',
          d: 'The Chief Justice of India',
          answer: 'B',
          explanation: 'Under Article 155 the Governor is appointed by the '
              'President and holds office during the President\'s pleasure.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-pol-015',
          subjectId: _gs,
          topicId: 'topic-union-state-executive',
          question: 'Under which Article is the office of the Comptroller and '
              'Auditor General established?',
          a: 'Article 76',
          b: 'Article 148',
          c: 'Article 280',
          d: 'Article 324',
          answer: 'B',
          explanation: 'Article 148 provides for the CAG. Article 76 is the '
              'Attorney General, Article 280 the Finance Commission and '
              'Article 324 the Election Commission.',
          difficulty: 'hard',
        ),
        _q(
          id: 'qb-pol-016',
          subjectId: _gs,
          topicId: 'topic-union-state-executive',
          question: 'The Panchayati Raj system was given constitutional status '
              'by which Amendment?',
          a: '71st Amendment',
          b: '72nd Amendment',
          c: '73rd Amendment',
          d: '74th Amendment',
          answer: 'C',
          explanation: 'The 73rd Amendment Act, 1992 added Part IX on '
              'Panchayats. The 74th did the same for urban local bodies.',
        ),
      ];

  // ==================== INDIAN HISTORY ====================

  static List<QuestionDto> _history() => [
        _q(
          id: 'qb-his-001',
          subjectId: _gs,
          topicId: 'topic-ancient-india',
          question: 'Which Indus Valley site was excavated first, in 1921?',
          a: 'Mohenjo-daro',
          b: 'Harappa',
          c: 'Lothal',
          d: 'Kalibangan',
          answer: 'B',
          explanation: 'Harappa was excavated by Daya Ram Sahni in 1921; '
              'Mohenjo-daro followed in 1922 under R. D. Banerji. The '
              'civilisation is named after Harappa for this reason.',
        ),
        _q(
          id: 'qb-his-002',
          subjectId: _gs,
          topicId: 'topic-ancient-india',
          question: 'After which war did Emperor Ashoka embrace Buddhism?',
          a: 'The Kalinga War',
          b: 'The Battle of Hydaspes',
          c: 'The Kurukshetra War',
          d: 'The Battle of Takshashila',
          answer: 'A',
          explanation: 'The bloodshed of the Kalinga War (c. 261 BCE) led '
              'Ashoka to renounce war and adopt Buddhism, recorded in his own '
              'Rock Edict XIII.',
        ),
        _q(
          id: 'qb-his-003',
          subjectId: _gs,
          topicId: 'topic-ancient-india',
          question: 'Which period of Indian history is described as the '
              '"Golden Age"?',
          a: 'The Maurya period',
          b: 'The Gupta period',
          c: 'The Kushana period',
          d: 'The Satavahana period',
          answer: 'B',
          explanation: 'The Gupta period (c. 320-550 CE) is called the Golden '
              'Age for its achievements in mathematics, astronomy, literature '
              'and sculpture.',
        ),
        _q(
          id: 'qb-his-004',
          subjectId: _gs,
          topicId: 'topic-medieval-india',
          question: 'Who founded the Slave (Mamluk) Dynasty of the Delhi '
              'Sultanate?',
          a: 'Iltutmish',
          b: 'Balban',
          c: 'Qutb-ud-din Aibak',
          d: 'Razia Sultana',
          answer: 'C',
          explanation: 'Qutb-ud-din Aibak founded the dynasty in 1206 after '
              'the death of Muhammad Ghori, and began the Qutb Minar.',
        ),
        _q(
          id: 'qb-his-005',
          subjectId: _gs,
          topicId: 'topic-medieval-india',
          question: 'The First Battle of Panipat in 1526 established which '
              'empire in India?',
          a: 'The Delhi Sultanate',
          b: 'The Mughal Empire',
          c: 'The Maratha Empire',
          d: 'The Vijayanagara Empire',
          answer: 'B',
          explanation: 'Babur defeated Ibrahim Lodi at Panipat in 1526, ending '
              'the Lodi dynasty and founding the Mughal Empire.',
        ),
        _q(
          id: 'qb-his-006',
          subjectId: _gs,
          topicId: 'topic-medieval-india',
          question: 'Which Portuguese navigator reached Calicut in 1498?',
          a: 'Bartolomeu Dias',
          b: 'Vasco da Gama',
          c: 'Ferdinand Magellan',
          d: 'Pedro Alvares Cabral',
          answer: 'B',
          explanation: 'Vasco da Gama landed at Kappad near Calicut in May '
              '1498, opening the sea route from Europe to India.',
        ),
        _q(
          id: 'qb-his-007',
          subjectId: _gs,
          topicId: 'topic-modern-india',
          question: 'In which year was the Battle of Plassey fought?',
          a: '1757',
          b: '1764',
          c: '1772',
          d: '1784',
          answer: 'A',
          explanation: 'Robert Clive defeated Siraj-ud-Daulah at Plassey in '
              '1757, beginning British political power in Bengal. Buxar '
              'followed in 1764.',
        ),
        _q(
          id: 'qb-his-008',
          subjectId: _gs,
          topicId: 'topic-modern-india',
          question: 'Who founded the Indian National Congress in 1885?',
          a: 'Dadabhai Naoroji',
          b: 'A. O. Hume',
          c: 'W. C. Bonnerjee',
          d: 'Gopal Krishna Gokhale',
          answer: 'B',
          explanation: 'Allan Octavian Hume, a retired British civil servant, '
              'founded the Congress in 1885. W. C. Bonnerjee presided over its '
              'first session.',
        ),
        _q(
          id: 'qb-his-009',
          subjectId: _gs,
          topicId: 'topic-modern-india',
          question: 'The Jallianwala Bagh massacre took place in which year?',
          a: '1917',
          b: '1919',
          c: '1922',
          d: '1930',
          answer: 'B',
          explanation: 'General Dyer ordered firing on an unarmed gathering at '
              'Amritsar on 13 April 1919, during protests against the Rowlatt '
              'Act.',
        ),
        _q(
          id: 'qb-his-010',
          subjectId: _gs,
          topicId: 'topic-modern-india',
          question: 'The Dandi March of 1930 was launched against which tax?',
          a: 'The land tax',
          b: 'The salt tax',
          c: 'The income tax',
          d: 'The excise on cloth',
          answer: 'B',
          explanation: 'Gandhi walked from Sabarmati to Dandi to break the '
              'salt law, launching the Civil Disobedience Movement.',
        ),
        _q(
          id: 'qb-his-011',
          subjectId: _gs,
          topicId: 'topic-modern-india',
          question: 'In which year was the Quit India Movement launched?',
          a: '1930',
          b: '1935',
          c: '1942',
          d: '1945',
          answer: 'C',
          explanation: 'The Congress passed the Quit India resolution in '
              'Bombay on 8 August 1942, where Gandhi gave the call "Do or '
              'Die".',
        ),
      ];

  // ==================== TAMIL NADU HISTORY ====================

  static List<QuestionDto> _tamilNaduHistory() => [
        _q(
          id: 'qb-tnh-001',
          subjectId: _gs,
          topicId: 'topic-ancient-tamil',
          question: 'The Brihadeeswarar Temple at Thanjavur was built by which '
              'ruler?',
          a: 'Rajendra Chola I',
          b: 'Rajaraja Chola I',
          c: 'Karikala Chola',
          d: 'Kulothunga Chola I',
          answer: 'B',
          explanation: 'Rajaraja Chola I completed the temple in 1010 CE. It '
              'is a UNESCO World Heritage Site as one of the Great Living '
              'Chola Temples.',
        ),
        _q(
          id: 'qb-tnh-002',
          subjectId: _gs,
          topicId: 'topic-ancient-tamil',
          question: 'Which city was the capital of the Pallava dynasty?',
          a: 'Madurai',
          b: 'Thanjavur',
          c: 'Kanchipuram',
          d: 'Uraiyur',
          answer: 'C',
          explanation: 'Kanchipuram was the Pallava capital. Madurai was the '
              'Pandya capital and Thanjavur the Chola capital.',
        ),
        _q(
          id: 'qb-tnh-003',
          subjectId: _gs,
          topicId: 'topic-ancient-tamil',
          question: 'The Keezhadi excavation site is located in which district '
              'of Tamil Nadu?',
          a: 'Madurai',
          b: 'Sivaganga',
          c: 'Thanjavur',
          d: 'Tirunelveli',
          answer: 'B',
          explanation: 'Keezhadi lies in Sivaganga district on the banks of '
              'the Vaigai, and its finds point to an urban Sangam-age '
              'settlement.',
        ),
        _q(
          id: 'qb-tnh-004',
          subjectId: _gs,
          topicId: 'topic-ancient-tamil',
          question: 'The emblem of the Chola dynasty was which animal?',
          a: 'The tiger',
          b: 'The fish',
          c: 'The bow',
          d: 'The lion',
          answer: 'A',
          explanation: 'The Cholas used the tiger, the Pandyas the fish and '
              'the Cheras the bow.',
        ),
        _q(
          id: 'qb-tnh-005',
          subjectId: _gs,
          topicId: 'topic-tn-freedom-movement',
          question: 'Who founded the Swadeshi Steam Navigation Company?',
          a: 'Subramania Bharati',
          b: 'V. O. Chidambaram Pillai',
          c: 'Subramania Siva',
          d: 'Tiruppur Kumaran',
          answer: 'B',
          explanation: 'V. O. Chidambaram Pillai launched the company in 1906 '
              'to compete with British shipping, earning him the title '
              '"Kappalottiya Tamilan".',
        ),
        _q(
          id: 'qb-tnh-006',
          subjectId: _gs,
          topicId: 'topic-tn-freedom-movement',
          question: 'Veerapandiya Kattabomman was the ruler of which '
              'palayam?',
          a: 'Sivagangai',
          b: 'Panchalankurichi',
          c: 'Ramnad',
          d: 'Dindigul',
          answer: 'B',
          explanation: 'Kattabomman was the Palayakkarar of Panchalankurichi '
              'and was executed by the British at Kayathar in 1799.',
        ),
        _q(
          id: 'qb-tnh-007',
          subjectId: _gs,
          topicId: 'topic-social-reformers-tn',
          question: 'Who founded the Self-Respect Movement in Tamil Nadu?',
          a: 'Periyar E. V. Ramasamy',
          b: 'C. N. Annadurai',
          c: 'Rajaji',
          d: 'Maraimalai Adigal',
          answer: 'A',
          explanation: 'Periyar E. V. Ramasamy launched the Self-Respect '
              'Movement in 1925 against caste hierarchy and religious '
              'orthodoxy.',
        ),
        _q(
          id: 'qb-tnh-008',
          subjectId: _gs,
          topicId: 'topic-social-reformers-tn',
          question: 'The Vaikom Satyagraha of 1924 was launched to secure '
              'which right?',
          a: 'The right to enter temples and use temple roads',
          b: 'The right to vote',
          c: 'The right to education',
          d: 'The right to own land',
          answer: 'A',
          explanation: 'The satyagraha demanded that so-called lower castes be '
              'allowed to use the roads around the Vaikom temple. Periyar\'s '
              'role in it earned him the title "Vaikom Veerar".',
        ),
      ];

  // ==================== GEOGRAPHY ====================

  static List<QuestionDto> _geography() => [
        _q(
          id: 'qb-geo-001',
          subjectId: _gs,
          topicId: 'topic-indian-geography',
          question: 'Which is the highest mountain peak situated within India?',
          a: 'Mount Everest',
          b: 'Kanchenjunga',
          c: 'Nanda Devi',
          d: 'K2',
          answer: 'B',
          explanation: 'Kanchenjunga in Sikkim is the highest peak within '
              'India. Everest lies in Nepal, and K2 is in the disputed '
              'Pakistan-administered region.',
        ),
        _q(
          id: 'qb-geo-002',
          subjectId: _gs,
          topicId: 'topic-indian-geography',
          question: 'What is the Standard Meridian of India?',
          a: '80 degrees 30 minutes East',
          b: '82 degrees 30 minutes East',
          c: '84 degrees 30 minutes East',
          d: '86 degrees 30 minutes East',
          answer: 'B',
          explanation: 'Indian Standard Time is based on 82 degrees 30 minutes '
              'East, which passes near Mirzapur in Uttar Pradesh.',
        ),
        _q(
          id: 'qb-geo-003',
          subjectId: _gs,
          topicId: 'topic-indian-geography',
          question: 'Which is the longest river in India?',
          a: 'The Brahmaputra',
          b: 'The Godavari',
          c: 'The Ganga',
          d: 'The Yamuna',
          answer: 'C',
          explanation: 'The Ganga runs about 2,525 km within India. The '
              'Godavari is the longest river of peninsular India.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-geo-004',
          subjectId: _gs,
          topicId: 'topic-tn-geography',
          question: 'Which is the longest river in Tamil Nadu?',
          a: 'The Vaigai',
          b: 'The Cauvery',
          c: 'The Thamirabarani',
          d: 'The Palar',
          answer: 'B',
          explanation: 'The Cauvery rises at Talakaveri in Karnataka and is '
              'the longest and most important river of Tamil Nadu.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-geo-005',
          subjectId: _gs,
          topicId: 'topic-tn-geography',
          question: 'Which is the highest peak in Tamil Nadu?',
          a: 'Anaimudi',
          b: 'Doddabetta',
          c: 'Mahendragiri',
          d: 'Velliangiri',
          answer: 'B',
          explanation: 'Doddabetta in the Nilgiris rises to about 2,637 m. '
              'Anaimudi is the highest peak of the Western Ghats but lies in '
              'Kerala.',
        ),
        _q(
          id: 'qb-geo-006',
          subjectId: _gs,
          topicId: 'topic-tn-geography',
          question: 'The Palk Strait separates India from which country?',
          a: 'Maldives',
          b: 'Indonesia',
          c: 'Sri Lanka',
          d: 'Myanmar',
          answer: 'C',
          explanation: 'The Palk Strait lies between Tamil Nadu and northern '
              'Sri Lanka, connecting the Bay of Bengal with the Gulf of '
              'Mannar.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-geo-007',
          subjectId: _gs,
          topicId: 'topic-physical-geography',
          question: 'The Western Ghats and the Eastern Ghats meet at which '
              'hills?',
          a: 'The Nilgiri Hills',
          b: 'The Cardamom Hills',
          c: 'The Javadi Hills',
          d: 'The Shevaroy Hills',
          answer: 'A',
          explanation: 'The two ranges converge at the Nilgiris in the '
              'Tamil Nadu-Karnataka-Kerala border region.',
        ),
        _q(
          id: 'qb-geo-008',
          subjectId: _gs,
          topicId: 'topic-physical-geography',
          question: 'Tamil Nadu receives most of its rainfall from which '
              'monsoon?',
          a: 'The south-west monsoon',
          b: 'The north-east monsoon',
          c: 'Western disturbances',
          d: 'The Nor\'westers',
          answer: 'B',
          explanation: 'Unlike most of India, Tamil Nadu gets the bulk of its '
              'rain from the retreating north-east monsoon between October and '
              'December.',
        ),
      ];

  // ==================== ECONOMY ====================

  static List<QuestionDto> _economy() => [
        _q(
          id: 'qb-eco-001',
          subjectId: _gs,
          topicId: 'topic-banking-finance',
          question: 'In which year was the Reserve Bank of India established?',
          a: '1930',
          b: '1935',
          c: '1947',
          d: '1949',
          answer: 'B',
          explanation: 'The RBI began operations on 1 April 1935 under the RBI '
              'Act, 1934. It was nationalised in 1949.',
        ),
        _q(
          id: 'qb-eco-002',
          subjectId: _gs,
          topicId: 'topic-banking-finance',
          question: 'What is the repo rate?',
          a: 'The rate at which the RBI lends to commercial banks',
          b: 'The rate at which banks lend to their best customers',
          c: 'The rate at which the RBI borrows from commercial banks',
          d: 'The share of deposits banks must keep with the RBI',
          answer: 'A',
          explanation: 'The repo rate is the rate at which the RBI lends '
              'short-term funds to banks against securities. The reverse repo '
              'is the opposite, and the CRR is the reserve requirement.',
        ),
        _q(
          id: 'qb-eco-003',
          subjectId: _gs,
          topicId: 'topic-banking-finance',
          question: 'The Goods and Services Tax came into effect in India on '
              'which date?',
          a: '1 April 2016',
          b: '1 July 2017',
          c: '1 April 2018',
          d: '1 January 2019',
          answer: 'B',
          explanation: 'GST replaced most indirect taxes from 1 July 2017, '
              'introduced by the 101st Constitutional Amendment.',
        ),
        _q(
          id: 'qb-eco-004',
          subjectId: _gs,
          topicId: 'topic-planning',
          question: 'The First Five Year Plan of India was based on which '
              'model?',
          a: 'The Mahalanobis model',
          b: 'The Harrod-Domar model',
          c: 'The Gadgil formula',
          d: 'The Wage Goods model',
          answer: 'B',
          explanation: 'The First Plan (1951-56) used the Harrod-Domar model '
              'and prioritised agriculture. The Second Plan used the '
              'Mahalanobis model.',
        ),
        _q(
          id: 'qb-eco-005',
          subjectId: _gs,
          topicId: 'topic-planning',
          question: 'Which body replaced the Planning Commission in 2015?',
          a: 'The Finance Commission',
          b: 'NITI Aayog',
          c: 'The National Development Council',
          d: 'The Economic Advisory Council',
          answer: 'B',
          explanation: 'NITI Aayog (National Institution for Transforming '
              'India) was set up on 1 January 2015 as a policy think tank '
              'replacing the Planning Commission.',
        ),
        _q(
          id: 'qb-eco-006',
          subjectId: _gs,
          topicId: 'topic-agriculture-economy',
          question: 'Who is regarded as the father of the Green Revolution in '
              'India?',
          a: 'Verghese Kurien',
          b: 'M. S. Swaminathan',
          c: 'Norman Borlaug',
          d: 'C. Subramaniam',
          answer: 'B',
          explanation: 'M. S. Swaminathan led the Indian Green Revolution. '
              'Norman Borlaug is the father of the global Green Revolution and '
              'Verghese Kurien led the White Revolution.',
        ),
        _q(
          id: 'qb-eco-007',
          subjectId: _gs,
          topicId: 'topic-agriculture-economy',
          question: 'The White Revolution in India refers to a large increase '
              'in the production of what?',
          a: 'Wheat',
          b: 'Milk',
          c: 'Cotton',
          d: 'Sugar',
          answer: 'B',
          explanation: 'Operation Flood, led by Verghese Kurien from 1970, '
              'made India the world\'s largest milk producer.',
          difficulty: 'easy',
        ),
      ];

  // ==================== GENERAL SCIENCE ====================

  static List<QuestionDto> _science() => [
        _q(
          id: 'qb-sci-001',
          subjectId: _gs,
          topicId: 'topic-physics',
          question: 'What is the SI unit of force?',
          a: 'Joule',
          b: 'Watt',
          c: 'Newton',
          d: 'Pascal',
          answer: 'C',
          explanation: 'Force is measured in newtons. The joule is energy, the '
              'watt is power and the pascal is pressure.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-sci-002',
          subjectId: _gs,
          topicId: 'topic-physics',
          question: 'What is the approximate speed of light in vacuum?',
          a: '3 x 10^6 m/s',
          b: '3 x 10^8 m/s',
          c: '3 x 10^10 m/s',
          d: '3 x 10^12 m/s',
          answer: 'B',
          explanation: 'Light travels at about 299,792,458 m/s, usually '
              'rounded to 3 x 10^8 m/s.',
        ),
        _q(
          id: 'qb-sci-003',
          subjectId: _gs,
          topicId: 'topic-physics',
          question: 'What is the SI unit of electric current?',
          a: 'Volt',
          b: 'Ohm',
          c: 'Ampere',
          d: 'Coulomb',
          answer: 'C',
          explanation: 'Current is measured in amperes. The volt is potential '
              'difference, the ohm is resistance and the coulomb is charge.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-sci-004',
          subjectId: _gs,
          topicId: 'topic-chemistry',
          question: 'What is the chemical symbol for gold?',
          a: 'Go',
          b: 'Gd',
          c: 'Au',
          d: 'Ag',
          answer: 'C',
          explanation: 'Gold is Au, from the Latin aurum. Ag is silver, from '
              'argentum.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-sci-005',
          subjectId: _gs,
          topicId: 'topic-chemistry',
          question: 'What is the chemical formula of common salt?',
          a: 'NaCl',
          b: 'KCl',
          c: 'CaCl2',
          d: 'NaHCO3',
          answer: 'A',
          explanation: 'Common salt is sodium chloride, NaCl. NaHCO3 is baking '
              'soda.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-sci-006',
          subjectId: _gs,
          topicId: 'topic-chemistry',
          question: 'What is the pH value of pure water at 25 degrees Celsius?',
          a: '5',
          b: '6',
          c: '7',
          d: '8',
          answer: 'C',
          explanation: 'Pure water is neutral with a pH of 7. Below 7 is '
              'acidic and above 7 is basic.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-sci-007',
          subjectId: _gs,
          topicId: 'topic-biology',
          question: 'How many bones are there in the adult human body?',
          a: '196',
          b: '206',
          c: '216',
          d: '226',
          answer: 'B',
          explanation: 'An adult has 206 bones. A newborn has around 270, '
              'which fuse as the child grows.',
        ),
        _q(
          id: 'qb-sci-008',
          subjectId: _gs,
          topicId: 'topic-biology',
          question: 'Which is the largest gland in the human body?',
          a: 'The pancreas',
          b: 'The thyroid',
          c: 'The liver',
          d: 'The pituitary',
          answer: 'C',
          explanation: 'The liver is the largest gland, producing bile and '
              'handling detoxification and metabolism.',
        ),
        _q(
          id: 'qb-sci-009',
          subjectId: _gs,
          topicId: 'topic-biology',
          question: 'Deficiency of Vitamin C causes which disease?',
          a: 'Rickets',
          b: 'Scurvy',
          c: 'Beriberi',
          d: 'Night blindness',
          answer: 'B',
          explanation: 'Scurvy results from a lack of Vitamin C. Rickets is '
              'Vitamin D, beriberi is Vitamin B1 and night blindness is '
              'Vitamin A.',
        ),
        _q(
          id: 'qb-sci-010',
          subjectId: _gs,
          topicId: 'topic-biology',
          question: 'In which cell organelle does photosynthesis take place?',
          a: 'The mitochondrion',
          b: 'The chloroplast',
          c: 'The ribosome',
          d: 'The nucleus',
          answer: 'B',
          explanation: 'Chloroplasts contain chlorophyll, which captures light '
              'energy for photosynthesis.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-sci-011',
          subjectId: _gs,
          topicId: 'topic-biology',
          question: 'Which hormone is produced by the pancreas to regulate '
              'blood sugar?',
          a: 'Adrenaline',
          b: 'Thyroxine',
          c: 'Insulin',
          d: 'Oestrogen',
          answer: 'C',
          explanation: 'Insulin, secreted by the beta cells of the islets of '
              'Langerhans, lowers blood glucose. Its deficiency causes '
              'diabetes mellitus.',
        ),
      ];

  // ==================== GENERAL TAMIL ====================

  static List<QuestionDto> _tamilLanguage() => [
        _q(
          id: 'qb-tam-001',
          subjectId: _tamil,
          topicId: 'topic-tamil-authors',
          question: 'How many couplets (kurals) does the Thirukkural contain?',
          a: '1,000',
          b: '1,330',
          c: '1,530',
          d: '2,000',
          answer: 'B',
          explanation: 'The Thirukkural has 1,330 couplets across 133 chapters '
              'of ten couplets each, in three sections: Aram, Porul and Inbam.',
        ),
        _q(
          id: 'qb-tam-002',
          subjectId: _tamil,
          topicId: 'topic-tamil-authors',
          question: 'Who is the author of Silappathikaram?',
          a: 'Ilango Adigal',
          b: 'Sithalai Sathanar',
          c: 'Thiruvalluvar',
          d: 'Kambar',
          answer: 'A',
          explanation: 'Silappathikaram was composed by Ilango Adigal. Its '
              'companion epic Manimekalai was written by Sithalai Sathanar.',
        ),
        _q(
          id: 'qb-tam-003',
          subjectId: _tamil,
          topicId: 'topic-tamil-authors',
          question: 'Who wrote Kambaramayanam?',
          a: 'Ottakoothar',
          b: 'Kambar',
          c: 'Pugazhendi',
          d: 'Sekkizhar',
          answer: 'B',
          explanation: 'Kambar composed the Tamil Ramayana, known as '
              'Kambaramayanam or Ramavataram, in the 12th century.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-tam-004',
          subjectId: _tamil,
          topicId: 'topic-tamil-grammar',
          question: 'Which is the oldest extant work of Tamil grammar?',
          a: 'Nannool',
          b: 'Tholkappiyam',
          c: 'Veerasozhiyam',
          d: 'Ilakkana Vilakkam',
          answer: 'B',
          explanation: 'Tholkappiyam, attributed to Tholkappiyar, is the '
              'oldest surviving Tamil grammar and covers letters, words and '
              'subject matter.',
        ),
        _q(
          id: 'qb-tam-005',
          subjectId: _tamil,
          topicId: 'topic-sangam-literature',
          question: 'Ettuthogai, a Sangam collection, consists of how many '
              'anthologies?',
          a: 'Five',
          b: 'Eight',
          c: 'Ten',
          d: 'Eighteen',
          answer: 'B',
          explanation: 'Ettuthogai means "eight anthologies". Pattuppattu, the '
              'companion collection, comprises ten long poems.',
        ),
        _q(
          id: 'qb-tam-006',
          subjectId: _tamil,
          topicId: 'topic-sangam-literature',
          question: 'In Sangam poetry, what does "Agam" refer to?',
          a: 'War and public life',
          b: 'Love and inner life',
          c: 'Religious devotion',
          d: 'Royal genealogy',
          answer: 'B',
          explanation: 'Agam poetry deals with love and the inner world, while '
              'Puram poetry deals with war, heroism and public life.',
        ),
      ];

  // ==================== GENERAL ENGLISH ====================

  static List<QuestionDto> _englishLanguage() => [
        _q(
          id: 'qb-eng-001',
          subjectId: _english,
          topicId: 'topic-english-vocabulary',
          question: 'Choose the word most nearly similar in meaning to '
              '"ABUNDANT".',
          a: 'Scarce',
          b: 'Plentiful',
          c: 'Fragile',
          d: 'Hidden',
          answer: 'B',
          explanation: 'Abundant means existing in large quantities, so '
              '"plentiful" is the synonym. "Scarce" is its antonym.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-eng-002',
          subjectId: _english,
          topicId: 'topic-english-vocabulary',
          question: 'Choose the word opposite in meaning to "ANCIENT".',
          a: 'Old',
          b: 'Antique',
          c: 'Modern',
          d: 'Historic',
          answer: 'C',
          explanation: '"Ancient" means belonging to the distant past, so its '
              'antonym is "modern". The other options are near-synonyms.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-eng-003',
          subjectId: _english,
          topicId: 'topic-english-vocabulary',
          question: 'What does the idiom "to let the cat out of the bag" mean?',
          a: 'To lose something valuable',
          b: 'To reveal a secret',
          c: 'To escape danger',
          d: 'To start a quarrel',
          answer: 'B',
          explanation: 'The idiom means to disclose a secret, usually by '
              'accident.',
        ),
        _q(
          id: 'qb-eng-004',
          subjectId: _english,
          topicId: 'topic-english-grammar',
          question: 'Choose the correct sentence.',
          a: 'He do not like coffee.',
          b: 'He does not likes coffee.',
          c: 'He does not like coffee.',
          d: 'He not like coffee.',
          answer: 'C',
          explanation: 'With the third person singular, the auxiliary takes '
              'the -s ("does") and the main verb stays in the base form '
              '("like").',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-eng-005',
          subjectId: _english,
          topicId: 'topic-english-grammar',
          question: 'Identify the part of speech of the underlined word: She '
              'sings BEAUTIFULLY.',
          a: 'Adjective',
          b: 'Adverb',
          c: 'Noun',
          d: 'Preposition',
          answer: 'B',
          explanation: '"Beautifully" modifies the verb "sings" and describes '
              'how the action is performed, so it is an adverb.',
          difficulty: 'easy',
        ),
        _q(
          id: 'qb-eng-006',
          subjectId: _english,
          topicId: 'topic-english-grammar',
          question: 'Choose the correct passive form: "The teacher praised the '
              'student."',
          a: 'The student was praised by the teacher.',
          b: 'The student is praised by the teacher.',
          c: 'The student has praised by the teacher.',
          d: 'The student was praising by the teacher.',
          answer: 'A',
          explanation: 'The active sentence is in the simple past, so the '
              'passive uses "was" plus the past participle "praised".',
        ),
      ];
}
