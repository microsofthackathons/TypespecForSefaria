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
@get
op getTopicV2(
  
  topic_slug: string,
  /**
   * Values can be `1` or `0`.
   *
   * If `1`, adds the following fields to each intra-topic link: `title`, `titleIsTransliteration`, `shouldDisplay`, and `order`.
   */
  @query annotate_links?: integer,
): TopicJSON;

/**
 * When one calls this endpoint _with_ a specific `topic_slug`, it returns a JSON object containing the metadata for the topic.
 * @returns  When one calls this endpoint _with_ a specific `topic_slug`, it returns a JSON object containing the metadata for the topic.
 */
@tag("Topic")
@route("/api/topics/{topic_slug}")
@get
op getTopicV1(topic_slug : string): TopicJSON;

/**
 * The topics API returns a list of JSON objects, each object containing all of the metadata for each topic in the Sefaria database.
* @returns A list of JSON objects, each object representing a topic in the Sefaria database. Please note, since this list is over 30,000 topics long, in the example we only presented the first several topics that are returned in the array.
 */
@tag("Topic")
@route("/api/topics")
@get
op getAllTopics(): TopicJSON[];

/**
 * Endpoint to retrieve topics and their links between other topics. As opposed to topic links to refs, this endpoint retrieve connections between one topic to another topic.
* @returns A list of topics connected to the `topic_slug` as well as a list of links.
 */
@tag("Topic")
@route("/api/topics-graph/{topic_slug}")
@get
op getTopicGraph(topic_slug : string): TopicGraphJSON;

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
     * A description of the topic in English
     */
    description?: BillingualJSON;
  
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
    primaryTitle?: BillingualJSON;
  
    /**
     * This field has the possibility of being used to indicate whether or not a title is a transliteration, however the data here is not always consistent or up-to-date. Therefore, it is best to disregard the data in this field, and there are many false negatives.
     */
    primaryTitleIsTransliteration?: BillingualJSON;
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
    titles?: {
      en?: string;
      he?: string;
    };
  
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
    primary_title?: BillingualJSON;
  
    /**
     * A description of the topic in English
     */
    description?: BillingualJSON;
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
    image_caption?: BillingualJSON;
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