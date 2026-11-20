import { LightningElement, track } from 'lwc';

/**
 * TODO - description
 *
 * @augments LightningElement
 * @private
 */
export default class CoreIntcStyleGuide extends LightningElement {
    radioValue = '';

    /**
     * TODO - description
     *
     * @returns {object[]} TODO - description
     * @private
     */
    get radioOptions() {
      return [
        { label: 'Option 1', value: '1' },
        { label: 'Option 2', value: '2' },
        { label: 'Option 3', value: '3' },
      ];
    }

    /**
     * TODO - description
     *
     * @returns {object[]} TODO - description
     * @private
     */
    get dropdownOptions() {
      return [
        { label: 'Option 1', value: '1' },
        { label: 'Option 2', value: '2' },
        { label: 'Option 3', value: '3' },
      ];
    }



  /* Typeahead search */
  @track currentlySearching;

  @track typeaheadOptions = [];

  @track typeaheadNoResults;

  @track typeaheadSelection;

  minimumCharactersForSearch = 3;

  noResultsLabel = 'No results.';

  /** handles search clear from CoreIntcSearch
   *
   */
  handleClearKeyword() {
    this.helperClearTypeahead();
  }

  /** handles search input - finished typing
   *
   * @param {*} evt finished typing event from CoreIntcSearch
   */
  handleFinishedTyping(evt) {
    this.helperTypeahead(evt.detail.keywordValue);
  }

  /** handle typeahead option selected
   *
   * @param {event} evt selected option event from CoreIntcSearch
   */
  handleSelectedOption(evt) {
    const { value } = evt.detail;
    this.typeaheadSelection = value;
    this.helperClearTypeahead();
  }

  /** clears typeahead values
   *
   */
  helperClearTypeahead() {
    this._cleared = true;
    this.currentlySearching = false;
    this.typeaheadOptions = [];
    this.typeaheadNoResults = '';
  }

  /** typeahead helper
   * logic around typehead values and backend search
   * based on keyword length and minimumCharactersForSearch
   * adds a "No Results" label for a valid search that returns no results
   *
   * @param {string} keywordValue keyword to search coveo;
   */
  async helperTypeahead(keywordValue) {
    this._cleared = false;
    this.typeaheadNoResults = '';
    this._keywordValue = keywordValue; // keep track for multiple consecutive searches

    if (keywordValue.length < this.minimumCharactersForSearch) {
      this.helperClearTypeahead();
      return;
    }

    let response = [];
    this.currentlySearching = true;

    try {
      response = await this.typeaheadSearch(keywordValue);
    } catch (e) {
      // TODO: Add Error Handling
      console.error('Problem with typeahead function', e);
    }

    if (this._keywordValue !== keywordValue || this._cleared) {
      return; // ignore response b/c another search has already begun (or search has been cleared)
    }

    this.currentlySearching = false;
    this.typeaheadOptions = response;
    this.typeaheadNoResults = response.length > 0 ? '' : 'No results';
  }

  /** function
   *
   * @param {string} keyword keyword
   * @returns {Promise<string[]>} typeahead options
   */
  typeaheadSearch(keyword) {
    let mock = [];
    const words = keyword.split(' ');
    if (keyword !== 'none' && words.length > 0) {
      mock = [
        `${words[0]} lorem ipsum`,
        `semper ${words[0]}`,
        `aute ${words[0]}`,
        `magna ${words[0]}`,
        `proident ${words[0]} duis`,
        `${words[0]} ${words[1] || 'esse'}`,
        `${words[0]} ${words[1] || 'blue'} green yellow`,
        `${words[0]} apple ${words[1] || 'orange'}`,
        `${words[0]} simple bark ${words[1] || 'tree'} flower`,
        `Ut ${words[0]} esse adipisicing aute magna proident officia duis esse ex. Aliqua eiusmod exercitation proident`,
      ];
    }
    if (keyword === 'fewer') {
      mock = mock.slice(0, 5);
    }
    if (keyword === 'more') {
      mock.push('another', 'and another', `and another ${words[0]}`);
    }
    // eslint-disable-next-line no-return-await
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    return new Promise((r) => setTimeout(() => { r(mock); }, 1000));
  }

  /** RESOURCES CREATE */
  resourceTypeOptions = [
    { label: 'White Paper', value: 'wp' },
    { label: 'Document', value: 'doc' },
  ];

  /**
   * handle add resources
   */
  handleAddResources() {
    // IPA2.0 + US TWC4497-1631
    // this.template.querySelector('c-ipa-offering-resource-create').open();
  }
}