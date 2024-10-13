import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";
import "../model/manuscript.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * The most up-to-date way to retrieve texts from Sefaria via the API, with enhanced control over language, language direction, and other parameters.
 * @returns Successful retrieval of the desired texts.
 */
@tag("Text")
@route("/api/v3/texts/{tref}")
@opExample(#{ returnType: getTextsV3ResponseExample }, #{ title: "Esther 1.1" })
@get
op getTextsV3(
  /**
   * There are two possible forms for the string passed as the `version`:
   * 1. `language`
   * 2. `language|versionTitle`
   *
   * When in the form of `language`, the primary version of that language is returned in the `versions` field of the response object. When in the form of `language>|<versionTitle`, only that specific version is returned in the `versions` field.
   *
   *
   * **Notes**:
   * - `language` is the full English name of the language. In cases of dialectics with varying sub-specifities, please pass the ‘mother’ language (so for example, `arabic` rather than `judeo-arabic`). This field is NOT case sensitive.
   * - `versionTitle` is the exact English `versionTitle` of the given `version` in the Sefaria database.
   * - When only `language` is passed, the response will return a single version of the text in that language, the one that is highest priority in the Sefaria database.
   * - Requests can have more than one `version` param. If no `version` was passed, the API defaults to `version=primary`.
   *
   * -----
   *
   * **Special Values**
   * The following values can be passed in as special values to the `version` parameter.
   * - `source`: When `version=source` is passed, it retrieves the text in its "source" language (i.e. the original language the text was written in, versus a translation).
   * - `translation`: When `version=translation`is passed, it retrieves a translation of the text.
   * - `primary`: When `version=primary` is passed, it retrieves the primary text as per the Sefaria database (i.e. the `isPrimary` field on the `version` in the database is set to `True`). Usually the text returned is identical to what is returned with the special value of `source`, but it can also include other languages (e.g. Hebrew for the _Kuzari_, which was originally written in Judeo-Arabic)
   * - `all`: get all texts in the required language.
   *
   *
   * If a required version is missing that information will be under the field warnings of the response.
   *
   */
  @query version?: string,

  /**
   * A Sefaria-specific reference, `Ref`. This should be a segment `Ref` (the most specific reference possible), or bottom level section `Ref` (i.e.  a section of text on level up, a section is an array of segments). If a `Ref` is passed in which is not a segment level or a bottom level section, the response will be to the first bottom level section `Ref` (e.g. `Genesis` will resolve to the bottom level section `Ref` of `Genesis 1`)
   */
  @path tref: string,

  /**
   * This parameter is only relevant for cases where the requested text is incomplete (i.e. not all of the segments in the requested version exist in the database for that text, such as a partial translation).
   *
   * When `fill_in_missing_segments=1`, the segments of text that are missing in the requested version will be filled by other versions of the same language.
   *
   * This value defaults to `0`.
   *
   */
  @query fill_in_missing_segments?: "0" | "1",

  /**
   * This parameter formats the text that will be returned from the `v3` `texts/` API. It can have one of four values:
   * 1. `text_only` - This strips footnotes, inline references and all html tags from the returned text
   * 2. `strip_only_footnotes` - This only strips the footnotes and commentator <i> tags without stripping the other HTML tags.This is useful for the native app, where we do not display footnotes.
   * 3. `wrap_all_entities` - This wraps the HTML for links and topic links
   * 4. `default` - This returns the basic text as it’s saved in Sefaria’s DB
   *
   */
  @query return_format?:
    | "default"
    | "wrap_all_entities"
    | "strip_only_footnotes"
    | "text_only" = "default",
): v3TextsJson;

/**
 * Retrieve the text and some additional metadata for a specific Sefaria textual `Ref`
 * @returns Successful response
 */
#deprecated "use getTextsV3"
@tag("Text")
@route("/api/texts/{tref}")
@opExample(
  #{ returnType: getTextsV1ResponseExample },
  #{ title: "Shabbat 22a.1" }
)
@get
op getTextsV1(
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
): textAPIReponse;

/**
 * The versions API takes a title of a valid Sefaria `index` as a parameter, and will return all available versions of the text in the Sefaria database, alongside metadata for each version. A version can be a translation of the text, an alternative language, or any other text associated with that index.
 *
 * *Note:* In order to see the expected results, you need to make sure you are passing a recognized `index`. For example, `Rashi on Genesis` is a valid `index` but `Rashi` is not. To see the entire list of valid Sefaria indices, click [here](https://www.sefaria.org/api/index/)
 * @returns Returns a list containing the JSON Objects for each version available for the given `index` title. Each JSON Object contains all of the metadata for a given version.
 */
@tag("Text")
@route("/api/texts/versions/{index}")
@opExample(
  #{ returnType: getVersionsResponseExample },
  #{ title: "Rashi on Kohelet" }
)
@get
op getVersions(index: string): VersionJSON[];

/**
 * Returns a list of distinct languages for which translations exist in the database.
 * @returns Successful Response
 */
@tag("Text")
@route("/api/texts/translations")
@opExample(
  #{
    returnType: #[
      "ar",
      "cs",
      "de",
      "en",
      "eo",
      "es",
      "fa",
      "fi",
      "fr",
      "he",
      "hu",
      "it",
      "ko",
      "pl",
      "pt",
      "ru",
      "yi"
    ],
  },
  #{ title: "translationEx" }
)
@get
op getLangages(): string[];

/**
 * Returns a dictionary of texts translated into `lang`, organized by the Sefaria category & secondary category of each title.
 * @returns Successful Response
 */
@tag("Text")
@route("/api/texts/translations/{lang}")
@get
op getTranslations(lang: string): {
  /** Title of the book on Sefaria */
  title?: string;

  /** Base URL of the book on Sefaria */
  url?: string;

  /** Title of this specific translation of the title */
  versionTitle?: string;

  /** Is this version a RTL text (i.e. `he`) or LTR text (i.e. `en`) */
  rtlLanguage?: "he" | "en";
};

/**
 * This call retrieves all associated manuscript data and metadata for a given Sefaria `tref`.
 * @returns Successful response
 */
@tag("Text")
@route("/api/manuscripts/{tref}")
@opExample(
  #{
    returnType: #[
      #{
        manuscript_slug: "leningrad-codex-(1008-ce)",
        page_id: "LC_Folio_435r",
        image_url: "https://manuscripts.sefaria.org/leningrad-color/BIB_LENCDX_F435A.jpg",
        thumbnail_url: "https://manuscripts.sefaria.org/leningrad-color/BIB_LENCDX_F435A_thumbnail.jpg",
        anchorRef: "Esther 4:17-6:2",
        anchorRefExpanded: #["Esther 5:14"],
        manuscript: #{
          slug: "leningrad-codex-(1008-ce)",
          title: "Leningrad Codex (1008 CE)",
          he_title: "כתב יד לנינגרד (1008)",
          source: "https://dornsife.usc.edu/wsrp/biblical-manuscripts",
          description: "Bruce Zuckerman, West Semitic Research, in collaboration with the Ancient Biblical Manuscript Center; courtesy Russian National Library, Saltykov-Schedrin",
          he_description: "",
        },
      },
      #{
        manuscript_slug: "megilat-ester-or-1047-(17th-century)",
        page_id: "Esther",
        image_url: "https://storage.googleapis.com/sefaria-manuscripts/misc/Megilat%20Ester%2C%20Or%201047%20-%20mid.jpg",
        thumbnail_url: "https://storage.googleapis.com/sefaria-manuscripts/misc/Megilat%20Ester%2C%20Or%201047%20-%20thumb.png",
        anchorRef: "Esther",
        anchorRefExpanded: #["Esther 5:14"],
        manuscript: #{
          slug: "megilat-ester-or-1047-(17th-century)",
          title: "Megilat Ester, Or 1047 (17th Century)",
          he_title: "מגילת אסתר Or 1047 (מאה 17)",
          source: "https://www.bl.uk/collection-items/megilat-ester-or-1047",
          description: "",
          he_description: "",
        },
      }
    ],
  },
  #{ title: "Esther 4:14-15" }
)
@get
op getManuscripts(
  /**
   * The `tref` parameter must a valid Sefaria ref to a text.
   */
  @path tref: string,
): ManuscriptJSON[];

/**
 * Returns a random text reference from the Sefaria library. Results can be limited to a specific category or from a selection of titles given the correct query params.
 * @returns Successful response
 */
@tag("Text")
@route("/api/texts/random")
@get
op getRandomText(
  /**
   * A string of book titles from the Sefaria library separated with the character `|`. If it exists it will limit the random selection to those titles.
   */
  @query titles?: string,

  /**
   * A string of categories from the Sefaria library separated with the character `|`. If it exists it will limit the random selection to those categories.
   */
  @query categories?: string,
): textAPIReponse;

/**
 * The texts on Sefaria are grouped into two language buckets, `en` for languages which read left-to-right (i.e. English, Spanish, German) and `he` for languages which read right-to-left (i.e. Hebrew, Arabic). This field is only ever populated by a string containing the value of either `en` or `he`.
 */
@example("'en'\n'he'")
scalar LanguageCode extends string;

/**
 * Expected reponse data from Sefaria's Text API
 */
@example(textAPIReponseModelExample)
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

/**
 * The metadata for a given version.
 */
