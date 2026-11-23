import { LightningElement, api, track, wire } from 'lwc';
//import getLicenseRecord from '@salesforce/apex/Sales_SplitSeatsOnLicenseController.getLicenseRecord';
import splitLicenses from '@salesforce/apex/Sales_SplitSeatsOnLicenseController.splitLicenses';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord } from 'lightning/uiRecordApi';
import LICENSE_OBJECT from '@salesforce/schema/Sales_License__c';
import newLicenseDetails from '@salesforce/apex/Sales_SplitSeatsOnLicenseController.newLicenseDetails';
import getTargetLicensesForMerging from '@salesforce/apex/Sales_SplitSeatsOnLicenseController.getTargetLicensesForMerging';
import mergeLicenseRecords from '@salesforce/apex/Sales_SplitSeatsOnLicenseController.mergeLicenseRecords';
import getFeedRecord from '@salesforce/apex/Sales_FeedbackController.getFeedRecord';//added for feedback
import checkCapablity from '@salesforce/apex/Sales_FeedbackController.checkCapablity';//added for feedback
//import checkOrderAndOrderProduct from '@salesforce/apex/Sales_SplitSeatsOnLicenseController.checkOrderAndOrderProduct';

//custom label
import textinput from '@salesforce/label/c.Sales_MergeSeats';
import Sales_NoOfSeatsLabel from '@salesforce/label/c.Sales_NoOfSeatsLabel';
import Sales_NoOfSeatsLabel_SplitLic from '@salesforce/label/c.Sales_NoOfSeatsLabel_SplitLic';
import Sales_MergeSeats_ProdTypeError from '@salesforce/label/c.Sales_MergeSeats_ProdTypeError';
import Sales_Split_ProdTypeError from '@salesforce/label/c.Sales_Split_ProdTypeError';
import Sales_Merge_NoOfSeatsError from '@salesforce/label/c.Sales_Merge_NoOfSeatsError';
import Sales_Split_NoOfSeatsError from '@salesforce/label/c.Sales_Split_NoOfSeatsError';
import Sales_NoOfSeatsGreaterThanZero_Error from '@salesforce/label/c.Sales_NoOfSeatsGreaterThanZero_Error';
import Sales_Merge_NoOfSeaterGrtThanZero_Error from '@salesforce/label/c.Sales_Merge_NoOfSeaterGrtThanZero_Error';
import Sales_Split_NoOfSeatsMoreThanone_Error from '@salesforce/label/c.Sales_Split_NoOfSeatsMoreThanone_Error';
import Sales_MergeSeats_CancelledLicError from '@salesforce/label/c.Sales_MergeSeats_CancelledLicError';
import Sales_SplitSeats_CancelledLicError from '@salesforce/label/c.Sales_SplitSeats_CancelledLicError';
import Sales_MergeSeats_RenewalsAppliedError from '@salesforce/label/c.Sales_MergeSeats_RenewalsAppliedError';
import Sales_SpliSeats_ADDSEATError from '@salesforce/label/c.Sales_SpliSeats_ADDSEATError';
import Sales_MergeSeats_RENEWALError from '@salesforce/label/c.Sales_MergeSeats_RENEWALError';
import Sales_UnableToProceedError from '@salesforce/label/c.Sales_UnableToProceedError';
import Sales_MergeSeats_ExpiredLicError from '@salesforce/label/c.Sales_MergeSeats_ExpiredLicError';
import Sales_ReviewErrors_Error from '@salesforce/label/c.Sales_ReviewErrors_Error';
import Sales_SplitMergeSeats_Error from '@salesforce/label/c.Sales_SplitMergeSeats_Error';
import Sales_MergeSeats_SelectTargetError from '@salesforce/label/c.Sales_MergeSeats_SelectTargetError';
import Sales_MergeSeats_RehostError from '@salesforce/label/c.Sales_MergeSeats_RehostError';
import Sales_MergeSeats_SuccessMsg from '@salesforce/label/c.Sales_MergeSeats_SuccessMsg';
import Sales_SplitSeats_SuccessMsg from '@salesforce/label/c.Sales_SplitSeats_SuccessMsg';
import Sales_TempLicError from '@salesforce/label/c.Sales_TempLicError';
import Sales_LicGeneration_Confirmation from '@salesforce/label/c.Sales_LicGeneration_Confirmation';
import Sales_NoServerToRemove from '@salesforce/label/c.Sales_NoServerToRemove';
import Sales_MoveSeatsToOneServer from '@salesforce/label/c.Sales_MoveSeatsToOneServer';
import Sales_MoveSeatsToOneEach from '@salesforce/label/c.Sales_MoveSeatsToOneEach';
import Sales_number_Of_Server from '@salesforce/label/c.Sales_number_Of_Server';
import Sales_Merge_Seats from '@salesforce/label/c.Sales_Merge_Seats';
import Sales_Split_Seats from '@salesforce/label/c.Sales_Split_Seats';
import Sales_Next from '@salesforce/label/c.Sales_Next';
import Sales_SaveOrder_HTML from '@salesforce/label/c.Sales_SaveOrder_HTML';
import Sales_AccessCheckMsg from '@salesforce/label/c.Sales_AccessCheckMsg';
import Sales_OrderClose from '@salesforce/label/c.Sales_OrderClose';
import Sales_Back from '@salesforce/label/c.Sales_Back';
import Sales_Confirm from '@salesforce/label/c.Sales_Confirm';
import Sales_Maitenance_Exp from '@salesforce/label/c.Sales_Maitenance_Exp';
import Sales_License_Expiration from '@salesforce/label/c.Sales_License_Expiration';
import Sales_ofseat from '@salesforce/label/c.Sales_ofseat';
import Sales_Part_Number from '@salesforce/label/c.Sales_Part_Number';
import sales_compid from '@salesforce/label/c.sales_compid';
import Sales_Name from '@salesforce/label/c.Sales_Name';
import Sales_Primary_Computer_Name from '@salesforce/label/c.Sales_Primary_Computer_Name';
import Sales_Current_Seat from '@salesforce/label/c.Sales_Current_Seat';
import Sales_Seat_After_Split from '@salesforce/label/c.Sales_Seat_After_Split';
import userId from '@salesforce/user/Id';
import validateUserAccess from '@salesforce/apex/Sales_ValidateUserEditAccess.validateUserAccess';

