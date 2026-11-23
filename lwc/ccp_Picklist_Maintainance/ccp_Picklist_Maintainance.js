import { LightningElement, track, wire, api } from "lwc";
import getTreeGridData  from "@salesforce/apex/Core_MDF_Smart_Picklist_Maintainence.getTreeGridData";
import { getPicklistValues} from 'lightning/uiObjectInfoApi';


//import Campaign from "@salesforce/schema/Opportunity.Campaign";

const s=[];
const PRODUCT_COLUMNS = [{
    type: 'text',
    fieldName: 'Object1',
    label: 'Object1',
    
},
{
  type: 'button',
  typeAttributes: {
    label: 'View Dependency'
  }
}];
const SELECTED_PRODUCT_COLUMNS = [{
  type: 'text',
  fieldName: 'name',
  label: 'Value of selected type',
  title: '',
}];
export default class Ccp_Picklist_Maintainance extends LightningElement { 
    @track options;
    
  
  
    // to get the default record type id, if you dont' have any recordtypes then it will get master
  
    @track columns = [{
      type: 'text',
      fieldName: 'name',
      label: '  Object  ::  Record Type   ::   Fields '
  }
  /*{
    type: 'button',
    typeAttributes: {
      label: 'View Dependency'
    }
  }*/
  ];
  
  
  selectedObject;
  selectedRecordType;
  selectedPicklist;
  @track picklistValues;
  @track recordTypeOptions;
  @track picklistFieldsOptions;
  @track isLoaded = true;
  @track selected= [];
  @track tableColumns = SELECTED_PRODUCT_COLUMNS;
  @track tableColumns1 = SELECTED_PRODUCT_COLUMNS;
  @track dataForTable;
  @track dataForTable1;
  @track dataForTable2;
  @track rectype;
  treeItems;
  @track tempList = [];
  @track tempList1 = [];
  @track tempList3 = [];
  @track getSelectedRecords = [];
  @track selectedRows = [];
  @track currentSelectedRows;
  @api singleitem;
  @api twoitems;
  @track tableColumns = SELECTED_PRODUCT_COLUMNS;
  
  
  
  @wire(getTreeGridData)
  wireTreeData({
   error,
   data
  }) {
   if (data) {
       console.log('line 93');
       var tempjson = JSON.parse(JSON.stringify(data).split('items').join('_children'));
       this.treeItems = tempjson;
       this.dataForTable1 = JSON.stringify(data).split('name');
       console.log ('line 99'+this.dataForTable1);
     } else {
       this.error = error; 
       console.log('Error line 102'+this.error);
   }
  }
  
  @api objectName='Case';
  @api recordTypeNm='Audit';
  @api recordTypeId='0121J000000uIJ8QAM';
  @api concatvalue ='Case.Core_MDF_Status__c';
  @api objectName1='Case';
  @api recordTypeNm1='Audit';
  @api recordTypeId1='0121J000000uIJ8QAM';
  @api concatvalue1 ='Case.Core_MDF_Status__c';
  @api var = 0;
  @api apiFieldName = '';
  
  
    handleClick(event) {
        var tempList = [];
        let i=0;
         this.tempList = event.detail.selectedItem;
         console.log('line 117'+JSON.stringify(event.detail));
        console.log('line 61'+event.detail.name);
        console.log('line 119'+event.detail.ConCatname);
        console.log('line 62'+event.detail.hasChildrenContent); 
        console.log('line 63'+event.detail.isExpanded);
        let flag = event.detail.isExpanded;
        if (flag){this.var++;}
        console.log('line 115'+flag);
        console.log ('value of i'+this.var);
  
        this.selectedItem = event.detail.name;
        this.ischeck = true;
        const text = event.detail.name.split("+");
        if (this.var <=2 )
        {
        console.log ('Enter in first loop');
        this.objectName = text[0];
        this.recordTypeNm = text[1];
        this.recordTypeId = text[2];
        this.recordTypeNm1 = text[1];
        this.recordTypeId1 = text[2];
        this.fieldName=text[3];
        }
        else if (this.var > 2)
        {
          console.log ('Enter in 2nd loop');
          this.objectName1 = text[0];
          this.recordTypeNm1 = text[1];
          this.recordTypeId1 = text[2];
          this.fieldName1=text[3];
  
        }
        this.concatvalue = text[0]+'.'+text[3];
        console.log('line 121'+this.objectName);
        console.log('line 122'+this.recordTypeId);
        console.log('line 123'+this.recordTypeNm);
        console.log('line 143'+this.recordTypeNm1);
        
          
      }
  
