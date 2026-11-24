import {
  registerComponentForInit,
  initializeWithHeadless,
  getHeadlessBundle,
} from 'c/quanticHeadlessLoader';
import {getItemFromLocalStorage, setItemInLocalStorage} from 'c/quanticUtils';
import {LightningElement, api, track} from 'lwc';

/** @typedef {import("coveo").SearchEngine} SearchEngine */
/** @typedef {import("coveo").SearchBoxState} SearchBoxState */
/** @typedef {import("coveo").SearchBox} SearchBox */
/** @typedef {import("coveo").RecentQueriesList} RecentQueriesList */

export default class quanticSearchBox extends LightningElement {
  @api engineId;
  @api placeholder = null;
  @api withoutSubmitButton = false;
  @api numberOfSuggestions = 7;
  @api textarea = false;
  @api disableRecentQueries = false;
  @api keepFiltersOnSearch = false;

  _subject;
  /**
   * Pre-populated query text passed from the parent component (e.g., Case Subject).
   * @api
   * @type {string}
   */
  @api
  get subject() {
    return this._subject;
  }
  set subject(value) {
    const previousValue = this._subject;
    this._subject = value;
    if (this.searchBox && value && value !== previousValue) {
      this.searchBox.updateText(value);
      this.searchBox.submit();
    }
  }

  @track state;

  searchBox;
  unsubscribe;
  headless;
  suggestions = [];
  hasInitializationError = false;
  recentQueriesList;
  recentQueries;

  /**
   * @param {SearchEngine} engine
   */
  initialize = (engine) => {
    this.engine = engine;
    this.headless = getHeadlessBundle(this.engineId);
    this.searchBox = this.headless.buildSearchBox(engine, {
      options: {
        numberOfSuggestions: Number(this.numberOfSuggestions),
        highlightOptions: {
          notMatchDelimiters: {
            open: '<b>',
            close: '</b>',
          },
        },
        clearFilters: !this.keepFiltersOnSearch,
      },
    });

    this.actions = {
      ...this.headless.loadQuerySuggestActions(engine),
    };

    if (!this.disableRecentQueries && this.headless.buildRecentQueriesList) {
      this.localStorageKey = `${this.engineId}_quantic-recent-queries`;
      this.recentQueriesList = this.headless.buildRecentQueriesList(engine, {
        initialState: {
          queries: getItemFromLocalStorage(this.localStorageKey) ?? [],
        },
        options: {
          maxLength: 20,
          clearFilters: !this.keepFiltersOnSearch,
        },
      });
      this.unsubscribeRecentQueriesList = this.recentQueriesList.subscribe(() =>
        this.updateRecentQueriesListState()
      );
    }

    this.unsubscribe = this.searchBox.subscribe(() => this.updateState());

    if (this._subject) {
      this.searchBox.updateText(this._subject);
    }
  };

  connectedCallback() {
    registerComponentForInit(this, this.engineId);
    this.addEventListener(
      'quantic__inputvaluechange',
      this.handleInputValueChange
    );
    this.addEventListener('quantic__submitsearch', this.handleSubmit);
    this.addEventListener('quantic__showsuggestions', this.showSuggestion);
    this.addEventListener('quantic__selectsuggestion', this.selectSuggestion);
  }

  renderedCallback() {
    initializeWithHeadless(this, this.engineId, this.initialize);
  }

  disconnectedCallback() {
    this.unsubscribe?.();
    this.unsubscribeRecentQueriesList?.();
    this.removeEventListener(
      'quantic__inputvaluechange',
      this.handleInputValueChange
    );
    this.removeEventListener('quantic__submitsearch', this.handleSubmit);
    this.removeEventListener('quantic__showsuggestions', this.showSuggestion);
    this.removeEventListener(
      'quantic__selectsuggestion',
      this.selectSuggestion
    );
  }

  get searchBoxValue() {
    return this.searchBox?.state.value || '';
  }

  updateState() {
    this.state = this.searchBox?.state;
    this.suggestions =
      this.state?.suggestions?.map((suggestion, index) => ({
        key: index,
        rawValue: suggestion.rawValue,
        value: suggestion.highlightedValue,
      })) ?? [];
  }

  updateRecentQueriesListState() {
    if (this.recentQueriesList.state?.queries) {
      this.recentQueries = this.recentQueriesList.state.queries;
      setItemInLocalStorage(
        this.localStorageKey,
        this.recentQueriesList.state.queries
      );
    }
  }

  handleInputValueChange = (event) => {
    event.stopPropagation();
    const newValue = event.detail.value;
    if (this.searchBox?.state?.value !== newValue) {
      this.searchBox.updateText(newValue);
    }
  };

  handleSubmit = (event) => {
    event.stopPropagation();
    this.searchBox?.submit();
  };

  showSuggestion = (event) => {
    event.stopPropagation();
    this.searchBox?.showSuggestions();
  };

  selectSuggestion = (event) => {
    event.stopPropagation();
    const {value, isRecentQuery, isClearRecentQueryButton} =
      event.detail.selectedSuggestion;
    if (isClearRecentQueryButton) {
      this.recentQueriesList.clear();
    } else if (isRecentQuery) {
      this.recentQueriesList.executeRecentQuery(
        this.recentQueries.indexOf(value)
      );
      this.engine.dispatch(
        this.actions.clearQuerySuggest({
          id: this.state.searchBoxId,
        })
      );
    } else {
      this.searchBox?.selectSuggestion(value);
    }
  };

  setInitializationError() {
    this.hasInitializationError = true;
  }
}