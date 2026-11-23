import { LightningElement, track, api, wire } from 'lwc';
import getOPIDAccounts from '@salesforce/apex/PRM_OPID_Util.getOPIDAccounts';

export default class IpaOnePartnerMap extends LightningElement 
{
    @track mapMarkers;
    @track mapTitle;
    @api recordId;
    @track markersTitle;
	error;
    @wire(getOPIDAccounts, { accountID: '$recordId' })
    wired_getOPIDAccounts({ error, data }) 
    {
        console.log('LINE 15 Record : ');
       this.markersTitle = 'Dell Account';
       this.mapTitle = 'Dell Global Account';
       this.mapMarkers = [];
		if (error) {
			this.error=error;
        } else if (data) 
        {
            console.log('Log 22 : '+ JSON.parse(data));
           // this.mapMarkers = JSON.parse(data);
		}
	}
    zoomLevel = 4;
    showFooter = true;
    listView = 'visible';
}