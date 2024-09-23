import "@typespec/http";
import "@typespec/openapi";
import "@typespec/openapi3";

import "../common.tsp";

using Http;
using OpenAPI;

namespace SefariaAPI;

/**
 * Initially designed to find links on websites using [Sefaria's Linker](https://www.sefaria.org/linker), the Find Refs API can identify textual refernces in any arbitrary text that gets sent to it via a structured POST request and returns a response object identifying each located reference including its start and end position within the submitted text.
 * @returns Successful Response
 */
@tag("Misc")
@route("/api/find-refs")
@opExample(
  #{
    parameters: #{
      text: #{
        body: "Genesis 1:1 is a citation and also Mishnah Peah 3-4. So is שמות ב",
        title: "Some thoughts on Sefer Bereishit 1",
      },
      lang: "en",
    },
  },
  #{ title: "Example" }
)
@post
op postFindRefs(@body body: FindRefsPOSTRequest): FindRefsAPIResponse;

/**
 * An [elastic search](https://www.elastic.co/guide/en/elasticsearch/reference/current/) endpoint for Sefaria's data. Given a properly formated POST request this endpoint will return search results for appropriate Sefaria records.
 * @returns Successful Response
 */
@tag("Misc")
@route("/api/search-wrapper")
@post
op postSearch(@body body: SearchPOSTData): searchResponse;

/**
 * Given a Sefaria text `Ref` and some other optional parameters, this endpoint returns a .png image ready to share on social media. At Sefaria.org we use it primarily to auto-generate social media images for any page.
 * @returns Successful Response
 */
@tag("Misc")
@route("/api/img-gen/{tref}")
@get
op getSocialMediaImage(
  /** A valid Sefaria textual `Ref`. */
  tref: ref,

  /**
   * The language the social image should return, `en` for English language or `he` for Hebrew.
   */
  @query lang?: "he" | "en",

  /**
   * This value determines the size of the image, set to the platform's ideal as specified in its own developer documentation.
   */
  @query platform?: "facebook" | "twitter",

  /**
   * The title of the version of English text desired for the image.
   */
  @query ven?: string,

  /**
   * The title of the version of Hebrew text desired for the image.
   */
  @query vhe?: string,
): ImagePngResponse;

/**
 * GET requests take a full category path in the request, e.g. `/api/category/Tanakh/Torah/Genesis`, and return the full category object found.
 *
 * If the category is not found, the returned object will have an error attribute. If any element of the path is found, the API will return the closest parent in an attribute called `closest_parent`. This is useful for proactively looking up a category before posting an `Index` to it.
 */
@tag("Misc")
@route("/api/category/{category_path}")
@opExample(
  #{
    returnType: #{
      path: #["Tanakh", "Torah"],
      titles: #[
        #{ lang: "en", text: "Torah", primary: true },
        #{ lang: "he", text: "תורה", primary: true }
      ],
      lastPath: "Torah",
    },
  },
  #{ title: "Genesis" }
)
@get
op getCategory(
  /** A valid Sefaria Category path */
  category_path: string,
): CatJSON;

/**
 * A response to the Find Refs API
 */
@example(#{
  title: #{
    results: #[
      #{
        startChar: 23,
        endChar: 34,
        text: "Bereishit 1",
        linkFailed: false,
        refs: #["Genesis 1"],
      }
    ],
    refData: #{
      `Genesis 1`: #{
        heRef: "בראשית א׳",
        url: "Genesis.1",
        primaryCategory: "Tanakh",
      },
    },
  },
  body: #{
    results: #[
      #{
        startChar: 0,
        endChar: 11,
        text: "Genesis 1:1",
        linkFailed: false,
        refs: #["Genesis 1:1"],
      },
      #{
        startChar: 35,
        endChar: 51,
        text: "Mishnah Peah 3-4",
        linkFailed: false,
        refs: #["Mishnah Peah 3-4"],
      }
    ],
    refData: #{
      `Genesis 1:1`: #{
        heRef: "בראשית א׳:א׳",
        url: "Genesis.1.1",
        primaryCategory: "Tanakh",
      },
      `Mishnah Peah 3-4`: #{
        heRef: "משנה פאה ג׳-ד׳",
        url: "Mishnah_Peah.3-4",
        primaryCategory: "Mishnah",
      },
    },
  },
})
model FindRefsAPIResponse {
  /**
   * Information about any references found in the `title` field of the POST request
   */
  title?: FindRefsAPIResponseReference;

  /**
   * Information about any references found in the `body` field of the POST request
   */
  body?: FindRefsAPIResponseReference;
}

model FindRefsAPIResponseReference {
  results?: FindRefsAPIResponseReferenceResult[];
  refData?: {
    RefTitle?: {
      /** The Hebrew equivalent of the cannonical ref */
      heRef?: string;

      /** The URL this ref can be found at on Sefaria */
      url?: string;

      /** The primary category this ref belongs to on Sefaria */
      primaryCategory?: string;
    };
  };
}

