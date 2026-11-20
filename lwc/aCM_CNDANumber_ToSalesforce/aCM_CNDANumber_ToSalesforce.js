import { LightningElement, track ,wire,api} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import getContracts from '@salesforce/apex/ACM_CNDA_SearchAndSelect.ExecuteAPI';
//import getCNDAforName from '@salesforce/apex/ACM_CNDA_SearchAndSelect.getCNDAforName';
import appendToAccountField from '@salesforce/apex/ACM_CNDA_SearchAndSelect.appendToAccountField';

export default class ContractList extends LightningElement {
    @track wireRecordId; //this will hold the current record id fetched from pagereference
    @track data;
    @track cndaList;
    @track selectedRows = [];
    showSpinner = true;
    empty = false;
    isloaded = false;
    rowLimit = 100;
    sortedBy;
    sortedDirection;
    

    columns = [
        { label: 'Counterparty Name', fieldName: 'counterparty_name', sortable: true },
        { label: 'Contract Subtype', fieldName: 'contract_subtype', sortable: true },
        { label: 'Contract Number', fieldName: 'contract_number', sortable: true },
        { label: 'Contract Type', fieldName: 'contract_type0', sortable: true },
        { label: 'Country', fieldName: 'counterparty_country', sortable: true },
        { label: 'City', fieldName: 'counterparty_city', sortable: true },
        { label: 'State/Province', fieldName: 'counterparty_state_province', sortable: true },
        { label: 'Contact Name', fieldName: 'intel_contact_name', sortable: true }        
    
    ];

    
    renderedCallback()
    {
      if(this.isloaded) return;
      const STYLE = document.createElement("style");
      STYLE.innerText = '.uiModal--medium .modal-container{ width : 90% !important; max-width : 100%; min-width : 480px;}';
      this.template.querySelector('lightning-card').appendChild(STYLE);
      this.isloaded=true;
    }


