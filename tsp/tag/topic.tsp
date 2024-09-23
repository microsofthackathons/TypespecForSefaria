import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";
import "../model/topic.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * Retrieve a specific topic from the `v2` version of the topics API.
 * @returns v2 Specific Topic API
 */
@tag("Topic")
@route("/api/v2/topics/{topic_slug}")
@opExample(
  #{
    returnType: #{
      slug: "moses",
      titles: #[
        #{ text: "Moses", lang: "en", primary: true },
        #{ text: "Moshe", lang: "en" },
        #{ text: "Moshe Rabbeinu", lang: "en" },
        #{ text: "moses", lang: "en" },
        #{ text: "MOshe", lang: "en" },
        #{ text: "#Moshe", lang: "en" },
        #{ text: "Moshe Rebbeinu", lang: "en" },
        #{ text: "Moshe Rabeinu", lang: "en" },
        #{ text: "Moses a Leader", lang: "en" },
        #{ text: "Moses our teacher", lang: "en" },
        #{ text: "משה", lang: "he", primary: true },
        #{ text: "ירד", lang: "he" },
        #{ text: "מֹשֶׁה", lang: "he" },
        #{ text: "משה רבינו", lang: "he" },
        #{ text: "משה כמנהיג", lang: "he" },
        #{ text: "משה רבנו", lang: "he" }
      ],
      subclass: "person",
      alt_ids: #{ _temp_id: "משה", wikidata: "Q9077", _old_slug: "-75" },
      properties: #{
        enWikiLink: #{
          value: "https://en.wikipedia.org/wiki/Moses",
          dataSource: "wikidata",
        },
        heWikiLink: #{
          value: "https://he.wikipedia.org/wiki/משה",
          dataSource: "wikidata",
        },
        deWikiLink: #{
          value: "https://de.wikipedia.org/wiki/Mose",
          dataSource: "wikidata",
        },
        esWikiLink: #{
          value: "https://es.wikipedia.org/wiki/Moisés",
          dataSource: "wikidata",
        },
        frWikiLink: #{
          value: "https://fr.wikipedia.org/wiki/Moïse",
          dataSource: "wikidata",
        },
        ruWikiLink: #{
          value: "https://ru.wikipedia.org/wiki/Моисей",
          dataSource: "wikidata",
        },
      },
      description: #{
        en: "Moses was the greatest prophet in the biblical tradition. Brought up in the Egyptian royal family, he fled Egypt before being sent back by God to lead the Israelites out of slavery and to the Promised Land. He brought the Torah down from Mount Sinai, and, according to Jewish tradition, wrote it all down. He died before reaching Israel.",
        he: "משה היה גדול הנביאים במסורת המקראית. הוא גדל בבית המלוכה המצרי, ברח ממצרים ונשלח לשם בחזרה על ידי אלוהים כדי להוציא את בני ישראל מעבדות ולהביאם לארץ המובטחת. הוא קיבל את התורה בהר סיני, ועל פי המסורת היהודית, כתב אותה מפי האל. הוא נפטר לפני כניסת העם לארץ המובטחת.",
      },
      categoryDescription: #{},
      numSources: 1767,
      good_to_promote: true,
      description_published: true,
      data_source: "sefaria",
      primaryTitle: #{ en: "Moses", he: "משה" },
      primaryTitleIsTransliteration: #{ en: false, he: false },
    },
  },
  #{ title: "Moses" }
)
@get
op getTopicV2(
  /**
   * Values can be `1` or `0`.
   *
   * If `1`, adds the following fields to each intra-topic link: `title`, `titleIsTransliteration`, `shouldDisplay`, and `order`.
   */
  @query annotate_links?: integer,

  /**
   * The slug of the desired topic
   */
  @path topic_slug: string,

  /**
   * Values can be `1` or `0`.
   *
   * If `1`, includes intra-topic links in the `result` field, under `links`.
   */
  @query with_links?: integer,

  /**
   * Values can be `1` or `0`.
   *
   * If `1`, the response includes time period data under the `timePeriod` key.
   */
  @query annotate_time_period?: unknown,

  /**
   * Values can be `1` or `0`.
   *
   * If `1`, groups link types with the `groupRelated` key set to true. This will simulate how the sidebar looks on the Sefaria site.
   */
  @query group_related?: integer,

  /**
   * Values can be `1` or `0`.
   *
   * If `1`, adds a list of `Ref`s tagged with this topic under the `refs` key.
   */
  @query with_refs?: integer,
): TopicJSON;

