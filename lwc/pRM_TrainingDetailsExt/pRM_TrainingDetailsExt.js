import { LightningElement, track, api } from 'lwc';
import TrainingDetails from '@salesforce/apex/PRM_External_Objects_Data.getExternalTrainingDetails';
import getRecordsCount from '@salesforce/apex/PRM_External_Objects_Data.recordsCount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { exportAsCSV } from 'c/pRM_Utils';
import header from '@salesforce/label/c.PRM_Contact_Training_Credits_Header';
import AccountNo from '@salesforce/label/c.PRM_Account_No';
import ContactName from '@salesforce/label/c.PRM_Contact_Name';
import TrainingId from '@salesforce/label/c.PRM_Training_Id';
import TrainingName from '@salesforce/label/c.PRM_Training_Name';
import CompletionDate from '@salesforce/label/c.PRM_Completion_Date';
import TrainingCredits from '@salesforce/label/c.PRM_Training_Credits_Count';
import dataSetNameLbl from '@salesforce/label/c.PRM_Training_Credits_Dataset';
import lblFrom from '@salesforce/label/c.PRM_From';
import lblTO from '@salesforce/label/c.PRM_To';
import startDatePlaceHolder from '@salesforce/label/c.PRM_Start_Date';
import endDatePlaceHolder from '@salesforce/label/c.PRM_End_Date';
import filterBtn from '@salesforce/label/c.PRM_Filter_Button';
import exportBtn from '@salesforce/label/c.PRM_Export_Button';
import prevBtn from '@salesforce/label/c.PRM_Previous_Button';
import nextBtn from '@salesforce/label/c.PRM_Next_Button';
import dtSeleError from '@salesforce/label/c.PRM_Date_Selection_Error';
import dtSeleErrorMsg from '@salesforce/label/c.PRM_Date_Selection_Error_Message';
import noDataError from '@salesforce/label/c.PRM_Criteria_Search_Error';
import noDataErrorMsg from '@salesforce/label/c.PRM_No_Data_Training_Error_Message';
import noOfRecords from '@salesforce/label/c.PRM_Total_Records';
import ofLabel from '@salesforce/label/c.PRM_Of';
import page from '@salesforce/label/c.PRM_Page';
import noTrainingRecords from '@salesforce/label/c.PRM_No_Training_Data';
import MeasurementPeriod from '@salesforce/label/c.PRM_Measurement_Period';
const columns = [{
  label: AccountNo,
  fieldName: 'account_number',// account_number
  type: 'text',
  cellAttributes: { alignment: 'center' },
}, {
  label: ContactName,
  fieldName: 'contact_name',//contact_name
  type: 'text',
  cellAttributes: { alignment: 'center' },
  // initialWidth: 120
}, {
  label: TrainingId,
  fieldName: 'training_id',//training_id
  type: 'text',
  cellAttributes: { alignment: 'center' },
  // initialWidth: 120
}, {
  label: TrainingName,
  fieldName: 'training_name',//training_name
  type: 'text',
  cellAttributes: { alignment: 'center' },
  // initialWidth: 200
}, {
  label: CompletionDate,
  fieldName: 'training_completion_date',//training_completion_date
  type: 'text',
  cellAttributes: { alignment: 'center' },
}, {
  label: TrainingCredits,
  fieldName: 'training_credits',//training_credits
  type: 'number',
  cellAttributes: { alignment: 'center' },
  // initialWidth: 200
},
{
    label: MeasurementPeriod,
    fieldName: 'Measurement_Period',
    type: 'text',
    cellAttributes: { alignment: 'center' },
    // initialWidth: 200
    }];

