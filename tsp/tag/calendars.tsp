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
@example(CalendarAPIResponseBaseReponseExample)
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
  @example("Daf Yomi")
  title?: BilingualOf<string>;

  /** The name of the reading for the selected date in the learning schedule in `en` and `he` */
  @example("Vayishlach")
  displayValue?: BilingualOf<string>;

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
  description?: BilingualOf<string>;
}
@example(#{
  parasha: #{
    title: #{ en: "Parashat Hashavua", he: "פרשת השבוע" },
    displayValue: #{ en: "Vayakhel-Pekudei", he: "ויקהל-פקודי" },
    url: "Exodus.35.1-40.38",
    ref: "Exodus 35:1-40:38",
    heRef: "שמות ל״ה:א׳-מ׳:ל״ח",
    order: 1,
    category: "Tanakh",
    extraDetails: #{
      aliyot: #[
        "Exodus 35:1-35:29",
        "Exodus 35:30-37:16",
        "Exodus 37:17-37:29",
        "Exodus 38:1-39:1",
        "Exodus 39:2-39:21",
        "Exodus 39:22-39:43",
        "Exodus 40:1-40:38",
        "Exodus 12:1-12:20"
      ],
    },
    description: #{
      en: "Vayakhel (“He Assembled”) opens as God commands the Israelites to observe the Sabbath. Moses asks for material donations for the building of the Mishkan (Tabernacle), and the people donate. A group of artisans designated by God begin building the Mishkan and its vessels.\n\nPekudei (“Accountings Of”) is the final Torah reading in the Book of Exodus. It describes the making of priestly garments worn in the Mishkan (Tabernacle) and the completion of its construction. At God’s command, Moses erects the Mishkan and puts its vessels in place, and God's presence fills the Mishkan.",
      he: "בפרשת ויקהל בני ישראל מצווים לשמור את השבת. בני ישראל מתבקשים לתרום חומרים לבניית המשכן; הם נענים לבקשה בנדיבות ומתבקשים להפסיק לתרום. בצלאל ואהליאב מתחילים לנהל את בניית מבנה המשכן, כלי המשכן והחצר. כל פרט מבוצע כפי שציווה אלוהים את משה.\n\nפרשת פקודי, האחרונה בספר שמות, מסכמת את תרומות החומרים השונים למשכן, ואת עשיית בגדי הכהונה. בפרשה מתואר אירוע הקמת המשכן והכנסת הכלים לתוכו. משהושלמה בניית המשכן הענן מכסה את אוהל מועד, והשכינה שורה במשכן. ענן שוכן על המשכן ביום, ובלילה נראית בו אש, לעיני בני ישראל.",
    },
  },
  haftarah: #[
    #{
      title: #{ en: "Haftarah", he: "הפטרה" },
      displayValue: #{
        en: "Ezekiel 45:16-46:18",
        he: "יחזקאל מ״ה:ט״ז-מ״ו:י״ח",
      },
      url: "Ezekiel.45.16-46.18",
      ref: "Ezekiel 45:16-46:18",
      order: 2,
      category: "Tanakh",
    }
  ],
  date: "2026-03-14T00:00:00",
  he_date: #{ en: "Adar 25, 5786", he: "אדר 25, 5786" },
})
model CalendarNextReadAPI {
  parasha?: {
    /** This should always read `Parashat Hashavua` */
    @example("Daf Yomi")
    title?: BilingualOf<string>;

    /** The name of the Parashah */
    @example("Vayishlach")
    displayValue?: BilingualOf<string>;

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
    description?: BilingualOf<string>;
  };
  haftarah?: {
    /** This should always read `Haftarah` */
    @example("Daf Yomi")
    title?: BilingualOf<string>;

    /** The name of the Haftarah */
    @example("Vayishlach")
    displayValue?: BilingualOf<string>;

    /** The url path on Sefaria where this selection can be found */
    url?: string;

    ref?: ref;

    /** This is used internally on Sefaria to arrange the learning schedules in the manner we choose. */
    order?: int32;

    /** Should return `Tanakh` */
    category?: string;
  }[];
  date?: utcDateTime;
  he_date?: BilingualOf<string>;
}

