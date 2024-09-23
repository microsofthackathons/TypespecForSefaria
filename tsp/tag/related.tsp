import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * A single API endpoint to return all of the content (links, sheets, notes, media, manuscripts, webpages and topics) related to the given `Ref` in the query.
 * @returns All content related to the queried `Ref`.
 */
@tag("Related")
@route("/api/related/{tref}")
@opExample(
  #{ returnType: getRelatedResponseExample },
  #{ title: "Or HaChaim on Deuteronomy 1:1:1" }
)
@get
op getRelated(
  /** A valid Sefaria textual `Ref`. */
  tref: ref,
): RelatedJSON;

/**
 * Returns a list of known connections for the submitted text `ref` along with some additional metadata.
 * @returns Successful response
 */
@tag("Related")
@route("/api/links/{tref}")
@get
op getLinks(
  /** A valid Sefaria textual `Ref`. */
  tref: ref,

  /**
   * `with_text` is an optional parameter that determines whether or not the API response will include the text of any connected links. It's default is `1`
   */
  @query with_text?: "0" | "1",

  /**
   * `with_sheet_links` is an optional parameter that determines whether or not the API response will include links to user generated source sheets from Sefaria. It's default is `0`
   */
  @query with_sheet_links?: "0" | "1",
): LinkObj[];

/**
 * An API endpoint where, given a `Ref`, all of the topics linked to that `Ref` are retrieved along with the respective metadata.
 * @returns Successful response
 */
@tag("Related")
@route("/api/ref-topic-links/{tref}")
@opExample(
  #{
    returnType: #{
      linkType: "about",
      class: "refTopic",
      dataSource: #{ en: "Aspaklaria", he: "אספקלריא", slug: "aspaklaria" },
      is_sheet: false,
      order: #{
        tfidf: 53.476917039392994,
        numDatasource: 2,
        availableLangs: #["en", "he"],
        comp_date: -1400,
        order_id: "A00000000300280026",
        pr: 5.15330629652094,
        curatedPrimacy: #{ en: 100, he: 0 },
      },
      descriptions: #{
        en: #{
          title: "A New Grain Offering",
          prompt: "The central ritual of Shavuot as described in the Torah is a special bread offering that was brought to the Temple. This sacrifice marked the beginning of sacrifices that were brought using grain from that year, as opposed to grains from the previous year, as explained in the Book of Numbers.",
        },
      },
      topic: "shavuot",
      anchorRef: "Numbers 28:26",
      anchorRefExpanded: #["Numbers 28:26"],
    },
  },
  #{ title: "Link to Bamidbar" }
)
@get
op getRefTopicLinks(
  /** A valid Sefaria textual `Ref` */
  tref: ref,
): RefTopicLinksJSON;

model RelatedJSON {
  /**
   * An array of JSON containing the metadata for links to the reference.
   */
  links?: RelatedLinkJSON[];

  /**
   * All public source sheets linked to a given `Ref` or containing that `Ref` on the sheet.
   */
  sheets?: SheetsJSON[];

  /**
   * Any notes a user has on a given `Ref`. **Note:** This data is only available for logged-in users to view their own notes on a text. This field will always present as an empty array for third party developers.
   */
  notes?: unknown[];

  /**
   * Webpages related to the `Ref`.
   */
  webpages?: WebPagesJSON[];

  /**
   * Topics related to a given `Ref`.
   */
  topics?: RelatedTopicJSON[];

  /**
   * An array of manuscript objects containing data of related manuscripts.
   */
  manuscripts?: ManuscriptJSON[];

  /**
   * An array of JSON containing any media related to the `Ref`.
   */
  media?: MediaJSON[];
}

/**
 * The link JSON returned as part of results for the related API endpoint.
 */
