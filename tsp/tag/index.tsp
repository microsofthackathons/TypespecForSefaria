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
@opExample(#{ returnType: getIndexV2ResponseExample }, #{ title: "Pesachim" })
@get
op getIndexV2(
  /** A title of a valid Sefaria `Index`. For a complete list of works in the [Sefaria](sefaria.org) library, as well as their index titles, query the [api/index](https://www.sefaria.org/api/index/) endpoint. */
  index_title: string,
): RawIndexJSON;

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
@opExample(#{ returnType: getShapeResponseExample }, #{ title: "Complex Text" })
@opExample(
  #{
    returnType: #[
      #{
        section: "Torah",
        heTitle: "שמות",
        title: "Exodus",
        length: 40,
        chapters: #[
          22,
          25,
          22,
          31,
          23,
          30,
          29,
          28,
          35,
          29,
          10,
          51,
          22,
          31,
          27,
          36,
          16,
          27,
          25,
          23,
          37,
          30,
          33,
          18,
          40,
          37,
          21,
          43,
          46,
          38,
          18,
          35,
          23,
          35,
          35,
          38,
          29,
          31,
          43,
          38
        ],
        book: "Exodus",
        heBook: "שמות",
      }
    ],
  },
  #{ title: "Simple Text" }
)
@get
op getShape(
  /**
   * The title of a valid Sefaria `Index`, or the path of a valid Sefaria category.
   */
  @path title: string,

  /**
   * The `depth` parameter in the query string indicates how many levels in the category tree to descend.
   * If `depth=0` is passed, then the returned JSON descends to end of tree.
   * The default is `depth=2`.
   */
  @query depth?: integer,

  /**
   * The dependents parameter, if `true`, includes dependent texts. By default, they are filtered out.
   */
  @query dependents?: boolean,
): ShapeJSON;

model APIIndexResponse
  is {
    /** This level of the object is a category listing. */
    contents?: {
      /** This level of the object is usually a book level. */
      contents?: {
        /** A list of categories that this book belongs to. */
        categories?: string[];

        /** This is used to order the texts on the Sefaria website. */
        order?: int32;

        /** The main category that this work falls under. */
        primary_category?: string;

        /** A short description of this book in English. */
        enShortDesc?: string;

        /** A short description of this book in Hebrew. */
        heShortDesc?: string;

        /** The corpus that this work belongs to e.g. `Tanakh` or `Mishnah` etc. */
        corpus?: string;

        /** The Hebrew title of this work. */
        heTitle?: string;

        /** The English title of this work. */
        title?: string;
      }[];

      /** This is used to order the texts on the Sefaria website. */
      order?: int32;

      ...APIIndexResponseCategoryInfo;
    }[];

    /** This is used to order the categories on the Sefaria website. */
    order?: int32;

    ...APIIndexResponseCategoryInfo;
  }[];

model APIIndexResponseCategoryInfo {
  /** Is the entirety of this category available in English */
  enComplete?: boolean;

  /** Is the entirety of this category available in Hebrew */
  heComplete?: boolean;

  /** An English description of the category */
  enDesc?: string;

  /** An Hebrew description of the category */
  heDesc?: string;

  /** A short description of this category in English. */
  enShortDesc?: string;

  /** A short description of this category in Hebrew. */
  heShortDesc?: string;

  heCategory?: string;

  /** The current category that these works are nested in. */
  category?: string;
}

/**
 * The shape API allows one to retrieve information about the shape of an Index on Sefaria. The shape refers some basic statistics about the Index, mostly the number of chapters, and the number of segments per chapter.
 */
