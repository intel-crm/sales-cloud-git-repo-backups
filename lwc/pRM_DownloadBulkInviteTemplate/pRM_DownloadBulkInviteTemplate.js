import { LightningElement, track} from 'lwc'; 
export default class PRM_DownloadBulkInviteTemplate extends LightningElement {

    columnNames = ['Contact Email','First Name','Last Name']
    
    // this method is used to download the template
    downloadBulkInviteTemplateFile() {           
        let doc = '';
        this.columnNames.forEach(element => {            
            doc += element+',';           
        });
        

        var element = 'data:text/csv;charset=utf-8,'+ encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        
        downloadElement.download = 'Bulk Invite Template.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
 
}