import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
/*
// MAIN OBJECT
import DEAL_OBJECT from '@salesforce/schema/PRM_Partner_Deal_Registration__c';

// FIELDS (UPDATE API NAMES IF NEEDED)

import CUSTOMER_NAME_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_CustomerName__c';
import WEBSITE_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_Website__c';
import COUNTRY_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_MailingCountry__c';
import STATE_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_MailingState__c';
import DECISION_MAKER_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_WhoIsDecisionMakerAtEndCustomer__c';

import OPPORTUNITY_NAME_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_OpportunityName__c';
import OPPORTUNITY_SUMMARY_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_OpportunitySummary__c';
import DECISION_DATE_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_EstimatedDecisionDate__c';
import VERTICAL_MARKET_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_VerticalMarket__c';
import TOTAL_BUDGET_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_EstimatedTotalBudgetForProject__c';
import LIST_OF_PARTNERS_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_ListAnyPartnersInvolvedInThisDea__c';
import INTEL_PRODUCTS_DETAILS_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_DetailsOnTheIntelProductsAssociated__c';
import HARDWARE_QTY_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_TotalQuantityOfIntelHardwareUnits__c';


// CHILD OBJECT
import DEAL_PRODUCT_OBJECT from '@salesforce/schema/PRM_Partner_Deal_Reg_Products__c';
import DEAL_PRODUCT_NAME_FIELD from '@salesforce/schema/PRM_Partner_Deal_Reg_Products__c.Name';
import DEAL_FIELD from '@salesforce/schema/PRM_Partner_Deal_Reg_Products__c.PRM_Partner_Deal_Registration__c';
import PRODUCT_FIELD from '@salesforce/schema/PRM_Partner_Deal_Reg_Products__c.PRM_Partner_Deal_Product__c';
import QUANTITY_FIELD from '@salesforce/schema/PRM_Partner_Deal_Reg_Products__c.PRM_Quantity__c';
*/
// APEX
//import searchProducts from '@salesforce/apex/PRM_PartnerDealRegHandler.searchDealProducts';

export default class DealWithProducts extends NavigationMixin(LightningElement) {
/*
    // CUSTOMER INFO
    @track customerName = '';
    @track website = '';
    @track country = '';
    @track state = '';
    @track decisionMaker = '';

    // DEAL INFO
    @track oppName = '';
    @track oppSummary = '';
    @track decisionDate = '';
    @track verticalMarket = '';
    @track verticalMarketOptions = [];
    @track totalBudget = '';
    @track listOfPartners = '';
    @track intelProductsOverview = '';
    @track qtyHardwareUnits = '';

    // PRODUCTS
    @track addProducts = false;
    @track products = [];

    debounceTimeout;

    // OBJECT INFO
    @wire(getObjectInfo, { objectApiName: DEAL_OBJECT })
    dealMetadata;

    // PICKLIST
    @wire(getPicklistValues, {
        recordTypeId: '$dealMetadata.data.defaultRecordTypeId',
        fieldApiName: VERTICAL_MARKET_FIELD
    })
    wiredVerticalMarket({ error, data }) {
        if (data) {
            this.verticalMarketOptions = data.values;
        } else if (error) {
            console.error(error);
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
    }

    handlePicklistChange(event) {
        this.verticalMarket = event.detail.value;
    }

    handleToggle(event) {
        this.addProducts = event.target.checked;

        if (this.addProducts && this.products.length === 0) {
            this.addProduct();
        }
    }

    addProduct() {
        this.products = [
            ...this.products,
            {
                id: Date.now(),
                searchTerm: '',
                searchResults: [],
                productId: '',
                quantity: 1
            }
        ];
    }

    removeProduct(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.products = this.products.filter(p => p.id !== index);
    }

    handleProductSearch(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const value = event.target.value;

        this.products = this.products.map(p => {
            if (p.id === index) p.searchTerm = value;
            return p;
        });

        clearTimeout(this.debounceTimeout);

        if (value.length >= 2) {
            this.debounceTimeout = setTimeout(() => {
                searchProducts({ searchKey: value })
                    .then(results => {
                        this.products = this.products.map(p => {
                            if (p.id === index) p.searchResults = results;
                            return p;
                        });
                    })
                    .catch(error => {
                        this.showToast('Error', error.body?.message, 'error');
                    });
            }, 300);
        }
    }

    selectProduct(event) {
        const index = parseInt(event.target.dataset.index, 10);

        this.products = this.products.map(p => {
            if (p.id === index) {
                p.productId = event.target.dataset.id;
                p.searchTerm = event.target.dataset.name;
                p.searchResults = [];
            }
            return p;
        });
    }

    handleProductChange(event) {
        const index = parseInt(event.target.dataset.index, 10);
        const field = event.target.dataset.id;
        const value = event.target.value;

        this.products = this.products.map(p => {
            if (p.id === index) {
                p[field] = field === 'quantity' ? parseInt(value, 10) || 0 : value;
            }
            return p;
        });
    }

    createDeal() {
        // if (!this.oppName || !this.customerName) {
        //     this.showToast('Error', 'Fill required fields', 'error');
        //     return;
        // }

        const dealFields = {
            [CUSTOMER_NAME_FIELD.fieldApiName]: this.customerName,
            [WEBSITE_FIELD.fieldApiName]: this.website,
            [COUNTRY_FIELD.fieldApiName]: this.country,
            [STATE_FIELD.fieldApiName]: this.state,
            [DECISION_MAKER_FIELD.fieldApiName]: this.decisionMaker,
            [OPPORTUNITY_NAME_FIELD.fieldApiName]: this.oppName,
            [OPPORTUNITY_SUMMARY_FIELD.fieldApiName]: this.oppSummary,
            [DECISION_DATE_FIELD.fieldApiName]: this.decisionDate,
            [VERTICAL_MARKET_FIELD.fieldApiName]: this.verticalMarket,
            [TOTAL_BUDGET_FIELD.fieldApiName]: this.totalBudget,
            [LIST_OF_PARTNERS_FIELD.fieldApiName]: this.listOfPartners,
            [INTEL_PRODUCTS_DETAILS_FIELD.fieldApiName]: this.intelProductsOverview,
            [HARDWARE_QTY_FIELD.fieldApiName]: this.qtyHardwareUnits
        };

        createRecord({
            apiName: DEAL_OBJECT.objectApiName,
            fields: dealFields
        })
            .then(deal => {
                if (this.addProducts && this.products.length > 0) {
                    this.createDealProducts(deal.id);
                } else {
                    this.navigateToRecord(deal.id);
                }
            })
            .catch(error => {
                this.showToast('Error', error.body?.message, 'error');
            });
    }

    createDealProducts(dealId) {
        const promises = this.products
            .filter(p => p.productId)
            .map(p => {
                const fields = {
                    [DEAL_PRODUCT_NAME_FIELD.fieldApiName]: p.searchTerm,
                    [DEAL_FIELD.fieldApiName]: dealId,
                    [PRODUCT_FIELD.fieldApiName]: p.productId,
                    [QUANTITY_FIELD.fieldApiName]: p.quantity
                };

                return createRecord({
                    apiName: DEAL_PRODUCT_OBJECT.objectApiName,
                    fields
                });
            });

        Promise.all(promises)
            .then(() => this.navigateToRecord(dealId))
            .catch(error => {
                this.showToast('Error', error.body?.message, 'error');
            });
    }

    navigateToRecord(recordId) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Partner Deal created successfully',
                variant: 'success'
            })
        );

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName: 'PRM_Partner_Deal_Registration__c',
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }*/
}