@example(#{
  _id: "52245641edbab41a9d003f13",
  index_title: "Rashi on Deuteronomy",
  category: "Commentary",
  type: "commentary",
  ref: "Rashi on Deuteronomy 1:11:1",
  anchorRef: "Deuteronomy 1:11",
  anchorRefExpanded: #["Deuteronomy 1:11"],
  sourceRef: "Rashi on Deuteronomy 1:11:1",
  sourceHeRef: "רש\"י על דברים א׳:י״א:א׳",
  anchorVerse: 11,
  sourceHasEn: true,
  compDate: #[1075, 1105],
  commentaryNum: 11.0001,
  collectiveTitle: #{ en: "Rashi", he: "רש\"י" },
  heTitle: "רש\"י על דברים",
})
model RelatedLinkJSON {
  _id?: string;

  /**
   * English title of the linked work.
   */
  @example("Rashi on Deuteronomy")
  index_title?: string;

  /**
   * Category of the type of link, for example a link between `Rashi on Exodus` and `Exodus` would have a category of `Commentary`.
   */
  @example("Commentary")
  category?: string;

  type?: string;

  /**
   * Specific `Ref` of the segment which is linked to the queried `anchorRef`.
   */
  @example("Rashi on Deuteronomy 1:11:1")
  ref?: ref;

  /**
   * The submitted ref in the GET request at times may fall within a more encompassing ranged `Re`f that includes multiple text segments. The `anchorRef` is that complete range the that the link is associated with, and will contain within it the specific ref that was passed.
   */
  @example("Deuteronomy 1:11")
  anchorRef?: ref;

  /**
   * An array of strings, where each string is a segment level `Ref` of the `Ref` passed in as a parameter. If a segment level `Ref` is passed in, this array will have a length of 1, and only contain that segment level `Ref`. If the `Ref` passed in is ranged, this array will contain each of the segment level `Ref`s within that range.
   *
   * For example, if someone was searching for links for Esther 4.14-15, the `anchorRefExpanded` would contain Esther 4.14 and Esther 4.15.
   */
  @example(#{ anchorRefExpanded: #["Deuteronomy 1:11"] })
  anchorRefExpanded?: ref[];

  @example(" רש\\\"י על דברים א׳:י״א:א׳\n")
  sourceRef?: string;

  /**
   * Hebrew `Ref` of the linked source.
   */
  sourceHeRef?: string;

  anchorVerse?: int32;

  /**
   * Does the source have an English translation?
   */
  @example("True")
  sourceHasEn?: boolean;

  /**
   * Date of the two books in the link were composed. Negative values indicate dates BCE.
   */
  @example(#[1075, 1105])
  compDate?: int32[];

  commentaryNum?: float64;
  collectiveTitle?: BilingualOf<string>;

  /**
   * Hebrew title of the linked work
   */
  @example("רש\\\"י על דברים")
  heTitle?: string;
}

/**
 * JSON containing metadata for media linked to `Ref`s on [Sefaria](sefaria.org)
 */
model MediaJSON {
  /**
   * The URL for the media.
   */
  media_url?: string;

  /**
   * Source of the media.
   */
  source?: string;

  /**
   * Hebrew title of the media source.
   */
  source_he?: string;

  /**
   * Start time of the media associated with this `Ref`.
   */
  start_time?: string;

  /**
   * End time of the portion of the associated media which correlates to this `Ref`.
   */
  end_time?: string;

  /**
   * The `Ref` in the query.
   */
  anchorRef?: ref;

  /**
   * The license on the media.
   */
  license?: string;

  /**
   * Website of the source.
   */
  source_site?: string;

  /**
   * A description of the associated media in English.
   */
  description?: string;

  /**
   * A description of the associated media in Hebrew.
   */
  description_he?: string;
}

/**
 * A JSON object containing the metadata for external webpages linked to this Sefaria `Ref`.
 */
model WebPagesJSON {
  /**
   * URL to the related article on the webpage.
   */
  url?: string;

  /**
   * Title of the webpage
   */
  title?: string;

  /**
   * All textual references found on this webpage which link to various Sefaria `Ref`s.
   */
  refs?: ref[];

  /**
   * Description of the article.
   */
  description?: string;

  /**
   * Number of hits by the Sefaria linker.
   */
  linkerHits?: int32;

  /**
   * Domain of the webpage
   */
  domain?: string;

  /**
   * Name of the webpage
   */
  siteName?: string;

  /**
   * Favicon of the external webspage
   */
  favicon?: string;

  authors?: string;
  articleSource?: string;

  /**
   * The `Ref` connecting this webpage to the queried `Ref`.
   */
  anchorRef?: ref;

  /**
   * If the `anchorRef` is a ranged `Ref`, this is an array of `Refs` containing each of the segments contained within that range. So for example, if `anchorRef` is Genesis 1:1-2, then `anchorRefExpanded` will be `["Genesis 1:1", "Genesis 1:2"]`.
   */
  anchorRefExpanded?: ref[];
}

/**
 * Topic JSON returned in the `topic` field of the related API endpoint.
 */
@example(#{
  linkType: "about",
  class: "refTopic",
  dataSource: #{},
  is_sheet: false,
  generatedBy: "sheet-topic-aggregator",
  order: #{
    user_votes: 14,
    tfidf: 10.783834565585545,
    numDatasource: 1,
    availableLangs: #["en", "he"],
    comp_date: -1400,
    order_id: "A00000000400010001-00010011",
    pr: 8.083013483888324,
    numSources: 143,
  },
  topic: "parashat-devarim",
  title: #{},
  titleIsTransliteration: #{},
  description: #{},
  anchorRef: "Deuteronomy 1:1-11",
  anchorRefExpanded: #[],
})
model RelatedTopicJSON {
  /**
   * The type of link between the topic and the `Ref`. For more on Sefaria's topic ontology, see [here](https://developers.sefaria.org/docs/topic-ontology).
   */
  @example("about")
  linkType?: string;

  /**
   * A classification of the link as either `refTopic` (i.e. a ref to a topic) or `intraTopic` (topic-to-topic). In this case, it would be expected that all returned topic links would be of type `refTopic`.
   */
  class?: "refTopic" | "intraTopic";

  /**
   * JSON containing the information as to the source of the data for a given ref-to-topic link.
   */
  @example(#{
    en: "Sheets by Sefaria users",
    he: "דפי מקורות ממשתמשי ספריא",
    slug: "sefaria-users",
  })
  dataSource?: DataSourceJSON;

  /**
   * Is this ref-to-topic link one that was generated by a user-created source sheet?
   */
  @example("True")
  is_sheet?: boolean;

  /**
   * How the topic was generated (i.e. by a user, aspaklaria, Sefaria staff)
   */
  @example("sheet-topic-aggregator")
  generatedBy?: string;

  /**
   * This JSON includes the various metrics that are relevant for ordering the link on a topics page. We use these metrics at [Sefaria.org](sefaria.org) to change the order on the topics page.
   */
  @example(#{
    user_votes: 14,
    tfidf: 10.783834565585545,
    numDatasource: 1,
    availableLangs: #["en", "he"],
    comp_date: -1400,
    order_id: "A00000000400010001-00010011",
    pr: 8.083013483888324,
    numSources: 143,
  })
  order?: OrderTopicLinkJSON;

  /**
   * Topic slug
   */
  @example("parashat-devarim")
  topic?: string;

  /**
   * The title of the topic in Hebrew (`he`) and English (`en`).
   */
  @example(#{ en: "Parashat Devarim", he: "פרשת דברים" })
  title?: {};

  /**
   * A boolean value for the `he` and `en` fields inside the title JSON, indicating whether or not either translation is a transliteration.
   */
  @example(#{ en: false, he: false })
  titleIsTransliteration?: {};

  /**
   * JSON containing descriptions for a given topic in various languages. Each language contains a title for the topic description, as well as a prompt which previews the source and asks questions to help the user engage with the text.
   */
  @example(#{
    en: "Devarim (“Words”) is the first Torah portion in the Book of Deuteronomy, the final book of the Torah. In it, Moses recounts events from the Israelites’ travels in the desert, like the appointment of judges, the sin of the spies, and the wars with the Emorite kings Sihon and Og.",
    he: "דברים היא הפרשה הראשונה בספר דברים, החומש החמישי והאחרון בתורה. בספר מובאים נאומי משה, שבהם הוא מזכיר אירועים מהעבר, סוקר מצוות שכבר ניתנו ומצווה מצוות חדשות. בפרשה משה מספר על הצורך במינוי שופטים להנהגת העם. הוא גם מזכיר את חטא המרגלים, שבו התלונן העם על הכניסה העתידית לארץ כנען, את העונש שהוטל על העם לנדוד במדבר ארבעים שנה ואת מלחמות ישראל במדבר.",
  })
  description?: {};

  /**
   * The `Ref` in the query.
   */
  anchorRef?: ref;

  /**
   * The segment `Ref`s within the `anchorRef`.
   */
  anchorRefExpanded?: ref[];
}