/**
 * When one calls this endpoint _with_ a specific `topic_slug`, it returns a JSON object containing the metadata for the topic.
 * @returns  When one calls this endpoint _with_ a specific `topic_slug`, it returns a JSON object containing the metadata for the topic.
 */
#deprecated "use getTopicV1"
@tag("Topic")
@route("/api/topics/{topic_slug}")
@opExample(
  #{
    returnType: #{
      slug: "sukkot",
      titles: #[
        #{ text: "Tabernacles", lang: "en" },
        #{ text: "Succot", lang: "en" },
        #{ text: "Sukkos", lang: "en" },
        #{ text: "Succos", lang: "en" },
        #{ text: "Booths", lang: "en" },
        #{ text: "sukkot", lang: "en" },
        #{ text: "succot", lang: "en" },
        #{ text: "Succoth", lang: "en" },
        #{ text: "Sukkoth", lang: "en" },
        #{ text: "חג הסוכות", lang: "he" },
        #{ text: "סכות", lang: "he" },
        #{ text: "Sukkot", lang: "en", primary: true },
        #{ text: "סוכות", lang: "he", primary: true }
      ],
      alt_ids: #{ _temp_id: "סוכות" },
      properties: #{
        heNliLink: #{
          value: "https://www.nli.org.il/he/discover/judaism/holidays/sukkot",
          dataSource: "sefaria",
        },
        enNliLink: #{
          value: "https://www.nli.org.il/en/discover/judaism/holidays/sukkot",
          dataSource: "sefaria",
        },
      },
      description: #{
        en: "Sukkot is a weeklong celebration of the harvest in early fall. It is celebrated by the building of temporary booths — that is, sukkot — outside homes in which people eat their meals and sometimes even sleep. The booths are reminders of the transience of life and the sheltering presence of God.",
        he: "חג הסוכות, הוא חג האסיף, נמשך שבעה ימים ומצוין בחודש תשרי על-ידי בניית סוכה מחוץ לבית, בה  אוכלים וחלק גם ישנים. הסוכה היא תזכורת לסוכות שבנו בני ישראל ביציאת מצרים, ומסמלת את ארעיות החיים ואת נוכחותו המגוננת של ה'",
      },
      categoryDescription: #{},
      displayOrder: 4,
      numSources: 831,
      description_published: true,
      data_source: "sefaria",
      image: #{
        image_uri: "https://storage.googleapis.com/img.sefaria.org/topics/sukkot.jpg",
        image_caption: #{
          en: "Detail of a painting of a sukkah. Image taken from f. 316v of Forli Siddur. 1383, Italian rite. The British Library",
          he: "פרט ציור של סוכה עם שולחן פרוש ושלוש דמויות. דימוי מתוך סידור פורלי, 1383 איטליה",
        },
      },
      primaryTitle: #{ en: "Sukkot", he: "סוכות" },
      primaryTitleIsTransliteration: #{ en: false, he: false },
    },
  },
  #{ title: "Sukkot Topic" }
)
@get
op getTopicV1(
  /**
   * The slug of a topic in the Sefaria system. (To find all of the slugs, you can run `api/topics` without a path parameter to see the data for each topic in our database).
   */
  @path topic_slug: string,

  /**
   * `1` or `0`. If `1`, includes intra-topic links in the `result` field, under `links`.
   */
  @query with_links?: integer,

  /**
   * `1` or `0`. If `1`, adds the following fields to each intra-topic link: `title`, `titleIsTransliteration`, `shouldDisplay`, and `order`.
   */
  @query annotate_links?: integer,

  /**
   * `1` or `0`. If `1`, groups link types with the `groupRelated` key set to true. This will simulate how the sidebar looks on the Sefaria site.
   */
  @query group_related?: integer,

  /**
   * `1` or `0`. If `1`, adds a list of `Ref`s tagged with this topic under the `refs` key.
   */
  @query with_refs?: integer,

  /**
   * `1` or `0`. If `1`, the response includes time period data under the `timePeriod` key.
   */
  @query annotate_time_period?: unknown,
): TopicJSON;

