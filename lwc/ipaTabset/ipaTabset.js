/** Documentation for the Tabset Component
 * <br>To be used with the {@link ipaTab ipaTab} component.
 * @example
 * <c-ipa-tabset>
 *     <c-ipa-tab heading="Tab 1">Tab 1 Content</c-ipa-tab>
 *     <c-ipa-tab heading="Tab 2">Tab 2 Content</c-ipa-tab>
 * </c-ipa-tabset>
 * @namespace ipaTabset
 * @property {string} name required name prefix used on the tabs
 * @property {int} initialActiveTab optional index for the initial selected tab
 * @author Nick Demarest, last modified 29 May 2020
*/

import { LightningElement, track, api } from 'lwc';

export default class IpaTabset extends LightningElement {

    @api name;
    @api initialActiveTab;
    @track currentTab;
    @track tabs = [];
    scrollOffset = 0;

    get innerNav() {
        return this.template.querySelector('.tabset-nav-inner');
    }

    setPaddleVisiblity() {
        let paddlePrevVisible = false, paddleNextVisible = false;
        paddlePrevVisible = this.innerNav && this.scrollOffset > 0;
        if (this.innerNav) {
            let navWidth = this.innerNav.scrollWidth;
            let containerWidth = this.template.querySelector('.tabset-nav').clientWidth;
            paddleNextVisible = this.scrollOffset < (navWidth - containerWidth);
        } else {
            paddleNextVisible = false;
        }
        this.template.querySelector('.tabset-prev-paddle').classList.toggle('slds-hide', !paddlePrevVisible);
        this.template.querySelector('.tabset-next-paddle').classList.toggle('slds-hide', !paddleNextVisible);
    }

    paddleReset() {
        this.innerNav.style.transform = 'translateX(0px)';
        this.scrollOffset = 0;
        this.setPaddleVisiblity();
    }

    connectedCallback() {
        this.connected = true;
        if (!this.name) throw new TypeError('A tabset name is required for accessibility.');
        this.addScreenSizeHandler();
    }

    disconnectedCallback() {
        this.connected = false;
        this.removeScreenSizeHandler();
    }

    // adjust Paddle visibility onrender (this will fire twice if paddle state changes, but not infinitely)
    renderedCallback() {
        this.setPaddleVisiblity();
        if (this.forceFocus) {
            this.forceFocus = false;
            this.template.querySelector('.tabset-nav-item[data-is-active="true"]').focus();
        }
        // accessibility
        this.template.querySelectorAll('.tabset-nav-item').forEach((navItem, idx) => {
            navItem.setAttribute('id', this.tabs[idx].key + '-nav');
            navItem.setAttribute('aria-controls', this.tabs[idx].key);
        });
    }

    handleSlotChange() {
        let allTabs = this.querySelectorAll('c-ipa-tab') || [];
        this.tabs = [...allTabs].map((tab, idx) => ({
            el: tab,
            key: `tab-${idx}-${this.name}`,
            label: tab.heading,
            link: tab.link || `tab-${idx}-${this.name}`,
            isActive: this.initialActiveTab ? idx === this.initialActiveTab : idx === 0,
            tabIndex: idx === 0 ? 0 : -1,
        }));
        allTabs.forEach((tab, idx) => {
            tab.ariaLabelledBy = this.tabs[idx].key + '-nav';
            tab.idValue = this.tabs[idx].key;
        });

        this.currentTab = this.initialActiveTab ? this.tabs[this.initialActiveTab].key : this.tabs[0].key;
        this.resetTabs();
        this._checkForPaddleStateOnRerender = true;
    }

    handleChangeTab(evt) {
        this.currentTab = evt.currentTarget.dataset.tab;
        let idx = evt.currentTarget.dataset.idx;
        let link = evt.currentTarget.dataset.link;
        let label = evt.currentTarget.textContent;

        this.resetTabs();
        // update the url hash include the deep link
        window.history.pushState(null, null, '#' + link);

        this.dispatchEvent(new CustomEvent('tabchange', { detail: { tab: this.currentTab, idx, link, label }}));
    }

    handleTabChangeAccessibility(evt) {
        if (evt.code === 'ArrowLeft' || evt.code === 'ArrowRight') {
            this.forceFocus = true;
            let idx = parseInt(evt.currentTarget.dataset.idx, 10) + (evt.code === 'ArrowLeft' ? -1 : 1);
            let link = this.tabs[idx].link;
            let label =  this.tabs[idx].label;
            idx = (idx + this.tabs.length)%this.tabs.length;
            this.currentTab = this.tabs[idx].key;
            this.resetTabs();
            // update the url hash include the deep link
            window.history.pushState(null, null, '#' + link);
            this.dispatchEvent(new CustomEvent('tabchange', { detail: { tab: this.currentTab, idx, link, label }}));
        }
    }

    resetTabs() {
        this.tabs = this.tabs.map(tab => {
            let isActive = this.currentTab === tab.key;
            tab.el.active = isActive;
            return { ...tab, isActive, tabIndex: isActive ? 0 : -1};
        });
    }

    handlePaddleClick(evt) {
        let direction = evt.currentTarget.dataset.direction;
        let scrollOffset = this.scrollOffset, newScrollOffset;
        let navWidth = this.innerNav.scrollWidth;
        let containerWidth = this.template.querySelector('.tabset-nav').clientWidth;
        if (direction === 'next') {
            newScrollOffset = scrollOffset + containerWidth;
            newScrollOffset = (newScrollOffset > navWidth - containerWidth) ? (navWidth - containerWidth) : newScrollOffset;
        } else {
            newScrollOffset = scrollOffset - containerWidth;
            newScrollOffset = (newScrollOffset < 0) ? 0 : newScrollOffset;
        }
        this.innerNav.style.transform = 'translateX(-' + newScrollOffset + 'px)';
        this.scrollOffset = newScrollOffset;
        this.setPaddleVisiblity();
    }

    addScreenSizeHandler() {
        this.screenSizeListener = () => {
            if (this._debounceResize) clearTimeout(this._debounceResize);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this._debounceResize = setTimeout(() => {
                if (this.innerNav) this.paddleReset();
                this._debounceResize = false;
            }, 80);
        };
        window.addEventListener('resize', this.screenSizeListener);
    }

    removeScreenSizeHandler() {
        window.removeEventListener('resize', this.screenSizeListener);
    }
}