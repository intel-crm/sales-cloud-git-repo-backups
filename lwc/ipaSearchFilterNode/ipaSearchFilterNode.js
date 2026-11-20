import { LightningElement, api } from 'lwc';
import { subscribeToTaxonomyData } from 'c/ipaTaxonomyService';

// Custom Labels
import viewAllPartners from '@salesforce/label/c.PMP_Search_ViewAllPartners';
import selectAll from '@salesforce/label/c.PMP_Search_SelectAll';
import deselectAll from '@salesforce/label/c.PMP_Search_DeselectAll';
import toggleFilterTreeItemAria from '@salesforce/label/c.PMP_Search_Toggle_Filter_Tree_Item_Aria';
//import prereleaseLabel from '@salesforce/label/c.PMP_Create_Offering_Prerelease_Label';

// Templates
import defaultTemplate from './ipaSearchFilterNode.html';
import selectTemplate from './select.html';
import largeData from './largeData.html';
import partnerTemplate from './partnerAZ.html';


/** Filter Node Component for ipaSearch (L2 Category search page)
 *
 * Parent Component: {@link ipaSearchFilters ipaSearchFilters}
 *
 * @property {object} filter keeps track of data on the filter
 * @property {boolean} isDraft used for 'draft' filters (in the modal and on mobile)
 * @property {boolean} showPreRelease shows pre-release items (intel admins only)
 * @augments LightningElement
 */
class IpaSearchFilterNode extends LightningElement {
    @api filter;

    @api isDraft;

    @api showPreRelease;

    /**
     * sets search params
     * - if node is a select, rebuild select options
     */
    @api set searchParams(params) {
      this._searchParams = params;
      if (this.filterDisplayType === 'select') {
        this.selectOptions = this.buildSelectOptions();
      }
    }

    /**
     * get search params
     *
     * @returns {object} search params
     */
    get searchParams() {
      return this._searchParams || {};
    }

    @api searchResponseFilters = {};

    /**
     * Custom labels
     *
     * @type {object}
     * @private
     */
    labels = {
      parternAZViewAll: viewAllPartners,
      selectAll,
      deselectAll,
      toggleFilterTreeNodeAria: toggleFilterTreeItemAria,
    //  prerelease: prereleaseLabel,
    }

    taxonomyData = {};

    /**
     * Internal ux state tracking, for 'large-data' filters only
     *
     * @type {object}
     * @private
     */
    expanded = {};

    /**
     * Returns HTML Template for rendering filter node
     *
     * @returns {object} template
     * @private
     */
    render() {
      if (this.filterDisplayType === 'select') {
        return selectTemplate;
      }
      if (this.filterDisplayType === 'large-data') {
        return largeData;
      }
      if (this.filterDisplayType === 'partner-list') {
        return partnerTemplate;
      }
      return defaultTemplate;
    }

    /**
     * Returns filter taxonomy
     *
     * @returns {object} filter taxonomy
     * @private
     */
    get filterTaxonomy() {
      return this.taxonomyData[this.filter.name] || {};
    }

    /**
     * Returns filter display type
     *
     * @returns {string} display type
     * @private
     */
    get filterDisplayType() {
      return this.filterTaxonomy.filterDisplayType;
    }

    /**
     * Returns css classes for styling filter node checkbox
     *
     * @returns {string} classes
     * @private
     */
    get checkboxClasses() {
      return 'checkbox checkbox-size-default';
    }

    /**
     * Returns search result counts
     *
     * @returns {object} search result counts
     * @private
     */
    get resultCounts() {
      return this.searchResponseFilters || {};
    }

    /**
     * Returns list of child filters
     *
     * @returns {object[]} child filters
     * @private
     */
    get filterRecords() {
      return (this.filter.children || [])
        .filter((id) => this.resultCounts[id])
        .map((id) => this.filterTaxonomy.records[id]);
    }

