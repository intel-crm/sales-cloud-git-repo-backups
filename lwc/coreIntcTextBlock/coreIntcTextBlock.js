import { LightningElement, api } from 'lwc';

import less from '@salesforce/label/c.Core_Intc_Show_Less';
import lessInfo from '@salesforce/label/c.Core_Intc_Show_Less_Info';
import more from '@salesforce/label/c.Core_Intc_Show_More';
import moreInfo from '@salesforce/label/c.Core_Intc_Show_More_Info';


/**
 * A Text Block component for displaying content in either a truncated state ("Less") or a full display state ("More").<br>
 *
 * There are three ways to set the content:
 * 1. Place the full content inside the core-intc-text-block tags.
 *     * This will result in the <code>size</code> property being used to determine how much of your content should be displayed in "Less" mode.
 *     * This content is placed in a standard <code>slot</code> so it renders normally.
 * 2. Set the <code>introSection</code> and <code>moreSection</code> properties.
 *     * This will result in the <code>introSection</code> being displayed in "Less" mode
 *       and the <code>moreSection</code> section being displayed in "More" mode.
 *     * The <a href="https://developer.salesforce.com/docs/component-library/bundle/lightning-formatted-rich-text/documentation"
 *        target="_blank" rel="noopener noreferrer">
 *       Lightning Formatted Rich Text</a> component is used to render this content.
 * 3. Place the content you want displayed in a truncated state inside a an 'intro' slot, and then place the full content underneath it.
 *
 * <div id="core-examples" sf-attr="c-coreintctextblock_coreintctextblock">
 *  <demo-core-intc-text-block show1="true"></demo-core-intc-text-block>
 *  <demo-core-intc-text-block show2="true"></demo-core-intc-text-block>
 *  <demo-core-intc-text-block show3="true"></demo-core-intc-text-block>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Content inside core-intc-text-block tags -->
 * <c-core-intc-text-block size="small">"Once upon a time there was a lot of text" repeated for demo purposes.</c-core-intc-text-block>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Content specified via the introSection and moreSection properties -->
 * <c-core-intc-text-block intro-section="Once upon a time..." more-section="Once upon a time there was a lot of text."></c-core-intc-text-block>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Content specified via the intro slot -->
 * <c-core-intc-text-block>
 *  <div slot="intro">Once upon a time...</div>
 *  Once upon a time there was a lot of text.
 * </c-core-intc-text-block>
 *
 * @augments LightningElement
 * @property {string} [buttonClasses=''] Additional CSS classes to add to the show more/less button.
 * @property {string} [describedBy=''] info on what text block contains for aria-describedby
 * @property {boolean} [expanded=false]  Indicates if the text block should be in "More" (true) or "Less" (false) mode by default.
 * @property {string} [introSection] The content to display in "Less" mode when not placing content inside the core-intc-text-block tags.
 * @property {string} [moreSection] The content to display in "More" mode when not placing content inside the core-intc-text-block tags.
 * @property {string} [noMoreLine=false] Indicates if the line to the left and right of the more/less button should be displayed.
 * @property {boolean} [scrollToTop=''] Controls scrolling behaviour with available variants 'text-block' (scrolls to top of text-block)
 * and 'custom' (dispatches a custom event and lets parent component handle scroll).
 * @property {string} [size=small]  The amount of content to be displayed in "Less" mode when content is placed inside the core-intc-text-block tags.
 * The max-height property is set in CSS so that content beyond the max-height is faded out. Available sizes are "x-small" (5rem), "small" (8rem),
 * "medium" (16rem), and "large" (24rem).
 * @property {string} [variant=''] different fade variants for different backgrounds. Supports lightGray and white.
 * @fires scrolltextblock scrollToTop is enabled with 'custom' variant and 'Show Less' is clicked
 */
