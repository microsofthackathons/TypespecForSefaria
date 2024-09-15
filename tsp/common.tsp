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
