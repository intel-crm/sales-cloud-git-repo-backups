import { LightningElement, wire, api } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import RECORD_JSON from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.PCC_Product_JSON__c';
import Id from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DEAL_PRODUCT_OBJECT from "@salesforce/schema/Core_Design_Registration_Product__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import dealProductInfo from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.PCC_Design_Deal_Registration_Product__c';
import dealProduct from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.PCC_Deal_Product__c';
import NEW_QUANTITY from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.PCC_Quantity__c';
import START_DATE from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.PCC_Start_Date__c';
import END_DATE from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.PCC_End_Date__c';
import PRODUCT from '@salesforce/schema/PCC_Deal_Change_Request_Line_Item__c.PCC_Product__c';
// import getProductsIds from '@salesforce/apex/PCC_ChangeRequest.getProductsIds';

export default class PCC_UpdateProduct extends LightningElement {
    @api recordId;
    drName;
    dealProductName;
    competitorProductName;
    drpRecord = {};
    designRegId;

    drName;
    dealProductName;
    competitorProductName;
    newProductScreenCols = [];

    showRecord = false;
    recordTypeId;
    @wire(getObjectInfo, { objectApiName: DEAL_PRODUCT_OBJECT })
    Function({ error, data }) {
        if (data) {
            let objArray = data.recordTypeInfos;
            for (let i in objArray) {
                if (objArray[i].name === "Deal Registration Product - Partner") {
                    this.recordTypeId = objArray[i].recordTypeId;
                    console.log('recordTypeId -->', this.recordTypeId);
                }

            }
        } else if (error) {
            console.log(JSON.stringify(error))
            // perform your logic related to error 
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [RECORD_JSON] }) recordDetails({ data, error }) {
        if (data) {
            console.log('Data', data);
            this.drpRecord = JSON.parse(data?.fields?.PCC_Product_JSON__c?.value);
            this.designRegId = this.drpRecord.Core_Design_Registration_Id__c;
        }

        if (error) {
            console.log('error', error);

        }
    }

    handleClick() {
        this.showRecord = true;
    }

    connectedCallback() {
        console.log('Record Id -->', this.recordId);

    }

    closeCreateScreen() {
        this.showRecord = false;
    }

    handleOnClose() {
        this.showRecord = false;
    }

    // mapOfIds = [];
    // async getProductIds(ids) {
    //     try {
    //         const result = await getProductsIds({ ids: ids });
    //         this.mapOfIds = result;
    //         console.log('Product IDs successfully fetched:', this.mapOfIds);
    //     } catch (error) {
    //         console.error('Error fetching product IDs:', error);
    //         throw error; // Rethrow the error for the calling function to handle
    //     }
    // }

    async handleIncomingRecord(evt) {
        console.log('evet -->', JSON.stringify(evt.detail.data));
        let fields = {};
        fields[RECORD_JSON.fieldApiName] = JSON.stringify(evt.detail.data);
        fields[Id.fieldApiName] = this.recordId;

        this.drName = evt.detail.drName;
        this.dealProductName = evt.detail.productName;
        this.competitorProductName = evt.detail.competitorProdName;
        this.newProductScreenCols = evt.detail.columns;
        fields[dealProductInfo.fieldApiName] = this.getFormattedTable(evt.detail.data);
        console.log('here' + evt.detail.data.PCC_Product_Additional_Attribute__c);
        fields[dealProduct.fieldApiName] = evt.detail.data?.PCC_Product_Additional_Attribute__c;
        fields[NEW_QUANTITY.fieldApiName] = evt.detail.data?.Core_Full_Year_Qty__c;
        fields[START_DATE.fieldApiName] = evt.detail.data?.PCC_Quote_Line_Pricing_Start_Date__c;
        fields[END_DATE.fieldApiName] = evt.detail.data?.PCC_Quote_Line_Pricing_End_Date__c;
        // await getProductsIds({ ids: evt.detail.data?.PCC_Product_Additional_Attribute__c });

        fields[PRODUCT.fieldApiName] = evt.detail.data?.Core_Product_Id__c;//this.mapOfIds[evt.detail.data?.PCC_Product_Additional_Attribute__c];
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(result => {
                console.log('Result -->', result);
                this.dispatchEvent(new ShowToastEvent({ title: 'Record Updated', message: 'Record Updated Successfully!', variant: 'success' }));
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: 'Error Encountered!', variant: 'error' }));

            })


    }


    getFormattedTable(item) {
        console.log('Item -->', item);

        // Extract headers and field names from the columns configuration
        const headers = this.newProductScreenCols
            .filter(column => column.label !== null && column.label !== undefined && column.label !== 'Actions')
            .map(column => column.label);
        console.log('Header -->', headers);


        const fieldNames = this.newProductScreenCols
            .filter(column => column.label !== null && column.label !== undefined && column.label !== 'Actions')
            .map(column => column.fieldName);
        console.log('fieldNames -->', fieldNames);


        // Create the table header row with labels
        const headerRow = headers.map(header => `
			<th style="border: 1px solid #ddd; padding: 8px; background-color: #f2f2f2;">
				${header}
			</th>
		`).join('');

        // Create the table data row with values from the item object using field names
        const dataRow = fieldNames.map(fieldName => {
            // Use fieldName to access the corresponding value in the item object
            //PCC_Product_Additional_Attribute__c, PCC_Competitor_Product__c, Core_Design_Registration_Id__c
            let value;
            if ((fieldName == 'PCC_Product_Additional_Attribute__c' || fieldName == 'PCC_Competitor_Product__c' || fieldName == 'Core_Design_Registration_Id__c') && (item[fieldName] !== null && item[fieldName] !== undefined)) {
                console.log('FieldName -->', fieldName);

                if (fieldName == 'PCC_Product_Additional_Attribute__c') {
                    // this.getProductDetails(item.PCC_Product_Additional_Attribute__c, [PRODUCT_NAME]);
                    value = this.dealProductName;//;item[fieldName].fields['Name'].value;
                }


                if (fieldName == 'PCC_Competitor_Product__c') {
                    // this.getProductDetails(item.PCC_Competitor_Product__c,[COMPETITOR_PRODUCT]);
                    value = this.competitorProductName;//item[referenceFieldName].fields['Name'].value;
                }

                if (fieldName == 'Core_Design_Registration_Id__c') {
                    // this.getProductDetails(item.PCC_Competitor_Product__c,[DR_NAME]);
                    value = this.drName;//item[referenceFieldName].fields['Name'].value;
                }
                // ---------
                // let referenceFieldName =  fieldName.replace(/__c$/,'s__r');
                // if (item[referenceFieldName] && item[referenceFieldName].fields && item[referenceFieldName].fields['Name']) {
                // 	value =  item[referenceFieldName].fields['Name'].value;
                // }else{
                // 	value ='N/A';
                // }

                // let key = fieldName.replace(/__c$/,'__r.fields.Name.value');
                // value = item[key];
                console.log('value -->', value);
            } else if (item[fieldName] !== undefined && item[fieldName] !== null) {
                console.log('FieldName -->', fieldName);
                value = item[fieldName];
                console.log('value -->', value);
            } else {
                console.log('FieldName -->', fieldName);
                value = 'N/A';
                console.log('value -->', value);
            }
            return `
				<td style="border: 1px solid #ddd; padding: 8px;">
					${value}
				</td>
			`;
        }).join('');

        // Return the complete table HTML
        return `
			<table style="width:100%; border-collapse: collapse;">
				<tr>
					${headerRow}
				</tr>
				<tr>
					${dataRow}
				</tr>
			</table>
		`;
    }


}