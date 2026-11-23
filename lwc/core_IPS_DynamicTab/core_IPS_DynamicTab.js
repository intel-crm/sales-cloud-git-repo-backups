import {
    LightningElement,
    track,wire,
    api
} from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQueryResult from '@salesforce/apex/Core_IPS_NewMapHomePageController.getQueryResult';
import CASEID_FIELD from '@salesforce/schema/Case.Id';
import CASE_COMMENT from '@salesforce/schema/Case.Core_IPS_Date_Time_Close_Pending__c';
import CASE_CLOSEPENDING from '@salesforce/schema/Case.Core_IPS_Comment__c';
import CASE_SUBSTATUS from '@salesforce/schema/Case.Core_Sub_Status__c';
import Projetc_NAME_FIELD from '@salesforce/schema/Case.Core_IPS_Project_Case__c';
import CASEPROJECT_FIELD from '@salesforce/schema/Case.Core_IPS_Project_Case__c';
import saveComment from '@salesforce/apex/Core_IPS_AdminUtility.saveComment';
import search from '@salesforce/apex/core_IPS_LEXAddCommentController.search';
import clear from '@salesforce/apex/core_IPS_LEXAddCommentController.clear';
import salesLabel from '@salesforce/label/c.Core_IPS_CaseRTF_Intel_Sales_Representative';
import caseDetailPage from '@salesforce/label/c.Core_IPS_Case_Detail_Page';
import getRequiredValues from '@salesforce/apex/core_IPS_LEXAddCommentController.getRequiredValues';
import getattachments from '@salesforce/apex/Core_IPS_NewMapHomePageController.getattachments';
import privateToPartner from '@salesforce/label/c.Core_IPS_CaseRTF_Private_To_Partner';
import technicalSpec from '@salesforce/label/c.Core_IPS_CaseRTF_Intel_Technical_Specialist';
import noteType from '@salesforce/label/c.Core_IPS_CaseRTF_Notetype_PrivateToAgents';
import privateToIntel from '@salesforce/label/c.Core_IPS_CaseRTF_Private_To_Intel';
import dataMigration from '@salesforce/label/c.Core_IPS_Data_Migration_Profile_Name';
export default class Core_IPS_DynamicTab extends NavigationMixin(LightningElement)  {
    showOptions;
    publicToCustomernPrivateToPartner;
    projectNameField = Projetc_NAME_FIELD;
    @api objectApiName;
    privateToIntel;
    privateToAgents;
    extUser;
    partnerType;
    partDFAEUser;
    externalUser;
    isNACCase;
    partnerAgentUser;
    userHasAccess;
    records;
    sectionNames = [];
    hasRendered = false;
    @track searchText='';
    @track interestedPartyData = [];
    @api caseProjId = '';
    @track dataTableData = [];
    @track dataselected = false;
    @track atDataselected = false;
    @track comDataselected = false;
    @track attDataTableData = [];
    @track commentDataTableData = [];
    @track errorMessage = '';
    @track show;
    @api recordId;
    @track spinnerOn = false;
    @track url;
    label = {salesLabel};
    commentTypevalue = 'Private to Intel';
    @track richtext = "";
    rowLimit =10;
    rowOffSet=0;
    hideButton = false;
    
    commentColumns = [{
        label: 'Comment',
            fieldName: 'Comment',
              
    },
    {
        fieldName: 'caseCommentype',
        label:'Comment Type'
    },
    {
        fieldName: 'CaseAuthorizeName',
        label: 'Authored Name'
    },{
        fieldName: 'createdDate',
        label:'Created Date',
        type: 'date',
        typeAttributes: {  
            day: 'numeric',  
            month: 'numeric',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',  
            second: '2-digit',  
            hour12: true}
    },{
        fieldName: 'salesRepresentive',
        label: 'Sales Representive'
    } 
  ];
      
