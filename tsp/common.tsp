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
@example("Mishnah Peah 4:2")
scalar ref extends string;

/**
 * Alternative title for a topic, along with the language code representing the language of the given title.
 */
@example(#{ text: "Tabernacles", lang: "en", primary: false })
model TitlesJSON {
  /**
   * The text of the title
   */
  @example("Sukkoth")
  text?: string;

  /**
   * The language of the title, either `en` or `he`.
   */
  @example("he")
  lang?: string;

  /**
   * A field depicting whether or not the title is the primary title. Note: For any given topics, one should expect two titles with this field present and set to `true`, an English and a Hebrew primary title. The English value with `primary` set to `true` will match the string value of the `primaryTitle` field on topic.
   */
  @example(false)
  Primary?: boolean;
}

/**
 * A JSON object containing `he` and `en` properties of the same type, along with documentation for each model. Intended as a building block for other models.
 */
model BilingualOfWithDocumentation<
  T,
  heDoc extends valueof string,
  enDoc extends valueof string
> {
  @doc(enDoc)
  en?: T;

  @doc(heDoc)
  he?: T;
}

/**
 * A JSON object containing `he` and `en` properties of the same type. Intended as a building block for other models.
 */
alias BilingualOf<T> = {
  en?: T;
  he?: T;
};
