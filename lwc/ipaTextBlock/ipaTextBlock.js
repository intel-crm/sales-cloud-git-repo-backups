/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api , track } from 'lwc';

import more from '@salesforce/label/c.PMP_More';
import less from '@salesforce/label/c.PMP_Show_Less';

export default class IpaTextBlock extends LightningElement {

    @api introSection = '';
    @api moreSection = '';
    @api heightLimited = '';
    @api heightLimitedSize = 'small';
    @track heightLimitedExceedsHeight = false;

    @api className = '';

    @track showMore;

    label = {
        more,
        less
    };

    debounce(callback, wait) {
        let timeout;
        return (...args) => {
            const context = this;
            clearTimeout(timeout);
            timeout = setTimeout(() => callback.apply(context, args), wait);
        };
    }

    connectedCallback() {
        if (this.heightLimited !== '') {
            window.addEventListener('resize', this.debounce(() => this.validateShowMore(), 500));
        }
    }

    renderedCallback() {
        this.validateShowMore();
    }

    get classes() {
        return {
            host: 'host ' + this.heightLimitedSize + ' ' + this.className,
            heightLimited: this.heightLimitedSize + ' heightLimited ' + (this.showMore ? 'expanded' : 'compact') + ' ' + (this.heightLimitedExceedsHeight ? 'h-enabled': 'h-disabled')
        };
    }

    get ifs() {
        return {
          notHeightLimited: this.heightLimited === '',
          showMore: this.showMore,
          notEmptyMoreSection: this.moreSection !== '',
          exceedsHeight: this.heightLimitedExceedsHeight
        };
      }

    @api
    handleMoreClick(e) {
        this.showMore = !this.showMore;
        e.preventDefault();
    }

    validateShowMore() {
        // check text inner height
		if (this.heightLimited !== '') {
            let wrapper = this.template.querySelector('[data-id="wrapper"]');
            let innerContent = this.template.querySelector('[data-id="innerContent"]');
            if (wrapper) {
                if (!this.showMore) {
                    let maxHeight = window.getComputedStyle(wrapper).maxHeight;
                    this.maxHeight = parseInt(maxHeight, 10);
                }
                let showShowMore = (wrapper.clientHeight <= innerContent.clientHeight && wrapper.clientHeight >= this.maxHeight);
                this.heightLimitedExceedsHeight = showShowMore;
            }
        }
	}

}