//import Sales_optionalproducterror from '@salesforce/label/c.Sales_optionalproducterror';

const FIELDS = ['Sales_License__c.Id', 'Sales_License__c.Sales_License_Avbl_Rehost_Nbr__c', 'Sales_License__c.Name', 'Sales_License__c.Sales_License_Type__c', 'Sales_License__c.Sales_License_Expiration_Date_Dt__c', 'Sales_License__c.Sales_License_Avbl_Qty_Nbr__c', 'Sales_License__c.Sales_License_Status__c', 'Sales_License__c.Sales_License_Product__c', 'Sales_License__c.Sales_License_Product__r.Name', 'Sales_License__c.Sales_License_Product__r.Core_OPN__c',
    'Sales_License__c.Sales_License_Maintenance_Exp_Dt__c', 'Sales_License__c.Sales_License_Available_Temp_Licenses__c', 'Sales_License__c.Sales_License_Comments_Txt__c', 'Sales_License__c.Sales_License_Web_Display_Flag__c', 'Sales_License__c.Sales_License_Host_Node_Id__c', 'Sales_License__c.Sales_License_Host_Node_Id__r.Name', 'Sales_License__c.Sales_License_Quantity__c', 'Sales_License__c.Sales_Tool_License_Type__c',
    'Sales_License__c.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c', 'Sales_License__c.Sales_License_Web_Display_Flag__c', 'Sales_License__c.Sales_License_Activation_Code__c'];
const columns = [
    { label: Sales_Part_Number, fieldName: 'prodOpn', initialWidth: 150 },
    { label: Sales_Maitenance_Exp, fieldName: 'maintExp', type: 'date-local', initialWidth: 150 },
    { label: Sales_Primary_Computer_Name, fieldName: 'compName', initialWidth: 130 },
    { label: Sales_Current_Seat, fieldName: 'noOfSeatsCurr', initialWidth: 130 },
    { label: Sales_Seat_After_Split, fieldName: 'noOfSeatsSplit', initialWidth: 130 },
    {
        type: "button",
        label: 'Generate License',
        typeAttributes: {
            label: 'Generate',
            name: 'Generate',
            title: 'Generate',
            disabled: { fieldName: 'showBtn' },
            value: 'GenerateLicence',
            iconPosition: 'left'
        },
    }
];

const mergeSeatsCols = [
    { label: Sales_Name, fieldName: 'name', initialWidth: 140 },
    { label: Sales_Part_Number, fieldName: 'prodOpn', initialWidth: 200 },
    { label: Sales_Maitenance_Exp, fieldName: 'maintExp', type: 'date-local', initialWidth: 200 },
    { label: Sales_License_Expiration, fieldName: 'licExp', type: 'date-local', initialWidth: 140 },
    { label: sales_compid, fieldName: 'hostName', initialWidth: 200 },
    { label: Sales_ofseat, fieldName: 'noOfSeatsCurr', initialWidth: 200 },
];

const columns2 = [{ label: 'Id', fieldName: 'licenseId' },
{ label: 'Primary Contact', fieldName: 'primarycontact' },
{ label: 'License Tool Type', fieldName: 'licenseType' },
{ label: 'Host Id', fieldName: 'hostIdValue' }];

export default class Sales_SplitSeatsOnLicense extends NavigationMixin(LightningElement) {
    // added by Pooja jadhav -- Model Pop Up Attriutes

    //--
    @track licenseActivationCode;
    @track lincenseWebDisplayFlag;
    @track licenseHostValue;
    //--
    @track mergeSeatsCols = mergeSeatsCols;
    @track isModalOpen = false;
    @track showLicenseGenrateCmp = false;
    @track hideMainButtons = false;
    @track activationCode;
    @track webdisplayFlag;
    @api Licenseids;
    @api newSplittedLicenses;
    @api licenseRecordId;
    @api licenseType;
    @api primarycontact;
    @api licenseId;
    @api isMergeSeats = false;
    @api isPartnerPortal = false;
    @api newlicenseIds = '';// containse ;seperated ids
    @track existingcomputername;
    //---------------
    @track targetLicenses = [];
    @track targetLicensesRaw = [];
    @track targetLicensesAll = [];
    @track searchStr;
    @track targetLicenseRecSelected;
    @track formTitle;
    noOfSeatsLabel;
    @track nextBtnLabel;
    @track userAccessCheck=false;
    disableBackBtn = false;
    isSplitSuccessfull = false;
    splited = false;
    showSplitOptionsRadioBtn = false;
    disableInput = false;
    showOptionsToSplitMsg = false;
    @api showTargetLicenses = false;
    @api isInternal = false;
    @api showOptionsToSplit = false;
    @api isInvalidLicense = false;
    @api isError = false;
    isNotFloatProd = true;
    @api recordId;
    @track licenseRecordToSplit;
    @api showSplittedLicenses = false;
    @track isLoaded;
    @api toolType;
    @track errorMsg = '';
    @track noOfSeats;
    radioBtnValue = 'AllSeatsToOne';
    //today = new Date();
    noOfServers = 1;
    data = [];
    splittedRecordId;
    columns = columns;
    //feedback start
    @track enableFeedback = false;
    @api disablefeedback = false;
    @track feedrec;
    @track isFeedbackvisible = false;
    @track noofdays;
    @track eventType;
    @track feedbackchatbot;
    @track iscapablity = false;
    @track isOrder = false;
    @track userId = userId;