@example(#{
  title: "Shulchan Arukh, Orach Chayim",
  versionTitle: "Wikisource Shulchan Aruch",
  versionSource: "https://en.wikisource.org/wiki/Translation:Shulchan_Aruch/Orach_Chaim/338",
  language: "en",
  status: "",
  license: "CC-BY-SA",
  versionNotes: "",
  digitizedBySefaria: "",
  priority: "",
  versionTitleInHebrew: "שולחן ערוך (ויקיטקסט)",
  versionNotesInHebrew: "",
  extendedNotes: "",
  extendedNotesHebrew: "",
  purchaseInformationImage: "",
  purchaseInformationURL: "",
  shortVersionTitle: "",
  shortVersionTitleInHebrew: "",
  firstSectionRef: "Shulchan Arukh, Orach Chayim 1",
})
model VersionJSON {
  /**
   * The title of the Index.
   */
  @example("Talmud Berakhot")
  title?: string;

  /**
   * The title of the version
   */
  @example("William Davidson Edition - Vocalized Aramaic")
  versionTitle?: string;

  /**
   * A URL pointing to the hardcopy of the text as it can be found in libraries, most usually in our case the NLI (National Library of Israel), but not exclusively.
   */
  @example("https://www.nli.org.il/he/books/NNL_ALEPH990025294890205171/NLI")
  versionSource?: string;

  /**
   * The language of the version. The versions on Sefaria are grouped into two language buckets, `en` for languages which read left-to-right (i.e. English, Spanish, German) and `he` for languages which read right-to-left (i.e. Hebrew, Arabic)
   */
  @example("'en'\n'he'")
  language?: LanguageCode;

  /**
   * The status field contains either the string `"locked"` or an empty string. If `"locked"` is the value of the field, it indicates that the text is locked from future updatees, edits and translations from community members.
   */
  @example("locked")
  status?: string;

  /**
   * The copyright license for using, and reproducing the text.
   */
  @example("CC-BY")
  license?: string;

  /**
   * English notes relating to the version, often containing details of authorship, place of printing, and sometimes donor dedications.
   */
  @example("\"English from The William Davidson digital edition of the <a href='https://korenpub.com/collections/the-noe-edition-koren-talmud-bavli-1'>Koren Noé Talmud</a>, with commentary by <a href='/adin-even-israel-steinsaltz'>Rabbi Adin Even-Israel Steinsaltz</a>\",")
  versionNotes?: string;

  /**
   * Whether or not the text was digitized by Sefaria. We have some texts we've been able to add to our database from digital sources, and other texts that we've transfered from print to a digital medium ourselves. This field indicates if Sefaria did the digitization.
   */
  @example("True")
  digitizedBySefaria?: boolean;

  /**
   * The priority field is a number which indicates the priority of a version relative to all other existing versions of the same text. A value of `1` indicates the lowest priority, while the highest value among all versions of the text indicate the highest priority.
   *
   * Priority values can also be floating point numbers. The priority field determines how the various available versions of a text will be displayed on the Sefaria website. The texts are displayed to the user in a highest-to-lowest priority order, in many cases offering more complete or higher quality versions of the text before ones of inferior quality.
   */
  @example(7)
  priority?: numeric;

  /**
   * The title of the version in Hebrew
   */
  @example("מהדורת וויליאם דייוידסון - ארמית המנוקד")
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
  @example("https://storage.googleapis.com/sefaria-physical-editions/4fc4b6d5b144eb3915d250d743eaf2e8.png")
  purchaseInformationImage?: string;

  /**
   * The URL pointing to a website where on can buy a physical copy of the given text version.
   */
  @example("https://korenpub.com/collections/the-noe-edition-koren-talmud-bavli-1/products/copy-of-vol-1-berakhot-1")
  purchaseInformationURL?: string;

  /**
   * An English short title for the version
   */
  @example("Koren - Steinsaltz")
  shortVersionTitle?: string;

  /**
   * A Hebrew short title for the version
   */
  shortVersionTitleInHebrew?: string;

  /**
   * The first `ref` for this title on a section level (as opposed to the more granular segment level). For example, `Genesis 1` would be the first section level ref of Genesis (as opposed to the segment, `Genesis 1:1`), and `Rashi on Kohelet 1:1` is the first section level ref of `Rashi on Kohelet` (as opposed to the segment level of `Rashi on Kohelet 1:1:1`)
   */
  @example("Rashi on Kohelet 1.1")
  firstSectionRef?: string;
}

/**
 * Information about a single text version of a title
 */
@example(#{
  title: "Genesis",
  versionTitle: "The Contemporary Torah, Jewish Publication Society, 2006",
  versionSource: "https://www.nli.org.il/he/books/NNL_ALEPH002529489/NLI",
  language: "en",
  status: "locked",
  license: "CC-BY-NC",
  versionNotes: "Dedicated by an anonymous donor in honor of all women and girls who study, teach, and transform Torah.\n<br><br>\n<a href=\"https://www.sefaria.org/sheets/382047\">Read the preface to The Contemporary Torah</a>\n<br><br>\n<a href=\"https://www.sefaria.org/sheets/380713\"> See the Dictionary of Gender in the Torah</a>",
  digitizedBySefaria: "",
  priority: 7,
  versionTitleInHebrew: "",
  versionNotesInHebrew: "תרומה אלמונית לכבוד כל הנשים והבנות שלומדות, מלמדות ונותנות צורה חדשה לתורה",
  extendedNotes: "",
  extendedNotesHebrew: "",
  purchaseInformationImage: "https://jps.org/wp-content/uploads/2014/10/ContemporaryTorah-300x458.png",
  purchaseInformationURL: "https://jps.org/books/contemporary-torah/",
  shortVersionTitle: "The Contemporary Torah, JPS, 2006",
  shortVersionTitleInHebrew: "",
  firstSectionRef: "Genesis 1",
})
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
 * The JSON returned from the `v3` `texts/` endpoint.
 */
@example(v3TextsJsonModelExample)
model v3TextsJson {
  /**
   * The list of requested `version` objects. It includes all the data that is unique to the requested `versions`.
   *
   */
  @example(v3TextsJson_versions_ModelExample)
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
  @example("Esther")
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
  @example(#["Tanakh", "Writings"])
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
  @example(#["Perek", "Pasuk"])
  addressTypes?: string[];

  /**
   * Various alternative titles used for the text.
   */
  @example(#["Est.", "Est", "Ester", "Esth.", "Esth", "Esther"])
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
  @example(#[
    #{
      finnish: #{
        warning_code: 102,
        message: "We do not have the language you asked for Esther 1:1. Available languages are ['english', 'esperanto', 'french', 'german', 'hebrew', 'italian', 'persian', 'polish', 'spanish', 'yiddish']",
      },
    },
    #{
      dutch: #{
        warning_code: 102,
        message: "We do not have the language you asked for Esther 1:1. Available languages are ['english', 'esperanto', 'french', 'german', 'hebrew', 'italian', 'persian', 'polish', 'spanish', 'yiddish']",
      },
    }
  ])
  warnings?: unknown[];
}

/**
 * Data returned in the `available_versions` field of the `v3` `texts` API. This contains all of the available versions for a given text, not just the required versions.
 */
