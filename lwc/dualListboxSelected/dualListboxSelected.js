import { LightningElement } from 'lwc';

export default class DualListboxSelected extends LightningElement {
    options = [];
    values = [];

    listOptions = [
        { value: '1', label: 'Option 1' },
        { value: '2', label: 'Option 2' },
        { value: '3', label: 'Option 3' },
        { value: '4', label: 'Option 4' },
        { value: '5', label: 'Option 5' },
        { value: '6', label: 'Option 6' },
        { value: '7', label: 'Option 7' },
        { value: '8', label: 'Option 8' },
    ];

    defaultOptions = ['7', '2', '3'];

    requiredOptions = ['2', '7'];



    connectedCallback() {
        const items = [];
        for (let i = 1; i <= 10; i++) {
            items.push({
                label: `Option ${i}`,
                value: `opt${i}`,
            });
        }
        this.options.push(...items);
        this.values.push(...['opt2', 'opt4', 'opt6']);
        console.log('this.options===' + this.options);
        console.log('this.values===' + this.values);
        console.log('this.options===' + this.defaultOptions);
    }
}