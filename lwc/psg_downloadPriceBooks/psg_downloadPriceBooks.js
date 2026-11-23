import {LightningElement, wire} from 'lwc';
//import getPdfDownloadLink from '@salesforce/apex/PSG_fileDownloadController.getPdfDownloadLink';
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
   /*@wire(getPdfDownloadLink, {})
   getPdfLink({ data, error }) {
       if (data) {
           //console.log('FileData: ' + JSON.stringify(data))
           this.tableData = data;
       } else {
           if(error){
              // console.log('error++++++++++: ', error)
           }
       }
   }*/
   callRowAction( event ) {  
    
     let row = event.detail.row;
     this.recordId= row.fileId; 
     window.location.href=(row.fileUrl);
     
     

    //const actionName = event.detail.action.name; 
    //console.log('ID     '+JSON.stringify(recId));
   // window.location.assign(row.fileurl)


    
        /*this[NavigationMixin.Navigate]({  
            type: 'standard__webPage',  
            attributes: {  
                recordId: this.recordId,
                url:encodeURI(row.fileUrl),
                // url:'https://'+location.host+'/'+'sfsites/c/sfc/servlet.shepherd/document/download/'+row.fileId,
               // url:window.open(row.fileUrl),
                //url:window.location.assign(row.fileurl),
                //actionName: 'download_file'  
            }  
        }) ;*/
    
   }
}