/* eslint-disable no-console */
import { LightningElement, api, wire } from 'lwc';
import fetchLookupData from '@salesforce/apex/PSS_PartnersOnSolution.fetchLookupData';
// import search from '@salesforce/apex/PSS_ReusableSearchController.fetchSearchData';

const DELAY = 300;


/** A component used to retrieve the records based on Object, fields and Searchkey.
 *
 * This component is reusable component.
 *
 * @example
 * <!-- HTML component -->
 * <c-pss-search-component
 *              obj-name="Contact"
 *               icon-name="standard:contact"
 *               label-name="Contact"
 *               placeholder="Search"
 *               fields={fields}
 *               display-fields={displayFields}
 *               onlookup={handleLookup} >
 *   </c-pss-search-component>
 *
 * @augments NavigationMixin
 * @augments LightningElement
 */
export default class PssSearchComponent extends LightningElement {
  // @api objName;

  // @api iconName;

  // @api labelName;

  // @api placeholder = 'Search';

  // @api fields = ['Name'];

  // @api displayFields;

  // searchRecords;

  // selectedRecord;

  // objectLabel;

  // isLoading = false;

  // field;

  // field1;

  // field2;

  @api label = 'custom lookup label';

  @api placeholder = 'search...';

  @api iconName = 'standard:account';

  @api sObjectApiName = 'Account';

  @api defaultRecordId = '';

  // private properties
  lstResult = []; // to store list of returned records

  hasRecords = true;

  searchKey=''; // to store input field value

  isSearchLoading = false; // to control loading spinner

  delayTimeout;

  selectedRecord = {}; // to store selected lookup record in object formate

  /**
   * Wire method to get the status of the current record from Solution Object.
   *
   * @param {object} result  The result from the wire service.
   * @param {object} result.error  The error object returned from the wire service.
   * @param {object} result.data  The data object returned from the wire service.
   *
   * @private
   */
  @wire(fetchLookupData, { searchKey: '$searchKey', sObjectApiName: '$sObjectApiName' })
  searchResult({ data, error }) {
    // const { data, error } = value; // destructure the provisioned value
    this.isSearchLoading = false;
    if (data) {
      this.hasRecords = data.length !== 0;
      console.log(`data from wire method :${JSON.stringify(data)}`);
      this.lstResult = JSON.parse(JSON.stringify(data));
    } else if (error) {
      console.log(`(error---> ${JSON.stringify(error)}`);
    }
  }

  /**
   * update searchKey property on input field change
   *
   * @param {event} event keychange event
   * @private
   */
  handleKeyChange(event) {
    // Debouncing this method: Do not update the reactive property as long as this function is
    // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
    this.isSearchLoading = true;
    window.clearTimeout(this.delayTimeout);
    const searchKey = event.target.value;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.delayTimeout = setTimeout(() => {
      this.searchKey = searchKey;
    }, DELAY);
  }

  /**
   * method to toggle lookup result section on UI
   *
   * @param {event} event toggle event
   * @private
   */
  toggleResult(event) {
    const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
    const clsList = lookupInputContainer.classList;
    const whichEvent = event.target.getAttribute('data-source');
    // eslint-disable-next-line default-case
    switch (whichEvent) {
      case 'searchInputField':
        clsList.add('slds-is-open');
        break;
      case 'lookupContainer':
        clsList.remove('slds-is-open');
        break;
    }
  }

  /**
   * method to clear selected lookup record
   *
   * @private
   */
  handleRemove() {
    this.searchKey = '';
    this.selectedRecord = {};
    this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function

    // remove selected pill and display input field again
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
    searchBoxWrapper.classList.remove('slds-hide');
    searchBoxWrapper.classList.add('slds-show');
    const pillDiv = this.template.querySelector('.pillDiv');
    pillDiv.classList.remove('slds-show');
    pillDiv.classList.add('slds-hide');
  }

