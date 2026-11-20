import { LightningElement, track, api} from 'lwc';

export default class UcdSearchBox extends LightningElement {
    @track searchKey;
    @api records;
    //@track recordList = {};
    @track recordsToDisplay = [];
    connectedCallback() {
        //this.recordList = this.records;
        this.records;
        console.log('in connected');
    }
    //Function to check for the search key in the table/ records coming in the connected call back
    onKeyChangeHandler(event) {
        const searchKey = event.target.value;
        if(searchKey.ignoreCase){
            //this.searchKey = searchKey;
            this.searchKey = new RegExp(searchKey, 'i');
            this.recordsToDisplay = this.records.filter(rec => JSON.stringify(rec).includes(searchKey));
            if(Array.isArray(this.recordsToDisplay) && this.recordsToDisplay.length > 0)
            this.dispatchEvent(new CustomEvent('searchforkey', {detail: this.recordsToDisplay}));
        }
    }

    
}