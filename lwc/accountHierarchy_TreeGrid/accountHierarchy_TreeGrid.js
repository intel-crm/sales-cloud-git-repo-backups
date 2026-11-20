import { LightningElement, track, api } from 'lwc';
import getChildAccounts from '@salesforce/apex/Core_MDF_AccountHierarchyController.fetchChildAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import exportExcel from '@salesforce/label/c.Core_MDF_ExportButtonLabel';
import noRecordsToDisplay from '@salesforce/label/c.Core_MDF_NoRecordsToDisplay';
import intelAccount from '@salesforce/label/c.Core_MDF_IntelAccount';
import level1Account from '@salesforce/label/c.Core_MDF_Level1Account';
import level2Account from '@salesforce/label/c.Core_MDF_Level2Account';
import level3Account from '@salesforce/label/c.Core_MDF_Level3Account';
import level4Account from '@salesforce/label/c.Core_MDF_Level4Account';
import level5Account from '@salesforce/label/c.Core_MDF_Level5Account';
import applicationErrorMsg from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import applicationErrorTitle from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';
import activeInactiveLabel from '@salesforce/label/c.Core_MDF_ActiveInactive_Label';
import programLabel from '@salesforce/label/c.Core_MDF_Program';
import loadingLabel from '@salesforce/label/c.Core_MDF_Loading';

const columns = [{ type: 'url', fieldName: 'AccountURL', label: 'Account Name', typeAttributes: { label: { fieldName: 'Name' }, tooltip: { fieldName: 'accountActive' } } },
{ label: 'Program', fieldName: 'program', type: 'text' },{ label: 'Active/Inactive', fieldName: 'accountActive', type: 'text' },
];
// Fields to be shown on Account Record Page
const columnsOnRecordpage = [{ type: 'url', fieldName: 'AccountURL', label: 'Account Name', typeAttributes: { label: { fieldName: 'Name' }, tooltip: { fieldName: 'accountActive' } } }];

export default class AccountHierarchy_TreeGrid extends LightningElement {

    @track gridColumns; // For Storing Columns header of tree grid
    @track gridData; // Accounts Data to be shown in tree grid
    @track gridExpandedRows; // Grid expanded rows
    @api ultimateAccountId; // Ultimate Account Id being passed from parent component
    @api ultimateAccountName; // Ultimate Account Name being passed from parent component
    @api salesforceBaseurl; // Salesforce base url
    @track showGridData; // show or hide tree grid
    @api isRecordPage = false; // Attribute for record page
    @api highlightedRowId = ''; // Records to be highlighted
    @track selectedRecords = []; // Array to store all the selected records
    @api enableScroll = '';
    showSpinner = false;

    label = { exportExcel, noRecordsToDisplay, intelAccount, level1Account, level2Account, level3Account, level4Account, level5Account, applicationErrorMsg, applicationErrorTitle, programLabel, activeInactiveLabel, loadingLabel };

    get dynamicStyling() {
        // If this is record Page - Add scroll bar
        var dynamicStyle;
        if (this.enableScroll === "true") {
            dynamicStyle = 'scrollableSection';
        }
        else {
            dynamicStyle = 'nonscrollableSection';
        }
        return dynamicStyle;
    }
    connectedCallback() {
        console.log('coming in treegrid');
        if (this.highlightedRowId != '') {
            this.isRecordPage = true;
        }
        // Calling a method to get all the Accounts in a hierarchy for a given Ultimate Account
        this.fetchAllChildAccounts();
        // Record Page the user is currently on should be selected by default
        this.selectedRecords.push(this.highlightedRowId);
    }

    // Preserve the selected Account Record on expand/collapse of tree
    handleToggle(event) {
        this.selectedRecords = [];
        this.selectedRecords.push(this.highlightedRowId);
    }