@example(#{
  status: "locked",
  priority: 3,
  license: "CC-BY-NC",
  versionNotes: "<a href=\"http://purl.org/jps/rjps-preface\">Read the Preface to the Revised JPS Edition</a>\n<br><br>\n<a href=\"http://purl.org/jps/gender\">Read the Notes on Gender in Translation for the Revised JPS Edition</a>\n<br><br>\n<a href=\"https://www.sefaria.org/collections/commentary-on-the-usage-and-rendering-of-%D7%90%D7%99%D7%A9?tab=sheets\">Read a Commentary on the Hebrew word ’ish in the Revised JPS Edition</a>",
  formatAsPoetry: "",
  digitizedBySefaria: "",
  method: "",
  heversionSource: "",
  versionUrl: "",
  versionTitleInHebrew: "",
  versionNotesInHebrew: "",
  shortVersionTitle: "Revised JPS, 2023",
  shortVersionTitleInHebrew: "",
  extendedNotes: "",
  extendedNotesHebrew: "",
  purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/JPS-Tanakh-Gender-Sensitive-Edition-Cover-300x450.jpg",
  purchaseInformationURL: "https://jps.org/books/the-jps-tanakh-gender-sensitive-edition/",
  hasManuallyWrappedRefs: "",
  actualLanguage: "en",
  languageFamilyName: "english",
  isSource: false,
  isPrimary: false,
  direction: "ltr",
  language: "en",
  title: "Obadiah",
  versionSource: "https://jps.org/books/the-jps-tanakh-gender-sensitive-edition/",
  versionTitle: "THE JPS TANAKH: Gender-Sensitive Edition",
})
model v3AvailableVersionsTextJson {
  ...v3TextVersionsJSON;

  /**
   * The title of the book.
   */
  @example("Esther")
  title?: string;
}
@example(#{
  status: "locked",
  priority: 2,
  license: "CC-BY-SA",
  versionNotes: "<i>Miqra According to the Masorah</i> (MAM) is a digital Hebrew edition of the Tanakh based on the Aleppo Codex and related manuscripts. It is designed for readers, and as such it contains added elements to aid vocalization of the text. For instance: When an accent is marked in an unstressed syllable, an extra accent is added in the proper place (<i>pashta</i>, <i>zarqa</i>, <i>segol</i>, <i>telisha</i>). <i>Legarmeih</i> and <i>paseq</i> are visibly distinguished. <i>Qamaz qatan</i> is indicated by its designated Unicode character (alternatives are documented where traditions differ about its application).<br>The text of MAM is fully documented. The <a href=\"https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94/%D7%9E%D7%99%D7%93%D7%A2_%D7%A2%D7%9C_%D7%9E%D7%94%D7%93%D7%95%D7%A8%D7%94_%D7%96%D7%95\">complete introduction</a> to the edition (Hebrew) explains the types of editorial decisions that have been made and the reasons for them (<a href=\"https://en.wikisource.org/wiki/User:Dovi/Miqra_according_to_the_Masorah#About_this_Edition_(English_Abstract)\">English abstract</a>). In addition, every word in the Bible about which there is some textual concern or ambiguity includes a documentation note; these notes can be viewed conveniently <a href=\"https://bdenckla.github.io/MAM-with-doc/\">here</a>. If an error is discovered, it may be reported to <a href=\"https://he.wikisource.org/wiki/%D7%A9%D7%99%D7%97%D7%AA_%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi\">User:Dovi</a> at Hebrew Wikisource. Please check the documentation notes before reporting an error.",
  formatAsPoetry: "",
  digitizedBySefaria: "",
  method: "",
  heversionSource: "",
  versionUrl: "",
  versionTitleInHebrew: "מקרא על פי המסורה",
  versionNotesInHebrew: "",
  shortVersionTitle: "",
  shortVersionTitleInHebrew: "",
  extendedNotes: "",
  extendedNotesHebrew: "",
  purchaseInformationImage: "",
  purchaseInformationURL: "",
  hasManuallyWrappedRefs: "",
  actualLanguage: "he",
  languageFamilyName: "hebrew",
  isSource: true,
  isPrimary: true,
  direction: "rtl",
  language: "he",
  versionSource: "https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94",
  versionTitle: "Miqra according to the Masorah",
  text: #[],
  firstSectionRef: "Obadiah 1",
})
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
  @example("Public Domain")
  license?: string;

  /**
   * Notes on the version
   */
  @example("© Kehot Publication Society")
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
  @example("https://storage.googleapis.com/sefaria-physical-editions/touger-mishneh-torah-hilkhot-teshuvah-purchase-img.png")
  purchaseInformationImage?: string;

  /**
   * A URL pointing to where one can purchase a hardcopy of this text.
   */
  @example("https://moznaim.com/products/mishneh-torah-rambam")
  purchaseInformationURL?: string;

  hasManuallyWrappedRefs?: string;

  /**
   * The [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) language code for the language of the text. We default to 2 letter codes when available, and 3 letter codes when they are not.
   */
  @example("de")
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
  @example("ltr")
  direction?: string;

  /**
   * A holdover from the `v2` API which will eventually be deprecated. This used to indicate the direction of the text, with `en` indicating texts written from left-to-right, and `he` indicating texting written from right-to-left.
   */
  @example("`he`\n`en`")
  language?: string;

  /**
   * The original source of the digital text.
   */
  @example("http://kehot.com/")
  versionSource?: string;

  /**
   * The English title of the Version of text.
   */
  @example("Mischnajot mit deutscher Übersetzung und Erklärung. Berlin 1887-1933 [de]")
  versionTitle?: string;

  /**
   * An array of strings containing the text of the specific version.
   *
   * If a segment `Ref` was passed, the array returned will be one-dimensional and contain a string with the specific segment level text.
   *
   * If a bottom level section `Ref` was passed, the array returned will be a two-dimensional array, a list of lists of strings. The outer layer of the array represents the section, and the inner arrays represent the segments.
   */
  @example(#[
    "<b>Von welcher Zeit ab liest man das Schema.</b> Zu Schema wird Deuter. 6, 4—9 <span dir=\"ltr\">שמע</span> , 2. Deuter. 11, 13—21 <span dir=\"rtl\">והיה אם שמוע</span> und 3. Numeri 15, 37—41 <span dir=\"rtl\">ויאמר</span> gerechnet.",
    "<b>da die Priester eintreten.</b> Nämlich unreine Priester, welche nicht gebadet und gereinigt hatten und erst mit dem Erscheinen der Sterne ihre Hebe essen durften (Lev. 22, 7).",
    "<b>bis zu Ende der ersten Nachtwache.</b> Man teilte die Nacht in drei Wachen.",
    "<b>Die Weisen.</b> So oft hier der Ausdruck die Weisen vorkommt, verstehe man darunter die große Mehrzahl der Weisen, sofern sie nach allgemein geltender Ansicht entscheidet.",
    "<b>Bis die Morgenröte.</b> Säule der Morgenröte im Hebr. und Arab.",
    "<b>aufsteigt.</b> Der Grund der Meinungsverschiedenheit liegt in der Deutung des <span dir=\"rtl\">ובשכבך</span> . R. Elieser erklärt: Wenn du dich niederlegst; dies geschieht bei den meisten Menschen bis Ende der ersten Nachtwache. Nach den Weisen und so auch nach R. Gamliel heißt <span dir=\"rtl\">ובשכבך</span> , wenn du liegst; demnach wäre es die ganze Nacht erlaubt das Schema zu lesen, jedoch die Weisen erlauben es nur bis Mitternacht, um der Gesetzesübertretung vorzubeugen, was R. Gamliel nicht für nötig hält.",
    "<b>Das Aufdampfen des Fettes und der Glieder.</b> Stücke der Opfertiere, (Lev. 6, 2; 7, 2.)",
    "<b>nur an demselben Tage gegessen werden darf.</b> D. h. am Tage der Darbringung (Lev. 7, 15).",
    "<b>Um die Menschen von der Übertretung fern zu halten.</b> Nämlich, sie setzten eine kürzere Frist, damit man sich auf keinen Fall verspäte.",
    "<b>Sobald man zwischen himmelblau und weiß unterscheiden kann; R. Elieser sagt: Zwischen himmelblau und lauchgrün; (und beendet das Lesen.</b> <span dir=\"rtl\">וגומרה</span> , wenn die Lesart richtig ist, bezieht es sich auf <span dir=\"rtl\">פרשת שמע</span> .",
    "<b>erst um drei Stunden aufzustehen.</b> Das Gesetz <span dir=\"rtl\">ובקומך</span> meint er, bedeute »bis Jedermann aufgestanden ist.« — Die Stunden sind hier je nach der Jahreszeit von verschiedener Länge; denn man teilte den Tag und die Nacht in je 12 Teile. Wenn also z. B. der Tag 8 und die Nacht 16 Stunden hat, so wird die Tagesstunde zu 8/12 gewöhnliche Stunden = 40 Minuten, die Nachtstunde aber zu 16/12 gewöhnliche Stunden = 80 Minuten gerechnet. Solche Stunden werden <span dir=\"rtl\">שעות זמניות</span> = Zeitstunden genannt",
    "<b>büsst nichts ein.</b> D. h. er möge immerhin die dazu gehörigen Vor- und Nachgebete sprechen (nach Einigen jedoch nur bis Ende der. 4. Stunde) obgleich deren Zeit vorüber ist.",
    "<b>brachte mich aber in Lebensgefahr durch Räuber.</b> Wäre beinahe von Räubern getötet worden.",
    "<b>Am Morgen spricht man zwei Segenssprüche voran.</b> <span dir=\"rtl\">לפניה</span> bezieht sich auf <span dir=\"rtl\">פרשת שמע</span> .",
    "<b>und zwei nachher.</b> Nämlich des Morgens <span dir=\"rtl\">אהבה רבה ,יוצר אור</span> und <span dir=\"rtl\">גאולה</span> Des Abends <span dir=\"rtl\">מעריב גאולה ,אהבת עולם ,ערבים</span> und <span dir=\"rtl\">השכיבנו</span> .",
    "<b>eine Schlussformel anzubringen.</b> Die ganze Stelle von <span dir=\"rtl\">מקום שאמרו</span> an wird hier als ein allgemeines, auf alle anderen <span dir=\"rtl\">ברכות</span> sich auch beziehendes Gesetz mit eingeschaltet. — Unter Schlussformel versteht man einen mit <span dir=\"rtl\">ברוך</span> anfangenden Satz, der das Ganze schliesst. Z. B. <span dir=\"rtl\">ברוך אתה ה׳ גאל ישראל</span> .",
    "<b>Man gedenke des Auszuges aus Ägypten auch in der Nachtzeit.</b> D. h. es ist Pflicht auch in der Nacht <span dir=\"rtl\">פרשת ציצית</span> zu sprechen, weil darin des Auszuges Erwähnung geschieht.",
    "<b>Ich bin jetzt beinah.</b> So nach einer Baraita im Jeruschalmi. Der babylonische Talmud jedoch sagt: R. Elasar ben Asarja sei damals nur 18 Jahre alt, aber bereits grau gewesen, wie ein Greis von siebzig Jahren. Nach Maimonides ist er durch vieles Studieren grau geworden."
  ])
  text?: string[];

  /**
   * The first available `Ref` to the section of text passed in the API.
   */
  firstSectionRef?: string;
}

