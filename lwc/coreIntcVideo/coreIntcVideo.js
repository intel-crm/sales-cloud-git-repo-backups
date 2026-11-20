import { LightningElement, api } from 'lwc';
import videoError from '@salesforce/label/c.Core_Intc_Video_Error';

/**
 * A reusable component to display video using Iframe. Currently supported format are: Brightcove, YouTube.
 * It also provides settings to specify the width and height of the video using any valid css value. By default,
 * the video component's width and height is determined by its parent div.
 *
 * ### Rendering the component
 * In order to render the video correctly, there are 2 options available:
 * * Provide unique Id related to the video.
 *   * For Brightcove videos, provide the correct <code>account</code> and <code>videoId</code>. This information can be found from
 *   [Brightcove Video Cloud](https://studio.brightcove.com).
 *   * For YouTube videos, provide the <code> videoId </code>. This information can be found as the URL parameters of the YouTube video.
 *     For instance, the following YouTube video has the id of XpglSazGh0E.
 *     https://www.youtube.com/watch?v=XpglSazGh0E&ab_channel=Intel
 * * Custom Iframe URL
 *   * Alternatively, custom iframe url can be provided as <code>iframeUrl</code> property to render video.
 *
 * For both options, provide the title of the iframe. This is needed for accessibility.
 *
 * <div id="core-examples" sf-attr="c-coreintcvideo_coreintcvideo">
 *   <demo-core-intc-video show1="true"></demo-core-intc-video>
 *   <demo-core-intc-video show2="true"></demo-core-intc-video>
 *   <demo-core-intc-video show3="true"></demo-core-intc-video>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Brightcove -->
 * <c-core-intc-video video-type="brightcove" account="921483702001" video-id="4570583963001" title="Brightcove video player">
 * </c-core-intc-video>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- YouTube -->
 * <c-core-intc-video video-type="youtube" video-id="XpglSazGh0E" title="YouTube video player">
 * </c-core-intc-video>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- YouTube with custom iframeUrl -->
 * <c-core-intc-video video-type="youtube" iframe-url="https://www.youtube.com/embed/XpglSazGh0E" title="YouTube video player">
 * </c-core-intc-video>
 *
 *
 * @augments LightningElement
 * @property {string} videoType Required - Values: brightcove, youtube
 * @property {string} [width=100%] specify width value (can be number, percentage, or other css value (px/rem))
 * @property {string} [height=100%] specify height value (can be number, percentage, or other css value (px/rem))
 * @property {string} [account] Brightcove only - Account ID
 * @property {string} [player=default] Brightcove only - player ID
 * @property {string} [embed=default] Brightcove only - embed value
 * @property {string} [videoId] Brightcove / YouTube - Video ID
 * @property {string} [iframeUrl] Brightcove / YouTube - can substitute a complete iframe src url instead of id values
 * @property {boolean} [disableFullScreen] disables full screen option (youtube / brightcove only)
 * @property {string} title Title of the Iframe
 */
class CoreIntcVideo extends LightningElement {
  /**
   * Used to delegate focus event from parent to child (coreIntcVideo)
   *
   * @type {boolean}
   * @private
   */
  static delegatesFocus = true;

  @api videoType = '';

  @api width = '100%';

  @api height = '100%';

  @api account = '';

  @api player = 'default';

  @api embed = 'default';

  @api videoId = '';

  @api iframeUrl = '';

  @api disableFullScreen;

  @api title = '';

  /**
   * track errors for developers
   *
   * @type {string}
   * @private
   */
  errors = '';

  /**
   * Connected callback. Determines if provided properties are correct and display error if otherwise.
   *
   * @private
   */
  connectedCallback() {
    // api properties validations
    const acceptedVideoTypes = ['brightcove', 'youtube'];
    let isError = false;
    if (!acceptedVideoTypes.includes(this.videoType)) {
      console.error(`${this.videoType || '[blank]'} is not an accepted video type`);
      isError = true;
    } else if (this.videoType === 'brightcove') {
      if (!this.iframeUrl || this.iframeUrl === '') {
        if (!this.account) {
          console.error('Missing account property');
          isError = true;
        }
        if (!this.videoId) {
          console.error('Missing video id');
          isError = true;
        }
      }
    }

    // On configuration error, display error message
    if (isError === true) {
      this.errors = videoError;
    }
  }