    columns = [{
            label: 'Interested Party Name',
            fieldName: 'InterestedPartyName',
        },
        {
            label: 'User',
            fieldName: 'User'

        },
        {
            label: 'Contact',
            fieldName: 'Contact',
        },
        {
            label: 'Active',
            fieldName: 'Active',
        },
        {
            label: 'First Name',
            fieldName: 'FirstName',
        },
        {
            label: 'Last Name',
            fieldName: 'LastName',
        },


    ];
    attColumns = [{
            label: 'Attachment Number',
            fieldName: 'AttachmentNumber',
        },
        {
            label: 'File Name',
            fieldName: 'FileName'

        },
        {
            label: 'File Description',
            fieldName: 'FileDescription',
        },
        {
            label: 'File Size',
            fieldName: 'FileSize',
        },
        {
            label: 'Category',
            fieldName: 'Category',
        },
        {
            label: 'Upload Status',
            fieldName: 'UploadStatus',
        },
        {
            label: 'File Download link',
            type: 'button', fieldName: 'FileDownloadLink',typeAttributes:  {label: {fieldName: 'Fieldlabelname'}, target: 'brand' }
        },
        {
            label: 'Created Date',
            fieldName: 'createddate',
        },
         {
            label: 'File Upload By',
            fieldName: 'uploadBy',
        },
        {
            label: 'Created By',
            fieldName: 'createdBy',
        },
    ];
    @track CaseObject;
    @track CaseData;
    @api validity =false;
    casesubststus;
    caseComment;
    closedPending;
    caseid;
    caseProjId;
    @wire(getRecord, 
        { recordId: '$recordId', fields: [CASEID_FIELD,CASE_COMMENT,CASE_CLOSEPENDING,CASE_SUBSTATUS,CASEPROJECT_FIELD] })
    CaseData ({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            this.casesubststus = getFieldValue(data, CASE_SUBSTATUS);
            this.caseComment = getFieldValue(data,CASE_COMMENT);
            this.closedPending = getFieldValue(data,CASE_CLOSEPENDING);
            this.caseid = getFieldValue(data, CASEID_FIELD);
            this.caseProjId = getFieldValue(data, CASEPROJECT_FIELD);
            
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log(this.FIELDS);
            console.log('CASEError'+JSON.stringify(this.error));
        }
       
    }
    renderedCallback(){
    //    this.template.querySelectorAll('.richText')[0].focus();
        this.template.querySelector('slds-radio');
    }
    connectedCallback() {
        console.log('hi im in cmp');
        console.log(this.recordId);
        this.getUploadAttachmentUrl();
        console.log('url1==sdsds',this.url);
        this.getInterestedPartyList();
        this.getAttachmentList();
        this.getRecentComments();
    }
    handleClick(event) {
        
        console.log('caseid'+this.caseid);
        let obj = {
            'casesubststus': this.casesubststus,
            'caseComment':this.richtext,
            'closedPending':this.closedPending,
            'caseid':this.caseid,
            'selectedRadioButton':this.commentTypevalue,
        }
        this.CaseObject = obj;
        if(this.richtext.trim() == '' || this.commentTypevalue == ''){
            this.showToast('Error', 'Please Insert Comment.', 'Error'); 
            this.spinnerOn = false;
        }else{
            this.hideButton = true;
            console.log('caseObject'+JSON.stringify(this.CaseObject));
        
        saveComment({newcaseJSON: JSON.stringify(this.CaseObject) })
        .then(result => {
            if(result) {
                console.log(JSON.stringify(this.result));
                this.showToast('Success', 'Case Comments Inserted.', 'success');
                this.navigateToViewCase();
                this.spinnerOn = false;
                
            }
        })
        .catch(error => {
            this.error = error;
            this.showToast('Error', 'Interested Parties insertion failed due to some error.', JSON.stringify(error));
            console.log('Error message ',error.body.message);
            this.spinnerOn = false;
        });
    }
    }
   

