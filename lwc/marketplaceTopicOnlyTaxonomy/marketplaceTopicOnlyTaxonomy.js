import { LightningElement, api } from 'lwc';
import { makeIpaAnalyticsCall } from 'c/ipaAnalyticsService';
//import getTopicTaxonomy from '@salesforce/apex/PMP_MarketplaceTopics.fetchTopicTaxonomy';

import metaTemplate from './marketplaceTopicOnlyTaxonomyList.html';
import template from './marketplaceTopicOnlyTaxonomy.html';

/**
 * A Taxonomy Record is a Hierarchical Tree-Like Node where records have N levels deep.
 *
 * @typedef TaxonomyRecord
 * @property {string} id Salesforce id of record
 * @property {string} parentId id of parent
 * @property {string} taxonomy unique id/name of taxonomy (ie. 'offeringCategories') to which the record belongs
 * @property {string} label display label
 * @property {string[]} children list of ids of child records
 * @property {boolean} [expandByDefault] 🗃 expand the filter by default on the L2 page
 * @property {boolean} [featured] 🗂 featured category (highlights Category in the Taxonomy List)
 * @property {string} [description] 🗂 category description
 * @property {string} [svgIconUrl] 🗂 category icon
 * @property {string} [learnMoreUrl] 🗂 "Learn More" url in Marquee on L2 Page
 * @property {string} [viewAllLabel] 🗂 category display label for "View all ... >" links
 * @property {object[]} [searchResultsGroupings] 🗂 ordered list of search results groupings (<b>ie. Distributor</b>)
 * @property {object[]} [searchFiltersGroupings] 🗃 OPTIONAL - Overwrites Grouping Level Value
 * <br>ordered list of search groupings & filters for L2 Search Category page
 * @property {Map<string, string[]>} [defaultFilters] 🗂 default value for filters (ie. { 'country': ['US'] })
 */

/**
 * Taxonomy
 *
 * @typedef Taxonomy
 * @property {string} name name of taxonomy <b>used as a unique id for search filtering</b>
 * @property {string} apiName api name of Salesforce object for linking
 * @property {string} label display name of the taxonomy ie. "Category", localized to current language
 * @property {string} viewAllLabel label for "View all ... >" links
 * @property {string} svgIconUrl icon
 * @property {string[]} topLevelIds a list of the first level of records by Salesforce Id
 * @property {string} [filterDisplayType] 📊 for custom filter display type, options:<ul><li><b>select</b> (ie. 'country')</li>
 * <br><li><b>large-data</b> (expandable & searchable, ie. 'processors')</li><li><b>partner-list</b> (only for 'partnerAZ')</li></ul>
 * @property {object[]} [searchFiltersGroupings] 🗄 ordered list of search groupings & filters for L2 Search Category page
 * @property {Map<id, TaxonomyRecord>} records a list of all records in the taxonomy
 */

/** Documentation for the Taxonomy List Component
 *
 * @property {string} taxonomy The api/unique/id 'name' of the taxonomy (ie. 'PartnerDirectory').
 * @property {string} limitRecordsValue Limit the number of records shown, can be 5/10/15/All.
 * @property {boolean} showFeaturedOnly This flag is only for category record lists that implement a 'featured' boolean flag.
 * <br>It works in conjunction with the limit. (ie. to show all featured, select 'All' from the limit dropdown, and check this 'featured' box.)
 * @property {boolean} listOfLists If set to true, this component will create ipaTaxonomyList components recursively for each of its children
 * @property {string} [recordId] Used for taxonomy lists that aren't top level (ie. L1 Pages).
 * @property {boolean} showIcon Show icon at top level heading.
 * @property {boolean} showHeading Show heading at top level.
 * @property {boolean} showViewAllLink Show the "View all ... >" link.
 * @property {string} viewAllCommunityPage View All Link Community Page (API Name).
 * @property {string} [cardStyle='No Icon'] Card style for {@link coreIntcSimpleCard coreIntcSimpleCard} component.
 * <br>Can be 'No Icon', 'Icon Horizontal', 'Icon Vertical', or 'Icon Body'.
 * @property {boolean} separatorAbove Shows a border separator above component.
 * @property {boolean} separatorBelow Shows a border separator below component.
 * @property {boolean} paddingAbove Adds padding above component.
 * @property {boolean} paddingBelow Adds padding below component.
 * @property {string} headingOverride Overrides dynamic heading from taxonomy data.
 * @property {string} theme Changes theme options... inverse or default.
 * @augments LightningElement
 */
class IpaTaxonomyList extends LightningElement {
    @api taxonomy = '';

    @api listOfLists;

    @api limitRecordsValue;

    @api recordId = '';

    @api showFeaturedOnly;

    @api showIcon;

    @api showHeading;

    @api showViewAllLink;

    @api viewAllCommunityPage;

    @api cardStyle = 'No Icon';

    @api separatorAbove;

    @api separatorBelow;

    @api paddingAbove;

    @api paddingBelow;

    @api headingOverride = '';

    @api theme;