class CoreIntcTextBlock extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api buttonClasses = '';

  @api describedBy = '';

  @api introSection = '';

  @api moreSection = '';

  @api noMoreLine = false;

  @api scrollToTop = '';

  @api size = 'small';

  @api variant = '';


  // ******* API getters and setters - defined in class properties *******
  /**
   * Returns the internal version of the expanded api property. See definition in class properties.
   *
   * @returns {boolean} The internal expanded property.
   * @private
   */
  @api get expanded() {
    return this._expanded;
  }


  /**
   * Sets the internal expanded property that controls whether the full text is displayed.
   *
   * @param {boolean} value  The value for expanded.
   * @private
   */
  set expanded(value) {
    this._expanded = value;
  }



  // ******* Class variables ********
  /**
   * tracks case where actual content is contained in block
   * so no need to show more/less
   *
   * @type {boolean}
   * @private
   */
  contained = false;


  /**
   * Internal version of the expanded api property. See definition in class properties.
   *
   * @type {boolean}
   * @private
   */
  _expanded = false;

  /**
   * Indicates if slot 'intro' is being used
   *
   * @type {boolean}
   * @private
   */
  isIntroSlot = false;

  /**
   * Indicates if default slot is being used
   *
   * @type {boolean}
   * @private
   */
  isDefaultSlot = false;

  /**
   * Returns the CSS classes to use for the show more/less button.
   *
   * @returns {string} CSS classes for the show more/less button.
   * @private
   */
  get fullButtonClasses() {
    let cssClasses = 'link-text link-no-underline text-block-button';
    if (!this.noMoreLine) {
      cssClasses += ' text-block-button-line';
    }
    cssClasses += ` ${this.buttonClasses}`;
    return cssClasses;
  }

  /**
   * Indicates if an 'intro' section has been set
   *
   * @returns {boolean} is intro section
   * @private
   */
  get isIntroSection() {
    return this.isIntroSlot || this.introSection;
  }

  /**
   * Determines if the more or less label should be displayed.
   *
   * @returns {string} label value
   * @private
   */
  get label() {
    return this.expanded ? less : more;
  }

  /**
   * Returns label for aria-describedby
   *
   * @returns {string} label
   * @private
   */
  get ariaLabel() {
    const showLess = this.describedBy ? lessInfo.replace('{0}', this.describedBy) : less;
    const showMore = this.describedBy ? moreInfo.replace('{0}', this.describedBy) : more;
    return this.expanded ? showLess : showMore;
  }


  /**
   * Toggles the up/down icon based on whether the content is in "Less" or "More" mode.
   *
   * @returns {string} icon name
   * @private
   */
  get iconName() {
    return this.expanded ? 'utility:chevronup' : 'utility:chevrondown';
  }


  /**
   * Determines if the introSection or moreSection content should be displayed.
   *
   * @returns {string} rich text value
   * @private
   */
  get specificFormattedText() {
    return this.expanded ? this.moreSection : this.introSection;
  }

  /**
   * Returns which slot should be displayed
   *
   * @returns {number} display slot
   * @private
   */
  get slotVisible() {
    return this.isIntroSlot && !this.expanded && !(this.size === 'full') ? 1 : 2;
  }


  // ******* Methods ********
  /**
   * Adds a resize event listener to ensure the correct height is set.
   *
   * @private
   */
  connectedCallback() {
    if (!this.introSection || !this.introSlot) {
      window.addEventListener('resize', this.resizeHandler.bind(this));
    }
  }


  /**
   * Removes the resize event listener added in connectedCallback.
   *
   * @private
   */
  disconnectedCallback() {
    window.removeEventListener('resize', this.resizeHandler.bind(this));
  }



  /**
   * rendered callback
   *
   * @private
   */
  renderedCallback() {
    this.checkIfContentIsContained();
  }


  /**
   * resize handler
   *
   * @private
   */
  resizeHandler() {
    this.debounce(() => this.checkIfContentIsContained(), 500)();
  }


  /**
   * debounce helper function
   *
   * @param {Function} callback callback function
   * @param {number} wait debounce wait time in ms
   * @returns {Function} debounced function
   * @private
   */
  debounce(callback, wait) {
    let timeout;
    return (...args) => {
      const context = this;
      clearTimeout(timeout);
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      timeout = setTimeout(() => callback.apply(context, args), wait);
    };
  }

  /**
   * see if "show/more" link is still necessary to show
   * (if content is contained it doesn't need it)
   *
   * @private
   */
  checkIfContentIsContained() {
    // check text inner height
    if (!this.introSection && !this.expanded && !this.isIntroSlot) {
      const content = this.template.querySelector('.text-block-content');
      if (content) {
        let { maxHeight } = getComputedStyle(content);
        maxHeight = Number(maxHeight.replace('px', ''));
        this.contained = content.clientHeight < maxHeight;
      }
    } else if (this.introSection && ((this.introSection === this.moreSection) || !this.moreSection)) {
      // if the intro section is the same as the more section (or no more section) no need to expand
      this.contained = true;
    } else if (this.isIntroSlot) {
      // no need to expand if content in intro slot and no content in default slot or if full content to be displayed
      this.contained = !this.isDefaultSlot || this.size === 'full';
    }
  }

  /**
   * Handles slot change
   *
   * @param {event} evt slot change event
   * @private
   */
  handleSlotChange(evt) {
    const nodes = evt.target.assignedNodes();
    if (evt.target.name === 'intro' && nodes.length) this.isIntroSlot = true;
    else this.isDefaultSlot = nodes.length;
  }

  /**
   * Helper for scrolling behaviour - either dispatches custom event 'scrolltextblock' or
   * scrolls to top of text block component
   *
   * @private
   */
  helperScroll() {
    if (this.scrollToTop === 'custom') {
      this.dispatchEvent(new CustomEvent('scrolltextblock'));
    } else if (this.scrollToTop === 'text-block') {
      const textblock = this.template.querySelector('.text-block-container');
      textblock.scrollIntoView({ behavior: 'smooth' });
    }
  }

  /**
   * Toggles between "Less" and "More" mode.
   *
   * @private
   */
  handleMoreClick() {
    if (this._expanded && this.scrollToTop) {
      this.helperScroll();
    }
    this._expanded = !this._expanded;
  }
}
export default CoreIntcTextBlock;