    accordianSection = '';

    handleToggleSection(event) {
        if (this.accordianSection.length === 0) {
            this.accordianSection = ''
        } else {
            this.accordianSection = 'Account'
        }

    }
    
    options = [{
        label: 'Public to Customers',
        value: 'Public to Customers',
        
        
    },
    {
        label: 'Private to Partner',
        value: 'Private to Partner'
       
    },
    {
        label: 'Private to Intel',
        value: 'Private to Intel'
        
    },
    {
        label: 'Private to Agents',
        value: 'Private to Agents'
        
    },
];
    //START - US943880 - 4/12/21 - Chandrashekar  - Used to calculate the rendered conditions for the comment options.
    @wire(getRequiredValues,{recordId : '$recordId'} ) 
    response({data,error}){
        if(data){
            let obj = JSON.parse(data);
            this.extUser = obj.extUser;
            this.partnerType = obj.partnerType;
            this.partDFAEUser = obj.partDFAEUser;
            this.externalUser = obj.externalUser;
            this.isNACCase = obj.isNACCase;
            this.partnerAgentUser = obj.partnerAgentUser;
            this.userHasAccess = obj.userHasAccess;
            if(!(this.extUser) && this.partnerType != 'Partner' && this.partDFAEUser != null){
                this.showOptions = true;
            } else {
                this.showOptions = false;
            }
            if((!(this.externalUser) || this.partnerType || this.partDFAEUser != null) && !(this.isNACCase)){
                this.publicToCustomernPrivateToPartner = true;
            } else {
                this.publicToCustomernPrivateToPartner = false;
            }
            if(!(this.externalUser) || this.partnerAgentUser){
                this.privateToIntel = true;
            } else{
                this.privateToIntel = false;
            }
            if(this.userHasAccess || this.partnerAgentUser){
                this.privateToAgents = true;
            } else {
                this.privateToAgents = false;
            }
        } else if(error){
            console.log('Error occured: '+error.message);
        }
    }
    get TransformedOptions(){
        let records = [];
        let commentType = this.commentTypevalue;
        let isPublicToCustomernPrivateToPartner = this.publicToCustomernPrivateToPartner;
        let isPrivateToIntel = this.privateToIntel;
        let isPrivateToAgents = this.privateToAgents;
        this.options.forEach(function(element,index){
            if((element.value === 'Public to Customers' && isPublicToCustomernPrivateToPartner === true)||(element.value === 'Private to Partner' && isPublicToCustomernPrivateToPartner === true)||(element.value ==='Private to Intel' && isPrivateToIntel === true)||(element.value === 'Private to Agents' && isPrivateToAgents === true)){
                records.push(element);
            }
        });
        if (Array.isArray(records)) {
            return records.map((record, index) => ({
                label: record.label,
                value: record.value,
                isChecked: commentType === record.value,
                indexId: `radio-${index}`
            }));
        } else {
            return [];
        }
    }
   //End - US943880
    getInterestedPartyList() {
        this.caseProjId = this.recordId;
        let searchQueryStr = ' select id , Name,First_Name__c,Last_Name__c, User__r.FirstName,User__r.LastName, Active__c from Core_IPS_Case_Interested_Party__c WHERE Case__c = \'' + this.caseProjId + '\' LIMIT 999';
        console.log(searchQueryStr);
        let firstName;
        let lastName;
        getQueryResult({
                queryString: searchQueryStr
            })
            .then(data => {
                if (data) {
                    let dataWrapper = [];
                    for (let i = 0; i < data.length; i++) {
                         if(data[i].First_Name__c == undefined ){
                            firstName = '';
                         }else{
                            firstName = data[i].First_Name__c;
                         }
                         if(data[i].Last_Name__c == undefined ){
                            lastName = '';
                         }else{
                            lastName = data[i].Last_Name__c;
                         }
                        
                        let obj = {
                            'InterestedPartyName': data[i].Name,
                            'User': data[i].User__r.FirstName +' '+ data[i].User__r.LastName,
                            'Contact': firstName +' ' + lastName,
                            'Active': data[i].Active__c,
                            'FirstName' : firstName,
                            'LastName' : lastName,
                        };
                        dataWrapper = [...dataWrapper, obj];
                    }
                    this.dataTableData = dataWrapper;
                    this.dataselected = true;
                    //console.log('wrapper' + JSON.stringify(dataWrapper));
                    console.log(this.dataTableData);
                    this.spinnerOn = false;
                    // this.showSearchRecords = this.mapRecords;
                    //this.showSupportedProducts = true;
                }

            })
            .catch(error => {
                console.error('Core_IPS_Create_Opportunity_PAR ::: Error in handleSearch. Error : ', JSON.stringify(error));
                //this.spinnerOn = false;
            })
    }
    getAttachmentList() {
        this.caseId = this.recordId;
        //let searchQueryStr = 'select id,Name,Core_File_Name__c,Core_File_URL__c,Core_File_Hyperlink__c,Core_Upload_Status__c,Core_File_Size__c,Core_Category__c,Core_File_Description__c from Core_IPS_Case_Attachments__c WHERE Core_Case__c = \'' + this.caseId + '\' LIMIT 999';
        //console.log(searchQueryStr);
        getattachments({
                caseID: this.recordId
            })
            .then(data => {
                if (data) {
                    let dataWrapper = [];
                    for (let i = 0; i < data.length; i++) {
                        console.log('URLLlll--->'+data[i].Core_File_URL__c);
                        let obj = {
                            'AttachmentNumber': data[i].Name,
                            'FileName': data[i].Core_File_Name__c,
                            'FileDescription': data[i].Core_File_Description__c,
                            'FileSize': data[i].Core_File_Size__c,
                            'Category': data[i].Core_Category__c,
                            'UploadStatus': data[i].Core_Upload_Status__c,
                            'FileDownloadLink': data[i].Core_File_URL__c,
                            'uploadBy': data[i].Core_FileUploadedBy__r.Name,
                            'createdBy':data[i].CreatedBy.Name,
                        };
                        var utcTime = new Date(data[i].CreatedDate);
                        var usaTime = utcTime.toLocaleString("en-US", {timeZone: "America/Los_Angeles",year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit'});
                        obj.createddate    = usaTime   ;
                        if( data[i].Core_Upload_Status__c == 'Complete'){
                           obj.Fieldlabelname = 'Download';
                        } else {
                           obj.Fieldlabelname = 'Resume';
                        }
                        dataWrapper = [...dataWrapper, obj];
                    }
                    this.attDataTableData = dataWrapper;
                    this.atDataselected = true;
                    console.log(this.attDataTableData);
                    this.spinnerOn = false;
                }

            })
            .catch(error => {
                console.error('Core_IPS_Create_Opportunity_PAR ::: Error in handleSearch. Error : ', JSON.stringify(error));
            })
    }
    getRecentComments() {
        var commentAuthoredBy;
        //var commentAccountBy;
        var authoredByEmail;
        var createdOnDate;
        this.caseId = this.recordId;
        let searchQueryStr = 'select id,CreatedBy.name,CreatedBy.Email,Core_IPS_Case__c,Core_IPS_Comment_Authored_By_Email__c, Core_IPS_Comment__c,Core_IPS_Rich_Comment__c,Core_IPS_Comment_Authored_By_Name__c,Core_IPS_Case_Comment_Type__c, Core_IPS_Comment_Author_Type__c, CreatedDate from Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c = \'' + this.caseId + '\' Order By CreatedDate DESC ';
        getQueryResult({
                queryString: searchQueryStr
            })
            .then(data => {
                if (data) {
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
                    }
                    this.hasRendered = true;
                }

            })
            .catch(error => {
                console.log('  Error : ', error.message);
            })
        }
        loadMoreData() {
            if(this.searchText.length === 0) {
                this.rowOffSet = this.rowOffSet + this.rowLimit;
                this.getRecentComments();
            }
        }

        searchButtonHandler() {
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
                        }; 
                        dataWrapper = [...dataWrapper, obj];
                    }
                    this.commentDataTableData = dataWrapper;
                 
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
            clear();
            this.searchText='';
            this.show = false;
            [...this.template
                .querySelectorAll('input')]
                .forEach((input) => { input.value = ''; });
            this.commentDataTableData =[];
            this.getRecentComments();
        }
        searchTextChangeHandler(event) {
            this.searchText = event.target.value;
        }

    //handle changes 
    handleCommentTypeChange(event) {
       
        this.commentTypevalue = event.target.value;
       
    }

    handleRichTextChange(event) {
        const changedRichText = event.detail.value;
       // console.log('Entered Value --> ',changedRichText);
        this.richtext = changedRichText;
        if(changedRichText == ''){
            this.errorMessage = 'Complete This Field';
            this.validity = false;
        }else{
            this.validity = true;
        }
    }
