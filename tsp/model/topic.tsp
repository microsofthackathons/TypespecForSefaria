namespace SefariaAPI;

/**
 * This JSON includes the various metrics that are relevant for ordering the link on a topics page. We use these metrics at [Sefaria.org](sefaria.org) to change the order on the topics page.
 */
@example(#{
  tfidf: 53.476917039392994,
  numDatasource: 2,
  availableLangs: #["en", "he"],
  comp_date: -1400,
  order_id: "A00000000300280026",
  pr: 5.15330629652094,
  curatedPrimacy: #{ en: 100, he: 0 },
})
model OrderTopicLinkJSON {
  /**
   * Results of the [tfidf algorithm](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) run on the `Ref`s within a given topic, as another metric for evaluating the relevance of a given source on a topic page.
   */
  @example(53.476917039392994)
  tfidf?: float64;

  /**
   * The number of datasources which connect this `Ref` to the topic. A value of `2` will occur when two sources (i.e. `aspaklaria` and `sefaria sheets` both have connections between this `Ref` and this topic.)
   */
  @example(3)
  numDatasource?: int32;

  /**
   * This topic is available in a list of languages represented as strings with their language code.
   */
  @example(#["en", "he"])
  availableLangs?: string[];

  /**
   * The date when the book referenced in the `Ref` was composed. Negative numbers indicate the work was composed BCE, whereas positive numbers indicate the book was composed CE.
   */
  @example(-1400)
  comp_date?: int32;

  /**
   * Unique ID for the `order` JSON.
   */
  @example("A00000000300280026")
  order_id?: string;

  /**
   * `PageRank`. Sefaria calculates `PageRank` for the sources on a given topic page using the internal Sefaria links to create a link graph and then running the [PageRank algorithm](https://en.wikipedia.org/wiki/PageRank) on that. Sources with higher `PageRank` are considered to be more centrally linked and more relevant.
   */
  @example(5.15330629652094)
  pr?: float64;

  /**
   * This field is used for manually ordering a source on a topics page. It has a separate order value for each language.
   */
  @example(#{ en: 100, he: 0 })
  curatedPrimacy?: BilingualOf<int32>;
}

/**
 * JSON containing the information as to the source of the data for a given ref-to-topic link.
 */
@example(#{
  en: "Sheets by Sefaria users",
  he: "דפי מקורות ממשתמשי ספריא",
  slug: "sefaria-users",
})
model DataSourceJSON {
  ...BilingualOfWithDocumentation<
    string,
    "Hebrew title of the data source",
    "English title of the data source"
  >;

  /**
   * Unique slug describing the data source.
   */
  @example("aspaklaria")
  slug?: string;
}
