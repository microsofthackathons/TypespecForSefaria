import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;
  /**
   * All content related to the queried `Ref`.
   */
  model `get_api-related-tref200ApplicationJsonResponse` {
    @statusCode statusCode: 200;
    @bodyRoot body: RelatedJSON;
  }
  

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