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

    @track str = '';

    @wire(getListUi, {
        listViewId: '$selectedListView',
        pageSize: 5
    })
    getListUi({ error, data }) {
        if (data) {
            this.isLoadingTable = true;
            let dataTable = [];
            let cols = [];
            data.info.displayColumns.forEach(ele => {
                let col = {};
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
            let urlColSetup = [];

            data.records.records.forEach(element => {

                let any = {};

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
                        this.str = JSON.stringify(element.fields[this.col[i].fieldName]?.value);
                        //
                        if(this.str.includes('mydeals'))
                        {
                            any[this.col[i].fieldName] = this.str.split('href=\'')[0].split('"')[2];
                            any[this.col[i].fieldName + 'Name'] = this.str.split('>')[1].split('<')[0];
                            urlColSetup.push(i);
                            this.col[i].typeAttributes = { 'label': { 'fieldName': this.col[i].fieldName + 'Name' }, 'target': '_blank' };        
                            console.log('any '+ JSON.stringify(any) );
                        }else     
                        //                  
                        if (this.str.includes('target=')) {

                            any[this.col[i].fieldName] = this.url + '/' + this.str.slice(12, 27);
                            any[this.col[i].fieldName + 'Name'] = this.str.slice(47, -5);
                            urlColSetup.push(i);
                            this.col[i].typeAttributes = { 'label': { 'fieldName': this.col[i].fieldName + 'Name' }, 'target': '_blank' };
                        } else {
                            any[this.col[i].fieldName] = element.fields[this.col[i].fieldName].value;
                        }
                    }
                }

                dataTable.push(any);
            });

            urlColSetup.forEach(ele => {
                this.col[ele].type = 'url';
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