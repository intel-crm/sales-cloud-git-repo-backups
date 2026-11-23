import { LightningElement, api, track } from 'lwc';
import Core_MDF_Search from '@salesforce/label/c.Core_MDF_Search';
import Core_MDF_Help_Text_SPIF_Search_Screen from '@salesforce/label/c.Core_MDF_Help_Text_SPIF_Search_Screen';

export default class Core_MDF_customTreeGrid extends LightningElement {
    @api columns;
    @api treeData;
    @api showTableHeader;
    @api showCheckbox;  
    @api isSearchEnabled;
    @api fieldToSearch;
    @api disableAll;
    @api screen;
    @api isShowHelpText;

    @track selectedRows = [];
    @track allChildRecords = [];
    @track selectedRecords = [];
    @track originalDataTreeData;
    @track childRecordsMap = new Map();
    @track parentChildMap = new Map();
    search = Core_MDF_Search;
    helpText = Core_MDF_Help_Text_SPIF_Search_Screen;
    
    connectedCallback() {
        console.log('data-->'+JSON.stringify(this.treeData));
        if(this.isSearchEnabled === undefined || this.isSearchEnabled === null || this.isSearchEnabled === '') {
            this.isSearchEnabled = false;
        }
        if(this.fieldToSearch === undefined || this.fieldToSearch === null || this.fieldToSearch === '') {
            this.fieldToSearch = "Name";
        }
        if(this.isShowHelpText === undefined || this.isShowHelpText === null || this.isShowHelpText === '') {
            this.isShowHelpText = false;
        }
        if(this.disableAll === undefined || this.disableAll === null || this.disableAll === '') {
            this.disableAll = false;
        }
        if(this.treeData !== undefined && (this.treeData !== null || this.treeData == null ) && this.treeData !== '') {
            if(this.isSearchEnabled) {
                this.originalDataTreeData = this.treeData;
            }
            for(let i=0; i<this.treeData.length; i++) {
                if(this.treeData[i].isChecked) {
                    this.selectedRows = [...this.selectedRows , this.treeData[i].name];
                }
                if(this.treeData[i]._children !== null && this.treeData[i]._children !== undefined) {
                    for(let j=0; j<this.treeData[i]._children.length; j++) {
                        if(this.treeData[i]._children[j].isChecked) {
                            this.selectedRows = [...this.selectedRows , this.treeData[i]._children[j].Id];
                        }
                        this.childRecordsMap.set(this.treeData[i]._children[j].Id, this.treeData[i]._children[j]);
                        if(this.parentChildMap.has(this.treeData[i].name)) {
                            let vals = this.parentChildMap.get(this.treeData[i].name);
                            vals = [...vals, this.treeData[i]._children[j].Id];
                            this.parentChildMap.set(this.treeData[i].name, vals);
                        } else { 
                            let vals = [];
                            vals = [...vals, this.treeData[i]._children[j].Id];
                            this.parentChildMap.set(this.treeData[i].name, vals);
                        }
                    }
                }
            }
        }
    }

    toggleSection(event) {
        let iconElementSelectorId = '[accesskey="'+event.target.accessKey+'"]';
        let iconElement = this.template.querySelector(iconElementSelectorId);
        let childRowSelectorId = '[data-id="'+event.target.accessKey+'"]';
        let childRow = this.template.querySelector(childRowSelectorId);
        if(childRow){
            if(iconElement.className == "slds-button__icon_left") {
                iconElement.className = "slds-icon-utility-switch slds-section__title-action-icon slds-button__icon_left slds-icon_container";
                childRow.className='slds-hide';
            } else {
                iconElement.className = "slds-button__icon_left";
                childRow.className='slds-show';
            }
        } 
    }

    getSelectedRow(event) {
        debugger;
        let isAllCheckboxSelected = false;
        let parentRowsSet = new Set(this.parentChildMap.keys());
        if(!event.target.checked) {
            if(event.target.name == "selectAll") {
                isAllCheckboxSelected = false;
            }
            if(event.target.name != "selectAll") {
                this.selectedRows = this.selectedRows.filter((item) => item !== event.target.name);
                if(parentRowsSet != null && parentRowsSet.has(event.target.name)) {
                    this.selectChildRows(event.target.name,'remove');
                }
            }
            this.selectParentRows(event.target.name, 'remove');
        }
        if(event.target.checked) {
            if(event.target.name == "selectAll") {
                isAllCheckboxSelected = true;
            }
            if(event.target.name != "selectAll") {
                if(!this.selectedRows.includes(event.target.name)) {
                    this.selectedRows = [...this.selectedRows, event.target.name];//CA
                }
                if(parentRowsSet != null && parentRowsSet.has(event.target.name)) {
                    this.selectChildRows(event.target.name,'add');
                }
            }
            this.selectParentRows(event.target.name, 'add');
        } 
        if(this.showTableHeader) {
            let selectAllCheckBox = this.template.querySelector("[name=selectAll]");
            selectAllCheckBox.checked = isAllCheckboxSelected;
        }
        this.selectedRecords = [];
        console.log('selected rows--',this.selectedRows.length);
        for(let j=0;j<this.selectedRows.length;j++) {
            if(this.childRecordsMap.get(this.selectedRows[j]) != null ) {
                let obj = {...this.childRecordsMap.get(this.selectedRows[j])};
                obj.isChecked = true;
                this.selectedRecords = [...this.selectedRecords, obj ];
            }
        }
        const selectedRecordEvent = new CustomEvent("recordselection", {
            detail: {
                selectedRows: this.selectedRecords,
            }
        });
        this.dispatchEvent(selectedRecordEvent);
    }