/**
 * The topics API returns a list of JSON objects, each object containing all of the metadata for each topic in the Sefaria database.
 * @returns A list of JSON objects, each object representing a topic in the Sefaria database. Please note, since this list is over 30,000 topics long, in the example we only presented the first several topics that are returned in the array.
 */
@tag("Topic")
@route("/api/topics")
@opExample(
  #{ returnType: getAllTopicsExampleResponse },
  #{ title: "The first three topics returned: " }
)
@get
op getAllTopics(): TopicJSON[];

/**
 * Endpoint to retrieve topics and their links between other topics. As opposed to topic links to refs, this endpoint retrieve connections between one topic to another topic.
 * @returns A list of topics connected to the `topic_slug` as well as a list of links.
 */
@tag("Topic")
@route("/api/topics-graph/{topic_slug}")
@opExample(
  #{
    returnType: #{
      topics: #[
        #{
          slug: "shabbat",
          titles: #[
            #{ text: "Shabbos", lang: "en" },
            #{ text: "Mishnah Shabbat", lang: "en" },
            #{ text: "שַׁבָּת", lang: "he" },
            #{ text: "השבת", lang: "he" },
            #{ text: "Shabbat", lang: "en", primary: true },
            #{ text: "שבת", lang: "he", primary: true }
          ],
          alt_ids: #{ _temp_id: "שבת", _old_slug: "shabbat1" },
          properties: #{
            heNliLink: #{
              value: "https://www.nli.org.il/he/discover/judaism/traditions/shabbat",
              dataSource: "sefaria",
            },
          },
          description: #{
            en: "Shabbat (or Sabbath) falls every seventh day of the week, from Friday just before sunset until dark on Saturday night. It is a day of rest, marking the time when God stopped creating after after the six days of creation. Shabbat recognizes God as Creator of the Universe and as Redeemer of Israel from Egypt.",
            he: "היום השביעי בשבוע, החל מיום שישי בשעת השקיעה ועד צאת הכוכבים במוצאי השבת. יום מנוחה לפי המקורות, המציין את הזמן שבו ה' נח לאחר שברא את העולם.",
          },
          categoryDescription: #{},
          displayOrder: 0,
          numSources: 1662,
          good_to_promote: true,
          description_published: true,
          data_source: "sefaria",
          image: #{
            image_uri: "https://storage.googleapis.com/img.sefaria.org/topics/shabbat.jpg",
            image_caption: #{
              en: "Friday Evening, Isidor Kaufmann, Austria c. 1920. The Jewish Museum, Gift of Mr. and Mrs. M. R. Schweitzer",
              he: "שישי בערב, איזידור קאופמן, וינה 1920. המוזיאון היהודי בניו יורק, מתנת  מר וגברת מ.ר. שוויצר",
            },
          },
          primaryTitle: #{ en: "Shabbat", he: "שבת" },
        },
        #{
          slug: "shabbat-shuvah",
          titles: #[
            #{ text: "Shabbat Shuvah", lang: "en", primary: true },
            #{ text: "שבת שובה", lang: "he", primary: true },
            #{ lang: "he", text: "שובה" }
          ],
          alt_ids: #{ _temp_id: "שבת שובה", _old_slug: "399" },
          description: #{
            en: "Shabbat of Repentance between Rosh Hashanah and Yom Kippur.",
            he: "",
          },
          numSources: 19,
          primaryTitle: #{ en: "Shabbat Shuvah", he: "שבת שובה" },
        },
        #{
          slug: "shabbat-hagadol",
          titles: #[],
          alt_ids: #{},
          description: #{},
          categoryDescription: #{},
          displayOrder: 230,
          numSources: 57,
          description_published: true,
          data_source: "sefaria",
          primaryTitle: #{ en: "Shabbat Hagadol", he: "שבת הגדול" },
        }
      ],
      links: #[
        #{
          toTopic: "shabbat",
          linkType: "is-a",
          class: "intraTopic",
          dataSource: "aspaklaria-edited-by-sefaria",
          fromTopic: "shabbat-shuvah",
          order: #{ linksInCommon: 0, toTfidf: 0, fromTfidf: 0 },
        },
        #{
          toTopic: "shabbat",
          linkType: "is-a",
          class: "intraTopic",
          dataSource: "aspaklaria-edited-by-sefaria",
          fromTopic: "shabbat-hagadol",
          order: #{
            linksInCommon: 1,
            toTfidf: 6.1420049159848755,
            fromTfidf: 9.085421387618508,
          },
        }
      ],
    },
  },
  #{ title: "Shabbat" }
)
@get
op getTopicGraph(
  /**
   * A valid Sefaria slug for a topic in the database.
   */
  @path topic_slug: string,

  /**
   * The type of the link, based on the relationship within our ontology. Many links has an `is-a` relationship (such as `Genesis` `is-a` `Book`), but other topic-to-topic links have a variety of other types documented [here](https://developers.sefaria.org/docs/topic-ontology#overview-of-sefaria-link-types).
   * Some examples include `child-of`, `parent-of`, `sibling-of` etc.
   */
  @query link_type?: string,
): TopicGraphJSON;

