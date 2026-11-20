import { api, LightningElement } from 'lwc';

import loadingLabel from '@salesforce/label/c.Core_Intc_Loading';
import indicatorAssistiveLabel from '@salesforce/label/c.Core_Intc_Carousel_Indicators';
import jumpEndLabel from '@salesforce/label/c.Core_Intc_Carousel_Jump_End';
import jumpBeginLabel from '@salesforce/label/c.Core_Intc_Carousel_Jump_Begin';
import previousPaddleLabel from '@salesforce/label/c.Core_Intc_Navigate_Previous';
import nextPaddleLabel from '@salesforce/label/c.Core_Intc_Navigate_Next';


/**
 * @typedef Indicator
 * @property {string} src Url of the image
 * @property {string} type Type of the indicator, currently supported (image, video)
 */

/**
 * Displays a series of content items as slides in a carousel.
 *
 * ### Slots:
 * * The "content" slot is mandatory. It is placed around the different content items that will be displayed in the carousel.
 * * The "footer-left" slot is optional. It is placed around content to be displayed to the left of the indicator images.
 * * The "footer-right" slot is optional. It is placed around content to be displayed to the right of the indicator images.
 *
 * ### Content Items:
 * * Content items are custom content and are defined within the carousel itself. They are designated by including the
 * <code>data-carousel-item</code> attribute with an associated index (see HTML examples below).
 *
 * ### Setting the Height:
 * * The height of the carousel is calculated dynamically based on the height of the tallest content item. This is done
 *  so that the carousel has a consistent height.
 * * The height of each content item should be relatively similar to minimize the amount of whitespace displayed.
 * * The height needs to be updated by calling the <code>resetHeight</code> method after all the content items are rendered.
 *  This becomes complicated when the content items include images because you do not want to call the resetHeight function
 *  until the images have been rendered. Approaches for dealing with this include using img onload methods, and/or a
 *  timeout. Please see the JavaScript component example 1 below.
 *
 * ### CSS Variables
 * | Name | Default | Description |
 * | ---- | ------- | ----------- |
 * | intc-carousel-bgcolor | white | Background color for images. |
 * | intc-carousel-indicator-bgcolor | white | Background color for indicator images. |
 * | intc-carousel-indicator-height | 2.25rem | Height of the indicator images. |
 * | intc-carousel-indicator-width | 4rem | Width of the indicator images. |
 *
 * ### Notes:
 * * It's recommended you don't use <code>indicatorImages</code> if <code>itemsPerPageMobile</code>, <code>itemsPerPageTablet</code>, and
 *  <code>itemsPerPageDesktop</code> are different since the indicator images will not match the slide content.
 * * Auto-scroll functionality is not supported due to challenges with accessibility.
 *
 * <div id="core-examples" sf-attr="c-coreintccarousel_coreintccarousel">
 *  <demo-core-intc-carousel show1="true"></demo-core-intc-carousel>
 *  <demo-core-intc-carousel show2="true"></demo-core-intc-carousel>
 * </div>
 *
 * @example
 * // JavaScript component example 1
 * export default class DemoCoreIntcCarousel extends LightningElement {
 *   // JavaScript component example 1 - using inidcatorImages
 *   images1 = ['Sindrax1.png', 'Sindrax2.png', 'Sindrax3.png', 'Sindrax4.png'];
 *
 *   // Tracks how many of the images have been loaded
 *   loadCount = 0;
 *
 *   // Called whenever an image is loaded
 *   imageLoad() {
 *     this.loadCount += 1;
 *     // Check if all four images are loaded
 *     if (this.loadCount === 4) {
 *       // Yes so add an additional 100ms for rendering
 *       // eslint-disable-next-line @lwc/lwc/no-async-operation
 *       setTimeout(() => {
 *         // Grab the carousel component in order to call resetHeight
 *         this.template.querySelector('c-core-intc-carousel').resetHeight();
 *       }, 100);
 *     }
 *   }
 * }
 *
 * @example
 * <!-- HTML component example 1 -->
 * <c-core-intc-carousel name="demo carousel 1" indicator-images={images1} with-paddles>
 *  <div slot="content">
 *    <div data-carousel-item="0">
 *      Content 1
 *      <img src="Sindrax1.png" alt="Sindrax 1" onload={imageLoad}>
 *    </div>
 *    <div data-carousel-item="1">
 *      Content 2
 *      <img src="Sindrax2.png" alt="Sindrax 2" onload={imageLoad}>
 *    </div>
 *    <div data-carousel-item="2">
 *      Content 3
 *      <img src="Sindrax3.png" alt="Sindrax 3" onload={imageLoad}>
 *    </div>
 *    <div data-carousel-item="3">
 *      Content 4
 *      <img src="Sindrax4.png" alt="Sindrax 4" onload={imageLoad}>
 *    </div>
 *  </div>
 * </c-core-intc-carousel>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <c-core-intc-carousel name="demo carousel 2" with-paddles items-per-page-desktop="2" item-gutter="5rem" show-edge-overlap-tablet transition-speed="1000">
 *  <div slot="content">
 *    <div data-carousel-item="0">
 *      Content 1
 *      <img src="Sindrax1.png" alt="Sindrax 1">
 *    </div>
 *    <div data-carousel-item="1">
 *      Content 2
 *      <img src="Sindrax2.png" alt="Sindrax 2">
 *    </div>
 *    <div data-carousel-item="2">
 *      Content 3
 *      <img src="Sindrax3.png" alt="Sindrax 3">
 *    </div>
 *    <div data-carousel-item="3">
 *      Content 4
 *      <img src="Sindrax4.png" alt="Sindrax 4">
 *    </div>
 *  </div>
 *  <div slot="footer-left">Left Footer Content</div>
 *  <div slot="footer-right">Right Footer Content</div>
 * </c-core-intc-carousel>
 *
 *
 * @property {string} [carouselType=indicator] Display style for the carousel.  Currently, 'indicator' is the only option.
 * @property {Indicator[]|string[]} [indicatorImages=[]] An array of {@link Indicator} objects or list of string urls
 * @property {string} [itemGutter=1rem] The margin between carousel items when displaying more than one item on a slide.
 * @property {number} [itemsPerPage=1] The number of carousel items to display on each slide. <code>itemsPerPageDesktop</code>,
 * <code>itemsPerPageMobile</code>, and <code>itemsPerPageTablet</code> override this value if they are set.
 * @property {number} [itemsPerPageDesktop] The number of carousel items to display on each slide when the screen size is greater than 1023px.
 * Defaults to <code>itemsPerPage</code>.
 * @property {number} [itemsPerPageMobile] The number of carousel items to display on each slide when the screen size is between 768px and 1023px.
 * Defaults to <code>itemsPerPage</code>.
 * @property {number} [itemsPerPageTablet] The number of carousel items to display on each slide when the screen size is less than 768px.
 * Defaults to <code>itemsPerPage</code>.
 * @property {string} name A unique name to be used as the carousel's ID. Required for accessiblity.
 * @property {boolean} [showEdgeOverlapMobile] Indicates if an edge overlap of the prev/next slides should be included when the screen size is less
 * than 768px. Makes device swipes easier.
 * @property {boolean} [showEdgeOverlapTablet] Indicates if an edge overlap of the prev/next slides should be included when the screen size is between
 * 768px and 1023px. Makes device swipes easier.
 * @property {number} [transitionSpeed=350] The transition speed between slides (in milliseconds).
 * @property {boolean} [withPaddles] Indicates if arrow paddles <- -> should be shown on the left and right.
 * @property {string} [variant] Applies variant styling to the carousel. Current supported variant is 'banner', 'gallery'.
 * @property {string[]} [indicatorAssistiveText=[]] Assistive text for the indicators (defaults to 'Page #').
 * @property {boolean} [isModal] Indicates if the carousel exists on the modal
 * @augments LightningElement
 */
