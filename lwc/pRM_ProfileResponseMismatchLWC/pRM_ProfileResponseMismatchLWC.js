import { LightningElement, track, api } from 'lwc';
import getOnePartnerIds from '@salesforce/apex/PRM_ProfileReponseMismatchReport.getOnePartnerIds';
import getProfileResponse from '@salesforce/apex/PRM_ProfileReponseMismatchReport.getProfileResponse';
import prevBtn from '@salesforce/label/c.PRM_Previous_Button';
import nextBtn from '@salesforce/label/c.PRM_Next_Button';

export default class PRM_ProfileResponseMismatchLWC extends LightningElement {

    @track prevBtnLbl = prevBtn;
    @track nextBtnLbl = nextBtn;
    @track recordIds;
    @track clearData = [];
    @track locationAccountsResponses = [];
    @track onePartnerResponses = [];
    @track tableData = [];
    @api pagesize = 5;
    @api reportdatasetname;
    @api reportname;
    @track hasData = false;
    @api deactivate = false;
    @track currentpage = 1;
    @track noOfPages = 0;
    @track startIndex = 0;
    @track endIndex = 200;
    @track counter = 0;
    @track noOfBatches = 0;
    @track spinner = true;
    @track noMismatchFlag = false;
    @track progressPercentage = 0;
    @track allrecordProcessed = false;
    @track dataSet = [];
    @track sortedDirection = 'asc'
    @track sortedBy;
    @track searchFilter = false;
    @track fields = [];
    @api columns;
    @track recordPresent = true;
    @track searchVal;

    connectedCallback() {
        if (this.columns !== null && this.columns !== undefined) {
            this.fields = JSON.parse(this.columns);
        }
        console.log('Columns :', this.fields);
        this.getOnePartnerIds();
    }

    getOnePartnerIds() {
        getOnePartnerIds()
            .then(res => {
                if (res !== undefined && res !== null) {
                    this.recordIds = res;
                    if (this.recordIds !== null && this.recordIds !== undefined && this.recordIds.length > 0) {
                        this.noOfBatches = Math.ceil(this.recordIds.length / 200);
                        this.getProfileResponses(this.recordIds.slice(this.startIndex, this.endIndex));
                    }
                }
            })
            .catch(error => {
                console.log('Error -->' + error);
            })
    }


    getProfileResponses(result) {
        console.log('slice ids -->', result);
        console.log('one -->', this.onePartnerResponses);
        getProfileResponse({ accountIds: result })
            .then(res => {
                console.log('Result -->', res);
                for (const key in res) {
                    if (res[key].locationAccountResponse !== null && res[key].locationAccountResponse !== undefined) {

                        let resultRecord = res[key].onePartnerResponse;
                        let onePartnerObject = {};
                        onePartnerObject.accountId = resultRecord.accountId;
                        onePartnerObject.accountName = resultRecord.accountName;
                        onePartnerObject.recordTypeName = resultRecord.recordTypeName;
                        onePartnerObject.brandedPtsEarningExl = resultRecord.brandedPtsEarningExl;
                        onePartnerObject.cmpPtsEarningExl = resultRecord.cmpPtsEarningExl;
                        onePartnerObject.odmWhiteboxPtsEarningExl = resultRecord.odmWhiteboxPtsEarningExl;
                        onePartnerObject.ptsNotEligible = resultRecord.ptsNotEligible;
                        onePartnerObject.ptsOptIn = resultRecord.ptsOptIn;
                        onePartnerObject.onePartnerId = resultRecord.onePartnerId;
                        onePartnerObject.onePartnerName = resultRecord.onePartnerName;
                        this.dataSet.push(onePartnerObject);

                        res[key].locationAccountResponse.map(item => {
                            let objData = {};
                            objData.accountId = item.accountId;
                            objData.accountName = item.accountName;
                            objData.recordTypeName = item.recordTypeName;
                            objData.brandedPtsEarningExl = item.brandedPtsEarningExl;
                            objData.cmpPtsEarningExl = item.cmpPtsEarningExl;
                            objData.odmWhiteboxPtsEarningExl = item.odmWhiteboxPtsEarningExl;
                            objData.ptsNotEligible = item.ptsNotEligible;
                            objData.ptsOptIn = item.ptsOptIn;
                            objData.onePartnerId = item.onePartnerId;
                            objData.onePartnerName = item.onePartnerName;
                            this.dataSet.push(objData);
                        })
                        // this.dataSet.push(res[key].locationAccountResponse);
                        res[key].onePartnerResponse.iconName = 'utility:chevronright';
                        this.onePartnerResponses.push(res[key].onePartnerResponse);

                        // this.onePartnerResponses.push(res[key].onePartnerResponse);
                        this.locationAccountsResponses.push({ Id: key, data: res[key].locationAccountResponse });
                    }
                }
                this.locationAccountsResponses = JSON.parse(JSON.stringify(this.locationAccountsResponses));
                this.onePartnerResponses = JSON.parse(JSON.stringify(this.onePartnerResponses));
                //this.tableData = this.onePartnerResponses;
                console.log('Table Data --> ' + this.counter, this.tableData);
                this.noOfPages = Math.ceil(this.onePartnerResponses.length / this.pagesize);
                if (this.onePartnerResponses.length > 0) {
                    this.hasData = true;
                    this.spinner = false;
                }
                console.log('Location Accounts Map -->', this.locationAccountsResponses);
                console.log('One Partner Responses -->', this.onePartnerResponses);
                this.counter += 1;
                this.startIndex = this.endIndex + 1;
                this.endIndex = (this.startIndex + 200 > this.recordIds.length) ? this.recordIds.length : this.startIndex + 200;
                console.log('Records ids -->', this.recordIds);
                console.log('');
                if (this.counter <= this.noOfBatches) {
                    this.getProfileResponses(this.recordIds.slice(this.startIndex, this.endIndex));
                    this.progressPercentage = (this.counter / this.noOfBatches) * 100;
                    this.allrecordProcessed = this.progressPercentage === 100 ? true : false;

                }
                this.noMismatchFlag = this.onePartnerResponses.length > 0 ? false : true;
                this.getCurrentPageRecords();
            })
            .catch(error => {
                this.spinner = false;
                this.hasData = false;
                console.log('Error -->', error);
            })

    }