/**
 * A single link returned by the link (and related[?]) APIs
 */
model LinkObj {
  _id?: string;

  /**
   * The cannonical title of the text in the Sefaria library.
   */
  index_title?: string;

  /**
   * The primary category this ref belongs to on Sefaria.
   */
  category?: string;

  /**
   * An arbitrary string assigned to the connection to identify it. Most commonly `commentary`, `reference`, or an empty string.
   */
  type?: string;

  ref?: ref;

  /**
   * The submitted `ref` in the GET request at times may fall within a more encompassing ranged ref that includes multiple text segments. The `anchorRef` is that complete range the that the link is associated with, and will contain within it the specific `ref` that was passed.
   */
  anchorRef?: string;

  /**
   * An array of strings, where each string is a segment level `ref` of the `ref` passed in as a parameter. If a segment level `ref` is passed in, this array will have a length of 1, and only contain that segment level `ref`. If the `ref` passed in is ranged, this array will contain each of the segment level `ref`s within that range.
   *
   * For example, if someone was searching for links for `Esther 4.14-15`, the `anchorRefExpanded` would contain `Esther 4.14` and `Esther 4.15`.
   */
  @minItems(1) anchorRefExpanded?: string[];

  /**
   * The connecting link for the submitted `ref`
   */
  sourceRef?: ref;

  sourceHeRef?: ref;
  anchorVerse?: int32;
  sourceHasEn?: boolean;

  /**
   * The estimated year of completion of the work according to the Gregorian calendar. If its length is zero the completion date is unknown. If its length is one, then the completion date is that single year. If its length is 2 then the date is a potential range with the first int in the array is the lower end of the range and the latter the higher.
   */
  compDate?: int32[];

  commentaryNum?: float64;
  collectiveTitle?: BilingualOf<string>;

  /**
   * The default text written in RTL characters for the query (Usually Hebrew). It is structured as a JaggedArray (nested arrays), with the lowest level being an array of strings with some html text.
   *
   */
  he?: string;

  /**
   * The title of the work in English for where the default `he` text came from.
   */
  heVersionTitle?: string;

  /**
   * A string of text documenting the license for the text in Hebrew.
   */
  heLicense?: string;

  /**
   * The title of the work in Hebrew for where the default `he` text came from.
   */
  heVersionTitleInHebrew?: string;

  /**
   * The default text written in LTR characters for the query (Usually English). It is structured as a JaggedArray (nested arrays), with the lowest level being an array of strings with some html text.
   */
  text?: unknown[];

  /**
   * A descriptive string which describes what version of a text this is. Is it from a particular printing or edition of a book? An online resource? This string should describe it in English
   */
  versionTitle?: string;

  /**
   * A string of text documenting the license for the text in English.
   */
  license?: string;

  /**
   * A descriptive string which describes what version of a text this is. Is it from a particular printing or edition of a book? An online resource? This string should describe it in Hebrew.
   */
  versionTitleInHebrew?: string;
}