class CoreIntcCarousel extends LightningElement {
  /** label for alternative text for loading spinner
   *
   * @type {string}
   * @private
   */
  loadingPage = loadingLabel;

  /**
   * Label for default assistive text for carousel indicators
   *
   * @type {string}
   * @private
   */
  indicatorLabel = indicatorAssistiveLabel;

  /**
   * Label for button to jump to beginning of carousel
   *
   * @type {string}
   * @private
   */
  jumpBeginText = jumpBeginLabel;

  /**
   * Label for button to jump to end of carousel
   *
   * @type {string}
   * @private
   */
  jumpEndText = jumpEndLabel;

  /**
   * Labbel for previous paddle
   *
   * @type {string}
   * @private
   */
  previousPaddleText = previousPaddleLabel;

  /**
   * Label for next paddle
   *
   * @type {string}
   * @private
   */
  nextPaddleText = nextPaddleLabel;

  /**
   * @typedef MobileTouchSettings
   * @property {number} [allowedTime=800] maximum time allowed to travel that distance (ms)
   * @property {number} [threshold=100] required min distance traveled to be considered swipe (px)
   * @property {number} [restraint=100] maximum distance allowed at the same time in perpendicular direction
   */

  /** settings for swipe functionality
   *
   * @type {MobileTouchSettings}
   * @private
   */
  TOUCH_SETTINGS = {
    allowedTime: 800,
    threshold: 100,
    restraint: 100,
  };

