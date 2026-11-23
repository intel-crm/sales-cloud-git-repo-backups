import { LightningElement,track } from 'lwc';
import getNotes from '@salesforce/apex/PRM_DownloadNotes_Contact.getNotes';
import PRM_PartnerSearch_Style from '@salesforce/resourceUrl/PRM_PartnerSearch_Style'
import { loadStyle } from 'lightning/platformResourceLoader'

const columnsTable = [
    { 
        cellAttributes: { 
            alignment: "left",
            size: 'medium',
            iconName: {
              fieldName: "iconType",
              iconPosition: "left"
            },
          },
        label: 'Title',
        fieldName: 'title',
        sortable: true
    },
    {
        label: 'Created By',
        fieldName: 'createdBy',
        sortable: true
    },
    {
        label: 'Last Modified',
        fieldName: 'lastModified',
        sortable: true
    },
    {
        label: 'Size',
        fieldName: 'size',
        sortable: true
    },
    {
        label: ' ',
        type: 'button-icon',
        fieldName : 'downloadAttachment',
        initialWidth: 135,
        sortable: true,
        typeAttributes: { iconName: 'utility:download', name: 'download_file', title: 'Click to download' }
    }
];


export default class PRM_DownloadNotes extends LightningElement {

    @track columnsTable=columnsTable;
    @track allNotes=[];
    @track showData = false;


    getUploadedNotes(){
        getNotes().then(response => {
            console.log('response--->'+ JSON.stringify(response));
            if(response.length>0){             
                this.allNotes = response;
                this.showData=true;
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

    handleRowAction(event) {
        var action = event.detail.action;
        console.log('********************'+JSON.stringify(event.detail.row));
        var row = event.detail.row;
        if(action.name == 'download_file'){
            this.downloadFile(row.downloadAttachment);
        }
    }

    downloadFile(downloadlink) {
        window.open(downloadlink,"_self");

    }

    renderedCallback() {
        if (this.isCssLoaded)
            return
        this.isCssLoaded = true
        loadStyle(this, PRM_PartnerSearch_Style)
            .then(() => {
                console.log("Loaded Successfully")
            })
            .catch(error => {
                console.error("Error in loading the colors")
            })
    }

    connectedCallback(){
        this.getUploadedNotes();
    }
}