import { LightningElement,wire,track } from 'lwc';
import fetchSampleRecs from '@salesforce/apex/MaintenanceScreen.fetchSampleRecs';
import fetchSampleRecs1 from '@salesforce/apex/MaintenanceScreen.fetchSampleRecs1';
import ParentId from '@salesforce/schema/Account.ParentId';
const columns = [
    { label: 'UserOrGroupName', fieldName: 'UserOrGroupName', type: 'text',editable: false },
    { label: 'AccessLevel', fieldName: 'AccessLevel', type: 'text',editable: false },
    { label: 'RowCause', fieldName: 'RowCause', type: 'text',editable: false },
    //{ label: 'ParentId', fieldName: 'ParentId', type: 'Id',editable: false },
   
];
export default class Maintenance_Screen extends LightningElement {
    data1 = [];
    recordId = ['0RJg00000008aUsGAI','0RJg00000008aUsGAI'];
    columns = columns;
    error;
    errorMsg;
    optionList;
    ops = [];
    optionList1;
    options2;
    result;
    result1;
    displayFields =false;
    objectDropdownvalues;
    final;
    enabled =true;
    @track  _selected;
    completeDropdownFieldvalues;
    values = [];
    objectShareName;
    @wire( fetchSampleRecs )  
    wiredRecs( value ) {
        const { data, error } = value;
        let records = [];
        this.objectDropdownvalues = [];
        if (data && data.length >0 ) {
            console.log('Full data',data); 
            let fullData = data;
            this.completeDropdownFieldvalues = data;
            fullData.map(data => {
                   let index = this.objectDropdownvalues.findIndex(element => element.label === data.Core_MDF_Object_Label__c )
                   console.log('Index',index);
                    if(index == -1)
                     {
                                console.log('Index1');
                                let dropdwonObj = {};
                                dropdwonObj.label = data.Core_MDF_Object_Label__c;
                                dropdwonObj.value = data.Core_MDF_Object_API_Name__c;
                                this.objectDropdownvalues.push(dropdwonObj);
                     }
                    // this.completeDropdownFieldvalues.push({})
                
            })        
            console.log('FirstPic1',this.objectDropdownvalues);
            console.log('ShareObjectName',this.objectShareName);

        } else if ( error ) {

            this.error = error;
            this.records = undefined;

        }
        
    }
    /*@wire( fetchSampleRecs1 , {ObjectName : '$objectShareName',selectedRecId : ['0RJg00000008aUsGAI']}) 
    wiredRecs1( value ) {
        console.log('Second wire is called',value);
        const { data, error } = value;
        if(data)
        {
           let temp = JSON.parse(JSON.stringify(data));
           let mapvalues = new Map(Object.entries(temp));
           console.log('Data',mapvalues);
           this.data1=mapvalues.get('0RJg00000008aUsGAI');
           console.log('sharing data',this.data1);
        }
        }
    */
    handleChange(event)
    {   
        this.final =[];
        this.values=[];
        this.enabled =false;
        console.log('Selected',this._selected);
        this._selected =[];
        console.log('Selected1',this._selected);
        console.log('Finalvalue',this.final);
        this.result = event.target.value;
        this.completeDropdownFieldvalues.map(val => {
            if(val.Core_MDF_Object_API_Name__c  == this.result) {
                  this.objectShareName = val.ShareObject__c;
            }
            })
            console.log('ShareObject',this.objectShareName);
        console.log('First---',this.result);
        this.getFieldvaluebasedonObject(this.result);
   }

 getFieldvaluebasedonObject(objName){
    
    let options = [];
    this.completeDropdownFieldvalues.map(val => {
    if(val.Core_MDF_Object_API_Name__c  == objName) {
    options.push({label: val.Core_MDF_Field_Label__c, value: val.Core_MDF_Field_API_Name__c});
    }
    })
    console.log('final1',options);
    this.final.push(...options);
    this.values.push(...[]);
    this.enabled =true;
  }
    get selected() {
        return this._selected.length ? this._selected : 'none';
       
    }

    handleChange2(e) {
        this._selected =e.target.value;
        console.log('Selected2',this._selected);
       
    }
 
    handleClick() {
        fetchSampleRecs1({ObjectName : this.objectShareName,selectedRecId : this.recordId}) 
        .then(result =>{
           // this.ops = result;
            //console.log('Finally',ops);
            let temp = JSON.parse(JSON.stringify(result));
            let mapvalues = new Map(Object.entries(temp));
            console.log('Data',mapvalues);
            this.data1=mapvalues.get('0RJg00000008aUsGAI');
            console.log('sharing data',this.data1);
        })
        .catch(error =>{
            this.errorMsg = error;
            console.log('Error',this.errorMsg);
        })
    }
}