export default class RecorPRM_TrainingDetailsExt extends LightningElement {
  totalRecords = noOfRecords;
  ofLbl = ofLabel;
  pageLbl = page;
  nextBtnLbl = nextBtn;
  prevBtnLbl = prevBtn;
  exportBtnLbl = exportBtn;
  filterBtnLbl = filterBtn;
  noDataMsgLbl = noTrainingRecords;
  dtFrom = lblFrom;
  dtTo = lblTO;
  startDatePlaceHolderlbl = startDatePlaceHolder;
  endDatePlaceHolderlbl = endDatePlaceHolder;
  dtSeleErrorLbl = dtSeleError;
  dtSeleErrorMsgLbl = dtSeleErrorMsg;
  headerLbl = header;
  measurementPeriod=MeasurementPeriod;
  columns = columns;
  @track count = 0;
  @track endDate;
  @track startDate;
  @track spinner = false;
  @track records = [];
  @track error;
  @api currentpage;
  @api pagesize;
  @track searchKey;
  @track doRun = false;
  @track lastId;
  @track prevtId;
  @track isData;
  totalpages;
  startDate;
  endDate;
  hasRender;
  @track diffDays;
  @track exprtData;
  dataSetName = dataSetNameLbl;
  @track isDataAvailable;
  handleExport() {
    exportAsCSV(this.dataSetName, this.currentpage, this.exprtData);
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
    // console.log("" + this.endDate);
  }

  criteriaSearch() {
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
      //  console.log("Date difference :" + this.diffDays);

      if (this.diffDays > 30 || (Date.parse(this.startDate) > Date.parse(this.endDate))) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: dtSeleError,
            message: dtSeleErrorMsg,
            variant: 'error',
          }),
        );
        this.doRun = false;
      } else {
        this.doRun = true;
        if (this.doRun) {
          this.spinner = true;
          this.hasRender = false;
          this.renderedCallback();
        }
      }
    } else {
      this.doRun = true;
      if (this.doRun) {
        this.spinner = true;
        this.hasRender = false;
        this.renderedCallback();
      }
    }
  }

  handleClick() {
    this.commonCode();
  }

  commonCode() {
    //  console.log('You are inside from next click');
    //  console.log('Start Date :' + this.startDate + ' End Date :' + this.endDate);
    this.spinner = true;
    getRecordsCount({ startDate: this.startDate, endDate: this.endDate }) // added start date and end date parameters 
      .then(recordsCount => {
        if (recordsCount === 0) {

          if (this.startDate.length > 0 || this.endDate.length > 0) {
            this.isData = false;
            this.spinner = false;
            this.dispatchEvent(new ShowToastEvent({
              title: noDataError,
              message: noDataErrorMsg,
              variant: 'info'
            }));
          } else {
            this.isData = false;
            this.spinner = false;
          }
          this.isDataAvailable = true;
        } else {
          this.totalrecords = recordsCount;
          this.hasRender = true;
          if (recordsCount !== 0 && !isNaN(recordsCount)) {
            this.totalpages = Math.ceil(recordsCount / this.pagesize);
            //        console.log('no of records ' + recordsCount)
            TrainingDetails({ pagenumber: this.currentpage, numberOfRecords: recordsCount, pageSize: this.pagesize, searchString: this.searchKey, startDate: this.startDate, endDate: this.endDate })//
              .then(result => {
                this.records = result;
                this.exprtData = this.records;
                this.isDataAvailable = this.records.length < 1 ? true : false;
                this.error = undefined;
                this.spinner = false;
                this.isData = true;
                //          console.log('Records retr :' + JSON.stringify(this.records));
                this.doRun = false;
              })
              .catch(error => {
                this.error = error;
                this.records = undefined;
                //        console.log('Error :' + error);
                this.spinner = false;
              });

          } else {
            this.records = [];
            this.totalpages = 1;
            this.totalrecords = 0;
            this.spinner = false;
          }
        }
        const event = new CustomEvent('recordsload', {
          detail: recordsCount
        });
        this.dispatchEvent(event);
      })
      .catch(error => {
        this.error = error;
        this.totalrecords = undefined;
        this.spinner = false;
        this.hasRender = true;
      });
  }

  renderedCallback() {
    //   console.log('>> ' + AccountNo + '>> ' + ContactName + '>> ' + TrainingCredits + '>> ' + TrainingName + '>> ' + CompletionDate);
    if (this.startDate == undefined || this.endDate == undefined) {
      this.startDate = "";
      this.endDate = "";
    } else {
      this.startDate = "" + this.startDate;
      this.endDate = "" + this.endDate;
    }

    //  console.log('from render :' + this.doRun);
    if (this.hasRender == false || this.count != this.currentpage) { //this.doRun == true &&
      this.count = this.currentpage;
      //    console.log('current page' + this.currentpage + ' count' + this.count);
      //    console.log('Render is running..' + this.hasRender);
      this.hasRender = true;
      this.commonCode();

    }
  }
}