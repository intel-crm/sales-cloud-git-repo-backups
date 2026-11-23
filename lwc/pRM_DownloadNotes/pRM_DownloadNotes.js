import { LightningElement,track } from 'lwc';
import getNotes from '@salesforce/apex/PRM_DownloadNotes_Contact.getNotes';
const columnsTable = [{
    label: 'Title',
    type: 'text',
    fieldName: 'title', 
},
{
    label: 'Created By',
    type: 'text',
    fieldName: 'createdBy',
},
{
    label: 'Last Modified',
    fieldName: 'lastModified',
    sortable: 'true'
},
{
    label: 'Size',
    fieldName: 'size'
},
{
    label: 'Download',
    type: 'button-icon',
    initialWidth: 135,
    typeAttributes: { iconName: 'utility:download', name: 'download_file', title: 'Click to download' }

}
];


export default class PRM_DownloadNotes extends LightningElement {

    @track columnsTable=columnsTable;
    @track allNotes=[];
    @track showData;


    getUploadedNotes(){
        getNotes().then(response => {
            console.log('response--->'+ JSON.stringify(response));
            if(response.length>0){             
                this.allNotes = response;
            }})
            .catch(error =>{
                console.log('Error',error);
            });
    }

    handleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldName, direction) {
        let parseData = JSON.parse(JSON.stringify(this.allNotes));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldName];
        };
        let isReverse = direction === 'asc' ? 1 : -1;   // cheking reverse direction
        // sorting data 
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x).toLowerCase() : ''; // handling null values
            y = keyValue(y) ? keyValue(y).toLowerCase() : '';

            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        // set the sorted data to data table data
        this.allNotes = parseData;
    }


    connectedCallback(){
        this.showData=true;
        this.getUploadedNotes();
    }
}