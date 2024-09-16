namespace SefariaAPI;

/**
 * JSON containing metadata relating for a given source sheet on [Sefaria](sefaria.org).
 */
model SheetsJSON {
  /**
   * the Sefaria User ID of the sheet's owner.
   */
  owner?: int32;

  /**
   * The unique `id` for the source sheet.
   */
  _id?: string;

  /**
   * The `id` of the sheet. This is used in the URL to retrieve sheets, for example, a sheet with an `id` of 1, would be accessible on [Sefaria](sefaria.org) at [sefaria.org/sheets/1](sefaria.org/sheets/1).
   */
  id?: string;

  /**
   * Is this sheet public.
   */
  public?: boolean;

  /**
   * Title of the Source Sheet.
   */
  title?: string;

  /**
   * URL to this source sheet.
   */
  sheetUrl?: string;

  /**
   * The Sefaria reference that connects this sheet to the submitted `ref`
   */
  anchorRef?: ref;

  /**
   * An array containing the individual segments `Ref`s which comprise the `anchorRef`.
   *
   * Example 1: Ranged `Ref`
   * If the `anchorRef` is `Genesis 2:14-16`, the `anchorRefExpanded` is `["Genesis 2:14", "Genesis 2:15", "Genesis 2:16"]`.
   *
   * Example 2: Segment Ref
   * If the `anchorRef` itself is a segment `Ref`, the `anchorRefExpanded` will contain that identical value. For example, `anchorRef` of `Genesis 2:11` will  have an `anchorRefExpanded` of `["Genesis 2:11"]`
   */
  anchorRefExpanded?: ref[];

  /**
   * A JSON object containing document level options related to how this source sheet should be displayed in Sefaria's Source Sheet editor.
   */
  options?: {
    //* Should the sources be automatically numbered in the Sefaria editor view */
    numbered?: boolean;

    //* Should the sources be boxed o the page in the Sefaria editor view */
    boxed?: boolean;

    //* Is this source sheet an assignment for students in the Sefaria editor view */
    assignable?: boolean;

    //* Should the source sheet include בס"ד at the top of the page in the Sefaria editor view */
    bsd?: boolean;

    //* Default display language of the source sheet in the Sefaria editor view */
    language?: "blingual" | "hebrew" | "english";

    //* Default display layout of the source sheet in the Sefaria editor view */
    layout?: string;

    //* Default display side of the language in a bilingual side-by-side view in the Sefaria editor view */
    langLayout?: string;

    //* Should the Tetragrammaton (Shem Hashem) and other variants of the divine name be replaced, and if so in what form? */
    divineNames?: string;

    highlightMode?: int32;
    collaboration?: string;
  };

  collectionTOC?: string;

  /**
   * Name of the owner of the sheet.
   */
  ownerName?: string;

  /**
   * Some source sheets are made by copying another users. If this is one of them, the original owner's user ID will be listed here.
   */
  via?: string;

  /**
   * Some source sheets are made by copying another users. If this is one of them, the original owner's display name will be listed here.
   */
  viaOwnerName?: string;

  /**
   * Some source sheets are created as assignments by a teacher to be completed by students. If this is one of those sheets the name of the assigner will be found here.
   */
  assignerName?: string;

  /**
   * Some source sheets are made by copying another users. If this is one of them, the path to the original owner's profile page will be listed here.
   */
  viaOwnerProfileUrl?: string;

  /**
   * Some source sheets are created as assignments by a teacher to be completed by students. If this is one of those sheets this will be the URL path to their profile.
   */
  assignerProfileUrl?: string;

  /**
   * The URL Path that will link to a user's profile on the Sefaria site.
   */
  ownerProfileUrl?: string;

  /**
   * Sheet owner image.
   */
  ownerImageUrl?: string;

  /**
   * a string indicating whether the sheet is `public` or `unlisted`
   */
  status?: "public" | "unlisted";

  /**
   * Number of source sheet views.
   */
  views?: int32;

  /**
   * Topics linked to the source sheet.
   */
  topics?: SheetTopicJSON[];

  /**
   * An array of user IDs who have favorited or liked this source sheet.
   */
  likes?: unknown[];

  /**
   * A user generated description of the source sheet
   */
  summary?: string;

  /**
   * Some source sheets are made by copying another users. If so, an attribution field will be created and displayed here.
   */
  attribution?: string;

  /**
   * Previously a source sheet flagged with `is_featured` would be promoted throughout the site in various places. This behavior was removed in 2022 but some of the data remains.
   */
  is_featured?: boolean;

  /**
   * This will always return `Sheets`
   */
  category?: string;

  type?: string;
}

model SheetTopicJSON {
  /**
   * Slug of the topic
   */
  slug?: string;

  /**
   * How the user typed the topic
   */
  asTyped?: string;

  /**
   * Hebrew topic title
   */
  he?: string;

  /**
   * English topic title
   */
  en?: string;
}