const getTextsV3ResponseExample : v3TextsJson = #{
  versions: #[
    #{
      status: "locked",
      priority: 2,
      license: "CC-BY-SA",
      versionNotes: "<i>Miqra According to the Masorah</i> (MAM) is a digital Hebrew edition of the Tanakh based on the Aleppo Codex and related manuscripts. It is designed for readers, and as such it contains added elements to aid vocalization of the text. For instance: When an accent is marked in an unstressed syllable, an extra accent is added in the proper place (<i>pashta</i>, <i>zarqa</i>, <i>segol</i>, <i>telisha</i>). <i>Legarmeih</i> and <i>paseq</i> are visibly distinguished. <i>Qamaz qatan</i> is indicated by its designated Unicode character (alternatives are documented where traditions differ about its application).<br>The text of MAM is fully documented. The <a href=\"https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94/%D7%9E%D7%99%D7%93%D7%A2_%D7%A2%D7%9C_%D7%9E%D7%94%D7%93%D7%95%D7%A8%D7%94_%D7%96%D7%95\">complete introduction</a> to the edition (Hebrew) explains the types of editorial decisions that have been made and the reasons for them (<a href=\"https://en.wikisource.org/wiki/User:Dovi/Miqra_according_to_the_Masorah#About_this_Edition_(English_Abstract)\">English abstract</a>). In addition, every word in the Bible about which there is some textual concern or ambiguity includes a documentation note; these notes can be viewed conveniently <a href=\"https://bdenckla.github.io/MAM-with-doc/\">here</a>. If an error is discovered, it may be reported to <a href=\"https://he.wikisource.org/wiki/%D7%A9%D7%99%D7%97%D7%AA_%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi\">User:Dovi</a> at Hebrew Wikisource. Please check the documentation notes before reporting an error.",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "מקרא על פי המסורה",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      versionSource: "https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94",
      versionTitle: "Miqra according to the Masorah",
      text: "וַיְהִ֖י בִּימֵ֣י אֲחַשְׁוֵר֑וֹשׁ ה֣וּא אֲחַשְׁוֵר֗וֹשׁ הַמֹּלֵךְ֙ מֵהֹ֣דּוּ וְעַד־כּ֔וּשׁ שֶׁ֛בַע וְעֶשְׂרִ֥ים וּמֵאָ֖ה מְדִינָֽה׃",
    }
  ],
  available_versions: #[
    #{
      status: "locked",
      priority: 2,
      license: "CC-BY-SA",
      versionNotes: "<i>Miqra According to the Masorah</i> (MAM) is a digital Hebrew edition of the Tanakh based on the Aleppo Codex and related manuscripts. It is designed for readers, and as such it contains added elements to aid vocalization of the text. For instance: When an accent is marked in an unstressed syllable, an extra accent is added in the proper place (<i>pashta</i>, <i>zarqa</i>, <i>segol</i>, <i>telisha</i>). <i>Legarmeih</i> and <i>paseq</i> are visibly distinguished. <i>Qamaz qatan</i> is indicated by its designated Unicode character (alternatives are documented where traditions differ about its application).<br>The text of MAM is fully documented. The <a href=\"https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94/%D7%9E%D7%99%D7%93%D7%A2_%D7%A2%D7%9C_%D7%9E%D7%94%D7%93%D7%95%D7%A8%D7%94_%D7%96%D7%95\">complete introduction</a> to the edition (Hebrew) explains the types of editorial decisions that have been made and the reasons for them (<a href=\"https://en.wikisource.org/wiki/User:Dovi/Miqra_according_to_the_Masorah#About_this_Edition_(English_Abstract)\">English abstract</a>). In addition, every word in the Bible about which there is some textual concern or ambiguity includes a documentation note; these notes can be viewed conveniently <a href=\"https://bdenckla.github.io/MAM-with-doc/\">here</a>. If an error is discovered, it may be reported to <a href=\"https://he.wikisource.org/wiki/%D7%A9%D7%99%D7%97%D7%AA_%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi\">User:Dovi</a> at Hebrew Wikisource. Please check the documentation notes before reporting an error.",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "מקרא על פי המסורה",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94",
      versionTitle: "Miqra according to the Masorah",
    },
    #{
      status: "locked",
      priority: 2,
      license: "CC-BY-NC",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "JPS, 1985",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/JPS_1985.png",
      purchaseInformationURL: "https://www.nebraskapress.unl.edu/jps/9780827602526/",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://jps.org/books/tanakh-the-holy-scriptures-blue/",
      versionTitle: "Tanakh: The Holy Scriptures, published by JPS",
    },
    #{
      status: "locked",
      priority: 1,
      license: "Public Domain",
      versionNotes: "This 1917 translation by the Jewish Publication Society is in the public domain. JPS graciously shared digital images of this text with the Open Siddur Project, from which the text was imported by Sefaria.",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "כתבי הקודש: תרגום חדש (1917 JPS)",
      versionNotesInHebrew: "תרגום JPS 1917 קיים בנחלת הכלל. הסריקות באדיבות JPS. שעתוק הטקסט תודות לפרויקט Open Siddur, משם יובא הטקסט למאגר ספריא",
      shortVersionTitle: "JPS 1917",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "http://opensiddur.org/2010/08/%D7%AA%D7%A0%D7%B4%D7%9A-the-holy-scriptures-a-new-translation-jps-1917/",
      versionTitle: "The Holy Scriptures: A New Translation (JPS 1917)",
    },
    #{
      status: "locked",
      priority: 1,
      license: "Public Domain",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "תנ״ך מלווה בטעמי מקרא",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "http://www.tanach.us/Tanach.xml",
      versionTitle: "Tanach with Ta'amei Hamikra",
    },
    #{
      status: "locked",
      priority: "",
      license: "Public Domain",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "תנ״ך - טקסט בלבד",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "http://www.tanach.us/Tanach.xml",
      versionTitle: "Tanach with Text Only",
    },
    #{
      status: "locked",
      priority: "",
      license: "Public Domain",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "תנ״ך עם ניקוד",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "http://www.tanach.us/Tanach.xml",
      versionTitle: "Tanach with Nikkud",
    },
    #{
      status: "",
      priority: "",
      license: "",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "תרגום קהילת ספריא",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://www.sefaria.org",
      versionTitle: "Sefaria Community Translation",
    },
    #{
      status: "locked",
      priority: "",
      license: "CC-BY",
      versionNotes: "To enhance the quality of this text, obvious translation errors were corrected in accordance with the Hebrew source",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "כתובים' על פי רש״י, רבי שרגא זילברשטיין",
      versionNotesInHebrew: "כדי לשפר את איכות הטקסט הזה, שונו שגיאות תרגום ברורות בהתאם למקור העברי",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "http://www.sefaria.org/shraga-silverstein",
      versionTitle: "The Rashi Ketuvim by Rabbi Shraga Silverstein",
    },
    #{
      status: "locked",
      priority: "",
      license: "CC-BY-NC",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/9f4b3fedfe5a8889a3a7b3b7f3022091.png",
      purchaseInformationURL: "https://korenpub.com/collections/tanakh",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://www.korenpub.com/koren_en_usd/koren/tanakh-bible/the-koren-jerusalem-bible.html",
      versionTitle: "The Koren Jerusalem Bible",
    },
    #{
      status: "locked",
      priority: "",
      license: "CC-BY",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/958565938f3a7ed617834d467ac93c9f.png",
      purchaseInformationURL: "https://www.israelbookshoppublications.com/store/pc/Metsudah-Five-Megilloth-w-Rashi-26p309.htm",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://www.judaicaplace.com/search/brand/Metsudah-Publications/",
      versionTitle: "The Metsudah Five Megillot, Lakewood, N.J., 2001",
    },
    #{
      status: "locked",
      priority: "",
      license: "CC-BY",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "חמש מגילות, הוצאת 'מצודה', לייקווד תשס\"א",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/232433ac3323606604f21e0c70f0c061.png",
      purchaseInformationURL: "https://www.israelbookshoppublications.com/store/pc/Metsudah-Five-Megilloth-w-Rashi-26p309.htm",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "https://www.judaicaplace.com/search/brand/Metsudah-Publications/",
      versionTitle: "The Metsudah Five Megillot, Lakewood, N.J., 2001",
    },
    #{
      status: "locked",
      priority: "",
      license: "",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "מגילת אסתר - מהדורה פורימית!!",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "https://www.sefaria.org",
      versionTitle: "Megillat Esther - Purim Edition!!",
    },
    #{
      status: "locked",
      priority: "",
      license: "Public Domain",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "fr",
      languageFamilyName: "french",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://fr.wikisource.org/wiki/Bible_du_Rabbinat_1899",
      versionTitle: "Bible du Rabbinat 1899 [fr]",
    },
    #{
      status: "",
      priority: "",
      license: "CC0",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "מגילת אמוג'י",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "https://www.sefaria.org",
      versionTitle: "Emoji Megillah",
    },
    #{
      status: "",
      priority: "",
      license: "CC0",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://www.sefaria.org",
      versionTitle: "Emoji Megillah",
    },
    #{
      status: "",
      priority: "",
      license: "Public Domain",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "Izaak Cylkow, 1841 - 1908",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "pl",
      languageFamilyName: "polish",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "http://bibliepolskie.pl/",
      versionTitle: "Bible in Polish, trans. Izaak Cylkow, 1841 - 1908 [pl]",
    },
    #{
      status: "",
      priority: "",
      license: "Public Domain",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "it",
      languageFamilyName: "italian",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "http://www.archivio-torah.it",
      versionTitle: "Ester. Traduzione italiana di Samuel David Luzzatto, 1872 [it]",
    },
    #{
      status: "",
      priority: "",
      license: "",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "fa",
      languageFamilyName: "persian",
      isSource: false,
      isPrimary: false,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "http://www.iranjewish.com/megilla/megilla_main.htm",
      versionTitle: "Book of Esther in Farsi, trans. by Pole-Choubi, synagogue Talmood Torah [fa]",
    },
    #{
      status: "",
      priority: "",
      license: "",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "fa",
      languageFamilyName: "persian",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "http://www.iranjewish.com/megilla/megilla_main.htm",
      versionTitle: "Book of Esther in Farsi, trans. by Pole-Choubi, synagogue Talmood Torah, LTR [fa]",
    },
    #{
      status: "",
      priority: "",
      license: "Public Domain",
      versionNotes: "This 1941 translation published by Yehoʼash Farlag Gezelshaft is in the public domain. A transcribed digitized version was produced by Itsik \"Robert\" Goldenberg, et al, by the Yehoyesh Project (1998-2006) under the direction of Leonard Prager. That version was graciously shared with the Open Siddur Project, from which the text was imported by Sefaria.",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "yi",
      languageFamilyName: "yiddish",
      isSource: false,
      isPrimary: false,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "http://opensiddur.org/praxes/study/yehoyeshs-yiddish-translation-of-the-tanakh/",
      versionTitle: "Yehoyesh's Yiddish Tanakh Translation [yi]",
    },
    #{
      status: "locked",
      priority: "",
      license: "",
      versionNotes: "<b>Translator:</b> Marion Kaufmann, based on german translations of Tur-Sinai, Martín Buber and Franz Rosenzwig<br><b>Review and correction:</b> Manes Kogan<br><b>Final Review:</b> Batia Dorfman",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "es",
      languageFamilyName: "spanish",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://www.seminariorabinico.org/wp-content/uploads/El-libro-de-Ester-Meguila-Ester.pdf",
      versionTitle: "El libro de Ester - Meguila Ester - Seminario Rabínico [es]",
    },
    #{
      status: "",
      priority: "",
      license: "",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "Samuel Cahen, 1831",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "fr",
      languageFamilyName: "french",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://www.levangile.com/Bible-CAH-1-1-1-complet-Contexte-oui.htm",
      versionTitle: "La Bible, Traduction Nouvelle, Samuel Cahen, 1831 [fr]",
    },
    #{
      status: "locked",
      priority: "",
      license: "Public Domain",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "eo",
      languageFamilyName: "esperanto",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://eo.wikisource.org/wiki/Malnova_Testamento_(Zamenhof)/Ester/1",
      versionTitle: "La Malnova Testamento, L.L.Zamenhof [eo]",
    },
    #{
      status: "",
      priority: "",
      license: "",
      versionNotes: "Digitized by Chajm Guski and Marina Struse",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "de",
      languageFamilyName: "german",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://www.talmud.de/tlmd/tanach/",
      versionTitle: "Die Heilige Schrift, trans. Dr. Simon Bernfeld, Berlin, 1902 - German [de]",
    },
    #{
      status: "locked",
      priority: "",
      license: "PD",
      versionNotes: "",
      formatAsPoetry: "",
      digitizedBySefaria: true,
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      title: "Esther",
      versionSource: "https://he.wikisource.org/wiki/%D7%9E%D7%A7%D7%A8%D7%90_%D7%9E%D7%91%D7%95%D7%90%D7%A8",
      versionTitle: "Miqra Mevoar, trans. and edited by David Kokhav, Jerusalem 2020",
    },
    #{
      status: "",
      priority: "",
      license: "",
      versionNotes: "<a href=\"http://purl.org/jps/rjps-preface\">Read the Preface to the Revised JPS Edition</a>\n<br><br>\n<a href=\"http://purl.org/jps/gender\">Read the Notes on Gender in Translation for the Revised JPS Edition</a>\n<br><br>\n<a href=\"https://www.sefaria.org/collections/commentary-on-the-usage-and-rendering-of-%D7%90%D7%99%D7%A9?tab=sheets\">Read a Commentary on the Hebrew word 'ish in the Revised JPS Edition</a>",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      shortVersionTitle: "Revised JPS, 2023",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/JPS-Tanakh-Gender-Sensitive-Edition-Cover-300x450.jpg",
      purchaseInformationURL: "https://jps.org/books/the-jps-tanakh-gender-sensitive-edition/",
      hasManuallyWrappedRefs: "",
      actualLanguage: "en",
      languageFamilyName: "english",
      isSource: false,
      isPrimary: false,
      direction: "ltr",
      language: "en",
      title: "Esther",
      versionSource: "https://jps.org/books/the-jps-tanakh-gender-sensitive-edition/",
      versionTitle: "THE JPS TANAKH: Gender-Sensitive Edition",
    }
  ],
  ref: "Esther 1:1",
  heRef: "אסתר א׳:א׳",
  sections: #["1", "1"],
  toSections: #["1", "1"],
  sectionRef: "Esther 1",
  heSectionRef: "אסתר א׳",
  firstAvailableSectionRef: "Esther 1:1",
  isSpanning: false,
  spanningRefs: #["Esther 1:1"],
  next: "Esther 2",
  title: "Esther 1",
  book: "Esther",
  heTitle: "אסתר",
  primary_category: "Tanakh",
  type: "Tanakh",
  indexTitle: "Esther",
  categories: #["Tanakh", "Writings"],
  heIndexTitle: "אסתר",
  isComplex: false,
  isDependant: false,
  order: #[34, 8],
  collectiveTitle: "",
  heCollectiveTitle: "",
  alts: #[],
  lengths: #[10, 167],
  length: 10,
  textDepth: 2,
  sectionNames: #["Chapter", "Verse"],
  addressTypes: #["Perek", "Pasuk"],
  titleVariants: #["Est.", "Est", "Ester", "Esth.", "Esth", "Esther"],
  heTitleVariants: #["מגילת אסתר", "אסתר"],
  index_offsets_by_depth: #{},
  warnings: #[],
};

