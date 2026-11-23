/* eslint-disable no-alert */
/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';

export default class MultiselectPicklist extends LightningElement {

    @track selectedRecords = [];
    @track picklist2 = [];
    @track picklist = [
        { label: 'English', value: 'English' },
        { label: 'German', value: 'German' },
        { label: 'Spanish', value: 'Spanish' },
        { label: 'French', value: 'French' },
        { label: 'Italian', value: 'Italian' },
        { label: 'Japanese', value: 'Japanese' },
    ];
    get options() {
        return this.picklist;
    }
    set options(value) {
        this.picklist = value;
    }
    handleComboboxChange(event) {
        let optionSelectRecId = [];

        let newsObject = { 'label': event.target.value, 'value': event.target.value };
        this.selectedRecords.push(newsObject);

        for (let i = 0; i < this.picklist.length; i++) {
            if (event.target.value !== this.picklist[i].value)
                optionSelectRecId.push(this.picklist[i]);
        }
        this.picklist = [...optionSelectRecId];
        let optionsSelRecords = this.picklist;
        console.log('optionsSelRecords' + JSON.stringify(optionsSelRecords));

        console.log('after selecting records' + JSON.stringify(this.selectedRecords));


    }

    removeRecord(event) {
        var mapped, result;
        let selectRecId = [];

        for (let i = 0; i < this.selectedRecords.length; i++) {
            if (event.detail.name !== this.selectedRecords[i].value) {
                selectRecId.push(this.selectedRecords[i]);
            }

            if (event.detail.name === this.selectedRecords[i].value) {
                this.picklist.push(this.selectedRecords[i]);
                this.picklist = [...this.picklist];
                //console.log('sort' + JSON.stringify(this.picklist.sort()));
                let pickListToBeSorted = this.picklist;
                mapped = pickListToBeSorted.map(function (el, j) {
                    return { index: j, value: el.label.toLowerCase() };
                })
                mapped.sort(function (a, b) {
                    if (a.value > b.value) {
                        return 1;
                    }
                    if (a.value < b.value) {
                        return -1;
                    }
                    return 0;
                });

                // container for the resulting order
                result = mapped.map(function (el) {
                    return pickListToBeSorted[el.index];
                });
                //  console.log('result' + JSON.stringify(result));
                this.picklist = result;
            }
        }
        this.selectedRecords = [...selectRecId];
        let selRecords = this.selectedRecords;
        console.log('after removing records' + JSON.stringify(selRecords));

        console.log(' this.picklist' + JSON.stringify(this.picklist));

    }
}