  /**
   * Brightcove iframe src
   *
   * @returns {string} src value
   * @private
   */
  get brightcoveIFrameSrc() {
    if (this.iframeUrl) {
      return this.iframeUrl;
    }

    const baseURL = `https://players.brightcove.net/${this.account}/${this.player}_${this.embed}/index.html`;
    const params = new URLSearchParams({
      videoId: this.videoId,
    });
    return `${baseURL}?${params}`;
  }

  /**
   * YouTube iframe src
   *
   * @returns {string} src value
   * @private
   */
  get youtubeIFrameSrc() {
    if (this.iframeUrl) {
      return this.iframeUrl;
    }

    const baseURL = `https://www.youtube.com/embed/${this.videoId}`;
    const params = new URLSearchParams({
      enablejsapi: 1,
      origin: window.location.origin,
    });
    return `${baseURL}?${params}`;
  }

  /**
   * Getter for allow parameter on iframe
   *
   * @returns {string} allow string
   * @private
   */
  get iframeAllow() {
    return this.disableFullScreen ? 'autoplay; encrypted-media' : `autoplay; fullscreen; encrypted-media`;
  }

  /**
   * Getter for window OBJECT
   *
   * @returns {object} window object
   * @private
   */
  get win() {
    // Get a reference to the iframe element
    const iframeTag = this.template.querySelector('iframe');
    // Retrieve window object needed for postMessage
    return iframeTag.contentWindow;
  }

  /**
   * computed style
   *
   * @returns {string} computed style for iframe
   * @private
   */
  get computedStyle() {
    const width = `${this.width}`.match(/^\d*$/) ? `${this.width}px` : this.width;
    const height = `${this.height}`.match(/^\d*$/) ? `${this.height}px` : this.width;
    return `width: ${width}; height: ${height}`;
  }

  /**
   * boolean values of video type
   *
   * @returns {object} boolean values
   * @private
   */
  get videoTypes() {
    return {
      isBrightcove: this.videoType === 'brightcove',
      isYouTube: this.videoType === 'youtube',
    };
  }

  /**
   * rendered callback
   *
   * @private
   */
  renderedCallback() {
    if (this.videoTypes.isBrightcove) {
      const iframe = this.template.querySelector('iframe');
      const wrapper = this.template.querySelector('.video-container');
      if (iframe) {
        iframe.setAttribute('style', this.computedStyle);
      }
      if (wrapper) {
        wrapper.setAttribute('style', this.computedStyle);
      }
    }

    if (this.videoTypes.isYouTube) {
      const iframe = this.template.querySelector('iframe');
      const wrapper = this.template.querySelector('.video-container');
      if (iframe) {
        iframe.setAttribute('width', this.width);
        iframe.setAttribute('height', this.height);
      }
      if (wrapper) {
        wrapper.setAttribute('style', this.computedStyle);
      }
    }
  }

  /**
   * (Brightcove only)
   * Play video. Custom plugin is required on Brightcove to handle message.
   *
   * @public
   */
  @api
  playVideo() {
    // eslint-disable-next-line no-restricted-globals
    const theURL = `${location.protocol}//players.brightcove.net`;
    // Post message passing 'playVideo' as the data
    this.win.postMessage('playVideo', theURL);
  }

  /**
   * (Brightcove only)
   * Pause video. Custom plugin is required on Brightcove to handle message.
   *
   * @public
   */
  @api
  pauseVideo() {
    // eslint-disable-next-line no-restricted-globals
    const theURL = `${location.protocol}//players.brightcove.net`;
    // Post message passing 'pauseVideo' as the data
    this.win.postMessage('pauseVideo', theURL);
  }
}
export default CoreIntcVideo;