import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

using Http;
using OpenAPI;

/**
 * The Sefaria API endpoints allows live access to Sefaria's structured database of Jewish texts and their interconnections.
 */
@service({
  title: "Sefaria API",
})
@info({
  version: "1.0.0",
  contact: {
    url: "https://www.sefaria.org",
    email: "developers@sefaria.org",
  },
  license: {
    name: "GNU AGPLv3",
    url: "https://www.gnu.org/licenses/agpl.txt",
  },
})

@server("https://www.sefaria.org", "")
namespace SefariaAPI;

/**
 * A string representing a citation to a Jewish text.
 *
 * A valid `Ref` consists of a title string followed optionally by a section string or a segment string.
 *
 * A title string is any one of the known text titles or title variants in the Sefaria Database.
 */
scalar ref extends string;

/**
 * Information about a single text version of a title
 */
model versionData {
  title?: string;
  versionTitle?: string;
  versionSource?: string;
  language?: string;
  status?: string;
  license?: string;
  versionNotes?: string;
  digitizedBySefaria?: string;
  priority?: int32;
  versionTitleInHebrew?: string;
  versionNotesInHebrew?: string;
  extendedNotes?: string;
  extendedNotesHebrew?: string;
  purchaseInformationImage?: string;
  purchaseInformationURL?: string;
  shortVersionTitle?: string;
  shortVersionTitleInHebrew?: string;
  firstSectionRef?: string;
}

/**
 * Full response of the Name API
 */
model nameAPIResponse {
  /**
   * The language of the completion results.
   */
  lang?: "en" | "he";

  /**
   * Returns `true` if the submitted text is a valid Sefaria textual reference
   */
  is_ref?: boolean;

  /**
   * A list of autocompletion responses for the submitted text.
   */
  completions?: string[];

  /**
   * A list of autocompletion response objects for the submitted text along with some information about them.
   */
  completion_objects?: {
    title?: string;
    key?: string;
    type?: string;
    is_primary?: boolean;
    order?: int32;
  }[];

  /**
   * Returns `true` if the submitted text is a book level reference. e.g. (Genesis)
   */
  is_book?: boolean;

  /**
   * Returns true if the submitted text is a `node` in a complex text. (For example, the query `Abarbanel on Torah, Genesis` is a `node` in the `index` of the complex text `Abarbanel on Torah`).
   */
  is_node?: boolean;

  /**
   * Returns `true` if the submitted text is a section `Ref` (e.g. Genesis 4, as opposed to a segment `Ref` such as Genesis 4.1).
   */
  is_section?: boolean;

  /**
   * Returns `true` if the submitted text is a segment level `Ref` (e.g. Genesis 43:3, as opposed to a section `Ref` such as Genesis 43)
   */
  is_segment?: boolean;

  /**
   * Returns `true` if the submitted text is a a ranged `Ref` (one that spans multiple sections or segments.) e.g. `Genesis 4-5`
   */
  is_range?: boolean;

  type?: "ref" | "Topic" | "AuthorTopic" | "PersonTopic" | "User";

  /**
   * If `is_ref` is `true`, this returns the cannonical ref for the submitted text.
   */
  ref?: string;

  /**
   * If `is_ref` is `true`, this returns the URL path to link to the submitted text on [Sefaria.org](sefaria.org)
   */
  url?: string;

  /**
   * If `is_ref` is `true`, this returns the cannonical name of the `index` of the submitted text.
   */
  index?: string;

  /**
   * If the submitted response is a `Ref`, this returns the book it belongs to.
   */
  book?: string;

  internalSections?: int32[];
  internalToSections?: int32[];
  sections?: string[];
  toSections?: string[];
  examples?: unknown[];

  /**
   * Given a reference, this returns the names of the sections and segments at each depth of that text.
   */
  sectionNames?: string[];

  /**
   * Given a `Ref`, this returns the names of the sections and segments at each depth of that text in Hebrew.
   */
  heSectionNames?: string[];

  /**
   * Given a partial `Ref`, this will return an array of strings of possible ways that it might be completed.
   */
  addressExamples?: string[];

  /**
   * Given a partial `Ref`, this will return an array of Hebrew strings of possible ways that it might be completed.
   */
  heAddressExamples?: string[];
}

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
    morphology?: string;
  };
}

/**
 * Expected reponse data from Sefaria's Text API
 */
model textAPIReponse {
  ref?: ref;

  /**
   * The Hebrew `Ref`.
   */
  heRef?: ref;

  /**
   * Whether or not the text is a "complex" text or not.
   *
   * In Sefaria, a complex text is any text which has a more complicated index structure beyond Chapters/Verses, (e.g. the Talmud). There are a variety of structural differences for a complex text, having to do primarily with its `Index`, and the way the data is stored. For more on complex texts, see the documentation here.
   */
  isComplex?: boolean;

  /**
   * The default, or specified text written in LTR characters for the query (Usually English). It is structured as a `JaggedArray` (nested arrays), with the lowest level being an array of strings with some HTML text.
   */
  @oneOf text?: string | string[][] | string[];

  /**
   * The default, or specified text written in RTL characters for the query (Usually Hebrew). It is structured as a JaggedArray (nested arrays), with the lowest level being an array of strings with some html text.
   */
  @oneOf he?: string[] | string;

  versions?: versionData[];
  textDepth?: int32;

  /**
   * An array containing the type names of the sections of this text. The length of sectionNames gives the depth of the structure of this text. For example, Kohelet `(["Chapter", "Verse"])` has depth 2, while Mishneh Torah `(["Book", "Topic", "Section", "Law"])` has depth 4. Comparing this depth to the depth of sections will show if the request was for the lowest level, or a higher level, of the text.
   */
  sectionNames?: string[];

  /**
   * A list which length reflects the depth of the text structure, with string values indicating class names for address types for each level
   */
  addressTypes?: string[];

  lengths?: int32[];
  length?: int32;
  heTitle?: string;
  titleVariants?: string[];
  heTitleVariants?: string[];
  type?: string;
  primary_category?: string;

  /**
   * The title of the book that the response comes from.
   */
  book?: string;

  /**
   * A list of categories that a text belongs to.
   */
  categories?: string[];

  order?: int32[];

  /**
   * An array which corresponds to sectionNames and represents the sections of the text requested. When sectionNames is `["Chapter", "Verse"]` a request for chapter 4 looks like `[4]` while a request for chapter 4, verse 7 would look like `[4, 7]`. _Note, for Talmud, Dafs are represented by a string like "42a" or "12b"_
   */
  sections?: int32[];

  toSections?: int32[];
  isDependant?: boolean;
  indexTitle?: string;
  heIndexTitle?: string;
  sectionRef?: ref;
  firstAvailableSectionRef?: string;
  heSectionRef?: ref;
  isSpanning?: boolean;
  versionTitle?: string;
  versionTitleInHebrew?: string;
  shortVersionTitle?: string;
  shortVersionTitleInHebrew?: string;
  versionSource?: string;
  versionStatus?: string;
  versionNotes?: string;
  extendedNotes?: string;
  extendedNotesHebrew?: string;
  versionNotesInHebrew?: string;

  /**
   * Was the `text` response initially digitized by Sefaria `1` or was it initially generated by another digital publisher `0`
   */
  digitizedBySefaria?: boolean;

  license?: string;
  formatEnAsPoetry?: boolean;
  heVersionTitle?: string;
  heVersionTitleInHebrew?: string;
  heShortVersionTitle?: string;
  heShortVersionTitleInHebrew?: string;
  heVersionSource?: string;
  heVersionStatus?: string;
  heVersionNotes?: string;
  heExtendedNotes?: string;
  heExtendedNotesHebrew?: string;
  heVersionNotesInHebrew?: string;

  /**
   * Was the `he` response initially digitized by Sefaria `1` or was it initially generated by another digital publisher `0`
   */
  heDigitizedBySefaria?: boolean;

  heLicense?: string;
  formatHeAsPoetry?: boolean;
  alts?: unknown[];
  index_offsets_by_depth?: {};

  /**
   * Next segment reference in sequence, if last ref, field will be `null`.
   */
  next?: string | null;

  /**
   * Previous segment reference in sequence, if first ref, field will be `null`.
   */
  prev?: string | null;

  commentary?: unknown[];
  sheets?: unknown[];
  layer?: unknown[];
}

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

model recommendedTopicResponse {
  /**
   * The url slug for the topic.
   */
  slug?: string;

  /**
   * Titles for the topic by language (usually Hebrew & English)
   */
  titles?: {
    en?: string;
    he?: string;
  };

  /**
   * Number of times the topic appears in the references
   */
  count?: int32;
}

/**
 * Manuscript data and metadata JSON.
 */
model ManuscriptJSON {
  /**
   * A unique slug for the given manuscript
   */
  manuscript_slug?: string;

  /**
   * The ID for the specific page within the manuscript being referenced.
   */
  page_id?: string;

  /**
   * The URL to the image of the manuscript, hosted by Sefaria. All URLs will be prefaced by `https://manuscripts.sefaria.org/`
   */
  image_url?: string;

  /**
   * The url to the thumbnail image of the manuscript.
   */
  thumbnail_url?: string;

  /**
   * A manuscript image will in most cases be associated with a range of `refs` (i.e. an image of a page of Tanakh will display multiple verses). The `anchorRef` is that complete range the manuscript is associated with, and will contain within it the specific textual `Ref` passed in as a parameter.
   */
  anchorRef?: string;

  /**
   * An array of strings, where each string is a segment level `Ref` of the `Ref` passed in as a parameter. If a segment level `Ref` is passed in, this array will have a length of 1, and only contain that segment level `Ref`. If the `Ref` passed in is ranged, this array will contain each of the segment level `Ref`s within that range.
   *
   * For example, if someone was searching for manuscript data for `Esther 4.14-15`, the `anchorRefExpanded` would contain `Esther 4.14` and `Esther 4.15`.
   */
  @minItems(1) anchorRefExpanded?: string[];

  /**
   * The version metadata for the manuscript, including the title, Hebrew and English descriptions.
   */
  manuscript: ManuscriptVersionMetaData;
}

/**
 * The specific metadata for the version of the manuscript.
 */