/**
 * Response from the ref-topic-links endpoint
 */
model RefTopicLinksJSON {
  /**
   * The type of the link, based on the relationship within our ontology. Many links has an `is-a` relationship (such as `Genesis` `is-a` `Book`), but other topic-to-topic links have a variety of other types documented  [here](https://developers.sefaria.org/docs/topic-ontology#overview-of-sefaria-link-types).
   *
   * Some examples include `child-of`, `parent-of`, `sibling-of` etc.
   */
  linkType?: string;

  /**
   * A classification of the link as either `refTopic` (i.e. a ref to a topic) or `intraTopic` (topic-to-topic). In this case, it would be expected that all returned topic links would be of type `refTopic`.
   */
  class?: "refTopic" | "intraTopic";

  /**
   * Where the topic link originated from (i.e. was it added to a sheet and generated by Sefaria users, or was it created by the Sefaria learning team?)
   */
  dataSource?: DataSourceJSON;

  /**
   * Is this ref-to-topic link one that was generated by a user-created source sheet?
   */
  is_sheet?: boolean;

  /**
   * This JSON includes the various metrics that are relevant for ordering the link on a topics page. We use these metrics at [Sefaria.org](sefaria.org) to change the order on the topics page.
   */
  order?: OrderTopicLinkJSON;

  /**
   * JSON containing descriptions for a given topic in various languages. Each language contains a `title` for the topic description, as well as a `prompt` which previews the source and asks questions to help the user engage with the text.
   */
  descriptions?: {
    en?: {
      title?: string;
      prompt?: string;
    };
  };

  /**
   * The title of the topic.
   */
  topic?: string;

  /**
   * The `Ref` the topic is connected to, which should overlap with the requested `Ref` passed through the endpoint. For example, if someone queries for `Bamidbar 28:21`, one of the topics returned is `passover` which has an `anchorRef` of `Numbers 28:16-24` - a range overlapping with our desired `Ref`.
   */
  anchorRef?: string;

  /**
   * If the `anchorRef` is a ranged `Ref` (i.e. containing more than a single segment), then this is a list of strings, with each string being one of single segment level `Ref`s that together comprise the range. So for example, the `anchorRefExpanded` of `Exodus 1:1-2` would be `["Exodus 1:1", "Exodus 1:2"]`.
   */
  anchorRefExpanded?: string[];
}