const CalendarAPIResponseBaseReponseExample : CalendarAPIResponse = #{
  date: "2023-11-28",
  timezone: "America/Halifax",
  calendar_items: #[
    #{
      title: #{ en: "Parashat Hashavua", he: "פרשת השבוע" },
      displayValue: #{ en: "Vayishlach", he: "וישלח" },
      url: "Genesis.32.4-36.43",
      ref: "Genesis 32:4-36:43",
      heRef: "בראשית ל״ב:ד׳-ל״ו:מ״ג",
      order: 1,
      category: "Tanakh",
      extraDetails: #{
        aliyot: #[
          "Genesis 32:4-32:13",
          "Genesis 32:14-32:30",
          "Genesis 32:31-33:5",
          "Genesis 33:6-33:20",
          "Genesis 34:1-35:11",
          "Genesis 35:12-36:19",
          "Genesis 36:20-36:43",
          "Genesis 36:40-36:43"
        ],
      },
      description: #{
        en: "Vayishlach (“He Sent”) follows Jacob and his family as Jacob wrestles with a man (commonly understood as an angel), is renamed Israel, and reconciles with his brother, Esau. Jacob’s daughter, Dina, is raped by a Hivite prince, and her brothers sack a city in response. Rachel dies as she gives birth to Jacob's youngest child, Benjamin.",
        he: "פרשת וישלח ממשיכה לעקוב אחרי יעקב ומשפחתו. יעקב נאבק עם איש (שלפי הפרשנות המקובלת הוא מלאך אלוהים), ובסיום המאבק האיש מעניק לו את השם ישראל. יעקב מתפייס עם אחיו עשו. דינה, בתו של יעקב, נאנסת ונשבית בידי נסיך חיווי, ואחיה הורגים את כל הזכרים בעיר ומשיבים אליהם את דינה. רחל מתה בשעת לידתו של בנימין, הצעיר בבני יעקב.",
      },
    },
    #{
      title: #{ en: "Haftarah", he: "הפטרה" },
      displayValue: #{ en: "Obadiah 1:1-21", he: "עובדיה א׳:א׳-כ״א" },
      url: "Obadiah.1.1-21",
      ref: "Obadiah 1:1-21",
      order: 2,
      category: "Tanakh",
    },
    #{
      title: #{ en: "Daf Yomi", he: "דף יומי" },
      displayValue: #{ en: "Bava Kamma 26", he: "בבא קמא כ״ו" },
      url: "Bava_Kamma.26",
      ref: "Bava Kamma 26",
      order: 3,
      category: "Talmud",
    },
    #{
      title: #{ en: "929", he: "929" },
      displayValue: #{ en: "Ezekiel 21 (473)", he: "יחזקאל כ״א (473)" },
      url: "Ezekiel.21",
      ref: "Ezekiel 21",
      order: 4,
      category: "Tanakh",
    },
    #{
      title: #{ en: "Daily Mishnah", he: "משנה יומית" },
      displayValue: #{
        en: "Mishnah Yevamot 10:4-5",
        he: "משנה יבמות י׳:ד׳-ה׳",
      },
      url: "Mishnah_Yevamot.10.4-5",
      ref: "Mishnah Yevamot 10:4-5",
      order: 5,
      category: "Mishnah",
    },
    #{
      title: #{ en: "Daily Rambam", he: "הרמב\"ם היומי" },
      displayValue: #{ en: "Marriage 14", he: "הלכות אישות י״ד" },
      url: "Mishneh_Torah,_Marriage.14",
      ref: "Mishneh Torah, Marriage 14",
      order: 6,
      category: "Halakhah",
    },
    #{
      title: #{
        en: "Daily Rambam (3 Chapters)",
        he: "הרמב\"ם היומי (3 פרקים)",
      },
      displayValue: #{
        en: "Other Sources of Defilement 9-11",
        he: "הלכות שאר אבות הטומאות ט׳-י״א",
      },
      url: "Mishneh_Torah,_Other_Sources_of_Defilement.9-11",
      ref: "Mishneh Torah, Other Sources of Defilement 9-11",
      order: 7,
      category: "Halakhah",
    },
    #{
      title: #{ en: "Daf a Week", he: "דף השבוע" },
      displayValue: #{ en: "Ketubot 64", he: "כתובות ס״ד" },
      url: "Ketubot.64",
      ref: "Ketubot 64",
      order: 8,
      category: "Talmud",
    },
    #{
      title: #{ en: "Halakhah Yomit", he: "הלכה יומית" },
      displayValue: #{
        en: "Shulchan Arukh, Orach Chayim 535:2-536:1",
        he: "שולחן ערוך, אורח חיים תקל״ה:ב׳-תקל״ו:א׳",
      },
      url: "Shulchan_Arukh,_Orach_Chayim.535.2-536.1",
      ref: "Shulchan Arukh, Orach Chayim 535:2-536:1",
      order: 9,
      category: "Halakhah",
    },
    #{
      title: #{ en: "Arukh HaShulchan Yomi", he: "ערוך השולחן היומי" },
      displayValue: #{ en: "Yoreh De'ah 191:7-15", he: "יורה דעה קצ״א:ז׳-ט״ו" },
      url: "Arukh_HaShulchan,_Yoreh_De'ah.191.7-15",
      ref: "Arukh HaShulchan, Yoreh De'ah 191:7-15",
      order: 10,
      category: "Halakhah",
    },
    #{
      title: #{ en: "Tanakh Yomi", he: "תנ\"ך יומי" },
      displayValue: #{ en: "Samuel Seder 17", he: "שמואל סדר יז" },
      url: "I_Samuel.25.33-26.24",
      ref: "I Samuel 25:33-26:24",
      order: 11,
      category: "Tanakh",
    },
    #{
      title: #{ en: "Chok LeYisrael", he: "חק לישראל" },
      displayValue: #{ en: "Vayishlach", he: "וישלח" },
      url: "collections/חק-לישראל?tag=Vayishlach",
      order: 12,
      category: "Tanakh",
    },
    #{
      title: #{ en: "Tanya Yomi", he: "תניא יומי" },
      displayValue: #{ en: "15 Kislev", he: "טו כסלו" },
      url: "Tanya,_Part_V;_Kuntres_Acharon.6.8",
      ref: "Tanya, Part V; Kuntres Acharon 6:8",
      order: 15,
      category: "Chasidut",
    },
    #{
      title: #{ en: "Yerushalmi Yomi", he: "ירושלמי יומי" },
      displayValue: #{
        en: "Jerusalem Talmud Orlah 18",
        he: "תלמוד ירושלמי ערלה יח",
      },
      url: "Jerusalem_Talmud_Orlah.3.1.16-3.1",
      ref: "Jerusalem Talmud Orlah 3:1:16-3:1",
      order: 16,
      category: "Talmud",
    }
  ],
};
