import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLinkedInterestedParties from "@salesforce/apex/Core_IPS_Case_Interested_Parties.getLinkedInterestedParties";
import getQueryResult from '@salesforce/apex/Core_IPS_Case_Interested_Parties.getQueryResult';
import getActiveContactIds from "@salesforce/apex/Core_IPS_Case_Interested_Parties.getActiveContactIds";
import isCaseEditable from "@salesforce/apex/Core_IPS_Case_Interested_Parties.isCaseEditable";
//import getUserProfileId from "@salesforce/apex/Core_IPS_Case_Interested_Parties.getUserProfileId";
import getInternalPartiesProfileIds from "@salesforce/apex/Core_IPS_Case_Interested_Parties.getInternalPartiesProfileIds";
import findTotalRecords from "@salesforce/apex/Core_IPS_Case_Interested_Parties.findTotalRecords";
import insertInterestedParties from "@salesforce/apex/Core_IPS_Case_Interested_Parties.insertInterestedParties";
import getContactUserMap from "@salesforce/apex/Core_IPS_Case_Interested_Parties.getContactUserMap";

import CURRENT_USER_ID from '@salesforce/user/Id';
import CASEID_FIELD from '@salesforce/schema/Case.Id';
import CASEACCOUNTID_FIELD from '@salesforce/schema/Case.AccountId';
import PROJECTCASEID_FIELD from '@salesforce/schema/Case.Core_IPS_Project_Case__c';
import CASERECTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CASEOWNERID_FIELD from '@salesforce/schema/Case.OwnerId';
import PRIVATEPROJECT_FIELD from '@salesforce/schema/Case.Core_IPS_Private_Project__c';
import ACCOWNERID_FIELD from '@salesforce/schema/Case.Account.OwnerId';
import CASERECTYPENAME_FIELD from '@salesforce/schema/Case.RecordType.Name';
import CUSTOMERVISIBLE_FIELD from '@salesforce/schema/Case.Core_IPS_Customer_Visible__c';

import Core_IPS_Interested_Party_Limit from '@salesforce/label/c.Core_IPS_Interested_Party_Limit';
import Core_IPS_Interested_Party_Warning_Msg from '@salesforce/label/c.Core_IPS_Interested_Party_Warning_Msg';
import checkCustomerVisibility from "@salesforce/apex/Core_IPS_Case_Interested_Parties.checkCustomerVisibility";

import caseDetailPage from '@salesforce/label/c.Core_IPS_Case_Detail_Page';
//import Core_IPS_Sales_Rep_ProfileIds from '@salesforce/label/c.Core_IPS_Sales_Rep_ProfileIds';


const COLUMNS = [ 
  {
      label: 'First Name',
      fieldName: 'FirstName'
  },
  {
      label: 'Last Name',
      fieldName: 'LastName'
  },
  {
      label: 'Email',
      fieldName: 'Email'
  }
];

const EXTERNAL = 'External';
const INTERNAL = 'Internal';

export default class Core_IPS_Case_Interested_Parties extends NavigationMixin(LightningElement) {
  
  @api recordId;
  @api interestedPartyType = 'Internal';

  @track searchKey;
  @track helpText;
  @track linkedInterestedParties;
  @track spinnerOn = false;
  @track selectedInterestedParties = [];
  @track selectedInterestedPartiesPresent = false;
  @track preSelectedRows = [];
  @track islinkedInterestedPartiesPresent = false;
  @track searchResult;
  @track isMoreThanThousandRes = false;
  isMoreThanThousandResMsg = Core_IPS_Interested_Party_Warning_Msg;
  @track isSearchResultPreset = false;
  @track isSearchBtnDisable = true;
  @track isDoneBtnDisable = true;

  @track relatedContactIds = new Set();
  @track activeContactIdsStr;
  @track relatedContactIdsStr;
  @track searchQueryStr;

  @track isEditableFlag = false;
  @track curUsrProfId;
  @track salesRepProfIdsStr;
  @track accTeamMemIdsStr;
  @track selectedColumns;
  @track tempRecordId;
  @track cnt=0;
  @track contactUserMap;