model ShapeJSON {
  /**
   * The parent section for this `Index`. (So for example, the `section` for `Jonah` is `Prophets`. The `section` for `Pesachim` is `Seder Moed`)
   */
  @example("Prophets")
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
  @example(#[16, 11, 10, 11])
  Chapters: ShapeJSON[];
}

/**
 * The full mongo record JSON from the database for a given Sefaria `Index`.
 */
@example(RawIndexJSONModelExample)
model RawIndexJSON {
  /**
   * Title of the work.
   */
  @example("Pesachim")
  title?: string;

  /**
   * The categories within which this text falls. *Note:* The order of the strings in the array is significant. The categories should go from most general at position `0`, to most specific.
   */
  @example(#["Talmud", "Bavli", "Seder Moed"])
  categories?: string[];

  /**
   * The structure of the Index within the Sefaria specific schema for texts.
   */
  @example(#{
    nodeType: "JaggedArrayNode",
    depth: 2,
    addressTypes: #["Talmud", "Integer"],
    sectionNames: #["Daf", "Line"],
    match_templates: #[],
    lengths: #[242, 3519],
    referenceableSections: #[true, false],
    titles: #[
      #{ text: "Masekhet Pesachim", lang: "en" },
      #{ text: "Talmud Pesachim", lang: "en" },
      #{ text: "Tractate Pesachim", lang: "en" },
      #{ text: "Pesahim", lang: "en" },
      #{ text: "Pes.", lang: "en" },
      #{ text: "P’saḥim", lang: "en" },
      #{ text: "Pessachim", lang: "en" },
      #{ text: "BT Pesachim", lang: "en" },
      #{ text: "Psachim", lang: "en" },
      #{ text: "Pesaḥim ", lang: "en" },
      #{ text: "פסחי'", lang: "he" },
      #{ text: "פסחי׳", lang: "he" },
      #{ text: "פסחים", lang: "he", primary: true },
      #{ text: "Pesachim", lang: "en", primary: true }
    ],
    key: "Pesachim",
    checkFirst: #{ he: "משנה פסחים", en: "Mishnah Pesachim" },
  })
  schema?: RawIndexSchemaJSON;

  /**
   * Alternative structures for the text.
   */
  alt_structs?: RawIndexAltStructsJSON;

  /**
   * Which structure of the available structures is default.
   */
  @example("chapters")
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
  @example("Pesachim (“Passover Festivals”) is the third tractate in Seder Moed (“Festivals”). Its ten chapters discuss laws relating to Passover: the consumption of matzah (unleavened bread) and maror (bitter herbs), the prohibitions against owning or consuming chametz (leavened bread) on the festival, the paschal lamb that used to be offered at the Temple in Jerusalem, and the order of the seder (ritual feast) held on the first evening of the holiday.\n.")
  enDesc?: string;

  /**
   * A short English description of the index.
   */
  @example("Passover: ridding of chametz, the Paschal lamb offering, matzah, maror, and the Seder.")
  enShortDesc?: string;

  /**
   * A short description of the text in Hebrew.
   */
  @example("דינים הקשורים לחג הפסח: איסור חמץ, קורבן הפסח, מצה, מרור וליל הסדר.")
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
  @example("Talmudic Babylon")
  compPlace?: string;

  /**
   * Location of publication
   */
  @example("Venice")
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
  @example("True")
  is_cited?: boolean;

  @example(#["Bavli"])
  corpora?: string[];
}

/**
 * Schema JSON for an Index.
 */
@example(#{
  nodeType: "JaggedArrayNode",
  depth: 2,
  addressTypes: #["Talmud", "Integer"],
  sectionNames: #["Daf", "Line"],
  match_templates: #[],
  lengths: #[242, 3519],
  referenceableSections: #[true, false],
  titles: #[],
  key: "Pesachim",
  checkFirst: #{ he: "משנה פסחים", en: "Mishnah Pesachim" },
})
model RawIndexSchemaJSON {
  /**
   * The type of node. Nodes can either be `SchemaNodes` or `JaggedArray` nodes. A `JaggedArray` is a nested array (2D or 3D), whereas a `SchemaNode` is a node with children of either type. All tree leaves in the Sefaria text tree must be `JaggedArray` nodes.
   */
  @example("JaggedArrayNode")
  nodeType?: "JaggedArrayNode" | "SchemaNode";

  /**
   * The depth of a text. For example, a book of Tanakh with chapters and verses has a depth 2, whereas a commentary on that book of Tanakh, with multiple comments on each verse (so a chapter-verse-comment structure) would have a depth of 3.
   */
  @example(2)
  depth?: int32;

  /**
   * A list which length reflects the depth of the text structure, with string values indicating class names for address types for each level.
   */
  @example(#["Talmud", "Integer"])
  addressTypes?: string[];

  /**
   * An array containing the type names of the sections of this text. The length of `sectionNames` gives the depth of the structure of this text. For example, Kohelet (`["Chapter", "Verse"]`) has depth 2, while Mishneh Torah (`["Book", "Topic", "Section", "Law"]`) has depth 4. Comparing this depth to the depth of sections will show if the request was for the lowest level, or a higher level, of the text.
   */
  @example(#["Book", "Topic", "Section", "Law"])
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
  @example(#[50, 1533])
  lengths?: int32[];

  referenceableSections?: boolean[];

  /**
   * Titles for the index.
   */
  @example(#[
    #{ text: "Masekhet Pesachim", lang: "en" },
    #{ text: "Talmud Pesachim", lang: "en" },
    #{ text: "Tractate Pesachim", lang: "en" },
    #{ text: "Pesahim", lang: "en" },
    #{ text: "Pes.", lang: "en" },
    #{ text: "P’saḥim", lang: "en" },
    #{ text: "Pessachim", lang: "en" },
    #{ text: "BT Pesachim", lang: "en" },
    #{ text: "Psachim", lang: "en" },
    #{ text: "Pesaḥim ", lang: "en" },
    #{ text: "פסחי'", lang: "he" },
    #{ text: "פסחי׳", lang: "he" },
    #{ text: "פסחים", lang: "he", primary: true },
    #{ text: "Pesachim", lang: "en", primary: true }
  ])
  titles?: TitlesJSON[];

  /**
   * Unique key for the text, usually matches the `Index` title.
   */
  @example("Pesachim")
  key?: string;

  checkFirst?: BilingualOf<string>;
}

/**
 * The JSON returned for the alt structs of an Index.
 */
@example(RawIndexAltStructsJSONModelExample)
model RawIndexAltStructsJSON {
  Chapters?: RawIndexNodesJSON;
}
@example(#{
  nodeType: "ArrayMapNode",
  depth: 0,
  wholeRef: "Pesachim 2a:1-21a:7",
  includeSections: true,
  match_templates: #[
    #{ term_slugs: #["perek", "chapter-129"], scope: "any" },
    #{ term_slugs: #["perek", "first"] },
    #{ term_slugs: #["chapter-129"], scope: "any" },
    #{ term_slugs: #["first"] }
  ],
  numeric_equivalent: 1,
  titles: #[
    #{ primary: true, text: "Chapter 1", lang: "en" },
    #{ primary: true, text: "אור לארבעה עשר", lang: "he" }
  ],
})
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
  @example("\"Pesachim 2a:1-21a:7")
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
  @example(3)
  numeric_equivalent?: int32;

  /**
   * Titles for this section of text.
   */
  @example(#[
    #{ primary: true, text: "Chapter 1", lang: "en" },
    #{ primary: true, text: "אור לארבעה עשר", lang: "he" }
  ])
  titles?: TitlesJSON[];
}