    /* Fetching All Acounts For a given Ultimate Account */
    @api fetchAllChildAccounts() {
        this.showSpinner = true;
        var accountsToDisplayOnTree = [];
        // Columns to be shown in tree grid
        if (this.isRecordPage) {
            this.gridColumns = columnsOnRecordpage;
        }
        else {
            this.gridColumns = columns;
        }
        // Fetching All child Accounts By passing the ultimate Account Id to apex method 
        getChildAccounts({ ultimateAccountId: this.ultimateAccountId })
            .then(allAccounts => {
                if (allAccounts !== undefined && allAccounts !== null && allAccounts !== "") {
                    allAccounts.sort((a, b) => (a.Name.toLowerCase() > b.Name.toLowerCase()) ? 1 : (a.Name.toLowerCase() === b.Name.toLowerCase()) ? ((b.CreatedDate > a.CreatedDate) ? 1 : -1) : -1);
                    accountsToDisplayOnTree = allAccounts;
                    // Calling a method to create tree grid data
                    this.createTreeGridData(accountsToDisplayOnTree);
                }
            })
            .catch(error => {
                this.error = error;
                accountsToDisplayOnTree = undefined;
                this.showSpinner = false;
                this.displayErrorMessageOnServerException();
            });
    }

    /* Method to Create tree grid data */
    createTreeGridData(accountsToDisplayOnTree) {
        var expandedRows = [];
        // Creating a vaisable to store Childrens of the parent account in array
        var accounts = { _children: [] };
        for (var index = 0; index < accountsToDisplayOnTree.length; index++) {
            var account = accountsToDisplayOnTree[index];
            expandedRows.push(account.Id);
            accounts[account.Id] = {
                Name: account.Name,
                Id: account.Id,
                program: (account.Core_MDF_Channel_Program__r !== undefined) ? (account.Core_MDF_Channel_Program__r.Name) : "",
                accountActive: (account.RecordType.DeveloperName !== 'Mastered_Account') ? (account.Core_MDF_Active_Ind__c ? "Active" : "Inactive") : "",
                parentAccount: (account.Core_MDF_Parent_Fund_Account__c !== undefined) ? (account.Core_MDF_Parent_Fund_Account__c) : "",
                parentRecordtype: (account.Core_MDF_Parent_Fund_Account__c !== undefined) ? (account.Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName) : "",
                recordType: account.RecordType.DeveloperName,
                AccountURL: '/' + account.Id,
                _children: []
            };
        }
        var isAccountRecPage = this.isRecordPage;
        // Pushing the child accounts to _children attribute of the immediate parent
        accountsToDisplayOnTree.forEach(function (account) {
            if (Boolean(isAccountRecPage)) {
                // for the Account's record Page If the Account is Intel; Add it at the top level 
                if (accounts[account.Id].parentAccount === '') {
                    accounts._children.push(accounts[account.Id]);
                }
                else {
                    accounts[account.Core_MDF_Parent_Fund_Account__c]._children.push(accounts[account.Id]);
                }
            }
            else {
                // If Parent Account is Intel then Push Virtual corps into first level --- Check for Not equal to Comarketing
                if (accounts[account.Id].recordType === 'Core_MDF_Co_Marketing' && accounts[account.Id].parentRecordtype === 'Mastered_Account') {
                    accounts._children.push(accounts[account.Id]);
                }
                // else Push Account into Account's Parent Fund Account _children
                else if (accounts[account.Id].parentRecordtype === 'Core_MDF_Co_Marketing') {
                    accounts[account.Core_MDF_Parent_Fund_Account__c]._children.push(accounts[account.Id]);
                }
            }
        });
        // Setting Tree Griddata and expandedrows attribute to be viewed in tree
        this.gridData = accounts._children;
        this.gridExpandedRows = expandedRows;
        if (this.gridData.length > 0) {
            this.showGridData = true;
        }
        else {
            this.showGridData = false;

        }
        this.showSpinner = false;
    }

