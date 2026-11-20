import { LightningElement, track, api } from 'lwc';
import TrainingDetails from '@salesforce/apex/PRM_External_Objects_Data.getExternalOPIDTrainingDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { exportAsCSV } from 'c/pRM_Utils';
import AccountNo from '@salesforce/label/c.PRM_Account_No';
import ContactName from '@salesforce/label/c.PRM_Contact_Name';
import TrainingId from '@salesforce/label/c.PRM_Training_Id';
import TrainingName from '@salesforce/label/c.PRM_Training_Name';
import CompletionDate from '@salesforce/label/c.PRM_Completion_Date';
import TrainingCredits from '@salesforce/label/c.PRM_Training_Credits_Count';
import CompanyTrainingCreditsHeader from '@salesforce/label/c.PRM_Company_Training_Credits';
import lblFrom from '@salesforce/label/c.PRM_From';
import lblTO from '@salesforce/label/c.PRM_To';
import startDatePlaceHolder from '@salesforce/label/c.PRM_Start_Date';
import endDatePlaceHolder from '@salesforce/label/c.PRM_End_Date';
import filterBtn from '@salesforce/label/c.PRM_Filter_Button';
import exportBtn from '@salesforce/label/c.PRM_Export_Button';
import noDataMsg from '@salesforce/label/c.PRM_No_Training_Data';
import prevBtn from '@salesforce/label/c.PRM_Previous_Button';
import nextBtn from '@salesforce/label/c.PRM_Next_Button';
import dtSeleError from '@salesforce/label/c.PRM_Date_Selection_Error';
import dtSeleErrorMsg from '@salesforce/label/c.PRM_Date_Selection_Error_Message';
import noDataError from '@salesforce/label/c.PRM_Criteria_Search_Error';
import noDataErrorMsg from '@salesforce/label/c.PRM_No_Data_Training_Error_Message';
import pagesize from '@salesforce/label/c.PRM_SOD_Training_Page_Size';
import datasetName from '@salesforce/label/c.PRM_Company_Training_Credits_Dataset';
import MeasurementPeriod from '@salesforce/label/c.PRM_Measurement_Period';

const columns = [{
    label: AccountNo,
    fieldName: 'account_number',// account_name
    type: 'text',
    cellAttributes: { alignment: 'center' },
}, {
    label: ContactName,
    fieldName: 'contact_name', // contact_name
    type: 'text',
    cellAttributes: { alignment: 'center' },
    // initialWidth: 120
}, {
    label: TrainingId,
    fieldName: 'training_id', // training_id
    type: 'text',
    cellAttributes: { alignment: 'center' },
    // initialWidth: 120
}, {
    label: TrainingName,
    fieldName: 'training_name', // training_name
    type: 'text',
    cellAttributes: { alignment: 'center' },
    // initialWidth: 200
}, {
    label: CompletionDate,
    fieldName: 'training_completion_date',// training_completion_date
    type: 'text',
    cellAttributes: { alignment: 'center' },
}, {
    label: TrainingCredits,
    fieldName: 'training_credits', // training_credits
    type: 'number',
    cellAttributes: { alignment: 'center' }
    // initialWidth: 200
},
{
    label: MeasurementPeriod,
    fieldName: 'Measurement_Period',
    type: 'text',
    cellAttributes: { alignment: 'center' },
    // initialWidth: 200
    }];


export default class PRM_CompanyTrainingCreadits extends LightningElement {
    nextBtnLbl = nextBtn;
    prevBtnLbl = prevBtn;
    exportBtnLbl = exportBtn;
    filterBtnLbl = filterBtn;
    noDataMsgLbl = noDataMsg;
    header = CompanyTrainingCreditsHeader;
    columns = columns;
    dtFrom = lblFrom;
    dtTo = lblTO;
    startDatePlaceHolderlbl = startDatePlaceHolder;
    endDatePlaceHolderlbl = endDatePlaceHolder;
    dtSeleErrorLbl = dtSeleError;
    dtSeleErrorMsgLbl = dtSeleErrorMsg;
    measurementPeriod=MeasurementPeriod;
    @track filteredRecordsList = [];
    @track currentAccount = 0;
    @track noFPages;
    @track noFFilteredPages;
    @track currentAccountRecords = [];
    @track actCount = 0;
    @track count = 1;
    @track endDate = '';
    @track isData;
    @track startDate = '';
    @track spinner = false;
    @track records = [];
    @track error;
    @track currentpage;
    // @track pageLengh = 200;
    @track searchKey;
    @track doRun = false;
    @track nOfAccnts;
    @track actList = [];
    @track error;
    @track loadPrev;
    @track loadMore;
    @track renderCnt = 0;
    @track nextRender;
    @track prevRender;
    @track filterRender;
    @track byFilter = false;
    @track hasRender;
    @track initalRender = 1;
    @track diffDays;
    @track exprtdata;
    @track isDataAvailable;
    // dataSetName = dataSetName;
    handleExport() {
        //console.log('Exported Data :' + this.exprtdata);
        exportAsCSV(datasetName, this.currentpage, this.exprtdata);
    }

