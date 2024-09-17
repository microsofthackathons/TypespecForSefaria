import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

@tag("Text")
@route("/api/bulktext/{refs}")
@get
op getBulkText(
  /** Pipe delimited list of Refs */
  refs: string,

  @query useTextFamily?: "1",
  @query asSizedString?: "1",
  @query minChar?: int32,
  @query maxChar?: int32,

  /**
   * Unless explicitly specified, the texts API returns a default version for the `he` and `he` responses (usually in Hebrew & English respectfully). Passing an ISO 639-1 language code here will prioritize text versions in that target language if available.
   */
  @query transLangPref?: string,

  @query ven?: string,
  @query vhe?: string,
): Record<BulkTextResponseWithFamily> | Record<BulkTextResponseWithoutFamily>;

model BulkTextResponseBase {
  lang: "he" | "en";
  ref: ref;
  heRef: string;
}

model BulkTextResponseWithFamily extends BulkTextResponseBase {
  he?: string[];
  en?: string[];

  /** The main category that this work falls under. */
  primary_category?: string;
}

model BulkTextResponseWithoutFamily extends BulkTextResponseBase {
  ...BilingualJSONSlim;
}