    handlerowaction(evt) {
        let cloned = JSON.parse(JSON.stringify(this.tableData));
        let row = evt.detail.row;
        let action = row.iconName === 'utility:chevronright' ? 'Expand' : 'Collapse';
        if (row.iconName === 'utility:chevronright') {
            row.iconName = 'utility:chevrondown';
        } else {
            row.iconName = 'utility:chevronright';
        }


        console.log('action -->', evt.detail.action.iconName);
        console.log('log -->', JSON.stringify(evt.detail.row));
        const index = this.tableData.findIndex(item => item.accountId === evt.detail.row.accountId);

        console.log(' -->', this.locationAccountsResponses);
        if (action === 'Expand') {
            this.locationAccountsResponses.map(item => {
                if (item.Id === evt.detail.row.accountId) {
                    console.log('Match', item.data);

                    item.data.map(locItem => {
                        locItem.disableIcon = true;
                        cloned.splice(index + 1, 0, locItem);
                    })

                }
            })
        }
        if (action === 'Collapse') {
            let counter = 0;
            this.locationAccountsResponses.map(item => {
                if (item.Id === evt.detail.row.accountId) {
                    counter += item.data.length;
                }
            })
            cloned.splice(index + 1, counter);
        }
        cloned[index] = row;
        this.tableData = [];
        this.tableData = cloned;
    }
    handleNext() {
        if (this.currentpage < this.noOfPages) {
            this.currentpage += 1;
            this.getCurrentPageRecords();
        }
    }

    handlePrevious() {
        if (this.currentpage >= this.noOfPages || this.currentpage > 1) {
            this.currentpage -= 1;
            this.getCurrentPageRecords();
        }

    }

    getCurrentPageRecords() {
        console.log('indese 167');
        this.tableData = [];
        let start = parseInt((this.currentpage - 1) * this.pagesize);
        let end = parseInt(start) + parseInt(this.pagesize);
        let copy = this.onePartnerResponses.slice(start, end);
        copy.map(item => {
            item.iconName = 'utility:chevronright';
            this.tableData.push(item);
        });

        this.loadMore = (this.currentpage > 1 && this.noOfPages <= this.currentpage) ? true : false;
        this.loadPrev = (this.currentpage === 1) ? true : false;
        this.showingOfTotal = (this.currentpage === this.noOfPages) ? this.onePartnerResponses.length : this.currentpage * this.pagesize;
    }

    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortData(fieldName === 'accountURL' ? 'accountName' : fieldName, sortDirection);
        // === 'asc' ? 'desc' : 'asc';

        console.log('110 -->' + this.tableData);
    }

    sortData(fieldname, direction) {
        let parseData = this.onePartnerResponses;//JSON.parse(JSON.stringify());
        this.tableData = [];
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // return parseData;
        // this.tableData = [];
        this.tableData = [...parseData];
        this.onePartnerResponses = this.tableData;
        this.getCurrentPageRecords();
        this.sortedDirection = direction;
        // console.log('Parsed data -->', this.tableData);
    }

    handleChange(event) {
        console.log('event ', event.target.value);
        if (event.target.value.length >= 3 && event.target.value.length > 0) {
            this.searchVal = event.target.value;
            this.searchFilter = true;
            this.search(event.target.value.trim());
        }
        if (event.target.value.length === 0) {
            this.clearFilter();
        }

    }

    search(key) {
        let copy = JSON.parse(JSON.stringify(this.onePartnerResponses));
        let filtereResult = [];
        copy.map(item => {
            let actName = item.accountName.toLowerCase();
            // console.log('includes key', actName.includes(key.toL     owerCase()));
            if (actName.includes(key.toLowerCase())) {
                filtereResult.push(item);
            }
        });
        if (filtereResult.length > 0) {
            this.recordPresent = true;
            this.tableData = [];
            this.tableData = filtereResult;
        }else{
            this.recordPresent = false;
            this.tableData = [];
        }
        // console.log('Filtred data -->', filtereResult);

    }

    clearFilter() {
        this.searchFilter = false;
        this.tableData = [];
        this.tableData = this.onePartnerResponsesy;
        this.getCurrentPageRecords();
        console.log('tableData -->', this.tableData);
    }

}