const getTextsV1ResponseExample : textAPIReponse = #{
  ref: "Shabbat 22a:1",
  heRef: "שבת כ״ב א:א׳",
  isComplex: false,
  text: #[],
  he: #[],
  versions: #[],
  textDepth: 2,
  sectionNames: #[],
  addressTypes: #[],
  lengths: #[],
  length: 314,
  heTitle: "שבת כ״ב א",
  titleVariants: #[],
  heTitleVariants: #[],
  type: "Talmud",
  primary_category: "Talmud",
  book: "Shabbat",
  categories: #[],
  order: #[],
  sections: #[],
  toSections: #[],
  isDependant: false,
  indexTitle: "Shabbat",
  heIndexTitle: "שבת",
  sectionRef: "Shabbat 22a",
  firstAvailableSectionRef: "Shabbat 22a:1",
  heSectionRef: "שבת כ״ב א",
  isSpanning: false,
  versionTitle: "William Davidson Edition - English",
  versionTitleInHebrew: "מהדורת וויליאם דייוידסון - אנגלית",
  shortVersionTitle: "Koren - Steinsaltz",
  shortVersionTitleInHebrew: "",
  versionSource: "https://korenpub.com/collections/the-noe-edition-koren-talmud-bavli-1",
  versionStatus: "locked",
  versionNotes: "English from The William Davidson digital edition of the <a href='https://korenpub.com/collections/the-noe-edition-koren-talmud-bavli-1'>Koren Noé Talmud</a>, with commentary by <a href='/adin-even-israel-steinsaltz'>Rabbi Adin Even-Israel Steinsaltz</a>",
  extendedNotes: "",
  extendedNotesHebrew: "",
  versionNotesInHebrew: "תרגום אנגלי של תלמוד מהדורת ויליאם דיוידסון מתוך מהדורת <a href='https://korenpub.com/collections/the-noe-edition-koren-talmud-bavli-1'>Noé</a> עם פירוש <a href='/adin-even-israel-steinsaltz'>הרב עדין אבן ישראל שטיינזלץ</a>, בהוצאת קורן ירושלים",
  digitizedBySefaria: false,
  license: "CC-BY-NC",
  formatEnAsPoetry: false,
  heVersionTitle: "William Davidson Edition - Vocalized Aramaic",
  heVersionTitleInHebrew: "מהדורת וויליאם דייוידסון - ארמית המנוקד",
  heShortVersionTitle: "",
  heShortVersionTitleInHebrew: "",
  heVersionSource: "https://www.sefaria.org",
  heVersionStatus: "locked",
  heVersionNotes: "Aramaic from The William Davidson digital edition of the <a href='https://www.korenpub.com/koren_en_usd/koren/talmud/koren-talmud-bavli-no.html'>Koren Noé Talmud</a>, with commentary by <a href='/adin-even-israel-steinsaltz'>Rabbi Adin Even-Israel Steinsaltz</a>\nNikud (vocalization) by <a href='https://dicta.org.il/'>Dicta - the Israel Center for Text Analysis</a>",
  heExtendedNotes: "",
  heExtendedNotesHebrew: "",
  heVersionNotesInHebrew: "הטקסט הארמי של מהדורת וויליאם דייוידסון הדיגיטלית מתוך <a href='https://www.korenpub.com/koren_en_usd/koren/talmud/koren-talmud-bavli-no.html'>תלמוד קורן מהדורת נאה</a>, עם באור מאת <a href='/adin-even-israel-steinsaltz'>הרב אבן־ישראל (שטיינזלץ)</a>\nמנוקד על ידי <a href='https://dicta.org.il/'>דיקטה - המרכז הישראלי לניתוח טקסטים</a>",
  heDigitizedBySefaria: false,
  heLicense: "CC-BY-NC",
  formatHeAsPoetry: false,
  title: "Shabbat 22a",
  heBook: "שבת",
  alts: #[],
  index_offsets_by_depth: #{},
  next: "Shabbat 22b",
  prev: "Shabbat 21b",
  commentary: #[],
  sheets: #[],
  layer: #[],
};

const getVersionsResponseExample : VersionJSON[] = #[
  #{
    title: "Rashi on Ecclesiastes",
    versionTitle: "The Metsudah Five Megillot, Lakewood, N.J., 2001",
    versionSource: "https://www.nli.org.il/he/books/NNL_ALEPH002162036",
    language: "he",
    status: "locked",
    license: "CC-BY",
    versionNotes: "",
    digitizedBySefaria: "",
    priority: 2,
    versionTitleInHebrew: "",
    versionNotesInHebrew: "",
    extendedNotes: "",
    extendedNotesHebrew: "",
    purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/ba0b4357b240eff4b28b7fcfc4669d56.png",
    purchaseInformationURL: "https://www.israelbookshoppublications.com/store/pc/Metsudah-Five-Megilloth-w-Rashi-26p309.htm",
    shortVersionTitle: "",
    shortVersionTitleInHebrew: "",
    firstSectionRef: "Rashi on Ecclesiastes 1:1",
  },
  #{
    title: "Rashi on Ecclesiastes",
    versionTitle: "The Metsudah Five Megillot, Lakewood, N.J., 2001",
    versionSource: "https://www.nli.org.il/he/books/NNL_ALEPH002162036",
    language: "en",
    status: "locked",
    license: "CC-BY",
    versionNotes: "",
    digitizedBySefaria: "",
    priority: 2,
    versionTitleInHebrew: "",
    versionNotesInHebrew: "",
    extendedNotes: "",
    extendedNotesHebrew: "",
    purchaseInformationImage: "https://storage.googleapis.com/sefaria-physical-editions/00c61bd3103f9398bf080832c4a0221f.png",
    purchaseInformationURL: "https://www.israelbookshoppublications.com/store/pc/Metsudah-Five-Megilloth-w-Rashi-26p309.htm",
    shortVersionTitle: "",
    shortVersionTitleInHebrew: "",
    firstSectionRef: "Rashi on Ecclesiastes 1:1",
  },
  #{
    title: "Rashi on Ecclesiastes",
    versionTitle: "On Your Way",
    versionSource: "http://mobile.tora.ws/",
    language: "he",
    status: "locked",
    license: "Public Domain",
    versionNotes: "",
    digitizedBySefaria: "",
    priority: 1,
    versionTitleInHebrew: "ובלכתך בדרך",
    versionNotesInHebrew: "",
    extendedNotes: "",
    extendedNotesHebrew: "",
    purchaseInformationImage: "",
    purchaseInformationURL: "",
    shortVersionTitle: "",
    shortVersionTitleInHebrew: "",
    firstSectionRef: "Rashi on Ecclesiastes 1:1",
  },
  #{
    title: "Rashi on Ecclesiastes",
    versionTitle: "Sefaria Community Translation",
    versionSource: "https://www.sefaria.org",
    language: "en",
    status: "",
    license: "",
    versionNotes: "",
    digitizedBySefaria: "",
    priority: "",
    versionTitleInHebrew: "תרגום קהילת ספריא",
    versionNotesInHebrew: "",
    extendedNotes: "",
    extendedNotesHebrew: "",
    purchaseInformationImage: "",
    purchaseInformationURL: "",
    shortVersionTitle: "",
    shortVersionTitleInHebrew: "",
    firstSectionRef: "Rashi on Ecclesiastes 3:3",
  },
  #{
    title: "Rashi on Ecclesiastes",
    versionTitle: "The Five Megilloth, English translation by A. Cohen, Soncino Press, 1946",
    versionSource: "https://www.nli.org.il/en/books/NNL_ALEPH002644163/NLI",
    language: "en",
    status: "locked",
    license: "CC-BY",
    versionNotes: "",
    digitizedBySefaria: "",
    priority: "",
    versionTitleInHebrew: "",
    versionNotesInHebrew: "",
    extendedNotes: "",
    extendedNotesHebrew: "",
    purchaseInformationImage: "",
    purchaseInformationURL: "",
    shortVersionTitle: "Abraham Cohen, Soncino Press, 1946",
    shortVersionTitleInHebrew: "",
    firstSectionRef: "Rashi on Ecclesiastes 1:1",
  }
];

