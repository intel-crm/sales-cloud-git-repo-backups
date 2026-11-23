import { LightningElement, api } from 'lwc';

/* istanbul ignore file */

import ariaClearSearchLabel from '@salesforce/label/c.Core_Intc_TypeaheadAccessibilityClear';
import ariaSearchLabel from '@salesforce/label/c.Core_Intc_TypeaheadAccessibilitySearch';
import ariaTypeaheadInstructions from '@salesforce/label/c.Core_Intc_TypeaheadAccessibility';

/**
 * @typedef TypeaheadOption
 * @property {string} label label
 * @property {string} value value
 */

/** A reusable component for a search input.
 *
 * This component is exposed in the Community Builder.
 *
 * A note on typeahead functionality:
 * - the component always searches what is in the input
 * - if a typeahead selection is made with the keyboard or mouse, the input value (keywordValue)
 * - is set before searching, and then the search is made so that the input value is always the search value
 *
 * <div id="core-examples" sf-attr="c-coreintcsearch_coreintcsearch">
 *  <demo-core-intc-search show1="true"></demo-core-intc-search>
 *  <demo-core-intc-search show2="true"></demo-core-intc-search>
 * </div>
 *
 * @example
 * <!-- HTML component example 1 -->
 * <!-- using an array of strings -->
 * <c-core-intc-search onfinishedtyping={handleInputChange} onkeywordinput={handleSearchByKeyword} onclearkeyword={handleClearKeyword}
 * onselectedoption={handleSelectedOption} placeholder="Type here" typeahead-options={matchingStates} is-typeahead
 * debounce-leading debounce-delay={debounceDelay}></c-core-intc-search>
 *
 * @example
 * <!-- HTML component example 2 -->
 * <!-- using an array of objects -->
 * <c-core-intc-search onfinishedtyping={handleInputChange} onkeywordinput={handleSearchByKeyword} onclearkeyword={handleClearKeyword}
 * onselectedoption={handleSelectedOption} placeholder="Type here" typeahead-options={matchingStates} is-typeahead
 * debounce-leading debounce-delay={debounceDelay}></c-core-intc-search>
 *
 * @class CoreIntcSearch
 * @private
 * @augments LightningElement
 * @property {string} keywordValue Api keyword value.
 * @property {string} placeholder Api pass in placeholder value text.
 * @property {boolean} disabled disable input
 * @property {number} debounceDelay Debounce search delay count
 * @property {boolean} debounceLeading use "leading" debounce / throttle to fire immediately
 * @property {boolean} isTypeahead is typeahead implementation
 * @property {boolean} showFilterSearchInputSpinnerIcon Show spinner icon true/false
 * @property {TypeaheadOption[]|string[]} typeaheadOptions list of typeahead options
 * @property {string} typeaheadNoResultsText "No results" returned from typeahead text
 * @property {string} [ariaClearSearchLabel] "clear search" accessibility label (default is Core_Intc_TypeaheadAccessibilityClear)
 * @property {string} [ariaSearchLabel] "search" accessibility label (default is Core_Intc_TypeaheadAccessibilitySearch)
 * @property {string} [ariaTypeaheadInstructions] accessibility typeahead instructions (default is Core_Intc_TypeaheadAccessibility)
 * @fires finishedtyping passes input value after 300ms when user is typing
 * @fires clearkeyword clears keyword value
 * @fires keywordinput when keyword is entered and user enters on search input
 */
export default class CoreIntcSearch extends LightningElement {
    // Need to delegate the focus behavior to inside the template content
    static delegatesFocus = true;

    @api ariaClearSearchLabel = ariaClearSearchLabel;

    @api ariaSearchLabel = ariaSearchLabel;

    @api ariaTypeaheadInstructions = ariaTypeaheadInstructions;

    // ******* API variables - defined in class properties *******
    @api keywordValue = '';

    @api placeholder = '';

    @api disabled;

    @api debounceDelay = 300;

    @api debounceLeading;

    @api isTypeahead;

    @api showFilterSearchInputSpinnerIcon;