    @wire(CurrentPageReference) 
    getStateParameters(currentPageReference) 
    {
        if (currentPageReference) {
            this.wireRecordId = this.currectRecordId = currentPageReference.state.recordId;
            console.log(this.wireRecordId);
        }

        let separators = /[,/; ]+/;

        getContracts({AcctID: this.wireRecordId, Name: null, multiParam: false})
        .then(result =>
            {
                console.log('result'+result);
                console.log(JSON.parse(result.jsonResponse).result);
                if(JSON.parse(result.jsonResponse).result)
                {
                    this.data = JSON.parse(result.jsonResponse).result.slice(0, this.rowLimit);
                }
                else
                {
                    this.data = JSON.parse(result.jsonResponse).result;
                }
                console.log('cndaList : '+result.cndaList);

                console.log(this.data.length);
                if(this.data.length <= 0)
                {
                        this.empty=true;
                        console.log('empty : '+this.empty);
                }

                if(!this.empty)
                {
                    console.log('hsk'+this.data);
                    console.log('Response is not empty');
                    if(result.cndaList)
                    {
                        console.log('cndaList values present');
                        // Extract selected contract numbers
                        let selectedIds = result.cndaList.split(separators).filter(id => id !== '');

                        console.log('this.data : '+this.data);
                        console.log(selectedIds);

                        // Separate the selected rows from the non-selected rows
                        let selectedData = this.data.filter(row => selectedIds.includes(row.contract_number));
                        let unselectedData = this.data.filter(row => !selectedIds.includes(row.contract_number));

                        // Combine selected rows at the top, followed by non-selected rows
                        this.data = [...selectedData, ...unselectedData];

                        // Map selected rows for reference, if needed (for example, for multi-select or other purposes)
                        this.selectedRows = selectedData.map(row => row.contract_number);
                    }

                }                
                
                this.showSpinner = false;
            }).catch(error =>
                {
                    
                            this.showSpinner = false;
                            console.log(error);
                            const event = new ShowToastEvent({
                                title: 'Contracts Fetch Failed',
                                message: 'Try again after sometime.',
                                variant: 'error',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
                            this.dispatchEvent(new CloseActionScreenEvent());
                }
            );

    }
    /**
     * Copied the code from above to call the method in apex class which fetched cnds based on input.
     */
    getcndawithName(){
        this.showSpinner = true;
        this.empty = false;
        const searchQuery = this.template.querySelector('lightning-input[data-name="search"]').value;
        console.log('searchQuery - ',searchQuery);
        let separators = /[,/; ]+/;
        getContracts({AcctID: this.wireRecordId, Name: searchQuery, multiParam: true})
        .then(result =>
            {
                console.log('result'+result);
                    if(JSON.parse(result.jsonResponse).result)
                    {
                        this.data = JSON.parse(result.jsonResponse).result.slice(0, this.rowLimit);
                    }
                    else
                    {
                        this.data = JSON.parse(result.jsonResponse).result;
                    }

                console.log(this.data.length);
                if(this.data.length <= 0)
                {
                        this.empty=true;
                        console.log('empty : '+this.empty);
                }

                if(!this.empty)
                {
                    console.log('Response is not empty');
                    if(result.cndaList)
                    {
                        console.log('cndaList values present');
                        // Extract selected contract numbers
                        let selectedIds = result.cndaList.split(separators);

                        // Separate the selected rows from the non-selected rows
                        let selectedData = this.data.filter(row => selectedIds.includes(row.contract_number));
                        let unselectedData = this.data.filter(row => !selectedIds.includes(row.contract_number));

                        // Combine selected rows at the top, followed by non-selected rows
                        this.data = [...selectedData, ...unselectedData];

                        // Map selected rows for reference, if needed (for example, for multi-select or other purposes)
                        this.selectedRows = selectedData.map(row => row.contract_number);
                    }

                }
                
                this.showSpinner = false;
            }).catch(error =>
                {
                        this.showSpinner = false;
                        console.log(error);
                        const event = new ShowToastEvent({
                        title: 'Contracts Fetch Failed',
                        message: 'Try again after sometime.',
                        variant: 'error',
                        mode: 'dismissable'
                        });
                        
                        this.dispatchEvent(event);
                        this.dispatchEvent(new CloseActionScreenEvent());

                }    
                
            );
    }

    getSelectedRec() {
        this.showSpinner = true;
        const selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecords:', selectedRecords);
    
        let selectedIds = '';
        selectedRecords.forEach(currentItem => {
            selectedIds = currentItem.contract_number + ';' + selectedIds;
        });
        this.selectedIds = selectedIds;
    
        console.log('Selected IDs:', this.selectedIds);
    
        appendToAccountField({
            accountId: this.currectRecordId,
            textToAppend: this.selectedIds,
            preselectedRows: this.selectedRows
        })
        .then(result => {
            if (result) {
                this.showSpinner = false;
                console.log('Account updated successfully');
                const event = new ShowToastEvent({
                    title: 'Account Update',
                    message: 'CNDA field update successful',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
            } else {
                this.showSpinner = false;
                console.log('Account update failed');
                const event = new ShowToastEvent({
                    title: 'Account Update Failed',
                    message: 'CNDA field update',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        })
        .catch(error => {
            this.showSpinner = false;
            console.log('Error:', error);
            const event = new ShowToastEvent({
                title: 'Account Update Failed',
                message: 'CNDA field update',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.dispatchEvent(new CloseActionScreenEvent());
        });
    }

    handleSort(event)
    {
        const {fieldName,sortDirection} = event.detail;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;

        this.sortData(fieldName,sortDirection);
    }

    sortData(field, direction)
    {
        let sortresult = [...this.data];

        sortresult.sort((a,b) => 
            {
                let valueA = a[field];
                let valueB = b[field];

                if(typeof valueA === 'string' && typeof valueB === 'string')
                {
                    valueA = valueA.toLowerCase();
                    valueB = valueB.toLowerCase();
                }
                
                if(valueA > valueB)
                {
                    return direction === 'asc' ? 1 :-1;
                }
                else if(valueB > valueA)
                {
                    return direction === 'asc' ? -1 : 1;
                }

                return 0;
            });
            this.data = sortresult;
    }
    

}