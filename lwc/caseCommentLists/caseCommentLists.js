import { LightningElement, track , wire} from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import getQueryResult from '@salesforce/apex/caseCommentListController.getCaseComments';
//import TIME_ZONE from '@salesforce/i18n/timeZone';
import LOCALE from '@salesforce/i18n/locale';

export default class caseCommentLists extends LightningElement {
    @track dataList = [];
    @track searchId;
    @track searchText;
    @track isDataAvailable = false;
     userLocale = LOCALE.timezone;

    @track mapRecordId;

    @wire(CurrentPageReference)
        currentPageReference;

    connectedCallback() {
        this.getRecords();
        console.log('caseCommentList ::: connectedCalback called');

    }
    onChangeHandler(event){
        this.searchText = event.target.value;
    }
    onSearch() {
        this.getRecords();
        
    }
    onReset(){
        this.searchText = '';
        this.getRecords();
    }

    getRecords() {
        this.mapRecordId = this.currentPageReference.attributes.recordId;
       getQueryResult({caseId : this.mapRecordId , searchText : this.searchText })
            .then(data => {
                if(data) {
                    
                    this.dataList = data;
                    this.isDataAvailable = true;
                    console.log('dataaa', this.dataList);
                }
            })
            .catch(error => {
                console.error('caseCommentList ::: Error in loading records. Error : ', JSON.stringify(error));
            })
    }
    


}