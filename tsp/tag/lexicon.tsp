import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * Searches Sefaria lexicon entries (i.e. dictionaries) for the query string passed as `word` to the endpoint.
 * @returns An array of matching words.
 */
@tag("Lexicon")
@route("/api/words/{word}")
@get
op getLexicon(
  /** A single dictionary entry on Sefaria. */
  word: string,

  /**
   * This parameters refines the search to fine tune based on the `lookup_ref`.
   */
  @query lookup_ref?: string,

  /**
   * This parameters refines the search to limit lookup to only the actual input string.
   */
  @query never_split?: string,

  /**
   * This parameters refines the search to look for substring matches regardless of results for original input. One can pass the values `0` (to indicate false) and `1` (to indicate true).
   */
  @query always_split?: string,

  @query always_consonants?: string,
): DictionaryEntryArray;

/**
 * Serves primarily as an autocompleter, returning potential lexicon entries for a given input.
 *
 * Returns an array of arrays, each containing two strings. The first is a completion entry in Hebrew without vowels and the second includes vowels.
 *
 * @returns Successful response
 */
@tag("Lexicon")
@route("/api/words/completion/{word}/{lexicon}")
@opExample(
  #{
    returnType: #[
      #["אב", "אַב"],
      #["אב", "אֵב"],
      #["אב", "אָב"],
      #["אבד", "אֲבַד"],
      #["אבה", "אבה"],
      #["אבן", "אֶ֫בֶן"],
      #["אגרה", "אִגְּרָה"],
      #["אדין", "אֱדַ֫יִן"],
      #["אדר", "אִדַּר"],
      #["אדר", "אֲדָר"],
      #["אדרגזר", "אֲדַרְגָּזַר"],
      #["אדרזדא", "אַדְרַזְדָּא"],
      #["אדרע", "אֶדְרַע"]
    ],
  },
  #{ title: "result" }
)
@get
op getWordCompletion(
  /** The word or phrase to search for in the lexicons. */
  word: string,

  /**
   * Number of results to return (0 indicates no limit, and is the default)
   */
  @query limit?: integer,

  /**
   * An optional text string matching the name of one of Sefaria's lexicons to limit the search.
   */
  @path lexicon: string,
): wordCompletionAPIResponse[];

alias DictionaryEntryArray = (
  | JastrowDictionaryEntry
  | StrongsDictionaryEntry
  | BDBDictionaryEntry
  | KleinDictionaryEntry
  | HebrewDictionaryEntry)[];

/**
 * An array of arrays, each containing two strings. The first is a completion entry in Hebrew without vowels and the second includes vowels.
 */
@example(#[#["אב", "אַב"]])
model wordCompletionAPIResponse is string[];

/**
 * A single dictionary entry on Sefaria.
 */
model dictionaryEntry {
  /**
   * The main word in the lexicon entry. The one you would look up in the book version.
   */
  headword?: string;

  /**
   * Name of the lexicon from which the entry comes from.
   */
  parent_lexicon?: string;

  parent_lexicon_details?: {};
}

/** A single dictionary entry on Sefaria. */
@example(#{
  headword: "רָאָה",
  parent_lexicon: "BDB Augmented Strong",
  content: #{
    morphology: "v",
    senses: #[
      #{
        definition: "to see,  look at,  inspect,  perceive,  consider",
        senses: #[
          #{
            senses: #[
              #{ definition: "to see" },
              #{ definition: "to see,  perceive" },
              #{ definition: "to see,  have vision" },
              #{
                definition: "to look at,  see,  regard,  look after,  see after,  learn about,  observe,  watch,  look upon,  look out,  find out",
              },
              #{
                definition: "to see,  observe,  consider,  look at,  give attention to, discern,  distinguish",
              },
              #{ definition: "to look at,  gaze at" }
            ],
            grammar: #{ verbal_stem: "Qal" },
          },
          #{
            senses: #[
              #{ definition: "to appear,  present oneself" },
              #{ definition: "to be seen" },
              #{ definition: "to be visible" }
            ],
            grammar: #{ verbal_stem: "Niphal" },
          },
          #{ definition: " to be seen", grammar: #{ verbal_stem: "Pual" } },
          #{
            senses: #[
              #{ definition: "to cause to see,  show" },
              #{
                definition: "to cause to look intently at,  behold,  cause to gaze at",
              }
            ],
            grammar: #{ verbal_stem: "Hiphil" },
          },
          #{
            senses: #[
              #{ definition: "to be caused to see,  be shown" },
              #{ definition: "to be exhibited to" }
            ],
            grammar: #{ verbal_stem: "Hophal" },
          },
          #{
            definition: " to look at each other,  face",
            grammar: #{ verbal_stem: "Hithpael" },
          }
        ],
      }
    ],
  },
  strong_number: "7200",
  transliteration: "râʼâh",
  pronunciation: "raw-aw'",
  language_code: "heb",
  parent_lexicon_details: #{
    name: "BDB Augmented Strong",
    language: "heb.biblical",
    to_language: "eng",
    text_categories: #["Tanakh, Torah", "Tanakh, Prophets", "Tanakh, Writings"],
    source: "Open Scriptures on GitHub",
    source_url: "https://github.com/openscriptures/strongs",
    attribution: "Based on the work of Larry Pierce at the Online Bible",
    attribution_url: "http://www.blueletterbible.org/contact/contact_gen.cfm",
  },
})
model StrongsDictionaryEntry {
  ...dictionaryEntry;
  strong_number?: string;
  transliteration?: unknown;
  pronunciation?: unknown;
  language_code?: unknown;
  content?: {
    morphology?: string;
    senses?: SenseStrongsDictionaryEntry[];
  };
}