const textAPIReponseModelExample : textAPIReponse = #{
  ref: "Mishnah Peah 4:2",
  heRef: "משנה פאה ד׳:ב׳",
  isComplex: false,
  text: #[
    "Peah is given from [the crop] while it is still connected with the soil. But in the case of hanging vine-branches and the date-palm, the owner brings down [the fruit] and distributes it among the poor. Rabbi Shimon says: the same applies to smooth nut trees. Even if ninety-nine [of the poor] say [to the owner] to distribute it and one says to leave it in the field, this latter is listened to, since he spoke in accordance with the halakhah.",
    "With hanging vine-branches and date-palm trees it is not so; even if ninety-nine [of the poor] say [to the owner] to leave it in the field and one says to distribute it, this latter is listened to, since he spoke in accordance with the halakhah.",
    "If [a poor man] took some of the peah [already collected] and threw it onto the remainder [not yet collected], he gets none of it. If he fell down upon it, or spread his cloak over it, they take the peah away from him. The same applies to gleanings and the forgotten sheaf.",
    "[The poor] may not harvest peah with scythes or tear it out [of the ground] with spades, so that they might not strike one another [with these implements].",
    "There are three times a day [the poor] make a search [in the field for peah]: morning, noon, and sunset. Rabban Gamaliel says: these [times] were only set lest they reduce them. Rabbi Akiva says: these were set lest they add to them. [The men] of Bet Namer used to have the poor harvest [the peah] with the aid of a rope, and they left peah at the end of each furrow.",
    "A non-Jew who harvested his field and then converted, he is exempt from [leaving] gleanings, the forgotten sheaf and peah. Rabbi Judah makes him liable to leave the forgotten sheaf, since he becomes liable for the forgotten sheaf at the time of their binding.",
    "One who dedicated standing grain [to the Temple] and then redeemed it while it was still standing grain, he is liable [to give the agricultural gifts to the poor]. [If he dedicated] sheaves and redeemed them while they were still sheaves, he is liable. [If he dedicated] standing grain and redeemed it [when it was already in] sheaves, he is exempt, since at the time when it became liable it was exempt.",
    "Similarly one who dedicates his produce prior to the stage when they are subject to tithes and then redeemed them, they are liable [to be tithed]. If [he dedicated them] when they had already become subject to tithes and then redeemed them, they are liable [to be tithed]. If he dedicated them before they had ripened, and they became ripe while in the possession of the [Temple] treasurer, and he then redeemed them, they are exempt, since at the time when they would have been liable, they were exempt.",
    "One who collected peah and said, “This is for so-and-so a poor man:” Rabbi Eliezer says: he has thus acquired it for him. The sages say: he must give it to the first poor man he finds. Gleanings, the forgotten sheaf and the peah of non-Jews are subject to tithes, unless he [the non-Jew] had declared them ownerless.",
    "What are gleanings? That which falls down at the time of harvesting. If while he was harvesting, he harvested a handful, or plucked a fistful, and then a thorn pricked him, and what he had in his hand fell to the ground, it still belongs to the owner. [That which drops from] inside the hand or the sickle [belongs] to the poor, but [that which falls from] the back of the hand or the sickle [belongs] to the owner. [That which falls from] the top of the hand or sickle: Rabbi Ishmael says: to the poor; But Rabbi Akiva says: to the owner.",
    "#[Grain found in] ant holes where the stalks are still standing, behold it still belongs to the owner. After the harvesters #[had passed over them], those found in the top parts #[of the ant holes belong] to the poor, but #[those found] on the bottom parts [belong] to the owner. Rabbi Meir says: it all belongs to the poor, for gleanings about which there is any doubt are regarded as gleanings."
  ],
  he: #[
    "הַפֵּאָה נִתֶּנֶת בִּמְחֻבָּר לַקַּרְקָע. בְּדָלִית וּבְדֶקֶל, בַּעַל הַבַּיִת מוֹרִיד וּמְחַלֵּק לָעֲנִיִּים. רַבִּי שִׁמְעוֹן אוֹמֵר, אַף בַּחֲלִיקֵי אֱגוֹזִים. אֲפִלּוּ תִשְׁעִים וְתִשְׁעָה אוֹמְרִים לְחַלֵּק וְאֶחָד אוֹמֵר לָבוֹז, לָזֶה שׁוֹמְעִין, שֶׁאָמַר כַּהֲלָכָה: \n",
    "בְּדָלִית וּבְדֶקֶל אֵינוֹ כֵן, אֲפִלּוּ תִשְׁעִים וְתִשְׁעָה אוֹמְרִים לָבוֹז וְאֶחָד אוֹמֵר לְחַלֵּק, לָזֶה שׁוֹמְעִין, שֶׁאָמַר כַּהֲלָכָה: \n",
    "נָטַל מִקְצָת פֵּאָה וּזְרָקָהּ עַל הַשְּׁאָר, אֵין לוֹ בָהּ כְּלוּם. נָפַל לוֹ עָלֶיהָ, וּפֵרֵשׂ טַלִּיתוֹ עָלֶיהָ, מַעֲבִירִין אוֹתָהּ הֵימֶנּוּ. וְכֵן בְּלֶקֶט, וְכֵן בְּעֹמֶר הַשִּׁכְחָה: \n",
    "פֵּאָה אֵין קוֹצְרִין אוֹתָהּ בְּמַגָּלוֹת, וְאֵין עוֹקְרִין אוֹתָהּ בְּקַרְדֻּמּוֹת, כְּדֵי שֶׁלֹּא יַכּוּ אִישׁ אֶת רֵעֵהוּ: \n",
    "שָׁלשׁ אַבְעָיוֹת בַּיּוֹם, בַּשַּׁחַר וּבַחֲצוֹת וּבַמִּנְחָה. רַבָּן גַּמְלִיאֵל אוֹמֵר, לֹא אָמְרוּ אֶלָּא כְּדֵי שֶׁלֹּא יִפְחֲתוּ. רַבִּי עֲקִיבָא אוֹמֵר, לֹא אָמְרוּ אֶלָּא כְּדֵי שֶׁלֹּא יוֹסִיפוּ. שֶׁל בֵּית נָמֵר הָיוּ מְלַקְּטִין עַל הַחֶבֶל, וְנוֹתְנִים פֵּאָה מִכָּל אֻמָּן וְאֻמָּן: \n",
    "עוֹבֵד כּוֹכָבִים שֶׁקָּצַר אֶת שָׂדֵהוּ וְאַחַר כָּךְ נִתְגַּיֵּר, פָּטוּר מִן הַלֶּקֶט וּמִן הַשִּׁכְחָה וּמִן הַפֵּאָה. רַבִּי יְהוּדָה מְחַיֵּב בְּשִׁכְחָה, שֶׁאֵין הַשִּׁכְחָה אֶלָּא בִשְׁעַת הָעִמּוּר: \n",
    "הִקְדִּישׁ קָמָה וּפָדָה קָמָה, חַיָּב. עֳמָרִין וּפָדָה עֳמָרִין, חַיָּב. קָמָה וּפָדָה עֳמָרִין, פְּטוּרָה, שֶׁבִּשְׁעַת חוֹבָתָהּ הָיְתָה פְטוּרָה: \n",
    "כַּיּוֹצֵא בוֹ, הַמַּקְדִּישׁ פֵּרוֹתָיו עַד שֶׁלֹּא בָאוּ לְעוֹנַת הַמַּעַשְׂרוֹת, וּפְדָאָן, חַיָּבִין. מִשֶּׁבָּאוּ לְעוֹנַת הַמַּעַשְׂרוֹת, וּפְדָאָן, חַיָּבִין. הִקְדִּישָׁן עַד שֶׁלֹּא נִגְמְרוּ וּגְמָרָן הַגִּזְבָּר, וְאַחַר כָּךְ פְּדָאָן, פְּטוּרִים, שֶׁבִּשְׁעַת חוֹבָתָן הָיוּ פְטוּרִים: \n",
    "מִי שֶׁלָּקַט אֶת הַפֵּאָה וְאָמַר הֲרֵי זוֹ לְאִישׁ פְּלוֹנִי עָנִי, רַבִּי אֱלִיעֶזֶר אוֹמֵר, זָכָה לוֹ. וַחֲכָמִים אוֹמְרִים, יִתְּנֶנָּה לֶעָנִי שֶׁנִּמְצָא רִאשׁוֹן. הַלֶּקֶט וְהַשִּׁכְחָה וְהַפֵּאָה שֶׁל עוֹבֵד כּוֹכָבִים חַיָּב בְּמַעַשְׂרוֹת, אֶלָּא אִם כֵּן הִפְקִיר: \n",
    "אֵיזֶהוּ לֶקֶט, הַנּוֹשֵׁר בִּשְׁעַת הַקְּצִירָה. הָיָה קוֹצֵר, קָצַר מְלֹא יָדוֹ, תָּלַשׁ מְלֹא קֻמְצוֹ, הִכָּהוּ קוֹץ וְנָפַל מִיָּדוֹ לָאָרֶץ, הֲרֵי הוּא שֶׁל בַּעַל הַבָּיִת. תּוֹךְ הַיָּד וְתוֹךְ הַמַּגָּל, לָעֲנִיִּים. אַחַר הַיָּד וְאַחַר הַמַּגָּל, לְבַעַל הַבָּיִת. רֹאשׁ הַיָּד וְרֹאשׁ הַמַּגָּל, רַבִּי יִשְׁמָעֵאל אוֹמֵר, לָעֲנִיִּים. רַבִּי עֲקִיבָא אוֹמֵר, לְבַעַל הַבָּיִת: \n",
    "חוֹרֵי הַנְּמָלִים שֶׁבְּתוֹךְ הַקָּמָה, הֲרֵי הֵן שֶׁל בַּעַל הַבָּיִת. שֶׁלְּאַחַר הַקּוֹצְרִים, הָעֶלְיוֹנִים לָעֲנִיִּים, וְהַתַּחְתּוֹנִים שֶׁל בַּעַל הַבָּיִת. רַבִּי מֵאִיר אוֹמֵר, הַכֹּל לָעֲנִיִּים, שֶׁסְּפֵק לֶקֶט, לֶקֶט: \n"
  ],
  versions: #[
    #{
      title: "Mishnah Peah",
      versionTitle: "Torat Emet 357",
      versionSource: "http://www.toratemetfreeware.com/index.html?downloads",
      language: "he",
      status: "locked",
      license: "Public Domain",
      versionNotes: "",
      digitizedBySefaria: "",
      priority: 3,
      versionTitleInHebrew: "תורת אמת 357",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
    },
    #{
      title: "Mishnah Peah",
      versionTitle: "Mishnah, ed. Romm, Vilna 1913",
      versionSource: "https://www.nli.org.il/he/books/NNL_ALEPH001741739",
      language: "he",
      status: "locked",
      license: "Public Domain",
      versionNotes: "",
      digitizedBySefaria: true,
      priority: 2,
      versionTitleInHebrew: "משנה, מהדורת בית דפוס ראם, וילנא 1913",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
    },
    #{
      title: "Mishnah Peah",
      versionTitle: "Mishnah Yomit by Dr. Joshua Kulp",
      versionSource: "http://learn.conservativeyeshiva.org/mishnah/",
      language: "en",
      status: "locked",
      license: "CC-BY",
      versionNotes: "",
      digitizedBySefaria: "",
      priority: 1,
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "Dr. Joshua Kulp",
      shortVersionTitleInHebrew: "",
    },
    #{
      title: "Mishnah Peah",
      versionTitle: "Mischnajot mit deutscher Übersetzung und Erklärung. Berlin 1887-1933 [de]",
      versionSource: "https://www.nli.org.il/he/books/NNL_ALEPH002378149/NLI",
      language: "en",
      status: "locked",
      license: "Public Domain",
      versionNotes: "Ordnung Seraïm, übers. und erklärt von Ascher Samter. 1887.<br>Ordnung Moed, von Eduard Baneth. 1887-1927.<br>Ordnung Naschim, von Marcus Petuchowski u. Simon Schlesinger. 1896-1933.<br>Ordnung Nesikin, von David Hoffmann. 1893-1898.<br>Ordnung Kodaschim, von John Cohn. 1910-1925.<br>Ordnung Toharot, von David Hoffmann, John Cohn und Moses Auerbach. 1910-1933.",
      digitizedBySefaria: true,
      priority: 0.5,
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
    },
    #{
      title: "Mishnah Peah",
      versionTitle: "Talmud Bavli. German. Lazarus Goldschmidt. 1929 [de]",
      versionSource: "https://www.nli.org.il/he/books/NNL_ALEPH001042448/NLI",
      language: "en",
      status: "locked",
      license: "Public Domain",
      versionNotes: "",
      digitizedBySefaria: true,
      priority: 0.25,
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "Lazarus Goldschmidt, 1929",
      shortVersionTitleInHebrew: "",
    },
    #{
      title: "Mishnah Peah",
      versionTitle: "Open Mishnah",
      versionSource: "http://en.wikisource.org/wiki/Mishnah",
      language: "en",
      status: "locked",
      license: "CC-BY-SA",
      versionNotes: "",
      digitizedBySefaria: "",
      priority: "",
      versionTitleInHebrew: "משנה פתוחה",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
    },
    #{
      title: "Mishnah Peah",
      versionTitle: "Le Talmud de Jérusalem, traduit par Moise Schwab, 1878-1890 [fr]",
      versionSource: "https://www.nli.org.il/he/books/NNL_ALEPH002182155/NLI",
      language: "en",
      status: "locked",
      license: "Public Domain",
      versionNotes: "",
      digitizedBySefaria: "",
      priority: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
    },
    #{
      title: "Mishnah Peah",
      versionTitle: "Mishnah based on the Kaufmann manuscript, edited by Dan Be'eri",
      versionSource: "https://archive.org/details/MishnaCorrectedKaufman00WHOLE",
      language: "he",
      status: "locked",
      license: "PD",
      versionNotes: "",
      digitizedBySefaria: true,
      priority: "",
      versionTitleInHebrew: "",
      versionNotesInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
    }
  ],
  textDepth: 2,
  sectionNames: #["Chapter", "Mishnah"],
  addressTypes: #["Perek", "Mishnah"],
  lengths: #[8, 69],
  length: 8,
  heTitle: "משנה פאה",
  titleVariants: #[
    "M Peah",
    "Mishna Peah",
    "M. Peah",
    "Mishnah Péah",
    "Pe’ah",
    "Pe'ah",
    "Peah",
    "Mishnah Peah"
  ],
  heTitleVariants: #["פאה", "משנה פיאה", "משנה פאה"],
  type: "Mishnah",
  primary_category: "Mishnah",
  book: "Mishnah Peah",
  categories: #["Mishnah", "Seder Zeraim"],
  order: #[2, 2],
  sections: #[4, 2],
  toSections: #[4, 2],
  isDependant: false,
  indexTitle: "Mishnah Peah",
  heIndexTitle: "משנה פאה",
  sectionRef: "Mishnah Peah 4",
  firstAvailableSectionRef: "Mishnah Peah 4:2",
  heSectionRef: "משנה פאה ד׳",
  isSpanning: false,
  versionTitle: "Mishnah Yomit by Dr. Joshua Kulp",
  versionTitleInHebrew: "",
  shortVersionTitle: "Dr. Joshua Kulp",
  shortVersionTitleInHebrew: "",
  versionSource: "http://learn.conservativeyeshiva.org/mishnah/",
  versionStatus: "locked",
  versionNotes: "",
  extendedNotes: "",
  extendedNotesHebrew: "",
  versionNotesInHebrew: "",
  digitizedBySefaria: false,
  license: "CC-BY",
  formatEnAsPoetry: false,
  heVersionTitle: "Torat Emet 357",
  heVersionTitleInHebrew: "תורת אמת 357",
  heShortVersionTitle: "",
  heShortVersionTitleInHebrew: "",
  heVersionSource: "http://www.toratemetfreeware.com/index.html?downloads",
  heVersionStatus: "locked",
  heVersionNotes: "",
  heExtendedNotes: "",
  heExtendedNotesHebrew: "",
  heVersionNotesInHebrew: "",
  heDigitizedBySefaria: false,
  heLicense: "Public Domain",
  formatHeAsPoetry: false,
  alts: #[],
  index_offsets_by_depth: #{},
  next: "Mishnah Peah 5",
  prev: "Mishnah Peah 3",
  commentary: #[],
  sheets: #[],
  layer: #[],
};

