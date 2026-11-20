import { LightningElement, track, api } from 'lwc';
import labelFileSizeInfo from '@salesforce/label/c.Core_MDF_VAT_File_Size_Info';
import labelDuplicateFileInfo from '@salesforce/label/c.Core_MDF_VAT_Duplciate_File_Info';
import hasClaimSubmitter from '@salesforce/customPermission/Core_MDF_RetailClaimSubmitter';
import hasIPAClaimSubmitter from '@salesforce/customPermission/Core_MDF_IPAClaimSubmitter'; // Added by Areefa 
export default class Core_MDF_Info_Banner extends LightningElement {

    @track message = labelFileSizeInfo;
    //@api showMultiFilesMessage = false;

    connectedCallback() { 
        this.hasClaimSubmitterPermission();
    }
    @api hasClaimSubmitterPermission() { 
        if (hasClaimSubmitter || hasIPAClaimSubmitter) { 
            this.message = labelFileSizeInfo + ' ' + labelDuplicateFileInfo;
            //this.showMultiFilesMessage = true;
        }
        else { 
            this.message = labelFileSizeInfo;
        }
    }
}