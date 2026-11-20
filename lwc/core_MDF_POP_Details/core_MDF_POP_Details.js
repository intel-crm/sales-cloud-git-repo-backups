import { LightningElement, api, wire } from "lwc";
import getPOPvalue from "@salesforce/apex/Core_MDF_POP_Details.getPOPvalues";
import Core_MDF_ApplicationErrorMessage from "@salesforce/label/c.Core_MDF_POP_ErrorMsg";

export default class Core_MDF_POP_Details extends LightningElement {

    @api recordId;
    @api recordIdinput;
    @api objectApiName;
    @api objectApiNameinput;
    @api displayLabel;
    @api actCat
    @api actType
    @api recTypeName
    @api actSubType

    displayHeader;
    result = '';
    haserror = false;
    isValidPOPdata = false;

    label = {
        Core_MDF_ApplicationErrorMessage
    };

    connectedCallback() {
        /* eslint-disable no-console*/
        if (this.recordIdinput !== undefined) {
            this.recordId = this.recordIdinput;
        }
        if (this.objectApiNameinput !== undefined) {
            this.objectApiName = this.objectApiNameinput;
        }   

        /*POP Details Object for all parameter  */
        var popDetailObj={
            recordId : this.recordId,
            objectApiName : this.objectApiName,
            displayLabel : this.displayLabel,
            actCat : this.actCat,
            actType : this.actType,
            recTypeName : this.recTypeName,
            actSubType : this.actSubType
        };
        console.log('actSubType==>'+this.actSubType+'='+this.actType);

        getPOPvalue({ popDetail: JSON.stringify(popDetailObj) })
            .then(data => {
                if (data) {
                    this.result = data.datamap;
                    this.displayHeader = data.displayHeader;
                    if (this.result != '') {
                        this.isValidPOPdata = true;
                    }
                }
            }).catch(error=>{
                if (error) {
                    this.haserror = true;
                    /* eslint-disable no-console*/
                    console.log('Error in loading POP Requirements. Error : ',this.error);
                }
            })
    }

    /*
    @wire(getPOPvalue, {
        recordId: "$recordId",
        objectApiName: "$objectApiName",
        displayLabel: "$displayLabel",
        actCat:"$actCat",
        actType:"$actType",
        recTypeName :"$recTypeName"
    })
    loaddata({ data, error }) {
        if (data) {
            this.result = data.datamap;
            this.displayHeader = data.displayHeader;
            console.log('POP-> ' + this.result);
            console.log('POPHeader-> ' + this.displayHeader);
            if (this.result != '') {
                this.isValidPOPdata = true;
            }

        }
        if (error) {
            this.haserror = true;
            /* eslint-disable no-console * /
             console.log(this.error);
        }
    }
    */
}