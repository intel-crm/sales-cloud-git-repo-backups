import { LightningElement, api, track, wire } from 'lwc';
import getQLIWithFieldSet from '@salesforce/apex/CRM_QuoteRequestController.getQLIWithFieldSet';


export default class crm_quoteLineRelatedList extends LightningElement{
  
    @api recordId;  
    @api objectApiName;
    @track quoteLineItems=[];
    @track columns=[];
    @track copyQuoteline=[];
    qlsize;
    error;
    @track userProfileName;
     
    connectedCallback(){
        getQLIWithFieldSet({recId: this.recordId})
        .then((result) => {
            this.quoteLineItems = result.QuoteLineItems;
            this.userProfileName = result.ProfileName;
            this.columns = this.parseFieldSet(result.FieldSetWrapList);            
            this.qlsize=this.quoteLineItems.length;
            if(this.quoteLineItems.length>0){
                this.copyQuoteline=this.quoteLineItems.map(quoteLineItem => {
                    return {...quoteLineItem, ...this.modifyColumns(quoteLineItem)}
                });
                
            }
          })
          .catch((error) => {
            this.error = error;
          });
      }

      modifyColumns(copyQL){
        let newMap={}
        this.columns.forEach(column => {
            const fieldvalue = column.actual;
            if (fieldvalue.includes('.')) {
                const [field1, field2] = fieldvalue.split('.');
                if (copyQL[field1] && copyQL[field1][field2]) {
                    const combinedField= field1+field2;
                    newMap[combinedField] = copyQL[field1][field2];
                    newMap[field1+'Id'] = copyQL[field1]['Id'];
                } 
            }
            if(column.type==='url' && column.fieldName!='Id'){
               
                    newMap[column.fieldName]='/'+newMap[column.fieldName];
                
            }
            if(column.type==='url' && column.fieldName=='Id'){
               
                    newMap[column.fieldName]='/'+copyQL[column.fieldName];
            }
        });
        return newMap;
      }

    // Parse the field set and generate columns
    parseFieldSet(fieldSetMap) {
        const columns = [];
        const dateatt= {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        };
        const idatt= {label: { fieldName: 'Pricing_Quote_Line_Number__c'},tooltip:{fieldName :'Pricing_Quote_Line_Number__c'} , target: '_blank'};
        // Loop through the field set map to construct columns
        fieldSetMap.forEach(column => {
                // Add column configuration for each field
                const fieldvalue = column.ApiName;
                let type=column.Type;
                let fieldId,fieldLabel;
                if(fieldvalue.includes('.')){
                    const field1 = fieldvalue.substring(fieldvalue, fieldvalue.indexOf("."));
                    const field2 =fieldvalue.substring(fieldvalue.indexOf(".")+1,fieldvalue.length);
                    fieldLabel=field1+field2;
                    fieldId=field1+'Id';
                    if(this.userProfileName === 'Partner'){
                        type='textPartner';
                    }else{
                        type='url';
                    }
                }
                if(column.Type ==='date'){
                    columns.push({
                        label: column.Label,
                        fieldName: fieldvalue,
                        actual:column.ApiName,
                        type: column.Type,
                        typeAttributes:dateatt
                    });
                }
                else if(column.Type ==='Id'){
                    if(this.userProfileName === 'Partner'){
                        columns.push({
                            label: 'Quote Line Number',
                            fieldName: 'Pricing_Quote_Line_Number__c',
                            actual:column.ApiName,
                            type: 'text',
                            typeAttributes:idatt
                        });
                    }
                    else{
                        columns.push({
                            label: 'Quote Line Number',
                            fieldName: column.ApiName,
                            actual:column.ApiName,
                            type: 'url',
                            typeAttributes:idatt
                        });
                    }
                }
                else if(type==='url'){
                    columns.push({
                        label: column.Label,
                        fieldName: fieldId,
                        actual:column.ApiName,
                        type:'url',
                        typeAttributes: {label: { fieldName: fieldLabel }, tooltip:{fieldName:fieldLabel}, target: '_blank'}
                    });
                }
                else if(type==='currency'){
					columns.push({
                        label: column.Label,
                        fieldName: column.ApiName,
                        actual:column.ApiName,
                        type: 'currency',
						cellAttributes: { alignment: 'left' },
                        typeAttributes:{ maximumFractionDigits: '2', currencyCode: 'USD' }
                    });
				}
                else if(type==='textPartner'){
                    columns.push({
                        label: column.Label,
                        fieldName: fieldLabel,
                        actual:column.ApiName,
                        type: 'text' 
                    });
                }
                else{
                    columns.push({
                        label: column.Label,
                        fieldName: column.ApiName,
                        actual:column.ApiName,
                        type: type
                    });
                }
                
        });
        return columns;
    }
   get qlLength(){
        if(this.qlsize===0){
            return true;
        } 
   }
   get objname(){
    if (this.objectApiName==='Opportunity'){
        return true;
    }
   }
 }