/*    handleTestRichTextChange(event){
        //console.log('Entered Value --> ',event.detail.value);
        const changedRichText = event.detail.value;
        this.richtext = changedRichText;
        if(changedRichText == ''){
            this.errorMessage = 'Complete This Field';
            this.validity = false;
        }else{
            this.validity = true;
        }
    }
    handleTestRichTextChange1(event){
        console.log('Entered Value --> ',event.detail.value);
    }*/
    handleCancel() {
		console.log('handleCancel called');
	this.navigateToViewCase();
	}

	navigateToViewCase() {
        let delayInMilliseconds = 2000; //1 second
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });

        setTimeout(function() {
            document.location.reload();
        }, delayInMilliseconds);
        
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
    handleRowActions(event){
        const handleRowActionsEvent = new CustomEvent("rowActions", {
            detail: {
                actionName: event.detail.action.name,
                row: event.detail.row
            }
        
        });
        let rec = JSON.stringify(handleRowActionsEvent);
        let record = JSON.parse(rec);
        let action = record.detail.row.Fieldlabelname;
        console.log('shobhiturl--->'+record.detail.row.FileDownloadLink);
        if(action == 'Resume'){
                localStorage.setItem('iframeurl',record.detail.row.FileDownloadLink);
                localStorage.setItem('recordId',this.recordId);
                const newWindow = window.open(this.url);
                newWindow.opener = null;//window.open(this.url,'_blank'); 
             }
            if(action == 'Download'){
                window.open(record.detail.row.FileDownloadLink); 
            }
         console.log('eventname--->'+record.detail.row.Fieldlabelname);
    }

    getUploadAttachmentUrl(){
        let testURL1 = window.location.href;
        this.url  = encodeURI(testURL1);
        let temUrl = this.url;
        let curURL = this.url.substring(8,this.url.indexOf("#"));
        temUrl = temUrl.substring(0,8);
        this.url = curURL;
        this.url = curURL.substring(0, this.url.indexOf("/"));
         console.log('Shobturl--->'+this.url);
       // this.url = window.location.href;
        if(this.url.includes('lightning')){
            console.log('url1==',this.url);
            let cururl = '/r/Case/'+this.recordId+'/view';
            let gourl = '/n/Core_IPS_Case_Attachments_LEX';
            this.url = this.url.replace(cururl,gourl);
            //this.url = this.url.replace();
            console.log('url==',this.url);
        }
         if(this.url.includes('crmdevcase')){
            this.url =   '/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
        else if(this.url.includes('crmqa3')){
            this.url =  '/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
        else if(this.url.includes('crmdevint3')){
            this.url =    '/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
        else{
            this.url =   '/lightning/n/Core_IPS_Case_Attachments_LEX';
        }
    }
}