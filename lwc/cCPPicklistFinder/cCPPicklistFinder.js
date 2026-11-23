import { LightningElement, api, track, wire } from "lwc";
import getRecordTypePickListValues from "@salesforce/apex/Core_MDF_CCPPicklistFinder.getRecordTypePickListValues";
import getFieldValues from "@salesforce/apex/Core_MDF_CCPPicklistFinder.getFieldValues";
import getPickListValuesBasedOnRecordType from "@salesforce/apex/Core_MDF_CCPPicklistFinder.getPickListValuesBasedOnRecordType";
import getObjects from "@salesforce/apex/Core_MDF_CCPPicklistFinder.getObjects";
import getRecTypeItems from "@salesforce/apex/Core_MDF_CCPPicklistFinder.getRecTypeItems";
import getFieldItems from "@salesforce/apex/Core_MDF_CCPPicklistFinder.getFieldItems";
import getValueItems from "@salesforce/apex/Core_MDF_CCPPicklistFinder.getValueItems";
const s=[];
export default class CCPPicklistFinder extends LightningElement {
  selectedObject;
  selectedRecordType;
  selectedPicklist;
  @track picklistValues;
  @track recordTypeOptions;
  @track picklistFieldsOptions;
  @track isLoaded = true;

  @track selected;
  treeList;
  @wire(getObjects) objects({ data, error }) {
    if (data) {
      console.log('Data is'+data);
      this.treeList = Array.from(data);
      console.log('Here are the values of line 51'+ this.treeList);
    }
  }
  handleClick(e) {
    console.log ('Inside handle click');
    s.splice(0, s.length);
    console.log(this.treeList);
    //get the selected item
  
    if (this.selected == undefined) {
      this.selected = e.detail.name;
    } else if (!this.selected.includes(e.detail.name)) {
      this.selected = e.detail.name;
    }

    let newItemsToIterate = Array.from(
      JSON.parse(JSON.stringify(this.treeList))
    );
    console.log ('Items to iterate'+newItemsToIterate);
    let newItems = Array.from(JSON.parse(JSON.stringify(this.treeList)));
    //const branch = newItems.length;
    console.log ('Items to iterate 2'+newItems);
    let i = 0;let selectedItem = newItemsToIterate[i];let k=0;let j=0;
    while (newItemsToIterate.length != 0) {
                     
      newItems = Array.from(JSON.parse(JSON.stringify(this.treeList)));

      //get the root
      for(let x=0;x<newItemsToIterate.length;x++){
        //if clicked on camp->ccf then s=0 first then again 0
        if(this.selected.includes(newItemsToIterate[x].name)){
          
          s.push(x);
          j=x;
          break;
        }
      }
      
    
      for (i=j; i < newItemsToIterate.length; i++) {
        selectedItem = newItemsToIterate[i]; 
        console.log('line 65'+newItemsToIterate[i]);
        console.log('line 66'+newItemsToIterate[i].items.length);
        if (
          newItemsToIterate[i].name == this.selected &&
          newItemsToIterate[i].items.length == 0
        ) {
          //j = i;
          //get next items and add
          if (newItemsToIterate[i].isObject == true) {
            //if object selected get rec type
            console.log(this.selected);
            getRecTypeItems({ objName: this.selected })
              .then((result) => {
                console.log(result);
                this.addItems(selectedItem, result);
                //j=i;
                newItems[i] = selectedItem;
                this.treeList = newItems;
              })
              .catch((error) => {
                alert(error);
                this.error = error;
              });

            newItemsToIterate = newItemsToIterate[i].items;
            break;
          }
       
        
          
         else if (newItemsToIterate[i].isRecType == true) {
            console.log(this.selected);
            //fetch fields

            getFieldItems({ objName: this.selected })
              .then((result) => {
                console.log(result);
                this.addItems(selectedItem, result);
                //k=j;

                newItems[s[0]].items[i] = selectedItem;
                this.treeList = newItems;
              })
              .catch((error) => {
                alert(error);
                this.error = error;
              });
            newItemsToIterate = newItemsToIterate[i].items;
            break;
          }

        
          else if (newItemsToIterate[i].isField == true) {
            console.log('Value from 108'+this.selected);
            //fetch values for selected field

            getValueItems({ objName: this.selected })
              .then((result) => {
                console.log(result);
                this.addItems(selectedItem, result);
                newItems[s[0]].items[s[1]].items[i] = selectedItem;
                this.treeList = newItems;
              })
              .catch((error) => {
                alert(error);
                this.error = error;
              });
            newItemsToIterate = newItemsToIterate[i].items;
            break;
          }
        }
        if (i == newItemsToIterate.length - 1) {
          newItemsToIterate = newItemsToIterate[j].items;
          break;
        }
        
      }
    }

  }

  addItems(selectedItem, newItemList) {
    const newItemsLen = newItemList.length;
    for (let i = 0; i < newItemsLen; i++) {
      console.log(newItemList[i]);
      selectedItem.items.push(newItemList[i]);
    }
  }

  /*get objectOptions() {
    return [
      { label: "Campaign", value: "Campaign" },
      { label: "Activity", value: "PartnerFundRequest" },
      { label: "Case", value: "Case" },
      { label: "Claim", value:"PartnerFundClaim"},
      { label: "Exception", value:"Core_MDF_Exception__c"},
      { label: "Escalation",value:"Core_MDF_Escalation__c"}
    ];
  }

  handleObjectNameChange(event) {
    this.isLoaded = false;
    this.picklistValues = "";
    this.selectedRecordType = "";
    this.selectedPicklist = "";
    this.selectedObject = event.target.value;
    getRecordTypePickListValues({ objName: this.selectedObject })
      .then((result) => {
        this.isLoaded = true;
        console.log(result);
        this.recordTypeOptions = result;
      })
      .catch((error) => {
        alert(error);
        this.error = error;
      });
  }

  // update recordType Id variable/property on record Type picklist change
  handleRecordTypeChange(event) {
    this.isLoaded = false;
    this.picklistValues = "";
    this.selectedPicklist = "";
    let recTypeId = event.target.value;
    if (recTypeId === "") {
      this.lstRatings = [];
    }
    getFieldValues({ objName: this.selectedObject })
      .then((result) => {
        this.isLoaded = true;
        console.log(result);
        this.picklistFieldsOptions = result;
      })
      .catch((error) => {
        alert(error);
        this.error = error;
      });
    this.selectedRecordType = recTypeId;
  }

  handleFieldChange(event) {
    this.isLoaded = false;
    this.picklistValues = "";
    let picklistSelected = event.target.value;
    this.selectedPicklist = picklistSelected;
    getPickListValuesBasedOnRecordType({
      objApiName: this.selectedObject,
      recordTypeName: this.selectedRecordType,
      fieldName: picklistSelected
    })
      .then((result) => {
        this.isLoaded = true;
        console.log(result);
        this.picklistValues = result;
      })
      .catch((error) => {
        alert(error);
        this.error = error;
      });
  }*/
}