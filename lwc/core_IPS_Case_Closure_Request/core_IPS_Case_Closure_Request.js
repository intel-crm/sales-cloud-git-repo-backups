import { LightningElement ,api, track,wire} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import knowledgeHelpText from '@salesforce/label/c.Core_IPS_Case_KnowledgeBaseLink';

import HideLightningHeader from '@salesforce/resourceUrl/HideLightningHeader';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import UpdateSObjects from '@salesforce/apex/CruderCntrl.UpdateSObjects';
import InsertSObjects from '@salesforce/apex/CruderCntrl.InsertSObjects';
//above 2 imports are to hide page headers]

//class import
import Core_IPS_AgentCaseClosureControllerLEX from '@salesforce/apex/Core_IPS_AgentCaseClosureControllerLEX.initialValidations';
import getAuthorType from '@salesforce/apex/Core_IPS_AgentCaseClosureControllerLEX.getAuthorType';
import getCaseClosureAccess from '@salesforce/apex/Core_IPS_AgentCaseClosureControllerLEX.getCaseClosureAccess';

import OBJECT_NAME from '@salesforce/schema/Case';
import Status_FIELD from '@salesforce/schema/Case.Status';
import SubStatus_FIELD from '@salesforce/schema/Case.Core_Sub_Status__c';
import CaseClosure_FIELD from '@salesforce/schema/Case.Core_Case_Closure__c';
import Reason_FIELD from '@salesforce/schema/Case.Core_Case_Resolution_Reason__c';
import BugDoc_FIELD from '@salesforce/schema/Case.Core_IPS_Bug_Doc_Fix_ID__c';
import KnowledgeBase_FIELD from '@salesforce/schema/Case.Core_IPS_Knowledge_Base_Link__c';
import sourceOfResolution_FIELD from '@salesforce/schema/Case.Core_IPS_CaseSource_of_Resolution__c';

import USER_ID from '@salesforce/user/Id';
import USERPROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import caseDetailPage from '@salesforce/label/c.Core_IPS_Case_Detail_Page';

// importing 2 fields for case clouse feature

import ProblemStatement_FIELD from '@salesforce/schema/Case.Core_IPS_Problem_Statement__c';
import Resolution_FIELD from '@salesforce/schema/Case.Core_IPS_Resolution__c';
import Core_IPS_Promblem_helptext from '@salesforce/label/c.Core_IPS_Promblem_helptext';
import Core_IPS_Rsolution_helptext from '@salesforce/label/c.Core_IPS_Rsolution_helptext';


const fields = [Reason_FIELD,BugDoc_FIELD,KnowledgeBase_FIELD,sourceOfResolution_FIELD,CaseClosure_FIELD,ProblemStatement_FIELD,Resolution_FIELD];

export default class Core_IPS_Case_Closure_Request extends LightningElement {

//picklist configuration values:
@track statusValue;
@track disableMe;
@track currentUserProfileName;
@track disableSOR = false;
@track error;
@track showErrormessage;
@track value;
@api recordId;
@track currenRecordId;
@track subStatusValue;
@track setRequired = false;
@track InlineHelpText;
fieldsInfo;
//to shopw error
@track showError = true;
@track showReturnBtn;
@track isSaveEnabled = false;
// for CRUD component
@track isUpdatePresent = false;
@track inputSObjectListSent = [];
@track isInserPresent= false;
@track inputSObjectListCase =[];
@track isLoaded = false;
@track fieldLabel;

// get values from UI


@track caseClosureDetails 
@track knowledgeBaselink;
@track commentToCust;
@track bugFix;
@track CaseClosurePicklist;
@track sourceOfResolution;
@track openmodel = false;
@track KnowledgeBaseLnkHelpText = knowledgeHelpText;
@track objectInfo;
@track helpText = '[Customer]';
@api CruderCntrl  =[];
caseClosureAccess = true;

// Added by Chetan -- Case Closure Fields

problemStatement;
resolution;

label ={
    Core_IPS_Promblem_helptext,
    Core_IPS_Rsolution_helptext
}


connectedCallback() {
    if(this.currentUserProfileName === 'Data Ops'){
        getCaseClosureAccess({  })
        .then(result =>{
            if(result==false){
                this.caseClosureAccess = false;
            }
            else{
                this.caseClosureAccess = true;
            }
        })
        .catch(error =>{
            console.log('Error--'+error);
        })
    }    
    //this is for heading
    loadStyle(this, HideLightningHeader)
    this.disableMe = true;
    this.openmodel = true;
    this.currenRecordId = this.recordId;

    //to check if record id null
    if(this.recordId ===undefined){
        this.showError = false;
        this.showErrormessage = 'Record id is Null';
    }
    this.checkInitialValidations();

}

isModalOpen = false;
    tooltipContent = this.KnowledgeBaseLnkHelpText;

