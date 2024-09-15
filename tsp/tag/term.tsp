import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * A Term is a shared title node.  It can be referenced and used by many different `Index` nodes. Terms that use the same `TermScheme` can be ordered within that scheme. So for example, _Parsha_ terms who all share the `TermScheme` of `parsha`, can be ordered within that scheme.
 *
 * Examples of valid terms:  `Noah`, `HaChovel`
 *
 * @returns The response to a query for a specific Term in the Terms API.
 */
@tag("Term")
@route("/api/terms/{name}")
@get
op `get_api-terms-name`(name: string): TermsJSON;

/**
 * Serves primarily as an autocompleter, returning potential keyword matches for `Ref`s, book titles, authors, topics, and collections available on Sefaria.
* @returns Successful response
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
): nameAPIResponse;


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
  
  