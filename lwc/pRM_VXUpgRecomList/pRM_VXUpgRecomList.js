import { LightningElement, track, wire, api } from 'lwc';

// importing Apex Class
import getUpgRecList from '@salesforce/apex/PRM_VXUpgRecomListController.getUpgRecList';
import fetchChildRecords from '@salesforce/apex/PRM_VXUpgRecomListController.fetchChildRecords';
import updateRecords from '@salesforce/apex/PRM_VXUpgRecomListController.updateRecords';
import updateStatus from '@salesforce/apex/PRM_VXUpgRecomListController.updateStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import PRM_Icon_New from '@salesforce/label/c.PRM_Icon_New';
import PRM_Icon_Dash from '@salesforce/label/c.PRM_Icon_Dash';
import PRM_Icon_chevronright from '@salesforce/label/c.PRM_Icon_chevronright';
import PRM_Action_Expand from '@salesforce/label/c.PRM_Action_Expand';
import PRM_Action_Upgrade from '@salesforce/label/c.PRM_Action_Upgrade';
import PRM_OPID_Upgrade_Success_Msg from '@salesforce/label/c.PRM_OPID_Upgrade_Success_Msg';
import PRM_OPID_Upgrade_Error_Msg from '@salesforce/label/c.PRM_OPID_Upgrade_Error_Msg';
import PRM_Location_Accs_Error_Msg from '@salesforce/label/c.PRM_Location_Accs_Error_Msg';
import PRM_OPID_Update_Success_Msg from '@salesforce/label/c.PRM_OPID_Update_Success_Msg';
import PRM_OPID_Update_Error_Msg from '@salesforce/label/c.PRM_OPID_Update_Error_Msg';
import PRM_Partner_Role_Error_Msg from '@salesforce/label/c.PRM_Partner_Role_Error_Msg';
import PRM_OPID_Account_Name from '@salesforce/label/c.PRM_OPID_Account_Name';
import PRM_Partner_Role_Column from '@salesforce/label/c.PRM_Partner_Role_Column';
import PRM_Tier_Column from '@salesforce/label/c.PRM_Tier_Column';
import PRM_Market_Type from '@salesforce/label/c.PRM_Market_Type';
import PRM_Total_Sales from '@salesforce/label/c.PRM_Total_Sales';
import PRM_Training_Count_Col from '@salesforce/label/c.PRM_Training_Count_Col';
import PRM_Emp_Training_Col from '@salesforce/label/c.PRM_Emp_Training_Col';
import PRM_MP_Solutions_Col from '@salesforce/label/c.PRM_MP_Solutions_Col';
import PRM_Nbr_Achieved_Column from '@salesforce/label/c.PRM_Nbr_Achieved_Column';
import PRM_Rank from '@salesforce/label/c.PRM_Rank';
import PRM_Spec_Present from '@salesforce/label/c.PRM_Spec_Present';
import PRM_Select_Benefit from '@salesforce/label/c.PRM_Select_Benefit';
import PRM_Notes_Col from '@salesforce/label/c.PRM_Notes_Col';
import PRM_Integ_Report from '@salesforce/label/c.PRM_Integ_Report';
import PRM_Acc_Plan_Ind from '@salesforce/label/c.PRM_Acc_Plan_Ind';
import PRM_Eligibility_Tier from '@salesforce/label/c.PRM_Eligibility_Tier';
import PRM_Recom_Type from '@salesforce/label/c.PRM_Recom_Type';
import PRM_Status_Column from '@salesforce/label/c.PRM_Status_Column';
import PRM_Upgrade_Column from '@salesforce/label/c.PRM_Upgrade_Column';

