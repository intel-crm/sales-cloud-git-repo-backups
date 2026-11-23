import { LightningElement, track, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import eventspagemessagechannel from '@salesforce/messageChannel/ipaSearchFiltersMessageChannel__c';
import getTechTaxonomy from '@salesforce/apex/PMP_RefineFilterController.getRefineFilterTaxonomies';
import langLocale from '@salesforce/i18n/lang';
import { handleError } from 'c/ipaErrorServiceMarketplace';

//Custom Labels
import RefineLabel from '@salesforce/label/c.IPA_Refine';
import searchboxLabel from '@salesforce/label/c.PMP_Search_SearchResults';
import clearall from '@salesforce/label/c.PMP_Clear_All_Filters';
import filtersapplied from '@salesforce/label/c.PMP_FiltersApplied';


/** Documentation for Refine Filter Component
 * <br>This is the parent component of the following components:<br>
 * <ul><li>{@link c/ipamultiSelectPickList}</li>
 * <li>{@link c/ipaPicklistValue}</li>
 *
 * @property {string} taxonomy this is the comma separated list of pim spec id used to generate filters on UI
 * @property {boolean} [separatorAbove] show separator above component
 * @property {boolean} [separatorBelow] show separator below component
 * @property {boolean} [paddingAbove] add padding above component
 * @property {boolean} [paddingBelow] add padding below component
 */
export default class App extends LightningElement {
    @api taxonomy;

    @api separatorAbove;

    @api separatorBelow;

    @api paddingAbove;

    @api paddingBelow;

    /**
     * Keeps track of the keyword entered by the user in the searchbox
     *
     * @type {String}
     * @private
     */
    keyWordEntered = '';

    /**
    * The Refine Button Label
    *
    * @type {String}
    * @private
    */
    Reflabel = '';

    /**
    * The Search box placeholder value
    *
    * @type {String}
    * @private
    */
    searchlabel = '';

    /**
    * Clear All filters label
    *
    * @type {String}
    * @private
    */
    clearallfilters = '';

    /**
    * Filters Applied: label
    *
    * @type {String}
    * @private
    */
    filtersapp = '';

    /**
     * Keeps track of selected values from the filters
     *
     * @type {object}
     * @private
     */
    @track selections = [];

    /**
     * Keeps track of selected category id from the filters
     *
     * @type {object}
     * @private
     */
    @track selectedtcat = [];

    /**
     * Keeps track of selected specifications id from the filters
     *
     * @type {object}
     * @private
     */
    @track selectedtspec = [];

    /**
     * Keeps track of selected specification values id from the filters
     *
     * @type {object}
     * @private
     */
    @track selectedtspecval = [];

    /**
     * If true, the pills sections will be displayed
     *
     * @type {boolean}
     * @private
     */
    @track showpills = false;

    /**
     * If true, the filter section will be displayed
     *
     * @type {boolean}
     * @private
     */
    @track showfilters = false;

    /**
     * Keeps track of values to be removed when unselect event is fired
     *
     * @type {object}
     * @private
     */
    @track removeselarray = [];

    /**
     * Keeps all the filers options in an array each position will have an array of options related to each filter
     *
     * @type {object}
     * @private
     */
    @track looparray = [];

    /**
     * If true, the search keyword is shown as pill
     *
     * @type {boolean}
     * @private
     */
    @track showsearchinputpill = false;

    @wire(MessageContext)
    messageContext;

    /**
     * Custom labels
     *
     * @type {object}
     * @private
     */
    labels = {
        RefineLabel,
        searchboxLabel,
        clearall,
        filtersapplied,
    };

    /**
     * Connected callback - subscribes to refine filter taxonomies
     *
     * @private
     */
    connectedCallback() {
        this.techtaxonomies();
        this.Reflabel = RefineLabel;
        this.searchlabel = searchboxLabel;
        this.clearallfilters = clearall;
        this.filtersapp = filtersapplied;
    }

    /**
     * If keyword is entered, dispatch to redux to set new keywordValue.
     *
     * @param {event} event onkeywordinput event
     * @private
     */
    handleSearchByKeyword(event) {
        if(event.detail.keywordValue.length > 2 || event.detail.keywordValue.length === 0) {
            if(event.detail.keywordValue.length > 2) {
                this.showpills = true;
                this.showsearchinputpill = true;
            } else if (event.detail.keywordValue.length === 0) {
                this.showsearchinputpill = false;
                if(this.selectedtcat.length===0 && this.selectedtspec.length===0 && this.selectedtspecval.length===0 && this.showpills === true) {
                    this.showpills = false;
                }
            }
            this.keyWordEntered = event.detail.keywordValue;
            if (!this._preventKeywordSearch) {
                this.publishPayload();
              } else {
                this._preventKeywordSearch = false;
              }
        }
    }

    /**
     * Clears search keyword and makes analytics call on results response with clear keyword
     *
     * @private
     */
    helperClearKeyword() {
        this.keyWordEntered = '';
        this.showsearchinputpill = false;
        if(this.selectedtcat.length===0 && this.selectedtspec.length===0 && this.selectedtspecval.length===0 && this.showpills === true) {
             this.showpills = false;
        }
        this.publishPayload();
    }

    /**
     * Handle Search on Icon Click
     *
     * @param {event} evt onclick event
     * @private
     */
    handleSearchButtonClick(evt) {
        evt.preventDefault();
        this.handleSearchByKeyword();
    }

    /**
    * Calls the apex method with the taxonomy data from the builder
    *
    * @param {String} userlanguage code
    * @param {object} taxonomy data in an array by splitting the comma separated values
    * @private
    */
    async techtaxonomies() {
        let langCode = langLocale;
        let userLanguage = '';
        if (langLocale.includes('-')) { //check for undefined or null exceptions
            langCode = langLocale.replaceAll('-', '_');
        }
        if (langCode === 'zh_Hans_CN' || langCode === 'zh_CN') {
            userLanguage = 'zh_CN';
        } else if (langCode === 'ja' || langCode === 'jp') {
            userLanguage = 'ja';
        } else {
            userLanguage = 'en_US';
        }
        var taxarray = this.taxonomy.split(',');
        await getTechTaxonomy({ langCode: userLanguage, refineFilters: taxarray })
            .then((result) => {
                for (let key in result) {
                    if (result.hasOwnProperty(key)) {
                        if (taxarray.includes(result[key].PimId)) {
                            const procobj = result[key].records;
                            const taxlabel = result[key].label;
                            const taxname = result[key].PimId;
                            let valarray = [];
                            for (let key in procobj) {
                                if (procobj.hasOwnProperty(key)) {
                                    let procsarry = {
                                        label: taxlabel, value: procobj[key].label, selected: false, id: procobj[key].id,
                                        objname: procobj[key].objectname
                                    };
                                    valarray.push(procsarry);
                                }
                            }
                            let indx = taxarray.indexOf(taxname);
                            taxarray[indx] = valarray;
                        }
                    }
                }
                this.looparray = JSON.parse(JSON.stringify(taxarray));
            })
            .catch((error) => {
                handleError(error, 'ApexCalloutFailed-asyncTechTaxonomiesFunction');
            });
    }

    /**
    * Makes the showfilters boolean true/false
    * 
    * @private
    */
    showfiltersfunc() {
        this.showfilters = this.showfilters === true ? false : true;
    }

    /**
     * Handles the selected values, pushes them to arrays and updates boolean variables
     *
     * @private
     * @param {*} event
     */
    handleSelectedValues(event) {
        let selval = JSON.parse(JSON.stringify(event.detail.sevalues));
        let selid = JSON.parse(JSON.stringify(event.detail.sevalid));
        let selobj = JSON.parse(JSON.stringify(event.detail.obj));
        let pubpayloadcheck = false;
        if (selval.length > 0) {
            this.showpills = true;
            for (let i = 0; i < selval.length; i++) {
                if (!this.selections.includes(selval[i])) {
                    this.selections.push(selval[i]);
                    pubpayloadcheck = true;
                }
                if (selobj === 'PMP_Category__c') {
                    if (!this.selectedtcat.includes(selid[i])) {
                        this.selectedtcat.push(selid[i]);
                    }
                } else if (selobj === 'PMP_Specification__c') {
                    if (!this.selectedtspec.includes(selid[i])) {
                        this.selectedtspec.push(selid[i]);
                    }
                } else {
                    if (!this.selectedtspecval.includes(selid[i])) {
                        this.selectedtspecval.push(selid[i]);
                    }
                }
            }
            if (pubpayloadcheck) {
                this.publishPayload();
            }
        }
    }
    /**
     * Handles the removal values when unselect event is fired, pushes them to arrays and updates boolean variables
     *
     * @private
     * @param {*} event
     */
    handleremovalselection(event) {
        let remval = event.detail.remval;
        let remobj = event.detail.obj;
        let remid = event.detail.remid;
        if (remobj === 'PMP_Category__c') {
            if (this.selectedtcat.includes(remid)) {
                let pillIndex = this.selectedtcat.indexOf(remid);
                this.selectedtcat.splice(pillIndex, 1);
            }
        } else if (remobj === 'PMP_Specification__c') {
            if (this.selectedtspec.includes(remid)) {
                let pillIndex = this.selectedtspec.indexOf(remid);
                this.selectedtspec.splice(pillIndex, 1);
            }
        } else {
            if (this.selectedtspecval.includes(remid)) {
                let pillIndex = this.selectedtspecval.indexOf(remid);
                this.selectedtspecval.splice(pillIndex, 1);
            }
        }
        if (this.selections.includes(remval)) {
            let pillIndex = this.selections.indexOf(remval);
            this.selections.splice(pillIndex, 1);
            this.publishPayload();
        }
        if (this.selections.length === 0) {
            this.showpills = false;
        }
    }

    /**
     * Payload is published using the LWC message channel
     *
     * @private
     */
    publishPayload() {
        const payload = {
            KeyWord: this.keyWordEntered, CategoriesApplied: JSON.parse(JSON.stringify(this.selectedtcat)),
            SpecificationsApplied: JSON.parse(JSON.stringify(this.selectedtspec)),
             SpecificationValuesApplied: JSON.parse(JSON.stringify(this.selectedtspecval)),
        };
        console.log('the payload for publish is', payload);
        publish(this.messageContext, eventspagemessagechannel, payload);
    }

    /**
     * Clears all the selections on click of clear all filers option
     *
     * @private
     */
    clearallselections() {
        this.removeselarray = JSON.parse(JSON.stringify(this.selections));
        this.template.querySelectorAll('c-ipamulti-select-pick-list').forEach((element) => {
            element.clearselections();
        });
        this.keyWordEntered = '';
        this.selections = [];
        this.selectedtcat = [];
        this.selectedtspec = [];
        this.selectedtspecval = [];
        this.showpills = false;
        this.showsearchinputpill = false;
        this.publishPayload();
    }
}