/** A single dictionary entry on Sefaria. */
model BDBDictionaryEntry {
  ...dictionaryEntry;

  /**
   * Returns a unique id for this reference that establishes an ordering of references across the whole catalog. The `rid` will change as the ordering of the categories changes, and may begin to overlap with other numbers because of those changes. However, at any point in time the `rid`s will be unique across the catalog. The `rid` is used to sort results from ElasticSearch queries.
   */
  rid?: string;

  /**
   * The corresponding Theological Wordbook of the Old Testament number for this word.
   */
  TWOT?: string;

  /**
   * An array of corresponsing Strong Numbers for this word.
   */
  strong_numbers?: string[];

  /**
   * Indicates if the headword is the Biblical root. (Indicated in print, by a larger printed headword).
   */
  root?: boolean;

  /**
   * A bool indicating the presence of the `‡` symbol in print, demonstrating that the word is peculiar to Biblical Aramaic.
   */
  peculiar?: boolean;

  /**
   * When the same headword has more than one entry with a differen meaning they are offset by the Roman numerals here.
   */
  ordinal?: string;

  /**
   * A count of the number of times the headword appears in the Bible
   */
  occurrences?: numeric;

  /**
   * In some cases the headword has some additional content in print beyond it. That data is included here.
   */
  headword_suffix?: string;

  /**
   * The corresponding Goodrick/Kohlenberger Lexicon number for this headword.
   */
  GK?: string;

  /**
   * A bool indicating the presense of the `†` symbol in print, indicating that all of the occurences of the word are listed as part of this entry
   */
  all_cited?: boolean;

  /**
   * Headword has brackets in print.
   */
  brackets?: boolean;

  /**
   * An array of alternative headwords for the entry
   */
  alt_headwords?: string[];

  /**
   * The previous entry in print.
   */
  prev_hw?: string;

  /**
   * The next entry in print.
   */
  next_hw?: string;

  content?: {
    senses?: {
      /** a definition of this sense of the word */
      definition?: string;

      /** A bool indicating the presense of the `†` symbol in print, indicating that all of the occurences of this sense of the word are listed as part of this entry */
      all_cited?: string;

      /** the grammatical verb form (binyan) of the word */
      form?: string;

      /** an additional note for the entry */
      note?: string;

      /** the string of the numbering of this sense in print (it can be a number, English letter, Roman digits, with period, in parentheses, etc.) */
      num?: string;

      /** number of occurrences of this sense in bible */
      occurences?: string;

      /** In some cases the sense has some additional characters before the entry  (e.g. the word Especially). That data is included here */
      pre_num?: string;
    }[];
  };
}

/** A single dictionary entry on Sefaria. */
model HebrewDictionaryEntry {
  ...dictionaryEntry;

  /**
   * Returns a unique id for this reference that establishes an ordering of references across the whole catalog. This id will change as the ordering of the categories changes, and may begin to overlap with other numbers because of those changes. However, at any point in time these ids will be unique across the catalog. Used to sort results from ElasticSearch queries
   */
  rid?: string;

  /**
   * Cross references to selections in the Sefaria library.
   */
  refs?: ref[];

  /**
   * The previous headword entry from the book.
   */
  prev_hw?: string;

  /**
   * The next headword entry from the book.
   */
  next_hw?: string;

  content?: {
    senses?: {
      /** A definition of this sense of the word */
      definition?: string;
    }[];
  };
}

/**
 * An entry from Jastrow’s Dictionary,
 */
model JastrowDictionaryEntry {
  ...dictionaryEntry;

  /**
   * Returns a unique id for this reference that establishes an ordering of references across the whole catalog. This id will change as the ordering of the categories changes, and may begin to overlap with other numbers because of those changes. However, at any point in time these ids will be unique across the catalog. Used to sort results from ElasticSearch queries
   */
  rid?: unknown;

  quotes?: unknown;

  /**
   * Cross references to selections in the Sefaria library.
   */
  refs?: ref[];

  /**
   * The previous headword entry from the book.
   */
  prev_hw?: unknown;

  /**
   * The next headword entry from the book.
   */
  next_hw?: unknown;

  /**
   * The plural form of the headword.
   */
  plural_form?: unknown;

  language_reference?: unknown;

  /**
   * A string containing the following characters `h.` (Hebrew), `b. h.` (Biblical Hebrew) `ch.` or `Ch.` (Chaldean) indicating the source language of the entry.
   */
  language_code?: unknown;

  /**
   * An array of alternate headwords for the entry. Symbolized in print as those headwords separated by commas after the initial entry.
   */
  alt_headwords?: string[];

  content?: {
    senses?: SenseJastrowDictionaryEntry[];

    /** A description of the morphological form of the word, one of `m., m. pl., f., f. pl., pr. n., pr. n. pl., pr. n. f., pr. n. m., pron., pers. pron.` */
    morphology?: string;
  };
}

