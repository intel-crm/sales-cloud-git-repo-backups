import { LightningElement, wire, track, api } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
export default class Pricing_ListViewTableCom extends LightningElement {


    @track isLoadingTable = true;
    @track url = window.location.origin;
    @track dataList = [];
    @track col = [];

    @track sortBy;
    @track defaultSortDirection = 'asc';
    @track sortDirection;

    @api objectAPIName;
    @api selectedListView;

    @wire(getListUi, {
        listViewId: '$selectedListView',
        pageSize: 5
    })
    getListUi({ error, data }) {
        if (data) {
            this.isLoadingTable = true;
            var dataTable = [];
            var cols = [];
            data.info.displayColumns.forEach(ele => {
                var col = {};
                if (ele.fieldApiName?.includes('.') || ele.fieldApiName == 'Name') {
                    col.label = ele.label;
                    col.fieldName = ele.fieldApiName.split('.')[0];
                    col.type = 'url';
                    col.sortable = "true";
                    col.typeAttributes = { 'label': { 'fieldName': col.fieldName + 'Name' }, 'target': '_blank' };
                } else {
                    col.label = ele.label;
                    col.fieldName = ele.fieldApiName;
                    col.type = 'text';
                    col.sortable = "true";
                }
                cols.push(col);
            });

            this.col = cols;

            data.records.records.forEach(element => {

                var any = {};

                for (let i = 0; i < this.col.length; i++) {

                    if (this.col[i].fieldName.endsWith('__r') && element.fields[this.col[i].fieldName].value != null) {
                        any[this.col[i].fieldName + 'Name'] = element.fields[this.col[i].fieldName].value.hasOwnProperty('fields') ? element.fields[this.col[i].fieldName].value.fields.Name.value : '';
                        any[this.col[i].fieldName] = element.fields[this.col[i].fieldName].value.hasOwnProperty('fields') ? this.url + '/' + element.fields[this.col[i].fieldName].value.fields.Id.value : '';

                    } else if (this.col[i].fieldName == 'Name') {
                        any[this.col[i].fieldName + 'Name'] = element.fields[this.col[i].fieldName].value;
                        any[this.col[i].fieldName] = this.url + '/' + element.fields['Id'].value;

                    } else if (this.col[i].type == 'url' && element.fields[this.col[i].fieldName].value != null) {
                        any[this.col[i].fieldName + 'Name'] = element.fields[this.col[i].fieldName].hasOwnProperty('displayValue') ? element.fields[this.col[i].fieldName].displayValue : '';
                        any[this.col[i].fieldName] = element.fields[this.col[i].fieldName].value.hasOwnProperty('fields') ? this.url + '/' + element.fields[this.col[i].fieldName].value.fields.Id.value : '';
                    }
                    else {
                        var str = JSON.stringify(element.fields[this.col[i].fieldName]?.value);

                        if (str?.includes('a href=')) {
                            any[this.col[i].fieldName] = this.url + '/' + str.slice(12, 27);
                            any[this.col[i].fieldName + 'Name'] = str.slice(47, -5);
                            this.col[i].type = 'url';
                            this.col[i].typeAttributes = { 'label': { 'fieldName': this.col[i].fieldName + 'Name' }, 'target': '_blank' };

                        } else if (str) {
                            any[this.col[i].fieldName] = element.fields[this.col[i].fieldName].value;
                        }
                    }
                }

                dataTable.push(any);

            });

            this.dataList = dataTable;
            this.isLoadingTable = false;

        } else if (error) {
            this.isLoadingTable = false;
            console.error('Error:', error);
        }
    }

    handleSortdata(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.dataList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.dataList = parseData;
    }
}