    /**
     * Typeahead options setter
     * sets label/value, highlights string w/ <strong> tags, keeps track of index
     *
     * @param {TypeaheadOption[]|string[]} val typeahead options value
     * @private
     */
    @api set typeaheadOptions(val) {
      this._typeaheadOptions = [...val].map((opt, idx) => {
        const label = typeof opt === 'string' ? opt : opt.label;

        return {
          key: `option-${idx}`,
          idx: (idx + 1),
          label: this.highlightTerms(label),
          originalLabel: label,
          value: typeof opt === 'string' ? opt : opt.value,
        };
      });
      this.currentTypeaheadIdx = 0;
    }

    /** typeahead options
     *
     * @returns {object[]} typeahead options
     * @private
     */
    get typeaheadOptions() {
      return this._typeaheadOptions || [];
    }

    @api typeaheadNoResults;

    currentTypeaheadIdx = 0;

    /** connected callback
     * sets base aria values for typeahead (only has to do this once)
     *
     * @private
     */
    connectedCallback() {
      this.ariaIds = {
        activeDescendant: this.isTypeahead ? `selectedTypeaheadOption` : '',
        owns: this.isTypeahead ? `typeaheadResults` : '',
        description: this.isTypeahead ? `typeaheadDescription` : '',
        autocomplete: this.isTypeahead ? 'both' : '',
      };
    }

    /**
     * Shows clear icon if there is a keyword value
     *
     * @returns {boolean} returns true or false if there is a keyword
     * @private
     */
    get showSearchInputClearIcon() {
      return this.keywordValue && this.keywordValue.length > 0;
    }

    /** shows typeahead based on typeahead options and/or typeahead "No Results" text
     *
     * @returns {boolean} returns true or false if there is a keyword
     * @private
     */
    get showTypeahead() {
      return this.typeaheadOptions.length > 0 || !!this.typeaheadNoResults;
    }

    /** typeahead options
     *
     * @returns {*} list of typeahead options
     * @private
     */
    get formattedTypeaheadOptions() {
      return this.typeaheadOptions.map((opt, idx) => ({
        ...opt,
        id: this.currentTypeaheadIdx === (idx + 1) ? this.ariaIds.activeDescendant : `ciso${idx}`,
        selected: this.currentTypeaheadIdx === (idx + 1),
      }));
    }

    /**
     * Highlights words in search responses
     *
     * @param {string} label string value for typeahead option
     * @returns {string} new label with syntax highlight (rich text)
     * @private
     */
    highlightTerms(label) {
      let words = this.keywordValue.match(/\w+/g) || []; // get words from keyword value
      words = words.slice(0, 16); // only look at first 16 words for performance if super long string

      // wrap matching words in <strong> tags to highlight
      let newLabel = label;
      words.forEach((word) => {
        const reg = new RegExp(`\\b${word}\\b`, 'g');
        newLabel = newLabel.replace(reg, `<strong>${word}</strong>`);
      });
      return newLabel;
    }

    /**
     * Gets keyword value from search input
     *
     * @param {event} evt input event
     * @private
     */
    handleSearchInput(evt) {
      /* eslint-disable @lwc/lwc/no-api-reassignments */
      this.keywordValue = evt.currentTarget.value;
      this._keywordValue = this.keywordValue; // stored for typeahead
      this._preventKeywordSearch = false;

      const finishedTyping = new CustomEvent('finishedtyping', {
        detail: {
          keywordValue: this.keywordValue,
        },
      });

      let firedEvent;

      if (this._debounce) {
        clearTimeout(this._debounce);
      // if debounce leading is set to true, fire immediately
      } else if (this.debounceLeading) {
        this.dispatchEvent(finishedTyping);
        firedEvent = true;
      }

      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this._debounce = setTimeout(() => {
        if (!firedEvent) {
          this.dispatchEvent(finishedTyping);
        }
        this._debounce = null; // reset debounce so debounce leading can operate again
      }, this.debounceDelay);
    }

    /**
     * Handle Search on Input Blur
     *
     * @private
     */
    handleSearchByKeyword() {
      if (this._preventKeywordSearch) {
        return;
      }

      const keywordInputEvent = new CustomEvent('keywordinput', {
        detail: {
          keywordValue: this.keywordValue,
        },
      });

      this.dispatchEvent(keywordInputEvent);
    }