    nxtEvt() {
        //console.log('Inside next page');
        this.nextRender = 1;
        this.hasRender = false;
        this.renderedCallback();
    }

    handlePrev() {
        //console.log('Inside prev');
        this.prevRender = 1;
        this.hasRender = false;
        this.renderedCallback();
    }

    getStringDate(dt) {
        let year;
        let month;
        let day;
        year = dt.getFullYear();
        month = (1 + dt.getMonth()).toString();
        month = month.length > 1 ? month : '0' + month;
        day = dt.getDate().toString();
        day = day.length > 1 ? day : '0' + day;
        return year + '-' + month + '-' + day;
    }
    setStartDate(event) {
        let dt = new Date(event.target.value);
        this.startDate = this.getStringDate(dt);
        if (this.startDate == '1970-01-01' || this.startDate == 'NaN-NaN-NaN') {
            this.startDate = '';
        }
        //   console.log("" + this.startDate);
    }
    setEndDate(event) {
        let dt = new Date(event.target.value);
        this.endDate = this.getStringDate(dt);
        if (this.endDate == '1970-01-01' || this.endDate == 'NaN-NaN-NaN') {
            this.endDate = '';
        }
        //  console.log("" + this.endDate);
    }

    criteriaSearch() {
        // console.log(' >> :' + dtSeleError + ' >> :' + dtSeleErrorMsg);
        if ((this.startDate.length > 0 && this.endDate.length > 0) || (this.startDate.length > 0 && this.endDate.length === 0) || (this.startDate.length < 1 && this.endDate.length > 0)) {
            if (this.startDate.length > 0 && this.endDate.length === 0) {
                //     console.log('Selected start date only');
                this.endDate = this.startDate;
            }
            if (this.startDate.length < 1 && this.endDate.length > 0) {
                //    console.log('Selected end date only');
                this.startDate = '';
                this.endDate = '';
            }
            const dateDiffrence = Date.parse(this.endDate) - Date.parse(this.startDate);
            this.diffDays = Math.ceil(dateDiffrence / (1000 * 60 * 60 * 24));
            // console.log("Date difference :" + this.diffDays);

            if (this.diffDays > 30 || (Date.parse(this.startDate) > Date.parse(this.endDate))) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: dtSeleError,
                        message: dtSeleErrorMsg,
                        variant: 'error',
                    }),
                );
            } else {
                this.currentAccountRecords = [];
                this.spinner = true;
                this.hasRender = false;
                this.filterRender = 1;
                this.renderedCallback();
            }
        } else {
            this.startDate = '';
            this.endDate = '';
            this.hasRender = false;
            this.filterRender = 1;
            this.renderedCallback();
        }
    }

    commonCode() {
        this.hasRender = true;
        this.spinner = true;
        TrainingDetails()
            .then(result => {
                if (result.length === 0) {
                    this.spinner = false;
                    this.isData = false;
                    this.loadMore = true;
                    this.loadPrev = true;
                    this.isDataAvailable = true;
                    this.currentAccount = 0;
                } else {
                    this.hasRender = true;
                    this.records = result;
                    this.error = undefined;
                    this.spinner = false;
                    this.isData = true;
                    let start = 0;
                    let end = pagesize;
                    this.currentAccountRecords = this.records.slice(start, end);
                    this.exprtdata = this.currentAccountRecords;
                    this.noFPages = Math.ceil(this.records.length / pagesize);
                    this.loadMore = (this.currentpage >= 1 && this.noFPages <= this.currentpage) ? true : false;
                    this.loadPrev = (this.currentpage === 1) ? true : false;
                    this.hasRender = true;
                    // console.log(':List Size:' + this.records.length);
                    this.isDataAvailable = (this.currentAccountRecords.length < 1) ? true : false;
                }
            })
            .catch(error => {
                this.hasRender = true;
                this.error = error;
                this.isData = false;
                this.records = undefined;
                //  console.log('Error :' + error);
                this.spinner = false;
            });
    }
    async connectedCallback() {
        this.currentpage = 1;
        //  console.log('From connected callback ');
        this.commonCode();
    }

    checkPrevANDNext() {
        this.loadMore = (this.currentpage > 1 && this.noFPages <= this.currentpage) ? true : false;
        this.loadPrev = (this.currentpage === 1) ? true : false;
    }
    getPageRecords() {
        this.currentAccountRecords = [];
        //console.log('Current Page' + this.currentpage);
        let start = parseInt((this.currentpage - 1) * pagesize);
        let end = parseInt(start) + parseInt(pagesize);
        //  console.log('start :' + start + ' End' + end);
        this.exprtdata = [];
        if (this.byFilter) {
            //  console.log('You are inside filtered records');
            this.currentAccountRecords = this.filteredRecordsList.slice(start, end);
            this.loadMore = (this.currentpage > 1 && this.noFFilteredPages <= this.currentpage) ? true : false;
            this.loadPrev = (this.currentpage === 1) ? true : false;
        } else {
            this.filteredRecordsList = [];
            // console.log('Your are innside another method...');
            this.currentAccountRecords = this.records.slice(start, end);
            this.checkPrevANDNext();
        }
        if (this.currentAccountRecords != null && this.currentAccountRecords.length > 0) {
            this.exprtdata = this.currentAccountRecords;
        } else {
            this.exprtdata = [];
        }
        this.spinner = false;
        //console.log('Data to append on table :' + this.currentAccountRecords);
    }
    renderedCallback() {
        //   console.log('Inside render call back >>' + AccountNo + '>> ' + ContactName + '>> ' + TrainingName + '>> ' + TrainingId + '>> ' + TrainingCredits + '>> ' + CompletionDate);
        if (this.nextRender === 1 && this.hasRender === false) {
            console.log('Inside next filter');
            this.nextRender += 1;
            this.hasRender = true;
            this.currentpage += 1;
            this.getPageRecords();

        } else if (this.prevRender === 1 && this.hasRender === false) {
            this.prevRender += 1;
            this.hasRender = true;
            this.currentpage -= 1;
            this.getPageRecords();
        } else if (this.hasRender === false && this.filterRender === 1) {
            this.byFilter = true;
            this.spinner = true;
            this.filterRender += 1;
            this.hasRender = true;
            let incr = 0;
            this.count = 0;
            this.currentAccountRecords = [];
            if (this.startDate.length < 1 && this.endDate.length < 1) {
                this.byFilter = false;
                //     console.log('From empty dates')
                let start = 0;
                this.currentpage = 1;
                let end = pagesize;
                this.exprtdata = [];
                this.currentAccountRecords = this.records.slice(start, end);
                this.exprtdata = this.currentAccountRecords;
                if (this.currentAccountRecords.length < 1) {
                    this.isDataAvailable = (this.currentAccountRecords.length < 1) ? true : false;
                    this.spinner = false;
                    this.isData = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: noDataError,
                        message: noDataErrorMsg,
                        variant: 'info'
                    }));
                } else {
                    this.spinner = false;
                    this.isData = true;
                    this.isDataAvailable = (this.currentAccountRecords.length < 1) ? true : false;
                }
                this.loadMore = ((this.currentpage > 1 && this.noFPages >= this.currentpage) || this.currentAccountRecords.length < pagesize) ? true : false;
                this.loadPrev = (this.currentpage === 1) ? true : false;
            } else {
                // console.log('From date filter');
                this.currentpage = 1;
                // this.currentAccountRecords = [];
                // this.exprtdata = [];
                this.filteredRecordsList = [];

                for (let index = 0; index < this.records.length; index++) {
                    let dt = this.records[index].training_completion_date;// training_completion_date

                    //   console.log('date received >> :' + dt);
                    // console.log(dt);
                    if (dt >= this.startDate && dt <= this.endDate) {
                        this.filteredRecordsList[incr] = this.records[index];
                        incr += 1;
                    }
                }
                if (this.filteredRecordsList.length > 0 && this.filteredRecordsList != null) {
                    this.noFFilteredPages = Math.ceil(this.filteredRecordsList.length / pagesize);
                    this.getPageRecords();
                } else {
                    this.currentAccountRecords = [];
                }
                //  console.log(' >> :' + JSON.stringify(this.filteredRecordsList));
                // this.exprtdata = this.filteredRecordsList;
                if (this.currentAccountRecords.length < 1) {
                    this.spinner = false;
                    this.isData = false;
                    this.isDataAvailable = (this.currentAccountRecords.length < 1) ? true : false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: noDataError,
                        message: noDataErrorMsg,
                        variant: 'info'
                    }));
                } else {
                    this.spinner = false;
                    this.isData = true;
                    this.isDataAvailable = (this.currentAccountRecords.length < 1) ? true : false;
                }

                this.loadMore = ((this.currentpage > 1 && this.noFPages >= this.currentpage) || this.currentAccountRecords.length < pagesize) ? true : false;
                this.loadPrev = (this.currentpage === 1) ? true : false;
            }
            // console.log('Added records' + this.currentAccountRecords);
        }

    }
}