/** A single matched reference */
model FindRefsAPIResponseReferenceResult {
  /** The index of the starting character of the match */
  startChar?: int32;

  /** The index of the ending character of the match */
  endChar?: int32;

  /** The matched reference */
  text?: string;

  linkFailed?: boolean;
  refs?: ref[];
}

@example(searchResponseModelExample)
model searchResponse {
  took?: int32;
  timed_out?: boolean;
  _shards?: {
    total?: int32;
    successful?: int32;
    skipped?: int32;
    failed?: int32;
  };
  hits?: {
    total?: int32;
    max_score?: float64;
    hits?: {
      _index?: string;
      _type?: string;
      _id?: string;
      _score?: float64;
      _source?: {
        ref?: string;
        heRef?: string;
        version?: string;
        lang?: string;
        version_priority?: int32;
        titleVariants?: string[];
        categories?: string[];
        order?: string;
        path?: string;
        pagesheetrank?: float64;
        comp_date?: int32;
        exact?: string;
        naive_lemmatizer?: string;
        hebrew_version_title?: string;
      };
      highlight?: {
        naive_lemmatizer?: string[];
      };
    }[];
  };
  aggregations?: {
    path?: {
      doc_count_error_upper_bound?: int32;
      sum_other_doc_count?: int32;
      buckets?: {
        key?: string;
        doc_count?: int32;
      }[];
    };
  };
}

/**
 * A properly formatted POST request for the Find Refs API
 */
@example(#{
  text: #{
    body: "Genesis 1:1 is a citation and also Mishnah Peah 3-4. So is שמות ב",
    title: "Some thoughts on Sefer Bereishit 1",
  },
  lang: "en",
})
model FindRefsPOSTRequest {
  /**
   * Initially designed for websites, this API expects the `text` field to contain both a `body` and a `title`. When parsing arbitrary text feel free to just use `body` and pass an empty string `''` to `title`
   */
  text: {
    body?: string;
    title?: string;
  };

  /**
   * Either `he` or `en`. If not included, it will default to one based on the number of Hebrew or Latin characters in the `body` of the `text`.
   */
  @example("en")
  lang: "he" | "en";
}

@example(#{
  aggs: #["path"],
  field: "naive_lemmatizer",
  filter_fields: #[],
  filters: #[],
  query: "banana",
  size: 50,
  slop: 10,
  sort_fields: #["pagesheetrank"],
  sort_method: "score",
  sort_reverse: false,
  sort_score_missing: 0.04,
  source_proj: true,
  type: "text",
})
model SearchPOSTData {
  /**
   * List of fields to aggregate on. Common fields are `path` for the `text` type and `group` or `topics` for the `sheet` type
   */
  aggs?: string[];

  /**
   * The field you want to query. Common fields to query are `exact` or `naive_lemmatizer` for the `text` and `merged` indices. For querying the `sheet` index, commonly you'll query the `content` field
   */
  field?: string;

  /**
   * Must be the same length as `filters`. Each entry specifies the field to apply the corresponding filter in `filters`. For queries of type `text` this has no effect since there's only one field to filter text queries on (`path`. this field is explained in `filters`). For `sheet` queries, the following fields can appear in `filter_fields`: `collections` (corresponds to the collections that the sheet is in), `topics_en` (corresponds to the topics for this sheet, translated into English), `topics_he` (corresponds to the topics for this sheet, translated into Hebrew).
   */
  filter_fields?: unknown[];

  /**
   * A list of filters to filter results. These filters cannot include RegEx. Any RegEx characters will be escaped. Each filter is applied to the corresponding field in the `filter_fields` list. E.g. if filters is `["Passover", "Torah Talks"]` and `filter_fields` is `["topics_en", "collections"]` then the `"Passover"` filter will be applied to the `"topics_en"` field and the `"Torah Talks"` filter will be applied to the `"collections"` field. For `text` queries, filters always applies to the `path` field of documents. This essentially corresponds to the category path of the book in Sefaria's table of contents (there are some differences with regards to commentary paths). For `sheet` queries, filters can be applied to `collections`, `topics_en` or `topics_he`. These fields are explained in `filter_fields` param.
   */
  filters?: unknown[];

  /**
   * Your search query.
   */
  query?: string;

  /**
   * For paginating results. The total number of results to return, starting from `start`
   */
  size?: int32;

  /**
   * The maximum distance between each query word in the resulting document. `0` means an exact match must be found
   */
  slop?: int32;

  /**
   * List of fields to sort on. If `sort_method = 'score'` this list should have exactly one item. Common fields to sort on are `comp_date` (which list results from titles published chronologically), `order` (which list results based on Sefaria's table of contents structure), `pagesheetrank` (most relevant results based on the Sheet Rank algorithm), `dateCreated` (for sheet results returned chronologically), `views` (for sheet results based on popularity).
   */
  sort_fields?: string[];

  /**
   * How to sort results. If sort, the values are sorted according to `sort_fields`. If `score`, the value in `sort_fields` is multiplied with the default ElasticSearch score.
   */
  sort_method?: "sort" | "score";

  /**
   * Whether or not to reverse the sort applied on `sort_fields`
   */
  sort_reverse?: boolean;

  /**
   * The number used in case there is a value missing in your `sort_field`
   */
  sort_score_missing?: float64;

  /**
   * By default, the ElasticSearch document is not returned. Specifying `true` will return the entire document. Specifying a `str` or `list(str)` will perform a projection on the document for the specified fields
   */
  source_proj?: boolean;

  /**
   * The ElasticSearch index you want to query, and the results you expect to get back. `sheet` returns results from Sefaria's user generated source sheets, while `text` returns results from the library.
   */
  type?: "text" | "sheet";
}

