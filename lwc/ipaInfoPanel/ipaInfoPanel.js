import { LightningElement } from 'lwc';
import InfoPanel1label from '@salesforce/label/c.PMP_Storefornt_InfoPanel1';
import InfoPanel2label from '@salesforce/label/c.PMP_Storefornt_InfoPanel2';
import InfoPanel3label from '@salesforce/label/c.PMP_Storefornt_InfoPanel3';
import InfoPanelDesciption1label from '@salesforce/label/c.PMP_Storefornt_InfoPanelDescription1';
import InfoPanelDesciption2label from '@salesforce/label/c.PMP_Storefornt_InfoPanelDescription2';
import InfoPanelDesciption3label from '@salesforce/label/c.PMP_Storefornt_InfoPanelDescription3';
import pmpStoreforntInfoPanelUrlLabel1 from '@salesforce/label/c.PMP_Storefornt_InfoPanelUrl1';
import pmpStoreforntInfoPanelUrlLabel2 from '@salesforce/label/c.PMP_Storefornt_InfoPanelUrl2';
import pmpStoreforntInfoPanelUrlLabel3 from '@salesforce/label/c.PMP_Storefornt_InfoPanelUrl3';
import myResource1 from '@salesforce/resourceUrl/PMP_InfoPanel_Logo_1';
import myResource2 from '@salesforce/resourceUrl/PMP_InfoPanel_Logo_2';
import myResource3 from '@salesforce/resourceUrl/PMP_InfoPanel_Logo_3';

/**
 * IPA Info Panel Component
 *
 * @augments LightningElement
 */
export default class IpaInfoPanel extends LightningElement {
    
    ipaInfoShare = [
      {
        label: InfoPanel1label,
        description: InfoPanelDesciption1label,
        resource: myResource1,
        url: pmpStoreforntInfoPanelUrlLabel1,

      },
      {
        label: InfoPanel2label,
        description: InfoPanelDesciption2label,
        resource: myResource2,
        url: pmpStoreforntInfoPanelUrlLabel2,

      },
      {
        label: InfoPanel3label,
        description: InfoPanelDesciption3label,
        resource: myResource3,
        url: pmpStoreforntInfoPanelUrlLabel3,

      },
    ];
}