import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * A string representing a citation to a Jewish text.
 *
 * A valid `Ref` consists of a title string followed optionally by a section string or a segment string.
 *
 * A title string is any one of the known text titles or title variants in the Sefaria Database.
 */
scalar ref extends string;

/**
 * Alternative title for a topic, along with the language code representing the language of the given title.
 */
model TitlesJSON {
  /**
   * The text of the title
   */
  text?: string;

  /**
   * The language of the title, either `en` or `he`.
   */
  lang?: string;

  /**
   * A field depicting whether or not the title is the primary title. Note: For any given topics, one should expect two titles with this field present and set to `true`, an English and a Hebrew primary title. The English value with `primary` set to `true` will match the string value of the `primaryTitle` field on topic.
   */
  Primary?: boolean;
}

alias BilingualJSONSlim = {
  en?: string;
  he?: string;
};

/**
 * A JSON object containing billingual text, both `he` and `en` parallel texts.
 */
model BillingualJSON {
  /**
   * The English field for a JSON object representing billingual text.
   */
  en?: string;

  /**
   * The Hebrew field for a JSON object representing billingual text.
   */
  he?: string;
}