/**
 * JSON response for a Category GET request
 */
@example(#{
  path: #["Tanakh", "Torah"],
  titles: #[
    #{ lang: "en", text: "Torah", primary: true },
    #{ lang: "he", text: "תורה", primary: true }
  ],
  lastPath: "Torah",
})
model CatJSON {
  /**
   * The full path of the category
   */
  path?: string[];

  /**
   * The titles for the category, in Hebrew and English.
   */
  titles?: TitlesJSON[];

  /**
   * The immediate parent of the current category. So for example, with the category `Tanakh/Torah/Genesis`, the `lastPath` is `Torah`.
   */
  lastPath?: string;
}

/**
 * Successful Response
 */
model ImagePngResponse {
  @statusCode statusCode: 200;
  @header contentType: "image/png";
  @body image: bytes;
}

const searchResponseModelExample = #{
  took: 11,
  timed_out: false,
  _shards: #{ total: 5, successful: 5, skipped: 0, failed: 0 },
  hits: #{
    total: 7,
    max_score: 16692.562,
    hits: #[
      #{
        _index: "text-b",
        _type: "text",
        _id: "Shabbat 73b:7 (Sefaria Community Translation #[en])",
        _score: 16692.562,
        _source: #{
          ref: "Shabbat 73b:7",
          heRef: "שבת ע״ג ב:ז׳",
          version: "Sefaria Community Translation",
          lang: "en",
          version_priority: 1,
          titleVariants: #[
            "Masekhet Shabbat",
            "Shabbos",
            "Shabbath",
            "Talmud Shabbat",
            "Tractate Shabbat",
            "Shab.",
            "Sabb.",
            "Sabbath",
            "BT Shabbat",
            "Shabbat"
          ],
          categories: #["Talmud", "Bavli", "Seder Moed"],
          order: "A00200000100001460007",
          path: "Talmud/Bavli/Seder Moed/Shabbat",
          pagesheetrank: 769.444762983379,
          comp_date: 450,
          exact: "קוצר: harvest Rashi : Is דש = when the kernel falls from natural covering. This means that we can't peel banana... But we can if it's לאלתר - for immediate consumption. Tosphot : Is דש = when your removing something from natural connection",
          naive_lemmatizer: "קוצר: harvest Rashi : Is דש = when the kernel falls from natural covering. This means that we can't peel banana... But we can if it's לאלתר - for immediate consumption. Tosphot : Is דש = when your removing something from natural connection",
          hebrew_version_title: "תרגום קהילת ספריא",
        },
        highlight: #{
          naive_lemmatizer: #[
            "This means that we can't peel <b>banana</b>... But we can if it's לאלתר - for immediate consumption. Tosphot : Is דש = when your removing something from natural connection"
          ],
        },
      },
      #{
        _index: "text-b",
        _type: "text",
        _id: "II Samuel 18:12 (Sefaria Community Translation #[en])",
        _score: 6415.7573,
        _source: #{
          ref: "II Samuel 18:12",
          heRef: "שמואל ב י״ח:י״ב",
          version: "Sefaria Community Translation",
          lang: "en",
          version_priority: 8,
          titleVariants: #[
            "2Sam",
            "Second Samuel",
            "Shmuel Bet",
            "Shmuel II",
            "Samuel II",
            "2 Sam",
            "II Shmuel",
            "II Sam.",
            "II Sam",
            "2Sam.",
            "2 Samuel",
            "II Shemuel",
            "2 Sam.",
            "II. Samuel",
            "II. Sam.",
            "Sam. II",
            "II Samuel"
          ],
          categories: #["Tanakh", "Prophets"],
          order: "A00000100300180012",
          path: "Tanakh/Prophets/II Samuel",
          pagesheetrank: 287.86486919568637,
          comp_date: -1000,
          exact: "And the dude said to Yoav: Bro, I just found the evil guy on a banana papaya tree. Let's go murder him ruthlessly, against the king's orders.",
          naive_lemmatizer: "And the dude said to Yoav: Bro, I just found the evil guy on a banana papaya tree. Let's go murder him ruthlessly, against the king's orders.",
        },
        highlight: #{
          naive_lemmatizer: #[
            "And the dude said to Yoav: Bro, I just found the evil guy on a <b>banana</b> papaya tree. Let's go murder him ruthlessly, against the king's orders."
          ],
        },
      },
      #{
        _index: "text-b",
        _type: "text",
        _id: "English Explanation of Mishnah Maasrot 1:1:4 (Mishnah Yomit by Dr. Joshua Kulp #[en])",
        _score: 36.80613,
        _source: #{
          ref: "English Explanation of Mishnah Maasrot 1:1:4",
          heRef: "ביאור אנגלי על משנה מעשרות א׳:א׳:ד׳",
          version: "Mishnah Yomit by Dr. Joshua Kulp",
          lang: "en",
          version_priority: 0,
          titleVariants: #[],
          categories: #[
            "Mishnah Commentary",
            "Modern Commentary on Mishnah",
            "English Explanation of Mishnah",
            "Seder Zeraim"
          ],
          order: "A001008001000006002000100010004",
          path: "Mishnah Commentary/Modern Commentary on Mishnah/English Explanation of Mishnah/Seder Zeraim/English Explanation of Mishnah Maasrot",
          pagesheetrank: 1.44,
          comp_date: 1997,
          exact: " But whatever is not considered food in the earlier stages #[of its growth] but only in its later stages, is not liable #[to tithe] until it can be considered food. However, if the produce is not considered edible at its earlier stage of growth, if it is nevertheless harvested at this earlier stage, it can be eaten without being tithed. An example might be a banana. A banana harvested at an earlier stage is not considered food and therefore one who does eat such a banana need not tithe it. It would only need to be tithed if harvested when ripe.",
          naive_lemmatizer: " But whatever is not considered food in the earlier stages #[of its growth] but only in its later stages, is not liable #[to tithe] until it can be considered food. However, if the produce is not considered edible at its earlier stage of growth, if it is nevertheless harvested at this earlier stage, it can be eaten without being tithed. An example might be a banana. A banana harvested at an earlier stage is not considered food and therefore one who does eat such a banana need not tithe it. It would only need to be tithed if harvested when ripe.",
        },
        highlight: #{
          naive_lemmatizer: #[
            "An example might be a <b>banana</b>. A <b>banana</b> harvested at an earlier stage is not considered food and therefore one who does eat such a <b>banana</b> need not tithe it."
          ],
        },
      },
      #{
        _index: "text-b",
        _type: "text",
        _id: "Kedushat Levi, Leviticus, Emor 11 (Kedushat Levi translated by Rb. Eliyahu Munk #[en])",
        _score: 27.977217,
        _source: #{
          ref: "Kedushat Levi, Leviticus, Emor 11",
          heRef: "קדושת לוי, ויקרא, אמור י״א",
          version: "Kedushat Levi translated by Rb. Eliyahu Munk",
          lang: "en",
          version_priority: 1,
          titleVariants: #["Emor", "Parashat Emor", "Parshat Emor"],
          categories: #["Chasidut", "Early Works"],
          order: "A0090000010410011",
          path: "Chasidut/Early Works/Kedushat Levi",
          pagesheetrank: 4.840000000000001,
          comp_date: 1772,
          exact: "The sages in Rosh Hashanah 12 alluded to this when ‎they stated that “the Jewish people are in the habit of counting ‎Biblical calendar dates as based on the view of Rabbi Eliezer when ‎speaking of the deluge, , whereas they do so according ‎to the view of Rabbi Joshua when counting the seasons the ‎seasons of the year.” . The Talmud adds that the ‎astronomers of the gentile nations also count the deluge ‎according to the opinion held by Rabbi Joshua. #[The whole ‎statement is extremely puzzling, our author contributing a novel ‎interpretation by understanding it as relating to the mystical ‎dimension of life on earth. Ed.] Our author raises the ‎question that seeing that the astronomers of the gentile nations ‎adopt an opinion that is contrary to halachah , how can they ‎be described as “sages of gentile nations?” We have a rule that ‎anyone contradicting what is written in the Torah or recorded as ‎wisdom by King Solomon is an absolute fool.‎ We need to explain above statement allegorically. We have ‎already explained in connection with a statement in the Talmud ‎‎ Pessachim 118 that when Rabbi Yishmael, son of Rabbi ‎Yossi, fell ill Rabbi Yehudah sent to ‎him asking him to tell them one or two Torah insights of his ‎father that he had not previously revealed. He responded by ‎offering an interpretation of a difficult passage in psalms 117,1 ‎where the psalmist appears to invite the nations of the world to ‎praise G’d, saying: ‎הללו את ה' כל גויים שבחוהו כל האומים‎, “praise the ‎Lord all you nations; extol Him all you peoples!” Seeing that the ‎next verse describes the miracles G’d has performed on behalf of ‎the Jewish people, what reason would the gentiles have to praise ‎G’d for this? He answered that if the gentiles are required to ‎praise the Lord for having been witnesses to miracles performed ‎for the Israelites, how much more so must the Israelites be duty ‎bound to praise Him on account of this! How much loving ‎kindness have we experienced at the hands of G’d without having ‎thanked Him adequately! Thereupon Rabbi asked for another ‎pearl of wisdom that Rabbi Yossi had not yet revealed. He told ‎them that at the time when the messiah would come, the gentiles ‎would welcome him with gifts. It seems clear that the words ‎שבחוהו‎, “praise Him,” in the psalm are not meant as ‎acknowledgement of what G’d had done for the gentiles, but for ‎what He had done for His people, the Israelites. It is the ‎overriding duty of all of G’d’s creatures, including the beasts in ‎the field to praise the Creator in accordance with the manner in ‎which they are capable of doing this. This includes even the flora ‎that appear tied to the place in which they grow, and which do ‎not even enjoy the ability to move freely on G’d’s earth. How ‎much more so must the more advanced forms of life on earth ‎praise their Creator, seeing that they are able to enjoy so much ‎more of the world they have been born into?‎ We may take a cue from the words of Rashi on ‎‎ Shabbat 50, “whatever G’d created, He created for the ‎greater glory of His name.” When Jews are killed for the ‎sanctification of the Lord’s name they do so joyfully.‎ It is therefore not difficult to comprehend that the psalmist ‎reminds the gentiles of their duty to praise the Lord as He has ‎given them an opportunity to carry out His will. Miracles which ‎G’d performed for the Israelites frequently were at the expense of ‎the gentiles who had oppressed them. The psalmist warns these ‎gentiles that they are obligated to praise the Lord for having been ‎privileged to experience His greatness even while they perish in ‎the process. The fact that they had been chosen to be G’d’s means ‎of showing His might to the Israelites is something they have to ‎acknowledge, not grudgingly, but joyfully. The fact that they ‎deliberately try to blind themselves to such recognition, stamps ‎them as utter fools. The perennial problem with fools is that they ‎do not wish to be enlightened, believing that they are wise.‎ However, there will come a time, when G’d will open the eyes ‎of the blind and all of them #[those who have survived the ‎cataclysmic events occurring first, Ed.] will turn into ‎servants of the Lord. At the time of the Exodus, when G’d performed miracles that ‎enabled the Israelites to be redeemed, He revealed His power to ‎the Egyptians at the same time, of course. However, the latter, ‎almost until their last breath did not acknowledge that it was G’d ‎Who was fighting them when the waves of the sea of reeds came ‎crashing over them. ‎ The Jews have not always been better, so that Isaiah 2,5 tells ‎us that the time will come when –after the gentiles have already ‎acknowledged all this in Isaiah 2,3 – they too will experienced the ‎‎“light” of the Lord. In psalms 118 David foresees all this already ‎hundreds of years before the prophet Isaiah.‎ Let us revert to the passage in the Talmud Rosh ‎Hashanah 12, and the strange statement referring to the ‎astronomers of the gentiles as “sages.” Traditionally, the month ‎of Tishrey symbolizes that G’d’s attribute of Justice, sits in ‎judgment of His creatures on the first day of that month. The ‎month of Nissan, however symbolizes the attribute of Mercy, ‎loving kindness, as it is the month during which the Jewish ‎people, who had a minimum of merits to their credit, were ‎redeemed after hundreds of years of persecution. When looked at ‎from the perspective of the gentiles, the month of Nissan ‎symbolizes the attribute of Justice, as during that month G’d ‎brought retribution on the leading nation of the gentiles, ‎reducing a world power, Egypt, to becoming a “banana republic,” ‎practically overnight. The effect of this was so overwhelming that ‎Rahab from Jericho, who harbored Joshua’s spies, was still in awe ‎of that event. .‎ Rabbi Eliezer correctly realized that for the gentiles what we ‎perceive as unmitigated disaster, actually is the catalyst that ‎brings them to recognize G’d in the end, by seeing in the month ‎of Tishrey also a harbinger of the attribute of Mercy, seeing it is ‎the gentiles’ last opportunity to change their ways and survive as ‎servants of G’d. The Talmud introduces a reference to the period during ‎which the deluge occurred, i.e. in Marcheshvan, although neither ‎Rabbi Joshua nor Rabbi Eliezer had made reference to that event ‎at all. When the “sages” of the gentile nations are described as ‎taking their cue from the deluge as being in accord with Rabbi ‎Joshua, even when referring to the deluge, what the Talmud ‎means is that these “gentile sages” recognized that the disasters ‎that had struck them was also an outpouring of G’d’s love, as this ‎enabled the survivors to recognize G’d as a G’d of love after all. ‎‎ #[According to the Talmud there the gentile sages ‎recognized what Yitro recognized later also, i.e. ‎that when G’d brings on retribution He makes the punishment fit ‎the crime. Ed.] ‎",
          naive_lemmatizer: "The sages in Rosh Hashanah 12 alluded to this when ‎they stated that “the Jewish people are in the habit of counting ‎Biblical calendar dates as based on the view of Rabbi Eliezer when ‎speaking of the deluge, , whereas they do so according ‎to the view of Rabbi Joshua when counting the seasons the ‎seasons of the year.” . The Talmud adds that the ‎astronomers of the gentile nations also count the deluge ‎according to the opinion held by Rabbi Joshua. #[The whole ‎statement is extremely puzzling, our author contributing a novel ‎interpretation by understanding it as relating to the mystical ‎dimension of life on earth. Ed.] Our author raises the ‎question that seeing that the astronomers of the gentile nations ‎adopt an opinion that is contrary to halachah , how can they ‎be described as “sages of gentile nations?” We have a rule that ‎anyone contradicting what is written in the Torah or recorded as ‎wisdom by King Solomon is an absolute fool.‎ We need to explain above statement allegorically. We have ‎already explained in connection with a statement in the Talmud ‎‎ Pessachim 118 that when Rabbi Yishmael, son of Rabbi ‎Yossi, fell ill Rabbi Yehudah sent to ‎him asking him to tell them one or two Torah insights of his ‎father that he had not previously revealed. He responded by ‎offering an interpretation of a difficult passage in psalms 117,1 ‎where the psalmist appears to invite the nations of the world to ‎praise G’d, saying: ‎הללו את ה' כל גויים שבחוהו כל האומים‎, “praise the ‎Lord all you nations; extol Him all you peoples!” Seeing that the ‎next verse describes the miracles G’d has performed on behalf of ‎the Jewish people, what reason would the gentiles have to praise ‎G’d for this? He answered that if the gentiles are required to ‎praise the Lord for having been witnesses to miracles performed ‎for the Israelites, how much more so must the Israelites be duty ‎bound to praise Him on account of this! How much loving ‎kindness have we experienced at the hands of G’d without having ‎thanked Him adequately! Thereupon Rabbi asked for another ‎pearl of wisdom that Rabbi Yossi had not yet revealed. He told ‎them that at the time when the messiah would come, the gentiles ‎would welcome him with gifts. It seems clear that the words ‎שבחוהו‎, “praise Him,” in the psalm are not meant as ‎acknowledgement of what G’d had done for the gentiles, but for ‎what He had done for His people, the Israelites. It is the ‎overriding duty of all of G’d’s creatures, including the beasts in ‎the field to praise the Creator in accordance with the manner in ‎which they are capable of doing this. This includes even the flora ‎that appear tied to the place in which they grow, and which do ‎not even enjoy the ability to move freely on G’d’s earth. How ‎much more so must the more advanced forms of life on earth ‎praise their Creator, seeing that they are able to enjoy so much ‎more of the world they have been born into?‎ We may take a cue from the words of Rashi on ‎‎ Shabbat 50, “whatever G’d created, He created for the ‎greater glory of His name.” When Jews are killed for the ‎sanctification of the Lord’s name they do so joyfully.‎ It is therefore not difficult to comprehend that the psalmist ‎reminds the gentiles of their duty to praise the Lord as He has ‎given them an opportunity to carry out His will. Miracles which ‎G’d performed for the Israelites frequently were at the expense of ‎the gentiles who had oppressed them. The psalmist warns these ‎gentiles that they are obligated to praise the Lord for having been ‎privileged to experience His greatness even while they perish in ‎the process. The fact that they had been chosen to be G’d’s means ‎of showing His might to the Israelites is something they have to ‎acknowledge, not grudgingly, but joyfully. The fact that they ‎deliberately try to blind themselves to such recognition, stamps ‎them as utter fools. The perennial problem with fools is that they ‎do not wish to be enlightened, believing that they are wise.‎ However, there will come a time, when G’d will open the eyes ‎of the blind and all of them #[those who have survived the ‎cataclysmic events occurring first, Ed.] will turn into ‎servants of the Lord. At the time of the Exodus, when G’d performed miracles that ‎enabled the Israelites to be redeemed, He revealed His power to ‎the Egyptians at the same time, of course. However, the latter, ‎almost until their last breath did not acknowledge that it was G’d ‎Who was fighting them when the waves of the sea of reeds came ‎crashing over them. ‎ The Jews have not always been better, so that Isaiah 2,5 tells ‎us that the time will come when –after the gentiles have already ‎acknowledged all this in Isaiah 2,3 – they too will experienced the ‎‎“light” of the Lord. In psalms 118 David foresees all this already ‎hundreds of years before the prophet Isaiah.‎ Let us revert to the passage in the Talmud Rosh ‎Hashanah 12, and the strange statement referring to the ‎astronomers of the gentiles as “sages.” Traditionally, the month ‎of Tishrey symbolizes that G’d’s attribute of Justice, sits in ‎judgment of His creatures on the first day of that month. The ‎month of Nissan, however symbolizes the attribute of Mercy, ‎loving kindness, as it is the month during which the Jewish ‎people, who had a minimum of merits to their credit, were ‎redeemed after hundreds of years of persecution. When looked at ‎from the perspective of the gentiles, the month of Nissan ‎symbolizes the attribute of Justice, as during that month G’d ‎brought retribution on the leading nation of the gentiles, ‎reducing a world power, Egypt, to becoming a “banana republic,” ‎practically overnight. The effect of this was so overwhelming that ‎Rahab from Jericho, who harbored Joshua’s spies, was still in awe ‎of that event. .‎ Rabbi Eliezer correctly realized that for the gentiles what we ‎perceive as unmitigated disaster, actually is the catalyst that ‎brings them to recognize G’d in the end, by seeing in the month ‎of Tishrey also a harbinger of the attribute of Mercy, seeing it is ‎the gentiles’ last opportunity to change their ways and survive as ‎servants of G’d. The Talmud introduces a reference to the period during ‎which the deluge occurred, i.e. in Marcheshvan, although neither ‎Rabbi Joshua nor Rabbi Eliezer had made reference to that event ‎at all. When the “sages” of the gentile nations are described as ‎taking their cue from the deluge as being in accord with Rabbi ‎Joshua, even when referring to the deluge, what the Talmud ‎means is that these “gentile sages” recognized that the disasters ‎that had struck them was also an outpouring of G’d’s love, as this ‎enabled the survivors to recognize G’d as a G’d of love after all. ‎‎ #[According to the Talmud there the gentile sages ‎recognized what Yitro recognized later also, i.e. ‎that when G’d brings on retribution He makes the punishment fit ‎the crime. Ed.] ‎",
          hebrew_version_title: "קדושת לוי, מתורגם בידי רבי אליהו מונק",
        },
        highlight: #{
          naive_lemmatizer: #[
            "gentiles, the month of Nissan ‎symbolizes the attribute of Justice, as during that month G’d ‎brought retribution on the leading nation of the gentiles, ‎reducing a world power, Egypt, to becoming a “<b>banana</b>"
          ],
        },
      },
      #{
        _index: "text-b",
        _type: "text",
        _id: "Peninei Halakhah, Shabbat 12:2:3 (Peninei Halakhah, English ed. Yeshivat Har Bracha #[en])",
        _score: 19.184504,
        _source: #{
          ref: "Peninei Halakhah, Shabbat 12:2:3",
          heRef: "פניני הלכה, שבת י״ב:ב׳:ג׳",
          version: "Peninei Halakhah, English ed. Yeshivat Har Bracha",
          lang: "en",
          version_priority: 0,
          titleVariants: #[],
          categories: #["Halakhah", "Modern", "Peninei Halakhah"],
          order: "A004014004010002001200020003",
          path: "Halakhah/Modern/Peninei Halakhah/Peninei Halakhah, Shabbat",
          pagesheetrank: 1.44,
          comp_date: 2007,
          exact: "May one mash foods like bananas and avocados? Some are stringent and forbid doing so with a fork, including for immediate consumption. Even the stringent opinion permits mashing these foods with a spoon, because that is considered a shinui. However, the lenient position allows mashing bananas and avocados even with a fork for immediate consumption, and the halakha follows this position. Thus one may mash a banana or avocado with a fork for immediate consumption. As we have already seen, the prohibition of Toḥen is not relevant to food being prepared for immediate consumption, as long as the mashing is not done with a special utensil designed for this purpose. 3 . There are several reasons for this permission:a) According to most poskim, the prohibition of Toḥen does not apply to fruits or vegetables that are edible .b) Even though SA 321:12 rules in accordance with those who are stringent, nevertheless, when the food is being prepared for immediate consumption, there is no prohibition .c) Even if the prohibition of Toḥen were applicable, according to Igrot Moshe 4:74, Toḥen2, since these foods remain a solid mass even after being mashed, Toḥen does not apply here at all.d) Mashing with a fork already constitutes a shinui, as this is not the normal way to grind . Yeḥaveh Da’at 5:27 and Menuḥat Ahava 2:8:12 permit this in practice. However, Ḥazon Ish OḤ §57 is stringent, and does not allow it even when the food being prepared will be consumed immediately. He also maintains that mashing is considered a type of Toḥen since it breaks down the structure of the fruit. He adds that if the mashing is done to feed the food to a baby, then it is prohibited based on MA 321:14, because it renders the food edible. SSK 6:1 and Hilkhot Shabbat Be-Shabbat 1:12:15 also state that one should be stringent. But they allow mashing with a spoon, as this definitely constitutes a shinui. Similarly, if the foods are very soft, then even those who are normally stringent allow mashing them with a fork. But in practice the primary position is the lenient one, as this is the position of practically all Rishonim.",
          naive_lemmatizer: "May one mash foods like bananas and avocados? Some are stringent and forbid doing so with a fork, including for immediate consumption. Even the stringent opinion permits mashing these foods with a spoon, because that is considered a shinui. However, the lenient position allows mashing bananas and avocados even with a fork for immediate consumption, and the halakha follows this position. Thus one may mash a banana or avocado with a fork for immediate consumption. As we have already seen, the prohibition of Toḥen is not relevant to food being prepared for immediate consumption, as long as the mashing is not done with a special utensil designed for this purpose. 3 . There are several reasons for this permission:a) According to most poskim, the prohibition of Toḥen does not apply to fruits or vegetables that are edible .b) Even though SA 321:12 rules in accordance with those who are stringent, nevertheless, when the food is being prepared for immediate consumption, there is no prohibition .c) Even if the prohibition of Toḥen were applicable, according to Igrot Moshe 4:74, Toḥen2, since these foods remain a solid mass even after being mashed, Toḥen does not apply here at all.d) Mashing with a fork already constitutes a shinui, as this is not the normal way to grind . Yeḥaveh Da’at 5:27 and Menuḥat Ahava 2:8:12 permit this in practice. However, Ḥazon Ish OḤ §57 is stringent, and does not allow it even when the food being prepared will be consumed immediately. He also maintains that mashing is considered a type of Toḥen since it breaks down the structure of the fruit. He adds that if the mashing is done to feed the food to a baby, then it is prohibited based on MA 321:14, because it renders the food edible. SSK 6:1 and Hilkhot Shabbat Be-Shabbat 1:12:15 also state that one should be stringent. But they allow mashing with a spoon, as this definitely constitutes a shinui. Similarly, if the foods are very soft, then even those who are normally stringent allow mashing them with a fork. But in practice the primary position is the lenient one, as this is the position of practically all Rishonim.",
        },
        highlight: #{
          naive_lemmatizer: #[
            "Thus one may mash a <b>banana</b> or avocado with a fork for immediate consumption."
          ],
        },
      },
      #{
        _index: "text-b",
        _type: "text",
        _id: "Klein Dictionary, בָּנָנָה (Carta Jerusalem; 1st edition, 1987 #[en])",
        _score: 1.032272,
        _source: #{
          ref: "Klein Dictionary, בָּנָנָה",
          heRef: "מילון קליין, בָּנָנָה",
          version: "Carta Jerusalem; 1st edition, 1987",
          lang: "en",
          version_priority: 0,
          titleVariants: #["בָּנָנָה"],
          categories: #["Reference", "Dictionary"],
          order: "A013000001B00729",
          path: "Reference/Dictionary/Klein Dictionary",
          pagesheetrank: 0.04,
          comp_date: 1973,
          exact: " בָּנָנָה f.n. FW banana. #[Sp. and Portuguese banana , from earlier Congolese banam .]",
          naive_lemmatizer: " בָּנָנָה f.n. FW banana. #[Sp. and Portuguese banana , from earlier Congolese banam .]",
          hebrew_version_title: "כרטא תשמ״ז",
        },
        highlight: #{
          naive_lemmatizer: #[
            "FW <b>banana</b>. #[Sp. and Portuguese <b>banana</b> , from earlier Congolese banam .]"
          ],
        },
      },
      #{
        _index: "text-b",
        _type: "text",
        _id: "Klein Dictionary, מוֹז (Carta Jerusalem; 1st edition, 1987 #[en])",
        _score: 0.9270322,
        _source: #{
          ref: "Klein Dictionary, מוֹז",
          heRef: "מילון קליין, מוֹז",
          version: "Carta Jerusalem; 1st edition, 1987",
          lang: "en",
          version_priority: 0,
          titleVariants: #["מוֹז"],
          categories: #["Reference", "Dictionary"],
          order: "A013000001M00857",
          path: "Reference/Dictionary/Klein Dictionary",
          pagesheetrank: 0.04,
          comp_date: 1973,
          exact: " מוֹז m.n. NH banana . #[Introduced by Eliezer ben Yehudah as a loan word from Arab. mauz , which is related to Aram. מוֹזָא .]",
          naive_lemmatizer: " מוֹז m.n. NH banana . #[Introduced by Eliezer ben Yehudah as a loan word from Arab. mauz , which is related to Aram. מוֹזָא .]",
          hebrew_version_title: "כרטא תשמ״ז",
        },
        highlight: #{
          naive_lemmatizer: #[
            "NH <b>banana</b> . #[Introduced by Eliezer ben Yehudah as a loan word from Arab. mauz , which is related to Aram. מוֹזָא .]"
          ],
        },
      }
    ],
  },
  aggregations: #{
    path: #{
      doc_count_error_upper_bound: 0,
      sum_other_doc_count: 0,
      buckets: #[
        #{ key: "Reference/Dictionary/Klein Dictionary", doc_count: 2 },
        #{ key: "Chasidut/Early Works/Kedushat Levi", doc_count: 1 },
        #{
          key: "Halakhah/Modern/Peninei Halakhah/Peninei Halakhah, Shabbat",
          doc_count: 1,
        },
        #{
          key: "Mishnah Commentary/Modern Commentary on Mishnah/English Explanation of Mishnah/Seder Zeraim/English Explanation of Mishnah Maasrot",
          doc_count: 1,
        },
        #{ key: "Talmud/Bavli/Seder Moed/Shabbat", doc_count: 1 },
        #{ key: "Tanakh/Prophets/II Samuel", doc_count: 1 }
      ],
    },
  },
};
