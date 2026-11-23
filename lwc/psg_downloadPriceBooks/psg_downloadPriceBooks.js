import {LightningElement, wire,track,api} from 'lwc';
import getPdfDownloadLink from '@salesforce/apex/PSG_fileDownloadController.getPdfDownloadLink';
import { NavigationMixin } from 'lightning/navigation'; 

const Columns = [
    { label: 'File Name', fieldName: 'fileTitle',wrapText:true,
     cellAttributes: {
        iconName:'utility:file', iconPosition:'left'
    } },
    //{ label: 'Download Link', fieldName: 'fileUrl', type:'url' }
    {
        label: 'Download',
        type: 'button',
        initialWidth: 200,
        typeAttributes: {label:'Download',variant:'brand', iconName:'action:download'
        ,iconPosition:'right',name: 'download', title:  'Download' },
         cellAttributes: {
            alignment: 'Center'
        }
    }
];

export default class psg_downloadPriceBooks extends  NavigationMixin(LightningElement) {
   //pdfDownloadLink;
    tableData
    columns=Columns
    recordId
    @track isdata=undefined;
   
   @wire(getPdfDownloadLink, {})
   getPdfLink({ data, error }) {
    
       if (data) {
           console.log('FileData: ' + JSON.stringify(data)+"lengths "+data.length)
           this.isdata=false
           this.tableData = data;
            } 
       else{
           if(error){
               console.log('error++++++++++: ', error)
               this.isdata=true;

               //this.isdata=true;
           }
       }
      
   }
   callRowAction( event ) {  
    
     let row = event.detail.row;
     this.recordId= row.fileId; 
     window.location.href=(row.fileUrl);
     }
}