model ManuscriptVersionMetaData {
  /**
   * The unique slug for the manuscript.
   */
  slug: string;

  /**
   * The title of the manuscript.
   */
  title: string;

  /**
   * The manuscript title in Hebrew.
   */
  he_title: string;

  /**
   * The url for the source of the manuscript images.
   */
  source: string;

  /**
   * A description of the manuscript, oftening containing details about the archivists or where the physical manuscript images can be found, as well as other library details.
   */
  description: string;

  /**
   * A Hebrew description of the manuscript, oftening containing details about the archivists or where the physical manuscript images can be found, as well as other library details.
   */
  he_description: string;
}

/**
 * An array of arrays, each containing two strings. The first is a completion entry in Hebrew without vowels and the second includes vowels.
 */
model wordCompletionAPIResponse is string[];

/**
 * The metadata for a given version.
 */
model VersionJSON {
  /**
   * The title of the Index.
   */
  title?: string;

  /**
   * The title of the version
   */
  versionTitle?: string;

  /**
   * A URL pointing to the hardcopy of the text as it can be found in libraries, most usually in our case the NLI (National Library of Israel), but not exclusively.
   */
  versionSource?: string;

  /**
   * The language of the version. The versions on Sefaria are grouped into two language buckets, `en` for languages which read left-to-right (i.e. English, Spanish, German) and `he` for languages which read right-to-left (i.e. Hebrew, Arabic)
   */
  language?: LanguageCode;

  /**
   * The status field contains either the string `"locked"` or an empty string. If `"locked"` is the value of the field, it indicates that the text is locked from future updatees, edits and translations from community members.
   */
  status?: string;

  /**
   * The copyright license for using, and reproducing the text.
   */
  license?: string;

  /**
   * English notes relating to the version, often containing details of authorship, place of printing, and sometimes donor dedications.
   */
  versionNotes?: string;

  /**
   * Whether or not the text was digitized by Sefaria. We have some texts we've been able to add to our database from digital sources, and other texts that we've transfered from print to a digital medium ourselves. This field indicates if Sefaria did the digitization.
   */
  digitizedBySefaria?: boolean;

  /**
   * The priority field is a number which indicates the priority of a version relative to all other existing versions of the same text. A value of `1` indicates the lowest priority, while the highest value among all versions of the text indicate the highest priority.
   *
   * Priority values can also be floating point numbers. The priority field determines how the various available versions of a text will be displayed on the Sefaria website. The texts are displayed to the user in a highest-to-lowest priority order, in many cases offering more complete or higher quality versions of the text before ones of inferior quality.
   */
  priority?: numeric;

  /**
   * The title of the version in Hebrew
   */
  versionTitleInHebrew?: string;

  /**
   * Hebrew notes relating to the version, often containing details of authorship, place of printing, and sometimes donor dedications.
   */
  versionNotesInHebrew?: string;

  /**
   * English extended notes on a version that go beyond the time and place of printing.
   */
  extendedNotes?: string;

  /**
   * Hebrew extended notes on a version that go beyond the time and place of printing.
   */
  extendedNotesHebrew?: string;

  /**
   * A URL pointing to an image of the hard copy of the version associated with the digital copy, for those who would like to purchase a hard copy.
   */
  purchaseInformationImage?: string;

  /**
   * The URL pointing to a website where on can buy a physical copy of the given text version.
   */
  purchaseInformationURL?: string;

  /**
   * An English short title for the version
   */
  shortVersionTitle?: string;

  /**
   * A Hebrew short title for the version
   */
  shortVersionTitleInHebrew?: string;

  /**
   * The first `ref` for this title on a section level (as opposed to the more granular segment level). For example, `Genesis 1` would be the first section level ref of Genesis (as opposed to the segment, `Genesis 1:1`), and `Rashi on Kohelet 1:1` is the first section level ref of `Rashi on Kohelet` (as opposed to the segment level of `Rashi on Kohelet 1:1:1`)
   */
  firstSectionRef?: string;
}

/**
 * The texts on Sefaria are grouped into two language buckets, `en` for languages which read left-to-right (i.e. English, Spanish, German) and `he` for languages which read right-to-left (i.e. Hebrew, Arabic). This field is only ever populated by a string containing the value of either `en` or `he`.
 */
scalar LanguageCode extends string;

/**
 * A response to the Find Refs API
 */
model FindRefsAPIResponse {
  /**
   * Information about any references found in the `title` field of the POST request
   */
  title?: {
    results?: {
      startChar?: int32;
      endChar?: int32;
      text?: string;
      linkFailed?: boolean;
      refs?: ref[];
    }[];
    refData?: {
      RefTitle?: {
        heRef?: string;
        url?: string;
        primaryCategory?: string;
      };
    };
  };

  /**
   * Information about any references found in the `body` field of the POST request
   */
  body?: {
    results?: {
      startChar?: int32;
      endChar?: int32;
      text?: string;
      linkFailed?: boolean;
      refs?: ref[];
    }[];
    refData?: {
      RefTitle?: {
        heRef?: string;
        url?: string;
        primaryCategory?: string;
      };
    };
  };
}

/**
 * A response from the Calendar API
 */
model CalendarAPIResponse {
  /**
   * The datestring for the calendars shown. It should match the values submitted in `year` `month` `day` or should be the current date.
   */
  date?: plainDate;

  /**
   * An IANA timezone name
   */
  timezone?: string;

  calendar_items?: {
    title?: {
      en?: string;
      he?: string;
    };
    displayValue?: {
      en?: string;
      he?: string;
    };
    url?: string;
    ref?: ref;
    heRef?: string;
    order?: int32;
    category?: string;
    extraDetails?: {
      aliyot?: string[];
    };
    description?: {
      en?: string;
      he?: string;
    };
  }[];
}

/**
 * A JSON object containing all of the metadata for a topic object
 */
model TopicJSON {
  /**
   * The unique slug for a given topic.
   */
  slug: string;

  /**
   * An array of JSON objects, each representing an alternative title for the object, in various languages.
   */
  titles: TitlesJSON[];

  /**
   * This is a dictionary containing the keys of naming schemes, and ids of this topic represented in that naming scheme.  It’s used both for canonical names in other naming schemes and temporary storage of names when renaming slugs. All of the data here is for internal use, with the exception of the values `bfo` and `wikidata`. `bfo` refers to [basic formal ontology](https://developers.sefaria.org/docs/topic-ontology), and `wikidata` to the wikidata ontology of topics.
   */
  alt_ids?: {
    _temp_id?: string;
  };

  /**
   * The properties stores optional data relating to the topic, including links (if relevant) to where on can learn more about the topic.
   */
  properties?: TopicPropertyJson;

  /**
   * A description of the topic in English
   */
  description?: BillingualJSON;

  /**
   * A description of the category of this topic
   */
  categoryDescription?: string;

  /**
   * The order in which topics are displayed on the Sefaria website, relative to other topics within their same category.
   */
  displayOrder?: int32;

  /**
   * The number of text sources associated with a topic.
   */
  numSources?: int32;

  /**
   * A boolean representing whether or not the description was published.
   */
  description_published?: boolean;

  /**
   * How the topic was generated, whether by Sefaria, a user on a source sheet, or some other source.
   */
  data_source?: string;

  /**
   * Metadata for images associated with topics.
   */
  image?: TopicImgJSON;

  /**
   * The primary title for a topic.
   */
  primaryTitle?: BillingualJSON;

  /**
   * This field has the possibility of being used to indicate whether or not a title is a transliteration, however the data here is not always consistent or up-to-date. Therefore, it is best to disregard the data in this field, and there are many false negatives.
   */
  primaryTitleIsTransliteration?: BillingualJSON;
}

/**
 * A JSON object containing the image metadata for topics with images.
 */
model TopicImgJSON {
  /**
   * The URL pointing to the image as hosted by Sefaria.
   */
  image_uri?: string;

  /**
   * A JSON object containing the billingual caption data for an image associated with a topic.
   */
  image_caption?: BillingualJSON;
}

/**
 * A JSON object containing billingual text, both `he` and `en` parallel texts.
 */
model BillingualJSON {
  /**
   * The English field for a JSON object representing billingual text.
   */
  en?: string;

  /**
   * The Hebrew field for a JSON object representing billingual text.
   */
  he?: string;
}

/**
 * The JSON object containing information about a topic's properties
 */
model TopicPropertyJson {
  /**
   * A link to the Hebrew page on the website of the National Library of Israel which corresponds to the given topic, so users can learn more.
   */
  heNliLink?: NLILinkJSON;

  /**
   * A link to the English page on the website of the National Library of Israel which corresponds to the given topic, so users can learn more.
   */
  enNliLink?: NLILinkJSON;
}

/**
 * JSON for storing NLI links related to data in the Sefaria database.
 */
model NLILinkJSON {
  /**
   * A link to a corresponding NLI page to learn more.
   */
  value?: string;

  /**
   * The source of the topic data, whether user-created or Sefaria-created.
   */
  dataSource?: string;
}

model CalendarNextReadAPI {
  parasha?: {
    title?: {
      en?: string;
      he?: string;
    };
    displayValue?: {
      en?: string;
      he?: string;
    };
    url?: string;
    ref?: ref;
    heRef?: string;
    order?: int32;
    category?: string;
    extraDetails?: {
      aliyot?: string[];
    };
    description?: {
      en?: string;
      he?: string;
    };
  };
  haftarah?: {
    title?: {
      en?: string;
      he?: string;
    };
    displayValue?: {
      en?: string;
      he?: string;
    };
    url?: string;
    ref?: ref;
    order?: int32;
    category?: string;
  }[];
  date?: utcDateTime;
  he_date?: {
    en?: string;
    he?: string;
  };
}

model APIIndexResponse
  is {
    contents?: {
      contents?: {
        categories?: string[];
        order?: int32;
        primary_category?: string;
        enShortDesc?: string;
        heShortDesc?: string;
        corpus?: string;
        heTitle?: string;
        title?: string;
      }[];
      order?: int32;
      enComplete?: boolean;
      heComplete?: boolean;
      enDesc?: string;
      heDesc?: string;
      enShortDesc?: string;
      heShortDesc?: string;
      heCategory?: string;
      category?: string;
    }[];
    order?: int32;
    enComplete?: boolean;
    heComplete?: boolean;
    enDesc?: string;
    heDesc?: string;
    enShortDesc?: string;
    heShortDesc?: string;
    heCategory?: string;
    category?: string;
  }[];