// Datatable Columns
const columns = [
    {
        type: 'button',
        fixedWidth: 110,
        typeAttributes: {
            label: PRM_Upgrade_Column,
            name: 'upgrade',
            title: 'Upgrade OPID',
            alternativeText: 'Upgrade OPID',
            variant: 'brand-outline',
            size: 'small',
            disabled: { fieldName: 'disableUpgBotton'}
        }
    },{
        type: 'button-icon',
        fixedWidth: 40,
        /*typeAttributes: {iconName: 'action:new', title: 'Expand', variant: 'border-filled', alternativeText: 'View'}*/
        typeAttributes: {
            iconName: {
                fieldName: 'operation'
            },
            name: 'Expand',
            title: 'Expand',
            variant: 'bare',
            size: 'small',
            alternativeText: 'Expand',
            disabled: { fieldName: 'disableIcon'}
        }
    }, {
        label: PRM_OPID_Account_Name,
        fieldName: 'nameUrl',
        type: 'url',
        initialWidth: 150,
        typeAttributes: { label: { fieldName: 'opidName' }, target: '_blank' }
    }, {
        label: PRM_Partner_Role_Column,
        fieldName: 'partnerRole',
        type: 'text',
        initialWidth: 150
    }, {
        label: PRM_Tier_Column,
        fieldName: 'tier',
        type: 'text',
        initialWidth: 100
    }, {
        label: PRM_Market_Type,
        fieldName: 'marketType',
        type: 'text',
        initialWidth: 100
    },/*{
        label: 'Sales Type',
        fieldName: 'salesGroup',
        type: 'text'
    },*/ {
        label: PRM_Total_Sales,
        fieldName: 'totalSales',
        type: 'number',
        initialWidth: 100
    },{
        label: PRM_Training_Count_Col,
        fieldName: 'trainingPointsCount',
        type: 'number',
        initialWidth: 100
    }, {
        label: PRM_Emp_Training_Col,
        fieldName: 'noOfEmpDoneTraining',
        type: 'number',
        initialWidth: 100
    }, {
        label: PRM_MP_Solutions_Col,
        fieldName: 'noOfMPSolutions',
        type: 'number',
        initialWidth: 100
    }, {
        label: PRM_Nbr_Achieved_Column,
        fieldName: 'trainingCompetancy',
        type: 'number',
        initialWidth: 100
    },  {
        label: PRM_Rank,
        fieldName: 'rank',
        type: 'number',
        initialWidth: 100
    },{
        label: PRM_Spec_Present,
        fieldName: 'specialtyPresent',
        type: 'text',
        initialWidth: 100
    }, {
        label: PRM_Select_Benefit,
        fieldName: 'selectBenefit',
        type: 'text',
        initialWidth: 170
    },{
        label: PRM_Notes_Col,
        fieldName: 'notes',
        type: 'text',
        initialWidth: 200,
        editable: true
    },{
        label: PRM_Integ_Report,
        fieldName: 'submittedIntegReport',
        type: 'boolean',
        initialWidth: 100,
        editable: true
    },{
        label: PRM_Acc_Plan_Ind,
        fieldName: 'accountPlanInd',
        type: 'boolean',
        initialWidth: 100,
        editable: true
    },{
        label: PRM_Eligibility_Tier,
        fieldName: 'elegibilityTier',
        type: 'text',
        initialWidth: 100
    }, {
        label: PRM_Recom_Type,
        fieldName: 'recommType',
        type: 'text',
        initialWidth: 100
    }, {
        label: PRM_Status_Column,
        fieldName: 'status',
        type: 'text',
        initialWidth: 100
    }/*, {
        type: 'button',
        fixedWidth: 120,
        typeAttributes: {
            label: 'Upgrade',
            name: 'upgrade',
            title: 'Upgrade OPID',
            alternativeText: 'Upgrade OPID',
            variant: 'brand-outline',
            size: 'small',
            disabled: { fieldName: 'disableUpgBotton'}
        }
    }*/
];

export default class PRM_VXUpgRecomList extends LightningElement {
    @track data = [];
    @track error;
    @track columns = columns;
    @track draftValues = [];
    @track updatedDataList = [];
    @track spinner = false;
    @track updatedDataList = [];
    @track tempdata = [];
    @api objectName = "PRM_Value_Exchange_Recommendation__c";
    @api fieldName = "PRM_Partner_Role_Nm__c";
    @track fieldLabel;
    @api recordTypeId;
    @api value;
    @track selectOptions = [{ label: "--None--", value: "Select" }];
    //@track originalData = [];
    @track childRecordData = [];
    @track currDraftValuesKey = [];
    @track currentAllData = [];
    @track ischildRecord = false;
    apiFieldName;
    refreshTable;

