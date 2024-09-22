namespace SefariaAPI;

/**
 * Manuscript data and metadata JSON.
 */
model ManuscriptJSON {
  /**
   * A unique slug for the given manuscript
   */
  manuscript_slug?: string;

  /**
   * The ID for the specific page within the manuscript being referenced.
   */
  page_id?: string;

  /**
   * The URL to the image of the manuscript, hosted by Sefaria. All URLs will be prefaced by `https://manuscripts.sefaria.org/`
   */
  image_url?: string;

  /**
   * The url to the thumbnail image of the manuscript.
   */
  thumbnail_url?: string;

  /**
   * A manuscript image will in most cases be associated with a range of `refs` (i.e. an image of a page of Tanakh will display multiple verses). The `anchorRef` is that complete range the manuscript is associated with, and will contain within it the specific textual `Ref` passed in as a parameter.
   */
  anchorRef?: string;

  /**
   * An array of strings, where each string is a segment level `Ref` of the `Ref` passed in as a parameter. If a segment level `Ref` is passed in, this array will have a length of 1, and only contain that segment level `Ref`. If the `Ref` passed in is ranged, this array will contain each of the segment level `Ref`s within that range.
   *
   * For example, if someone was searching for manuscript data for `Esther 4.14-15`, the `anchorRefExpanded` would contain `Esther 4.14` and `Esther 4.15`.
   */
  @minItems(1) anchorRefExpanded?: string[];

  /**
   * The version metadata for the manuscript, including the title, Hebrew and English descriptions.
   */
  manuscript: ManuscriptVersionMetaData;
}

/**
 * The specific metadata for the version of the manuscript.
 */
model ManuscriptVersionMetaData {
  /**
   * The unique slug for the manuscript.
   */
  slug: string;

  /**
   * The title of the manuscript.
   */
  title: string;

  /**
   * The manuscript title in Hebrew.
   */
  he_title: string;

  /**
   * The url for the source of the manuscript images.
   */
  source: string;

  /**
   * A description of the manuscript, oftening containing details about the archivists or where the physical manuscript images can be found, as well as other library details.
   */
  description: string;

  /**
   * A Hebrew description of the manuscript, oftening containing details about the archivists or where the physical manuscript images can be found, as well as other library details.
   */
  he_description: string;
}