model searchResponse {
  took?: int32;
  timed_out?: boolean;
  _shards?: {
    total?: int32;
    successful?: int32;
    skipped?: int32;
    failed?: int32;
  };
  hits?: {
    total?: int32;
    max_score?: float64;
    hits?: {
      _index?: string;
      _type?: string;
      _id?: string;
      _score?: float64;
      _source?: {
        ref?: string;
        heRef?: string;
        version?: string;
        lang?: string;
        version_priority?: int32;
        titleVariants?: string[];
        categories?: string[];
        order?: string;
        path?: string;
        pagesheetrank?: float64;
        comp_date?: int32;
        exact?: string;
        naive_lemmatizer?: string;
        hebrew_version_title?: string;
      };
      highlight?: {
        naive_lemmatizer?: string[];
      };
    }[];
  };
  aggregations?: {
    path?: {
      doc_count_error_upper_bound?: int32;
      sum_other_doc_count?: int32;
      buckets?: {
        key?: string;
        doc_count?: int32;
      }[];
    };
  };
}

/**
 * The JSON returned from the `v3` `texts/` endpoint.
 */
model v3TextsJson {
  /**
   * The list of requested `version` objects. It includes all the data that is unique to the requested `versions`.
   *
   */
  versions?: v3TextVersionsJSON[];

  available_versions?: v3AvailableVersionsTextJson[];
  ref?: ref;

  /**
   * Hebrew `Ref` for the segment.
   */
  heRef?: string;

  /**
   * An array which corresponds to sectionNames and represents the sections of the text requested. When sectionNames is `["Chapter", "Verse"]` a request for chapter 4 looks like `[4]` while a request for chapter 4, verse 7 would look like `[4, 7]`. _Note, for Talmud, Dafs are represented by a string like "42a" or "12b"_
   */
  sections?: unknown[];

  toSections?: unknown[];
  sectionRef?: ref;
  heSectionRef?: string;
  firstAvailableSectionRef?: string;
  isSpanning?: boolean;
  spanningRefs?: unknown[];

  /**
   * Next segment reference in sequence, if last ref, field will be `null`.
   */
  next?: string;

  /**
   * Previous segment reference in sequence, if first ref, field will be `null`.
   */
  prev?: string;

  /**
   * The title of the book these versions correspond to.
   */
  title?: string;

  /**
   * The title of the book that the response comes from.
   */
  book?: string;

  heTitle?: string;
  primary_category?: string;
  type?: string;

  /**
   * The book title
   */
  indexTitle?: string;

  /**
   * A list of categories that a text belongs to.
   */
  categories?: string[];

  heIndexTitle?: string;

  /**
   * Whether or not the text is a "complex" text or not.
   *
   * In Sefaria, a complex text is any text which has a more complicated index structure beyond Chapters/Verses, (e.g. the Talmud). There are a variety of structural differences for a complex text, having to do primarily with its Index, and the way the data is stored. For more on complex texts, see the documentation here.
   */
  isComplex?: boolean;

  isDependant?: boolean;
  order?: int32[];

  /**
   * A shortened name of the Index for display in the connection panel (i.e. `Rashi on Genesis` will have a collective title of `Rashi`)
   */
  collectiveTitle?: string;

  /**
   * A Hebrew shortened name of the Index for display in the connection panel (i.e. `רש״י על בראשית` will have a collective title of `רש״י`)
   */
  heCollectiveTitle?: string;

  alts?: unknown[];
  lengths?: int32[];
  length?: int32;

  /**
   * The depth of the text. For example, Genesis will have depth of `2`, since it is comprised of two layers, chapters and verses. Whereas a commentary on Genesis will have a depth of `3`, since it is organized by chapter, verse, and then specific comment on a verse.
   */
  textDepth?: int32;

  /**
   * An array containing the type names of the sections of this text. The length of sectionNames gives the depth of the structure of this text. For example, Kohelet `(["Chapter", "Verse"])` has depth 2, while Mishneh Torah `(["Book", "Topic", "Section", "Law"])` has depth 4. Comparing this depth to the depth of sections will show if the request was for the lowest level, or a higher level, of the text.
   */
  sectionNames?: string[];

  /**
   * A list which length reflects the depth of the text structure, with string values indicating class names for address types for each level
   */
  addressTypes?: string[];

  /**
   * Various alternative titles used for the text.
   */
  titleVariants?: string[];

  heTitleVariants?: string[];
  index_offsets_by_depth?: {};

  /**
   * A list of objects - for any version parameter that has no result there is a readable message and warning code.
   *
   * Codes:
   * `APINoVersion = 101`
   * `APINoLanguageVersion = 102`
   * `APINoSourceText = 103`
   * `APINoTranslationText = 104`
   *
   */
  warnings?: unknown[];
}

/**
 * Data returned in the `available_versions` field of the `v3` `texts` API. This contains all of the available versions for a given text, not just the required versions.
 */
model v3AvailableVersionsTextJson {
  ...v3TextVersionsJSON;

  /**
   * The title of the book.
   */
  title?: string;
}

model v3TextVersionsJSON {
  /**
   * Whether or not the text is `"locked"` for further edits from the community.
   */
  status?: string;

  /**
   * The priority assigned to a version of the text. A higher number will have the text appear higher within the listing of available versions for a specific text on the Sefaria website. (i.e. `Esther A` with a priority of `2`, will appear before `Esther B`, with a priority of `1`)
   */
  priority?: float32;

  /**
   * The license for the text, in terms of copyright, and distribution.
   */
  license?: string;

  /**
   * Notes on the version
   */
  versionNotes?: string;

  /**
   * A boolean indicating whether or not the text (or portions of it) are formatted as poetry.
   */
  formatAsPoetry?: boolean;

  /**
   * An indicator of whether or not Sefaria digitized the text, versus acquiring an already digital copy of a text.
   */
  digitizedBySefaria?: boolean;

  method?: string;
  heversionSource?: string;

  /**
   * URl for the version
   */
  versionUrl?: string;

  versionTitleInHebrew?: string;
  versionNotesInHebrew?: string;
  shortVersionTitle?: string;
  shortVersionTitleInHebrew?: string;
  extendedNotes?: string;
  extendedNotesHebrew?: string;

  /**
   * A URL pointing to an image of the hardcopy text available for purchase.
   */
  purchaseInformationImage?: string;

  /**
   * A URL pointing to where one can purchase a hardcopy of this text.
   */
  purchaseInformationURL?: string;

  hasManuallyWrappedRefs?: string;

  /**
   * The [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) language code for the language of the text. We default to 2 letter codes when available, and 3 letter codes when they are not.
   */
  actualLanguage?: string;

  /**
   * The overarching family for the specific language detailed in `actualLanguage`. For example, `Arabic` would be the overarching family for `judeo-arabic`.
   */
  languageFamilyName?: string;

  isSource?: boolean;

  /**
   * Indicates whether or not this version of the text is determined as the primary version in the Sefaria database.
   */
  isPrimary?: boolean;

  /**
   * The direction of the text, either `ltr` (left-to-right) or `rtl` (right-to-left). Examples of `ltr` languages include English, French and German. Examples of `rtl` languages are Hebrew and Arabic.
   */
  direction?: string;

  /**
   * A holdover from the `v2` API which will eventually be deprecated. This used to indicate the direction of the text, with `en` indicating texts written from left-to-right, and `he` indicating texting written from right-to-left.
   */
  language?: string;

  /**
   * The original source of the digital text.
   */
  versionSource?: string;

  /**
   * The English title of the Version of text.
   */
  versionTitle?: string;

  /**
   * An array of strings containing the text of the specific version.
   *
   * If a segment `Ref` was passed, the array returned will be one-dimensional and contain a string with the specific segment level text.
   *
   * If a bottom level section `Ref` was passed, the array returned will be a two-dimensional array, a list of lists of strings. The outer layer of the array represents the section, and the inner arrays represent the segments.
   */
  text?: string[];

  /**
   * The first available `Ref` to the section of text passed in the API.
   */
  firstSectionRef?: string;
}

/**
 * A single link returned by the link (and related[?]) APIs
 */
model LinkObj {
  _id?: string;

  /**
   * The cannonical title of the text in the Sefaria library.
   */
  index_title?: string;

  /**
   * The primary category this ref belongs to on Sefaria.
   */
  category?: string;

  /**
   * An arbitrary string assigned to the connection to identify it. Most commonly `commentary`, `reference`, or an empty string.
   */
  type?: string;

  ref?: ref;

  /**
   * The submitted `ref` in the GET request at times may fall within a more encompassing ranged ref that includes multiple text segments. The `anchorRef` is that complete range the that the link is associated with, and will contain within it the specific `ref` that was passed.
   */
  anchorRef?: string;

  /**
   * An array of strings, where each string is a segment level `ref` of the `ref` passed in as a parameter. If a segment level `ref` is passed in, this array will have a length of 1, and only contain that segment level `ref`. If the `ref` passed in is ranged, this array will contain each of the segment level `ref`s within that range.
   *
   * For example, if someone was searching for links for `Esther 4.14-15`, the `anchorRefExpanded` would contain `Esther 4.14` and `Esther 4.15`.
   */
  @minItems(1) anchorRefExpanded?: string[];

  /**
   * The connecting link for the submitted `ref`
   */
  sourceRef?: ref;

  sourceHeRef?: ref;
  anchorVerse?: int32;
  sourceHasEn?: boolean;

  /**
   * The estimated year of completion of the work according to the Gregorian calendar. If its length is zero the completion date is unknown. If its length is one, then the completion date is that single year. If its length is 2 then the date is a potential range with the first int in the array is the lower end of the range and the latter the higher.
   */
  compDate?: int32[];

  commentaryNum?: float64;
  collectiveTitle?: {
    en?: string;
    he?: string;
  };

  /**
   * The default text written in RTL characters for the query (Usually Hebrew). It is structured as a JaggedArray (nested arrays), with the lowest level being an array of strings with some html text.
   *
   */
  he?: string;

  /**
   * The title of the work in English for where the default `he` text came from.
   */
  heVersionTitle?: string;

  /**
   * A string of text documenting the license for the text in Hebrew.
   */
  heLicense?: string;

  /**
   * The title of the work in Hebrew for where the default `he` text came from.
   */
  heVersionTitleInHebrew?: string;

  /**
   * The default text written in LTR characters for the query (Usually English). It is structured as a JaggedArray (nested arrays), with the lowest level being an array of strings with some html text.
   */
  text?: unknown[];

  /**
   * A descriptive string which describes what version of a text this is. Is it from a particular printing or edition of a book? An online resource? This string should describe it in English
   */
  versionTitle?: string;

  /**
   * A string of text documenting the license for the text in English.
   */
  license?: string;

  /**
   * A descriptive string which describes what version of a text this is. Is it from a particular printing or edition of a book? An online resource? This string should describe it in Hebrew.
   */
  versionTitleInHebrew?: string;
}

