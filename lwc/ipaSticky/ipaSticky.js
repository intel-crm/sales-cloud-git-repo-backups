import { LightningElement, api } from 'lwc';

/**
 * Singleton - keeps track of all #connected sticky components
 * (to calculate the sum of multiple heights, for multiple stickies on the same page)
 *
 */
const registeredStickyComponents = {};

/**
 * There are 2 required slots
 * - "content" - this is the non sticky content
 * - "sticky" - this is the sticky content
 *
 * @augments LightningElement
 * @property {boolean} fullWidth full width (example: sticky header)
 * @property {string} [position=0] positioning a specific order with multiple sticky sections (ie. 1, 2, 3)
 * @property {string} [start=top] (top/bottom) when does the sticky content stick?
 * @property {boolean} [previewMode] allow a preview mode to disable sticky functionality
 */
class IpaSticky extends LightningElement {
  @api fullWidth;

  @api position = 0;

  @api start = 'top';

  @api previewMode;

  /**
   * tracks stuckness
   *
   * @type {boolean}
   * @public
   */
  stuck;

  /**
   * gets current height of sticky content (for other sticky components)
   *
   * @returns {number} calculated height
   */
  @api currentHeight() {
    return this.template.querySelector('.sticky-content').offsetHeight;
  }

  /**
   * connected callback
   *
   * @private
   */
  connectedCallback() {
    if (!this.previewMode) {
      window.addEventListener('scroll', this.handleScroll.bind(this));
    }
  }

  /**
   * rendered callback
   *
   * @private
   */
  renderedCallback() {
    if (!this._uid) {
      this._uid = Date.now();
      registeredStickyComponents[this.position] = {
        ...registeredStickyComponents[this.position],
        [this._uid]: this,
      };
    }
  }

  /**
   * disconnects observer
   *
   * @private
   */
  disconnectedCallback() {
    window.removeEventListener('scroll', this.handleScroll.bind(this));
    delete registeredStickyComponents[this.position][this._uid];
  }

  /**
   * handle scroll
   *
   * @private
   */
  handleScroll() {
    // calculates offset (if other stickies are present)
    const multipleStickyOffset = Object.keys(registeredStickyComponents).filter((pos) => parseInt(pos, 10) <= parseInt(this.position, 10))
      .reduce((offsetValue, nextPos) => offsetValue
        + Object.keys(registeredStickyComponents[nextPos])
          .reduce((total, uid) => {
            const isMyUid = parseInt(uid, 10) === this._uid;
            const comp = registeredStickyComponents[nextPos][uid];
            // add all stuck component heights (not self)
            const delta = comp.stuck && !isMyUid ? comp.currentHeight() : 0;
            return total + delta;
          }, 0),
      0);
    // stuck content takes over once page is scrolled to content
    // buffer is calculated based on scroll start value
    const mainContent = this.template.querySelector('.main-content');
    const stickyContent = this.template.querySelector('.sticky-content');
    let buffer = this.start === 'bottom' ? (mainContent.offsetHeight - stickyContent.offsetHeight) : 0;
    buffer -= 1; // for better ui
    const stuck = window.pageYOffset > (mainContent.offsetTop - multipleStickyOffset + buffer);
    stickyContent.setAttribute('data-stuck', stuck);
    if (stuck !== this.stuck) {
      if (stuck) {
        stickyContent.style.top = `${multipleStickyOffset}px`;
      }
      this.stuck = stuck;
    }
  }
}
export default IpaSticky;