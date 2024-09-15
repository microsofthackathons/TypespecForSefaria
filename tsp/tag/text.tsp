import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";
import "../model/manuscript.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * The texts on Sefaria are grouped into two language buckets, `en` for languages which read left-to-right (i.e. English, Spanish, German) and `he` for languages which read right-to-left (i.e. Hebrew, Arabic). This field is only ever populated by a string containing the value of either `en` or `he`.
 */
scalar LanguageCode extends string;

/**
 * The most up-to-date way to retrieve texts from Sefaria via the API, with enhanced control over language, language direction, and other parameters.
 * @returns Successful retrieval of the desired texts.
 */
@tag("Text")
@route("/api/v3/texts/{tref}")
@get
op getTextsV3(tref: string): v3TextsJson;

/**
 * Retrieve the text and some additional metadata for a specific Sefaria textual `Ref`
* @returns Successful response
 */
@tag("Text")
@route("/api/texts/{tref}")
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
@get
op getVersions(index: string): VersionJSON[];

/**
 * Returns a list of distinct languages for which translations exist in the database.
* @returns Successful Response
 */
@tag("Text")
@route("/api/texts/translations")
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
    title?: string;
    url?: string;
    versionTitle?: string;
    rtlLanguage?: "he" | "en";
  };

/**
 * This call retrieves all associated manuscript data and metadata for a given Sefaria `tref`.
* @returns Successful response
 */
@tag("Text")
@route("/api/manuscripts/{tref}")
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
  
 