    /** Handle Search on Icon Click
     *
     * @param {event} evt click event
     * @private
     */
    handleSearchButtonClick(evt) {
      evt.preventDefault();
      if (this.isTypeahead) {
        this.helperSelectTypeaheadOption();
      } else {
        this.handleSearchByKeyword();
      }
    }

    /**
     * Prevents double search (oninput called onblur)
     *
     * @private
     */
    handleClearKeywordMousedown() {
      this._preventKeywordSearch = true; // prevents double search (oninput called onblur)
    }

    /**
     * Clears keywordValue when close icon is hit
     *
     * @private
     */
    helperClearKeyword() {
      this.keywordValue = '';
      const clearKeywordInput = new CustomEvent('clearkeyword');
      this.dispatchEvent(clearKeywordInput);
      if (this.isTypeahead) {
        this.currentTypeaheadIdx = 0;
        this.typeaheadOptions = [];
      }
      this.template.querySelector('input[type="search"]').focus();
    }

    /**
     * Calls helpers to handle clear keyword value
     *
     * @private
     */
    handleClearKeyword() {
      this.helperClearKeyword();
    }

    /**
     * General Accessibility handler
     * Escape clears search
     * For typeaheads: up/down arrow keys, and enter key
     *
     * @param {event} evt key event
     * @private
     */
    handleKeyAccessibility(evt) {
      const { code } = evt;
      if (code === 'Escape') {
        this.helperClearKeyword();
      }

      if (!this.isTypeahead) {
        return;
      }

      // get original label text (without syntax highlighting <strong> tags)
      const originalLabel = (idx) => (idx === 0 ? this._keywordValue : this.typeaheadOptions[idx - 1].originalLabel);

      // Move down thru typeahead options (accessibility)
      if (code === 'ArrowDown' && this.showTypeahead) {
        this.currentTypeaheadIdx += 1;
        if (this.currentTypeaheadIdx > this.typeaheadOptions.length) {
          this.currentTypeaheadIdx = 0; // reset to top (1 would be first typeahead option)
        }
        this.keywordValue = originalLabel(this.currentTypeaheadIdx);
      }

      // Move up thru typeahead options (accessibility)
      if (code === 'ArrowUp' && this.showTypeahead) {
        this.currentTypeaheadIdx += -1;
        if (this.currentTypeaheadIdx < 0) {
          this.currentTypeaheadIdx = this.typeaheadOptions.length; // reset to bottom
        }
        this.keywordValue = '';
        // keeps cursor at the end of the input
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          this.keywordValue = originalLabel(this.currentTypeaheadIdx);
        }, 2);
      }

      // Select a typeahead option (accessibility)
      if (code === 'Enter') {
        this.helperSelectTypeaheadOption();
      }
    }

    /** click typeahead option
     *
     * @param {event} evt click event
     * @private
     */
    handleClickTypeaheadOption(evt) {
      const idx = parseInt(evt.currentTarget.dataset.idx, 10);
      this.keywordValue = this.typeaheadOptions[idx - 1].originalLabel;
      this.helperSelectTypeaheadOption();
    }

    /** mouseover typeahead option
     *
     * @param {event} evt mouseover event
     * @private
     */
    handleMouseoverTypeaheadOption(evt) {
      this.currentTypeaheadIdx = parseInt(evt.currentTarget.dataset.idx, 10);
    }

    /** mouseout typeahead option
     *
     * @private
     */
    handleMouseoutTypeaheadOptions() {
      this.currentTypeaheadIdx = 0;
    }

    /** typeahead option select
     *
     * @private
     */
    helperSelectTypeaheadOption() {
      let optionValue;
      if (this.currentTypeaheadIdx > 0) {
        optionValue = this.typeaheadOptions[this.currentTypeaheadIdx - 1].value;
      }
      this.currentTypeaheadIdx = -1; // resets UI / weird bug where view doesn't refresh if stays 0
      this.typeaheadOptions = []; // resets typeahead options
      const selectedOption = new CustomEvent('selectedoption', {
        detail: { value: this.keywordValue, optionValue },
      });
      this.dispatchEvent(selectedOption);
    }

    /**
     * Clears keyword Value on Enter for Accessibility
     *
     * @param {event} evt key event
     * @private
     */
    handleClearKeywordAccessibility(evt) {
      if (evt.code === 'Enter') {
        this.helperClearKeyword();
      }
    }
}