    openModal() {
        this.isModalOpen = true;
       
    }

   closeModal() {
        this.isModalOpen =false;
    }
    
    // this object have record information
    @track ccRecord = {
        Status : Status_FIELD,
        SubStatus : SubStatus_FIELD,
        CaseClosure : CaseClosure_FIELD,
        Reason : Reason_FIELD,
        Bug : BugDoc_FIELD,
        KnowBase : KnowledgeBase_FIELD,
        SOR : sourceOfResolution_FIELD
    };

    @wire(getObjectInfo, {objectApiName : OBJECT_NAME})
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName : SubStatus_FIELD
    })  picklistValues;

    @wire(getPicklistValues, {
            recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
            fieldApiName : Status_FIELD
    })  picklistValuesStatus;
        
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName : CaseClosure_FIELD
    })  picklistValuesClosure;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName : sourceOfResolution_FIELD
    })  picklistValuesSOR;
   /* @wire(getObjectInfo, { objectApiName: OBJECT_NAME})
    getInlineHelptextInfo(result) {
        if (result.data)
            this.fieldsInfo = result.data.fields;
        console.log('wire--',JSON.stringify(result));
    } */

case;

   returnRequest(){
    var url = window.location.href; 
    var value = url.substr(0,url.lastIndexOf('/') + 1);
    window.history.back();
    return false;
    }

    checkInitialValidations(){
        this.validateRequiredFields();
        Core_IPS_AgentCaseClosureControllerLEX({ caseID: this.recordId })
            .then(result =>{
                console.log('result'+result);
                if(result ===null){
                    console.log("hey"+result);
                }else{
                    console.log("Error"+result);
                    this.showError = false;
                    this.showErrormessage = result;
                }
            })
    }
  

    //get the values from UI
    handleComboboxChange(event) { 
        
        this.CaseClosurePicklist = event.target.value;
        
        this.validateRequiredFields();
     }

     
    handleBugFix(event) {
        
        this.bugFix = event.target.value;
    }


    handleCommentToCust(event) {
        
        this.commentToCust = event.target.value;
        
        this.validateRequiredFields();
       
    }

    handleChangeCaseClosure(event) {
        
        this.caseClosureDetails = event.target.value;
        this.validateRequiredFields();
    }
    handleKnowledgeBase(event) {
        
        this.knowledgeBaselink = event.target.value;
    }
    handleSourceOfResolution(event) {
        
        this.sourceOfResolution = event.target.value;
    }

    // Added by -- Chetan ----- Case closure  start

    handleProblemStatement(event){
        this.problemStatement = event.target.value;
    }

    handleResolution(event){
        this.resolution = event.target.value;
    }

    // End


    validateRequiredFields() {
        //var flag = false;
        //if((this.CaseClosurePicklist === 'Intel > Customized Solution' || this.CaseClosurePicklist === 'Intel > No Fix/Not To Be Fixed' || this.CaseClosurePicklist === 'Intel > Answered General Inquiry' || this.CaseClosurePicklist === 'Customer > Duplicate' ) && ( this.caseClosureDetails === null || this.caseClosureDetails === '' || this.caseClosureDetails === undefined)) {
        if(this.CaseClosurePicklist === 'Intel > Customized Solution' || this.CaseClosurePicklist === 'Intel > No Fix/Not To Be Fixed' || this.CaseClosurePicklist === 'Intel > Answered General Inquiry' || this.CaseClosurePicklist === 'Customer > Duplicate' ) {
            this.setRequired = true;
        } 
        else{ 
            this.setRequired = false;   
        }
        //if(this.CaseClosurePicklist === undefined || this.CaseClosurePicklist === null || this.CaseClosurePicklist === '' || this.commentToCust === undefined || this.commentToCust === null || this.commentToCust === ''|| ((this.CaseClosurePicklist === 'Intel > Customized Solution' || this.CaseClosurePicklist === 'Intel > No Fix/Not To Be Fixed' || this.CaseClosurePicklist === 'Intel > Answered General Inquiry' || this.CaseClosurePicklist === 'Customer > Duplicate' ) && (this.caseClosureDetails == null || this.caseClosureDetails == undefined || this.caseClosureDetails == '')) ) {
        if(this.CaseClosurePicklist === undefined || this.CaseClosurePicklist === null || this.CaseClosurePicklist === '' || this.commentToCust === undefined || this.commentToCust === null || this.commentToCust === ''|| ((this.setRequired == true) && (this.caseClosureDetails == null || this.caseClosureDetails == undefined || this.caseClosureDetails == '')) ) { 
        //  flag = false;
          this.isSaveEnabled = true; 
        } else {
            //flag = true;
                this.isSaveEnabled = false;  
        }
        //return flag;
    }

    saveRequest(){
        var caseList = [];
        //var flag = this.validateRequiredFields();
        //console.log('flag '+ flag);
        this.isLoaded = true;
        //if(flag) {
            //console.log('inside if ');
            let Case = {
                Id : this.recordId,
                //Description: "this is description changed by CRUD",
                Status: "Open",
                Core_Sub_Status__c: "Close-Pending",
                Core_IPS_Date_Time_Close_Pending__c: new Date(),
                Core_Case_Closure__c: this.CaseClosurePicklist,
                Core_IPS_CaseSource_of_Resolution__c: this.sourceOfResolution,
                Core_Case_Resolution_Reason__c:this.caseClosureDetails,
                Core_IPS_Bug_Doc_Fix_ID__c: this.bugFix,
                Core_IPS_Knowledge_Base_Link__c: this.knowledgeBaselink,

                //Added by Chetan - Case -Clousure

                Core_IPS_Problem_Statement__c: this.problemStatement,
                Core_IPS_Resolution__c:  this.resolution,

            }
            
            caseList = [...caseList, Case]; 
            this.inputSObjectListCase =caseList;
            //this.isUpdatePresent = true;
            console.log('in crud12Update'+JSON.stringify(this.inputSObjectListCase));
        UpdateSObjects( { inputSObjectList: this.inputSObjectListCase } )
        .then(results => {
        if(results!=undefined){
            console.log('ResultUpdate ', JSON.stringify(results));
           /* this.results.forEach(function (value){
                this.CruderCntrl.push(value);
            })*/
            //console.log( this.CruderCntrl.length);
            //console.log( this.CruderCntrl[3].sObjID);
            this.insertComment();
            //return refreshApex(this.CruderCntrl);
        }       
    })
    .catch(error => {
            })    
            //this.closeQuickAction();
        //}
    }
    insertComment(){
        var commentList=[];
        getAuthorType()
            .then(result =>{
                //this.caseClosureDetails,
                let authorType = '';
                if(result) {
                    authorType = result;
                }
                /*this.inputSObjectListSent =[{sobjectType : "Core_IPS_Case_Comments__c",
                    Core_IPS_Case__c : this.recordId,
                    Core_IPS_Rich_Comment__c : this.commentToCust, 
                    Core_IPS_Case_Comment_Type__c :'Public to Customers',
                    Core_IPS_Comment_Author_Type__c : authorType   
                }];*/
                let comment = {
                    sobjectType : "Core_IPS_Case_Comments__c",
                    Core_IPS_Case__c : this.recordId,
                    Core_IPS_Rich_Comment__c : this.commentToCust, 
                    Core_IPS_Case_Comment_Type__c :'Public to Customers',
                    Core_IPS_Comment_Author_Type__c : authorType,
                }
                commentList = [...commentList,comment];
                this.inputSObjectListSent = commentList;
                console.log('Comment->'+JSON.stringify(comment));
                //this.isInserPresent = true;
                InsertSObjects ( { inputSObjectList: this.inputSObjectListSent } )
        .then(results => {
           if(results!=undefined){
              console.log('ResultInsertIncrud ', JSON.stringify(results));
              this.isLoaded = false;
              this.showSuccessToast();
              this.closeQuickAction();
              
             this.RefreshValues();
           }      
        })
        .catch(error => {
            console.error('Error in Insert ', error);
        })   
    
                
              /*  this.isLoaded = false;
                this.showSuccessToast();
                //eval("$A.get('e.force:refreshView').fire();");
                debugger;
                //window.open('/lightning/r/Case/' + this.recordId + '/view', '_top');
                //window.location.href = caseDetailPage + this.recordId + '/view'
                this.closeQuickAction();
                console.log('PBS-callrefresh');
                this.RefreshValues();*/
            })
            .catch(error=>{
                console.error('Error in loading Core_IPS_Comment_Author_Type__c ', error);
            })
    }
    showSuccessToast() {
        debugger;
        const evt = new ShowToastEvent({
            title: 'Record Updated',
            message: 'Record Updated  ',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    closeQuickAction() {
        this.openmodel = false;
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
        debugger;
       window.location.reload();

    }
     RefreshValues() {
            console.log('PBS-refresh');
            //await new Promise(resolve => setTimeout(resolve, 1500));
            window.location.reload();
    }        
    
    @wire(getRecord, { recordId: USER_ID, fields: [USERPROFILE_NAME]}) 
    userDetails({error, data}) {
        if (data) {
            this.currentUserProfileName = data.fields.Profile.value.fields.Name.value; 
            if(this.currentUserProfileName === 'Data Ops'){
                this.disableSOR = true;
            }else{
                this.disableSOR = false;
            }
        } else if (error) {
            this.showErrormessage = error ;
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields}) 
    caseClosure;
            get bugFixValue() {
                let bugFixTemp = getFieldValue(this.caseClosure.data, BugDoc_FIELD);
                if(bugFixTemp!= undefined && bugFixTemp != null && bugFixTemp!='' && (this.bugFix == undefined || this.bugFix == null || this.bugFix == '')){
                   this.bugFix = getFieldValue(this.caseClosure.data, BugDoc_FIELD);
                } 
                return getFieldValue(this.caseClosure.data, BugDoc_FIELD);
            }
            get caseClosureDetailsValue() {
                let caseClosureDetailsTemp = getFieldValue(this.caseClosure.data, Reason_FIELD);
                console.log('get caseClosureDetails 1',caseClosureDetailsTemp);
                if(caseClosureDetailsTemp!= undefined && caseClosureDetailsTemp != null && caseClosureDetailsTemp!='' && (this.caseClosureDetails == undefined || this.caseClosureDetails == null || this.caseClosureDetails == '')){
                   this.caseClosureDetails = getFieldValue(this.caseClosure.data, Reason_FIELD);
                   console.log('get caseClosureDetailsValue 2',this.caseClosureDetails);
                } 
                console.log('get caseClosureDetailsValue 3',getFieldValue(this.caseClosure.data, Reason_FIELD));
                return getFieldValue(this.caseClosure.data, Reason_FIELD);
            }
            get knowledgeBaselinkValue() {
                let knowledgeBaselinkTemp = getFieldValue(this.caseClosure.data, KnowledgeBase_FIELD);
                if(knowledgeBaselinkTemp!= undefined && knowledgeBaselinkTemp != null && knowledgeBaselinkTemp!='' && (this.knowledgeBaselink == undefined || this.knowledgeBaselink == null || this.knowledgeBaselink == '')){
                   this.knowledgeBaselink = getFieldValue(this.caseClosure.data, KnowledgeBase_FIELD);
                } 
                return getFieldValue(this.caseClosure.data, KnowledgeBase_FIELD);
            }
            get sourceOfResolutionValue() {
                let sourceOfResolutionTemp = getFieldValue(this.caseClosure.data, sourceOfResolution_FIELD);
                if(sourceOfResolutionTemp!= undefined && sourceOfResolutionTemp != null && sourceOfResolutionTemp!='' && (this.sourceOfResolution == undefined || this.sourceOfResolution == null || this.sourceOfResolution == '')){
                   this.sourceOfResolution = getFieldValue(this.caseClosure.data, sourceOfResolution_FIELD);
                } 
                return getFieldValue(this.caseClosure.data, sourceOfResolution_FIELD);
            }
            get CaseClosurePicklistValue() {
                let caseClosureTemp = getFieldValue(this.caseClosure.data, CaseClosure_FIELD);
                if(caseClosureTemp!= undefined && caseClosureTemp != null && caseClosureTemp!='' && (this.CaseClosurePicklist == undefined || this.CaseClosurePicklist == null || this.CaseClosurePicklist == '')){
                   this.CaseClosurePicklist = getFieldValue(this.caseClosure.data, CaseClosure_FIELD);
                } 
                return getFieldValue(this.caseClosure.data, CaseClosure_FIELD);
            }
    

        // Added by Chetan ---- Case Clouser Edit Functionality
            get problemStatementValue(){
                let problemStatementTemp = getFieldValue(this.caseClosure.data, ProblemStatement_FIELD);
                if(problemStatementTemp!= undefined && problemStatementTemp != null && problemStatementTemp!='' && (this.problemStatement == undefined || this.problemStatement == null || this.problemStatement == '')){
                   this.problemStatement = getFieldValue(this.caseClosure.data, ProblemStatement_FIELD);
                } 
                return getFieldValue(this.caseClosure.data, ProblemStatement_FIELD);
            }

            get resolutionValue(){
                let resolutionTemp = getFieldValue(this.caseClosure.data, Resolution_FIELD);
                if(resolutionTemp!= undefined && resolutionTemp != null && resolutionTemp!='' && (this.resolution == undefined || this.resolution == null || this.resolution == '')){
                    this.resolution = getFieldValue(this.caseClosure.data, Resolution_FIELD);
                 } 
                 return getFieldValue(this.caseClosure.data, Resolution_FIELD);
            }

    
}