const getRelatedResponseExample = #{
  links: #[
    #{
      _id: "54bd48c4fbfba21733367bfa",
      index_title: "Psalms",
      category: "Tanakh",
      type: "",
      ref: "Psalms 51",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Psalms 51",
      sourceHeRef: "תהילים נ״א",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-1000, 0],
      commentaryNum: 51,
      collectiveTitle: #{ en: "Psalms", he: "תהילים" },
      heTitle: "תהילים",
    },
    #{
      _id: "54bd48c4fbfba21733367bfc",
      index_title: "Pirkei Avot",
      category: "Mishnah",
      type: "",
      ref: "Pirkei Avot 3",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Pirkei Avot 3",
      sourceHeRef: "משנה אבות ג׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[190, 230],
      commentaryNum: 3,
      collectiveTitle: #{ en: "Pirkei Avot", he: "משנה אבות" },
      heTitle: "משנה אבות",
    },
    #{
      _id: "54bd48c4fbfba21733367bfe",
      index_title: "Pirkei Avot",
      category: "Mishnah",
      type: "",
      ref: "Pirkei Avot 4",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Pirkei Avot 4",
      sourceHeRef: "משנה אבות ד׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[190, 230],
      commentaryNum: 4,
      collectiveTitle: #{ en: "Pirkei Avot", he: "משנה אבות" },
      heTitle: "משנה אבות",
    },
    #{
      _id: "54bd48c4fbfba21733367c08",
      index_title: "Proverbs",
      category: "Tanakh",
      type: "",
      ref: "Proverbs 3",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Proverbs 3",
      sourceHeRef: "משלי ג׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-800, -400],
      commentaryNum: 3,
      collectiveTitle: #{ en: "Proverbs", he: "משלי" },
      heTitle: "משלי",
    },
    #{
      _id: "54bd48c4fbfba21733367c0e",
      index_title: "Yoma",
      category: "Talmud",
      type: "",
      ref: "Yoma 19b",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Yoma 19b",
      sourceHeRef: "יומא י״ט ב",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[450, 550],
      commentaryNum: 38,
      collectiveTitle: #{ en: "Yoma", he: "יומא" },
      heTitle: "יומא",
    },
    #{
      _id: "53f17c73fbfba22336eaba1e",
      index_title: "Deuteronomy",
      category: "Tanakh",
      type: "commentary",
      ref: "Deuteronomy 1:1",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Deuteronomy 1:1",
      sourceHeRef: "דברים א׳:א׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-1400, -400],
      commentaryNum: 1.0001,
      collectiveTitle: #{ en: "Deuteronomy", he: "דברים" },
      heTitle: "דברים",
    },
    #{
      _id: "54bd48c4fbfba21733367bf8",
      index_title: "Exodus",
      category: "Tanakh",
      type: "",
      ref: "Exodus 19:2",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Exodus 19:2",
      sourceHeRef: "שמות י״ט:ב׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-1400, -400],
      commentaryNum: 19.0002,
      collectiveTitle: #{ en: "Exodus", he: "שמות" },
      heTitle: "שמות",
    },
    #{
      _id: "54bd48c4fbfba21733367c00",
      index_title: "Numbers",
      category: "Tanakh",
      type: "",
      ref: "Numbers 20",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Numbers 20",
      sourceHeRef: "במדבר כ׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-1400, -400],
      commentaryNum: 20,
      collectiveTitle: #{ en: "Numbers", he: "במדבר" },
      heTitle: "במדבר",
    },
    #{
      _id: "54bd48c4fbfba21733367c02",
      index_title: "Numbers",
      category: "Tanakh",
      type: "",
      ref: "Numbers 12:8",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Numbers 12:8",
      sourceHeRef: "במדבר י״ב:ח׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-1400, -400],
      commentaryNum: 12.0008,
      collectiveTitle: #{ en: "Numbers", he: "במדבר" },
      heTitle: "במדבר",
    },
    #{
      _id: "54bd48c4fbfba21733367c06",
      index_title: "Kiddushin",
      category: "Talmud",
      type: "",
      ref: "Kiddushin 38a",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Kiddushin 38a",
      sourceHeRef: "קידושין ל״ח א",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[450, 550],
      commentaryNum: 75,
      collectiveTitle: #{ en: "Kiddushin", he: "קידושין" },
      heTitle: "קידושין",
    },
    #{
      _id: "54bd48c4fbfba21733367c0a",
      index_title: "Berakhot",
      category: "Talmud",
      type: "",
      ref: "Berakhot 7a",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Berakhot 7a",
      sourceHeRef: "ברכות ז׳ א",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[450, 550],
      commentaryNum: 13,
      collectiveTitle: #{ en: "Berakhot", he: "ברכות" },
      heTitle: "ברכות",
    },
    #{
      _id: "54bd48c4fbfba21733367c0c",
      index_title: "Eruvin",
      category: "Talmud",
      type: "",
      ref: "Eruvin 54a",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Eruvin 54a",
      sourceHeRef: "עירובין נ״ד א",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[450, 550],
      commentaryNum: 107,
      collectiveTitle: #{ en: "Eruvin", he: "עירובין" },
      heTitle: "עירובין",
    },
    #{
      _id: "54bd48c4fbfba21733367c10",
      index_title: "Genesis",
      category: "Tanakh",
      type: "",
      ref: "Genesis 14:13",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Genesis 14:13",
      sourceHeRef: "בראשית י״ד:י״ג",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-1400, -400],
      commentaryNum: 14.0013,
      collectiveTitle: #{ en: "Genesis", he: "בראשית" },
      heTitle: "בראשית",
    },
    #{
      _id: "54bd48c4fbfba21733367c12",
      index_title: "Genesis",
      category: "Tanakh",
      type: "",
      ref: "Genesis 25:27",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Genesis 25:27",
      sourceHeRef: "בראשית כ״ה:כ״ז",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[-1400, -400],
      commentaryNum: 25.0027,
      collectiveTitle: #{ en: "Genesis", he: "בראשית" },
      heTitle: "בראשית",
    },
    #{
      _id: "5c17ba58b071e100bf4f3c69",
      index_title: "Megillah",
      category: "Talmud",
      type: "",
      ref: "Megillah 31b:8",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      sourceRef: "Megillah 31b:8",
      sourceHeRef: "מגילה ל״א ב:ח׳",
      anchorVerse: 1,
      sourceHasEn: true,
      compDate: #[450, 550],
      commentaryNum: 62.0008,
      collectiveTitle: #{ en: "Megillah", he: "מגילה" },
      heTitle: "מגילה",
    }
  ],
  sheets: #[
    #{
      owner: 10614,
      _id: "60ee8884d6d0a523b1342111",
      id: "335567",
      public: true,
      title: "Gentle Rebuke",
      sheetUrl: "/sheets/335567",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      options: #{
        numbered: 0,
        boxed: 0,
        assignable: 0,
        bsd: 0,
        language: "bilingual",
        layout: "sideBySide",
        langLayout: "heRight",
        divineNames: "noSub",
        highlightMode: 0,
        collaboration: "none",
      },
      ownerName: "Rabbi Yossi Orkin",
      ownerProfileUrl: "/profile/yossi-orkin",
      ownerImageUrl: "https://storage.googleapis.com/sefaria-profile-pictures/yossi-orkin-1626415935-small.png",
      status: "public",
      views: 398,
      topics: #[
        #{
          slug: "deuteronomy",
          asTyped: "Parshat Devarim",
          en: "Parshat Devarim",
          he: "ספר דברים",
        }
      ],
      likes: #[],
      summary: "Parshat Devarim Questions",
      is_featured: false,
      category: "Sheets",
      type: "sheet",
    },
    #{
      owner: 92910,
      _id: "60ec76e6340e9458714cc018",
      id: "335153",
      public: true,
      title: "R'Isaac Bernstein -1st of series on \"themes in Devorim\".",
      sheetUrl: "/sheets/335153",
      anchorRef: "Or HaChaim on Deuteronomy 1:1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      options: #{
        numbered: 0,
        boxed: 0,
        assignable: 0,
        bsd: 0,
        language: "hebrew",
        layout: "stacked",
        langLayout: "heRight",
        divineNames: "h",
        highlightMode: 0,
        collaboration: "none",
      },
      ownerName: "I am Anonymous",
      ownerProfileUrl: "/profile/i-am-anonymous",
      ownerImageUrl: "",
      status: "public",
      views: 278,
      topics: #[
        #{
          slug: "parshanut1",
          asTyped: "Parshanut",
          en: "Parshanut",
          he: "פרשנות",
        },
        #{
          slug: "torah-portions",
          asTyped: "Parsha",
          en: "Parsha",
          he: "פרשות השבוע",
        }
      ],
      likes: #[],
      summary: "Parsha shiurim by R'Isaac Bernsein",
      is_featured: false,
      category: "Sheets",
      type: "sheet",
    },
    #{
      owner: 62800,
      _id: "62ed99e8a85e3ca24ef0064f",
      id: "423213",
      public: true,
      title: "OHR HACHAIM ON DEVARIM",
      sheetUrl: "/sheets/423213",
      anchorRef: "Or HaChaim on Deuteronomy 1:1",
      anchorRefExpanded: #["Or HaChaim on Deuteronomy 1:1:1"],
      options: #{
        numbered: 0,
        boxed: 0,
        assignable: 0,
        bsd: 0,
        language: "hebrew",
        layout: "stacked",
        langLayout: "heRight",
        divineNames: "noSub",
        highlightMode: 0,
        collaboration: "none",
      },
      ownerName: "Yitzi Adlin",
      ownerProfileUrl: "/profile/yitzi-adlin",
      ownerImageUrl: "",
      status: "public",
      views: 186,
      topics: #[],
      likes: #[],
      summary: "",
      is_featured: false,
      category: "Sheets",
      type: "sheet",
    }
  ],
  notes: #[],
  webpages: #[],
  topics: #[],
  manuscripts: #[],
  media: #[],
};
