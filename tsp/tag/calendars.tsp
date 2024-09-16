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
): CalendarAPIResponse;

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
): CalendarNextReadAPI;

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

  calendar_items?: CalendarAPIResponseCalendarItem[];
}

/**
 * A single learning schedule for the selected date
 */
model CalendarAPIResponseCalendarItem {
  /** The learning schedule title in `he` and `en` */
  title?: {
    en?: string;
    he?: string;
  };

  /** The name of the reading for the selected date in the learning schedule in `en` and `he` */
  displayValue?: {
    en?: string;
    he?: string;
  };

  /** The url path on Sefaria where this selection can be found */
  url?: string;

  ref?: ref;

  /** The Hebrew equivalent of the `ref` */
  heRef?: string;

  /** This is used internally on Sefaria to arrange the learning schedules in the manner we choose. */
  order?: int32;

  /** The primary category that this `ref` belongs to */
  category?: string;

  /** Additional details about this learning schedule entry */
  extraDetails?: {
    /** The breakdown of aliyot for a parashah */
    aliyot?: string[];
  };

  /** A description of this learning schedule entry if it exists in `he` and `en` */
  description?: {
    en?: string;
    he?: string;
  };
}

model CalendarNextReadAPI {
  parasha?: {
    /** This should always read `Parashat Hashavua` */
    title?: {
      en?: string;
      he?: string;
    };

    /** The name of the Parashah */
    displayValue?: {
      en?: string;
      he?: string;
    };

    /** The url path on Sefaria where this selection can be found */
    url?: string;

    ref?: ref;

    /** The Hebrew equivalent of the `ref` */
    heRef?: string;

    /** This is used internally on Sefaria to arrange the learning schedules in the manner we choose. */
    order?: int32;

    /** Should always return `Tanakh` */
    category?: string;

    /** Additional details about this learning schedule entry */
    extraDetails?: {
      /** The breakdown of aliyot for a parashah */
      aliyot?: string[];
    };

    /** A description of this learning schedule entry if it exists in `he` and `en` */
    description?: {
      en?: string;
      he?: string;
    };
  };
  haftarah?: {
    /** This should always read `Haftarah` */
    title?: {
      en?: string;
      he?: string;
    };

    /** The name of the Haftarah */
    displayValue?: {
      en?: string;
      he?: string;
    };

    /** The url path on Sefaria where this selection can be found */
    url?: string;

    ref?: ref;

    /** This is used internally on Sefaria to arrange the learning schedules in the manner we choose. */
    order?: int32;

    /** Should return `Tanakh` */
    category?: string;
  }[];
  date?: utcDateTime;
  he_date?: {
    en?: string;
    he?: string;
  };
}
