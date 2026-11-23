import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import findHierarchyData from '@salesforce/apex/Account_Hierarchy_TreeGrid_1.findHierarchyData';
export default class AccountHierarchyTree extends LightningElement {

    @track gridColumns = [
        {
            type: 'url',
            fieldName: 'AccountURL',
            label: 'Account Name',
            typeAttributes: {
                label: { fieldName: 'accountName' }
            }
        },
        {
            type: 'url',
            fieldName: 'AccountURL',
            label: 'Account Id',
            typeAttributes: {
                label: { fieldName: 'name' }
            }
        }
     ];
    
    @track searchValue;
    @track gridData;
    @track gridExpandedRows;
    @track error;
    @wire(findHierarchyData)
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
             this.gridExpandedRows = roles[undefined]._children;
             //console.log(JSON.stringify(tempjson, null, '\t'));
         } else {
             this.error = error;
             //  alert('error' + error);
         }

     }

    

    
}