const v3TextsJsonModelExample : v3TextsJson = #{
  versions: #[
    #{
      status: "locked",
      priority: 2,
      license: "CC-BY-SA",
      versionNotes: "<i>Miqra According to the Masorah</i> (MAM) is a digital Hebrew edition of the Tanakh based on the Aleppo Codex and related manuscripts. It is designed for readers, and as such it contains added elements to aid vocalization of the text. For instance: When an accent is marked in an unstressed syllable, an extra accent is added in the proper place (<i>pashta</i>, <i>zarqa</i>, <i>segol</i>, <i>telisha</i>). <i>Legarmeih</i> and <i>paseq</i> are visibly distinguished. <i>Qamaz qatan</i> is indicated by its designated Unicode character (alternatives are documented where traditions differ about its application).<br>The text of MAM is fully documented. The <a href=\"https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94/%D7%9E%D7%99%D7%93%D7%A2_%D7%A2%D7%9C_%D7%9E%D7%94%D7%93%D7%95%D7%A8%D7%94_%D7%96%D7%95\">complete introduction</a> to the edition (Hebrew) explains the types of editorial decisions that have been made and the reasons for them (<a href=\"https://en.wikisource.org/wiki/User:Dovi/Miqra_according_to_the_Masorah#About_this_Edition_(English_Abstract)\">English abstract</a>). In addition, every word in the Bible about which there is some textual concern or ambiguity includes a documentation note; these notes can be viewed conveniently <a href=\"https://bdenckla.github.io/MAM-with-doc/\">here</a>. If an error is discovered, it may be reported to <a href=\"https://he.wikisource.org/wiki/%D7%A9%D7%99%D7%97%D7%AA_%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi\">User:Dovi</a> at Hebrew Wikisource. Please check the documentation notes before reporting an error.",
      formatAsPoetry: "",
      digitizedBySefaria: "",
      method: "",
      heversionSource: "",
      versionUrl: "",
      versionTitleInHebrew: "מקרא על פי המסורה",
      versionNotesInHebrew: "",
      shortVersionTitle: "",
      shortVersionTitleInHebrew: "",
      extendedNotes: "",
      extendedNotesHebrew: "",
      purchaseInformationImage: "",
      purchaseInformationURL: "",
      hasManuallyWrappedRefs: "",
      actualLanguage: "he",
      languageFamilyName: "hebrew",
      isSource: true,
      isPrimary: true,
      direction: "rtl",
      language: "he",
      versionSource: "https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94",
      versionTitle: "Miqra according to the Masorah",
      text: #[],
      firstSectionRef: "Obadiah 1",
    }
  ],
  available_versions: #[],
  ref: "Obadiah",
  heRef: "עובדיה",
  sections: #[],
  toSections: #[],
  sectionRef: "Obadiah",
  heSectionRef: "עובדיה",
  firstAvailableSectionRef: "Obadiah 1",
  isSpanning: false,
  spanningRefs: #[],
  next: "Obadiah 1",
  prev: "Obadiah 1",
  title: "Obadiah",
  book: "Obadiah",
  heTitle: "עובדיה",
  primary_category: "Tanakh",
  type: "Tanakh",
  indexTitle: "Obadiah",
  categories: #["Tanakh", "Prophets"],
  heIndexTitle: "עובדיה",
  isComplex: false,
  isDependant: false,
  order: #[18, 13],
  collectiveTitle: "",
  heCollectiveTitle: "",
  alts: #[],
  lengths: #[1, 21],
  length: 1,
  textDepth: 2,
  sectionNames: #["Chapter", "Verse"],
  addressTypes: #["Perek", "Pasuk"],
  titleVariants: #[
    "Ovadiah",
    "Ob.",
    "Oba.",
    "Ovadyah",
    "Ovadia",
    "Ovadya",
    "Abdias",
    "Obad",
    "Obadiah"
  ],
  heTitleVariants: #["עובדיה"],
  index_offsets_by_depth: #{},
  warnings: #[],
};