model RawIndexNodesJSON {
  nodes?: RawIndexAltStructNodeJSON[];
}

const getIndexV2ResponseExample : RawIndexJSON = #{
  title: "Pesachim",
  categories: #["Talmud", "Bavli", "Seder Moed"],
  schema: #{
    nodeType: "JaggedArrayNode",
    depth: 2,
    addressTypes: #["Talmud", "Integer"],
    sectionNames: #["Daf", "Line"],
    match_templates: #[
      #{ term_slugs: #["talmud", "bavli", "pesachim"] },
      #{ term_slugs: #["talmud", "bavli", "tractate", "pesachim"] },
      #{ term_slugs: #["talmud", "pesachim"] },
      #{ term_slugs: #["bavli", "pesachim"] },
      #{ term_slugs: #["gemara", "pesachim"] },
      #{ term_slugs: #["bavli", "tractate", "pesachim"] },
      #{ term_slugs: #["gemara", "tractate", "pesachim"] },
      #{ term_slugs: #["tractate", "pesachim"] },
      #{ term_slugs: #["pesachim"] }
    ],
    lengths: #[242, 3519],
    referenceableSections: #[true, false],
    titles: #[
      #{ text: "Masekhet Pesachim", lang: "en" },
      #{ text: "Talmud Pesachim", lang: "en" },
      #{ text: "Tractate Pesachim", lang: "en" },
      #{ text: "Pesahim", lang: "en" },
      #{ text: "Pes.", lang: "en" },
      #{ text: "P’saḥim", lang: "en" },
      #{ text: "Pessachim", lang: "en" },
      #{ text: "BT Pesachim", lang: "en" },
      #{ text: "Psachim", lang: "en" },
      #{ text: "Pesaḥim", lang: "en" },
      #{ text: "פסחי'", lang: "he" },
      #{ text: "פסחי׳", lang: "he" },
      #{ text: "פסחים", lang: "he", primary: true },
      #{ text: "Pesachim", lang: "en", primary: true }
    ],
    key: "Pesachim",
    checkFirst: #{ he: "משנה פסחים", en: "Mishnah Pesachim" },
  },
  alt_structs: #{
    Chapters: #{
      nodes: #[
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 2a:1-21a:7",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-129"], scope: "any" },
            #{ term_slugs: #["perek", "first"] },
            #{ term_slugs: #["chapter-129"], scope: "any" },
            #{ term_slugs: #["first"] }
          ],
          numeric_equivalent: 1,
          titles: #[
            #{ primary: true, text: "Chapter 1", lang: "en" },
            #{ primary: true, text: "אור לארבעה עשר", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 21a:8-42a:14",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-224"], scope: "any" },
            #{ term_slugs: #["perek", "second"] },
            #{ term_slugs: #["chapter-224"], scope: "any" },
            #{ term_slugs: #["second"] }
          ],
          numeric_equivalent: 2,
          titles: #[
            #{ primary: true, text: "Chapter 2", lang: "en" },
            #{ primary: true, text: "כל שעה", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 42a:15-50a:22",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-324"], scope: "any" },
            #{ term_slugs: #["perek", "third"] },
            #{ term_slugs: #["chapter-324"], scope: "any" },
            #{ term_slugs: #["third"] }
          ],
          numeric_equivalent: 3,
          titles: #[
            #{ primary: true, text: "Chapter 3", lang: "en" },
            #{ primary: true, text: "אלו עוברין", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 50a:23-57b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-420"], scope: "any" },
            #{ term_slugs: #["perek", "fourth"] },
            #{ term_slugs: #["chapter-420"], scope: "any" },
            #{ term_slugs: #["fourth"] }
          ],
          numeric_equivalent: 4,
          titles: #[
            #{ primary: true, text: "Chapter 4", lang: "en" },
            #{ primary: true, text: "מקום שנהגו", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 58a:1-65b:9",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-518"], scope: "any" },
            #{ term_slugs: #["perek", "fifth"] },
            #{ term_slugs: #["chapter-518"], scope: "any" },
            #{ term_slugs: #["fifth"] }
          ],
          numeric_equivalent: 5,
          titles: #[
            #{ primary: true, text: "Chapter 5", lang: "en" },
            #{ primary: true, text: "תמיד נשחט", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 65b:10-73b:16",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-616"], scope: "any" },
            #{ term_slugs: #["perek", "sixth"] },
            #{ term_slugs: #["chapter-616"], scope: "any" },
            #{ term_slugs: #["sixth"] }
          ],
          numeric_equivalent: 6,
          titles: #[
            #{ primary: true, text: "Chapter 6", lang: "en" },
            #{ primary: true, text: "אלו דברים", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 74a:1-86b:13",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-714"], scope: "any" },
            #{ term_slugs: #["perek", "seventh"] },
            #{ term_slugs: #["chapter-714"], scope: "any" },
            #{ term_slugs: #["seventh"] }
          ],
          numeric_equivalent: 7,
          titles: #[
            #{ primary: true, text: "Chapter 7", lang: "en" },
            #{ primary: true, text: "כיצד צולין", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 87a:1-92b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-814"], scope: "any" },
            #{ term_slugs: #["perek", "eighth"] },
            #{ term_slugs: #["chapter-814"], scope: "any" },
            #{ term_slugs: #["eighth"] }
          ],
          numeric_equivalent: 8,
          titles: #[
            #{ primary: true, text: "Chapter 8", lang: "en" },
            #{ primary: true, text: "האשה", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 92b:4-99a:5",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-914"], scope: "any" },
            #{ term_slugs: #["perek", "ninth"] },
            #{ term_slugs: #["chapter-914"], scope: "any" },
            #{ term_slugs: #["ninth"] }
          ],
          numeric_equivalent: 9,
          titles: #[
            #{ primary: true, text: "Chapter 9", lang: "en" },
            #{ primary: true, text: "מי שהיה טמא", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 99b:1-121b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-109"], scope: "any" },
            #{ term_slugs: #["perek", "tenth"] },
            #{ term_slugs: #["chapter-109"], scope: "any" },
            #{ term_slugs: #["tenth"] },
            #{ term_slugs: #["perek", "last"] },
            #{ term_slugs: #["last"] }
          ],
          numeric_equivalent: 10,
          titles: #[
            #{ primary: true, text: "Chapter 10", lang: "en" },
            #{ primary: true, text: "ערבי פסחים", lang: "he" }
          ],
        }
      ],
    },
  },
  default_struct: "Chapters",
  exclude_structs: #["schema"],
  order: #[4, 3],
  authors: #[],
  enDesc: "Pesachim (“Passover Festivals”) is the third tractate in Seder Moed (“Festivals”). Its ten chapters discuss laws relating to Passover: the consumption of matzah (unleavened bread) and maror (bitter herbs), the prohibitions against owning or consuming chametz (leavened bread) on the festival, the paschal lamb that used to be offered at the Temple in Jerusalem, and the order of the seder (ritual feast) held on the first evening of the holiday.\n.",
  enShortDesc: "Passover: ridding of chametz, the Paschal lamb offering, matzah, maror, and the Seder.",
  heShortDesc: "דינים הקשורים לחג הפסח: איסור חמץ, קורבן הפסח, מצה, מרור וליל הסדר.",
  pubDate: #[1523],
  hasErrorMargin: true,
  compDate: #[450, 550],
  compPlace: "Talmudic Babylon",
  pubPlace: "Venice",
  era: "A",
  is_cited: true,
  corpora: #["Bavli"],
};