  // Api Variables
  @api name;

  @api indicatorImages = [];

  @api itemsPerPage = 1;

  @api itemsPerPageMobile;

  @api itemsPerPageTablet;

  @api itemsPerPageDesktop;

  @api itemGutter = '1rem';

  @api showEdgeOverlapMobile;

  @api showEdgeOverlapTablet;

  @api carouselType = 'indicator';

  @api transitionSpeed = 350;

  @api withPaddles;

  @api variant;

  @api indicatorAssistiveText = [];

  @api isModal;

  /** show loading page spinner
   *
   * @type {boolean}
   * @private
   */
  loadingPageSpinner;

  /** current page of carousel
   *
   * @type {number}
   * @private
   */
  currentPage = 1;

  /** page count (total pages of carousel)
   *
   * @type {number}
   * @private
   */
  pageCount = 1;

  /**
   * @typedef Breakpoint
   * @property {boolean} isMobile true if on mobile device
   * @property {boolean} isTablet true if on tablet device
   * @property {boolean} isDesktop true if on desktop
   */

  /**
   * current breakpoint - tracked from redux
   *
   * @type {Breakpoint}
   * @private
   */
  breakpoint = {};

  /**
   * If true, hide paddle on the right side of indicator carousel
   *
   * @type {boolean}
   * @private
   */
  hideRightIndicatorPaddles = true;

  /**
   * If true, hide paddle on the left side of indicator carousel
   *
   * @type {boolean}
   * @private
   */
  hideLeftIndicatorPaddles = true;

  /**
   * Index of the first indicator that is visible on rendered screen
   *
   * @type {number}
   * @private
   */
  _indicatorIndex = 0;

  /**
   * Indicates whether carousel is gallery variant
   *
   * @type {boolean}
   * @private
   */
  isGallery = false;

  /**
   * The CSS class to use for the left footer.
   *
   * @type {string}
   * @private
   */
  leftFooterClass = 'slds-hide';

  /**
   * Indicates if the left footer has content.
   *
   * @type {boolean}
   * @private
   */
  leftFooterContent = false;

  /**
   * The CSS class to use for the right footer.
   *
   * @type {string}
   * @private
   */
  rightFooterClass = 'slds-hide';

  /**
   * Indicates if the right footer has content.
   *
   * @type {boolean}
   * @private
   */
  rightFooterContent = false;

  /**
   * Indicates if the jump links should be displayed
   *
   * @type {boolean}
   * @private
   */
  showJumps = true;



  /**
   * connected callback function
   *
   * adds screen size handler (to reset UI on resize)
   * subscribes to redux breakpoint to adjust items per page
   *
   * @private
   */
  connectedCallback() {
    this.isGallery = this.variant === 'gallery';
    this.loadingPageSpinner = true;
    if (!this.name) {
      throw new Error('A carousel name is required for accessibility.');
    }
    this._addScreenSizeHandler();
  }

  /**
   * handle screen change thru breakpoints
   *
   * @param {event} evt screen change event
   * @private
   */
  handleScreenChange(evt) {
    const startItemIndex = (this.currentPage - 1) * this.itemsPerPageValue;
    this.breakpoint = evt.detail.screen;
    const newPage = Math.floor(startItemIndex / this.itemsPerPageValue) + 1;
    if (newPage !== this.currentPage) {
      this.changePage(newPage);
    }
  }

