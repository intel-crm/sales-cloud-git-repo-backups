import { LightningElement, track, api } from "lwc";
import RECORDS_LIMIT from '@salesforce/label/c.Core_IPS_RecordsLimit';
import NO_RECORDS_FOUND from '@salesforce/label/c.Core_IPS_NoRecFoundMsg';
import findRecords from "@salesforce/apex/Core_IPS_CustomLookupController.findRecords";
import findTotalRecords from "@salesforce/apex/Core_IPS_CustomLookupController.findTotalRecords";
import findTotalRecordsSosl from "@salesforce/apex/Core_IPS_CustomLookupController.findTotalRecordsSosl";
import getIPSProjListBasedOnSelectedProd from '@salesforce/apex/Core_IPS_GetProjectOnProducts_Ctrl.getIPSProjListBasedOnSelectedProd';
import PortalSiteURL from '@salesforce/label/c.Core_IPS_PortalSiteURL_LWC';

export default class Core_IPS_CustomLookup extends LightningElement {

    @api selectedRecord;
    @api iconname;
    @api queryString;
    @api searchfieldName;
    @api recordsToSearch;
    @api queryExecutionRequired;
    @api countQueryString;
    @api isSosl;

    @api isReadOnly;
    @api isRequiredField;
    @api label;
    @api placeholder;

    @api extraField1Label;
    @api extraField1;
    @api extraField2Label;
    @api extraField2;
    //Added by Chetan on 16-10-2024 -(TWC745-5178) As Part of Adding Account id to Account search  
    @api extraField3Label;
    @api extraField3;
    //minhaj
    @api assetId;


    @track searchKey;
    @track isRecordsPresent = true;
    @track selectedRecordFieldlabel;
    @track records;
    @track error;
    @track isRecordLoading = false;
    @track isMoreRecordLoading = false;
    @track response = [];

    totalRecords;
    limit;
    position = 0;
    scrollBottom = 0;
    flagOnScroll = false;
    scrollableDiv;
    @track margintopforspinner;
    @track isRequiredFieldErrMsg = false;

    rec_limit = parseInt(RECORDS_LIMIT, 10);
    noRecordsErr = NO_RECORDS_FOUND;
    countNotApplicable = 0;
    @track isLightingportal = false;
    @track tempQueryString;
    @track tempQueryString1;
    @api isProj;
    @api isProd;
    @api selectedProject;
    @track keyLenMsg = false;
    @track minKeyLenMsg = false;
    @api queryString1;
    connectedCallback() {
      
       this.tempQueryString = this.queryString1;
       if(window.location.href.includes('IPS')) {
        this.isLightingportal = true;
     }
        //this.countNotApplicable++;
        //if(this.countNotApplicable == 1){
        if(this.isProj || (this.isProd && this.selectedProject!=undefined && this.selectedProject!=null && this.selectedProject!='')){
             this.keyLenMsg = true;
             this.handleNotApplicableSearchChange();
            
        }
        if(this.isProd && (this.selectedProject==undefined || this.selectedProject==null || this.selectedProject=='')){
        
            this.minKeyLenMsg = true;
        }
        if (this.selectedRecord) {
        }
        let splittedText = [];
        if ((this.isReadOnly === undefined || this.isReadOnly === null)) {
            this.isReadOnly = false;
        }
        if ((this.queryExecutionRequired === undefined || this.queryExecutionRequired === null)) {
            this.queryExecutionRequired = true;
        }
        if (this.isSosl === undefined || this.isSosl === null || this.isSosl === '') {
            this.isSosl = false;
        }
        if (this.isRequiredField === undefined || this.isRequiredField === null) {
            this.isRequiredField = false;
        } else if (this.isRequiredField === "false") {
            this.isRequiredField = false;
        } else if (this.isRequiredField === "true") {
            this.isRequiredField = true;
            this.margintopforspinner = "margin-top:0.7rem;"; console.log('this.label inside line 67 ' + this.label, this.margintopforspinner);
        } else {
            this.isRequiredField = false;

            if (this.label !== undefined && this.label !== null && this.label !== '') {
                this.margintopforspinner = "margin-top:0.7rem;";
            } else {
                this.margintopforspinner = "margin-top:0rem;";
            }
        }
        if (this.selectedRecord !== undefined && this.selectedRecord !== null) {
            let splitResult = this.selectedRecord;
            splittedText = this.searchfieldName.split('.');
            if (splittedText.length > 0) {
                for (let i = 0; i < splittedText.length; i++) {
                    splitResult = splitResult[splittedText[i]];
                }
                this.selectedRecordFieldlabel = splitResult;
            } else {
                this.selectedRecordFieldlabel = this.selectedRecord[this.searchfield];
            }
        }
    }