      handleRowAction(event) {
         
        console.log('Inside 104'+event.detail.action.name);
        console.log('Inside 105'+event.detail.row.id);
  
    }
    getSelectedName(event)
    {
      const selectedRows = event.detail.selectedRows;
      console.log('121'+selectedRows);
      // Display that fieldName of the selected rows
      for (let i = 0; i < selectedRows.length; i++){
      alert("You selected: " + selectedRows[i].getSelectedName);
    }
  
  
    }
  
  
      handleSelectedRows()
      {
        console.log('Here at line 153');
        var tempList = [];
        var tempList1 = [];
        var tempList3 =[];
        var res = [];
        var selectRows = this.template.querySelector('lightning-tree-grid').getSelectedRows();
        var my_obj_str = JSON.stringify(selectRows);
  
        console.log ('Parameters'+my_obj_str);
        
        var stringify = JSON.parse(my_obj_str);
        console.log ('Parameters len'+stringify.length);
        for (var i = 0; i < stringify.length; i++) {
          res.push(stringify[i]['ConCatname']);
          tempList.push(stringify[i]['name']);
  
          console.log('line 166'+res);
          console.log('line 171'+tempList);
  
          
  
      }
      console.log('length of the result'+res.length);
      if (res.length == 2 )
      { 
        this.twoitems = true;
        const t2 =res.toString().split("+");
        console.log('line 180'+t2);
        const t3 = t2.toString().split(',');
        console.log('line 182'+t3);
        console.log('divided values0'+t3[0]);
        console.log('divided values1'+t3[1]);
        console.log('divided values2'+t3[2]);
        console.log('divided values3'+t3[3]);
        console.log('divided values4'+t3[4]);
        console.log('divided values5'+t3[5]);
  
        this.objectName = t3[0];
        this.recordTypeId = t3[1];
        this.apiFieldName=t3[2];
        this.concatvalue = t3[0]+'.'+t3[2];
        this.objectName1 = t3[3];
        this.recordTypeId1 = t3[4];
        this.apiFieldName1=t3[5];
        this.concatvalue1 = t3[3]+'.'+t3[5];
  
  
      }
      else if (res.length <= 1){
      this.singleitem=true;
      const text = res.toString().split("+");
      const text1 = tempList.toString().split(",");
      this.dispobjectName = text[0];
      this.disprecordTypeId = text[1];
      this.objectName = text[0];
      this.recordTypeId = text[1];
      this.apiFieldName=text[2];
      this.fieldnm = text1[0];
      this.concatvalue = text[0]+'.'+text[2];
  
      }
      else{
        alert ("You cannot select more than 2 items to compare");
      }
  
      console.log('line 144'+this.objectName);
      console.log('line 145'+this.recordTypeId);
      console.log('line 146'+this.apiFieldName);  
      console.log('line 207'+this.objectName1);
      console.log('line 208'+this.recordTypeId1);
      console.log('line 209'+this.apiFieldName1);
      console.log('line 221'+this.concatvalue);   
      console.log('line 222'+this.concatvalue1);   
      console.log('HI'+tempList3.items);
      console.log('line 189'+this.objectName);
      console.log('line 190'+this.recordTypeId);
      console.log('line 191'+this.apiFieldName);
    }
  
      @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$concatvalue' })
      picklistValues;
  
    
      @wire(getPicklistValues, { recordTypeId: '$recordTypeId1', fieldApiName: '$concatvalue1' })
      picklistValues1;
  
  
      handleChange(event) {
        this.value = event.detail.value;
    }
  }