  /**
   * disconnected callback function
   * removes screen size handler on component disconnect
   *
   * @private
   */
  disconnectedCallback() {
    this._removeScreenSizeHandler();
  }

  /**
   * rendered callback function
   * Ensures UI is reset on each render
   * needs access to DOM Elements which is why it is done here
   *
   * @private
   */
  renderedCallback() {
    this.resetUI();
  }

  /**
   * Resets UI - slide horizontal location
   *
   * @private
   */
  resetUI() {
    // reset page count ( and avoid infinite loop )
    if (this.pageCount !== this.pageCountValue) {
      this.pageCount = this.pageCountValue;
      return;
    }

    this.items.forEach((item, idx) => {
      /* eslint-disable no-param-reassign */
      item.indexValue = idx;
      item.style.flex = `0 0 ${this.itemWidth}`;
      item.style.margin = `0 ${this.itemGutter}`;
      item.style.maxWidth = this.itemWidth;
      if (this.isModal) {
        item.style.visibility = idx === this.currentPage - 1 ? 'visible' : 'hidden';
      }
      /* eslint-enable no-param-reassign */
    });

    if (this.isModal || this.items.length <= 1) {
      this.showJumps = false;
    } else {
      this.showJumps = true;
    }

    const contentContainer = this.template.querySelector(
      '.carousel-content-container',
    );
    contentContainer.style.marginLeft = `calc(-${this.itemGutter} + (${this.edgesOverlapValue} / 2))`;
    contentContainer.style.transition = `left ${this.transitionSpeed}ms ease`;

    if (!this.isGallery) {
      const focusedIndicator = this.template.querySelector(
        'li.carousel-indicator a:focus',
      );
      if (focusedIndicator) {
        const indicatorPage = parseInt(focusedIndicator.dataset.index, 10) + 1;
        if (indicatorPage !== this.currentPage) {
          const selector = `li.carousel-indicator:nth-child(${this.currentPage}) a`;
          this.template.querySelector(selector).focus();
        }
      }
    }
    this.resetHeight();
    if (this.isGallery) {
      this.checkOverflow();
    }
  }

  /**
   * Resets the height of the carousel dynamically based on the height of the tallest content item.
   * If the height is 0, it is assumed the content is hidden (ie. in a collapsed modal).
   *
   * @public
   */
  @api resetHeight() {
    const contentContainer = this.template.querySelector(
      '.carousel-content-container',
    );
    const mainContainer = this.template.querySelector('.carousel-container');
    if (contentContainer.scrollHeight) {
      mainContainer.style.height = `${contentContainer.scrollHeight}px`;
    }
  }

  /**
   * these are the items of the carousel
   *
   * @returns {object[]} all carousel items
   * @private
   */
  get items() {
    return this.querySelectorAll('[data-carousel-item]');
  }

  /**
   * returns the value for number of items per page
   *
   * @returns {number} items per page
   * @private
   */
  get itemsPerPageValue() {
    if (this.breakpoint.isMobile) {
      return this.itemsPerPageMobile || this.itemsPerPage;
    }
    if (this.breakpoint.isTablet) {
      return this.itemsPerPageTablet || this.itemsPerPage;
    }
    if (this.breakpoint.isDesktop) {
      return this.itemsPerPageDesktop || this.itemsPerPage;
    }
    return this.itemsPerPage;
  }

  /**
   * item width (css value)
   *
   * @returns {string} css for item width
   * @private
   */
  get itemWidth() {
    const percent = Math.round(1000000 / this.itemsPerPageValue) / 10000;
    let gutters = ((this.itemsPerPageValue - 1) * 2) / this.itemsPerPageValue;
    gutters = Math.round(gutters * 10000) / 10000;
    return `calc(${percent}% - (${this.itemGutter} * ${gutters}) - (${this.edgesOverlapValue} / ${this.itemsPerPageValue}))`;
  }

  /**
   * edge overlap (css value)
   *
   * @returns {string} css for edge overlap
   * @private
   */
  get edgesOverlapValue() {
    if (this.breakpoint.isMobile && this.showEdgeOverlapMobile) {
      return '30%';
    }
    if (this.breakpoint.isTablet && this.showEdgeOverlapTablet) {
      return '30%';
    }
    return '0px';
  }

