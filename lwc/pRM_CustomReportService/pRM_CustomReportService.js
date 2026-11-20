import { LightningElement, track, api, wire } from 'lwc';
import getAccountsAndBenefits from '@salesforce/apex/PRM_BenefitMisMatchReport.getAccountsAndBenefits';
import requiredBenefits from '@salesforce/apex/PRM_BenefitMisMatchReport.getRequiredBenefits';
import getAccountIds from '@salesforce/apex/PRM_BenefitMisMatchReport.getAccountIds';
import prevBtn from '@salesforce/label/c.PRM_Previous_Button';
import nextBtn from '@salesforce/label/c.PRM_Next_Button';


export default class PRM_CustomReportService extends LightningElement {
    nextBtnLbl = nextBtn;
    prevBtnLbl = prevBtn;
    loadMore = false;
    loadPrev = false;
    currentpage = 1;
    showingOfTotal;
    noOfPages = 1;
    @track tableData = [];
    @api pagesize;
    @api reportdatasetname;
    @api reportname;
    record = [];
    @track hasData = false;
    @track sortedDirection = 'asc';
    @track mainCopy = [];
    @track sortedBy;
    accountName = 'accountName';
    @track spinner = true;
    @track inputValue;
    id = 'Id';
    @track startIndex = 0;
    @track endIndex = 200;
    @track recordIds;
    @track noOfBatches = 0;
    @track counter = 0;
    @track progressPercentage = 0;
    @track allrecordProcessed = false;
    @track searchFilter = false;
    @api columns;
    @track fields = [];
    result = [];
    @track matrixRecords;
    @track noMismatchFlag = true;
    @track actsinlist=[];
    @track searchVal;
    @track recordPresent=true;

    getRequiredBenefits() {
        requiredBenefits().then(result => {
            if (result !== undefined) {
                console.log('PRM_CustomReportService.getRequiredBenefits :', result);
                 this.matrixRecords = result;
                //this.matrixRecords.push('0012i00000IK2NuAAL');
                this.getAccountIdsAndMissingBnfts();
            }

        })
            .catch(error => {
                console.log('Error -->', error);
            })
    }

    getAccountsandBenefits(res) {
        
        getAccountsAndBenefits({ accountIds: res, wrapper: JSON.stringify(this.matrixRecords) }).then(result => {
            if (result !== undefined) {
                console.log('PRM_CustomReportService.getAccountsandBenefits :', result);
                this.noMismatchFlag = false;
                this.counter += 1;
                this.startIndex = this.endIndex + 1;
                this.endIndex = (this.startIndex + 200 > this.recordIds.length) ? this.recordIds.length : this.startIndex + 200;
                this.spinner = false;
                let tdata = [];
                this.result = result;//.slice(1, 20);                JSON.parse(JSON.stringify())               
                this.result.map(item => {
                    let row = {};
                    row.accountId = item.accountId;
                    row.accountName = item.accountName;
                    row.recordTypeName = item.recordTypeName === 'Mastered_Account' ? 'Location Account' : 'One Partner Id Account';
                    row.accountURL = '/' + item.accountId;

                    //iterate over benefits
                    let bnfts = '';
                    if (item.missedBenefits || item.bnftsToBeremoved) {
                        let missedbnfts = '';
                        // missing benefits
                        bnfts = item.missedBenefits;
                        bnfts.map(bnftrecord => {
                            missedbnfts += '' + bnftrecord + ';';
                        });
                        row.missingBenefits = missedbnfts;

                        //extra benefits
                        let extradbnfts = '';
                        bnfts = item.bnftsToBeremoved;
                        bnfts.map(bnftrecord => {
                            extradbnfts += '' + bnftrecord + ';';
                        });

                        row.extraBenefits = extradbnfts;
                        // row.recordTypeName = item.recordTypeName;

                        let roles = '';
                        item.role.map(role => {
                            roles += '' + role + ';';
                        });

                        row.role = roles;

                        let tiers = '';
                        item.tier.map(tier => {
                            tiers += '' + tier + ';';
                        });

                        row.role = roles;
                        row.tier = tiers;
                        if (extradbnfts.length > 0 && missedbnfts.length > 0) {
                            tdata.push(row);
                        }

                    }
                    this.hasData = true;
                });
                this.tableData = tdata;
                this.tableData.map(item => {
                    if(!this.actsinlist.includes(item.accountId)){
                        this.actsinlist.push(item.accountId);
                        this.mainCopy.push(item);
                    }
                })

                this.noOfPages = Math.ceil(this.mainCopy.length / this.pagesize); // calcualtes total no of pages
                this.loadMore = (this.currentpage >= 1 && this.noOfPages <= this.currentpage) ? true : false; // enable/disable next
                this.loadPrev = (this.currentpage === 1) ? true : false;//enable/disable prev button                
                this.getCurrentPageRecords();

                if (this.counter <= this.noOfBatches) {
                    this.getAccountsandBenefits(this.recordIds.slice(this.startIndex, this.endIndex), this.matrixRecords);
                    this.progressPercentage = (this.counter / this.noOfBatches) * 100;
                    this.allrecordProcessed = this.progressPercentage === 100 ? true : false;
                }

            } else {
                this.spinner = false;
            }
        })
            .catch(error => {
                this.spinner = false;
                console.error('Error -->', error);
            });
    }


    getAccountIdsAndMissingBnfts() {
        getAccountIds().then(res => {
            if (res !== undefined) {
                console.log('PRM_CustomReportService.getAccountIdsAndMissingBnfts :', res);
                this.recordIds = res;
                this.noOfBatches = Math.ceil(this.recordIds.length / 200);
                // this.getAccountsandBenefits(this.recordIds.splice(this.startIndex, this.endIndex));
                if (this.matrixRecords !== null && this.matrixRecords !== undefined) {
                    this.getAccountsandBenefits(this.recordIds.splice(this.startIndex, this.endIndex));
                }
            }
        })
            .catch(error => {
                console.log('Error -->', error);
            })
    }

    connectedCallback() {

        if (this.columns != null && this.columns !== undefined) {
            this.fields = JSON.parse(this.columns);
        }

        this.getRequiredBenefits();

    }
    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortData(fieldName === 'accountURL' ? 'accountName' : fieldName, sortDirection);
        this.sortedDirection = sortDirection;// === 'asc' ? 'desc' : 'asc';
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.tableData));
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
            this.searchVal=null;
            this.searchFilter = false;
            this.clearFilter();
        }

    }

    search(key) {
        let copy = JSON.parse(JSON.stringify(this.mainCopy)); // this.tableData
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
        this.tableData = [];
        // this.tableData = this.mainCopy;
        this.getCurrentPageRecords();
        console.log('tableData -->', this.tableData);
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
        this.tableData = [];
        let start = parseInt((this.currentpage - 1) * this.pagesize);
        let end = parseInt(start) + parseInt(this.pagesize);
        this.tableData = this.mainCopy.slice(start, end);
        this.loadMore = (this.currentpage > 1 && this.noOfPages <= this.currentpage) ? true : false;
        this.loadPrev = (this.currentpage === 1) ? true : false;
        this.showingOfTotal = (this.currentpage === this.noOfPages) ? this.mainCopy.length : this.currentpage * this.pagesize;
    }


}