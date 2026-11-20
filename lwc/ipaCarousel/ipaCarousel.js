/** Documentation for the Carousel Component
 * <br><br>This is a generic carousel used in the following components:
 * <ul><li>{@link ipaL0FeaturedOfferingTabs ipaL0FeaturedOfferingTabs}</li><li>{@link ipaPromoCarousel ipaPromoCarousel}</li><li>{@link ipaBannerCarousel ipaBannerCarousel}</ul>
 * <br>
 * <h2>Accessibility & Autoscroll</h2>
 * Extensive accessibility has been added to the carousel.
 * <br>Because of the challenges of accessibility with auto-scroll, its functionality has been disabled.
 * <br>To reimplement it it may require 'aria-live' and other accessibility controls with play/pause button.
 * <br>UI may also require "prescroll" content, or a way to ensure a smooth transition from last page to first page...
 * <h2>Usage</h2>
 * Each carousel slide must be wrapped in a {@link ipaCarouselItem ipaCarouselItem} component.
 * <br>
 * <br>
 * <i>NOTE: Touch Settings for swiping on mobile/tablet are in TOUCH_SETTINGS object</i>
 * @example
 * <c-ipa-carousel name="ImageCarousel"
 *     items-per-page-mobile="1"
 *     items-per-page-tablet="2"
 *     items-per-page-desktop="4">
 *     <div data-carousel-item="0">Image 1 ...</div>
 *     <div data-carousel-item="1">Image 2 ...</div>
 * </c-ipa-carousel>
 * @namespace ipaCarousel
 * @property {string} name unique name - <b>required</b> for accessiblity
 * @property {number} itemsPerPage=1 how many carousel items are on each slide
 * @property {number} itemsPerPageMobile how many carousel items are on each slide (Mobile)
 * @property {number} itemsPerPageTablet how many carousel items are on each slide (Tablet)
 * @property {number} itemsPerPageDesktop how many carousel items are on each slide (Desktop)
 * @property {string} itemGutter=1rem the margin between carousel items
 * @property {boolean} showEdgeOverlapMobile=false show edge overlap of prev/next slides (Mobile) <i>better UI for device swipe</i>
 * @property {boolean} showEdgeOverlapTablet=false show edge overlap of prev/next slides (Tablet) <i>better UI for device swipe</i>
 * @property {boolean} keepIndicatorSpacing=false keep indicator spacing and left/right slot content, even if only one page exists
 * @property {string} carouselType='indicator' style for carousel - only option currently is 'indicator'
 * @property {number} transitionSpeed=500 slide transition speed in ms
 * @property {number} autoScroll=0 <b>DISABLED</b> Time Interval for auto-scrolling carousel in ms (0 = disabled)
 *
 * @author Nick Demarest, last modified 29 July 2020
*/

/** @event pagechange
  * @type {CustomEvent}
  * @property {string} detail.page current page after change
  * @example
  * <c-ipa-carousel onpagechange={...}></c-ipa-carousel>
  * @memberof ipaCarousel
 */

import { LightningElement, api, track } from 'lwc';
import { getState, subscribe } from 'c/ipaRedux';

export default class IpaCarousel extends LightningElement {

    labels = {
        loadingPage: 'Loading...',
        playPause: 'Stop and start auto-scrolling carousel behavior'
    };

    TOUCH_SETTINGS = {
        allowedTime: 800, // maximum time allowed to travel that distance
        threshold: 100, //required min distance traveled to be considered swipe
        restraint: 100 // maximum distance allowed at the same time in perpendicular direction
    }

    @api name;

    @api itemsPerPage = 1;
    @api itemsPerPageMobile;
    @api itemsPerPageTablet;
    @api itemsPerPageDesktop;

    @api itemGutter = '1rem';

    @api showEdgeOverlapMobile;
    @api showEdgeOverlapTablet;
    @api keepIndicatorSpacing;

    @api carouselType = 'indicator';
    @api transitionSpeed = 500;
    @api set autoScroll(val) { this._autoScroll = parseInt(val, 10); }
    get autoScroll() { return this._autoScroll; }


    @track loadingPageSpinner;
    @track currentPage = 1;
    @track pageCount = 1;
    @track breakpoint = {};
    @track autoScrollIcon;

