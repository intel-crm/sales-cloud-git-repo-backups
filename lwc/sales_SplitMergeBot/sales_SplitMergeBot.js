/*import { LightningElement } from 'lwc';

export default class Sales_SplitMergeBot extends LightningElement {
    parameters = {};

    connectedCallback() {

        this.parameters = this.getQueryParameters();
        console.log('parameter'+this.parameters);
    }

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }
}*/
import { LightningElement, wire, api,track} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class Sample extends LightningElement {

    recId;
    @api isMergeSeats = false;
    @api isSplit=false;
    @api value;
    @api recordId;
    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {
        this.windowURL = String(window.location);

    //console.log('Split value' + this.windowURL.split('/s/'));

    this.value=this.windowURL.split('/sales-license/')[1];//to query the  capability from community
    this.recordId=this.value.split('/')[0];
    //this.capabilityvalue=this.capabilityvalue.split('/')[0];

    console.log(this.value+'this.value');
    console.log(this.recordId+'this.recordId');
       
        if ( this.currentPageReference.state.license ) {

            console.log( 'recId Param value is ' + this.currentPageReference.state.license );
            this.recId = this.currentPageReference.state.license;
            console.log( 'recId Param value is 43 ' + this.recId );
            if(this.recId=='merge'){
                this.isMergeSeats=true;
                console.log('isMergeSeats'+this.isMergeSeats);
            }
            else{
                this.isSplit=true;
                console.log('isSplit'+this.isSplit);
            }

        }

        if ( this.currentPageReference.state.c__testParam ) {

            console.log( 'Param ' + this.currentPageReference.state.c__testParam );

        }
   
    }

}