const v3TextsJson_versions_ModelExample : v3TextVersionsJSON = #{
  status: "locked",
  priority: 2,
  license: "CC-BY-SA",
  versionNotes: "<i>Miqra According to the Masorah</i> (MAM) is a digital Hebrew edition of the Tanakh based on the Aleppo Codex and related manuscripts. It is designed for readers, and as such it contains added elements to aid vocalization of the text. For instance: When an accent is marked in an unstressed syllable, an extra accent is added in the proper place (<i>pashta</i>, <i>zarqa</i>, <i>segol</i>, <i>telisha</i>). <i>Legarmeih</i> and <i>paseq</i> are visibly distinguished. <i>Qamaz qatan</i> is indicated by its designated Unicode character (alternatives are documented where traditions differ about its application).<br>The text of MAM is fully documented. The <a href=\"https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94/%D7%9E%D7%99%D7%93%D7%A2_%D7%A2%D7%9C_%D7%9E%D7%94%D7%93%D7%95%D7%A8%D7%94_%D7%96%D7%95\">complete introduction</a> to the edition (Hebrew) explains the types of editorial decisions that have been made and the reasons for them (<a href=\"https://en.wikisource.org/wiki/User:Dovi/Miqra_according_to_the_Masorah#About_this_Edition_(English_Abstract)\">English abstract</a>). In addition, every word in the Bible about which there is some textual concern or ambiguity includes a documentation note; these notes can be viewed conveniently <a href=\"https://bdenckla.github.io/MAM-with-doc/\">here</a>. If an error is discovered, it may be reported to <a href=\"https://he.wikisource.org/wiki/%D7%A9%D7%99%D7%97%D7%AA_%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi\">User:Dovi</a> at Hebrew Wikisource. Please check the documentation notes before reporting an error.",
  formatAsPoetry: "",
  digitizedBySefaria: "",
  method: "",
  heversionSource: "",
  versionUrl: "",
  versionTitleInHebrew: "מקרא על פי המסורה",
  versionNotesInHebrew: "",
  shortVersionTitle: "",
  shortVersionTitleInHebrew: "",
  extendedNotes: "",
  extendedNotesHebrew: "",
  purchaseInformationImage: "",
  purchaseInformationURL: "",
  hasManuallyWrappedRefs: "",
  actualLanguage: "he",
  languageFamilyName: "hebrew",
  isSource: true,
  isPrimary: true,
  direction: "rtl",
  language: "he",
  versionSource: "https://he.wikisource.org/wiki/%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9:Dovi/%D7%9E%D7%A7%D7%A8%D7%90_%D7%A2%D7%9C_%D7%A4%D7%99_%D7%94%D7%9E%D7%A1%D7%95%D7%A8%D7%94",
  versionTitle: "Miqra according to the Masorah",
  text: #[
    #[
      "חֲז֖וֹן עֹֽבַדְיָ֑ה כֹּֽה־אָמַר֩ אֲדֹנָ֨י יֱהֹוִ֜ה לֶאֱד֗וֹם שְׁמוּעָ֨ה שָׁמַ֜עְנוּ מֵאֵ֤ת יְהֹוָה֙ וְצִיר֙ בַּגּוֹיִ֣ם שֻׁלָּ֔ח ק֛וּמוּ וְנָק֥וּמָה עָלֶ֖יהָ לַמִּלְחָמָֽה׃",
      "הִנֵּ֥ה קָטֹ֛ן נְתַתִּ֖יךָ בַּגּוֹיִ֑ם בָּז֥וּי אַתָּ֖ה מְאֹֽד׃",
      "זְד֤וֹן לִבְּךָ֙ הִשִּׁיאֶ֔ךָ שֹׁכְנִ֥י בְחַגְוֵי־סֶ֖לַע מְר֣וֹם שִׁבְתּ֑וֹ אֹמֵ֣ר בְּלִבּ֔וֹ מִ֥י יוֹרִדֵ֖נִי אָֽרֶץ׃",
      "אִם־תַּגְבִּ֣יהַּ כַּנֶּ֔שֶׁר וְאִם־בֵּ֥ין כּֽוֹכָבִ֖ים שִׂ֣ים קִנֶּ֑ךָ מִשָּׁ֥ם אוֹרִֽידְךָ֖ נְאֻם־יְהֹוָֽה׃",
      "אִם־גַּנָּבִ֤ים בָּאֽוּ־לְךָ֙ אִם־שׁ֣וֹדְדֵי לַ֔יְלָה אֵ֣יךְ נִדְמֵ֔יתָה הֲל֥וֹא יִגְנְב֖וּ דַּיָּ֑ם אִם־בֹּֽצְרִים֙ בָּ֣אוּ לָ֔ךְ הֲל֖וֹא יַשְׁאִ֥ירוּ עֹלֵלֽוֹת׃",
      "אֵ֚יךְ נֶחְפְּשׂ֣וּ עֵשָׂ֔ו נִבְע֖וּ מַצְפֻּנָֽיו׃",
      "עַֽד־הַגְּב֣וּל שִׁלְּח֗וּךָ כֹּ֚ל אַנְשֵׁ֣י בְרִיתֶ֔ךָ הִשִּׁיא֛וּךָ יָכְל֥וּ לְךָ֖ אַנְשֵׁ֣י שְׁלֹמֶ֑ךָ לַחְמְךָ֗ יָשִׂ֤ימוּ מָזוֹר֙ תַּחְתֶּ֔יךָ אֵ֥ין תְּבוּנָ֖ה בּֽוֹ׃",
      "הֲל֛וֹא בַּיּ֥וֹם הַה֖וּא נְאֻם־יְהֹוָ֑ה וְהַאֲבַדְתִּ֤י חֲכָמִים֙ מֵֽאֱד֔וֹם וּתְבוּנָ֖ה מֵהַ֥ר עֵשָֽׂו׃",
      "וְחַתּ֥וּ גִבּוֹרֶ֖יךָ תֵּימָ֑ן לְמַ֧עַן יִכָּֽרֶת־אִ֛ישׁ מֵהַ֥ר עֵשָׂ֖ו מִקָּֽטֶל׃",
      "מֵחֲמַ֛ס אָחִ֥יךָ יַעֲקֹ֖ב תְּכַסְּךָ֣ בוּשָׁ֑ה וְנִכְרַ֖תָּ לְעוֹלָֽם׃",
      "בְּיוֹם֙ עֲמׇֽדְךָ֣ מִנֶּ֔גֶד בְּי֛וֹם שְׁב֥וֹת זָרִ֖ים חֵיל֑וֹ וְנׇכְרִ֞ים בָּ֣אוּ <span class=\"mam-kq-trivial\">שְׁעָרָ֗ו</span> וְעַל־יְרוּשָׁלַ֙͏ִם֙ יַדּ֣וּ גוֹרָ֔ל גַּם־אַתָּ֖ה כְּאַחַ֥ד מֵהֶֽם׃",
      "וְאַל־תֵּ֤רֶא בְיוֹם־אָחִ֙יךָ֙ בְּי֣וֹם נׇכְר֔וֹ וְאַל־תִּשְׂמַ֥ח לִבְנֵֽי־יְהוּדָ֖ה בְּי֣וֹם אׇבְדָ֑ם וְאַל־תַּגְדֵּ֥ל פִּ֖יךָ בְּי֥וֹם צָרָֽה׃",
      "אַל־תָּב֤וֹא בְשַֽׁעַר־עַמִּי֙ בְּי֣וֹם אֵידָ֔ם אַל־תֵּ֧רֶא גַם־אַתָּ֛ה בְּרָעָת֖וֹ בְּי֣וֹם אֵיד֑וֹ וְאַל־תִּשְׁלַ֥חְנָה בְחֵיל֖וֹ בְּי֥וֹם אֵידֽוֹ׃",
      "וְאַֽל־תַּעֲמֹד֙ עַל־הַפֶּ֔רֶק לְהַכְרִ֖ית אֶת־פְּלִיטָ֑יו וְאַל־תַּסְגֵּ֥ר שְׂרִידָ֖יו בְּי֥וֹם צָרָֽה׃",
      "כִּֽי־קָר֥וֹב יוֹם־יְהֹוָ֖ה עַל־כׇּל־הַגּוֹיִ֑ם כַּאֲשֶׁ֤ר עָשִׂ֙יתָ֙ יֵעָ֣שֶׂה לָּ֔ךְ גְּמֻלְךָ֖ יָשׁ֥וּב בְּרֹאשֶֽׁךָ׃",
      "כִּ֗י כַּֽאֲשֶׁ֤ר שְׁתִיתֶם֙ עַל־הַ֣ר קׇדְשִׁ֔י יִשְׁתּ֥וּ כׇֽל־הַגּוֹיִ֖ם תָּמִ֑יד וְשָׁת֣וּ וְלָע֔וּ וְהָי֖וּ כְּל֥וֹא הָיֽוּ׃",
      "וּבְהַ֥ר צִיּ֛וֹן תִּהְיֶ֥ה פְלֵיטָ֖ה וְהָ֣יָה קֹ֑דֶשׁ וְיָֽרְשׁוּ֙ בֵּ֣ית יַֽעֲקֹ֔ב אֵ֖ת מוֹרָֽשֵׁיהֶֽם׃",
      "וְהָיָה֩ בֵית־יַעֲקֹ֨ב אֵ֜שׁ וּבֵ֧ית יוֹסֵ֣ף לֶהָבָ֗ה וּבֵ֤ית עֵשָׂו֙ לְקַ֔שׁ וְדָלְק֥וּ בָהֶ֖ם וַאֲכָל֑וּם וְלֹֽא־יִֽהְיֶ֤ה שָׂרִיד֙ לְבֵ֣ית עֵשָׂ֔ו כִּ֥י יְהֹוָ֖ה דִּבֵּֽר׃",
      "וְיָרְשׁ֨וּ הַנֶּ֜גֶב אֶת־הַ֣ר עֵשָׂ֗ו וְהַשְּׁפֵלָה֙ אֶת־פְּלִשְׁתִּ֔ים וְיָרְשׁוּ֙ אֶת־שְׂדֵ֣ה אֶפְרַ֔יִם וְאֵ֖ת שְׂדֵ֣ה שֹׁמְר֑וֹן וּבִנְיָמִ֖ן אֶת־הַגִּלְעָֽד׃",
      "וְגָלֻ֣ת הַֽחֵל־הַ֠זֶּ֠ה לִבְנֵ֨י יִשְׂרָאֵ֤ל אֲשֶֽׁר־כְּנַעֲנִים֙ עַד־צָ֣רְפַ֔ת וְגָלֻ֥ת יְרוּשָׁלַ֖͏ִם אֲשֶׁ֣ר בִּסְפָרַ֑ד יִֽרְשׁ֕וּ אֵ֖ת עָרֵ֥י הַנֶּֽגֶב׃",
      "וְעָל֤וּ מֽוֹשִׁעִים֙ בְּהַ֣ר צִיּ֔וֹן לִשְׁפֹּ֖ט אֶת־הַ֣ר עֵשָׂ֑ו וְהָיְתָ֥ה לַֽיהֹוָ֖ה הַמְּלוּכָֽה׃"
    ]
  ],
  firstSectionRef: "Obadiah 1",
};