    connectedCallback() {
        this.loadingPageSpinner = true;
        if (!this.name) throw new Error('A carousel name is required for accessibility.');
        if (this.autoScroll) throw new Error('Auto-scroll has been disabled in the carousel.');
        this._addScreenSizeHandler();
        this.sub = subscribe('ui.breakpoint', breakpoint => {
            let startItemIndex = (this.currentPage - 1) * this.itemsPerPageValue;
            this.breakpoint = breakpoint;
            let newPage = Math.floor(startItemIndex / this.itemsPerPageValue) + 1;
            if (newPage !== this.currentPage) this.changePage(newPage);
        });
    }

    disconnectedCallback() {
        this._removeScreenSizeHandler();
    }

    renderedCallback() {
        this.resetUI();
    }

    resetUI() {
        // reset page count ( and avoid infinite loop )
        if (this.pageCount !== this.pageCountValue) {
            this.pageCount = this.pageCountValue;
            return;
        }

        this.items.forEach((item, idx) => {
            item.indexValue = idx;
            item.style.flex = `0 0 ${this.itemWidth}`;
            item.style.margin = `0 ${this.itemGutter}`;
            item.style.maxWidth = this.itemWidth;
        });

        let contentContainer = this.template.querySelector('.carousel-content-container');
        contentContainer.style.marginLeft = `calc(-${this.itemGutter} + (${this.edgesOverlapValue} / 2))`;
        contentContainer.style.transition = `left ${this.transitionSpeed}ms linear`;

        this.resetHeight();
        // this.resetAutoScroller(); DISABLED
    }

    /** resets height programmatically (ie. needed w/ variable images)
     * @function ipaCarousel#resetHeight
    */
    @api resetHeight() {
        let contentContainer = this.template.querySelector('.carousel-content-container');
        let mainContainer = this.template.querySelector('.carousel-container');
        mainContainer.style.height = `${contentContainer.scrollHeight}px`;
    }

    resetAutoScroller() {
        if (!this.items.length || !this.autoScroll || this.pageCount < 2 || this._autoScrollActive) return;
        if (this._autoScrollCancelled) return;
        clearInterval(this._autoScrollInterval);
        this._autoScrollActive = true;
        if (this.autoScroll && this.pageCount > 1) {
            this.autoScrollIcon = 'utility:pause';
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this._autoScrollInterval = setInterval(() => {
                if (this.currentPage === this.pageCount) {
                    this.changePage(1, true);
                } else {
                    this.changePage(this.currentPage < this.pageCount ? this.currentPage + 1 : 1);
                }
            }, this.autoScroll);
        }
    }

    cancelAutoScroller() {
        if (this._autoScrollActive) {
            this._autoScrollActive = false;
            this.autoScrollIcon = 'utility:play';
            clearInterval(this._autoScrollInterval);
            this._autoScrollCancelled = true;
        }
    }

    get items() {
        return this.querySelectorAll('[data-carousel-item]');
    }

    get itemsPerPageValue() {
        if (this.breakpoint.isMobile) return this.itemsPerPageMobile || this.itemsPerPage;
        if (this.breakpoint.isTablet) return this.itemsPerPageTablet || this.itemsPerPage;
        if (this.breakpoint.isDesktop) return this.itemsPerPageDesktop || this.itemsPerPage;
        return this.itemsPerPage;
    }

    get itemWidth() {
        let percent = (Math.round(1000000 / this.itemsPerPageValue) / 10000);
        let gutters = ((this.itemsPerPageValue - 1) * 2) / this.itemsPerPageValue;
        gutters = Math.round(gutters * 10000) / 10000;
        return `calc(${percent}% - (${this.itemGutter} * ${gutters}) - (${this.edgesOverlapValue} / ${this.itemsPerPageValue}))`;
    }

    get edgesOverlapValue() {
        let breakpoint = { ...getState().ui.breakpoint };
        if (breakpoint.isMobile && this.showEdgeOverlapMobile) return '30%';
        if (breakpoint.isTablet && this.showEdgeOverlapTablet) return '30%';
        return '0px';
    }

    get pageCountValue() {
        return Math.ceil(this.items.length / this.itemsPerPageValue);
    }

    get indicators() {
        // builds indicators
        let indicators = [];
        while (indicators.length < this.pageCount) {
            let page = indicators.length + 1;
            let active = String(this.currentPage) === String(page);
            indicators.push({
                page,
                key: `carousel-page-${page}`,
                class: 'slds-carousel__indicator-action ' + (active ? 'slds-is-active' : ''),
                ariaSelected: active,
                ariaControls: this.name,
                title: '',
                assistiveText: ''
            });
        }
        return indicators;
    }

