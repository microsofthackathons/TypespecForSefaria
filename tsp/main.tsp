import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "./tag/text.tsp";
import "./tag/index.tsp";
import "./tag/related.tsp";
import "./tag/calendars.tsp";
import "./tag/lexicon.tsp";
import "./tag/topic.tsp";
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
