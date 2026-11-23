import { LightningElement, api } from 'lwc';
import basePath from '@salesforce/community/basePath';

/**
 * @augments LightningElement
 *
 * Script Config Properties
 * @property {string} dataLiUrl data li url
 * @property {string} khorosScriptUrl khoros endpoint
 * Base Properties
 * @property {string} [heading] heading
 * @property {string} [headingStyle=h3] change the heading style
 * @property {string} [ctaLabel] cta link label
 * @property {string} [ctaLink] cta link url
 * @property {boolean} [inverse] inverse
 * @property {string} widgetId widget id - required data config for Khoros content
 * @property {string} skinId skin id - required for styling config
 * @property {string} labels comma separated list of labels
 * @property {string} tags comma separated list of tags
 * Content Properties
 * @property {string} widgetCategory required comma-separated list of categories (ie. category:hardware-products)
 * @property {string} discussionStyle discussion style (Blogs/Contests/Forums/Ideas/Knowledge Base/Q and A)
 * UI Properties
 * @property {string} [displayStyle=Card View] display style (List View / Card View)
 * @property {number} [numberOfMessages=1] 1 - 10
 * @property {string} [sortBy=Most Kudos] sort by: Most Kudos, Most Comments, Most Views, Created Date (desc/asc)
 * @property {boolean} [showAvatars] gets set to TRUE if undefined
 * @property {boolean} [showAuthorName] gets set to TRUE if undefined
 * @property {boolean} [showDateTime] gets set to TRUE if undefined
 * @property {boolean} [showKudos] gets set to TRUE if undefined
 * @property {boolean} [showComments] gets set to TRUE if undefined
 * @property {boolean} [showViews] gets set to TRUE if undefined
 * @property {boolean} [showImage] gets set to TRUE if undefined (Only used in Card View)
 * @property {number} [numberOfBodyLines=2] number of lines for message body
 * @property {boolean} showMessageBody gets set to TRUE if undefined
 */
class IpaKhorosCommunitySyndication extends LightningElement {
  @api heading = '';

  @api headingStyle = 'h3';

  @api ctaLabel = '';

  @api ctaLink = '';

  @api inverse;

  // Hardcoded Base Properties
  @api widgetId = '';

  @api skinId = '';

  @api labels = '';

  @api tags = '';

  // Content Properties
  @api widgetCategory = '';

  @api discussionStyle = '';

  // UI Properties
  @api displayStyle = 'Card View';

  @api numberOfMessages = 1;

  @api sortBy = 'Most Kudos';

  @api showAvatars;

  @api showAuthorName;

  @api showDateTime;

  @api showKudos;

  @api showComments;

  @api showViews;

  @api showImage;

  @api numberOfBodyLines = 2;

  @api showMessageBody;

  @api listItemUrl;

  @api khorosScriptSrc;

  /**
   * track if IFrame times out
   */
  timedOut = false;

  /**
   * Discussion Style
   * - maps design attributes to param values
   *
   * @type {object}
   * @private
   */
  discussionStyleMap = {
    Blogs: 'blogs',
    Contests: 'contests',
    Forums: 'forums',
    Ideas: 'ideas',
    'Knowledge Base': 'knowledge bases',
    'Q and A': 'q and a',
  };

  /**
   * Display Style
   * - maps design attributes to params
   *
   * @type {object}
   * @private
   */
  displayStyleMap = {
    'List View': 'list_view',
    'Card View': 'card_view',
  };

  /**
   * Sort By
   * - maps design attributes to params
   *
   * @type {object}
   * @private
   */
  sortByMap = {
    'Most Kudos': 'kudos',
    'Most Comments': 'comments',
    'Most Views': 'views',
    'Created Date (newest to oldest)': 'date-desc',
    'Created Date (oldest to newest)': 'date-asc',
  };

  /**
   * default value to TRUE if undefined
   *
   * @param {boolean} value initial value
   * @returns {boolean} value
   * @private
   */
  defaultTrue(value) {
    if (value === undefined) {
      return true;
    }
    return value;
  }

  /**
   * params object
   *
   * @returns {object} params
   * @private
   */
  get paramsObj() {
    return {
      dataLiUrl: this.listItemUrl,
      khorosSrc: this.khorosScriptSrc,
      // CONFIG
      id: this.widgetId,
      skinId: this.skinId,
      // CONTENT
      locationDisplayId: this.widgetCategory,
      discussionStyle: this.discussionStyleMap[this.discussionStyle],
      // UI
      displayStyle: this.displayStyleMap[this.displayStyle],
      numberOfMessages: this.numberOfMessages,
      sortBy: this.sortByMap[this.sortBy],
      showAvatars: this.defaultTrue(this.showAvatars),
      showAuthorName: this.defaultTrue(this.showAuthorName),
      showDateTime: this.defaultTrue(this.showDateTime),
      showKudos: this.defaultTrue(this.showKudos),
      showComments: this.defaultTrue(this.showComments),
      showViews: this.defaultTrue(this.showViews),
      showImage: this.displayStyle === 'Card View' ? this.defaultTrue(this.showImage) : false,
      numberOfBodyLines: this.showMessageBody ? this.numberOfBodyLines : '0',
      showMessageBody: this.defaultTrue(this.showMessageBody),
    };
  }

  /** iframe src attribute
   * - IpaKhorosCommunitySyndication VF page
   * - with dynamic parameters
   *
   * @returns {string} src
   * @private
   */
  get iframeSrc() {
    const params = new URLSearchParams();
    Object.keys(this.paramsObj).forEach((key) => {
      params.set(key, this.paramsObj[key]);
    });
    const community = basePath.match(/\/(.+)\/s/)[1];
    return `/${community}/apex/IpaKhorosCommunitySyndication?${params}`;
  }

  /**
   * If Iframe times out (or if in builder) remove it from template
   *
   * @returns {boolean} show Iframe component
   */
  get showIFrame() {
    return !this.inBuilder && !this.timedOut;
  }

  /**
   * doesn't load IFrame content if in Community Experience Builder
   *
   * @returns {boolean} true if in builder
   */
  get inBuilder() {
    return !!window.location.href.match('livepreview.salesforce');
  }

  /**
   * heading styles
   *
   * @returns {string} class list
   * @private
   */
  get headingStyles() {
    return [
      'truncate-2',
      this.headingStyle,
      this.inverse ? 'color-white' : '',
    ].join(' ');
  }

  /**
   * connected callback
   * - adds event listener for postMessage w/ height info
   * (coming from IpaKhorosCommunitySyndication VF page)
   *
   * @private
   */
  connectedCallback() {
    window.addEventListener('message', this.handleMessage.bind(this));
  }

  /**
   * removes listener
   *
   * @private
   */
  disconnectedCallback() {
    window.removeEventListener('message', this.handleMessage.bind(this));
  }

  /**
   * handles message event
   * - resizes frame
   *
   * @param {event} evt message event
   * @private
   */
  handleMessage(evt) {
    if (evt.origin !== window.location.origin) {
      return;
    }
    if (evt.data && evt.data.type === 'khorosTimeout') {
      this.timedOut = true;
      console.error('Error loading Khoros Syndication content. Timed out.');
    }
    if (evt.data && evt.data.type === 'khorosIframeHeight') {
      const { height } = evt.data;
      this.template.querySelector('iframe').style.height = height;
    }
  }
}
export default IpaKhorosCommunitySyndication;