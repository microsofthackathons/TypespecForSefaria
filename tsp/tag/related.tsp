import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * A single API endpoint to return all of the content (links, sheets, notes, media, manuscripts, webpages and topics) related to the given `Ref` in the query.
* @returns All content related to the queried `Ref`.
 */
@tag("Related")
@route("/api/related/{tref}")
@get
op `get_api-related-tref`(tref: string): RelatedJSON;

/**
 * Returns a list of known connections for the submitted text `ref` along with some additional metadata.
* @returns Successful response
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
): LinkObj[];

/**
 * An API endpoint where, given a `Ref`, all of the topics linked to that `Ref` are retrieved along with the respective metadata.
* @returns Successful response
 */
@tag("Related")
@route("/api/ref-topic-links/{tref}")
@get
op `get_api-ref-topic-links-tref`(tref: string): RefTopicLinksJSON;

  
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

  