import { LightningElement,track,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult'; // Changed by tushar for security venuability 
import getCaseCommentsForLWC from '@salesforce/apex/core_IPS_LEXAddCommentController.getCaseCommentsForLWC';// Changed by tushar for security venuability 
import search from '@salesforce/apex/core_IPS_LEXAddCommentController.search';
import getCase from '@salesforce/apex/Core_IPS_NewMapHomePageController.getCase';
//mport getSearchResults from '@salesforce/apex/Core_IPS_NewMapHomePageController.getSearchResults';
import clear from '@salesforce/apex/core_IPS_LEXAddCommentController.clear';
import salesLabel from '@salesforce/label/c.Core_IPS_CaseRTF_Intel_Sales_Representative';
import privateToPartner from '@salesforce/label/c.Core_IPS_CaseRTF_Private_To_Partner';
import technicalSpec from '@salesforce/label/c.Core_IPS_CaseRTF_Intel_Technical_Specialist';
import noteType from '@salesforce/label/c.Core_IPS_CaseRTF_Notetype_PrivateToAgents';
import privateToIntel from '@salesforce/label/c.Core_IPS_CaseRTF_Private_To_Intel';
import dataMigration from '@salesforce/label/c.Core_IPS_Data_Migration_Profile_Name';
import getRequiredValues from '@salesforce/apex/core_IPS_LEXAddCommentController.getRequiredValues';
export default class Core_IPS_caseComments extends NavigationMixin(LightningElement) {
    @api isLightningMode;
    hasRendered = false;
    records;
    fieldName = 'Core_IPS_Comment__c';
    extUser;
    partnerType;
    partDFAEUser;
    externalUser;
    isNACCase;
    partnerAgentUser;
    userHasAccess;
    caseId;
    label = {salesLabel};
    sectionNames = [];
    tempVar = [];
    @track showButton = true;
    @api recordId;
    @track show;
    @track comments =[];
    @track commentDataTableData=[];
    @track searchText= '';
    connectedCallback() {
        getCase({
            recordId : this.recordId
        })
        .then(data=>{
            if(data == 'Closed'){
                this.showButton = false;
            }  
        })
        this.getRequiredValuesMethod();
    }
    getRequiredValuesMethod(){
        getRequiredValues({
            recordId : this.recordId
        })
        .then(data => {
            if(data){
                let obj = JSON.parse(data);
                this.extUser = obj.extUser;
                this.partnerType = obj.partnerType;
                this.partDFAEUser = obj.partDFAEUser;
                this.externalUser = obj.externalUser;
                this.isNACCase = obj.isNACCase;
                this.partnerAgentUser = obj.partnerAgentUser;
                this.userHasAccess = obj.userHasAccess;
                this.getRecentComments();
            }
        })
        .catch(error =>{
            console.log('  Error : ', error.message);
        })
    }
    getRecentComments() {
        var commentAuthoredBy;
        var commentAccountBy;
        var authoredByEmail;
        var createdOnDate;
        this.caseId = this.recordId;
        /*Start -- Tushar -- 14/05/2026 --- CRUD Added as part of vulnerability fix. */
        getCaseCommentsForLWC({ caseId: this.recordId })
            .then(data => {
                if (data) {
                    /*END -- Tushar -- 14/05/2026 --- CRUD Added as part of vulnerability fix. */
                    //console.log('data debug cs for ips agent '+ JSON.stringify(data));
                    this.records = data;     
                    this.hasRendered = false;  
                    for (let i = 0; i < data.length; i++) {
                        //console.log('record check cs ', data[i]);
                        this.sectionNames = [...this.sectionNames, i];
                        commentAuthoredBy = (data[i].Core_IPS_Comment_Authored_By_Name__c!=null) ?data[i].Core_IPS_Comment_Authored_By_Name__c : '';
                        authoredByEmail = (data[i].Core_IPS_Comment_Authored_By_Email__c!=null) ?data[i].Core_IPS_Comment_Authored_By_Email__c+' '+'-'+' ' : '';
                        if(data[i].Core_IPS_Comment_Authored_By_Name__c == null && data[i].Core_IPS_Comment_Authored_By_Email__c == null){
                            commentAuthoredBy = data[i].CreatedBy.Name;
                            authoredByEmail = data[i].CreatedBy.Email;
                        }
                        createdOnDate= new Date(new Date(data[i].CreatedDate)).toLocaleString([], {year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit'});
                        console.log(commentAuthoredBy+'  '+authoredByEmail+' '+createdOnDate);
                        let obj = {
                            'Id': i,
                            'Comment': data[i].Core_IPS_Rich_Comment__c,
                            'CaseAuthorizeName' : commentAuthoredBy + '   ' + authoredByEmail+'  '+createdOnDate,          
                            'isExternal' : false 
                        };
                        
                        if((data[i].Core_IPS_Comment_Author_Type__c == 'Customer' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner - DFAE') && data[i].Core_IPS_Case_Comment_Type__c =='Public to Customers'){ 
                            obj.isExternal = true;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.extUser) && this.partnerType != 'Partner')&&(data[i].Core_IPS_Comment_Author_Type__c == 'Partner - DFAE')&&(data[i].Core_IPS_Case_Comment_Type__c == 'Private to Partner')){
                            obj.isExternal = true;
                            obj.CaseAuthorizeName = privateToPartner +'  '+ commentAuthoredBy +'  '+ authoredByEmail +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if(this.externalUser && !(this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c == 'Public to Customers'){
                            obj.CaseAuthorizeName = commentAuthoredBy +'   '+ this.label + '  '+createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj]; 
                        }
                        if((!(this.extUser) && this.partnerType!='Partner') && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner' && this.partnerType=='Partner - DFAE'){
                            obj.CaseAuthorizeName = privateToPartner +'   '+ commentAuthoredBy +'    '+ this.label +'   '+createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj]; 
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            obj.CaseAuthorizeName = privateToPartner + '  '+ commentAuthoredBy +'   '+ salesLabel +'   '+ authoredByEmail +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            obj.CaseAuthorizeName = commentAuthoredBy +'   '+ salesLabel +'   '+ authoredByEmail +'    '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            obj.CaseAuthorizeName = privateToIntel + '  '+ commentAuthoredBy +'   '+ salesLabel +'   '+ authoredByEmail +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((this.externalUser && !(this.partnerAgentUser)) && (data[i].Core_IPS_Comment_Author_Type__c == 'Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers' ){
                            obj.CaseAuthorizeName = commentAuthoredBy +'   '+ technicalSpec +'   '+ createdOnDate; 
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.extUser)&&this.partnerType != 'Partner') && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner' && this.partnerType=='Partner - DFAE'){
                            obj.CaseAuthorizeName = privateToPartner +'   '+ commentAuthoredBy +'   '+ technicalSpec +'   '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            obj.CaseAuthorizeName = privateToPartner +'   '+ commentAuthoredBy +'   '+ technicalSpec +'   '+ authoredByEmail +'    '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            obj.CaseAuthorizeName = commentAuthoredBy +'   '+ technicalSpec +'   '+ authoredByEmail +'   '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'System') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            obj.CaseAuthorizeName = privateToIntel +'   '+ commentAuthoredBy +'   '+ technicalSpec +'   '+ authoredByEmail +'    '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Agents' && (this.userHasAccess || this.partnerAgentUser)){
                            obj.CaseAuthorizeName = noteType +'   '+ commentAuthoredBy +'   '+ technicalSpec +'   '+ authoredByEmail +'    '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            obj.CaseAuthorizeName = privateToIntel +'  '+ technicalSpec +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if(!(this.extUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Agents' && (this.partnerAgentUser || this.userHasAccess)){
                            obj.CaseAuthorizeName = noteType +'  '+ technicalSpec +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser || this.partnerType=='Partner - DFAE') && data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            obj.CaseAuthorizeName = privateToPartner +'  '+ technicalSpec +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if(data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            obj.CaseAuthorizeName = technicalSpec +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            obj.CaseAuthorizeName = privateToIntel +'  '+ dataMigration +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser || this.partnerType=='Partner - DFAE') && data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            obj.CaseAuthorizeName = privateToPartner +'  '+ dataMigration +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if(!(this.extUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Agents' && (this.partnerAgentUser || this.userHasAccess)){
                            obj.CaseAuthorizeName = noteType +'  '+ dataMigration +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }
                        if(data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            obj.CaseAuthorizeName = dataMigration +'  '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        } 
                        /*if(data[i].Core_IPS_Comment_Author_Type__c == 'Agent' && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            obj.CaseAuthorizeName = commentAuthoredBy +'   '+ technicalSpec +'   '+ authoredByEmail +'   '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }*/
                       /* if(data[i].Core_IPS_Comment_Author_Type__c == 'Agent' && data[i].Core_IPS_Case_Comment_Type__c !='Public to Customers'){
                            obj.CaseAuthorizeName = data[i].Core_IPS_Case_Comment_Type__c+' '+commentAuthoredBy +'   '+ technicalSpec +'   '+ authoredByEmail +'   '+ createdOnDate;
                            this.commentDataTableData = [...this.commentDataTableData, obj];
                        }*/
                    }
                    this.hasRendered = true;
                }

            })
            .catch(error => {
                console.log('  Error : ', error.message);
            })
    }

        searchButtonHandler() {
            this.hasRendered = false;
            this.caseId = this.recordId;
            var commentAuthoredBy;
            var authoredByEmail;
            var createdOnDate;
            search({
                str : this.searchText,
                caseRec : this.caseId
            })
            .then(data => {
                if (data.length > 0) {
        
                    this.show = false;
                    let dataWrapper = [];
                    for (let i = 0; i < data.length; i++) {
                        commentAuthoredBy = (data[i].Core_IPS_Comment_Authored_By_Name__c!=null) ?data[i].Core_IPS_Comment_Authored_By_Name__c : '';
                        authoredByEmail = (data[i].Core_IPS_Comment_Authored_By_Email__c!=null) ?data[i].Core_IPS_Comment_Authored_By_Email__c+' '+'-'+' ' : '';
                        createdOnDate= new Date(new Date(data[i].CreatedDate)).toLocaleString([], {year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit'});
                        let obj = {
                            'Id': i,
                            'Comment': data[i].Core_IPS_Rich_Comment__c,
                            'CaseAuthorizeName' : commentAuthoredBy + ' ' +'('+ authoredByEmail+data[i].Core_IPS_Case_Comment_Type__c+')'+' '+createdOnDate, 
                            'isExternal' : false         
                        }; 
                        if((data[i].Core_IPS_Comment_Author_Type__c == 'Customer' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner - DFAE') && data[i].Core_IPS_Case_Comment_Type__c =='Public to Customers'){ 
                            obj.isExternal = true;
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.extUser) && this.partnerType != 'Partner')&&(data[i].Core_IPS_Comment_Author_Type__c == 'Partner - DFAE')&&(data[i].Core_IPS_Case_Comment_Type__c == 'Private to Partner')){
                            obj.isExternal = true;
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if(this.externalUser && !(this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c == 'Public to Customers'){
                            dataWrapper = [...dataWrapper, obj]; 
                        }
                        if((!(this.extUser) && this.partnerType!='Partner') && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner' && this.partnerType=='Partner - DFAE'){
                            dataWrapper = [...dataWrapper, obj]; 
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'FAE' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((this.externalUser && !(this.partnerAgentUser)) && (data[i].Core_IPS_Comment_Author_Type__c == 'Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers' ){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.extUser)&&this.partnerType != 'Partner') && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner' && this.partnerType=='Partner - DFAE'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'System') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && (data[i].Core_IPS_Comment_Author_Type__c == 'Agent' || data[i].Core_IPS_Comment_Author_Type__c == 'Partner - Agent') && data[i].Core_IPS_Case_Comment_Type__c=='Private to Agents' && (this.userHasAccess || this.partnerAgentUser)){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser)|| this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if(!(this.extUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Agents' && (this.partnerAgentUser || this.userHasAccess)){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser || this.partnerType=='Partner - DFAE') && data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if(data[i].Core_IPS_Comment_Author_Type__c == 'Backend Integration' && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Intel'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if((!(this.externalUser) || this.partnerAgentUser || this.partnerType=='Partner - DFAE') && data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Partner'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if(!(this.extUser) && data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Private to Agents' && (this.partnerAgentUser || this.userHasAccess)){
                            dataWrapper = [...dataWrapper, obj];
                        }
                        if(data[i].Core_IPS_Comment_Author_Type__c == 'Data Migration' && data[i].Core_IPS_Case_Comment_Type__c=='Public to Customers'){
                            dataWrapper = [...dataWrapper, obj];
                        }
                    }
                    this.commentDataTableData = dataWrapper;
                    this.hasRendered = true;
                 
                } else {
                    this.show = true;
                    this.commentDataTableData = [];
                }
            })
            .catch(error => {
                console.log(' Error : ', error.message);
            })
        }
        resetButtonHandler(){
            //this.hasRendered = false;
            clear();
            this.searchText='';
            this.show = false;
            [...this.template
                .querySelectorAll('input')]
                .forEach((input) => { input.value = ''; });
            this.commentDataTableData =[];
            this.getRecentComments();
            this.template.querySelector("c-core-ips-custom-lookup").removeSelected();
        }
        // Start - US943890 - Chandrashekar - Button to add comment in the recent comments component.
        handleNavigate(){
            if(this.isLightningMode == true){
                var compDefinition = {
                    componentDef: "c:core_IPS_DynamicTab",
                    attributes: {
                        recordId: this.recordId
                    }
                };
                var encodedCompDef = btoa(JSON.stringify(compDefinition));
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/one/one.app#' + encodedCompDef
                    }
                });
            } else {
                var encodedCompDef = btoa('{"componentDef":"c:core_IPS_DynamicTab","attributes":{"recordId": "'+this.recordId+'"},"state":{}}');
                window.open('/one/one.app#'+encodedCompDef,'_Self');
            }
        }
        //End - US943890
        //Start - US943890 - Chandrashekar - Button to collapse all the comments and expand all the comments.
        handleCollapse(){
            if(this.sectionNames.length > 0){
                this.tempVar = [...this.sectionNames];
                this.sectionNames = [];
            } else if(this.sectionNames.length == 0) {
                this.sectionNames = [...this.tempVar];
                this.tempVar = [];
            }
        }
        //End - US943890
        handleEvent(event){
            if(!event.detail.record){
                this.searchText = ' ';
            } else {
                this.searchText = event.detail.record.Core_IPS_Comment__c;
            }
        }
    }