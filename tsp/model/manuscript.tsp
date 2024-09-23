namespace SefariaAPI;

/**
 * Manuscript data and metadata JSON.
 */
@example(#{
  manuscript_slug: "leningrad-codex-(1008-ce)",
  page_id: "LC_Folio_434v",
  image_url: "https://manuscripts.sefaria.org/leningrad-color/BIB_LENCDX_F434B.jpg",
  thumbnail_url: "https://manuscripts.sefaria.org/leningrad-color/BIB_LENCDX_F434B_thumbnail.jpg",
  anchorRef: "Esther 3:15-4:17",
  anchorRefExpanded: #["Esther 4:14"],
  manuscript: #{
    slug: "leningrad-codex-(1008-ce)",
    title: "Leningrad Codex (1008 CE)",
    he_title: "כתב יד לנינגרד (1008)",
    source: "https://dornsife.usc.edu/wsrp/biblical-manuscripts",
    description: "Bruce Zuckerman, West Semitic Research, in collaboration with the Ancient Biblical Manuscript Center; courtesy Russian National Library, Saltykov-Schedrin",
    he_description: "",
  },
})
model ManuscriptJSON {
  /**
   * A unique slug for the given manuscript
   */
  @example("leningrad-codex-(1008-ce)")
  manuscript_slug?: string;

  /**
   * The ID for the specific page within the manuscript being referenced.
   */
  @example("LC_Folio_435r")
  page_id?: string;

  /**
   * The URL to the image of the manuscript, hosted by Sefaria. All URLs will be prefaced by `https://manuscripts.sefaria.org/`
   */
  @example("https://manuscripts.sefaria.org/leningrad-color/BIB_LENCDX_F434B_thumbnail.jpg")
  image_url?: string;

  /**
   * The url to the thumbnail image of the manuscript.
   */
  @example("https://manuscripts.sefaria.org/leningrad-color/BIB_LENCDX_F434B_thumbnail.jpg")
  thumbnail_url?: string;

  /**
   * A manuscript image will in most cases be associated with a range of `refs` (i.e. an image of a page of Tanakh will display multiple verses). The `anchorRef` is that complete range the manuscript is associated with, and will contain within it the specific textual `Ref` passed in as a parameter.
   */
  @example("Esther 3:15-4:17")
  anchorRef?: string;

  /**
   * An array of strings, where each string is a segment level `Ref` of the `Ref` passed in as a parameter. If a segment level `Ref` is passed in, this array will have a length of 1, and only contain that segment level `Ref`. If the `Ref` passed in is ranged, this array will contain each of the segment level `Ref`s within that range.
   *
   * For example, if someone was searching for manuscript data for `Esther 4.14-15`, the `anchorRefExpanded` would contain `Esther 4.14` and `Esther 4.15`.
   */
  @example(#{ anchorRefExpanded: #["Esther 4:14", "Esther 4:15"] })
  @minItems(1)
  anchorRefExpanded?: string[];

  /**
   * The version metadata for the manuscript, including the title, Hebrew and English descriptions.
   */
  manuscript: ManuscriptVersionMetaData;
}

/**
 * The specific metadata for the version of the manuscript.
 */
@example(#{
  slug: "leningrad-codex-(1008-ce)",
  title: "Leningrad Codex (1008 CE)",
  he_title: "כתב יד לנינגרד (1008)",
  source: "https://dornsife.usc.edu/wsrp/biblical-manuscripts",
  description: "Bruce Zuckerman, West Semitic Research, in collaboration with the Ancient Biblical Manuscript Center; courtesy Russian National Library, Saltykov-Schedrin",
  he_description: "",
})
model ManuscriptVersionMetaData {
  /**
   * The unique slug for the manuscript.
   */
  @example("leningrad-codex-(1008-ce)")
  slug: string;

  /**
   * The title of the manuscript.
   */
  @example("Leningrad Codex (1008 CE)")
  title: string;

  /**
   * The manuscript title in Hebrew.
   */
  @example("כתב יד לנינגרד (1008)")
  he_title: string;

  /**
   * The url for the source of the manuscript images.
   */
  @example("https://dornsife.usc.edu/wsrp/biblical-manuscripts/")
  source: string;

  /**
   * A description of the manuscript, oftening containing details about the archivists or where the physical manuscript images can be found, as well as other library details.
   */
  @example("Bruce Zuckerman, West Semitic Research, in collaboration with the Ancient Biblical Manuscript Center; courtesy Russian National Library, Saltykov-Schedrin")
  description: string;

  /**
   * A Hebrew description of the manuscript, oftening containing details about the archivists or where the physical manuscript images can be found, as well as other library details.
   */
  he_description: string;
}
