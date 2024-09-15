import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "./tag/text.tsp";
import "./tag/index.tsp";
import "./tag/related.tsp";
import "./tag/calendars.tsp";
import "./tag/lexicon.tsp";
import "./tag/topic.tsp";
import "./tag/term.tsp";
import "./tag/misc.tsp";

using Http;
using OpenAPI;

/**
 * The Sefaria API endpoints allows live access to Sefaria's structured database of Jewish texts and their interconnections.
 */
@service({
  title: "Sefaria API",
})
@info({
  version: "1.0.0",
  contact: {
    url: "https://www.sefaria.org",
    email: "developers@sefaria.org",
  },
  license: {
    name: "GNU AGPLv3",
    url: "https://www.gnu.org/licenses/agpl.txt",
  },
})
@server("https://www.sefaria.org", "")
namespace SefariaAPI;