/**
 * Given a list of `Ref`s this API returns the most used topics associated with them. This is a fast way of identifying potential shared topics amongst disparate `Ref`s.
 * @returns Successful response
 */
@tag("Topic")
@route("/api/recommend/topics/{ref_list}")
@get
op getRecommendedTopics(
  /**
   * List of strings separated by '+'
   */
  @path ref_list: string,
): recommendedTopicResponse[];

/**
 * Returns Texts API data for a random text taken from popular topic tags.
 * @returns Successful response
 */
@tag("Topic")
@route("/api/texts/random-by-topic")
@opExample(
  #{
    returnType: #{
      ref: "Avot D'Rabbi Natan 32:1",
      topic: #{
        slug: "metushelach",
        titles: #[
          #{
            text: "Metushelach",
            lang: "en",
            primary: true,
            transliteration: true,
          },
          #{ text: "מתושלח", lang: "he", primary: true },
          #{ text: "Methuselah", lang: "en" },
          #{ text: "Methushelach", lang: "en" }
        ],
        subclass: "person",
        alt_ids: #{ _temp_id: "מתושלח", wikidata: "Q156290" },
        properties: #{
          enWikiLink: #{
            value: "https://en.wikipedia.org/wiki/Methuselah",
            dataSource: "wikidata",
          },
          heWikiLink: #{
            value: "https://he.wikipedia.org/wiki/מתושלח",
            dataSource: "wikidata",
          },
          deWikiLink: #{
            value: "https://de.wikipedia.org/wiki/Methusalem",
            dataSource: "wikidata",
          },
          esWikiLink: #{
            value: "https://es.wikipedia.org/wiki/Matusalén",
            dataSource: "wikidata",
          },
          frWikiLink: #{
            value: "https://fr.wikipedia.org/wiki/Mathusalem",
            dataSource: "wikidata",
          },
          ruWikiLink: #{
            value: "https://ru.wikipedia.org/wiki/Мафусал_(потомок_Сифа)",
            dataSource: "wikidata",
          },
        },
        numSources: 7,
        good_to_promote: true,
        primaryTitle: #{ en: "Metushelach", he: "מתושלח" },
      },
      url: "Avot_D'Rabbi_Natan.32.1",
    },
  },
  #{ title: "Metushelach" }
)
@get
op getRandomByTopic(): RandomByTopicJSON;

/**
 * A JSON object containing all of the metadata for a topic object
 */