  /**
   * method to update selected record from search result
   *
   * @param {event} event select event
   * @private
   */
  handelSelectedRecord(event) {
    const objId = event.target.getAttribute('data-recid'); // get selected record Id
    this.selectedRecord = this.lstResult.find((data) => data.Id === objId); // find selected record from list
    this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function
    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
  }

  /* */
  /**
   * COMMON HELPER METHOD STARTED
   *
   * @private
   */
  handelSelectRecordHelper() {
    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
    searchBoxWrapper.classList.remove('slds-show');
    searchBoxWrapper.classList.add('slds-hide');
    const pillDiv = this.template.querySelector('.pillDiv');
    pillDiv.classList.remove('slds-hide');
    pillDiv.classList.add('slds-show');
  }

  /**
   * send selected lookup record to parent component using custom event
   *
   * @param {string} value value to dispatch to parent component.
   * @private
   */
  lookupUpdatehandler(value) {
    const oEvent = new CustomEvent('lookupupdate',
      {
        detail: { selectedRecord: value },
      });
    this.dispatchEvent(oEvent);
  }

  /**
   * Method to get the related data on load of the component.
   *
   * @private
   */
  /* connectedCallback() {
      console.log(`object Name: ${JSON.stringify(this.objName)}`);
      if (this.objName.includes('__c')) {
        const obj = this.objName.substring(0, this.objName.length - 3);
        this.objectLabel = obj.replaceAll('_', ' ');
      } else {
        this.objectLabel = this.objName;
      }
      this.objectLabel = this.titleCase(this.objectLabel);
      console.log(`object Label: ${JSON.stringify(this.objectLabel)}`);
      let fieldList;
      if (!Array.isArray(this.displayFields)) {
        fieldList = this.displayFields.split(',');
      } else {
        fieldList = this.displayFields;
      }

      if (fieldList.length > 1) {
        this.field = fieldList[0].trim();
        this.field1 = fieldList[1].trim();
      }
      if (fieldList.length > 2) {
        this.field2 = fieldList[2].trim();
      }

      const combinedFields = [];
      fieldList.forEach((field) => {
        if (!this.fields.includes(field.trim())) {
          combinedFields.push(field.trim());
        }
      });

      // eslint-disable-next-line @lwc/lwc/no-api-reassignments
      this.fields = combinedFields.concat(JSON.parse(JSON.stringify(this.fields)));
      console.log(`fields :${JSON.stringify(this.fields)}`);
    }

    /**
     * Method to retrieve the records from the sObject based on the search keyword.
     *
     * @param {object} event selected value in the text box is given as parameter
     * @private
     */
  /* handleInputChange(event) {
      window.clearTimeout(this.delayTimeout);
      const searchKey = event.target.value;
      // this.isLoading = true;
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.delayTimeout = setTimeout(() => {
        if (searchKey.length >= 2) {
          search({
            objectName: this.objName,
            fieldName: this.fields,
            searchKeyWord: searchKey,
          })
            .then((result) => {
              console.log(`result data :${JSON.stringify(result)}`);
              const stringResult = JSON.stringify(result);
              const allResult = JSON.parse(stringResult);
              console.log(`parsed data :${JSON.stringify(allResult)}`);
              allResult.forEach((record) => {
                const resultRecord = record;
                resultRecord.FIELD1 = record[this.field];
                resultRecord.FIELD2 = record[this.field1];
                if (this.field2) {
                  resultRecord.FIELD3 = record[this.field2];
                } else {
                  resultRecord.FIELD3 = '';
                }
              });
              this.searchRecords = allResult;
            })
            .catch((error) => {
              console.error('Error:', error);
            })
            .finally(() => {
              // this.isLoading = false;
            });
        }
      }, DELAY);
    }

    /**
     * Method to convert the string to lowercase
     *
     * @param {string} string string which will converted to lowercase.
     * @returns {string} the lowercase os given string
     */
  /* titleCase(string) {
      const sentence = string.toLowerCase().split(' ');
      for (let i = 0; i < sentence.length; i += 1) {
        sentence[i] = sentence[i][0].toUpperCase() + sentence[i].slice(1);
      }
      return sentence;
    } */
}