model TopicGraphJSON {
  /**
   * Array of topics
   */
  topics?: TopicJSON[];

  links?: TopicGraphLinkJSON[];
}

model TopicGraphLinkJSON {
  /**
   * Slug of the `toTopic` (i.e. the topic to which the link connects to, usually the slug passed as `topic_slug` to the `api/topic-graph` endpoint).
   */
  toTopic?: string;

  /**
   * The type of the link, based on the relationship within our ontology. Many links has an `is-a` relationship (such as `Genesis` `is-a` `Book`), but other topic-to-topic links have a variety of other types documented [here](https://developers.sefaria.org/docs/topic-ontology#overview-of-sefaria-link-types).
   *
   * Some examples include `child-of`, `parent-of`, `sibling-of` etc.
   */
  linkType?: string;

  /**
   * Class of the link `intraTopic` (a link from topic-to-topic) or `refTopic` (a link from a topic-to-ref).
   */
  class?: "refTopic" | "intraTopic";

  /**
   * Source where the topic link originated from.
   */
  dataSource?: string;

  /**
   * Slug of the `fromTopic` (i.e. the topic from which the link originates).
   */
  fromTopic?: string;

  /**
   * A dictionary containing information regarding the links in common, as well as the to and from `tfIdf` scores. To learn more about the [tfIdf](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) algorithm.
   */
  order?: OrderJSON;
}

model OrderJSON {
  linksInCommon?: int32;
  toTfidf?: int32;
  fromTfidf?: int32;
}

/**
 * Response to the random-by-topic API endpoint.
 */
model RandomByTopicJSON {
  /**
   * The `Ref` of the text randomly selected, which is connected to one of the recently popular topics.
   */
  ref?: string;

  /**
   * The topic attached to the `Ref` returned.
   */
  topic?: RandomByTopicTopicJSON;

  /**
   * The `Ref` in a format appropriate for a URL, with spaces replaced with `.` etc.
   */
  url?: string;
}

/**
 * Topic JSON for the `random-by-topic/` endpoint.
 */
model RandomByTopicTopicJSON {
  /**
   * The unique slug for a given topic.
   */
  slug: string;

  /**
   * An array of JSON objects, each representing an alternative title for the object, in various languages.
   */
  titles?: TitlesJSON;

  /**
   * This is a dictionary containing the keys of naming schemes, and ids of this topic represented in that naming scheme.  It’s used both for canonical names in other naming schemes and temporary storage of names when renaming slugs. All of the data here is for internal use, with the exception of the values `bfo` and `wikidata`. `bfo` refers to [basic formal ontology](https://github.com/BFO-ontology/BFO#implementations), and `wikidata` to the wikidata ontology of topics.
   */
  alt_ids?: unknown;

  /**
   * A description of the category of this topic
   */
  categoryDescription?: string;

  /**
   * A topic which will be included in our results from the `random-by-topic` endpoint.
   */
  good_to_promote?: boolean;

  /**
   * The number of text sources associated with a topic.
   */
  numSources?: integer;

  /**
   * A boolean representing whether or not the description was published.
   */
  description_published?: boolean;

  /**
   * How the topic was generated, whether by Sefaria, a user on a source sheet, or some other source.
   */
  data_source?: string;

  /**
   * The primary title for a topic.
   */
  primary_title?: BillingualJSON;

  /**
   * A description of the topic in English
   */
  description?: BillingualJSON;
}

/**
 * Response from the ref-topic-links endpoint
 */
model RefTopicLinksJSON {
  /**
   * The type of the link, based on the relationship within our ontology. Many links has an `is-a` relationship (such as `Genesis` `is-a` `Book`), but other topic-to-topic links have a variety of other types documented  [here](https://developers.sefaria.org/docs/topic-ontology#overview-of-sefaria-link-types).
   *
   * Some examples include `child-of`, `parent-of`, `sibling-of` etc.
   */
  linkType?: string;

  /**
   * A classification of the link as either `refTopic` (i.e. a ref to a topic) or `intraTopic` (topic-to-topic). In this case, it would be expected that all returned topic links would be of type `refTopic`.
   */
  class?: "refTopic" | "intraTopic";

  /**
   * Where the topic link originated from (i.e. was it added to a sheet and generated by Sefaria users, or was it created by the Sefaria learning team?)
   */
  dataSource?: DataSourceJSON;

  /**
   * Is this ref-to-topic link one that was generated by a user-created source sheet?
   */
  is_sheet?: boolean;

  /**
   * This JSON includes the various metrics that are relevant for ordering the link on a topics page. We use these metrics at [Sefaria.org](sefaria.org) to change the order on the topics page.
   */
  order?: OrderTopicLinkJSON;

  /**
   * JSON containing descriptions for a given topic in various languages. Each language contains a `title` for the topic description, as well as a `prompt` which previews the source and asks questions to help the user engage with the text.
   */
  descriptions?: {
    en?: {
      title?: string;
      prompt?: string;
    };
  };

  /**
   * The title of the topic.
   */
  topic?: string;

  /**
   * The `Ref` the topic is connected to, which should overlap with the requested `Ref` passed through the endpoint. For example, if someone queries for `Bamidbar 28:21`, one of the topics returned is `passover` which has an `anchorRef` of `Numbers 28:16-24` - a range overlapping with our desired `Ref`.
   */
  anchorRef?: string;

  /**
   * If the `anchorRef` is a ranged `Ref` (i.e. containing more than a single segment), then this is a list of strings, with each string being one of single segment level `Ref`s that together comprise the range. So for example, the `anchorRefExpanded` of `Exodus 1:1-2` would be `["Exodus 1:1", "Exodus 1:2"]`.
   */
  anchorRefExpanded?: string[];
}

/**
 * JSON containing the information as to the source of the data for a given ref-to-topic link.
 */
model DataSourceJSON {
  /**
   * English title of the data source.
   */
  en?: string;

  /**
   * Hebrew title of the data source.
   */
  he?: string;

  /**
   * Unique slug describing the data source.
   */
  slug?: string;
}

/**
 * This JSON includes the various metrics that are relevant for ordering the link on a topics page. We use these metrics at [Sefaria.org](sefaria.org) to change the order on the topics page.
 */
model OrderTopicLinkJSON {
  /**
   * Results of the [tfidf algorithm](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) run on the `Ref`s within a given topic, as another metric for evaluating the relevance of a given source on a topic page.
   */
  tfidf?: float64;

  /**
   * The number of datasources which connect this `Ref` to the topic. A value of `2` will occur when two sources (i.e. `aspaklaria` and `sefaria sheets` both have connections between this `Ref` and this topic.)
   */
  numDatasource?: int32;

  /**
   * This topic is available in a list of languages represented as strings with their language code.
   */
  availableLangs?: string[];

  /**
   * The date when the book referenced in the `Ref` was composed. Negative numbers indicate the work was composed BCE, whereas positive numbers indicate the book was composed CE.
   */
  comp_date?: int32;

  /**
   * Unique ID for the `order` JSON.
   */
  order_id?: string;

  /**
   * `PageRank`. Sefaria calculates `PageRank` for the sources on a given topic page using the internal Sefaria links to create a link graph and then running the [PageRank algorithm](https://en.wikipedia.org/wiki/PageRank) on that. Sources with higher `PageRank` are considered to be more centrally linked and more relevant.
   */
  pr?: float64;

  /**
   * This field is used for manually ordering a source on a topics page. It has a separate order value for each language.
   */
  curatedPrimacy?: {
    en?: int32;
    he?: int32;
  };
}

/**
 * Term JSON returned to a query for a Term.
 */
model TermsJSON {
  /**
   * The name of the `Term`. Since a `Term` is a shared title node that can be referenced and used by many different `Index` nodes, the `name` field is critical as it contains the shared title.
   */
  name: string;

  /**
   * Alternative titles for the term in Hebrew and English.
   */
  titles?: TitlesJSON[];

  /**
   * A shared `scheme` for a group of terms.
   */
  scheme?: string;

  /**
   * Terms that share a `scheme` can be ordered within that `scheme`. So for example, _Parshiyot_ within the `Parasha` scheme can be ordered as per the order of the _Parshiyot_.
   */
  order?: int32;

  /**
   * For a _Parasha_, this is the Sefaria `Ref` which correlates to this _Parasha_ in the text. For example, _Parshat Noah_ corresponds to the ranged `Ref` of `"Genesis 6:9-11:32"`.
   */
  ref?: ref;

  /**
   * The category of a specific term.
   */
  category?: string;
}

/**
 * Alternative title for a topic, along with the language code representing the language of the given title.
 */
model TitlesJSON {
  /**
   * The text of the title
   */
  text?: string;

  /**
   * The language of the title, either `en` or `he`.
   */
  lang?: string;

  /**
   * A field depicting whether or not the title is the primary title. Note: For any given topics, one should expect two titles with this field present and set to `true`, an English and a Hebrew primary title. The English value with `primary` set to `true` will match the string value of the `primaryTitle` field on topic.
   */
  Primary?: boolean;
}

model RelatedJSON {
  /**
   * An array of JSON containing the metadata for links to the reference.
   */
  links?: RelatedLinkJSON[];

  /**
   * All public source sheets linked to a given `Ref` or containing that `Ref` on the sheet.
   */
  sheets?: SheetsJSON[];

  /**
   * Any notes a user has on a given `Ref`. **Note:** This data is only available for logged-in users to view their own notes on a text. This field will always present as an empty array for third party developers.
   */
  notes?: unknown[];

  /**
   * Webpages related to the `Ref`.
   */
  webpages?: WebPagesJSON[];

  /**
   * Topics related to a given `Ref`.
   */
  topics?: RelatedTopicJSON[];

  /**
   * An array of manuscript objects containing data of related manuscripts.
   */
  manuscripts?: ManuscriptJSON[];

  /**
   * An array of JSON containing any media related to the `Ref`.
   */
  media?: MediaJSON[];
}

/**
 * JSON containing metadata for media linked to `Ref`s on [Sefaria](sefaria.org)
 */
