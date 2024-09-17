namespace SefariaAPI;

/**
 * This JSON includes the various metrics that are relevant for ordering the link on a topics page. We use these metrics at [Sefaria.org](sefaria.org) to change the order on the topics page.
 */
model OrderTopicLinkJSON {
  /**
   * Results of the [tfidf algorithm](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) run on the `Ref`s within a given topic, as another metric for evaluating the relevance of a given source on a topic page.
   */
  tfidf?: float64;

  /**
   * The number of datasources which connect this `Ref` to the topic. A value of `2` will occur when two sources (i.e. `aspaklaria` and `sefaria sheets` both have connections between this `Ref` and this topic.)
   */
  numDatasource?: int32;

  /**
   * This topic is available in a list of languages represented as strings with their language code.
   */
  availableLangs?: string[];

  /**
   * The date when the book referenced in the `Ref` was composed. Negative numbers indicate the work was composed BCE, whereas positive numbers indicate the book was composed CE.
   */
  comp_date?: int32;

  /**
   * Unique ID for the `order` JSON.
   */
  order_id?: string;

  /**
   * `PageRank`. Sefaria calculates `PageRank` for the sources on a given topic page using the internal Sefaria links to create a link graph and then running the [PageRank algorithm](https://en.wikipedia.org/wiki/PageRank) on that. Sources with higher `PageRank` are considered to be more centrally linked and more relevant.
   */
  pr?: float64;

  /**
   * This field is used for manually ordering a source on a topics page. It has a separate order value for each language.
   */
  curatedPrimacy?: BilingualOf<int32>;
}

/**
 * JSON containing the information as to the source of the data for a given ref-to-topic link.
 */
model DataSourceJSON {
  ... BilingualOfWithDocumentation<string, "Hebrew title of the data source", "English title of the data source">;

  /**
   * Unique slug describing the data source.
   */
  slug?: string;
}