    changePage(newPageValue, notransition) {
        let contentContainer = this.template.querySelector('.carousel-content-container');
        this.currentPage = newPageValue;
        let transition = contentContainer.style.transition;
        if (notransition) contentContainer.style.transition = 'none';
        contentContainer.style.left = `calc((-100% - (${this.itemGutter} * 2) + ${this.edgesOverlapValue}) * ${this.currentPage - 1})`;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        if (notransition) setTimeout(() => { contentContainer.style.transition = transition; }, 10);
        this.dispatchEvent(new CustomEvent('pagechange', { detail: { page: this.currentPage }}));
    }

    handleChangePage(evt) {
        this.changePage(evt.currentTarget.dataset.page);
        this.cancelAutoScroller();
   }

    handleStopAutoScroll() {
        this.cancelAutoScroller();
    }

    handleTouchStart(evt) {
        let touchobj = evt.changedTouches[0],
            swipedir = 'none',
            startX = touchobj.pageX,
            startY = touchobj.pageY,
            // record time when finger first makes contact with surface
            startTime = Date.now();
        this._touchData = { swipedir, startX, startY, startTime };
    }

    handleTouchEnd(evt) {
        let touchobj = evt.changedTouches[0],
            // get horizontal dist traveled by finger while in contact with surface
            distX = touchobj.pageX - this._touchData.startX,
            // get vertical dist traveled by finger while in contact with surface
            distY = touchobj.pageY - this._touchData.startY,
            // get time elapsed
            elapsedTime = Date.now() - this._touchData.startTime;

        // first condition for awipe met
        if (elapsedTime <= this.TOUCH_SETTINGS.allowedTime) {
            let threshold = this.TOUCH_SETTINGS.threshold,
                restraint = this.TOUCH_SETTINGS.restraint;
            // 2nd condition for horizontal swipe met
            if (Math.abs(distX) >= threshold && Math.abs(distY) <= restraint) {
                // if dist traveled is negative, it indicates left swipe
                let swipedir = (distX < 0) ? 'left' : 'right';
                // Page Logic
                if (swipedir === 'left' && this.currentPage < this.pageCount - 1) {
                    this.changePage(this.currentPage + 1);
                    this.cancelAutoScroller();
                } else if (swipedir === 'right' && this.currentPage > 1) {
                    this.changePage(this.currentPage - 1);
                    this.cancelAutoScroller();
                }
            }
        }
    }

    handleSlotChange(evt) {
        let nodes = evt.target.assignedNodes();
        // ensure wrapper is flex if it exists
        nodes.forEach(node => { node.style.display = 'flex'; });
        this.loadingPageSpinner = false;
    }

    // accessibility: change page automatically when tabbing through carousel items
    handleKeydown(evt) {
        if (evt.key === 'Tab') {
            this.cancelAutoScroller();
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                let focusedItem = this.querySelector('c-ipa-carousel-item:focus-within');
                if (focusedItem) {
                    let page = Math.floor(parseInt(focusedItem.indexValue, 10) / this.itemsPerPageValue) + 1;
                    if (page !== this.currentPage) this.changePage(page, page > this.currentPage);
                }
            }, 20);
        }
    }

    toggleAutoScroll() {
        if (this._autoScrollActive) {
            this.cancelAutoScroller();
        } else {
            this._autoScrollCancelled = false;
            this.resetAutoScroller();
        }
    }

    handleClickAutoScrollPlayPauseAccessibility(evt) {
        if (evt.key === 'Enter') this.toggleAutoScroll();
    }

    handleClickAutoScrollPlayPause() {
        this.toggleAutoScroll();
    }

    _addScreenSizeHandler() {
        this.screenSizeListener = () => {
            if (this._debounceResize) clearTimeout(this._debounceResize);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this._debounceResize = setTimeout(() => {
                this.resetHeight();
                this.resetAutoScroller();
                this._debounceResize = false;
            }, 100);
        };
        window.addEventListener('resize', this.screenSizeListener);
    }

    _removeScreenSizeHandler() {
        window.removeEventListener('resize', this.screenSizeListener);
    }
}