import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "./tag/text.tsp";
import "./tag/index.tsp";
import "./tag/related.tsp";
import "./tag/calendars.tsp";
import "./tag/lexicon.tsp";
import "./common.tsp";
import "./model/manuscript.tsp";
import "./model/topic.tsp";

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
