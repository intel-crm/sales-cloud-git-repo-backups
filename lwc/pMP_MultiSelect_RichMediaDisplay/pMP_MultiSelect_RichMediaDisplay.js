import { LightningElement, track,api} from 'lwc';

export default class PMP_MutliSelect_RichMediaDisplay extends LightningElement {
   
    /*
    Declaring recordId to get the rich media asset record id
    */
    @api recordId;

    @track selectedItemsToDisplay = ''; //to display items in comma-delimited way
    @track values = []; //stores the labels in this array
    @track isItemExists = false; //flag to check if message can be displayed

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);        
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //displays the items in comma-delimited way
    displayItem(args){
        this.values = []; //initialize first
        args.map(element=>{
            this.values.push(element.value);
        });

        this.isItemExists = (args.length>0);
        this.selectedItemsToDisplay = this.values.join(', ');
    }
}