  get options() {
	  if((this.recTypeName === 'IPS No Assigned Contact Case' && this.isEditableFlag)||(!this.customerVisible)) {
		return [
			{ label: 'Internal', value: 'Internal' }
		];
	  } 
	 if(!this.isEditableFlag) {
		return [
			{ label: 'External', value: 'External' }
		];
	 } else {
		return [
			{ label: 'Internal', value: 'Internal' },
			{ label: 'External', value: 'External' },
		];
	  }
  }

  columns = COLUMNS;

  searchCardTitle = "Search Interested Parties";
  selectedCardTitle = "Selected";
  searchResCardTitle = "Search Results";
  contactIconName = "standard:contact";
  placeholder;

  hideCheckboxColumn = true;
  showRowNumberColumn = false;
  enableInfiniteLoading = true;
  numAndCheckboxBothCols = false;
  normalDataTable = false;
  numberOfRowsToShow = 5;
  heightInRem = 12;

  accOwnerId;
  caseAccId;
  caseProjId;
  caseRecTypeId;
  caseOwnerId;
  casePrivateProj;
  recTypeName;
  customerVisible;
  /*
  @wire(isCaseEditable, { recordId: '$recordId'})
  WiredCaseAccess({data, error}) {
	console.log('line 111 data WiredCaseAccess ', data);
	if(data) {
		console.log('line 113 data WiredCaseAccess ', data);
	}
	if(error) {
		console.error('Error in loading case edit access ', error, JSON.stringify(error));
	}
  }*/
/*
  @wire(getUserProfileId)
  wiredProfileId({data, error}) {
	  if(data) {
		this.curUsrProfId = data;
		console.log('this.curUsrProfId ', this.curUsrProfId);
		this.salesRepProfIdsStr = '(\'\')';
		if(Core_IPS_Sales_Rep_ProfileIds.includes(this.curUsrProfId)) {
			this.salesRepProfIdsStr = JSON.stringify(Core_IPS_Sales_Rep_ProfileIds.split(","));
			this.salesRepProfIdsStr = this.salesRepProfIdsStr.replace("[", "(");
            this.salesRepProfIdsStr = this.salesRepProfIdsStr.replace("]", ")");
            this.salesRepProfIdsStr = this.salesRepProfIdsStr.replace(/"/g, "'");
		}
		console.log('this.salesRepProfIdsStr ', this.salesRepProfIdsStr);
	  }
	  if(error) {
		console.error('Error in loading cur user profile id ', error, JSON.stringify(error));
	  }
  }
*/
currentPageReference;
@wire(CurrentPageReference)
setCurrentPageReference(currentPageReference) {
	this.currentPageReference = currentPageReference;
	console.log('currentPageReference'+this.currentPageReference?.state?.c__recordId);
	this.recordId = this.currentPageReference?.state?.c__recordId;
	console.log('pprecordId--'+this.recordId);
	if(this.cnt==1&&this.recordId!=this.tempRecordId){
		window.location.reload();
	 }
}

