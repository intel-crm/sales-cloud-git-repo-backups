/* eslint-disable no-param-reassign */
import { LightningElement, track, api } from 'lwc';

/**
 * Displays a series of {@link CoreIntcTab} components.
 *
 * ### Notes:
 * * If more tabs are defined than can be displayed, scroll paddles are added to the left and right side
 *   of the tabs. However, the content of a tab will always expand to the full width of the content container.
 * * When mobile stacking is used, the tab heading will be rendered above its content.
 *
 * ### CSS Variables
 * | Name | Default | Description |
 * | ---- | ------- | ----------- |
 * | intc-tabs-active-bgcolor | transparent | Background color for the active tab. |
 * | intc-tabs-active-bottom-border-color | energy-blue | Bottom border color for the active tab. |
 * | intc-tabs-active-color | carbon-shade2 | Font color for the active tab. |
 * | intc-tabs-active-weight | 400 | Font weight for the active tab. |
 * | intc-tabs-bottom-border-color | carbon-tint2 | Bottom border color for the entire tabs component. |
 * | intc-tabs-hover-bottom-border-color | energy-blue | Bottom border color for a tab that the user is hovering over. |
 * | intc-tabs-inactive-color | classic-blue | Font color for inactive tabs. |
 * | intc-tabs-margin-bottom | lwc-spacingLarge | Bottom margin for the entire tabs component. |
 *
 * <div id="core-examples" sf-attr="c-coreintctabset_coreintctabset c-coreintctab_coreintctab">
 *   <demo-core-intc-tabset show1="true"></demo-core-intc-tabset>
 *   <demo-core-intc-tabset show2="true"></demo-core-intc-tabset>
 *   <demo-core-intc-tabset show3="true"></demo-core-intc-tabset>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- Default display -->
 * <c-core-intc-tabset name="demo1">
 *     <c-core-intc-tab heading="Tab 1">Tab 1 Content</c-core-intc-tab>
 *     <c-core-intc-tab heading="Tab 2">Tab 2 Content</c-core-intc-tab>
 * </c-core-intc-tabset>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- Set the selected tab and use mobile stacking -->
 * <c-core-intc-tabset name="demo2" initial-active-tab="2" stack-mobile="true">
 *     <c-core-intc-tab heading="Tab 1">Tab 1 Content</c-core-intc-tab>
 *     <c-core-intc-tab heading="Tab 2">Tab 2 Content</c-core-intc-tab>
 *     <c-core-intc-tab heading="Tab 3">Tab 3 Content</c-core-intc-tab>
 * </c-core-intc-tabset>
 *
 * @example
 * <!-- HTML component example 3 -->
 * <!-- Long tab names to demonstrate scrolling -->
 * <c-core-intc-tabset name="demo3">
 *   <c-core-intc-tab heading="Tab 1 with a longer name to demonstrate scrolling">Tab 1 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 2 with a longer name to demonstrate scrolling">Tab 2 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 3 with a longer name to demonstrate scrolling">Tab 3 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 4 with a longer name to demonstrate scrolling">Tab 4 Content</c-core-intc-tab>
 *   <c-core-intc-tab heading="Tab 5 with a longer name to demonstrate scrolling">Tab 5 Content</c-core-intc-tab>
 * </c-core-intc-tabset>
 *
 * @augments LightningElement
 * @property {string} name  Prefix used to identify tabs.
 * @property {number} [initialActiveTab=0] Index of the initially selected tab.
 * @property {boolean} [stackMobile=false] Indicates if tabs should be stacked and always visible on mobile.
 */
class CoreIntcTabset extends LightningElement {
    // ******* Constants *******
    NAV_ANIMATION_DURATION = 270;

    // ******* API variables - defined in class properties *******
    @api name;

    @api initialActiveTab;

    @api stackMobile;

    // ******* Track variables ********
    @track currentTab;

    @track tabs = [];

    offset = 0;

    /**
     * get the inner nav
     *
     * @private
     * @returns {object} html dom element
     */
    get innerNav() {
      return this.template.querySelector('.tabset-nav-inner');
    }

    /**
     * get the container width
     *
     * @private
     * @returns {number} client width of container
     */
    get containerWidth() {
      return this.template.querySelector('.tabset-nav').clientWidth;
    }

    /**
     * get the scroll width
     *
     * @private
     * @returns {number} scroll width of inner nav
     */
    get allTabNavWidth() {
      return this.innerNav.scrollWidth;
    }

    /**
     * recenters tabs on the active tab
     *
     * @private
     */
    recenterTabs() {
      if (this.allTabNavWidth > this.containerWidth) {
        const el = this.template.querySelector(`.tabset-nav-item[data-tab="${this.currentTab}"]`);
        if (this.innerNav && el) {
          const halfScreen = this.containerWidth / 2;
          let offset = -el.offsetLeft - (el.clientWidth / 2) + halfScreen;
          const isFirst = el.dataset.idx === 0;
          const isLast = el.dataset.idx === this.tabs.length - 1;
          if (isFirst || offset > 0) {
            offset = 0;
          }
          if (isLast || offset < -this.allTabNavWidth + this.containerWidth) {
            offset = -this.allTabNavWidth + this.containerWidth;
          }
          this.innerNav.style.transform = `translateX(${offset}px)`;
          this.offset = offset;
        }
      }
    }

    /**
     * connected callback
     *
     * @private
     */
    connectedCallback() {
      this.connected = true;
      if (!this.name) {
        throw new TypeError('A tabset name is required for accessibility.');
      }
      this.addScreenSizeHandler();
      this.resetPaddles();
    }

    /**
     * disconnected callback
     *
     * @private
     */
    disconnectedCallback() {
      this.connected = false;
      this.removeScreenSizeHandler();
    }