  /**
   * page count
   *
   * @returns {number} page count
   * @private
   */
  get pageCountValue() {
    return Math.ceil(this.items.length / this.itemsPerPageValue);
  }

  /**
   * indicators are the dots (or images) at the bottom of the carousel
   * this function formats the indicators for all html and other properties
   *
   * @returns {object[]} indicators
   * @private
   */
  get indicators() {
    const indicators = [];
    while (indicators.length < this.pageCount) {
      const page = indicators.length + 1;
      const active = String(this.currentPage) === String(page);
      const isIndicatorString = typeof this.indicatorImages[page - 1] === 'string' || !this.indicatorImages[page - 1];
      indicators.push({
        page,
        key: `carousel-page-${page}`,
        class: `carousel-indicator-action ${
          active ? 'carousel-is-active' : ''
        }`,
        ariaSelected: active,
        ariaControls: this.name,
        title: '',
        assistiveText: this.indicatorAssistiveText[page - 1] || this.indicatorLabel.replace('{0}', page),
        imageUrl: isIndicatorString
          ? this.indicatorImages[page - 1] : this.indicatorImages[page - 1].src,
        isMedia: isIndicatorString
          ? this.indicatorImages.length > 0
          : this.indicatorImages[page - 1].type === 'image' || this.indicatorImages[page - 1].type === 'video',
        isVideo: isIndicatorString
          ? false : this.indicatorImages[page - 1].type === 'video',
      });
    }
    return indicators;
  }

  /**
   * hides indicators if only one page
   *
   * @returns {boolean} hide value
   * @private
   */
  get hideIndicators() {
    return this.indicators.length < 2;
  }

  /**
   * Get style classes for right indicator.
   * Hides indicator if property is set to true
   *
   * @returns {string} style classes
   * @private
   */
  get rightIndicatorPaddleClasses() {
    return [
      'indicator-paddle-wrapper',
      'paddle-right',
      (this.hideRightIndicatorPaddles ? 'hidden' : ' '),
    ].join(' ');
  }

  /**
   * Get style classes for left indicator.
   * Hides indicator if property is set to true
   *
   * @returns {string} style classes
   * @private
   */
  get leftIndicatorPaddleClasses() {
    return [
      'indicator-paddle-wrapper',
      'paddle-left',
      (this.hideLeftIndicatorPaddles ? 'hidden' : ' '),
    ].join(' ');
  }

  /**
   * Get maximum number of indicators that can be rendered in current screen size
   *
   * @returns {number} Maximum number of carousels indicators
   * @private
   */
  get maxRenderedIndicators() {
    const indicatorsDiv = this.template.querySelector('.carousel-indicators-container');
    const indicators = this.template.querySelectorAll('.carousel-indicator');
    // Obtain maximum number of indicators that can be rendered without overflowing
    if (indicatorsDiv && indicators.length > 0) {
      return Math.floor(indicatorsDiv.clientWidth / indicators[0].clientWidth);
    }
    return 0;
  }

  /**
   * Setter for indicator index
   * Sets indicator index and checks if indicator paddle should be visible
   *
   * @private
   */
  set indicatorIndex(newIndex) {
    this._indicatorIndex = newIndex;
    this.hideIndicatorPaddlesIfOverflow();
  }

  /**
   * Getter for indicatorIndex
   *
   * @returns {number} index of the indicator
   * @private
   */
  get indicatorIndex() {
    return this._indicatorIndex;
  }

  /**
   * Getter for paddleTabIndex
   *
   * @returns {string} 0 if carousel is on modal, -1 otherwise
   * @private
   */
  get paddleTabIndex() {
    return this.isModal ? '0' : '-1';
  }

  /**
   * Hides indicator paddles based on overflow
   *
   * @private
   */
  hideIndicatorPaddlesIfOverflow() {
    if (this._indicatorIndex > 0) {
      this.hideLeftIndicatorPaddles = false;
    } else {
      this.hideLeftIndicatorPaddles = true;
    }
    const remainingIndicators = this.pageCount - (this.maxRenderedIndicators + this._indicatorIndex);
    if (remainingIndicators > 0) {
      this.hideRightIndicatorPaddles = false;
    } else {
      this.hideRightIndicatorPaddles = true;
    }
  }

