import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * Returns the daily or weekly learning schedule for a given date.
* @returns Successful Response
 */
@tag("Calendars")
@route("/api/calendars")
@get
op getCalendars(
  /**
   * When this value is set to `diaspora=1`, the text returned is the weekly Torah reading for the diaspora. When this value is set to `diaspora=0`, the text returned is the Torah reading for Israel.
   */
  @query diaspora?: "0" | "1",

  /**
   * If available, the weekly _Haftarah_ will be returned for one of the selected custom.
   */
  @query custom?: "ashkenazi" | "sephardi" | "edot%20hamizrach",

  /**
   * By default the API returns for the current time. You can override it by using a combination of the `year`, `day`, and `month` params - all three of which must be used, or else the API will fallback to the default.
   */
  @query year?: numeric,

  /**
   * By default the API returns for the current time. You can override it by using a combination of the `year`, `day`, and `month` params - all three of which must be used, or else the API will fallback to the default.
   */
  @query month?: numeric,

  /**
   * By default the API returns for the current time. You can override it by using a combination of the `year`, `day`, and `month` params - all three of which must be used, or else the API will fallback to the default.
   */
  @query day?: numeric,

  /**
   * By default, the API attempts to return the calendars for the client's timezone. If you want another region you can override it. Timezone names are in accordance with [IANA Standards](https://www.iana.org/time-zones)
   */
  @query timezone?: unknown,
): CalendarNextReadAPI;

/**
 * Given a Parasha name in English, this API returns the next Hebrew and English dates that it is read, along with details about the Torah and Haftarah readings for that date.
* @returns Successful Response
 */
@tag("Calendars")
@route("/api/calendars/next-read/{parasha}")
@get
op getNextRead(
  /**
   * One of the 54 weekly Torah Parasha names in English or one of the 7 double parshiyot.
   */
  @path parasha:
    | "Bereshit"
    | "Noach"
    | "Lech-Lecha"
    | "Vayera"
    | "Chayei Sara"
    | "Toldot"
    | "Vayetzei"
    | "Vayishlach"
    | "Vayeshev"
    | "Miketz"
    | "Vayigash"
    | "Vayechi"
    | "Shemot"
    | "Vaera"
    | "Bo"
    | "Beshalach"
    | "Yitro"
    | "Mishpatim"
    | "Terumah"
    | "Tetzaveh"
    | "Ki Tisa"
    | "Vayakhel"
    | "Pekudei"
    | "Vayikra"
    | "Tzav"
    | "Shmini"
    | "Tazria"
    | "Metzora"
    | "Achrei Mot"
    | "Kedoshim"
    | "Emor"
    | "Behar"
    | "Bechukotai"
    | "Bamidbar"
    | "Nasso"
    | "Beha’alotcha"
    | "Sh’lach"
    | "Korach"
    | "Chukat"
    | "Balak"
    | "Pinchas"
    | "Matot"
    | "Masei"
    | "Devarim"
    | "Vaetchanan"
    | "Eikev"
    | "Re’eh"
    | "Shoftim"
    | "Ki Teitzei"
    | "Ki Tavo"
    | "Nitzavim"
    | "Vayeilech"
    | "Ha’azinu"
    | "Vezot Haberakhah"
    | "Vayakhel-Pekudei"
    | "Tazria-Metzora"
    | "Achrei Mot-Kedoshim"
    | "Behar-Bechukotai"
    | "Chukat-Balak"
    | "Matot-Masei"
    | "Nitzavim-Vayeilech",
): CalendarAPIResponse;


/**
 * A response from the Calendar API
 */
model CalendarAPIResponse {
    /**
     * The datestring for the calendars shown. It should match the values submitted in `year` `month` `day` or should be the current date.
     */
    date?: plainDate;
  
    /**
     * An IANA timezone name
     */
    timezone?: string;
  
    calendar_items?: {
      title?: {
        en?: string;
        he?: string;
      };
      displayValue?: {
        en?: string;
        he?: string;
      };
      url?: string;
      ref?: ref;
      heRef?: string;
      order?: int32;
      category?: string;
      extraDetails?: {
        aliyot?: string[];
      };
      description?: {
        en?: string;
        he?: string;
      };
    }[];
  }
  
  model CalendarNextReadAPI {
    parasha?: {
      title?: {
        en?: string;
        he?: string;
      };
      displayValue?: {
        en?: string;
        he?: string;
      };
      url?: string;
      ref?: ref;
      heRef?: string;
      order?: int32;
      category?: string;
      extraDetails?: {
        aliyot?: string[];
      };
      description?: {
        en?: string;
        he?: string;
      };
    };
    haftarah?: {
      title?: {
        en?: string;
        he?: string;
      };
      displayValue?: {
        en?: string;
        he?: string;
      };
      url?: string;
      ref?: ref;
      order?: int32;
      category?: string;
    }[];
    date?: utcDateTime;
    he_date?: {
      en?: string;
      he?: string;
    };
  }