model MediaJSON {
  /**
   * The URL for the media.
   */
  media_url?: string;

  /**
   * Source of the media.
   */
  source?: string;

  /**
   * Hebrew title of the media source.
   */
  source_he?: string;

  /**
   * Start time of the media associated with this `Ref`.
   */
  start_time?: string;

  /**
   * End time of the portion of the associated media which correlates to this `Ref`.
   */
  end_time?: string;

  /**
   * The `Ref` in the query.
   */
  anchorRef?: ref;

  /**
   * The license on the media.
   */
  license?: string;

  /**
   * Website of the source.
   */
  source_site?: string;

  /**
   * A description of the associated media in English.
   */
  description?: string;

  /**
   * A description of the associated media in Hebrew.
   */
  description_he?: string;
}

/**
 * A JSON object containing the metadata for external webpages linked to this Sefaria `Ref`.
 */
model WebPagesJSON {
  /**
   * URL to the related article on the webpage.
   */
  url?: string;

  /**
   * Title of the webpage
   */
  title?: string;

  /**
   * All textual references found on this webpage which link to various Sefaria `Ref`s.
   */
  refs?: ref[];

  /**
   * Description of the article.
   */
  description?: string;

  /**
   * Number of hits by the Sefaria linker.
   */
  linkerHits?: int32;

  /**
   * Domain of the webpage
   */
  domain?: string;

  /**
   * Name of the webpage
   */
  siteName?: string;

  /**
   * Favicon of the external webspage
   */
  favicon?: string;

  authors?: string;
  articleSource?: string;

  /**
   * The `Ref` connecting this webpage to the queried `Ref`.
   */
  anchorRef?: ref;

  /**
   * If the `anchorRef` is a ranged `Ref`, this is an array of `Refs` containing each of the segments contained within that range. So for example, if `anchorRef` is Genesis 1:1-2, then `anchorRefExpanded` will be `["Genesis 1:1", "Genesis 1:2"]`.
   */
  anchorRefExpanded?: ref[];
}

/**
 * JSON containing metadata relating for a given source sheet on [Sefaria](sefaria.org).
 */
model SheetsJSON {
  /**
   * the Sefaria User ID of the sheet's owner.
   */
  owner?: int32;

  /**
   * The unique `id` for the source sheet.
   */
  _id?: string;

  /**
   * The `id` of the sheet. This is used in the URL to retrieve sheets, for example, a sheet with an `id` of 1, would be accessible on [Sefaria](sefaria.org) at [sefaria.org/sheets/1](sefaria.org/sheets/1).
   */
  id?: string;

  /**
   * Is this sheet public.
   */
  public?: boolean;

  /**
   * Title of the Source Sheet.
   */
  title?: string;

  /**
   * URL to this source sheet.
   */
  sheetUrl?: string;

  /**
   * The Sefaria reference that connects this sheet to the submitted `ref`
   */
  anchorRef?: ref;

  /**
   * An array containing the individual segments `Ref`s which comprise the `anchorRef`.
   *
   * Example 1: Ranged `Ref`
   * If the `anchorRef` is `Genesis 2:14-16`, the `anchorRefExpanded` is `["Genesis 2:14", "Genesis 2:15", "Genesis 2:16"]`.
   *
   * Example 2: Segment Ref
   * If the `anchorRef` itself is a segment `Ref`, the `anchorRefExpanded` will contain that identical value. For example, `anchorRef` of `Genesis 2:11` will  have an `anchorRefExpanded` of `["Genesis 2:11"]`
   */
  anchorRefExpanded?: ref[];

  /**
   * A JSON object containing document level options related to how this source sheet should be displayed in Sefaria's Source Sheet editor.
   */
  options?: {
    numbered?: boolean;
    boxed?: boolean;
    assignable?: boolean;
    bsd?: boolean;
    language?: "blingual" | "hebrew" | "english";
    layout?: string;
    langLayout?: string;
    divineNames?: string;
    highlightMode?: int32;
    collaboration?: string;
  };

  collectionTOC?: string;

  /**
   * Name of the owner of the sheet.
   */
  ownerName?: string;

  /**
   * Some source sheets are made by copying another users. If this is one of them, the original owner's user ID will be listed here.
   */
  via?: string;

  /**
   * Some source sheets are made by copying another users. If this is one of them, the original owner's display name will be listed here.
   */
  viaOwnerName?: string;

  /**
   * Some source sheets are created as assignments by a teacher to be completed by students. If this is one of those sheets the name of the assigner will be found here.
   */
  assignerName?: string;

  /**
   * Some source sheets are made by copying another users. If this is one of them, the path to the original owner's profile page will be listed here.
   */
  viaOwnerProfileUrl?: string;

  /**
   * Some source sheets are created as assignments by a teacher to be completed by students. If this is one of those sheets this will be the URL path to their profile.
   */
  assignerProfileUrl?: string;

  /**
   * The URL Path that will link to a user's profile on the Sefaria site.
   */
  ownerProfileUrl?: string;

  /**
   * Sheet owner image.
   */
  ownerImageUrl?: string;

  /**
   * a string indicating whether the sheet is `public` or `unlisted`
   */
  status?: "public" | "unlisted";

  /**
   * Number of source sheet views.
   */
  views?: int32;

  /**
   * Topics linked to the source sheet.
   */
  topics?: SheetTopicJSON[];

  /**
   * An array of user IDs who have favorited or liked this source sheet.
   */
  likes?: unknown[];

  /**
   * A user generated description of the source sheet
   */
  summary?: string;

  /**
   * Some source sheets are made by copying another users. If so, an attribution field will be created and displayed here.
   */
  attribution?: string;

  /**
   * Previously a source sheet flagged with `is_featured` would be promoted throughout the site in various places. This behavior was removed in 2022 but some of the data remains.
   */
  is_featured?: boolean;

  /**
   * This will always return `Sheets`
   */
  category?: string;

  type?: string;
}

model SheetTopicJSON {
  /**
   * Slug of the topic
   */
  slug?: string;

  /**
   * How the user typed the topic
   */
  asTyped?: string;

  /**
   * Hebrew topic title
   */
  he?: string;

  /**
   * English topic title
   */
  en?: string;
}

/**
 * The link JSON returned as part of results for the related API endpoint.
 */
model RelatedLinkJSON {
  _id?: string;

  /**
   * English title of the linked work.
   */
  index_title?: string;

  /**
   * Category of the type of link, for example a link between `Rashi on Exodus` and `Exodus` would have a category of `Commentary`.
   */
  category?: string;

  type?: string;

  /**
   * Specific `Ref` of the segment which is linked to the queried `anchorRef`.
   */
  ref?: ref;

  /**
   * The submitted ref in the GET request at times may fall within a more encompassing ranged `Re`f that includes multiple text segments. The `anchorRef` is that complete range the that the link is associated with, and will contain within it the specific ref that was passed.
   */
  anchorRef?: ref;

  /**
   * An array of strings, where each string is a segment level `Ref` of the `Ref` passed in as a parameter. If a segment level `Ref` is passed in, this array will have a length of 1, and only contain that segment level `Ref`. If the `Ref` passed in is ranged, this array will contain each of the segment level `Ref`s within that range.
   *
   * For example, if someone was searching for links for Esther 4.14-15, the `anchorRefExpanded` would contain Esther 4.14 and Esther 4.15.
   */
  anchorRefExpanded?: ref[];

  sourceRef?: string;

  /**
   * Hebrew `Ref` of the linked source.
   */
  sourceHeRef?: string;

  anchorVerse?: int32;

  /**
   * Does the source have an English translation?
   */
  sourceHasEn?: boolean;

  /**
   * Date of the two books in the link were composed. Negative values indicate dates BCE.
   */
  compDate?: int32[];

  commentaryNum?: float64;
  collectiveTitle?: {
    en?: string;
    he?: string;
  };

  /**
   * Hebrew title of the linked work
   */
  heTitle?: string;
}

/**
 * Topic JSON returned in the `topic` field of the related API endpoint.
 */
model RelatedTopicJSON {
  /**
   * The type of link between the topic and the `Ref`. For more on Sefaria's topic ontology, see [here](https://developers.sefaria.org/docs/topic-ontology).
   */
  linkType?: string;

  /**
   * A classification of the link as either `refTopic` (i.e. a ref to a topic) or `intraTopic` (topic-to-topic). In this case, it would be expected that all returned topic links would be of type `refTopic`.
   */
  class?: "refTopic" | "intraTopic";

  /**
   * JSON containing the information as to the source of the data for a given ref-to-topic link.
   */
  dataSource?: DataSourceJSON;

  /**
   * Is this ref-to-topic link one that was generated by a user-created source sheet?
   */
  is_sheet?: boolean;

  /**
   * How the topic was generated (i.e. by a user, aspaklaria, Sefaria staff)
   */
  generatedBy?: string;

  /**
   * This JSON includes the various metrics that are relevant for ordering the link on a topics page. We use these metrics at [Sefaria.org](sefaria.org) to change the order on the topics page.
   */
  order?: OrderTopicLinkJSON;

  /**
   * Topic slug
   */
  topic?: string;

  /**
   * The title of the topic in Hebrew (`he`) and English (`en`).
   */
  title?: {};

  /**
   * A boolean value for the `he` and `en` fields inside the title JSON, indicating whether or not either translation is a transliteration.
   */
  titleIsTransliteration?: {};

  /**
   * JSON containing descriptions for a given topic in various languages. Each language contains a title for the topic description, as well as a prompt which previews the source and asks questions to help the user engage with the text.
   */
  description?: {};

  /**
   * The `Ref` in the query.
   */
  anchorRef?: ref;

  /**
   * The segment `Ref`s within the `anchorRef`.
   */
  anchorRefExpanded?: ref[];
}

/**
 * The full mongo record JSON from the database for a given Sefaria `Index`.
 */