  /**
   * change page function
   *
   * Changes the carousel page
   * (without transition is used for infinite carouseling.. not implemented)
   *
   * @param {number} newPageValue the new page value
   * @param {boolean} notransition change page w/o transition
   * @param {boolean} noDispatchEvent if true, does not dispatch any event after operation
   * @private
   */
  changePage(newPageValue, notransition, noDispatchEvent) {
    const contentContainer = this.template.querySelector(
      '.carousel-content-container',
    );
    this.currentPage = parseInt(newPageValue, 10);
    const { transition } = contentContainer.style;
    if (notransition) {
      contentContainer.style.transition = 'none';
    }

    // Reset back to zero in case browser has autoscrolled the element into focus
    const carouselContainer = this.template.querySelector('.carousel-container');
    carouselContainer.scrollLeft = 0;

    // Shift the content container to start at the appropriate item
    contentContainer.style.left = `calc((-100% - (${this.itemGutter} * 2) + ${
      this.edgesOverlapValue
    }) * ${this.currentPage - 1})`;
    if (notransition) {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        contentContainer.style.transition = transition;
      }, 10);
    }
    if (!noDispatchEvent) {
      this.dispatchEvent(
        new CustomEvent('pagechange', { detail: { page: this.currentPage, isModal: this.isModal } }),
      );
    }
  }

  /**
   * changes page by direction (left or right)
   * used as a short hand for accessiblity, then calls changePage
   *
   * @param {string} dir direction ('left' or 'right')
   * @private
   */
  changePageByDirection(dir) {
    const delta = dir === 'left' ? -1 : 1;
    let newPage = this.currentPage + delta;
    if (newPage < 1) {
      newPage = this.pageCount;
    }
    if (newPage > this.pageCount) {
      newPage = 1;
    }
    this.changePage(newPage);
  }

  /**
   * handles page change event
   *
   * @param {event} evt event object
   * @private
   */
  handleChangePage(evt) {
    this.changePage(evt.currentTarget.dataset.page);
    this.dispatchEvent(new CustomEvent('indicatorclick'));
  }

  /**
   * handles paddle click event
   *
   * @param {event} evt event object
   * @private
   */
  handlePaddleClick(evt) {
    this.changePageByDirection(evt.currentTarget.dataset.direction);
    if (this.isGallery) {
      if (this.currentPage - 1 < this._indicatorIndex || this.currentPage - 1 >= this._indicatorIndex + this.maxRenderedIndicators) {
        this.changeIndicatorByDirection(evt.currentTarget.dataset.direction);
      }
      this.dispatchEvent(new CustomEvent('paddleclick'));
    }
    evt.preventDefault();
  }

  /**
   * handles touch start (mobile device)
   *
   * @param {event} evt event object
   * @private
   */
  handleTouchStart(evt) {
    const touchobj = evt.changedTouches[0];
    const swipedir = 'none';
    const startX = touchobj.pageX;
    const startY = touchobj.pageY;
    // record time when finger first makes contact with surface
    const startTime = Date.now();
    this._touchData = {
      swipedir,
      startX,
      startY,
      startTime,
    };
  }

  /**
   * handles touch end (mobile device)
   *
   * @param {event} evt event object
   * @private
   */
  handleTouchEnd(evt) {
    const touchobj = evt.changedTouches[0];
    // get horizontal dist traveled by finger while in contact with surface
    const distX = touchobj.pageX - this._touchData.startX;
    // get vertical dist traveled by finger while in contact with surface
    const distY = touchobj.pageY - this._touchData.startY;
    // get time elapsed
    const elapsedTime = Date.now() - this._touchData.startTime;

    // first condition for awipe met
    if (elapsedTime <= this.TOUCH_SETTINGS.allowedTime) {
      const { threshold, restraint } = this.TOUCH_SETTINGS;
      // 2nd condition for horizontal swipe met
      if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint) {
        // if dist traveled is negative, it indicates left swipe
        const swipedir = distX < 0 ? 'left' : 'right';
        // Page Logic
        if (swipedir === 'left' && this.currentPage < this.pageCount) {
          this.changePage(this.currentPage + 1);
        } else if (swipedir === 'right' && this.currentPage > 1) {
          this.changePage(this.currentPage - 1);
        }
      }
    }
  }

  /**
   * handles slot change
   *
   * @param {event} evt event object
   * @private
   */
  handleSlotChange(evt) {
    const nodes = evt.target.assignedNodes();
    // ensure wrapper is flex if it exists
    nodes.forEach((node) => {
      // eslint-disable-next-line no-param-reassign
      node.style.display = 'flex';
    });
    this.loadingPageSpinner = false;
  }



  /**
   * Updates the variables that track whether there is footer slot content and then
   * updates the footer class variables.
   *
   * @param {object} evt  The standard DOM slotChange event.
   * @private
   */
  handleFooterSlotChange(evt) {
    let hasContent = false;
    const slotNodes = evt.target.assignedNodes({ flatten: true });
    const slotNodesLength = slotNodes.length;

    // Check for anything other than an empty slot
    for (let count = 0; count < slotNodesLength; count += 1) {
      if (slotNodes[count].tagName !== 'SLOT') {
        hasContent = true;
        break;
      }
    }

    // Update the footer content variable
    const [, side] = evt.target.name.split('-');
    this[`${side}FooterContent`] = hasContent;

    // Update the footer class variables based on whether there is any footer content
    if (this.leftFooterContent || this.rightFooterContent) {
      this.leftFooterClass = 'footer-content-left';
      this.rightFooterClass = 'footer-content-right';
    } else {
      this.leftFooterClass = 'slds-hide';
      this.rightFooterClass = 'slds-hide';
    }
  }



  /**
   * handles key down (Accessibility)
   *
   * @param {event} evt event object
   * @private
   */
  handleKeydown(evt) {
    if (evt.key === 'Tab') {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        const focusedItem = this.querySelector(
          '[data-carousel-item]:focus-within',
        );
        if (focusedItem) {
          const page = Math.floor(parseInt(focusedItem.indexValue, 10) / this.itemsPerPageValue) + 1;
          if (page !== this.currentPage) {
            this.changePage(page, page > this.currentPage);
          }
        }
      }, 20);

      // Don't want the tab event to get propagated to the gallery parent
      if (evt.target.classList.contains('carousel-indicator-action')
      && !(evt.target.parentElement === evt.target.parentElement.parentElement.firstElementChild && evt.shiftKey)) {
        evt.stopPropagation();
      }
    }
    if (evt.key === 'ArrowLeft') {
      if (this.isGallery) {
        const newPage = this.currentPage - 1;
        if (newPage === this._indicatorIndex) {
          this.changeIndicatorByDirection('left');
        } else {
          const neededIndex = this.getIndicatorIndex(newPage);
          if (this._indicatorIndex !== neededIndex) {
            this.scrollIndicator(neededIndex);
          }
        }
      }
      this.changePageByDirection('left');
      evt.preventDefault();
    }
    if (evt.key === 'ArrowRight') {
      if (this.isGallery) {
        if (this.currentPage === this.pageCount || this.currentPage === this._indicatorIndex + this.maxRenderedIndicators) {
          this.changeIndicatorByDirection('right');
        } else {
          const newPage = this.currentPage + 1;
          const neededIndex = this.getIndicatorIndex(newPage);
          if (this._indicatorIndex !== neededIndex) {
            this.scrollIndicator(neededIndex);
          }
        }
      }
      this.changePageByDirection('right');
      evt.preventDefault();
    }
  }



  /**
   * Handles an indicator receiving focus.
   *
   * @param {object} evt The focus event.
   * @private
   */
  handleIndicatorFocus(evt) {
    const focusedIndicator = parseInt(evt.target.getAttribute('data-index'), 10);
    const indicatorDiv = this.template.querySelector('.carousel-indicators');
    // Only need to scroll indicators if they are not all displayed
    if (indicatorDiv.scrollWidth > indicatorDiv.clientWidth) {
      const neededIndex = this.getIndicatorIndex(focusedIndicator + 1);
      this.scrollIndicator(neededIndex);
    }
  }



  /**
   * handles onclick event on indicator paddle
   *
   * @param {object} event Associated event object
   */
  handleIndicatorPaddleClick(event) {
    this.changeIndicatorByDirection(event.currentTarget.dataset.direction);
  }

  /**
   * adds screen size handler
   *
   * @private
   */
  _addScreenSizeHandler() {
    this.screenSizeListener = () => {
      if (this._debounceResize) {
        clearTimeout(this._debounceResize);
      }
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this._debounceResize = setTimeout(() => {
        this.resetHeight();
        if (this.isGallery) {
          this.checkOverflow();
        }
        this._debounceResize = false;
      }, 150);
    };
    window.addEventListener('resize', this.screenSizeListener);
  }

  /**
   * removes screen size handler
   *
   * @private
   */
  _removeScreenSizeHandler() {
    window.removeEventListener('resize', this.screenSizeListener);
  }

  /**
   * Checks if indicators are overflowing
   * Show indicator paddles if indicators are overflowing
   *
   * @private
   */
  checkOverflow() {
    const indicatorDiv = this.template.querySelector('.carousel-indicators');
    if (indicatorDiv.scrollWidth > indicatorDiv.clientWidth && this._indicatorIndex === 0) {
      this.hideRightIndicatorPaddles = false;
    }
    this.hideIndicatorPaddlesIfOverflow();
  }

  /**
   * Change indicator based on the provided direction
   *
   * @param {string} direction Direction to translate the indicator to
   * @private
   */
  changeIndicatorByDirection(direction) {
    let addIndex = 0;
    if (direction === 'right') {
      const remainingIndicators = this.pageCount - (this.maxRenderedIndicators + this.indicatorIndex);
      if (remainingIndicators <= 0) {
        addIndex = this.indicatorIndex * -1;
      } else {
        addIndex = this.maxRenderedIndicators;
      }
    } else if (direction === 'left') {
      if (this.indicatorIndex === 0) {
        addIndex = this.getIndicatorIndex(this.pageCount);
      } else {
        addIndex = this.indicatorIndex > this.maxRenderedIndicators ? -1 * this.maxRenderedIndicators : -1 * this.indicatorIndex;
      }
    }

    this.scrollIndicator(this.indicatorIndex + addIndex);
  }



  /**
   * Calculates the first indicator to display (indicatorIndex) based on the given page number.
   *
   * @param {number} newPage The page that is to be displayed.
   * @returns {number} The first indicator to display based on the given page number.
   * @private
   */
  getIndicatorIndex(newPage) {
    let neededIndex = Math.floor(newPage / this.maxRenderedIndicators);
    if (newPage % this.maxRenderedIndicators === 0) {
      neededIndex -= 1;
    }
    neededIndex *= this.maxRenderedIndicators;
    return neededIndex;
  }



  /**
   * Scroll indicator to the specified index
   *
   * @param {number} idx Index of the indicator to scroll to
   */
  scrollIndicator(idx) {
    const indicators = this.template.querySelectorAll('.carousel-indicator');
    const indicatorsDiv = this.template.querySelector('.carousel-indicators');
    // Obtain maximum number of indicators that can be rendered without overflowing
    const translateAmt = (idx) * indicators[0].clientWidth;
    indicatorsDiv.style.transform = `translateX(-${translateAmt}px)`;
    this.indicatorIndex = idx;
  }

  /**
   * Set active page and indicators based on the provided index
   *
   * @param {number} idx Index of the page (1-indexed)
   * @public
   */
  @api
  setRenderedCarouselState(idx) {
    this.changePage(idx, true, true);
    if (idx - 1 < this._indicatorIndex) {
      this.changeIndicatorByDirection('left');
    } else if (idx - 1 >= this._indicatorIndex + this.maxRenderedIndicators) {
      this.changeIndicatorByDirection('right');
    }
  }

  /**
   * Accssibility - jump to beginning/end of carousel on click
   *
   * @param {object} event Associated event object
   * @private
   */
  jumpTo(event) {
    const { jumpTo } = event.target.dataset;
    this.template.querySelector(`.${jumpTo}`).scrollIntoView({ block: 'center' });
    this.template.querySelector(`.${jumpTo}`).focus();
  }
}
export default CoreIntcCarousel;