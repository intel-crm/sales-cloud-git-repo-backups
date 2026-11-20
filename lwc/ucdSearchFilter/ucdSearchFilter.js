import { LightningElement, track, api} from 'lwc';

export default class UcdSearchFilter extends LightningElement {
    @track searchKey;
    @api records;
    @track recordsToDisplay = [];
    connectedCallback() {
        this.records;
       
    }
    //Function to check for the search key in the table/ records coming in the connected call back
    onKeyChangeHandler(event) {
        var searchKey = event.target.value.toLowerCase();
        if(searchKey){
            this.searchKey = searchKey;
            this.recordsToDisplay = this.records.filter(rec => JSON.stringify(rec).toLowerCase().includes(searchKey));
            if(this.recordsToDisplay.length == 0){
                this.recordsToDisplay = [];
                this.dispatchEvent(new CustomEvent('filterkey', {detail: this.recordsToDisplay}));
            }           
            if(Array.isArray(this.recordsToDisplay) && this.recordsToDisplay.length > 0)
            this.dispatchEvent(new CustomEvent('filterkey', {detail: this.recordsToDisplay}));
        }
        else{
            this.recordsToDisplay = [];
            this.dispatchEvent(new CustomEvent('filterkey', {detail: 'NoRecords'}));
        }
    }

    
}