model RawIndexJSON {
  /**
   * Title of the work.
   */
  title?: string;

  /**
   * The categories within which this text falls. *Note:* The order of the strings in the array is significant. The categories should go from most general at position `0`, to most specific.
   */
  categories?: string[];

  /**
   * The structure of the Index within the Sefaria specific schema for texts.
   */
  schema?: RawIndexSchemaJSON;

  /**
   * Alternative structures for the text.
   */
  alt_structs?: RawIndexAltStructsJSON;

  /**
   * Which structure of the available structures is default.
   */
  default_struct?: string;

  exclude_structs?: string[];
  order?: int32[];

  /**
   * Author(s) of the text.
   */
  authors?: unknown[];

  /**
   * A longer English description of the index.
   */
  enDesc?: string;

  /**
   * A short English description of the index.
   */
  enShortDesc?: string;

  /**
   * A short description of the text in Hebrew.
   */
  heShortDesc?: string;

  /**
   * Date(s) of publication. *Note:* A negative value indicates the work was published BCE.
   */
  pubDate?: int32[];

  /**
   * This field tells you if `compDate` is list of 2 integers (i.e. is a range) because much of the time `compDate` will be a range only when there's an error margin in our knowledge of the completion date.
   */
  hasErrorMargin?: boolean;

  /**
   * Date(s) of text composition.
   *
   * **Notes:**
   * - A negative value indicates BCE.
   * - The integers are Gregorian years.
   * - If it has 2 values, that is the range of years it was composed.
   * - If has 1 value, that is the year it was composed.
   * - If it has 0, we don’t know the year it was composed.
   */
  compDate?: int32[];

  /**
   * Location of composition
   */
  compPlace?: string;

  /**
   * Location of publication
   */
  pubPlace?: string;

  /**
   * Era of the text. The value will be represented by one of the following codes.
   *
   * ```
   *     "Gaonim": "GN",
   *     "Rishonim": "RI",
   *     "Achronim": "AH",
   *     "Tannaim": "T",
   *     "Amoraim": "A",
   *     "Contemporary": "CO"
   * ```
   */
  era?: string;

  /**
   * Indicator of whether ot not this text is cited by others in our library. Functionally, this means we will pick up links to this text when cited in other texts.
   */
  is_cited?: boolean;

  corpora?: string[];
}

/**
 * Schema JSON for an Index.
 */
model RawIndexSchemaJSON {
  /**
   * The type of node. Nodes can either be `SchemaNodes` or `JaggedArray` nodes. A `JaggedArray` is a nested array (2D or 3D), whereas a `SchemaNode` is a node with children of either type. All tree leaves in the Sefaria text tree must be `JaggedArray` nodes.
   */
  nodeType?: "JaggedArrayNode" | "SchemaNode";

  /**
   * The depth of a text. For example, a book of Tanakh with chapters and verses has a depth 2, whereas a commentary on that book of Tanakh, with multiple comments on each verse (so a chapter-verse-comment structure) would have a depth of 3.
   */
  depth?: int32;

  /**
   * A list which length reflects the depth of the text structure, with string values indicating class names for address types for each level.
   */
  addressTypes?: string[];

  /**
   * An array containing the type names of the sections of this text. The length of `sectionNames` gives the depth of the structure of this text. For example, Kohelet (`["Chapter", "Verse"]`) has depth 2, while Mishneh Torah (`["Book", "Topic", "Section", "Law"]`) has depth 4. Comparing this depth to the depth of sections will show if the request was for the lowest level, or a higher level, of the text.
   */
  sectionNames?: string[];

  /**
   * This data is used for the linker.
   */
  match_templates?: unknown[];

  /**
   * The lengths of the text at each level of depth. For example, a text of depth 2 will have an array with two values, the first representing the number of sections, and the second value representing the number of verses. So, if Genesis has lengths, it's array will look like this `[50, 1533]`. This is interpreted to mean the Genesis Index has 50 chapters (sections) and 1533 verses (segments).
   *
   * A depth-3 text (a commentary, for example) will have three values, representing the number of super sections, sections, and segments.
   */
  lengths?: int32[];

  referenceableSections?: boolean[];

  /**
   * Titles for the index.
   */
  titles?: TitlesJSON[];

  /**
   * Unique key for the text, usually matches the `Index` title.
   */
  key?: string;

  checkFirst?: {
    he?: string;
    en?: string;
  };
}

/**
 * The JSON returned for the alt structs of an Index.
 */
model RawIndexAltStructsJSON {
  Chapters?: RawIndexNodesJSON;
}

model RawIndexAltStructNodeJSON {
  /**
   * The type of node
   */
  nodeType?: string;

  /**
   * The depth of the Node.
   */
  depth?: int32;

  /**
   * The specific ranged `Ref` that corresponds to this section of text.
   */
  wholeRef?: ref;

  includeSections?: boolean;

  /**
   * Data used for linker purposes.
   */
  match_templates?: {
    term_slugs?: string[];
    scope?: string;
  }[];

  /**
   * The numeric equivalent of the section. So for example, if chapter two of Masechet Pesachim is referred to as `כל שעה`, the `numeric_equivalent` is 2.
   */
  numeric_equivalent?: int32;

  /**
   * Titles for this section of text.
   */
  titles?: TitlesJSON[];
}

model RawIndexNodesJSON {
  nodes?: RawIndexAltStructNodeJSON[];
}

/**
 * A properly formatted POST request for the Find Refs API
 */
model FindRefsPOSTRequest {
  /**
   * Initially designed for websites, this API expects the `text` field to contain both a `body` and a `title`. When parsing arbitrary text feel free to just use `body` and pass an empty string `''` to `title`
   */
  text: {
    body?: string;
    title?: string;
  };

  /**
   * Either `he` or `en`. If not included, it will default to one based on the number of Hebrew or Latin characters in the `body` of the `text`.
   */
  lang: "he" | "en";
}

model SearchPOSTData {
  /**
   * List of fields to aggregate on. Common fields are `path` for the `text` type and `group` or `topics` for the `sheet` type
   */
  aggs?: string[];

  /**
   * The field you want to query. Common fields to query are `exact` or `naive_lemmatizer` for the `text` and `merged` indices. For querying the `sheet` index, commonly you'll query the `content` field
   */
  field?: string;

  /**
   * Must be the same length as `filters`. Each entry specifies the field to apply the corresponding filter in `filters`. For queries of type `text` this has no effect since there's only one field to filter text queries on (`path`. this field is explained in `filters`). For `sheet` queries, the following fields can appear in `filter_fields`: `collections` (corresponds to the collections that the sheet is in), `topics_en` (corresponds to the topics for this sheet, translated into English), `topics_he` (corresponds to the topics for this sheet, translated into Hebrew).
   */
  filter_fields?: unknown[];

  /**
   * A list of filters to filter results. These filters cannot include RegEx. Any RegEx characters will be escaped. Each filter is applied to the corresponding field in the `filter_fields` list. E.g. if filters is `["Passover", "Torah Talks"]` and `filter_fields` is `["topics_en", "collections"]` then the `"Passover"` filter will be applied to the `"topics_en"` field and the `"Torah Talks"` filter will be applied to the `"collections"` field. For `text` queries, filters always applies to the `path` field of documents. This essentially corresponds to the category path of the book in Sefaria's table of contents (there are some differences with regards to commentary paths). For `sheet` queries, filters can be applied to `collections`, `topics_en` or `topics_he`. These fields are explained in `filter_fields` param.
   */
  filters?: unknown[];

  /**
   * Your search query.
   */
  query?: string;

  /**
   * For paginating results. The total number of results to return, starting from `start`
   */
  size?: int32;

  /**
   * The maximum distance between each query word in the resulting document. `0` means an exact match must be found
   */
  slop?: int32;

  /**
   * List of fields to sort on. If `sort_method = 'score'` this list should have exactly one item. Common fields to sort on are `comp_date` (which list results from titles published chronologically), `order` (which list results based on Sefaria's table of contents structure), `pagesheetrank` (most relevant results based on the Sheet Rank algorithm), `dateCreated` (for sheet results returned chronologically), `views` (for sheet results based on popularity).
   */
  sort_fields?: string[];

  /**
   * How to sort results. If sort, the values are sorted according to `sort_fields`. If `score`, the value in `sort_fields` is multiplied with the default ElasticSearch score.
   */
  sort_method?: "sort" | "score";

  /**
   * Whether or not to reverse the sort applied on `sort_fields`
   */
  sort_reverse?: boolean;

  /**
   * The number used in case there is a value missing in your `sort_field`
   */
  sort_score_missing?: float64;

  /**
   * By default, the ElasticSearch document is not returned. Specifying `true` will return the entire document. Specifying a `str` or `list(str)` will perform a projection on the document for the specified fields
   */
  source_proj?: boolean;

  /**
   * The ElasticSearch index you want to query, and the results you expect to get back. `sheet` returns results from Sefaria's user generated source sheets, while `text` returns results from the library.
   */
  type?: "text" | "sheet";
}

/**
 * The shape API allows one to retrieve information about the shape of an Index on Sefaria. The shape refers some basic statistics about the Index, mostly the number of chapters, and the number of segments per chapter.
 */
model ShapeJSON {
  /**
   * The parent section for this `Index`. (So for example, the `section` for `Jonah` is `Prophets`. The `section` for `Pesachim` is `Seder Moed`)
   */
  Section?: string;

  /**
   * A boolean representing whether or not this is a complex text.
   */
  isComplex?: boolean;

  /**
   * The number of chapters or top-level sections in the `Index`.
   */
  Length?: unknown;

  /**
   * Title of the `Index` in English
   */
  Book: string;

  /**
   * Title of the `Index` in Hebrew.
   */
  heBook: string;

  /**
   * For simple texts, this is a list of chapter lengths. For complex texts or categories, the Shape API will return a list of dicts for each text within that category or text.
   */
  Chapters: ShapeJSON[];
}

/**
 * JSON response for a Category GET request
 */
model CatJSON {
  /**
   * The full path of the category
   */
  path?: string[];

  /**
   * The titles for the category, in Hebrew and English.
   */
  titles?: TitlesJSON[];

  /**
   * The immediate parent of the current category. So for example, with the category `Tanakh/Torah/Genesis`, the `lastPath` is `Torah`.
   */
  lastPath?: string;
}

/**
 * Successful retrieval of the desired texts.
 */
model `get_api-v3-texts-tref200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: v3TextsJson;
}

/**
 * Successful response
 */
model `get_api-texts-tref200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: textAPIReponse;
}

/**
 * Returns a list containing the JSON Objects for each version available for the given `index` title. Each JSON Object contains all of the metadata for a given version.
 */
model `get_api-texts-versions-index200VersionJSONResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: VersionJSON[];
  @header contentType: "VersionJSON";
}

/**
 * Successful Response
 */
model `get_api-texts-translations200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: string[];
}

/**
 * Successful Response
 */
model `get_api-texts-translations-lan200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: {
    title?: string;
    url?: string;
    versionTitle?: string;
    rtlLanguage?: "he" | "en";
  };
}

/**
 * Successful response
 */
model `get_api-manuscripts-tref200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: ManuscriptJSON[];
}

/**
 * Successful response
 */
model `get_api-texts-random200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: textAPIReponse;
}

/**
 * Successful Request
 */
model `get_api-v2-raw-index-index-title200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: RawIndexJSON;
}