    capablity = 'Split Seats';
    label = {
        Sales_NoOfSeatsLabel, Sales_NoOfSeatsLabel_SplitLic, Sales_MergeSeats_ProdTypeError, Sales_Split_ProdTypeError, Sales_Merge_NoOfSeatsError, Sales_Split_NoOfSeatsError,
        Sales_NoOfSeatsGreaterThanZero_Error, Sales_Merge_NoOfSeaterGrtThanZero_Error, Sales_Split_NoOfSeatsMoreThanone_Error, Sales_MergeSeats_CancelledLicError,
        Sales_SplitSeats_CancelledLicError, Sales_MergeSeats_RenewalsAppliedError, Sales_SpliSeats_ADDSEATError, Sales_MergeSeats_RENEWALError, Sales_UnableToProceedError, Sales_MergeSeats_ExpiredLicError,
        Sales_ReviewErrors_Error, Sales_SplitMergeSeats_Error, Sales_MergeSeats_SelectTargetError, Sales_MergeSeats_RehostError, Sales_MergeSeats_SuccessMsg, Sales_SplitSeats_SuccessMsg, Sales_TempLicError,
        Sales_LicGeneration_Confirmation, Sales_NoServerToRemove, textinput, Sales_number_Of_Server, Sales_MoveSeatsToOneServer, Sales_MoveSeatsToOneEach, Sales_Merge_Seats, Sales_Split_Seats, Sales_Next, Sales_SaveOrder_HTML,
        Sales_OrderClose, Sales_Back, Sales_Confirm,Sales_AccessCheckMsg
    };

    /* checkorderdetails(){
      checkOrderAndOrderProduct({recordId:this.recordId})
       .then((result) => {
              this.isOrder=result;
              if(this.isOrder==true && this.isMergeSeats==false){
                  console.log('order n order product blank');
                  this.isInvalidLicense =true;
                  this.showNotificationerror(this.label.Sales_Err,this.label.Sales_optionalproducterror,'error');		
              }
          })
          .catch((error) => {
              
          });
      }*/
    @wire(checkCapablity, { capablity: '$capablity' })
    checkCapablity({ error, data }) {
        if (data) {
            console.log('capability available>' + data);
            this.iscapablity = data;
            this.getFeedbackRecords();
        }
        if (error) {
        }
    }