/** A single dictionary entry on Sefaria. */
model KleinDictionaryEntry {
  ...dictionaryEntry;

  /**
   * Returns a unique id for this reference that establishes an ordering of references across the whole catalog. This id will change as the ordering of the categories changes, and may begin to overlap with other numbers because of those changes. However, at any point in time these ids will be unique across the catalog. Used to sort results from ElasticSearch queries
   */
  rid?: unknown;

  quotes?: unknown;

  /**
   * Internal references to the Klein dictionary for other entries.
   */
  refs?: ref[];

  /**
   * The previous headword entry from the book.
   */
  prev_hw?: unknown;

  /**
   * The next headword entry from the book.
   */
  next_hw?: unknown;

  /**
   * The plural form of the headword
   */
  plural_form?: unknown;

  language_reference?: unknown;

  /**
   * If not present, it’s Biblical.  Otherwise values could be [PBH, MH, NH, FW] - Post Biblical Hebrew, Middle Hebrew, New Hebrew, Foreign Word.
   */
  language_code?: unknown;

  /**
   * One of [n., adj., adv., m.n., abs., art. , attrib., auxil., comp., copul., c st., def., f., f. n., imper.., Imperf., Indef art., Inf, Interj., Interr., Intr., Neut., Part., Pass., Perf., Possess., p. part., prep., pres part., pres t., p.t.., sing., Subj., Tr.]
   */
  morphology?: unknown;

  /**
   * Alternative spellings of headword
   */
  alt_headwords?: unknown;

  /**
   * The trailing end of the dictionary entry, after the formal definition - may have comparisons to cognates or similar notes
   */
  notes?: unknown;

  /**
   * HTML - list of derivate words - <a> tag wrapped with links to Sefaria entries
   */
  derivatives?: unknown;

  content?: {
    senses?: SenseKleinDictionaryEntry[];

    /** One of [n., adj., adv., m.n., abs., art. , attrib., auxil., comp., copul., c st., def., f., f. n., imper.., Imperf., Indef art., Inf, Interj., Interr., Intr., Neut., Part., Pass., Perf., Possess., p. part., prep., pres part., pres t., p.t.., sing., Subj., Tr.] */
    morphology?: string;
  };
}

model SenseStrongsDictionaryEntry {
  /**
   * A definition of the word
   */
  definition?: unknown;

  grammar?: {
    verbal_stem?: string;
  };
}

model SenseKleinDictionaryEntry {
  /**
   * A definition of the word
   */
  definition?: string;

  grammar?: {
    verbal_stem?: string;
    language_code?: string;

    /** what form the root takes in this binyan */
    binyan_form?: string[];

    morphology?: string;
  };

  /**
   * a number indicating which numbered sense this is
   */
  number?: string;

  /**
   * the plural form of the sense
   */
  plural_form?: string;

  /**
   * The trailing end of the dictionary entry, after the formal definition - may have comparisons to cognates or similar notes
   */
  notes?: string;

  /**
   *  One of [n., adj., adv., m.n., abs., art. , attrib., auxil., comp., copul., c st., def., f., f. n., imper.., Imperf., Indef art., Inf, Interj., Interr., Intr., Neut., Part., Pass., Perf., Possess., p. part., prep., pres part., pres t., p.t.., sing., Subj., Tr.]
   */
  morphology?: string;

  /**
   * If not present, it’s Biblical.  Otherwise values could be [PBH, MH, NH, FW] - Post Biblical Hebrew, Middle Hebrew, New Hebrew, Foreign Word.
   */
  language_code?: string;

  alternative?: string;
}

/**
 * Each meaning of the word is tagged as a `sense` within `senses`
 * Each sense may be preceded by a bolded number which will be tagged as a `number`
 * Each Binyan will also be broken down into `senses`
 */
model SenseJastrowDictionaryEntry {
  /**
   * A definition of the word
   */
  definition?: string;

  grammar?: {
    verbal_stem?: string;
    language_code?: string;

    /** Found in verbs, a binyan is a linguistic alternate use of the word. It will be one of the following: Hiph., Hish., Hith., Hithpalp., Hithpol., Hoph., Hoth., Niph, , Nith., Pa., Pi., Pil., Pilp., Pir., Po., Pol., Polp., Pu., Pul., Pulp., Qal., Shaph., Shiph., Shuph., Tiph., Tuph., Hif., Nif., Hithpa., Af., Ithpa., Ithpe., Nithpa */
    binyan_form?: string[];
  };
  number?: string;
}
