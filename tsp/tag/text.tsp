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
scalar LanguageCode extends string;

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

const getTextsV3ResponseExample = #{
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
      versionTitle: "Bible du Rabbinat 1899 #[fr]",
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
      versionTitle: "Bible in Polish, trans. Izaak Cylkow, 1841 - 1908 #[pl]",
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
      versionTitle: "Ester. Traduzione italiana di Samuel David Luzzatto, 1872 #[it]",
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
      versionTitle: "Book of Esther in Farsi, trans. by Pole-Choubi, synagogue Talmood Torah #[fa]",
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
      versionTitle: "Book of Esther in Farsi, trans. by Pole-Choubi, synagogue Talmood Torah, LTR #[fa]",
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
      versionTitle: "Yehoyesh's Yiddish Tanakh Translation #[yi]",
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
      versionTitle: "El libro de Ester - Meguila Ester - Seminario Rabínico #[es]",
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
      versionTitle: "La Bible, Traduction Nouvelle, Samuel Cahen, 1831 #[fr]",
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
      versionTitle: "La Malnova Testamento, L.L.Zamenhof #[eo]",
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
      versionTitle: "Die Heilige Schrift, trans. Dr. Simon Bernfeld, Berlin, 1902 - German #[de]",
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

const getTextsV1ResponseExample = #{
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

const getVersionsResponseExample = #[
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
