import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
/*
// MAIN OBJECT
import DEAL_OBJECT from '@salesforce/schema/PRM_Partner_Deal_Registration__c';

// FIELDS
import CUSTOMER_NAME_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_CustomerName__c';
import WEBSITE_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_Website__c';
import COUNTRY_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_MailingCountry__c';
import STATE_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_MailingState__c';
import DECISION_MAKER_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_WhoIsDecisionMakerAtEndCustomer__c';
import STATUS_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_Status__c';
import PARTNER_ACCOUNT_FIELD from '@salesforce/schema/PRM_Partner_Deal_Registration__c.PRM_Partner_Account__c';

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

export default class PartnerDealRegWithProducts extends NavigationMixin(LightningElement) {
/*
    @track customerName = '';
    @track website = '';
    @track country = '';
    @track state = '';
    @track decisionMaker = '';

    @track oppName = '';
    @track oppSummary = '';
    @track decisionDate = '';
    @track verticalMarket = '';
    @track verticalMarketOptions = [];
    @track totalBudget = '';
    @track listOfPartners = '';
    @track intelProductsOverview = '';
    @track qtyHardwareUnits = '';

    @track addProducts = false;
    @track products = [];

    @track partnerAccountId;

    debounceTimeout;

    @wire(getObjectInfo, { objectApiName: DEAL_OBJECT })
    dealMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$dealMetadata.data.defaultRecordTypeId',
        fieldApiName: VERTICAL_MARKET_FIELD
    })
    wiredVerticalMarket({ error, data }) {
        if (data) {
            this.verticalMarketOptions = data.values;
        } else if (error) {
            console.error('Picklist error →', JSON.stringify(error));
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
        console.log(`Field changed: ${field} → ${this[field]}`);
    }

    handlePicklistChange(event) {
        this.verticalMarket = event.detail.value;
        console.log(`Vertical Market selected: ${this.verticalMarket}`);
    }

    handleToggle(event) {
        this.addProducts = event.target.checked;
        console.log(`Add Products toggled: ${this.addProducts}`);
        if (this.addProducts && this.products.length === 0) {
            this.addProduct();
        }
    }

    addProduct() {
        const newProduct = {
            id: Date.now(),
            searchTerm: '',
            searchResults: [],
            productId: '',
            quantity: 1
        };
        this.products = [...this.products, newProduct];
        console.log('Added new product entry:', newProduct);
    }

    removeProduct(event) {
        const index = parseInt(event.target.dataset.index, 10);
        this.products = this.products.filter(p => p.id !== index);
        console.log(`Removed product at index: ${index}`);
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
                console.log(`Searching products for: "${value}" at index ${index}`);
                searchProducts({ searchKey: value })
                    .then(results => {
                        this.products = this.products.map(p => {
                            if (p.id === index) p.searchResults = results;
                            return p;
                        });
                        console.log(`Search results for index ${index}:`, results);
                    })
                    .catch(error => {
                        console.error('Product search error →', JSON.stringify(error));
                        this.showToast('Error', 'Product search failed: ' + (error.body?.message || JSON.stringify(error)), 'error');
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
        console.log(`Product selected at index ${index}:`, event.target.dataset);
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
        console.log(`Product field changed at index ${index}: ${field} → ${value}`);
    }

    createDeal() {
        console.log('Creating Deal with fields:', {
            customerName: this.customerName,
            website: this.website,
            country: this.country,
            state: this.state,
            decisionMaker: this.decisionMaker,
            oppName: this.oppName,
            oppSummary: this.oppSummary,
            decisionDate: this.decisionDate,
            verticalMarket: this.verticalMarket,
            totalBudget: this.totalBudget,
            listOfPartners: this.listOfPartners,
            intelProductsOverview: this.intelProductsOverview,
            qtyHardwareUnits: this.qtyHardwareUnits,
            addProducts: this.addProducts,
            products: this.products
        });

        const dealFields = {
            [STATUS_FIELD.fieldApiName]: 'New',
            //[PARTNER_ACCOUNT_FIELD.fieldApiName]: this.partnerAccountId,
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

        createRecord({ apiName: DEAL_OBJECT.objectApiName, fields: dealFields })
            .then(deal => {
                console.log('Deal created successfully:', deal);
                if (this.addProducts && this.products.length > 0) {
                    console.log('Proceeding to create products for Deal ID:', deal.id);
                    this.createDealProducts(deal.id);
                } else {
                    this.navigateToRecord(deal.id);
                }
            })
            .catch(error => {
                console.error('Deal creation failed →', error);
                let message = error.body?.message || JSON.stringify(error);
                this.showToast('Error', 'Deal creation failed: ' + message, 'error');
            });
    }

    createDealProducts(dealId) {
        console.log('Creating Deal Products for Deal ID:', dealId);
        console.log('Current products before filtering:', this.products);

        const productsToCreate = this.products.filter(p => p.productId);
        console.log('Filtered products with productId:', productsToCreate);

        const promises = productsToCreate.map((p, idx) => {
            const fields = {
                [DEAL_PRODUCT_NAME_FIELD.fieldApiName]: p.searchTerm,
                [DEAL_FIELD.fieldApiName]: dealId,
                [PRODUCT_FIELD.fieldApiName]: p.productId,
                [QUANTITY_FIELD.fieldApiName]: p.quantity
            };
            console.log(`Product ${idx} payload →`, fields);

            return createRecord({ apiName: DEAL_PRODUCT_OBJECT.objectApiName, fields })
                .then(result => {
                    console.log(`Product ${idx} created successfully:`, result);
                    return result;
                })
                .catch(err => {
                    console.error(`Product ${idx} creation error →`, err);
                    throw err; // re-throw to catch in Promise.all
                });
        });

        Promise.all(promises)
            .then(() => {
                console.log('All products created successfully for Deal ID:', dealId);
                this.navigateToRecord(dealId);
            })
            .catch(error => {
                console.error('One or more product creations failed →', error);
                let message = error.body?.message || JSON.stringify(error);
                this.showToast('Error', 'Product creation failed: ' + message, 'error');
            });
    }

    navigateToRecord(recordId) {
        console.log('Navigating to Deal record:', recordId);
        this.showToast('Success', 'Partner Deal created successfully', 'success');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: { recordId, objectApiName: 'PRM_Partner_Deal_Registration__c', actionName: 'view' }
        });
    }

    showToast(title, message, variant) {
        console.log(`Toast → ${title}: ${message}`);
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }*/
}