    getFeedbackRecords() {
        getFeedRecord({ capablity: this.capablity })
            .then((result) => {
                this.feedrec = result;
                console.log('feed back records length>>' + JSON.stringify(this.feedrec));
                console.log("This is data" + this.feedrec.Last_Feedback_Captured__c);
                this.noofdays = this.feedrec.Last_Feedback_Captured__c;
                this.eventType = this.feedrec.Event_Type__c;
                this.feedbackchatbot = this.feedrec.Chatbot_Feedback__c;
                console.log("this.noofdays>>" + this.noofdays);
                if (this.noofdays > 89 && this.iscapablity == true && (this.eventType = 'Event Feedback') && (this.feedbackchatbot = false)) {
                    this.isFeedbackvisible = true;
                }
                else {
                    console.log('inside else isFeedbackvisible>>>' + this.isFeedbackvisible);
                    this.isFeedbackvisible = false;
                }

            })
            .catch((error) => {
                console.log('imperative existing feedback>>>' + JSON.stringify(error) + 'this.iscapablity>>' + this.iscapablity);
                if (this.iscapablity == true) {
                    this.isFeedbackvisible = true;
                }
            });
    }
    //feedback end

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wireRecord(result) {
        this.isInvalidLicense = true;
        if (result.data) {
            this.licenseRecordToSplit = result.data;
            //  this.checkorderdetails(); 
            if (this.checkIfLicenseIsValid() == false && this.userAccessCheck==false) {
                const evt2 = new ShowToastEvent({
                    title: 'Error',
                    message: this.errorMsg,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt2);
                this.isLoaded = true;
            } else {
                //  this.isValidLicense = true;
                if (this.isMergeSeats == true) {
                    getTargetLicensesForMerging({
                        licRecordId: this.recordId
                    })
                        .then(result => {
                            if (result != undefined || result.data.length != 0) {
                                this.targetLicensesRaw = result;
                                this.prepareTargetLicenseRecordsData();
                                this.showTargetLicenses = true;
                                this.isNotFloatProd = false;
                                this.isInvalidLicense = false;
                                this.isLoaded = true;
                            }
                            else {
                                this.isLoaded = true;
                                const evt = new ShowToastEvent({
                                    title: 'Error',
                                    message: this.label.Sales_NoServerToRemove,
                                    variant: 'error',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(evt);
                                this.isLoaded = true;
                                this.handleOnBackBtnClick();
                                this.isInvalidLicense = true;
                            }
                        })
                        .catch(error => {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: error,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                            this.isLoaded = true;
                        });
                } else {
                    this.isNotFloatProd = false;
                    this.isInvalidLicense = false;
                    this.isLoaded = true;
                }
            }
        } else if (result.error) {
            const evt3 = new ShowToastEvent({
                title: 'Error',
                message: result.error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt3);
        }
    }

    connectedCallback() {
        console.log('connected callback');
        this.validateUserAccessLogic();
        if(this.userAccessCheck==false){
        if (this.isMergeSeats == true) {
            this.formTitle = this.label.Sales_Merge_Seats;
            this.nextBtnLabel = this.label.Sales_SaveOrder_HTML;
            this.noOfSeatsLabel = this.label.Sales_NoOfSeatsLabel;
        } else {
            this.formTitle = this.label.Sales_Split_Seats;
            this.nextBtnLabel = this.label.Sales_Next;
            this.noOfSeatsLabel = this.label.Sales_NoOfSeatsLabel_SplitLic;
        }
    }
}
    disconnectedCallback() {
        this.reloadPage();
    }


    @track createComputer;
    closeModel() {
        this.createComputer = false;
    }


    handleGenerateLicense(event) {
        let value = event.detail.row;
        console.log('row  -->' + JSON.stringify(value));
        this.lincenseWebDisplayFlag = value.webdisplayFlag;
        this.licenseActivationCode = value.activationCode;
        this.licenseHostValue = value.hostIdValue;
        console.log('license hotst -->' + this.licenseHostValue);
        this.createComputer = true;
        this.licenseRecordId = value.licenseId;
        console.log('Record Id -->' + this.licenseRecordId);
        this.licenseType = value.licenseType;
        this.primarycontact = value.primarycontact;
        this.existingcomputername = value.compName;
        console.log('Row -->' + JSON.stringify(value));

    }

    inputChange(event) {
        this.noOfSeats = event.target.value;
    }

    get options() {
        return [
            { label: this.label.Sales_MoveSeatsToOneServer, value: 'AllSeatsToOne' },
            { label: this.label.Sales_MoveSeatsToOneEach, value: 'EachSeatToDiff' },
        ];
    }

    prepareTargetLicenseRecordsData() {
        //   console.log('in prepare');
        this.targetLicenses = [];
        if (this.targetLicensesRaw != undefined && this.targetLicensesRaw.length > 0) {
            for (let i = 0; i < this.targetLicensesRaw.length; i++) {
                var tempHost = this.targetLicensesRaw[i].Sales_License_Host_Node_Id__c;
                var tempHostName = '';
                if (tempHost != undefined) {
                    tempHostName = this.targetLicensesRaw[i].Sales_License_Host_Node_Id__r.Name;
                }

                // console.log('targetLicensesRawi:'+JSON.stringify(this.targetLicensesRaw[i]));

                let dataRec = {
                    id: this.targetLicensesRaw[i].Id,
                    name: this.targetLicensesRaw[i].Name,
                    // ordProd: this.targetLicensesRaw[i].Sales_License_Order_Product__c,
                    status: this.targetLicensesRaw[i].Sales_License_Status__c,
                    avlbQty: this.targetLicensesRaw[i].Sales_License_Avbl_Qty_Nbr__c,
                    prodOpn: this.targetLicensesRaw[i].Sales_License_Product__r.Core_OPN__c,
                    maintExp: this.targetLicensesRaw[i].Sales_License_Maintenance_Exp_Dt__c,
                    licExp: this.targetLicensesRaw[i].Sales_License_Expiration_Date_Dt__c,
                    hostName: tempHostName,
                    noOfSeatsCurr: this.targetLicensesRaw[i].Sales_License_Quantity__c,
                    host: tempHost,
                    avlTempLic: this.targetLicensesRaw[i].Sales_License_Available_Temp_Licenses__c,
                    comments: this.targetLicensesRaw[i].Sales_License_Comments_Txt__c,
                    maintExpDt: this.targetLicensesRaw[i].Sales_License_Maintenance_Exp_Dt__c,
                    licStatus: this.targetLicensesRaw[i].Sales_License_Status__c,
                    hostId: this.targetLicensesRaw[i].Sales_License_Host_Node_Id__c
                }

                this.targetLicenses.push(dataRec);
                this.targetLicensesAll.push(dataRec);
            }

        }
    }

    handleClose(event) {
        this.createComputer = false;
        this.disableInput = true;
        this.isLoaded = true;

        /* newLicenseDetails({ ids: this.newlicenseIds }).then(result => {
             //this.parseResult(result);
         }).catch(error => {
             console.log('Error -->' + JSON.stringify(error))
         })*/
    }
    handleclick() {
        var el = this.template.querySelector('lightning-datatable');
        console.log(el);
        var selected = el.getSelectedRows();
        console.log(selected);
    }

    handleRadioBtnChange(event) {
        this.showSplittedLicenses = false;
        if (event.target.value === 'AllSeatsToOne') {
            this.noOfServers = 1;
        } else {
            this.noOfServers = this.noOfSeats;
        }
        this.prepareSplittedLicenseRecordData();
        this.showSplittedLicenses = true;
    }

    prepareSplittedLicenseRecordData() {
        this.data = [];
        var compname = '';
        if (this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__r.value != undefined) {
            compname = this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__r.value.fields.Name.value;
        }
        var noOfSeatsRemaining = this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value - this.noOfSeats;
        let dataRecord = {
            prodName: this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Name.value,
            prodOpn: this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Core_OPN__c.value,
            maintExp: this.licenseRecordToSplit.fields.Sales_License_Maintenance_Exp_Dt__c.value,
            activationCode: this.licenseRecordToSplit.fields.Sales_License_Activation_Code__c.value,
            webdisplayFlag: this.licenseRecordToSplit.fields.Sales_License_Web_Display_Flag__c.value,
            compName: compname,
            noOfSeatsCurr: this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value,
            noOfSeatsSplit: noOfSeatsRemaining,
            showBtn: true

        }

        this.data.push(dataRecord);
        var count = 0;
        var noOfSeatsAfterSplit = 0;
        if (this.noOfServers == 1) {
            noOfSeatsAfterSplit = this.noOfSeats;
        } else {
            noOfSeatsAfterSplit = 1;
        }

        while (count < this.noOfServers) {
            let dataRecord1 = {
                prodName: this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Name.value,
                prodOpn: this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Core_OPN__c.value,
                maintExp: this.licenseRecordToSplit.fields.Sales_License_Maintenance_Exp_Dt__c.value,
                activationCode: this.licenseRecordToSplit.fields.Sales_License_Activation_Code__c.value,
                webdisplayFlag: this.licenseRecordToSplit.fields.Sales_License_Web_Display_Flag__c.value,
                compName: compname,
                noOfSeatsCurr: ' ',
                noOfSeatsSplit: noOfSeatsAfterSplit,
                showBtn: true

            }

            this.data.push(dataRecord1);
            count = count + 1;

        }

    }
    checkIfLicenseIsValid() {

        var isValid = true;
        var today = new Date();

        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;



        // Return the date in "YYYY-MM-DD" format
        //let today = rightNow.toISOString().slice(0,10);
        console.log('product type:' + this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value);
        console.log('this.noOfSeats:' + this.noOfSeats);
        this.toolType = this.licenseRecordToSplit.fields.Sales_Tool_License_Type__c.value;
        if (this.licenseRecordToSplit != undefined && this.toolType != 'FLOAT' && this.toolType != 'NEUTRAL' && this.toolType != 'N-A') {
            isValid = false;
            if (this.isMergeSeats == true) {
                this.errorMsg = this.label.Sales_MergeSeats_ProdTypeError;
            } else {
                this.errorMsg = this.label.Sales_Split_ProdTypeError;
            }
            this.isNotFloatProd = true;
            this.isError = true;
        }
        else if (this.noOfSeats != undefined && ((this.noOfSeats >= this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value && this.isMergeSeats == false) || (this.noOfSeats > this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value && this.isMergeSeats == true))) {
            console.log('405:' + this.noOfSeats);
            if (this.isMergeSeats == true) {
                isValid = false;
                this.errorMsg = this.label.Sales_Merge_NoOfSeatsError;
            }
            if(!this.isSplitSuccessfull && (!this.isMergeSeats))
            {
                console.log('412:'+this.noOfSeats);
                isValid = false;
                this.errorMsg = this.label.Sales_Split_NoOfSeatsError;
            }
            this.isNotFloatProd = false;
        } else if (this.noOfSeats != undefined && this.noOfSeats <= 0) {
            isValid = false;
            this.errorMsg = this.label.Sales_NoOfSeatsGreaterThanZero_Error;
            this.isNotFloatProd = false;
        } else if (this.licenseRecordToSplit != undefined && this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value <= 0) {
            isValid = false;
            if (this.isMergeSeats == true) {
                this.errorMsg = this.label.Sales_Merge_NoOfSeaterGrtThanZero_Error;
            } else {
                this.errorMsg = this.label.Sales_Split_NoOfSeatsMoreThanone_Error;
            }
            this.isNotFloatProd = false;
        } 
        
        else if (this.isMergeSeats==false && this.licenseRecordToSplit != undefined && this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value == 1)
         {
            
           
                isValid = false;
                this.errorMsg =  this.label.Sales_Split_NoOfSeatsMoreThanone_Error;
            
            this.isNotFloatProd = false;
        }




        else if (this.licenseRecordToSplit.fields.Sales_License_Status__c.value == 'Cancelled') {
            isValid = false;
            if (this.isMergeSeats == true) {
                this.errorMsg = this.label.Sales_MergeSeats_CancelledLicError;
            } else {
                this.errorMsg = this.label.Sales_SplitSeats_CancelledLicError;
            }
            this.isNotFloatProd = false;
        } else if (this.licenseRecordToSplit.fields.Sales_License_Status__c.value == 'Renewals Applied' && this.isMergeSeats == true) {
            isValid = false;
            this.errorMsg = this.label.Sales_MergeSeats_RenewalsAppliedError;
            this.isNotFloatProd = false;

        } else if ((this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value == 'ADD SEAT' || this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Core_Product_Ext_Attribute_Id__r.value.fields.Core_Prod_Tool_Type_Nm__c.value == 'RENEWAL') && this.isMergeSeats == false) {
            isValid = false;
            this.errorMsg = this.label.Sales_SpliSeats_ADDSEATError;
            this.isNotFloatProd = false;
        } else if ((this.licenseRecordToSplit.fields.Sales_License_Type__c.value == 'Renewal' || this.licenseRecordToSplit.fields.Sales_License_Type__c.value == 'Optional' || this.licenseRecordToSplit.fields.Sales_License_Type__c.value == 'Evaluation') && this.isMergeSeats == true) {
            isValid = false;
            this.errorMsg = this.label.Sales_MergeSeats_RENEWALError;
            this.isNotFloatProd = false;
        } else if (this.licenseRecordToSplit == undefined) {
            isValid = false;
            this.errorMsg = this.label.Sales_UnableToProceedError;
            this.isNotFloatProd = false;
        } else if (this.isMergeSeats == true && this.licenseRecordToSplit.fields.Sales_License_Expiration_Date_Dt__c.value != null && this.licenseRecordToSplit.fields.Sales_License_Expiration_Date_Dt__c.value < today) {
            // console.log('time:'+today.toISOString());
            //console.log('lic exp:'+this.licenseRecordToSplit.fields.Sales_License_Expiration_Date_Dt__c.value );
            isValid = false;
            this.errorMsg = this.label.Sales_MergeSeats_ExpiredLicError;
            this.isNotFloatProd = false;
        }
        else {
            this.errorMsg = '';
            this.isNotFloatProd = false;
        }
        return isValid;
    }
    handleOnNextBtnClick() {
        console.log('validate:' + this.validateFields());
        if (!this.validateFields()) {
            const toast = new ShowToastEvent({
                message: this.label.Sales_ReviewErrors_Error,
                variant: "error",
            });
            this.dispatchEvent(toast);
        }
        else {
            if (this.isMergeSeats == true) {
                this.handleConfirmation();
            } else
                if (this.checkIfLicenseIsValid() == false) {
                    const evt2 = new ShowToastEvent({
                        title: 'Error',
                        message: this.errorMsg,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt2);
                    this.isLoaded = true;
                } else {
                    this.prepareSplittedLicenseRecordData();
                    this.isInvalidLicense = false;
                    this.showOptionsToSplit = true;
                    this.showSplitOptionsRadioBtn = true;
                }
        }
    }
    handleOnBackBtnClick() {
        this.isInvalidLicense = false;
        this.showOptionsToSplit = false;
        this.showSplitOptionsRadioBtn = false;
    }

    // cancelClickPopupBtn() {
    //     this.handleConfirmation();
    // }

    updatedRecord(event) {
        let licDet = event.detail;
        console.log('Event details -->' + JSON.stringify(licDet));
    }

    parseResult(result) {
        if (result != undefined) {
            //this.Licenseids = result;
            this.data = [];
            this.newSplittedLicenses = result;
            var compname = '';
            var hostId = '';
            var primaryCon = '';
            //console.log('new created licenses -->' + JSON.stringify(this.newSplittedLicenses));
            if (this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__r.value != undefined) {
                compname = this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__r.value.fields.Name.value;
                hostId = this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value;
            }
            if (this.licenseRecordToSplit.fields.Sales_License_Primary_Admin_Contact__c != undefined) {
                primaryCon = this.licenseRecordToSplit.fields.Sales_License_Primary_Admin_Contact__c.value;
            }
            var noOfSeatsRemaining = this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value - this.noOfSeats;
            let dataRecord = {
                licenseType: this.licenseRecordToSplit.fields.Sales_Tool_License_Type__c.value,
                primarycontact: primaryCon,
                licenseId: this.recordId,
                hostIdValue: hostId,
                prodName: this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Name.value,
                prodOpn: this.licenseRecordToSplit.fields.Sales_License_Product__r.value.fields.Core_OPN__c.value,
                maintExp: this.licenseRecordToSplit.fields.Sales_License_Maintenance_Exp_Dt__c.value,
                activationCode: this.licenseRecordToSplit.fields.Sales_License_Activation_Code__c.value,
                webdisplayFlag: this.licenseRecordToSplit.fields.Sales_License_Web_Display_Flag__c.value,
                compName: compname,
                noOfSeatsCurr: noOfSeatsRemaining,
                showBtn: false

            }
            this.data.push(dataRecord);
            this.newSplittedLicenses.forEach(element => {
                var hostName = '';
                if (element.Sales_License_Host_Node_Id__c != undefined) {
                    hostName = element.Sales_License_Host_Node_Id__r.Name
                }
                this.newlicenseIds += element.Id + ';';
                let dataRecord = {
                    licenseType: element.Sales_Tool_License_Type__c,
                    primarycontact: element.Sales_License_Primary_Admin_Contact__c,
                    licenseId: element.Id,
                    prodName: element.Sales_License_Product__r.Name,
                    prodOpn: element.Sales_License_Product__r.Core_OPN__c,
                    maintExp: element.Sales_License_Maintenance_Exp_Dt__c,
                    activationCode: element.Sales_License_Activation_Code__c,
                    webdisplayFlag: element.Sales_License_Web_Display_Flag__c,
                    compName: hostName,
                    noOfSeatsCurr: element.Sales_License_Quantity__c,
                    hostIdValue: element.Sales_License_Host_Node_Id__c,
                    showBtn: false
                }

                this.data.push(dataRecord);

            });

            //this.navigateToLicenseRecord();            
        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: this.label.Sales_SplitMergeSeats_Error,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            this.isLoaded = true;
            this.handleOnBackBtnClick();
            this.isInvalidLicense = true;
        }
    }

    handleConfirmation() {
        this.isLoaded = false;
        this.isInvalidLicense = true;
        console.log('Source host Id', this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c);
        //console.log('Target host Id',this.targetLicenseRecSelected[0].hostId);
        if (this.checkIfLicenseIsValid() == false) {
            const evt2 = new ShowToastEvent({
                title: 'Error',
                message: this.errorMsg,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt2);
            this.isLoaded = true;
            this.isInvalidLicense = false;
        } else {
            let licRec = {
                sobjectType: LICENSE_OBJECT.objectApiName,
                Id: this.recordId,
                Name: this.licenseRecordToSplit.fields.Name.value,
                Sales_License_Quantity__c: this.licenseRecordToSplit.fields.Sales_License_Quantity__c.value,
                // Sales_License_Order_Product__c: this.licenseRecordToSplit.fields.Sales_License_Order_Product__c.value,
                Sales_License_Avbl_Qty_Nbr__c: this.licenseRecordToSplit.fields.Sales_License_Avbl_Qty_Nbr__c.value,
                Sales_License_Status__c: this.licenseRecordToSplit.fields.Sales_License_Status__c.value,
                Sales_License_Maintenance_Exp_Dt__c: this.licenseRecordToSplit.fields.Sales_License_Maintenance_Exp_Dt__c.value,
                Sales_License_Avbl_Rehost_Nbr__c: this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value,
                Sales_License_Host_Node_Id__c: this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value,
                Sales_License_Comments_Txt__c: this.licenseRecordToSplit.fields.Sales_License_Comments_Txt__c.value,
                Sales_License_Web_Display_Flag__c: this.licenseRecordToSplit.fields.Sales_License_Web_Display_Flag__c.value,
                Sales_License_Available_Temp_Licenses__c: this.licenseRecordToSplit.fields.Sales_License_Available_Temp_Licenses__c.value,
                Sales_License_Expiration_Date_Dt__c: this.licenseRecordToSplit.fields.Sales_License_Expiration_Date_Dt__c.value
            }
            //    console.log('recordId-->'+recordId);
            console.log('temp = ' + licRec.Sales_License_Available_Temp_Licenses__c + 'actual = ' + licRec.Sales_License_Quantity__c);
            console.log('rehost = ' + this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value);

           /* if(licRec.Sales_License_Quantity__c==1){
                var errorMsg;
                this.errorMsg = 'Number of seats to merge cannot be greater than number of seats on source License';
            }
            else*/ if (this.isMergeSeats == true) {
                var errorMsg;

                if (this.targetLicenseRecSelected == undefined) {
                    errorMsg = this.label.Sales_MergeSeats_SelectTargetError;
                }
                else if (this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value != null
                    && this.targetLicenseRecSelected[0].hostId !== undefined
                    && this.targetLicenseRecSelected[0].hostId != this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value
                    && this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value != undefined && this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value == 0) {
                    console.log('Inside condition check');
                    console.log('Source host Id', this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value);
                    console.log('Target host Id', this.targetLicenseRecSelected[0].hostId);
                    errorMsg = this.label.Sales_MergeSeats_RehostError;
                }
                else if (this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value != null
                    && this.targetLicenseRecSelected[0].hostId !== undefined
                    && this.targetLicenseRecSelected[0].hostId != this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value
                    && this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value == undefined) {
                    console.log('Inside condition check');
                    console.log('Source host Id', this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value);
                    console.log('Target host Id', this.targetLicenseRecSelected[0].hostId);
                    errorMsg = this.label.Sales_MergeSeats_RehostError;
                }

                else if (this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value != null
                    && this.targetLicenseRecSelected[0].hostId == null
                    && this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value != undefined && this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value == 0) {
                    console.log('Inside condition check');
                    console.log('Source host Id1', this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value);
                    console.log('Target host Id1', this.targetLicenseRecSelected[0].hostId);
                    errorMsg = this.label.Sales_MergeSeats_RehostError;
                }
                else if (this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value != null
                    && this.targetLicenseRecSelected[0].hostId == null
                    && this.licenseRecordToSplit.fields.Sales_License_Avbl_Rehost_Nbr__c.value == undefined) {
                    console.log('Inside condition check');
                    console.log('Source host Id', this.licenseRecordToSplit.fields.Sales_License_Host_Node_Id__c.value);
                    console.log('Target host Id', this.targetLicenseRecSelected[0].hostId);
                    errorMsg = this.label.Sales_MergeSeats_RehostError;
                }
                if (errorMsg != undefined) {
                    this.isInvalidLicense = false;
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: errorMsg,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.isLoaded = true;
                } else {
                    console.log('targetLicenseRecSelected:' + this.targetLicenseRecSelected[0].id);

                    let targetLicRec = {
                        sobjectType: LICENSE_OBJECT.objectApiName,
                        Id: this.targetLicenseRecSelected[0].id,
                        Name: this.targetLicenseRecSelected[0].name,
                        // Sales_License_Order_Product__c: this.targetLicenseRecSelected[0].ordProd,
                        Sales_License_Avbl_Qty_Nbr__c: this.targetLicenseRecSelected[0].avlbQty,
                        Sales_License_Status__c: this.targetLicenseRecSelected[0].status,
                        Sales_License_Quantity__c: this.targetLicenseRecSelected[0].noOfSeatsCurr,
                        Sales_License_Available_Temp_Licenses__c: this.targetLicenseRecSelected[0].avlTempLic,
                        Sales_License_Comments_Txt__c: this.targetLicenseRecSelected[0].comments,
                        Sales_License_Maintenance_Exp_Dt__c: this.targetLicenseRecSelected[0].maintExpDt,
                        Sales_License_Status__c: this.targetLicenseRecSelected[0].licStatus,
                        Sales_License_Host_Node_Id__c: this.targetLicenseRecSelected[0].hostId,
                        Sales_License_Expiration_Date_Dt__c: this.targetLicenseRecSelected[0].licExp
                    }
                    console.log('targetLicRec:' + JSON.stringify(targetLicRec));
                    mergeLicenseRecords({
                        noOfSeatsToMerge: this.noOfSeats,
                        sourceLicRec: licRec,
                        targetLicRec: targetLicRec
                    })
                        .then(result => {
                            if (result != undefined) {
                                console.log('success');
                                const evt = new ShowToastEvent({
                                    title: 'Success',
                                    message: this.label.Sales_MergeSeats_SuccessMsg,
                                    variant: 'success',
                                    mode: 'dismissable'
                                });
                                this.dispatchEvent(evt);
                                this.isLoaded = true;
                                this.isInvalidLicense = true;
                                this.navigateToLicenseRecord(this.targetLicenseRecSelected[0].id);
                            }
                        })
                        .catch(error => {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                            this.isLoaded = true;
                        });
                }

            } else {
                this.disableBackBtn = true;

                splitLicenses({

                    licRecord: licRec,
                    noOfSeatsToSplit: this.noOfSeats,
                    noOfServers: this.noOfServers
                })
                    .then(result => {
                        this.parseResult(result);
                        this.isSplitSuccessfull = true;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: this.label.Sales_SplitSeats_SuccessMsg,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(evt);
                        this.isLoaded = true;
                        this.isInvalidLicense = true;
                        this.showOptionsToSplitMsg = true;
                        this.showSplitOptionsRadioBtn = false;
                        this.disableInput = true;
                        this.splited = true;
                    })
                    .catch(error => {
                        console.log('error' + JSON.stringify(error));

                        if (error.body.message.includes(this.label.Sales_TempLicError)) {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: this.label.Sales_TempLicError,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        } else {
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(evt);
                        }

                        this.isLoaded = true;
                    });
            }
        }
    }

    handleOnConfirmBtnClick() {
        //  console.log('This record id-->'+this.recordId);
        // this.isModalOpen = true;        
        this.handleConfirmation();
    }
    navigateToLicenseRecord(licRecId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: licRecId,
                objectApiName: 'Sales_License__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    validateFields() {
        return [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }

    handleCancelBtnClick() {
        if (this.isMergeSeats == true) {
            this.navigateToLicenseRecord(this.recordId);
            console.log('Inside if handle cancel');
        } else {
            if (this.isSplitSuccessfull == true && this.isFeedbackvisible == true) {
                console.log('inside enable feedback');
                this.enableFeedback = true;
                //   this.showModal=false;
                /*   this[NavigationMixin.Navigate]({
                      type: 'standard__component',
                      attributes: {
                          componentName: 'c__sales_EventFeedback'
                      },
                      state: {
                          c__recId: this.licenseRecordId,
                          c__capablity: this.capablity
                      }
                  }); */
            } else {
                console.log('Inside else  handle cancel' + this.isPartnerPortal);
                //this.dispatchEvent(new CloseActionScreenEvent());
                if (this.isPartnerPortal) {
                    console.log('Inside if close action  handle cancel');
                    this.dispatchEvent(new CustomEvent('quickactionclose'));
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.reloadPage();
                } else {
                    console.log('Inside else close action  handle cancel');
                    this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(new CustomEvent('quickactionclose'));
                    this.reloadPage();
                }

            }


        }

    }


    reloadPage() {

        setTimeout(function () {
            location.reload(true);
        }, 2000);
    }

    // model popup req code

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    // closeModal() {
    //     // to close modal set isModalOpen tarck value as false
    //     this.showLicenseGenrateCmp = false;
    //     this.cancelClickPopupBtn();
    //     this.isModalOpen = false;
    // }
    // submitDetails() {
    //     // to close modal set isModalOpen tarck value as false
    //     // hide main component buttons
    //     this.hideMainButtons = true;
    //     this.cancelClickPopupBtn();

    //     //   console.log('result' + result);
    //     this.showLicenseGenrateCmp = true;

    //     this.isModalOpen = false;
    // }

    handleTargetLicenseSelection(event) {
        this.targetLicenseRecSelected = event.detail.selectedRows;
        console.log('on row sel:' + this.targetLicenseRecSelected);
        console.log('on row sel2:' + event.detail.selectedRows);

    }

    inputFilterChange(event) {
        // console.log('input:'+ event.target.value);  
        if (event.target.value == undefined || event.target.value == '') {
            this.targetLicenses = this.targetLicensesAll;
        } else {
            this.targetLicenses = [];
            for (let i = 0; i < this.targetLicensesAll.length; i++) {
                //   console.log('lic:'+this.targetLicensesAll[i]);
                if (this.targetLicensesAll[i].hostName.includes(event.target.value)) {
                    //   console.log('inside');
                    this.targetLicenses.push(this.targetLicensesAll[i]);
                    // this.targetLicenses = this.targetLicensesAll.filter((hostName) =>
                    // hostName.startsWith(event.target.value)
                    // );
                }
            }
        }
    }
    showNotificationerror(title, msg, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    validateUserAccessLogic() {
        console.log('824 userId: ' + this.userId + ' recordId: ' + this.recordId);
        validateUserAccess({ userID: this.userId, recordId: this.recordId })
            .then((result) => {
                console.log('result =' + result);
                if (result == false) {
                    this.userAccessCheck=true;
                    console.log('user doesnt have access to the record');
                    //this.closeQuickAction();
                    const evt = new ShowToastEvent({
                        variant: 'error',
                        title: 'Failure',
                        mode: 'sticky',
                        message: this.label.Sales_AccessCheckMsg,
                    });
                    //
                    //this.fireToastEvent('Failure!','You cannot modify this record !! ','error','Sticky');
                    this.dispatchEvent(evt);

                    //this.dispatchEvent(new CloseActionScreenEvent());
                    this.dispatchEvent(new CustomEvent('quickactionclose'));
                }
            })
    }

}