const getShapeResponseExample : ShapeJSON[] = #[
  #{
    isComplex: true,
    section: "Haggadah",
    length: 38,
    chapters: #[
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, קדש",
        title: "Pesach Haggadah, Kadesh",
        length: 1,
        chapters: 13,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, ורחץ",
        title: "Pesach Haggadah, Urchatz",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, כרפס",
        title: "Pesach Haggadah, Karpas",
        length: 1,
        chapters: 3,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, יחץ",
        title: "Pesach Haggadah, Yachatz",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, הא לחמא עניא",
        title: "Pesach Haggadah, Magid, Ha Lachma Anya",
        length: 1,
        chapters: 3,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, מה נשתנה",
        title: "Pesach Haggadah, Magid, Four Questions",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, עבדים היינו",
        title: "Pesach Haggadah, Magid, We Were Slaves in Egypt",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, מעשה שהיה בבני ברק",
        title: "Pesach Haggadah, Magid, Story of the Five Rabbis",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, כנגד ארבעה בנים",
        title: "Pesach Haggadah, Magid, The Four Sons",
        length: 1,
        chapters: 5,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, יכול מראש חודש",
        title: "Pesach Haggadah, Magid, Yechol Me'rosh Chodesh",
        length: 1,
        chapters: 1,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, מתחילה עובדי עבודה זרה היו אבותינו",
        title: "Pesach Haggadah, Magid, In the Beginning Our Fathers Were Idol Worshipers",
        length: 1,
        chapters: 5,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, ארמי אבד אבי",
        title: "Pesach Haggadah, Magid, First Fruits Declaration",
        length: 1,
        chapters: 24,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, עשר המכות",
        title: "Pesach Haggadah, Magid, The Ten Plagues",
        length: 1,
        chapters: 20,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, דיינו",
        title: "Pesach Haggadah, Magid, Dayenu",
        length: 1,
        chapters: 16,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, פסח מצה ומרור",
        title: "Pesach Haggadah, Magid, Rabban Gamliel's Three Things",
        length: 1,
        chapters: 7,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, חצי הלל",
        title: "Pesach Haggadah, Magid, First Half of Hallel",
        length: 1,
        chapters: 4,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מגיד, כוס שניה",
        title: "Pesach Haggadah, Magid, Second Cup of Wine",
        length: 1,
        chapters: 4,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, רחצה",
        title: "Pesach Haggadah, Rachtzah",
        length: 1,
        chapters: 3,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מוציא מצה",
        title: "Pesach Haggadah, Motzi Matzah",
        length: 1,
        chapters: 4,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, מרור",
        title: "Pesach Haggadah, Maror",
        length: 1,
        chapters: 3,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, כורך",
        title: "Pesach Haggadah, Korech",
        length: 1,
        chapters: 4,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, שולחן עורך",
        title: "Pesach Haggadah, Shulchan Orech",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, צפון",
        title: "Pesach Haggadah, Tzafun",
        length: 1,
        chapters: 3,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, ברך, ברכת המזון",
        title: "Pesach Haggadah, Barech, Birkat Hamazon",
        length: 1,
        chapters: 23,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, ברך, כוס שלישית",
        title: "Pesach Haggadah, Barech, Third Cup of Wine",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, ברך, שפוך חמתך",
        title: "Pesach Haggadah, Barech, Pour Out Thy Wrath",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, הלל, מסיימים את ההלל",
        title: "Pesach Haggadah, Hallel, Second Half of Hallel",
        length: 1,
        chapters: 10,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, הלל, מזמורי הודיה",
        title: "Pesach Haggadah, Hallel, Songs of Praise and Thanks",
        length: 1,
        chapters: 6,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, הלל, כוס רביעית",
        title: "Pesach Haggadah, Hallel, Fourth Cup of Wine",
        length: 1,
        chapters: 4,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, חסל סידור פסח",
        title: "Pesach Haggadah, Nirtzah, Chasal Siddur Pesach",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, לשנה הבאה",
        title: "Pesach Haggadah, Nirtzah, L'Shana HaBaa",
        length: 1,
        chapters: 1,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, ויהי בחצי הלילה",
        title: "Pesach Haggadah, Nirtzah, And It Happened at Midnight",
        length: 1,
        chapters: 11,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, זבח פסח",
        title: "Pesach Haggadah, Nirtzah, Zevach Pesach",
        length: 1,
        chapters: 8,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, אדיר במלוכה",
        title: "Pesach Haggadah, Nirtzah, Ki Lo Na'e",
        length: 1,
        chapters: 9,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, אדיר הוא",
        title: "Pesach Haggadah, Nirtzah, Adir Hu",
        length: 1,
        chapters: 8,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, ספירת העומר",
        title: "Pesach Haggadah, Nirtzah, Sefirat HaOmer",
        length: 1,
        chapters: 2,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, אחד מי יודע",
        title: "Pesach Haggadah, Nirtzah, Echad Mi Yodea",
        length: 1,
        chapters: 1,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      },
      #{
        section: "Haggadah",
        heTitle: "הגדה של פסח, נרצה, חד גדיא",
        title: "Pesach Haggadah, Nirtzah, Chad Gadya",
        length: 1,
        chapters: 10,
        book: "Pesach Haggadah",
        heBook: "הגדה של פסח",
      }
    ],
    book: "Pesach Haggadah",
    heBook: "הגדה של פסח",
  }
];