model TopicJSON {
  /**
   * The unique slug for a given topic.
   */
  slug: string;

  /**
   * An array of JSON objects, each representing an alternative title for the object, in various languages.
   */
  titles: TitlesJSON[];

  /**
   * This is a dictionary containing the keys of naming schemes, and ids of this topic represented in that naming scheme.  It’s used both for canonical names in other naming schemes and temporary storage of names when renaming slugs. All of the data here is for internal use, with the exception of the values `bfo` and `wikidata`. `bfo` refers to [basic formal ontology](https://developers.sefaria.org/docs/topic-ontology), and `wikidata` to the wikidata ontology of topics.
   */
  alt_ids?: {
    _temp_id?: string;
  };

  /**
   * The properties stores optional data relating to the topic, including links (if relevant) to where on can learn more about the topic.
   */
  properties?: TopicPropertyJson;

  /**
   * A description of the topic
   */
  description?: BilingualOf<string>;

  /**
   * A description of the category of this topic
   */
  categoryDescription?: string;

  /**
   * The order in which topics are displayed on the Sefaria website, relative to other topics within their same category.
   */
  displayOrder?: int32;

  /**
   * The number of text sources associated with a topic.
   */
  numSources?: int32;

  /**
   * A boolean representing whether or not the description was published.
   */
  description_published?: boolean;

  /**
   * How the topic was generated, whether by Sefaria, a user on a source sheet, or some other source.
   */
  data_source?: string;

  /**
   * Metadata for images associated with topics.
   */
  image?: TopicImgJSON;

  /**
   * The primary title for a topic.
   */
  primaryTitle?: BilingualOf<string>;

  /**
   * This field has the possibility of being used to indicate whether or not a title is a transliteration, however the data here is not always consistent or up-to-date. Therefore, it is best to disregard the data in this field, and there are many false negatives.
   */
  primaryTitleIsTransliteration?: BilingualOf<string>;
}

model TopicGraphJSON {
  /**
   * Array of topics
   */
  topics?: TopicJSON[];

  links?: TopicGraphLinkJSON[];
}

model recommendedTopicResponse {
  /**
   * The url slug for the topic.
   */
  slug?: string;

  /**
   * Titles for the topic by language (usually Hebrew & English)
   */
  titles?: BilingualOf<string>;

  /**
   * Number of times the topic appears in the references
   */
  count?: int32;
}

/**
 * Response to the random-by-topic API endpoint.
 */
model RandomByTopicJSON {
  /**
   * The `Ref` of the text randomly selected, which is connected to one of the recently popular topics.
   */
  ref?: string;

  /**
   * The topic attached to the `Ref` returned.
   */
  topic?: RandomByTopicTopicJSON;

  /**
   * The `Ref` in a format appropriate for a URL, with spaces replaced with `.` etc.
   */
  url?: string;
}

/**
 * Topic JSON for the `random-by-topic/` endpoint.
 */
model RandomByTopicTopicJSON {
  /**
   * The unique slug for a given topic.
   */
  slug: string;

  /**
   * An array of JSON objects, each representing an alternative title for the object, in various languages.
   */
  titles?: TitlesJSON;

  /**
   * This is a dictionary containing the keys of naming schemes, and ids of this topic represented in that naming scheme.  It’s used both for canonical names in other naming schemes and temporary storage of names when renaming slugs. All of the data here is for internal use, with the exception of the values `bfo` and `wikidata`. `bfo` refers to [basic formal ontology](https://github.com/BFO-ontology/BFO#implementations), and `wikidata` to the wikidata ontology of topics.
   */
  alt_ids?: unknown;

  /**
   * A description of the category of this topic
   */
  categoryDescription?: string;

  /**
   * A topic which will be included in our results from the `random-by-topic` endpoint.
   */
  good_to_promote?: boolean;

  /**
   * The number of text sources associated with a topic.
   */
  numSources?: integer;

  /**
   * A boolean representing whether or not the description was published.
   */
  description_published?: boolean;

  /**
   * How the topic was generated, whether by Sefaria, a user on a source sheet, or some other source.
   */
  data_source?: string;

  /**
   * The primary title for a topic.
   */
  primary_title?: BilingualOf<string>;

  /**
   * A description of the topic
   */
  description?: BilingualOf<string>;
}

/**
 * The JSON object containing information about a topic's properties
 */
model TopicPropertyJson {
  /**
   * A link to the Hebrew page on the website of the National Library of Israel which corresponds to the given topic, so users can learn more.
   */
  heNliLink?: NLILinkJSON;

  /**
   * A link to the English page on the website of the National Library of Israel which corresponds to the given topic, so users can learn more.
   */
  enNliLink?: NLILinkJSON;
}

