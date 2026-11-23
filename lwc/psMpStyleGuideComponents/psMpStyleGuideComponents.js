import { LightningElement, api, track } from 'lwc';
import { subscribe } from 'c/ipaRedux';

import cards from './cards.html';
import modals from './modals.html';
import components from './psMpStyleGuideComponents.html';

import data, { loadingData } from './mockdata/index';

export default class Styleguide extends LightningElement {

    @api page; // see #render
    @api loadData = 0; // seconds to show 'loading' state of component if applicable
    @track data = null;
    @track breakpoint = {};

    connectedCallback() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => { this.data = data; }, this.loadData * 1000);
        this.data = loadingData;
        this._subscription = subscribe('ui.breakpoint', breakpoint => {
            this.breakpoint = breakpoint;
        });
    }

    disconnectedCallback() {
        this._subscription();
    }

    get isDataLoaded() {
        return this.data ? true : false;
    }

    render() {
        switch (this.page) {
            case 'Cards':
                return cards;
            case 'Modals':
                return modals;
            default:
                return components;
        }
    }

    handleReload() {
        this.data = loadingData;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => { this.data = data; }, 3000);
    }

    // modals.html
    handleOpenModal(evt) {
        let m = evt.currentTarget.dataset.modal;
        this.template.querySelector(`c-ps-mp-modal[data-name="modal${m}"]`).openModal();
    }

}