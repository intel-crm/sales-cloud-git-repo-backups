import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import findHierarchyData from '@salesforce/apex/Core_MDF_AcctHierarchyDetailController.findHierarchyData';
export default class Core_MDF_AcctHierarchyDetailLWC extends LightningElement {
    @api recordId = '001g000002KveA0AAJ';
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
             //  alert(data);
             var res = data;
             var expandedRows = [];
             var apexResponse = res;
             var roles = {};
             console.log('*******apexResponse:'+JSON.stringify(apexResponse));
             var results = apexResponse;
             roles[undefined] = { Name: "Root", items: [] };
             apexResponse.forEach(function(v) {
                 expandedRows.push(v.Id);
                 roles[v.Id] = { 
                    label: v.Name,
                    name:'/'+v.Id,
                    href:'/'+v.Id,
                    expanded: true,
                     items: [] };
             });
             console.log('roles-----'+JSON.stringify(roles));
             apexResponse.forEach(function(v) {
                console.log('roles---2--'+JSON.stringify(roles[v.Id]));
                 roles[v.Core_MDF_Parent_Fund_Account__c].items.push(roles[v.Id]);   
             });
             this.gridData = roles[undefined].items;
             console.log('this.gridData-----'+JSON.stringify(this.gridData));
             //this.gridExpandedRows = roles[undefined]._children;
            // console.log(JSON.stringify(tempjson, null, '\t'));
         } else {
             this.error = error;
             //  alert('error' + error);
         }

     }

    

    
}