/**
 * Successful Response
 */
model `get_api-index200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: APIIndexResponse;
}

/**
 * Retrieve basic statistics and information about the "shape" of an `Index` on Sefaria.
 */
model `get_api-shape-title200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: ShapeJSON;
}

/**
 * All content related to the queried `Ref`.
 */
model `get_api-related-tref200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: RelatedJSON;
}

/**
 * Successful response
 */
model `get_api-links-tref200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: LinkObj[];
}

/**
 * Successful response
 */
model `get_api-ref-topic-links-tref200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: RefTopicLinksJSON;
}

/**
 * Successful Response
 */
model `get_api-calendars200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: CalendarAPIResponse;
}

/**
 * Successful Response
 */
model `get_api-calendars-next-read-parasha200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: CalendarNextReadAPI;
}

/**
 * An array of matching words.
 */
model `get_api-words-word200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: (
    | JastrowDictionaryEntry
    | StrongsDictionaryEntry
    | BDBDictionaryEntry
    | KleinDictionaryEntry
    | HebrewDictionaryEntry)[];
}

/**
 * Successful response
 */
model `get_api-words-completion-word-lexicon200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: wordCompletionAPIResponse[];
}

/**
 * v2 Specific Topic API
 */
model `get_api-v2-topics-topic-slug200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: TopicJSON;
}

/**
 * When one calls this endpoint _with_ a specific `topic_slug`, it returns a JSON object containing the metadata for the topic.
 *
 */
model `get_api-topics-topic-slug200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: TopicJSON;
}

/**
 * A list of JSON objects, each object representing a topic in the Sefaria database. Please note, since this list is over 30,000 topics long, in the example we only presented the first several topics that are returned in the array.
 */
model `get_api-topics200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: TopicJSON[];
}

/**
 * A list of topics connected to the `topic_slug` as well as a list of links.
 */
model `get_api-topics-graph-topic-slug200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: TopicGraphJSON;
}

/**
 * Successful response
 */
model `get_api-recommend-topics-ref-list200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: recommendedTopicResponse[];
}

/**
 * Successful response
 */
model `get_api-texts-random-by-topic200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: RandomByTopicJSON;
}

/**
 * The response to a query for a specific Term in the Terms API.
 */
model `get_api-terms-name200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: TermsJSON;
}

/**
 * Successful response
 */
model `get_api-name-name200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: nameAPIResponse;
}

/**
 * Successful Response
 */
model `post_api-find-refs200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: FindRefsAPIResponse;
}

/**
 * Successful Response
 */
model `post_api-search-wrapper200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: searchResponse;
}

/**
 * Successful Response
 */
model `get_api-img-gen-tref200ImagePngResponse` {
  @statusCode statusCode: 200;
  @header contentType: "image/png";
  @body image: bytes;
}

/**
 * GET requests take a full category path in the request, e.g. `/api/category/Tanakh/Torah/Genesis`, and return the full category object found.
 *
 * If the category is not found, the returned object will have an error attribute. If any element of the path is found, the API will return the closest parent in an attribute called `closest_parent`. This is useful for proactively looking up a category before posting an `Index` to it.
 */
model `get_api-category-category-path200ApplicationJsonResponse` {
  @statusCode statusCode: 200;
  @bodyRoot body: CatJSON;
}

/**
 * The most up-to-date way to retrieve texts from Sefaria via the API, with enhanced control over language, language direction, and other parameters.
 */
@tag("Text")
@route("/api/v3/texts/{tref}")
@get
op `get_api-v3-texts-tref`(tref: string): `get_api-v3-texts-tref200ApplicationJsonResponse`;

/**
 * Retrieve the text and some additional metadata for a specific Sefaria textual `Ref`
 */
@tag("Text")
@route("/api/texts/{tref}")
@get
op `get_api-texts-tref`(
  @query callback?: string,

  /**
   * The `context` param defaults to `1`, which allows for the API to return the entire context for the desired segment. When you explicitly set `context=0` only the desired segment is returned, without any of the accompanying context.
   */
  @query context?: "0" | "1",

  /**
   * The `commentary` param defaults to `0`, which turns off commentary being returned in the response. When you explicitly set `commentary=1` all of commentary to that specific connection is returned in list of JSON objects containing the text of the commentaries
   */
  @minValue(0)
  @maxValue(1)
  @query
  commentary?: integer,

  /**
   * By default this is set to `1` which ensures that any references at the title level will return only the first section of a book instead of its entirety. If you want the API to return the entire content of the book set pad to `0`
   */
  @query pad?: "0" | "1",

  /**
   * Unless explicitly specified, the texts API returns a default version of a text with roman characters as of the content in the `text` response. Passing a specific `versionTitle` here will load that text version if it exists instead of the default.
   *
   */
  @query ven?: string,

  /**
   * If a given text reference doesn't return any content, setting this to `1` will return the first reference that does.
   *
   * Sometimes this occurs when a text reference may pass our ref checking logic, but doesn't exist e.g. `https://www.sefaria.org/api/texts/Berakhot 1a?firstAvailableRef=1`, and sometimes this occurs when a translation is incomplete. Defaults to `0`
   */
  @query firstAvailableRef?: "0" | "1",

  /**
   * Unless explicitly specified, the texts API returns a default version of a text with Hebrew characters as of the content in the `he` response. Passing a specific `versionTitle` here will load that text version if it exists instead of the default.
   *
   */
  @query vhe?: string,

  @query layer?: string,

  /**
   * Returns the `alt structures` for the target text in the JSON response object.
   */
  @query alts?: "0" | "1",

  @query wrapLinks?: "0" | "1",
  @query wrapNamedEntities?: "0" | "1",

  /**
   * Sefaria texts include footnotes and other `iTags` in the response. This param defaults to `0` which leaves them in. Changing it to `1` will remove them.
   */
  @query stripItags?: "0" | "1",

  /**
   * If the absolute value of this param is greater than `1` the API response will return include `|n|` text API responses which include `|n|-1` additional consecutive sections of the targeted text if they exist. If the integer is positive, it will return the next consecutive chapter[s], and if negative it will contain the previous consecutive chapter[s].
   */
  @query multiple?: "0" | "1",

  /**
   * Unless explicitly specified, the texts API returns a default version for the `he` and `text` responses (usually in Hebrew & English respectfully). Passing an ISO 639-1 language code here will prioritize text versions in that target language if available.
   */
  @query transLangPref?: string,

  @query fallbackOnDefaultVersion?: "0" | "1",

  /**
   * The `sheets` param defaults to `0`, which turns off user-generated Sefaria Sheet data from being returned in the response. When you explicitly set `sheets=1` all of the user-generated sheet content to that specific connection is returned in list of JSON objects.
   *
   * _This usage is deprecated. Instead you should use the `Related API`._
   */
  @query sheets?: "0" | "1",

  /**
   * A valid textual `Ref` to a Sefaria text.
   */
  @path tref: ref,
): `get_api-texts-tref200ApplicationJsonResponse`;

/**
 * The versions API takes a title of a valid Sefaria `index` as a parameter, and will return all available versions of the text in the Sefaria database, alongside metadata for each version. A version can be a translation of the text, an alternative language, or any other text associated with that index.
 *
 * *Note:* In order to see the expected results, you need to make sure you are passing a recognized `index`. For example, `Rashi on Genesis` is a valid `index` but `Rashi` is not. To see the entire list of valid Sefaria indices, click [here](https://www.sefaria.org/api/index/)
 */
@tag("Text")
@route("/api/texts/versions/{index}")
@get
op `get_api-texts-versions-index`(index: string): `get_api-texts-versions-index200VersionJSONResponse`;

/**
 * Returns a list of distinct languages for which translations exist in the database.
 */
@tag("Text")
@route("/api/texts/translations")
@get
op `get_api-texts-translations`(): `get_api-texts-translations200ApplicationJsonResponse`;

/**
 * Returns a dictionary of texts translated into `lang`, organized by the Sefaria category & secondary category of each title.
 */
@tag("Text")
@route("/api/texts/translations/{lang}")
@get
op `get_api-texts-translations-lan`(lang: string): `get_api-texts-translations-lan200ApplicationJsonResponse`;

/**
 * This call retrieves all associated manuscript data and metadata for a given Sefaria `tref`.
 */
@tag("Text")
@route("/api/manuscripts/{tref}")
@get
op `get_api-manuscripts-tref`(
  /**
   * The `tref` parameter must a valid Sefaria ref to a text.
   */
  @path tref: string,
): `get_api-manuscripts-tref200ApplicationJsonResponse`;

/**
 * Returns a random text reference from the Sefaria library. Results can be limited to a specific category or from a selection of titles given the correct query params.
 */
@tag("Text")
@route("/api/texts/random")
@get
op `get_api-texts-random`(
  /**
   * A string of book titles from the Sefaria library separated with the character `|`. If it exists it will limit the random selection to those titles.
   */
  @query titles?: string,

  /**
   * A string of categories from the Sefaria library separated with the character `|`. If it exists it will limit the random selection to those categories.
   */
  @query categories?: string,
): `get_api-texts-random200ApplicationJsonResponse`;

/**
 * This API endpoint will retrieve the full mongo record of the given `Index` as it appears in the database.
 */
@tag("Index")
@route("/api/v2/raw/index/{index_title}")
@get
op `get_api-v2-raw-index-index-title`(index_title : string): `get_api-v2-raw-index-index-title200ApplicationJsonResponse`;

/**
 * This API endpoint returns the titles of all the books in the Sefaria Library arranged by their category along with some additional metadata. This is a large and rarely changing request and should be cached locally if you utilize it.
 */
@tag("Index")
@route("/api/index")
@get
op `get_api-index`(): `get_api-index200ApplicationJsonResponse`;

/**
 * Retrieve basic statistics and information about the "shape" of an `Index` on Sefaria.
 */
@tag("Index")
@route("/api/shape/{title}")
@get
op `get_api-shape-title`(title: string): `get_api-shape-title200ApplicationJsonResponse`;

/**
 * A single API endpoint to return all of the content (links, sheets, notes, media, manuscripts, webpages and topics) related to the given `Ref` in the query.
 */
@tag("Related")
@route("/api/related/{tref}")
@get
op `get_api-related-tref`(tref: string): `get_api-related-tref200ApplicationJsonResponse`;

/**
 * Returns a list of known connections for the submitted text `ref` along with some additional metadata.
 */
