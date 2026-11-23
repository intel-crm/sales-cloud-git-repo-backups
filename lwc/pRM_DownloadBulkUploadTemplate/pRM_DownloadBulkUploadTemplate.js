import { LightningElement, track,api} from "lwc"; 
export default class PRM_DownloadBulkInviteTemplate extends LightningElement {
  @api downloadtemp;

    // Utkarsh - TWC727-1237 - Added partner FAE and end custmoer url field.
    columnNames = ['Group ID','Header/Product','Design Registration Line ID','Product','Quantity (Full Production Year)','Target Resale Price','Partner Tracking Number','Cancelled (Y)','Product Comments','Registration Number','Owner (Email)','Product Group','Design Registration Name','Description','Opportunity Volume','Partner FAE','Partner FSR','Design Solution Network','End Customer Name','End Customer Address1','End Customer Address2','End Customer City','End Customer State','End Customer Zip/Postal Code','End Customer Country','End Customer Contact Title','End Customer Contact Name','End Customer Contact Email','End Customer Contact Phone','Are Intel items used for MINDS? (It is the Intel Partner\'s responsibility to understand the export customs and sanction controls applicable to Intel Partner\'s company project and product and take all actions necessary to ensure compliance.)','Decision Date','First Customer Ship Date','Production End Date','Vertical Market','Intel Platform','Product Segment','Product Application','Manufacturing Region','FPGA Quote Comments','End Customer URL','Partner FAE Email']
    // this method is used to download the template
    downloadBulkuploadTemplateFile() {           
        let doc = "";
        this.columnNames.forEach((element) => {            
            doc += element+",";           
        });
        
        let universalBOM = '\uFEFF';// Utkarsh - TWC727-1237 - Changes done to download file in UTF-8 CSV.	
        var element = "data:text/csv;charset=utf-8,"+ encodeURI(universalBOM + doc); //+ encodeURIComponent(doc);
        let downloadElement = document.createElement("a");
        downloadElement.href = element;
        downloadElement.target = "_self";
        
        downloadElement.download = "Bulk Upload Template.csv";
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
}