    /**
     * adjust Paddle visibility onrender (this will fire twice if paddle state changes, but not infinitely)
     *
     * @private
     */
    renderedCallback() {
      if (this.forceFocus) {
        this.forceFocus = false;
        const el = this.template.querySelector('.tabset-nav-item[data-is-active="true"]');
        if (el) {
          this.template.querySelector('.tabset-nav-item[data-is-active="true"]').focus();
        } else {
          // stack mobile todo? heading?
        }
      }
      // accessibility
      this.template.querySelectorAll('.tabset-nav-item').forEach((navItem, idx) => {
        navItem.setAttribute('id', `${this.tabs[idx].key}-nav`);
        navItem.setAttribute('aria-controls', this.tabs[idx].key);
      });
    }

    /**
     * adjust Paddle visibility onrender (this will fire twice if paddle state changes, but not infinitely)
     *
     * @private
     */
    handleSlotChange() {
      const allTabs = this.querySelectorAll('c-core-intc-tab') || [];
      this.tabs = [...allTabs].map((tab, idx) => ({
        el: tab,
        key: `tab-${idx}-${this.name}`,
        label: tab.heading,
        link: tab.link || `tab-${idx}-${this.name}`,
        isActive: this.initialActiveTab ? idx === this.initialActiveTab : idx === 0,
        tabIndex: idx === 0 ? 0 : -1,
      }));
      allTabs.forEach((tab, idx) => {
        if (this.stackMobile) {
          tab.stackMobile = true;
        }
        tab.ariaLabelledBy = `${this.tabs[idx].key}-nav`;
        tab.idValue = this.tabs[idx].key;
      });

      this.currentTab = this.initialActiveTab ? this.tabs[this.initialActiveTab].key : this.tabs[0].key;
      this.resetTabs();
      this._checkForPaddleStateOnRerender = true;
    }

    /**
     * handleChangeTab
     *
     * @param {event} evt tab change event from ipaTab
     *
     * @private
     */
    handleChangeTab(evt) {
      this.currentTab = evt.currentTarget.dataset.tab;
      const { idx, link } = evt.currentTarget.dataset;
      const label = evt.currentTarget.textContent;

      this.resetTabs();
      // update the url hash include the deep link
      window.history.pushState(null, null, `#${link}`);

      this.dispatchEvent(new CustomEvent('tabchange', {
        detail: {
          tab: this.currentTab, idx, link, label,
        },
      }));
    }

    /**
     * handleTabChangeAccessibility
     *
     * @param {event} evt tab change event (accessibility) from ipaTab
     *
     * @private
     */
    handleTabChangeAccessibility(evt) {
      if (evt.code === 'ArrowLeft' || evt.code === 'ArrowRight') {
        this.forceFocus = true;
        let idx = parseInt(evt.currentTarget.dataset.idx, 10) + (evt.code === 'ArrowLeft' ? -1 : 1);
        const { link, label } = this.tabs[idx];
        idx = (idx + this.tabs.length) % this.tabs.length;
        this.currentTab = this.tabs[idx].key;
        this.resetTabs();
        // update the url hash include the deep link
        window.history.pushState(null, null, `#${link}`);
        this.dispatchEvent(new CustomEvent('tabchange', {
          detail: {
            tab: this.currentTab, idx, link, label,
          },
        }));
      }
    }

    /**
     * resetTabs
     *
     * @private
     */
    resetTabs() {
      this.tabs = this.tabs.map((tab) => {
        const isActive = this.currentTab === tab.key;
        // eslint-disable-next-line no-param-reassign
        tab.el.active = isActive;
        return { ...tab, isActive, tabIndex: isActive ? 0 : -1 };
      });
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.recenterTabs();
        this.resetPaddles();
      });
    }

    /**
     * handlePaddleClick
     *
     * @param {event} evt paddle click event
     *
     * @private
     */
    handlePaddleClick(evt) {
      const { direction } = evt.currentTarget.dataset;
      let { offset } = this;
      if (direction === 'next') {
        offset -= this.containerWidth;
        const maxOffset = -this.allTabNavWidth + this.containerWidth;
        if (offset < maxOffset) {
          offset = maxOffset;
        }
      } else {
        offset += this.containerWidth;
        if (offset > 0) {
          offset = 0;
        }
      }
      this.innerNav.style.transform = `translateX(${offset}px)`;
      this.offset = offset;
      this.resetPaddles();
    }

    /**
     * resetPaddles
     *
     * @private
     */
    resetPaddles() {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        let paddlePrevVisible = false;
        let paddleNextVisible = false;
        const { offset } = this;
        paddlePrevVisible = offset < 0;
        paddleNextVisible = (this.allTabNavWidth > this.containerWidth) && offset > (-this.allTabNavWidth + this.containerWidth);
        this.template.querySelector('.tabset-prev-paddle').classList.toggle('slds-hide', !paddlePrevVisible);
        this.template.querySelector('.tabset-next-paddle').classList.toggle('slds-hide', !paddleNextVisible);
      }, this.NAV_ANIMATION_DURATION);
    }

    /**
     * addScreenSizeHandler
     *
     * @private
     */
    addScreenSizeHandler() {
      this.screenSizeListener = () => {
        if (this._debounceResize) {
          clearTimeout(this._debounceResize);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._debounceResize = setTimeout(() => {
          if (this.innerNav) {
            this.recenterTabs();
            this.resetPaddles();
          }
          this._debounceResize = false;
        }, 80);
      };
      window.addEventListener('resize', this.screenSizeListener);
    }

    /**
     * removeScreenSizeHandler
     *
     * @private
     */
    removeScreenSizeHandler() {
      window.removeEventListener('resize', this.screenSizeListener);
    }
}
export default CoreIntcTabset;