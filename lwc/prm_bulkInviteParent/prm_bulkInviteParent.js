import { LightningElement,track,api } from 'lwc';
import PRM_Donwload_BulkStatement from '@salesforce/label/c.PRM_Donwload_BulkStatement';
import PRM_Upload_BulkStatement from '@salesforce/label/c.PRM_Upload_BulkStatement';
import PRM_AfterUpload_BulkStatement from '@salesforce/label/c.PRM_AfterUpload_BulkStatement';
import PRM_Download1_BulkStatement from '@salesforce/label/c.PRM_Download1_BulkStatement';
import PRM_Note from '@salesforce/label/c.PRM_Note';
export default class Prm_bulkInviteParent extends LightningElement {
   
    label = {
        PRM_Upload_BulkStatement,
        PRM_Donwload_BulkStatement,
        PRM_AfterUpload_BulkStatement,
        PRM_Download1_BulkStatement,
        PRM_Note

    };

        
      
}