const RawIndexAltStructsJSONModelExample = #{
  alt_structs: #{
    Chapters: #{
      nodes: #[
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 2a:1-21a:7",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-129"], scope: "any" },
            #{ term_slugs: #["perek", "first"] },
            #{ term_slugs: #["chapter-129"], scope: "any" },
            #{ term_slugs: #["first"] }
          ],
          numeric_equivalent: 1,
          titles: #[
            #{ primary: true, text: "Chapter 1", lang: "en" },
            #{ primary: true, text: "אור לארבעה עשר", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 21a:8-42a:14",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-224"], scope: "any" },
            #{ term_slugs: #["perek", "second"] },
            #{ term_slugs: #["chapter-224"], scope: "any" },
            #{ term_slugs: #["second"] }
          ],
          numeric_equivalent: 2,
          titles: #[
            #{ primary: true, text: "Chapter 2", lang: "en" },
            #{ primary: true, text: "כל שעה", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 42a:15-50a:22",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-324"], scope: "any" },
            #{ term_slugs: #["perek", "third"] },
            #{ term_slugs: #["chapter-324"], scope: "any" },
            #{ term_slugs: #["third"] }
          ],
          numeric_equivalent: 3,
          titles: #[
            #{ primary: true, text: "Chapter 3", lang: "en" },
            #{ primary: true, text: "אלו עוברין", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 50a:23-57b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-420"], scope: "any" },
            #{ term_slugs: #["perek", "fourth"] },
            #{ term_slugs: #["chapter-420"], scope: "any" },
            #{ term_slugs: #["fourth"] }
          ],
          numeric_equivalent: 4,
          titles: #[
            #{ primary: true, text: "Chapter 4", lang: "en" },
            #{ primary: true, text: "מקום שנהגו", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 58a:1-65b:9",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-518"], scope: "any" },
            #{ term_slugs: #["perek", "fifth"] },
            #{ term_slugs: #["chapter-518"], scope: "any" },
            #{ term_slugs: #["fifth"] }
          ],
          numeric_equivalent: 5,
          titles: #[
            #{ primary: true, text: "Chapter 5", lang: "en" },
            #{ primary: true, text: "תמיד נשחט", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 65b:10-73b:16",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-616"], scope: "any" },
            #{ term_slugs: #["perek", "sixth"] },
            #{ term_slugs: #["chapter-616"], scope: "any" },
            #{ term_slugs: #["sixth"] }
          ],
          numeric_equivalent: 6,
          titles: #[
            #{ primary: true, text: "Chapter 6", lang: "en" },
            #{ primary: true, text: "אלו דברים", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 74a:1-86b:13",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-714"], scope: "any" },
            #{ term_slugs: #["perek", "seventh"] },
            #{ term_slugs: #["chapter-714"], scope: "any" },
            #{ term_slugs: #["seventh"] }
          ],
          numeric_equivalent: 7,
          titles: #[
            #{ primary: true, text: "Chapter 7", lang: "en" },
            #{ primary: true, text: "כיצד צולין", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 87a:1-92b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-814"], scope: "any" },
            #{ term_slugs: #["perek", "eighth"] },
            #{ term_slugs: #["chapter-814"], scope: "any" },
            #{ term_slugs: #["eighth"] }
          ],
          numeric_equivalent: 8,
          titles: #[
            #{ primary: true, text: "Chapter 8", lang: "en" },
            #{ primary: true, text: "האשה", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 92b:4-99a:5",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-914"], scope: "any" },
            #{ term_slugs: #["perek", "ninth"] },
            #{ term_slugs: #["chapter-914"], scope: "any" },
            #{ term_slugs: #["ninth"] }
          ],
          numeric_equivalent: 9,
          titles: #[
            #{ primary: true, text: "Chapter 9", lang: "en" },
            #{ primary: true, text: "מי שהיה טמא", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 99b:1-121b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-109"], scope: "any" },
            #{ term_slugs: #["perek", "tenth"] },
            #{ term_slugs: #["chapter-109"], scope: "any" },
            #{ term_slugs: #["tenth"] },
            #{ term_slugs: #["perek", "last"] },
            #{ term_slugs: #["last"] }
          ],
          numeric_equivalent: 10,
          titles: #[
            #{ primary: true, text: "Chapter 10", lang: "en" },
            #{ primary: true, text: "ערבי פסחים", lang: "he" }
          ],
        }
      ],
    },
  },
};