    /**
     * Returns classes for HTML markup
     *
     * @returns {string} classes
     * @private
     */
    get classes() {
      return [
        ' ',
        (this.theme === 'inverse' ? ' color-white inverse' : ' '),
      ].join(' ');
    }

    /**
     * Return classes for taxonomy heading
     *
     * @returns {string} classes
     * @private
     */
    get headingClasses() {
      return [
        'h4',
        (this.theme === 'inverse' ? ' color-white inverse' : ' '),
      ].join(' ');
    }

    /**
     * If header should be shown
     *
     * @returns {boolean} header shown
     * @private
     */
    get showHeader() {
      return !!((this.showIcon || this.showHeading || this.showViewAllLink));
    }

    /**
     * Returns URL of icon
     *
     * @returns {string} icon url
     * @private
     */
    get icon() {
      if (this.recordId) return this.records[this.recordId].svgIconUrl;
      return this.taxonomyData.svgIconUrl;
    }

    /**
     * Returns heading to be displayed in HTML Markup
     *
     * @returns {string} heading
     * @private
     */
    get heading() {
      if (this.headingOverride) return this.headingOverride;
      if (this.recordId) return this.records[this.recordId].label;
      return this.taxonomyData.label;
    }

    /**
     * Returns records in taxonomy data
     *
     * @returns {TaxonomyRecord} records
     * @private
     */
    get records() {
      return this.taxonomyData.records;
    }

    /**
     * Returns label for view all link
     *
     * @returns {string} label
     * @private
     */
    get viewAllLabel() {
      return this.recordId ? this.records[this.recordId].viewAllLabel : this.taxonomyData.viewAllLabel;
    }

    /**
     * Returns array of records to displayed in card list
     *
     * @returns {object[]} array of records
     * @private
     */
    get listRecords() {
      let records = [];
      if (this.recordId) {
        records = this.records[this.recordId].children.map((id) => this.records[id]);
      } else {
        records = this.taxonomyData.topLevelIds.map((id) => this.records[id]);
      }
      if (this.showFeaturedOnly) records = records.filter((rec) => rec.featured);
      return this.limitRecordsValue !== 'All' ? records.slice(0, this.limitRecordsValue) : records;
    }

    /**
     * Returns object with properties defining the "view all" link
     *
     * @returns {object} view all link
     * @private
     */
    get viewAllLink() {
      return {
        communityPage: this.recordId ? null : this.viewAllCommunityPage,
        objectPage: this.recordId ? this.taxonomyData.apiName : null,
        recordId: this.recordId,
        label: this.viewAllLabel,
      };
    }

    /**
     * Returns array of card objects
     *
     * @returns {object[]} array of cards
     * @private
     */
    get cardListData() {
      return this.listRecords.map((record) => ({
        title: record.label,
        svgIconUrl: record.svgIconUrl,
        description: record.description,
        linkData: {
          label: record.viewAllLabel,
          objectPage: this.taxonomyData.apiName,
          recordId: record.id,
        },
      }));
    }

    /**
     * Returns number of columns of cards to be displayed
     *
     * @returns {number} columns of cards
     * @private
     */
    get cardListDesktopCols() {
      if (this.cardStyle === 'Icon Body' || this.cardStyle === 'Icon Horizontal') return 3;
      return 5;
    }

    /**
     * Is component loading
     *
     * @type {boolean}
     * @private
     */
    loading;

    /**
     * Connected callback - subscribes to taxonomy data
     *
     * @private
     */
//IPA2.0:TWC729-8114 Topics Removal/Event Removal
//    connectedCallback() {
//      if (!this.taxonomy) throw new Error('Taxonomy is a required design attribute!');
//      this.loading = true;
//     getTopicTaxonomy().then((result) => {
//        this.taxonomyData = result[this.taxonomy];
//        if (!this.taxonomyData) {
//            throw new Error(`Taxonomy Data loaded, but missing taxonomy: ${this.taxonomy}`);
//          }
//          this.loading = false;
//    })
//    .catch((error) => {
//        throw error;
//    });
//    }

    /**
     * Unsubscribes from taxonomy data
     *
     * @private
     */
    disconnectedCallback() {
     /*  if (this._subscription) {
        //this._subscription();
      } */
    }

    /**
     * Returns component
     *
     * @returns {string} HTML Markup of component
     * @private
     */
    render() {
      return this.listOfLists ? metaTemplate : template;
    }


    /**
     * Creates a data object based on the CTA link's properties and sends that
     * to the analytics library to be logged.
     *
     * @param {object} linkClickEvent  The corelinkclick event thrown by the coreIntcLink in coreIntcCtaBar.
     * @private
     */
    handleLinkClick(linkClickEvent) {
      // Create the parameters for the analytics post
      const messageData = {
        analyticsType: 'click',
        element: '',
        pageTitle: linkClickEvent.detail.label || '',
        targetURL: linkClickEvent.detail.href || '',
      };

      // The event should not be needed above this in the hierarchy
      linkClickEvent.stopPropagation();

      // Call the helper library to log the analytics data
      makeIpaAnalyticsCall(messageData);
    }
}
export default IpaTaxonomyList;