  @wire(getRecord, { recordId: '$recordId' , fields: [ CASEID_FIELD, CASEACCOUNTID_FIELD, PROJECTCASEID_FIELD, CASERECTYPEID_FIELD, CASEOWNERID_FIELD, PRIVATEPROJECT_FIELD, ACCOWNERID_FIELD, CASERECTYPENAME_FIELD, CUSTOMERVISIBLE_FIELD ]})
    wiredResult({data, error}) {
        if(data) {
          this.accOwnerId = getFieldValue(data, ACCOWNERID_FIELD);
          this.caseAccId = getFieldValue(data, CASEACCOUNTID_FIELD);
          this.caseProjId = getFieldValue(data, PROJECTCASEID_FIELD);
          this.caseRecTypeId = getFieldValue(data, CASERECTYPEID_FIELD);
          this.caseOwnerId = getFieldValue(data, CASEOWNERID_FIELD);
		  this.casePrivateProj = getFieldValue(data, PRIVATEPROJECT_FIELD);
		  this.recTypeName = getFieldValue(data, CASERECTYPENAME_FIELD);
		  this.customerVisible = getFieldValue(data, CUSTOMERVISIBLE_FIELD);
          console.log('this.accOwnerId ', this.accOwnerId);
          console.log('this.caseAccId ', this.caseAccId);
          console.log('this.caseProjId ', this.caseProjId);
          console.log('this.caseRecTypeId ', this.caseRecTypeId);
          console.log('this.caseOwnerId ', this.caseOwnerId);
		  console.log('this.casePrivateProj ', this.casePrivateProj);
		  console.log('this.recTypeName ', this.recTypeName);
		  console.log('this.customerVisible ', this.customerVisible);
		  this.accTeamMemIdsStr = '(';
		  if(this.accOwnerId !== undefined && this.accOwnerId !== null && this.accOwnerId !=='') {
			this.accTeamMemIdsStr += '\'' + this.accOwnerId + '\'';
		  }
		  if(this.caseOwnerId !== undefined && this.caseOwnerId !== null && this.caseOwnerId !=='') {
			if(this.accOwnerId !== undefined && this.accOwnerId !== null && this.accOwnerId !=='') {
				this.accTeamMemIdsStr += ', ';
			}
			this.accTeamMemIdsStr += '\'' + this.caseOwnerId + '\'';
		  }
		  if((this.accOwnerId === undefined || this.accOwnerId === null || this.accOwnerId ==='') && (this.caseOwnerId === undefined || this.caseOwnerId === null || this.caseOwnerId ==='')) {
			this.accTeamMemIdsStr += '\'\'';
		  }
		  this.accTeamMemIdsStr += ')';
		  //this.accTeamMemIdsStr = '( \''+ this.accOwnerId + '\', \'' + this.caseOwnerId + '\' )';
		  this.spinnerOn = false;
        }
        if(error) {
            console.error('Error in loading case record type name', error, JSON.stringify(error));
        }
    }

  @wire(getLinkedInterestedParties, {caseId: '$recordId', interestedPartyType: '$interestedPartyType'})
    WiredGetInterestedParties({data, error}) {
      if(data) {
        console.log('data ', JSON.stringify(data));
		this.spinnerOn = true;
		
		this.relatedContactIds.clear();
		this.relatedContactIdsStr = '(';

        for(let i = 0;i< data.length;i++) {
          this.preSelectedRows = [...this.preSelectedRows, data[i].Id];
          if(this.interestedPartyType === 'Internal') {
			this.relatedContactIds.add(data[i].User__c);
			this.relatedContactIdsStr += '\''+data[i].User__c+'\'';
          }
          if(this.interestedPartyType === 'External') {
			this.relatedContactIds.add(data[i].Contact__c);
			this.relatedContactIdsStr += '\''+data[i].Contact__c+'\'';
		  }
		  if(i === data.length-1) {
			//this.relatedContactIdsStr += ')' 
		  } else {
			this.relatedContactIdsStr += ', ' 
		  }
		}
		if(data.length===0) {
			this.relatedContactIdsStr += '\'\'';
		}
		this.relatedContactIdsStr += ')';
		console.log('this.relatedContactIdsStr ', this.relatedContactIdsStr);
		
		console.log(JSON.stringify(this.preSelectedRows));
		console.log('this.preSelectedRows.length ', this.preSelectedRows.length);
		console.log('data.length ', data.length);
		if(data.length>0) {
			if(this.preSelectedRows !== undefined && this.preSelectedRows !== null && this.preSelectedRows !== '[]'  && this.preSelectedRows.length >0){
				this.linkedInterestedParties = data;
				this.islinkedInterestedPartiesPresent = true;
			}
		}
		this.spinnerOn = false;
		
		console.log('data.length 156 ', data.length);
      }
      if(error) {
		this.spinnerOn = false;
		
        console.error("Error loading in linked interested parties. ", error, JSON.stringify(error));
      }
    }

  connectedCallback() {
	this.spinnerOn = true;
	this.tempRecordId = this.recordId;
    this.cnt=1;
	this.setHelpText();    
	console.log('CURRENT_USER_ID ', CURRENT_USER_ID);
	isCaseEditable({caseId: this.recordId})
		.then(result=>{
			if(result) {
				this.isEditableFlag = result;
				if(!this.isEditableFlag) {
					this.interestedPartyType="External";
				}
				console.log('this case is editable ? - ', this.isEditableFlag );
			}
		})
		.catch(error=>{
			console.error('Error in loading case edit access ', error, JSON.stringify(error));
		})
  }
  