@tag("Related")
@route("/api/links/{tref}")
@get
op `get_api-links-tref`(
  tref: string,

  /**
   * `with_text` is an optional parameter that determines whether or not the API response will include the text of any connected links. It's default is `1`
   */
  @query with_text?: "0" | "1",

  /**
   * `with_sheet_links` is an optional parameter that determines whether or not the API response will include links to user generated source sheets from Sefaria. It's default is `0`
   */
  @query with_sheet_links?: "0" | "1",
): `get_api-links-tref200ApplicationJsonResponse`;

/**
 * An API endpoint where, given a `Ref`, all of the topics linked to that `Ref` are retrieved along with the respective metadata.
 */
@tag("Related")
@route("/api/ref-topic-links/{tref}")
@get
op `get_api-ref-topic-links-tref`(tref: string): `get_api-ref-topic-links-tref200ApplicationJsonResponse`;

/**
 * Returns the daily or weekly learning schedule for a given date.
 */
@tag("Calendars")
@route("/api/calendars")
@get
op `get_api-calendars`(
  /**
   * When this value is set to `diaspora=1`, the text returned is the weekly Torah reading for the diaspora. When this value is set to `diaspora=0`, the text returned is the Torah reading for Israel.
   */
  @query diaspora?: "0" | "1",

  /**
   * If available, the weekly _Haftarah_ will be returned for one of the selected custom.
   */
  @query custom?: "ashkenazi" | "sephardi" | "edot%20hamizrach",

  /**
   * By default the API returns for the current time. You can override it by using a combination of the `year`, `day`, and `month` params - all three of which must be used, or else the API will fallback to the default.
   */
  @query year?: numeric,

  /**
   * By default the API returns for the current time. You can override it by using a combination of the `year`, `day`, and `month` params - all three of which must be used, or else the API will fallback to the default.
   */
  @query month?: numeric,

  /**
   * By default the API returns for the current time. You can override it by using a combination of the `year`, `day`, and `month` params - all three of which must be used, or else the API will fallback to the default.
   */
  @query day?: numeric,

  /**
   * By default, the API attempts to return the calendars for the client's timezone. If you want another region you can override it. Timezone names are in accordance with [IANA Standards](https://www.iana.org/time-zones)
   */
  @query timezone?: unknown,
): `get_api-calendars200ApplicationJsonResponse`;

/**
 * Given a Parasha name in English, this API returns the next Hebrew and English dates that it is read, along with details about the Torah and Haftarah readings for that date.
 */
@tag("Calendars")
@route("/api/calendars/next-read/{parasha}")
@get
op `get_api-calendars-next-read-parasha`(
  /**
   * One of the 54 weekly Torah Parasha names in English or one of the 7 double parshiyot.
   */
  @path parasha:
    | "Bereshit"
    | "Noach"
    | "Lech-Lecha"
    | "Vayera"
    | "Chayei Sara"
    | "Toldot"
    | "Vayetzei"
    | "Vayishlach"
    | "Vayeshev"
    | "Miketz"
    | "Vayigash"
    | "Vayechi"
    | "Shemot"
    | "Vaera"
    | "Bo"
    | "Beshalach"
    | "Yitro"
    | "Mishpatim"
    | "Terumah"
    | "Tetzaveh"
    | "Ki Tisa"
    | "Vayakhel"
    | "Pekudei"
    | "Vayikra"
    | "Tzav"
    | "Shmini"
    | "Tazria"
    | "Metzora"
    | "Achrei Mot"
    | "Kedoshim"
    | "Emor"
    | "Behar"
    | "Bechukotai"
    | "Bamidbar"
    | "Nasso"
    | "Beha’alotcha"
    | "Sh’lach"
    | "Korach"
    | "Chukat"
    | "Balak"
    | "Pinchas"
    | "Matot"
    | "Masei"
    | "Devarim"
    | "Vaetchanan"
    | "Eikev"
    | "Re’eh"
    | "Shoftim"
    | "Ki Teitzei"
    | "Ki Tavo"
    | "Nitzavim"
    | "Vayeilech"
    | "Ha’azinu"
    | "Vezot Haberakhah"
    | "Vayakhel-Pekudei"
    | "Tazria-Metzora"
    | "Achrei Mot-Kedoshim"
    | "Behar-Bechukotai"
    | "Chukat-Balak"
    | "Matot-Masei"
    | "Nitzavim-Vayeilech",
): `get_api-calendars-next-read-parasha200ApplicationJsonResponse`;

/**
 * Searches Sefaria lexicon entries (i.e. dictionaries) for the query string passed as `word` to the endpoint.
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
): `get_api-words-word200ApplicationJsonResponse`;

/**
 * Serves primarily as an autocompleter, returning potential lexicon entries for a given input.
 *
 * Returns an array of arrays, each containing two strings. The first is a completion entry in Hebrew without vowels and the second includes vowels.
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
): `get_api-words-completion-word-lexicon200ApplicationJsonResponse`;

/**
 * Retrieve a specific topic from the `v2` version of the topics API.
 */
@tag("Topic")
@route("/api/v2/topics/{topic_slug}")
@get
op `get_api-v2-topics-topic-slug`(
  
  topic_slug: string,
  /**
   * Values can be `1` or `0`.
   *
   * If `1`, adds the following fields to each intra-topic link: `title`, `titleIsTransliteration`, `shouldDisplay`, and `order`.
   */
  @query annotate_links?: integer,
): `get_api-v2-topics-topic-slug200ApplicationJsonResponse`;

/**
 * When one calls this endpoint _with_ a specific `topic_slug`, it returns a JSON object containing the metadata for the topic.
 *
 */
@tag("Topic")
@route("/api/topics/{topic_slug}")
@get
op `get_api-topics-topic-slug`(topic_slug : string): `get_api-topics-topic-slug200ApplicationJsonResponse`;

/**
 * The topics API returns a list of JSON objects, each object containing all of the metadata for each topic in the Sefaria database.
 */
@tag("Topic")
@route("/api/topics")
@get
op `get_api-topics`(): `get_api-topics200ApplicationJsonResponse`;

/**
 * Endpoint to retrieve topics and their links between other topics. As opposed to topic links to refs, this endpoint retrieve connections between one topic to another topic.
 */
@tag("Topic")
@route("/api/topics-graph/{topic_slug}")
@get
op `get_api-topics-graph-topic-slug`(topic_slug : string): `get_api-topics-graph-topic-slug200ApplicationJsonResponse`;

/**
 * Given a list of `Ref`s this API returns the most used topics associated with them. This is a fast way of identifying potential shared topics amongst disparate `Ref`s.
 */
@tag("Topic")
@route("/api/recommend/topics/{ref_list}")
@get
op `get_api-recommend-topics-ref-list`(
  /**
   * List of strings separated by '+'
   */
  @path ref_list: string,
): `get_api-recommend-topics-ref-list200ApplicationJsonResponse`;

/**
 * Returns Texts API data for a random text taken from popular topic tags.
 */
@tag("Topic")
@route("/api/texts/random-by-topic")
@get
op `get_api-texts-random-by-topic`(): `get_api-texts-random-by-topic200ApplicationJsonResponse`;

/**
 * A Term is a shared title node.  It can be referenced and used by many different `Index` nodes. Terms that use the same `TermScheme` can be ordered within that scheme. So for example, _Parsha_ terms who all share the `TermScheme` of `parsha`, can be ordered within that scheme.
 *
 * Examples of valid terms:  `Noah`, `HaChovel`
 *
 */
@tag("Term")
@route("/api/terms/{name}")
@get
op `get_api-terms-name`(name: string): `get_api-terms-name200ApplicationJsonResponse`;

/**
 * Serves primarily as an autocompleter, returning potential keyword matches for `Ref`s, book titles, authors, topics, and collections available on Sefaria.
 */
@tag("Term")
@route("/api/name/{name}")
@get
op `get_api-name-name`(
  name: string,
  /**
   * Number of results to return (`0` indicates no limit)
   */
  @query limit?: integer,

  /**
   * By default `0` the Name API returns `Ref`s, book titles, authors, topics, and collections. If true, the response will only contain text references.
   */
  @query ref_only?: "0" | "1",
): `get_api-name-name200ApplicationJsonResponse`;

/**
 * Initially designed to find links on websites using [Sefaria's Linker](https://www.sefaria.org/linker), the Find Refs API can identify textual refernces in any arbitrary text that gets sent to it via a structured POST request and returns a response object identifying each located reference including its start and end position within the submitted text.
 */
@tag("Misc")
@route("/api/find-refs")
@post
op `post_api-find-refs`(
  @bodyRoot body: FindRefsPOSTRequest,
): `post_api-find-refs200ApplicationJsonResponse`;

/**
 * An [elastic search](https://www.elastic.co/guide/en/elasticsearch/reference/current/) endpoint for Sefaria's data. Given a properly formated POST request this endpoint will return search results for appropriate Sefaria records.
 */
@tag("Misc")
@route("/api/search-wrapper")
@post
op `post_api-search-wrapper`(
  @bodyRoot body: SearchPOSTData,
): `post_api-search-wrapper200ApplicationJsonResponse`;

/**
 * Given a Sefaria text `Ref` and some other optional parameters, this endpoint returns a .png image ready to share on social media. At Sefaria.org we use it primarily to auto-generate social media images for any page.
 */
@tag("Misc")
@route("/api/img-gen/{tref}")
@get
op `get_api-img-gen-tref`(
  tref: string,
  /**
   * The language the social image should return, `en` for English language or `he` for Hebrew.
   */
  @query lang?: "he" | "en",

  /**
   * This value determines the size of the image, set to the platform's ideal as specified in its own developer documentation.
   */
  @query platform?: "facebook" | "twitter",

  /**
   * The title of the version of English text desired for the image.
   */
  @query ven?: string,

  /**
   * The title of the version of Hebrew text desired for the image.
   */
  @query vhe?: string,
): `get_api-img-gen-tref200ImagePngResponse`;

/**
 * GET requests take a full category path in the request, e.g. `/api/category/Tanakh/Torah/Genesis`, and return the full category object found.
 *
 * If the category is not found, the returned object will have an error attribute. If any element of the path is found, the API will return the closest parent in an attribute called `closest_parent`. This is useful for proactively looking up a category before posting an `Index` to it.
 */
@tag("Misc")
@route("/api/category/{category_path}")
@get
op `get_api-category-category-path`(category_path: string): `get_api-category-category-path200ApplicationJsonResponse`;