    async handlelookup() {
        this.limit = this.rec_limit;
        if((this.isProj) || (this.isProd && this.selectedProject != null && this.selectedProject != undefined && this.selectedProject != '')){
            if(this.searchKey.length==0 && this.isLightingportal==true){
                this.searchKey='Not';
            }
        }
        
	if ((this.queryExecutionRequired || this.queryExecutionRequired === "true") && this.searchKey !== undefined && this.searchKey !== null && this.searchKey !== '' && this.searchKey !== ' ' && this.queryString !== undefined && this.queryString !== null) {
            this.isRecordLoading = true;
            if (this.countQueryString !== undefined && this.countQueryString !== null && this.countQueryString !== '') {
                if (this.isSosl === "true") {
                    findTotalRecordsSosl({ searchKey: this.searchKey, query: this.countQueryString })
                        .then(result => {
                            this.totalRecords = result;
                            this.errors = undefined;
                        })
                        .catch(error => {
                            this.errors = error;
                            this.totalRecords = 0;
                        });
                } else {
                    findTotalRecords({ searchKey: this.searchKey, query: this.countQueryString })
                        .then(result => {
                            this.totalRecords = result;
                            this.errors = undefined;
                        })
                        .catch(error => {
                            this.errors = error;
                            this.totalRecords = 0;
                        });
                }
            } else {
                this.totalRecords = 100;
            }


            await findRecords({
                searchKey: this.searchKey,
                queryString: this.queryString,
                recordLimit: this.limit,
                isSosl: this.isSosl
            })
                .then(async (result) => {

                    if (result !== undefined && result !== null) {
                        let qString = this.queryString;
                        if (qString.includes('RETURNING core_ips_project__c')) {

                            if (location.href.includes(PortalSiteURL)) {

                                if (this.assetId != null && this.assetId != undefined && this.assetId != '') {
                                    let NotApplicable = { "Name": "Not Applicable", "Core_IPS_Project_ID__c": null, "Id": null };
                                    let result1 = await this.getProjects(this.searchKey);



                                    result = [NotApplicable, ...result1];
                                    this.records = result;


                                }
                                else {

                                    let NotApplicable = { "Name": "Not Applicable", "Core_IPS_Project_ID__c": null, "Id": null };
                                    this.response = [NotApplicable, ...result];
                                    this.records = this.response;
                                }


                            }
                            else {
                                this.response = result;
                                this.records = this.response;
                            }
                        }
                        else {
                            
                            if(this.isProj){
                                let NotApplicable = { "Name": "Not Applicable", "Core_IPS_Project_ID__c": null, "Id": null };
                                this.response = [NotApplicable, ...result];
                                this.records = this.response;              
                            }
                            else{
                                this.records = result;
                            }    
                        }
                        this.error = undefined;
                        this.isRecordsPresent = true;
                        this.position = 0;
                        this.flagOnScroll = false;
                        if (this.scrollableDiv !== undefined && this.scrollableDiv !== null) {
                            this.scrollableDiv.scrollTop = 0;
                        }
                        if (this.records == 0 || this.records == null || this.records == undefined) {
                            this.isRecordsPresent = false;
                        }
                        this.isRecordLoading = false;
                    } else {
                        this.isRecordsPresent = false;
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.error('Core_IPS_CustomLookup ::: error in loading records in custom lookup ', error);
                    this.isRecordsPresent = false;
                });

        } else {
            if (!this.queryExecutionRequired || this.queryExecutionRequired === "false") {
                let key = (this.searchKey !== undefined && this.searchKey !== null && this.searchKey.length > 0) ? this.searchKey.toLowerCase() : null;
                this.records = this.recordsToSearch.filter((item) => item.Name.toLowerCase().includes(key));
                if (this.records !== undefined && this.records !== null && this.records.length > 0) {
                    this.isRecordsPresent = true;
                } else {
                    this.isRecordsPresent = false;
                }
            }
        }
        if (this.searchKey === undefined || this.searchKey === null || this.searchKey === '' || this.searchKey === ' ') {
            this.records = undefined;
        }

    }


    async getProjects(searchkey) {
        let selectedProject = [];
        await getIPSProjListBasedOnSelectedProd({ selectedProductId: this.assetId, searchTxt: searchkey })
            .then((res) => {
                selectedProject = [...res];
                return selectedProject;
            })
            .catch(err => {
                console.log('error in getprojwhenprodselected', err);
                return null;
            })
        return selectedProject;

    }

    handleNotApplicableSearchChange(){
        this.searchKey = 'Not'
        if (this.searchKey !== undefined && this.searchKey !== null && this.searchKey !== '') {
            /*if (this.isRequiredField) {
                if (this.isRequiredFieldErrMsg) {
                    this.margintopforspinner = "margin-top: -0.3rem;";
                    if (this.searchKey.length > 2) {
                        this.margintopforspinner = "margin-top: 0rem;";
                    }
                } else {
                    if (this.searchKey.length < 3) {
                        this.margintopforspinner = "margin-top: 0.3rem;";
                    } else {
                        this.margintopforspinner = "margin-top:0.7rem;";
                    }
                }
                if (this.searchKey.length < 1) {
                    this.records = undefined;
                    this.isRecordsPresent = true;
                }
            } else {
                if (this.searchKey.length < 3) {
                    this.margintopforspinner = "margin-top:-0.5rem;";
                } else {
                    if (this.label !== undefined && this.label !== null && this.label !== '') {
                        this.margintopforspinner = "margin-top:0.7rem;";
                    } else {
                        this.margintopforspinner = "margin-top:0rem;";
                    }
                }
                if (this.searchKey.length < 1) {
                    this.records = undefined;
                    this.isRecordsPresent = true;
                }
            }
	    */
            if (this.searchKey.length > 2) {
                clearTimeout(this.timeoutId);
                this.timeoutId = setTimeout(this.handlelookup.bind(this), 500);
            }
        } else {
            this.isRecordsPresent = true;
            this.records = undefined;
        }
    }

    handleOnchange(event) {
        this.searchKey = event.detail.value;
        console.log('querystring--'+this.queryString+'\n'+this.selectedProject);
        if(this.isProd) { 
            
            //'this.searchKey !== undefined' added by Kamala on 28-04-2026 - TWC745-9174 as part of Lightening Component exception 
            if(this.searchKey !== undefined && this.searchKey.length>0 && this.isProd){
                this.minKeyLenMsg = false;
            }
            //'this.searchKey !== undefined' added by Kamala on 28-04-2026 - TWC745-9174 as part of Lightening Component exception 
            else if(this.searchKey !== undefined && this.searchKey.length<=0 && this.isProd && (this.selectedProject==null || this.selectedProject==undefined || this.selectedProject=='')){
                this.minKeyLenMsg = true;
            }
        }
        if(this.isProj){
            
                let queryOrderByClauseStr = ' ORDER BY Name ASC';
                
                let queryWhereClauseStr = ' AND ( Name LIKE \'%' + this.searchKey + '%\'' + ' OR Core_IPS_Project_ID__c LIKE \'%' + this.searchKey + '%\')';
                if(this.searchKey.length>0 )
                    this.queryString = this.tempQueryString + queryWhereClauseStr + queryOrderByClauseStr ;
                else
                    this.queryString = this.tempQueryString + queryOrderByClauseStr ;
                
		        clearTimeout(this.timeoutId);
                this.timeoutId = setTimeout(this.handlelookup.bind(this), 500);
               
        }
        
        else{
            if(this.isProd){
            
                
		        let queryOrderByClauseStr = ' ORDER BY Name ASC, Account.Name ASC NULLS Last, Core_IPS_Project_Name__c ASC NULLS Last';
                
                let queryCondition = 'LIKE \'%' + this.searchKey + '%\'';
                //Product2.Name, core_Product_Application__c, Core_IPS_Project_Name__c, AccountId, Core_Code_Name__c, core_ips_project__c,Core_Supported_Product__c, Id,Name
                let queryWhereClauseStr = ' AND ( Product2.Name '+ queryCondition + ' OR core_Product_Application__c ' + queryCondition +  ' OR Core_IPS_Project_Name__c ' + queryCondition +  ' OR Core_Code_Name__c ' + queryCondition +  ' OR Name ' + queryCondition +' OR Core_Alias__c ' + queryCondition +')';
                if(this.searchKey.length>0 )
                    this.queryString = this.tempQueryString + queryWhereClauseStr + queryOrderByClauseStr ;
                else
                    this.queryString = this.tempQueryString + queryOrderByClauseStr ;
            
	        }
            if(this.isProd && this.selectedProject != null && this.selectedProject != undefined && this.selectedProject != ''){
                
		        this.keyLenMsg = true;
                clearTimeout(this.timeoutId);
                this.timeoutId = setTimeout(this.handlelookup.bind(this), 500);    
            
            }
            else if (this.searchKey !== undefined && this.searchKey !== null && this.searchKey !== '') {
                
		        if (this.isRequiredField) {
                    if (this.isRequiredFieldErrMsg) {
                        this.margintopforspinner = "margin-top: -0.3rem;";
                        if (this.searchKey.length > 2) {
                            this.margintopforspinner = "margin-top: 0rem;";
                        }
                    } else {
                        if (this.searchKey.length < 3) {
                            this.margintopforspinner = "margin-top: 0.3rem;";
                        } else {
                            this.margintopforspinner = "margin-top:0.7rem;";
                        }
                    }
                    if (this.searchKey.length < 1) {
                        this.records = undefined;
                        this.isRecordsPresent = true;
                    }
                } else {
                    
		            if (this.searchKey.length < 3 ) {
                        console.log('OnChangeProd - else error1');
                        this.margintopforspinner = "margin-top:-0.5rem;";
                    } else {
                        if (this.label !== undefined && this.label !== null && this.label !== '') {
                            this.margintopforspinner = "margin-top:0.7rem;";
                        } else {
                            this.margintopforspinner = "margin-top:0rem;";
                        }
                    }
                    if (this.searchKey.length < 1) {
                        this.records = undefined;
                        this.isRecordsPresent = true;
                    }
                    
                }
                if ( this.searchKey.length > 2) {
                    console.log('call search');
                    clearTimeout(this.timeoutId);
                    this.timeoutId = setTimeout(this.handlelookup.bind(this), 500);
                }
                if (this.isProd && this.searchKey.length < 3) {
                    this.records = undefined;
                    this.isRecordsPresent = true;
                }
                
            } else {
                this.isRecordsPresent = true;
                this.records = undefined;
            }
        }
    }
    handleFocusOut() {
        let key = this.searchKey;
        if (key === undefined || key === null || key === '') {
            this.isRequiredFieldErrMsg = true;
            this.margintopforspinner = "margin-top: -0.3rem;";
        }
        if (key !== undefined && key !== null && key !== '' && key.length > 0) {
            this.isRequiredFieldErrMsg = false;
            if (this.label !== undefined && this.label !== null && this.label !== '') {
                this.margintopforspinner = "margin-top:0.7rem;";
            } else {
                this.margintopforspinner = "margin-top: 0.3rem;";
            }

        }
    }

    handleSelect(event) {
        const selectedRecordId = event.detail;
        this.selectedRecord = this.records.find(
            record => record.Id === selectedRecordId
        );
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent("selectedrec", {
            detail: {
                recordId: selectedRecordId,
                record: this.selectedRecord
            }
        });
        let splittedText = [];
        if (this.selectedRecord !== undefined && this.selectedRecord !== null) {
            let splitResult = this.selectedRecord;
            splittedText = this.searchfieldName.split('.');
            if (splittedText.length > 0) {
                for (let i = 0; i < splittedText.length; i++) {
                    splitResult = splitResult[splittedText[i]];
                }
                this.selectedRecordFieldlabel = splitResult;
            } else {
                this.selectedRecordFieldlabel = this.selectedRecord[this.searchfield];
            }
        }
        this.dispatchEvent(selectedRecordEvent);
    }

    handleRemove(event) {
        event.preventDefault();
        
        this.searchKey= false;
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
         this.selectedRecordFieldlabel = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent("selectedrec", {
            detail: {
                recordId: undefined,
                record: undefined
            }
        });
        this.dispatchEvent(selectedRecordEvent);
        if(this.isProj || (this.isProd && this.selectedProject!=undefined && this.selectedProject!=null && this.selectedProject!='')){
            this.queryString = this.tempQueryString;
            this.handleNotApplicableSearchChange();
           // no use for not appliacle working without this trick aswell this.handleNotApplicable();
        }
        if(this.isProd && (this.selectedProject==undefined || this.selectedProject==null || this.selectedProject=='')){
            this.minKeyLenMsg = true;
        }
        else{
            this.minKeyLenMsg = false;
        }
        
    }

    @api
    removeSelected() {
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent("selectedrec", {
            detail: {
                recordId: undefined,
                record: undefined
            }
        });
        this.dispatchEvent(selectedRecordEvent);
    }

    onScrollHandle(event) {
        //Minhaj
        let qString = this.queryString;
        if (qString.includes('RETURNING core_ips_project__c')) {
            if (location.href.includes(PortalSiteURL)) {
                if (this.assetId != null && this.assetId != undefined && this.assetId != '') {

                    return;
                }
            }
        }

        if (this.countQueryString !== undefined && this.countQueryString !== null && this.countQueryString !== '') {
            let newScrollValue = event.target.scrollTop;
            this.scrollableDiv = event.target;
            if (newScrollValue > this.position) {
                this.scrollBottom = event.target.scrollHeight - event.target.offsetHeight;
                if (parseInt(newScrollValue, 10) >= this.scrollBottom - 1 && this.flagOnScroll === false) {
                    this.flagOnScroll = true;
                    if (this.limit < this.totalRecords) {
                        this.limit = ((this.limit + this.rec_limit) > this.totalRecords) ? (this.limit + (this.totalRecords - this.limit)) : this.limit + this.rec_limit;
                        this.isMoreRecordLoading = true;
                        setTimeout(function () { console.log('Loading...'); }, 500);
                        if (this.limit === 300) {
                            this.isMoreRecordLoading = false;
                        } else {

                            findRecords({
                                searchKey: this.searchKey,
                                queryString: this.queryString,
                                recordLimit: this.limit,
                                isSosl: this.isSosl
                            })
                                .then(result => {
                                    if (result !== undefined && result !== null) {
                                        this.records = result;
                                        this.error = undefined;
                                        this.isRecordsPresent = true;
                                        this.flagOnScroll = false;
                                        setTimeout(function () { console.log('Loaded...'); }, 500);
                                        this.isMoreRecordLoading = false;
                                    } else {
                                        this.isRecordsPresent = false;
                                    }
                                })
                                .catch(error => {
                                    this.error = error;
                                    console.error('Core_IPS_CustomLookup ::: error in loading records in custom lookup ', error);
                                    this.isRecordsPresent = false;
                                });

                        }
                    }
                }
            }
            this.position = newScrollValue;
        }
    }
}