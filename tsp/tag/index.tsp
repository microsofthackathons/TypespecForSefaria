import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";
import "../model/manuscript.tsp";
import "../model/sheets.tsp";
import "../model/topic.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * This API endpoint will retrieve the full mongo record of the given `Index` as it appears in the database.
 * @returns Successful Request
 */
@tag("Index")
@route("/api/v2/raw/index/{index_title}")
@get
op getIndexV2(index_title: string): RawIndexJSON;

/**
 * This API endpoint returns the titles of all the books in the Sefaria Library arranged by their category along with some additional metadata. This is a large and rarely changing request and should be cached locally if you utilize it.
 * @returns Successful Response
 */
@tag("Index")
@route("/api/index")
@get
op getTableOfContents(): APIIndexResponse;

/**
 * Retrieve basic statistics and information about the "shape" of an `Index` on Sefaria.
 */
@tag("Index")
@route("/api/shape/{title}")
@get
op getShape(title: string): ShapeJSON;

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