/**
 * JSON for storing NLI links related to data in the Sefaria database.
 */
model NLILinkJSON {
  /**
   * A link to a corresponding NLI page to learn more.
   */
  value?: string;

  /**
   * The source of the topic data, whether user-created or Sefaria-created.
   */
  dataSource?: string;
}

/**
 * A JSON object containing the image metadata for topics with images.
 */
model TopicImgJSON {
  /**
   * The URL pointing to the image as hosted by Sefaria.
   */
  image_uri?: string;

  /**
   * A JSON object containing the billingual caption data for an image associated with a topic.
   */
  image_caption?: BilingualOf<string>;
}

model TopicGraphLinkJSON {
  /**
   * Slug of the `toTopic` (i.e. the topic to which the link connects to, usually the slug passed as `topic_slug` to the `api/topic-graph` endpoint).
   */
  toTopic?: string;

  /**
   * The type of the link, based on the relationship within our ontology. Many links has an `is-a` relationship (such as `Genesis` `is-a` `Book`), but other topic-to-topic links have a variety of other types documented [here](https://developers.sefaria.org/docs/topic-ontology#overview-of-sefaria-link-types).
   *
   * Some examples include `child-of`, `parent-of`, `sibling-of` etc.
   */
  linkType?: string;

  /**
   * Class of the link `intraTopic` (a link from topic-to-topic) or `refTopic` (a link from a topic-to-ref).
   */
  class?: "refTopic" | "intraTopic";

  /**
   * Source where the topic link originated from.
   */
  dataSource?: string;

  /**
   * Slug of the `fromTopic` (i.e. the topic from which the link originates).
   */
  fromTopic?: string;

  /**
   * A dictionary containing information regarding the links in common, as well as the to and from `tfIdf` scores. To learn more about the [tfIdf](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) algorithm.
   */
  order?: OrderJSON;
}

model OrderJSON {
  linksInCommon?: int32;
  toTfidf?: int32;
  fromTfidf?: int32;
}