    /**
     * Returns list of child filter node objects
     *
     * @returns {object[]} child filter nodes
     * @private
     */
    get childFilters() {
      const isLargeData = this.filterDisplayType === 'large-data';
      const children = this.filterRecords.reduce((result, filter) => {
        const key = `filter-node-${filter.id}`;
        const childFilter = {
          key,
          label: filter.label,
          value: filter.id,
          name: this.filter.name,
          selected: this.filter.selectedFiltersList[filter.id],
          selectedFiltersList: this.filter.selectedFiltersList,
          expandedFilters: this.filter.expandedFilters,
          prerelease: !!filter.prerelease,
          count: this.resultCounts[filter.id] || 0,
          children: [...filter.children] || [],
          hasChildren: filter.children.length > 0,
          hasVisibleChildren: filter.children.some((child) => this.resultCounts[child] && (this.showPreRelease || !filter.prerelease)),
        };

        // complex logic for Expanded Filter priority
        // user interaction takes precedence
        if (isLargeData) {
          childFilter.expanded = childFilter.selected || (childFilter.expandedFilters || {})[childFilter.name];
          if (this.filter.highlightedFilters) {
            childFilter.highlighted = this.filter.highlightedFilters[filter.id];
            childFilter.highlightedFilters = this.filter.highlightedFilters;
          }
          // highlighted override
          if (this.filter.expandedFilters) {
            if (this.filter.expandedFilters[filter.id] !== undefined) {
              childFilter.expanded = this.filter.expandedFilters[filter.id];
            }
            childFilter.expandedFilters = this.filter.expandedFilters;
          }
          if (this.filter.modalData && this.filter.modalData === key && this.expanded[key] === undefined) {
            childFilter.expanded = true;
          }
          // override expanded value with internal state (if not just searched)
          if (this.filter.searchKeyword === this.searchKeyword) {
            if (this.expanded[key] !== undefined) {
              childFilter.expanded = this.expanded[key];
            }
          }
          this.searchKeyword = this.filter.searchKeyword;
          childFilter.searcKeyword = this.filter.searchKeyword;
          childFilter.expandedIcon = childFilter.expanded ? 'utility:dash' : 'utility:add';
          if (childFilter.expanded) {
            childFilter.rendered = true; // performance boost
          }
        }
        if (this.showPreRelease || !childFilter.prerelease) {
          result.push(childFilter);
        }
        return result;
      }, []);
      return children;
    }

    /**
     * Returns sorted list of select options
     *
     * @returns {object[]} select options
     * @private
     */
    buildSelectOptions() {
      const selectedOptions = this.searchParams.filters[this.filter.name] || [];
      // build select filter options from records
      const options = (this.filter.children || []).reduce((filtered, option) => {
        // filter out options without results (unless Country)
        if (this.resultCounts[option] || this.filter.name === 'Country') {
          const record = this.filterTaxonomy.records[option];
          filtered.push({
            label: record.label, value: record.id, selected: selectedOptions.includes(record.id),
          });
        }
        return filtered;
        // then sort alphabetically (with current selected option first)
      }, []).sort((optA, optB) => {
        if (optA.selected) return -1;
        if (optB.selected) return 1;
        return optA.label < optB.label ? -1 : 1;
      });
      if (!selectedOptions.length) {
        options.unshift({ label: '', value: '' });
      }
      return options;
    }

    /**
     * Returns list of tags for partner-list display
     *
     * @returns {object[]} tags
     * @private
     */
    get tagGroup() {
      return [
        {
          label: 'Ω', id: 'Ω', key: 'Omega', href: '#Ω', regex: /^[^a-z0-9].?/i,
        },
        {
          label: '#', id: '#', key: 'Number', href: '##', regex: /^[\d].?/i,
        },
        {
          label: 'A-D', id: 'A-D', key: 'A-D', href: '#A-D', regex: /^[abcd].?/i,
        },
        {
          label: 'E-I', id: 'E-I', key: 'E-I', href: '#E-I', regex: /^[efghi].?/i,
        },
        {
          label: 'J-N', id: 'J-N', key: 'J-N', href: '#J-N', regex: /^[jklmn].?/i,
        },
        {
          label: 'O-S', id: 'O-S', key: 'O-S', href: '#O-S', regex: /^[opqrs].?/i,
        },
        {
          label: 'T-X', id: 'T-X', key: 'T-X', href: '#T-X', regex: /^[tuvwx].?/i,
        },
        {
          label: 'Y-Z', id: 'Y-Z', key: 'Y-Z', href: '#Y-Z', regex: /^[yz].?/i,
        },
      ];
    }

    /**
     * Returns list of partner filters for partner-list display
     *
     * @returns {object[]} partner filters
     * @private
     */
    get filterListForPartnerAZ() {
      const all = {}; const
        tags = this.tagGroup;
      tags.forEach((tag) => { all[tag.id] = { ...tag, filterList: [] }; });
      this.childFilters.forEach((item) => all[tags.find((tag) => item.label.match(tag.regex)).id].filterList.push(item));
      Object.keys(all).forEach((key) => {
        all[key].filterList.sort((a, b) => (a.label.toLowerCase() > b.label.toLowerCase() ? 1 : -1));
      });
      return Object.values(all);
    }

    /**
     * connected callback
     * - subscribes to taxonomy data loading
     */
    connectedCallback() {
      this._subscription = subscribeToTaxonomyData((taxonomyData) => {
        if (taxonomyData.includesSecondaryList) {
          this.taxonomyData = taxonomyData.data;
          if (this.filterDisplayType === 'select') {
            this.selectOptions = this.buildSelectOptions();
          }
        }
      });
    }