    @wire(getObjectInfo, { objectApiName: "$objectName" })
    getObjectData({ error, data }) {
        if (data) {
        if (this.recordTypeId == null)
            this.recordTypeId = data.defaultRecordTypeId;
        this.apiFieldName = this.objectName + "." + this.fieldName;
        this.fieldLabel = data.fields[this.fieldName].label;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getPicklistValues, {recordTypeId: "$recordTypeId",fieldApiName: "$apiFieldName"})
      getPicklistValues({ error, data }) {
        if (data) {
          // Map picklist values
          for (let lst = 0; lst < data.values.length; lst++) {
            const option = {
              label: data.values[lst].label,
              value: data.values[lst].label
            };
            this.selectOptions = [...this.selectOptions, option];
          }
        } else if (error) {
            this.error = error;
        }
      }

    @wire(getUpgRecList)
    recommRecords(result) {
        this.refreshTable = result;
        //const {data,error} = result;
        let temp = [];
        if (result.data) {
            let nameUrl;
            let parentRecList = result.data.parentRecList;
            this.data = parentRecList.map(row => {
                nameUrl = `/${row.id}`;
                return { ...row, nameUrl }
            })
            if (this.value === "Select" || this.value === undefined) {
                this.tempdata = this.data;
            }else {
                for (let lst = 0; lst < this.data.length; lst++) {
                  if (this.data[lst].partnerRole === this.value) {
                    temp.push(this.data[lst]);
                  }
                }
              this.tempdata = temp;
            }
        }
        else if (result.error) {
            this.error = result.error;
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        const actionName = event.detail.action.name;
        console.log('Action Name: '+actionName);
        console.log('Clicked Icon: '+row.operation);
        if(actionName === PRM_Action_Expand){
            if(row.operation === PRM_Icon_New){
                let temp = [];
                //this.originalData = this.tempdata;
                fetchChildRecords({key: row.key})
                    .then(returnedlstResult => {
                        let nameUrl;
                        this.childRecordData = returnedlstResult.map(row => {
                            nameUrl = `/${row.id}`;
                            return { ...row, nameUrl }
                        })
                        if (this.value === "Select" || this.value ===undefined) {
                            this.tempdata = this.childRecordData;
                        } 
                        else {
                            for (let lst = 0; lst < this.childRecordData.length; lst++) {
                              if (this.childRecordData[lst].partnerRole === this.value) {
                                temp.push(this.childRecordData[lst]);
                              }
                            }
                          this.tempdata = temp;
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });
            }
            else if(row.operation === PRM_Icon_Dash || row.operation === PRM_Icon_chevronright){
                let temp = [];
                for(let lst = 0; lst < this.tempdata.length; lst++){
                    if(this.tempdata[lst].operation === PRM_Icon_New){
                        temp.push(this.tempdata[lst]);
                    } else{
                        if(this.tempdata[lst].operation === PRM_Icon_Dash){
                            this.tempdata[lst].operation = PRM_Icon_New;
                            temp.push(this.tempdata[lst]);
                        }
                    }
                }
                this.tempdata = temp;
                refreshApex(this.refreshTable);
            }
        }
        else if(actionName === PRM_Action_Upgrade){
            this.spinner = true;
            console.log('Onclick on Upgarde Button:');
            console.log('Current Row Data: '+JSON.stringify(row));
                updateStatus({key: row.key})
                .then(result =>{
                    if(result === true){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: PRM_OPID_Upgrade_Success_Msg,
                                variant: 'success'
                            })
                        );
                        this.spinner = false;
                        return refreshApex(this.refreshTable);  
                    }
                    else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Failed',
                                message: PRM_OPID_Upgrade_Error_Msg,
                                variant: 'error'
                            })
                        );
                         // Clear all draft values
                         this.draftValues = [];
                         this.spinner = false;
                         return refreshApex(this.refreshTable);
                    }
                })
                .catch(error =>{
                    this.error = error;
                });
        }
    }

    handleSave(event) {
        this.spinner = true;
        this.draftValues =  event.detail.draftValues;
        let toUpdateList = JSON.parse(JSON.stringify(this.draftValues));
        //console.log('Parsed stringify: '+JSON.stringify(toUpdateList));

        for(let i = 0;i<this.tempdata.length;i++){
            for(let j=0;j<this.draftValues.length;j++){
                if((this.tempdata[i].key === this.draftValues[j].key) && (this.tempdata[i].operation === PRM_Icon_chevronright)){
                    this.ischildRecord = true;
                    //console.log('Matched Key for child: '+this.draftValues[j].key);
                }
            }
        }

        if(this.ischildRecord === true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Not Allowed',
                    message: PRM_Location_Accs_Error_Msg,
                    variant: 'error'
                })
            );
             // Clear all draft values
             this.draftValues = [];
             this.spinner = false;
             this.ischildRecord = false;
             return refreshApex(this.refreshTable);
        }else{
            updateRecords({draftValues: toUpdateList})
            .then(returnValue =>{
                if(returnValue === true){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: PRM_OPID_Update_Success_Msg,
                            variant: 'success'
                        })
                    );
                     // Clear all draft values
                     this.draftValues = [];
                     this.spinner = false;
                     return refreshApex(this.refreshTable);                 
                }
                else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Failed',
                            message: PRM_OPID_Update_Error_Msg,
                            variant: 'error'
                        })
                    );
                     // Clear all draft values
                     this.draftValues = [];
                     this.spinner = false;
                     return refreshApex(this.refreshTable);
                }
            })
            .catch(error =>{
                this.error = error;
            });
        }
    }
    
    handleChange(event) {
        this.value = event.detail.value;
        var selected = event.detail.value;
        let temp = [];
        if (selected === "Select") {
          this.tempdata = this.data;
        } else {
          for (let lst = 0; lst < this.data.length; lst++) {
            if (this.data[lst].partnerRole === selected) {
              temp.push(this.data[lst]);
            }
          }
          if(temp.length > 0){
            this.tempdata = temp;
          }else{
            this.tempdata = [];  
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Records Found',
                    message: PRM_Partner_Role_Error_Msg,
                    variant: 'error'
                })
            );
          }
        }
    }
}