const getAllTopicsExampleResponse = #[
  #{
    slug: "prayer",
    titles: #[
      #{ primary: true, text: "תפילה", lang: "he" },
      #{ primary: true, text: "Prayer", lang: "en" },
      #{ text: "Tefillah", lang: "en", transliteration: true },
      #{ text: "תפלה", lang: "he", fromTerm: true },
      #{ text: "T'filah", lang: "en" },
      #{ text: "Tefilla", lang: "en" },
      #{ text: "Tefilah", lang: "en" },
      #{ text: "התפלל", lang: "he" },
      #{ text: "Liturgy", lang: "en" },
      #{ text: "Siddur", lang: "en" },
      #{ text: "תְּפִלָּה", lang: "he" },
      #{ text: "סידור", lang: "he" },
      #{ text: "סדר התפילה", lang: "he" },
      #{ lang: "en", text: "prayer" },
      #{ lang: "en", text: "#Tefillah" },
      #{ lang: "en", text: "Tefila" },
      #{ lang: "en", text: "TEFILA" },
      #{ lang: "en", text: "Tefiilah" },
      #{ lang: "en", text: "Tfillah" },
      #{ lang: "en", text: "T'fillah" },
      #{ lang: "en", text: "T'filla" },
      #{ lang: "en", text: "Tfilla" },
      #{ lang: "en", text: "T'fila" }
    ],
    alt_ids: #{
      _temp_id: "תפלה",
      _temp_toc_id: "Prayer",
      _old_slug: "tfilla1",
    },
    description: #{},
    categoryDescription: #{
      en: "Liturgy and modes of Jewish prayer.",
      he: "נוסחי תפילה ודרכי תפילה יהודית.",
    },
    isTopLevelDisplay: true,
    displayOrder: 30,
    numSources: 2937,
    good_to_promote: true,
    primaryTitle: #{ en: "Prayer", he: "תפילה" },
  },
  #{
    slug: "torah",
    titles: #[
      #{ text: "Torah", lang: "en", primary: true },
      #{ text: "תורה", lang: "he", primary: true },
      #{ text: "Chumash", lang: "en" },
      #{ lang: "en", text: "torah" }
    ],
    alt_ids: #{ _temp_id: "תורה" },
    numSources: 2333,
    good_to_promote: true,
    primaryTitle: #{ en: "Torah", he: "תורה" },
  },
  #{
    slug: "passover",
    titles: #[
      #{ text: "Passover", lang: "en", primary: true },
      #{ text: "פסח", lang: "he", primary: true },
      #{ text: "Pesach", lang: "en", transliteration: true },
      #{ text: "Pesah", lang: "en" },
      #{ text: "Chag HaPesach", lang: "en", fromTerm: true },
      #{ text: "Pessach", lang: "en", fromTerm: true },
      #{ text: "חג הפסח", lang: "he", fromTerm: true },
      #{ text: "חג המצות", lang: "he", fromTerm: true },
      #{ lang: "he", text: "חג פסח" }
    ],
    alt_ids: #{ _temp_id: "פסח", _old_slug: "-13" },
    properties: #{
      heNliLink: #{
        value: "https://www.nli.org.il/he/discover/judaism/holidays/passover",
        dataSource: "sefaria",
      },
      enNliLink: #{
        value: "https://www.nli.org.il/en/discover/judaism/holidays/passover",
        dataSource: "sefaria",
      },
    },
    description: #{
      en: "Passover, or Pesach, is a week long springtime festival commemorating the Exodus from Egypt. It also celebrates national redemption, and freedom from slavery. It is observed through avoidance of certain foods (especially grains) and ritual dinners called Seders where attendees retell the story of the Exodus.",
      he: "חג הפסח הוא חג שנמשך שבוע וחל באביב, לזכר יציאת מצרים. הוא גם חוגג את גאולת העם והשחרור מעבדות. הוא נחגג באמצעות הימנעות ממאכלים מסוימים (במיוחד דגנים) וסעודה טקסית הנקראת ליל הסדר אשר בה מספרים המשתתפים את סיפור יציאת מצרים.",
    },
    categoryDescription: #{},
    displayOrder: 10,
    numSources: 2040,
    description_published: true,
    primaryTitle: #{ en: "Passover", he: "פסח" },
  },
  #{
    slug: "teshuvah",
    titles: #[
      #{ text: "Teshuvah", lang: "en", primary: true },
      #{ text: "Teshuva", lang: "en" },
      #{ text: "Repentance", lang: "en" },
      #{ text: "Tshuva", lang: "en" },
      #{ text: "Repentence", lang: "en" },
      #{ text: "T'shuva", lang: "en" },
      #{ text: "teshuva", lang: "en" },
      #{ text: "teshuvah", lang: "en" },
      #{ text: "Repent", lang: "en" },
      #{ text: "Tshuvah", lang: "en" },
      #{ text: "תשובה", lang: "he", primary: true },
      #{ text: "תְּשׁוּבָה", lang: "he" }
    ],
    alt_ids: #{ _temp_id: "תשובה" },
    description: #{
      en: "The word \"teshuvah\" literally means “return” and is best translated as \"repentance.\" Teshuvah is presented in Jewish sources as a gift from God because it allows one to return to the path of righteousness. Although it can be done at any time, Yom Kippur is the Jewish holiday most associated with repentance.",
      he: "המונח תשובה כוונתו שיבה אל דרכי האל. במקורות היהודיים נתפסת התשובה כמתנה מאלוהים, מכיוון שהיא מאפשרת לאדם לשוב ולדבוק בדרכי הטוב והיושר. אף שתשובה היא דבר שאפשר לעשות בכל עת, יום הכיפורים הוא המועד המוכר ביותר למטרה זו.",
    },
    categoryDescription: #{},
    numSources: 1967,
    good_to_promote: true,
    description_published: true,
    data_source: "sefaria",
    primaryTitle: #{ en: "Teshuvah", he: "תשובה" },
  },
  #{
    slug: "יחיד-וחברה",
    titles: #[#{ lang: "he", text: "יחיד וחברה", primary: true }],
    alt_ids: #{ _old_slug: "-163" },
    numSources: 1826,
    primaryTitle: #{ en: "", he: "יחיד וחברה" },
  }
];