    /**
     * unsubscribes to taxonomy data
     */
    disconnectedCallback() {
      if (this._subscription) {
        this._subscription();
      }
    }

    /**
     * perform search
     *
     * @param {object} searchParams search params
     */
    performSearch(searchParams) {
      this.dispatchEvent(new CustomEvent('search', { detail: { searchParams }, bubbles: true, composed: true }));
    }

    /**
     * Handles selecting a search filter node
     *
     * @param {event} evt onchange event
     * @private
     */
    handleFilterChange(evt) {
      const selectedFilter = evt.currentTarget.value;
      const selected = !this.filter.selectedFiltersList[selectedFilter];
      this.dispatchEvent(new CustomEvent('filterchange', {
        detail: {
          filterName: this.filter.name,
          filterId: selectedFilter,
          selected,
          isDraft: !!this.isDraft,
        },
        bubbles: true,
        composed: true,
      }));
    }

    /**
     * Handles changing select option
     *
     * @param {event} evt onclick event
     * @private
     */
    handleChangeSelect(evt) {
      const selectedOption = evt.currentTarget.value;
      if (this.isDraft) {
        this.dispatchEvent(new CustomEvent('filterchange', {
          detail: {
            filterName: this.filter.name,
            filterId: selectedOption,
            clearFilter: true, // does not support multiple select...
            selected: true,
            isDraft: true,
          },
          bubbles: true,
          composed: true,
        }));
      } else {
        // no analytics on filter change just change in keyword/clear all/category update
        this.performSearch({
          filters: {
            ...this.searchParams.filters,
            [this.filter.name]: [selectedOption],
          },
          page: 1,
        });
      }
    }

    /**
     * Handles opening modal for large data filter nodes using keys
     *
     * @param {event} evt onkeydown event
     * @private
     */
    handleOpenModalAccessibility(evt) {
      if (evt.code === 'Enter') {
        this.helperOpenModal(evt);
      }
    }

    /**
     * Handles opening modal for large data filter nodes
     *
     * @param {event} evt onclick event
     * @private
     */
    handleOpenModal(evt) {
      this.helperOpenModal(evt);
    }

    /**
     * Helps open modal for large data filter nodes
     * Dispatches custom 'openmodal' event
     *
     * @param {event} evt click or key event
     * @private
     */
    helperOpenModal(evt) {
      this.dispatchEvent(new CustomEvent('openmodal', {
        detail: { filterName: this.filter.name, modalData: evt.currentTarget.dataset.modalData },
      }));
    }

    /**
     * Handles toggling expansion of large data filter node using keys
     *
     * @param {event} evt onkeydown event
     * @private
     */
    handleToggleExpandFilterAccessibility(evt) {
      if (evt.code === 'Enter') {
        this.helperToggleExpandFilter(evt);
      }
    }

    /**
     * Handles toggling expansion of large data filter node
     *
     * @param {event} evt onclick event
     * @private
     */
    handleToggleExpandFilter(evt) {
      this.helperToggleExpandFilter(evt);
    }

    /**
     * Helps toggle expansion of large data filter node
     *
     * @param {event} evt click or key event
     * @private
     */
    helperToggleExpandFilter(evt) {
      const { key } = evt.currentTarget.dataset;
      const expanded = evt.currentTarget.dataset.expanded === 'true';
      this.expanded = { ...this.expanded, [key]: !expanded };
    }

    /**
     * Handle select or deselect all for large-data view using keys
     *
     * @param {event} evt onkey down event
     * @private
     */
    handleSelectOrDeselectAllAccessibility(evt) { // logic here is only for large-data view
      if (evt.code === 'Enter') {
        this.helperSelectOrDeselectAll(evt);
      }
    }

    /**
     * Handle select or deselect all for large-data view
     *
     * @param {event} evt onclick event
     * @private
     */
    handleSelectOrDeselectAll(evt) {
      this.helperSelectOrDeselectAll(evt);
    }

    /**
     * Helps recursively select or deselect all filter nodes for large-data view
     *
     * @param {event} evt click or key event
     * @private
     */
    helperSelectOrDeselectAll(evt) {
      const { filterId } = evt.currentTarget.dataset;
      const { action } = evt.currentTarget.dataset;
      // checks self immediately for better UI
      if (action === 'select') {
        this.template.querySelector(`lightning-input[data-filter-id="${filterId}"]`).checked = true;
      }

      this.dispatchEvent(new CustomEvent('filterchange', {
        detail: {
          filterName: this.filter.name,
          filterId,
          selected: action === 'select',
          all: true,
          isDraft: !!this.isDraft,
          renderModalSpinner: true,
        },
        bubbles: true,
        composed: true,
      }));
    }
}
export default IpaSearchFilterNode;