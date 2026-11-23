import { LightningElement,track} from 'lwc';

export default class Samplemaplwc extends LightningElement {
    @track hasRequiredData = false;

    // Example map with some data
    dataMap = new Map([
        ['key1', 'value1'],
        ['key2', 'value2'],
        ['key3', 'value3']
    ]);

    checkValues() {
        const requiredData = 'value2'; // The data you're checking for
        this.hasRequiredData = this.dataMap.has(this.getKeyFromValue(requiredData));
        console.log('this.hasRequiredData'+this.hasRequiredData);
    }

    getKeyFromValue(value) {
        for (let [key, val] of this.dataMap) {
            if (val === value) {
                return key;
            }
        }
        return null; // Return null if the value is not found
    }
}