const RawIndexJSONModelExample = #{
  title: "Pesachim",
  categories: #["Talmud", "Bavli", "Seder Moed"],
  schema: #{
    nodeType: "JaggedArrayNode",
    depth: 2,
    addressTypes: #["Talmud", "Integer"],
    sectionNames: #["Daf", "Line"],
    match_templates: #[
      #{ term_slugs: #["talmud", "bavli", "pesachim"] },
      #{ term_slugs: #["talmud", "bavli", "tractate", "pesachim"] },
      #{ term_slugs: #["talmud", "pesachim"] },
      #{ term_slugs: #["bavli", "pesachim"] },
      #{ term_slugs: #["gemara", "pesachim"] },
      #{ term_slugs: #["bavli", "tractate", "pesachim"] },
      #{ term_slugs: #["gemara", "tractate", "pesachim"] },
      #{ term_slugs: #["tractate", "pesachim"] },
      #{ term_slugs: #["pesachim"] }
    ],
    lengths: #[242, 3519],
    referenceableSections: #[true, false],
    titles: #[
      #{ text: "Masekhet Pesachim", lang: "en" },
      #{ text: "Talmud Pesachim", lang: "en" },
      #{ text: "Tractate Pesachim", lang: "en" },
      #{ text: "Pesahim", lang: "en" },
      #{ text: "Pes.", lang: "en" },
      #{ text: "P’saḥim", lang: "en" },
      #{ text: "Pessachim", lang: "en" },
      #{ text: "BT Pesachim", lang: "en" },
      #{ text: "Psachim", lang: "en" },
      #{ text: "Pesaḥim", lang: "en" },
      #{ text: "פסחי'", lang: "he" },
      #{ text: "פסחי׳", lang: "he" },
      #{ text: "פסחים", lang: "he", primary: true },
      #{ text: "Pesachim", lang: "en", primary: true }
    ],
    key: "Pesachim",
    checkFirst: #{ he: "משנה פסחים", en: "Mishnah Pesachim" },
  },
  alt_structs: #{
    Chapters: #{
      nodes: #[
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 2a:1-21a:7",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-129"], scope: "any" },
            #{ term_slugs: #["perek", "first"] },
            #{ term_slugs: #["chapter-129"], scope: "any" },
            #{ term_slugs: #["first"] }
          ],
          numeric_equivalent: 1,
          titles: #[
            #{ primary: true, text: "Chapter 1", lang: "en" },
            #{ primary: true, text: "אור לארבעה עשר", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 21a:8-42a:14",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-224"], scope: "any" },
            #{ term_slugs: #["perek", "second"] },
            #{ term_slugs: #["chapter-224"], scope: "any" },
            #{ term_slugs: #["second"] }
          ],
          numeric_equivalent: 2,
          titles: #[
            #{ primary: true, text: "Chapter 2", lang: "en" },
            #{ primary: true, text: "כל שעה", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 42a:15-50a:22",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-324"], scope: "any" },
            #{ term_slugs: #["perek", "third"] },
            #{ term_slugs: #["chapter-324"], scope: "any" },
            #{ term_slugs: #["third"] }
          ],
          numeric_equivalent: 3,
          titles: #[
            #{ primary: true, text: "Chapter 3", lang: "en" },
            #{ primary: true, text: "אלו עוברין", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 50a:23-57b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-420"], scope: "any" },
            #{ term_slugs: #["perek", "fourth"] },
            #{ term_slugs: #["chapter-420"], scope: "any" },
            #{ term_slugs: #["fourth"] }
          ],
          numeric_equivalent: 4,
          titles: #[
            #{ primary: true, text: "Chapter 4", lang: "en" },
            #{ primary: true, text: "מקום שנהגו", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 58a:1-65b:9",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-518"], scope: "any" },
            #{ term_slugs: #["perek", "fifth"] },
            #{ term_slugs: #["chapter-518"], scope: "any" },
            #{ term_slugs: #["fifth"] }
          ],
          numeric_equivalent: 5,
          titles: #[
            #{ primary: true, text: "Chapter 5", lang: "en" },
            #{ primary: true, text: "תמיד נשחט", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 65b:10-73b:16",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-616"], scope: "any" },
            #{ term_slugs: #["perek", "sixth"] },
            #{ term_slugs: #["chapter-616"], scope: "any" },
            #{ term_slugs: #["sixth"] }
          ],
          numeric_equivalent: 6,
          titles: #[
            #{ primary: true, text: "Chapter 6", lang: "en" },
            #{ primary: true, text: "אלו דברים", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 74a:1-86b:13",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-714"], scope: "any" },
            #{ term_slugs: #["perek", "seventh"] },
            #{ term_slugs: #["chapter-714"], scope: "any" },
            #{ term_slugs: #["seventh"] }
          ],
          numeric_equivalent: 7,
          titles: #[
            #{ primary: true, text: "Chapter 7", lang: "en" },
            #{ primary: true, text: "כיצד צולין", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 87a:1-92b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-814"], scope: "any" },
            #{ term_slugs: #["perek", "eighth"] },
            #{ term_slugs: #["chapter-814"], scope: "any" },
            #{ term_slugs: #["eighth"] }
          ],
          numeric_equivalent: 8,
          titles: #[
            #{ primary: true, text: "Chapter 8", lang: "en" },
            #{ primary: true, text: "האשה", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 92b:4-99a:5",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-914"], scope: "any" },
            #{ term_slugs: #["perek", "ninth"] },
            #{ term_slugs: #["chapter-914"], scope: "any" },
            #{ term_slugs: #["ninth"] }
          ],
          numeric_equivalent: 9,
          titles: #[
            #{ primary: true, text: "Chapter 9", lang: "en" },
            #{ primary: true, text: "מי שהיה טמא", lang: "he" }
          ],
        },
        #{
          nodeType: "ArrayMapNode",
          depth: 0,
          wholeRef: "Pesachim 99b:1-121b:3",
          includeSections: true,
          match_templates: #[
            #{ term_slugs: #["perek", "chapter-109"], scope: "any" },
            #{ term_slugs: #["perek", "tenth"] },
            #{ term_slugs: #["chapter-109"], scope: "any" },
            #{ term_slugs: #["tenth"] },
            #{ term_slugs: #["perek", "last"] },
            #{ term_slugs: #["last"] }
          ],
          numeric_equivalent: 10,
          titles: #[
            #{ primary: true, text: "Chapter 10", lang: "en" },
            #{ primary: true, text: "ערבי פסחים", lang: "he" }
          ],
        }
      ],
    },
  },
  default_struct: "Chapters",
  exclude_structs: #["schema"],
  order: #[4, 3],
  authors: #[],
  enDesc: "Pesachim (“Passover Festivals”) is the third tractate in Seder Moed (“Festivals”). Its ten chapters discuss laws relating to Passover: the consumption of matzah (unleavened bread) and maror (bitter herbs), the prohibitions against owning or consuming chametz (leavened bread) on the festival, the paschal lamb that used to be offered at the Temple in Jerusalem, and the order of the seder (ritual feast) held on the first evening of the holiday.\n.",
  enShortDesc: "Passover: ridding of chametz, the Paschal lamb offering, matzah, maror, and the Seder.",
  heShortDesc: "דינים הקשורים לחג הפסח: איסור חמץ, קורבן הפסח, מצה, מרור וליל הסדר.",
  pubDate: #[1523],
  hasErrorMargin: true,
  compDate: #[450, 550],
  compPlace: "Talmudic Babylon",
  pubPlace: "Venice",
  era: "A",
  is_cited: true,
  corpora: #["Bavli"],
};
