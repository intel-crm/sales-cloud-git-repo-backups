import { LightningElement,wire,track } from 'lwc';
import getOpportunityLineItem from '@salesforce/apex/Core_opportunityproduct_listprice_contrl.getOpportunityLineItem';
const columns = [
    { label: 'Date', fieldName: 'createdDate'},
    //{ label: 'Field', fieldName: 'Field'},
    { label: 'User', fieldName: 'createdBy'},
    { label: 'Orginal Value', fieldName: 'oldValue'},
    { label: 'New Value', fieldName: 'newValue'} 
];
export default class Core_opportunityproduct_listprice extends LightningElement {
   columns = columns;
   debugger;   
    @track oppprod ={};
   //@wire(getOpportunityLineItem) oppprod;
connectedCallback(){
  getOpportunityLineItem()
  .then(data => {
      console.log(data);
      this.oppprod=data;

  })
  .catch(error => {
      console.log('error'+JSON.stringify(error));
  });
  //console.log('Test--'+oppprod);
}
   //Console.log('Test--',oppprod);
  //System.debug(+oppprod);
   
}