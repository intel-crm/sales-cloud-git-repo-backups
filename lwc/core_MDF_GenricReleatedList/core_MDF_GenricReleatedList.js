import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getRelatedRecords from '@salesforce/apex/Core_MDF_GenericRelatedListController.getRelatedRecords';
import getFieldLabels from '@salesforce/apex/Core_MDF_GenericRelatedListController.getFieldLabels';

export default class GenericRelatedList extends NavigationMixin(LightningElement) {

    @api recordId;
    @api childObjectApi;
    @api relationshipField;
    @api title;

    records = [];
    columns = [];

    _fields;
    fieldLabelMap = {};

    // -------------------------------
    // FIELD LABEL FETCH
    // -------------------------------
    @wire(getFieldLabels, {
        objectApiName: '$childObjectApi',
        fieldList: '$_fields'
    })
    wiredLabels({ data }) {
        if (data) {
            this.fieldLabelMap = data;
            this.buildColumns();
        }
    }

    // -------------------------------
    // BUILD COLUMNS USING LABEL MAP
    // -------------------------------
    buildColumns() {
        if (!this._fields) return;

        this.columns = this._fields.split(',').map(field => {

            const trimmed = field.trim();
            const label = this.fieldLabelMap[trimmed] || trimmed;

            if (trimmed.toLowerCase() === 'name' || trimmed.toLowerCase() === 'title') {
                return {
                    label: label,
                    fieldName: 'Id',
                    type: 'button',
                    typeAttributes: {
                        label: { fieldName: trimmed },
                        name: 'view',
                        variant: 'base'
                    }
                };
            }

            return {
                label: label,
                fieldName: trimmed,
                type: 'text'
            };
        });
    }

    // -------------------------------
    // PUBLIC PROPERTY (FIELDS)
    // -------------------------------
    @api
    set fields(value) {
        this._fields = value;
        this.buildColumns();
    }

    get fields() {
        return this._fields;
    }

    // -------------------------------
    // GET RECORD ID FROM URL
    // -------------------------------
    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (!this.recordId && pageRef?.state?.recordId) {
            this.recordId = pageRef.state.recordId;
        }
    }

    connectedCallback() {
        const path = window.location.pathname.split('/');
        const index = path.indexOf('partnerfundclaim');

        if (index > -1 && path[index + 1]) {
            this.recordId = path[index + 1];
        }
    }

    // -------------------------------
    // FETCH RELATED RECORDS
    // -------------------------------
    @wire(getRelatedRecords, {
        childObjectApi: '$childObjectApi',
        relationshipField: '$relationshipField',
        parentId: '$recordId',
        fieldList: '$fields'
    })
    wiredData({ error, data }) {
        if (data) {
            this.records = data;
        } else if (error) {
            console.error('Apex Error:', error);
        }
    }

    // -------------------------------
    // NAVIGATION
    // -------------------------------
    // handleRowAction(event) {

    //     const row = event.detail.row;
    //     const recordId = row.Id;
    //     const recordTitle = row.Title || '';

    //     if (window.location.pathname.includes('/partnerfundclaim/')) {
    //         return;
    //     }

    //     const baseUrl = window.location.origin;
    //     const targetUrl = `${baseUrl}/Partnercenter/s/partnerfundclaim/${recordId}/${encodeURIComponent(recordTitle)}`;

    //     window.location.href = targetUrl;
    // }
    handleRowAction(event) {

   const recordId = event.detail.row.Id;

    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordPage',
        attributes: {
            recordId: recordId,
            actionName: 'view'
        }
    }).then(url => {
        window.open(url, '_blank');
    });
}

}