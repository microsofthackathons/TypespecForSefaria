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
@opExample(
  #{
    returnType: #{
      name: "Noach",
      titles: #[
        #{ primary: true, text: "Noach", lang: "en" },
        #{ primary: true, text: "נח", lang: "he" },
        #{ text: "Parashat Noach", lang: "en" },
        #{ text: "פרשת נח", lang: "he" },
        #{ text: "Noah", lang: "en" },
        #{ text: "Parshat Noah", lang: "en" }
      ],
      scheme: "Parasha",
      order: 2,
      ref: "Genesis 6:9-11:32",
      category: "Torah Portions",
    },
  },
  #{ title: "Noah" }
)
@get
op getTerms(
  /** The English name of a valid Sefaria term. */
  name: string,
): TermsJSON;

/**
 * Serves primarily as an autocompleter, returning potential keyword matches for `Ref`s, book titles, authors, topics, and collections available on Sefaria.
 * @returns Successful response
 */
@tag("Term")
@route("/api/name/{name}")
@get
op getName(
  /**
   * An arbitrary text string to match against Sefaria's data collections.
   */
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
@example(#{
  name: "Noach",
  titles: #[
    #{ primary: true, text: "Noach", lang: "en" },
    #{ primary: true, text: "נח", lang: "he" },
    #{ text: "Parashat Noach", lang: "en" },
    #{ text: "פרשת נח", lang: "he" },
    #{ text: "Noah", lang: "en" },
    #{ text: "Parshat Noah", lang: "en" }
  ],
  scheme: "Parasha",
  order: 2,
  ref: "Genesis 6:9-11:32",
  category: "Torah Portions",
})
model TermsJSON {
  /**
   * The name of the `Term`. Since a `Term` is a shared title node that can be referenced and used by many different `Index` nodes, the `name` field is critical as it contains the shared title.
   */
  @example("Noah")
  name: string;

  /**
   * Alternative titles for the term in Hebrew and English.
   */
  @example(#[
    #{ primary: true, text: "Noach", lang: "en" },
    #{ primary: true, text: "נח", lang: "he" },
    #{ text: "Parashat Noach", lang: "en" },
    #{ text: "פרשת נח", lang: "he" },
    #{ text: "Noah", lang: "en" },
    #{ text: "Parshat Noah", lang: "en" }
  ])
  titles?: TitlesJSON[];

  /**
   * A shared `scheme` for a group of terms.
   */
  @example("Parasha")
  scheme?: string;

  /**
   * Terms that share a `scheme` can be ordered within that `scheme`. So for example, _Parshiyot_ within the `Parasha` scheme can be ordered as per the order of the _Parshiyot_.
   */
  @example(4)
  order?: int32;

  /**
   * For a _Parasha_, this is the Sefaria `Ref` which correlates to this _Parasha_ in the text. For example, _Parshat Noah_ corresponds to the ranged `Ref` of `"Genesis 6:9-11:32"`.
   */
  @example("Genesis 6:9-11:32")
  ref?: ref;

  /**
   * The category of a specific term.
   */
  @example("`texts`, `Torah Portions`")
  category?: string;
}

/**
 * Full response of the Name API
 */
@example(#{
  lang: "en",
  is_ref: true,
  completions: #[
    "Job",
    "Rashi on Job",
    "Rashi on Amos",
    "Rashi on Arachin",
    "Rashi on Beiah",
    "Rashi on Bechorot",
    "Rashi on Berachoth",
    "Rashi on Chag.",
    "Rashi on Hullin",
    "Rashi on Dan."
  ],
  completion_objects: #[
    #{
      title: "Job",
      key: "Job",
      type: "ref",
      is_primary: true,
      order: 1000000,
    },
    #{
      title: "Job",
      type: "Topic",
      key: "job-and-his-friends",
      is_primary: false,
      order: 4999978,
    },
    #{
      title: "Rashi on Job",
      key: "Rashi on Job",
      type: "ref",
      is_primary: true,
      order: 1000000,
    },
    #{
      title: "Rashi on Amos",
      key: "Rashi on Amos",
      type: "ref",
      is_primary: true,
      order: 1000000,
    },
    #{
      title: "Rashi on Arachin",
      key: "Rashi on Arakhin",
      type: "ref",
      is_primary: false,
      order: 1000000,
    },
    #{
      title: "Rashi on Beiah",
      key: "Rashi on Beitzah",
      type: "ref",
      is_primary: false,
      order: 1000000,
    },
    #{
      title: "Rashi on Bechorot",
      key: "Rashi on Bekhorot",
      type: "ref",
      is_primary: false,
      order: 1000000,
    },
    #{
      title: "Rashi on Berachoth",
      key: "Rashi on Berakhot",
      type: "ref",
      is_primary: false,
      order: 1000000,
    },
    #{
      title: "Rashi on Chag.",
      key: "Rashi on Chagigah",
      type: "ref",
      is_primary: false,
      order: 1000000,
    },
    #{
      title: "Rashi on Hullin",
      key: "Rashi on Chullin",
      type: "ref",
      is_primary: false,
      order: 1000000,
    },
    #{
      title: "Rashi on Dan.",
      key: "Rashi on Daniel",
      type: "ref",
      is_primary: false,
      order: 1000000,
    }
  ],
  is_book: false,
  is_node: false,
  is_section: false,
  is_segment: true,
  is_range: false,
  type: "ref",
  ref: "Rashi on Job 1:3:3",
  url: "Rashi_on_Job.1.3.3",
  index: "Rashi on Job",
  book: "Rashi on Job",
  internalSections: #[1, 3, 3],
  internalToSections: #[1, 3, 3],
  sections: #["1", "3", "3"],
  toSections: #["1", "3", "3"],
  examples: #[],
  sectionNames: #["Chapter", "Verse", "Comment"],
  heSectionNames: #["פרק", "פסוק", "פירוש"],
  addressExamples: #["3", "6", "9"],
  heAddressExamples: #["ג׳", "ו׳", "ט׳"],
})
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
  @example(#[
    #{
      title: "Ruth",
      key: "Ruth",
      type: "ref",
      is_primary: true,
      order: 1000000,
    },
    #{
      title: "Ruth Rabbah",
      key: "Ruth Rabbah",
      type: "ref",
      is_primary: true,
      order: 1000000,
    },
    #{
      title: "Ruth",
      type: "PersonTopic",
      key: "ruth",
      is_primary: true,
      order: 4999550,
    },
    #{
      title: "Ruach Hakodesh",
      type: "Topic",
      key: "ruach-hakodesh1",
      is_primary: true,
      order: 4999902,
    },
    #{
      title: "Ruach",
      type: "Topic",
      key: "ruach1",
      is_primary: true,
      order: 4999949,
    },
    #{
      title: "Rubissa Sharona Hassan",
      type: "User",
      key: "sharona-hassan",
      pic: "https://storage.googleapis.com/sefaria-profile-pictures/sharona-hassan-1622999139-small.png",
      order: 6999998,
      is_primary: true,
    }
  ])
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
