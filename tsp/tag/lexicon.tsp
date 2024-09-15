import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

using Http;
using OpenAPI;

namespace SefariaAPI;

alias DictionaryEntryArray = (
      | JastrowDictionaryEntry
      | StrongsDictionaryEntry
      | BDBDictionaryEntry
      | KleinDictionaryEntry
      | HebrewDictionaryEntry)[];

/**
 * Searches Sefaria lexicon entries (i.e. dictionaries) for the query string passed as `word` to the endpoint.
 * @returns An array of matching words.
 */
@tag("Lexicon")
@route("/api/words/{word}")
@get
op `get_api-words-word`(
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
@get
op `get_api-words-completion-word-lexicon`(
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

/**
 * An array of arrays, each containing two strings. The first is a completion entry in Hebrew without vowels and the second includes vowels.
 */
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
  
  model StrongsDictionaryEntry extends dictionaryEntry {
    strong_number?: string;
    transliteration?: unknown;
    pronunciation?: unknown;
    language_code?: unknown;
    content?: {
      morphology?: string;
      senses?: SenseStrongsDictionaryEntry[];
    };
  }
  
  model BDBDictionaryEntry  extends dictionaryEntry {
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
        definition?: string;
        all_cited?: string;
        form?: string;
        note?: string;
        num?: string;
        occurences?: string;
        pre_num?: string;
      }[];
    };
  }
  
  model HebrewDictionaryEntry  extends dictionaryEntry {
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
        definition?: string;
      }[];
    };
  }
  
  /**
   * An entry from Jastrow’s Dictionary,
   */
  model JastrowDictionaryEntry  extends dictionaryEntry {

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
      morphology?: string;
    };
  }
  
  
  model KleinDictionaryEntry extends dictionaryEntry {
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
      binyan_form?: string[];
    };
    number?: string;
  }