    selectParentRows(child, operation) {
        let parentRowsSet = new Set(this.parentChildMap.keys());
        let childObj = this.childRecordsMap.get(child);
        if(parentRowsSet != null && childObj!= undefined && parentRowsSet.has(childObj.parentRow)) {
            let parentRowSelectorId = '[name="'+childObj.parentRow+'"]';
            let parentRow = this.template.querySelector(parentRowSelectorId);
            if(operation=='add') {
                let childRows = this.parentChildMap.get(childObj.parentRow);
                let selectedRowsSet =new Set(this.selectedRows);
                let selectParentFlag = true;
                if(childRows!=null ){
                    for(let i=0;i<childRows.length;i++) {
                        if(!selectedRowsSet.has(childRows[i])) {
                            selectParentFlag = false;
                        }
                    }
                }
                parentRow.checked = selectParentFlag;
                if(selectParentFlag) {
                    this.selectedRows = [...this.selectedRows, childObj.parentRow];
                }
            } else if(operation=='remove') {
                parentRow.checked = false;
                this.selectedRows = this.selectedRows.filter((item) => item !== parentRow.name);
            }
        }
    }

    selectChildRows(parentRow, operation) {
        let childRowSet = new Set(this.parentChildMap.get(parentRow));
        let inputElements = this.template.querySelectorAll("[type=checkbox]");
        inputElements.forEach(element => { 
            if(childRowSet.has(element.name)) {
                if(operation=='add') {
                    element.checked = true;
                    if(!this.selectedRows.includes(element.name)) {
                        this.selectedRows = [...this.selectedRows, element.name];
                    }
                } else if(operation=='remove') {
                    element.checked = false;
                    this.selectedRows = this.selectedRows.filter((item) => item !== element.name);
                }
            }
        });
    }

    selectAllRows(event) {
        this.selectedRecords = [];
        let inputElements = this.template.querySelectorAll("[type=checkbox]");
        if(event.target.checked) {
            inputElements.forEach(element => { 
                element.checked = true;
                if(!this.selectedRows.includes(element.name) && element.name != "selectAll") {
                    this.selectedRows = [...this.selectedRows, element.name];
                }
            });
            for(let i=0; i<this.allChildRecords.length;i++) {
                this.allChildRecords[i].isChecked = true;
                this.selectedRecords = [...this.selectedRecords, this.allChildRecords[i]];
            }
        } else {
            inputElements.forEach(element => { 
                element.checked = false;
                this.selectedRows = this.selectedRows.filter((item) => item !== element.name); 
            });
        }
        const selectedRecordEvent = new CustomEvent("recordselection", {
            detail: {
                selectedRows: this.selectedRecords,
            }
        });
        this.dispatchEvent(selectedRecordEvent);
    }

    searchData(event) {
        debugger;
        let searchKey = event.target.value;
        let dataWrapper = [];
        let fieldToSearch = this.fieldToSearch;
        if(searchKey != null && searchKey.length > 2) { // Only proceed with search if searchKey has at least 3 characters
            //resetting the tree data value, in case previous search returned blank
            this.treeData = this.originalDataTreeData;
            console.log('TREE DATA---',JSON.stringify(this.treeData));
                    for(let i=0; i<this.treeData.length; i++) {
                        let childDataWrapper = [];
                        if(this.treeData[i]._children !== null && this.treeData[i]._children !== undefined) {
                            childDataWrapper = this.treeData[i]._children.filter((item) => item[fieldToSearch].toLowerCase().includes(searchKey.toLowerCase()));
                        }
                        if(childDataWrapper !== undefined && childDataWrapper.length>0) {
                            // If matches found, include them in dataWrapper
                            let obj = {...this.treeData[i]};
                            obj._children = childDataWrapper;
                            dataWrapper = [...dataWrapper, obj];
                        }
                    }
                    this.treeData = dataWrapper;// Update treeData based on search results
        } else {
                // If searchKey is too short, revert to original data
                this.treeData = this.originalDataTreeData;
            }
        }
    
    renderedCallback(){
        var scrollablediv = this.template.querySelector('[data-id="scrollablediv"]');
        if(this.screen == 'reviewScreen'){
            scrollablediv.className = 'reviewScreen slds-table_bordered slds-border_right slds-border_left';
        }else{
            scrollablediv.className ='spifScreen';
        }
        console.log('this.selectedRows', this.selectedRows);
        if(this.selectedRows.length >= 1){
            this.selectedRows.forEach(item => {
                console.log('item from selected row', item);
                var selectedChild = this.template.querySelector(`[data-id="${item}"]`);
                if(selectedChild != null && selectedChild != undefined){
                    selectedChild.checked = true;
                }
            });
        }        
    }
}