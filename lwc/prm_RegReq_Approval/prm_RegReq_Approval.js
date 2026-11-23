import { LightningElement, track, api, wire } from 'lwc'
import { CloseActionScreenEvent } from 'lightning/actions'
//import createAccount from '@salesforce/apex/QuickActionController.createAccount';
import regreqApproveRejectNew from '@salesforce/apex/PRM_Registration_Req_Approve_Reject.regreqApproveRejectNew'
import fetchApprovalRecord from '@salesforce/apex/PRM_Registration_Req_Approve_Reject.fetchApprovalRecord'
import validateData from '@salesforce/apex/PRM_Registration_Req_Approve_Reject.validateData'
import checkCompanyValidationStatus from '@salesforce/apex/PRM_Registration_Req_Approve_Reject.checkCompanyValidationStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import {getRecordNotifyChange } from 'lightning/uiRecordApi'
import PRM_BlockedAccountError from '@salesforce/label/c.PRM_BlockedAccountError';
import PRM_BlockedContError_IPA from '@salesforce/label/c.PRM_BlockedContError_IPA';
import 	PRM_ErrorMsg_BlockDomain from '@salesforce/label/c.PRM_ErrorMsg_BlockDomain';
import PRM_CDB_ValidationInProgress from '@salesforce/label/c.PRM_CDB_Company_Validation_In_Progress_Msg';

export default class Prm_RegReq_Approval extends LightningElement {
  @api recordId 
  recordDetail
  @track comments
  @track approvalInstanceId
  @track companyNameToPass
  @track altLangToPass
  isSpinner = true
  status
  @track showSave = false
  callDataValidated = true
  isDataValid
  callFetchApproval = true
  infoMsg = ''
  @track companyName
  @track companyLang
  @track errorMessage
  isError = false
  isBlocked=false
  iscompanyPresent = true
  isAltLangPresent = true
  errorMessage = 'Please fill in following required field/s before Approval:'
  errorMessages = [];
  otherError = false

  handleOnLoad () {
    //this.isSpinner = true;
    validateData({ regReqId: this.recordId })
      .then(result => {
        console.log('>>>>result' + JSON.stringify(result))
        if (result == 'Success') {
          fetchApprovalRecord({ regReqId: this.recordId })
            .then(result1 => {
              this.otherError = false;
              console.log('>>>>result1' + JSON.stringify(result1))
              this.showSave = true;
              if (!result1.workItemId) {
                this.otherError = true;
                console.log('>>>>Inside error 51')
                this.showtoastMessage(
                  'Error',
                  'You Dont have access to Approve this record.',
                  'error'
                )
                this.closeAction();
              } else if(result1.blockedEmailDomain){ 
                console.log('>>>>Inside error 60')// IPA 2.0 - TWC729-8020
                this.otherError = true 
                this.showtoastMessage(
                  'Error',
                  PRM_ErrorMsg_BlockDomain,
                  'error'
                  )
                  this.isSpinner = false
                  this.closeAction();
                } else {
                  console.log('>>>>Inside error 70')
                
                this.approvalInstanceId = result1.workItemId
                //to show required fields missing message
                if (result1.isNewAccCreation) {
                  //read company name details
                  if (!result1.companyNameEng) {
                    this.isError = true
                    this.otherError = true
                    this.iscompanyPresent = false
                    this.errorMessages.push('Company Name - English Language');
                    this.showSave = false
                    this.isBlocked=false
                  }else {
                    this.companyNameToPass = result1.companyNameEng;
                  } 
                  //read alternate language details
                  if (!result1.companyAltLang) {
                    this.isError = true
                    this.otherError = true
                    this.errorMessages.push('Alternate Company Name Language');
                    this.showSave = false
                    this.isBlocked=false
                  } else {
                    this.altLangToPass = result1.companyAltLang;
                  }
                } 

                if(result1.blockedContact){
                  this.otherError = true
                  this.showtoastMessage(
                    'Error',
                    PRM_BlockedContError_IPA,
                    'error'
                  )
                  
                  this.isBlocked=true
                  this.isSpinner = false
                  this.isError=false;
                  this.showSave = false;
                  this.iscompanyPresent = true
                  this.errorMessages=''
                  this.errorMessage=''
                 this.closeAction();
                }
                if(result1.blockedAccount){
                  this.otherError = true
                  this.showtoastMessage(
                    'Error',
                    PRM_BlockedAccountError,
                    'error'
                  )
                  
                  this.isBlocked=true
                  this.isSpinner = false
                  this.isError=false;
                  this.showSave = false;
                  this.iscompanyPresent = true
                  this.errorMessages=''
                  this.errorMessage=''
                 this.closeAction();
                }
              }
               if(!this.otherError){
                  checkCompanyValidationStatus({ regReqId: this.recordId })
                    .then(result2 => {
                       console.log('Apex returned: ', result2);
                       console.log('otherError>> ', this.otherError);
			                var enableForAllFlag = result2.enableForAllFlag ? result2.enableForAllFlag.toLowerCase():'null';
                      if (result2.isValidationInProgress && enableForAllFlag =='true' ){
                        this.showtoastMessage(
                        'Warning!',
                        PRM_CDB_ValidationInProgress,
                        'warning'
                        )
                      }
            }).catch(error2 => {
              this.isSpinner = false
              console.log('>>>>result error 2' + JSON.stringify(error2))
            })
        }
                this.isSpinner = false
            })
            .catch(error1 => {
              this.isSpinner = false
              console.log('>>>>resultiner' + JSON.stringify(error1))
            })
            console.log('otherError 135>> ', this.otherError);
           
        } else {
          this.showtoastMessage('Error', result, 'error')
          this.isDataValid = false
          this.isSpinner = false
          this.closeAction()
        }
      })
      .catch(error => {
        this.isSpinner = false
        console.log('>>>>result' + JSON.stringify(error))
      })
      
  }

  closeAction () {
    this.dispatchEvent(new CloseActionScreenEvent())
  }

  handleSaveButton () {
    this.isSpinner = true
    this.showSave = false
    if (this.approvalInstanceId) {
      this.comments = this.template.querySelector('.prmreviewnote').value
      
      regreqApproveRejectNew({
        regReqId: this.recordId,
        approvalInstanceId: this.approvalInstanceId,
        aprovalType: 'Approved',
        reason: this.comments
      })
        .then(result => {
          if (result.flag) {
            if (result.createAccReq) {
              this.showtoastMessage(
                'Info',
                'New Account Request Record has been successfully created.',
                'success'
              )
            } else {
              this.showtoastMessage(
                'Success',
                'Registration Request is Approved',
                'success'
              )
            }
            this.callFetchApproval = false
            getRecordNotifyChange([{ recordId: this.recordId }])
          } else {
            this.infoMsg = result.message != null ? result.message : 'There is some error while approving Registration.'
            this.showtoastMessage('Error', this.infoMsg, 'error')
          }
          this.isSpinner = false
          this.dispatchEvent(new CloseActionScreenEvent())
        })
        .catch(error => {
          this.isSpinner = false
          console.log(
            'Error occured while calling regreqApproveRejectNew',
            error
          )
        })
    }
  }

  showtoastMessage (title, message, varient) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: varient
    })
    this.dispatchEvent(evt)
  }
}