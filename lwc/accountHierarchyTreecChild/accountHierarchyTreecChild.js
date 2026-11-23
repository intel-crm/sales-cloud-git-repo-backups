import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import findHierarchyData from '@salesforce/apex/Core_MDF_AcctHierarchyDetailController.findHierarchyData';
export default class AccountHierarchyTreecChild extends LightningElement {

    @api recordId;
    @track gridColumns = [
        {
            type: 'url',
            fieldName: 'AccountURL',
            label: 'Account Name',
            typeAttributes: {
                label: { fieldName: 'accountName' }
            }
        }
     ];
    @track searchValue;
    @track gridData;
    @track gridExpandedRows;
    @track error;
    @wire(findHierarchyData, { recId: '$recordId' })
     wireTreeData({
         error,
         data
     }) { 
         if (data) {
            var res = data;
            var expandedRows = [];
            var apexResponse = res;
            var roles = {};
            console.log('child recordId-----'+this.recordId);
            console.log('****child***apexResponse:'+JSON.stringify(apexResponse));
            var results = apexResponse;
            roles[undefined] = { Name: "Root", _children: [] };
            apexResponse.forEach(function(v) {
                expandedRows.push(v.Id);
                roles[v.Id] = { 
                    accountName: v.Name ,
                    name: v.Id,
                    region:v.Core_Geo__c,
                    subRegion:v.Core_Sub_Geo__c,
                    AccountURL:'/'+v.Id,
                    _children: [] };
            });
            apexResponse.forEach(function(v) {
                roles[v.Core_MDF_Parent_Fund_Account__c]._children.push(roles[v.Id]);   
            });
            this.gridData = roles[undefined]._children;
            console.log('****child***apexResponse:'+JSON.stringify(this.gridData));
            this.gridExpandedRows = roles[undefined]._children;
         } else {
             this.error = error;
             //  alert('error' + error);
         }

     }

}