    // Creating Excel file for Export functionality 
    exportToExcel() {
        var isAccountRecPage = this.isRecordPage;
        var baseURL = this.salesforceBaseurl;
        var ultimateAccountName = this.ultimateAccountName;
        var ultimateAccountId = this.ultimateAccountId;
        var accountData;

        // Adding All the accounts of a hierarchy except for the Intel Account
        if (Boolean(isAccountRecPage)) {
            accountData = this.gridData[0]._children;
        }
        else {
            accountData = this.gridData;
        }

        // Table- Start
        var finalExcelData = "<table border='1px' style='font-size:22px'>";

        // Header for the file
        finalExcelData += "<tr>" + "<td>" + this.label.intelAccount + "</td>" + "<td>" + this.label.level1Account + "</td>" + "<td>" + this.label.level2Account + "</td>" + "<td>" + this.label.level3Account + "</td>" + "<td>" + this.label.level4Account + "</td>" + "<td>" + this.label.level5Account + "</td>" + "<td>" + this.label.programLabel + "</td>" + "<td>" + this.label.activeInactiveLabel + "</td>" + "</tr>";
        finalExcelData += "<tr><pre><td>" + ultimateAccountName.link(baseURL + ultimateAccountId) + "</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></pre></tr>";

        // Adding data in table in a specific format
        for (var index1 = 0; index1 < accountData.length; index1++) {
            finalExcelData += "<tr><pre><td></td><td>" + accountData[index1].Name.link(baseURL + accountData[index1].Id) + "</td><td></td><td></td><td></td><td></td>" + "<td>" + accountData[index1].program + "</td>" + "<td>" + accountData[index1].accountActive + "</td></pre>" + "</tr>";
            var level2Child = accountData[index1]._children;

            for (var index2 = 0; index2 < level2Child.length; index2++) {

                finalExcelData += "<tr><pre><td></td><td></td><td>" + level2Child[index2].Name.link(baseURL + level2Child[index2].Id) + "</td><td></td><td></td><td></td>" + "<td>" + level2Child[index2].program + "</td>" + "<td>" + level2Child[index2].accountActive + "</td></pre>" + "</tr>";
                var level3Child = level2Child[index2]._children;

                for (var index3 = 0; index3 < level3Child.length; index3++) {

                    finalExcelData += "<tr><pre><td></td><td></td><td></td><td>" + level3Child[index3].Name.link(baseURL + level3Child[index3].Id) + "</td><td></td><td></td>" + "<td>" + level3Child[index3].program + "</td>" + "<td>" + level3Child[index3].accountActive + "</td></pre>" + "</tr>";
                    var level4Child = level3Child[index3]._children;

                    for (var index4 = 0; index4 < level4Child.length; index4++) {

                        finalExcelData += "<tr><pre><td></td><td></td><td></td><td></td><td>" + level4Child[index4].Name.link(baseURL + level4Child[index4].Id) + "</td><td></td>" + "<td>" + level4Child[index4].program + "</td>" + "<td>" + level4Child[index4].accountActive + "</td></pre>" + "</tr>";
                        var level5Child = level4Child[index4]._children;

                        for (var index5 = 0; index5 < level5Child.length; index5++) {

                            finalExcelData += "<tr><pre><td></td><td></td><td></td><td></td><td></td><td>" + level5Child[index5].Name.link(baseURL + level5Child[index5].Id) + "</td>"  + "<td>" + level5Child[index5].program + "</td>" + "<td>" + level5Child[index5].accountActive + "</td></pre>" + "</tr>";
                        }
                    }
                }
            }
        }
        // Table-Ends
        finalExcelData = finalExcelData + "</table>";

        // Final Excel file generation
        let hiddenElement = document.createElement('a');
	let blob = new Blob(["\ufeff",finalExcelData]);
        hiddenElement.href = window.URL.createObjectURL(blob, {type: "text/plain"});
        hiddenElement.target = '_self';
        hiddenElement.download = ultimateAccountName + ' Account Hierarchy.xls';
        document.body.appendChild(hiddenElement);
        hiddenElement.click();
    }

    /* Displaying Errors As a toast Message On Server Side Exception */
    displayErrorMessageOnServerException() {
        const evt = new ShowToastEvent({
            title: this.label.applicationErrorTitle,
            message: this.label.applicationErrorMsg,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}