import { LightningElement,wire, api, track } from 'lwc';
import getCases from "@salesforce/apex/core_IPS_AdvanceSearch.getCases";
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { getPicklistValues } from "lightning/uiObjectInfoApi";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import PRIORITY_FIELD from "@salesforce/schema/Case.Priority";


export default class Core_IPS_AdvanceSearch_LWC extends LightningElement {
    
    @track data;
    searchable = [];
    wiredCaseCount;
    wiredCases;

    doneTypingInterval = 0;
    statusPickListValues;
    

    searchAllValue;

    caseNumber = "";
    productName = "";
    referenceid="";
     status = null;
  

    displayTable=false;

    @wire(getCases, {
        caseNumber: "$caseNumber",
        referenceId: "$referenceid",
        productName: "$productName",
        status: "$status",
       
    })
    wiredSObjects(result) {
        console.log("wire getting called");
        this.wiredCases = result;
        if (result.data) {
            this.searchable = this.data = result.data.map((caseObj, index) => ({
                caseData: { ...caseObj },
                index: index + 1,
                rowIndex: index
            }));
        } else if (result.error) {
            console.error("Error", error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "012000000000000AAA",
        fieldApiName: STATUS_FIELD
    })
    statusPickLists({ error, data }) {
        if (error) {
            console.error("error", error);
        } else if (data) {
            this.statusPickListValues = [
                { label: "All", value: null },
                ...data.values
            ];
        }
    }



    handleChange(event) {
        this[event.target.name] = event.target.value;
        console.log("change", this[event.target.name]);
        this.displayTable=false;
    }

    handleKeyUp(event) {
        clearTimeout(this.typingTimer);
        let value = event.target.value;
        let name = event.target.name;

        this.typingTimer = setTimeout(() => {
            this[name] = value;
        }, this.doneTypingInterval);
        this.displayTable=false;
    }

    clearSearch() {
        this.caseNumber = "";
        this.accountName = "";
        this.productName = "";
        this.subject = "";
        this.status = null;
        this.priority = null;
        this.searchable = this.data;
        this.searchAllValue = "";
        this.searchAll();
    }

    handleSearchAll(event) {
        this.searchAllValue = event.target.value;
        this.searchAll();
        this.displayTable=false;
    }

    searchAll() {
        let searchStr = this.searchAllValue.toLowerCase();
        const regex = new RegExp(
            "(^" + searchStr + ")|(." + searchStr + ")|(" + searchStr + "$)"
        );
       
            this.searchable = this.data.filter((item) => {
                if (
                    regex.test(
                        item.caseData.CaseNumber.toLowerCase() +
                            " " +
                            item.caseData.CaseNumber.toLowerCase()
                    ) ||
                    regex.test(
                        item.caseData.Status?.toLowerCase() +
                            " " +
                            item.caseData.Status?.toLowerCase()
                    ) ||
                    regex.test(
                        item.caseData.Subject?.toLowerCase() +
                            " " +
                            item.caseData.Subject?.toLowerCase()
                    ) ||
                    regex.test(
                        item.caseData.Account?.Name?.toLowerCase() +
                            " " +
                            item.caseData.Account?.Name?.toLowerCase()
                    ) ||
                    regex.test(
                        item.caseData.Contact?.Name?.toLowerCase() +
                            " " +
                            item.caseData.Contact?.Name?.toLowerCase()
                    ) ||
                    regex.test(
                        item.caseData.Priority?.toLowerCase() +
                            " " +
                            item.caseData.Priority?.toLowerCase()
                    )
                ) {
                    return item;
                }
            });
        
        console.log(this.searchable);
    }

    handleNavigate(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                actionName: "view",
                recordId: event.target.dataset.id
            }
        });
    }
    handleSearchKeyword(){
    this.displayTable=true;
    }
}