  handleChangeInterestedPartyType(event) {
	this.spinnerOn = true;
	this.searchKey = '';
	this.isSearchBtnDisable = true;
	this.isSearchResultPreset = false;
    this.searchResult = undefined;
    this.interestedPartyType = event.detail.value;
    this.preSelectedRows = [];
    this.linkedInterestedParties = undefined;
	this.islinkedInterestedPartiesPresent = false;
	this.selectedInterestedParties = [];
    this.setHelpText();
	if(this.interestedPartyType==="External") {
		getActiveContactIds({accountId: this.caseAccId , projectId: this.caseProjId})
        .then(result=>{
          if(result) {
			this.activeContactIdsStr = JSON.stringify(result);
            this.activeContactIdsStr = this.activeContactIdsStr.replace("[", "(");
            this.activeContactIdsStr = this.activeContactIdsStr.replace("]", ")");
            this.activeContactIdsStr = this.activeContactIdsStr.replace(/"/g, "'");
			console.log('activeContactIdsStr ', this.activeContactIdsStr);
			this.spinnerOn = false;
          }
        })
        .catch(error=>{
			this.spinnerOn = false;
          console.error('Error in loading activeContactIds ', error, JSON.stringify(error));
		})
		this.spinnerOn = false;
	}
  }
  setHelpText(){
    if(this.interestedPartyType==="Internal") {
	  this.getProfileIds();
      this.placeholder = "Type in the name and click Search..";
	  this.helpText = 'FAEs belonging to your account/Internal Users can be added or removed as Interested Parties to this case. If you do not find a user, it is possible they do not have access to this case or do not belong to your account.';
	  this.spinnerOn = false;
    } else if(this.interestedPartyType==="External") {
      this.placeholder = "Type * or type in the name and click Search";
      this.helpText = 'Contacts belonging to your account can be added or removed as Interested Parties to this case. If you do not find a user, it is possible they do not have access to this case or do not belong to your account.';      
    }
  }

  getProfileIds() {
	getInternalPartiesProfileIds({caseId: this.recordId})
		.then(result=>{
			if(result) {
				console.log('result profile ids ', result );
				this.salesRepProfIdsStr = JSON.stringify(result);
				this.salesRepProfIdsStr = this.salesRepProfIdsStr.replace("[", "(");
				this.salesRepProfIdsStr = this.salesRepProfIdsStr.replace("]", ")");
				this.salesRepProfIdsStr = this.salesRepProfIdsStr.replace(/"/g, "'");
				console.log('this.salesRepProfIdsStr ', this.salesRepProfIdsStr);
				this.spinnerOn = false;
			}
		})
		.catch(error=>{
			console.error("Error loading in profile ids. ", error, JSON.stringify(error));
			this.spinnerOn = false;
		})
  }

  getSelectedRecords(event) {
	this.selectedInterestedParties = [];
	let data = event.detail.selectedRows;
	console.log('this.selectedInterestedParties ', data);
	this.preSelectedRows = [];
	if(data !== undefined && data !== null && data !== '') {
		
		for(let i = 0;i< data.length;i++) {
			this.isDoneBtnDisable = false;
			let obj;
			if(this.interestedPartyType==="Internal") {
				obj = { 'Id' : data[i].Id, 'FirstName': data[i].FirstName,  'LastName':  data[i].LastName, 'Email': data[i].Email };
				this.preSelectedRows = [...this.preSelectedRows, data[i].Id];
			}
			if(this.interestedPartyType==="External") {   
				obj = { 'Id' : data[i].Id, 'FirstName': data[i].FirstName,  'LastName':  data[i].LastName, 'Email': data[i].Email };
				this.preSelectedRows = [...this.preSelectedRows, data[i].Id];
			}
			this.selectedInterestedParties = [...this.selectedInterestedParties, obj];
		}
		this.selectedInterestedPartiesPresent = true;
	}
  }

  removeSelectedRows(event) {
	let data = event.detail.selectedRows;
	this.selectedInterestedParties = data;
	if(data === undefined || data === null || data === '') {
		console.log(' removeSelectedRows this.selectedInterestedPartiesPresent false ', data);
		this.isDoneBtnDisable = true;
		this.selectedInterestedPartiesPresent = false;
	}
  }

  handleSearchKey(event) {
    this.searchKey = event.detail.value;
    if(this.searchKey !== undefined && this.searchKey !== null && this.searchKey !== '' && this.searchKey.length>0) {
      this.isSearchBtnDisable = false;
    } else {
      this.isSearchBtnDisable = true;
    }
  }

  handleSearch() {
	this.spinnerOn = true;
	setTimeout(function() { console.log('Loading...');}, 500);
    this.isSearchResultPreset = false;
    this.searchResult = undefined;
    let searchableString;
    console.log('handle search called. Search Key : ', this.searchKey);    

	this.searchQueryStr = '';
	if(this.interestedPartyType==="Internal") {
		this.selectedColumns = this.conColumns;
		searchableString = '\'' + this.searchKey + '%\'';

		let selectStr = ' SELECT ';
		let fieldsStr = ' Id, Name, FirstName, LastName, Email '
		let fromObjectStr = ' FROM User ';
		let whereClause = '';
		let whereClause1 = ' (IsActive = true)  AND (FirstName LIKE ' + searchableString + ' OR LastName LIKE ' + searchableString + ' OR Email LIKE ' + searchableString + ') AND (NOT(ID IN ' + this.relatedContactIdsStr + ' )) ';
		if(this.caseProjId !== undefined && this.caseProjId !== null && this.caseProjId !== ''
			&& this.casePrivateProj !== undefined && this.casePrivateProj !== null && this.casePrivateProj !== '' && this.casePrivateProj == true
		) {
			whereClause = ' WHERE ' + whereClause1 + ' AND Id IN (Select Core_IPS_User__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c = \'' + this.caseProjId + '\'  AND Status__c=\'Active\')';
		} else {
			whereClause = ' WHERE (ProfileId IN ' + this.salesRepProfIdsStr + ' AND ' + whereClause1 + ') OR (Id IN ' + this.accTeamMemIdsStr + ' AND '  + whereClause1 + ')';
		}
		let limitStr = ' LIMIT ' + Core_IPS_Interested_Party_Limit;
		//sQuery= 'SELECT Id, Name, FirstName, LastName, Email FROM User WHERE Id In (Select Core_IPS_User__c from Core_IPS_Intel_Support_Team__c where Core_IPS_Project__c =:projId AND Status__c=\'Active\') AND (FirstName like :searchableString OR LastName like :searchableString OR Email like :searchableString) AND (NOT(ID IN :relatedUserIDs)) AND (IsActive = true) ORDER BY ' + sortHeader.sortExpression + ' ' + sortHeader.sortDirection + ' ' + sortHeader.sortNullFirstLast +' Limit '+System.Label.Core_IPS_Interested_Party_Limit; 
		this.searchQueryStr = selectStr + fieldsStr + fromObjectStr + whereClause + limitStr;
		console.log('this.searchQueryStr '+this.searchQueryStr);

		let searchCountQuery = selectStr + ' count() ' + fromObjectStr + whereClause;
		console.log('this.searchCountQuery '+searchCountQuery);
		findTotalRecords({query : searchCountQuery})
			.then(data => {
				if(data) {
					this.searchResultCount = data;
					if(data > parseInt(Core_IPS_Interested_Party_Limit)) {
						this.isMoreThanThousandRes = true;
					}
					this.spinnerOn = false;
					console.log('this.searchResult count ', data);
				}
				
			})
			.catch(error => {
				console.log('Total record error');
				console.error('Core_IPS_Case_Interested_Parties ::: Error in loading Contact records. Error pp: ', JSON.stringify(error));
				this.spinnerOn = false;
				
			})
 
		getQueryResult({queryString : this.searchQueryStr, isWithoutSharing: false})
			.then(data => {
				if(data) {
					this.searchResult = data;
					this.isSearchResultPreset = true;
					this.spinnerOn = false;
					console.log('this.searchResult', this.searchResult);
				}
				else{
					const event = new ShowToastEvent({
						message: 'No User Found.',
						variant: 'error',
					});
					this.dispatchEvent(event);
				}
				this.spinnerOn = false;
				
			})
			.catch(error => {
				console.log('get Query Result error');
				console.error('Core_IPS_Case_Interested_Parties ::: Error in loading Contact records. Error : ', JSON.stringify(error));
				this.spinnerOn = false;
				
			})

	} else if(this.interestedPartyType==="External") {
		this.selectedColumns = this.columns;
		searchableString = '\'%' + this.searchKey + '%\'';

		let slectStr = ' SELECT ';
		let fieldsStr = ' Id, firstName, LastName, Email, Name, AccountId, Account.Name '
		let fromObjectStr = ' FROM Contact ';
	
        if(this.caseAccId !== undefined && this.caseAccId !== null && this.caseAccId !== '' 
          && (this.caseProjId === undefined || this.caseProjId === null || this.caseProjId === ''  )
        ) {
			let whereClause1 = ' WHERE AccountId = \'' + this.caseAccId + '\'';
			if(this.searchKey!='*'){
			   whereClause1 += ' AND (Name LIKE ' + searchableString + ' OR FirstName LIKE ' + searchableString +  ' OR LastName LIKE ' + searchableString + ' OR Email LIKE ' + searchableString + ') ';
			}   
			whereClause1 += ' AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false ';
			whereClause1 += ' AND (ID IN ' + this.activeContactIdsStr + ' ) AND (NOT(ID IN ' + this.relatedContactIdsStr + ' ))'
			this.searchQueryStr = slectStr + fieldsStr + fromObjectStr + whereClause1;
			console.log('this.searchQueryStr- '+this.searchQueryStr);
			getContactUserMap({queryString : this.searchQueryStr, isWithoutSharing: true})
				.then(data=>{
					if(data) {
						this.contactUserMap = JSON.parse(JSON.stringify(data));
						console.log('getContactUserMap '+ JSON.stringify(data));
						console.log('getContactUserMap '+ JSON.stringify(data));
						//let keys = Object.keys(prodVarResult);
					}
					
				})
				.catch(error=>{
					const event = new ShowToastEvent({
						message: 'No User Found.',
						variant: 'error',
					});
					this.dispatchEvent(event);
					this.spinnerOn = false;
					console.error('Core_IPS_Case_Interested_Parties ::: Error in loading Contact userid map. Error : ', JSON.stringify(error));
				})
			getQueryResult({queryString : this.searchQueryStr, isWithoutSharing: false})
				.then(data => {
					if(data) {
						this.searchResult = data;
						this.isSearchResultPreset = true;
						this.spinnerOn = false;
						console.log('this.searchResult ', this.searchResult);
						
					}
				})
				.catch(error => {
					console.error('Core_IPS_Case_Interested_Parties ::: Error in loading Contact records. Error : ', JSON.stringify(error));
					this.spinnerOn = false;
					
				})
        }
        if(this.caseProjId !== undefined || this.caseProjId !== null || this.caseProjId !== ''  ) {
			let whereClause1=''; 
			if(this.searchKey!='*'){
			    whereClause1+=' WHERE (Name LIKE ' + searchableString + ' OR FirstName LIKE ' + searchableString +  ' OR LastName LIKE ' + searchableString + ' OR Email LIKE ' + searchableString + ') ';
			    whereClause1 += ' AND Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false ';
			}
			else{
				whereClause1 += ' WHERE Core_IPS_Active__c = true AND Core_IPS_Email_Opt_Out__c=false ';
			}
			whereClause1 += ' AND (ID IN ' + this.activeContactIdsStr + ' ) AND (NOT(ID IN ' + this.relatedContactIdsStr + ' ))'
			this.searchQueryStr = slectStr + fieldsStr + fromObjectStr + whereClause1;
			console.log('this.searchQueryStr '+this.searchQueryStr);
			getContactUserMap({queryString : this.searchQueryStr, isWithoutSharing: true})
				.then(data=>{
					if(data) {
						this.contactUserMap = JSON.parse(JSON.stringify(data));
						var obj1 = this.contactUserMap; //{"0033F000001QqZ5QAK":"0053F000000NnYLQA0","0033F000001R9xgQAC":"0053F000000O0sIQAS"};
						var ids = '0033F000001QqZ5QAK';
						console.log('TEST getContactUserMap '+ obj1[ids]);

						console.log('getContactUserMap '+ this.contactUserMap);
						console.log('this.contactUserMap user value ', this.contactUserMap["0033F000001QqZ5QAK"]);
					}
					
				})
				.catch(error=>{
					const event = new ShowToastEvent({
						message: 'No User Found.',
						variant: 'error',
					});
					this.dispatchEvent(event);
					this.spinnerOn = false;
					console.error('Core_IPS_Case_Interested_Parties ::: Error in loading Contact userid map. Error : ', JSON.stringify(error));
				})
			getQueryResult({queryString : this.searchQueryStr, isWithoutSharing: true})
				.then(data => {
					if(data) {
						this.searchResult = data;
						this.isSearchResultPreset = true;
						this.spinnerOn = false;
						console.log('this.searchResult ', this.searchResult);
						
					}
				})
				.catch(error => {
					console.error('Core_IPS_Case_Interested_Parties ::: Error in loading Contact records. Error : ', JSON.stringify(error));
					this.spinnerOn = false;
					
				})
        }
	}
  }

  handleSave() {
	this.isDoneBtnDisable = true;
	this.spinnerOn = true;
	setTimeout(function() { console.log('Loading...');}, 500);
	if(this.interestedPartyType==="Internal") {
		if(this.selectedInterestedParties !== undefined && this.selectedInterestedParties !== null && this.selectedInterestedParties.length>0) {
			let interestedParties = [];
			for(let i=0;i<this.selectedInterestedParties.length;i++) {
				let obj = {
					User__c: this.selectedInterestedParties[i].Id,
					Case__c: this.recordId,
					Type__c: "Internal",
					Active__c:  true
				}
				if(this.casePrivateProj) {
					obj.Core_IPS_Project_Interested_Party__c = true;
				}
				interestedParties = [...interestedParties, obj];
			}
			insertInterestedParties({interestedParties: interestedParties, isWithoutSharing: false})
				.then(result=>{
					if(result) {
						this.showToast('Success', 'Interested Parties Inserted.', 'success');
						this.navigateToViewCase();
						this.spinnerOn = false;
					}
				})
				.catch(error=>{
					console.error('Core_IPS_Case_Interested_Parties ::: Error in inserting interestedParties records. Error : ', JSON.stringify(error));
					this.showToast('Error', 'Interested Parties insertion failed due to some error.', 'error');
					this.spinnerOn = false;
				});
		}
	} else if(this.interestedPartyType==="External") {
		checkCustomerVisibility({recordId : this.recordId})
		.then(data =>{
			if(!data){
				this.showToast('Warning','Case is not visible to customers. Cannot assign External Interested Parties.','warning');
			    this.navigateToViewCase();
			}
		else{
		if(this.selectedInterestedParties !== undefined && this.selectedInterestedParties !== null && this.selectedInterestedParties.length>0) {
			let interestedParties = [];
			for(let i=0;i<this.selectedInterestedParties.length;i++) {
				let obj = {
					Contact__c : this.selectedInterestedParties[i].Id,
					Case__c : this.recordId,
					Type__c : "External",
					Active__c : true,
					User__c : this.contactUserMap[this.selectedInterestedParties[i].Id]
				}
				console.log('this.contactUserMap[this.selectedInterestedParties[i].Id] '+this.contactUserMap[this.selectedInterestedParties[i].Id]);
				interestedParties = [...interestedParties, obj];
			}
			insertInterestedParties({interestedParties: interestedParties, isWithoutSharing: true})
				.then(result=>{
					if(result) {
						this.showToast('Success', 'Interested Parties Inserted.', 'success');
						this.navigateToViewCase();
						this.spinnerOn = false;
					}
				})
				.catch(error=>{
					console.error('Core_IPS_Case_Interested_Parties ::: Error in inserting interestedParties records. Error : ', JSON.stringify(error));
					this.showToast('Error', 'Interested Parties insertion failed due to some error.', 'error');
					this.spinnerOn = false;
				});
		}
	}
})
	}
  }

	handleCancel() {
		console.log('handleCancel called');
	this.navigateToViewCase();
	}

	navigateToViewCase() {
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Case',
                actionName: 'view'
            },
        });*/
		window.location.href = caseDetailPage + this.recordId + '/view'

	}
	
	showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}