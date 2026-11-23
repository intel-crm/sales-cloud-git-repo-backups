import { LightningElement, track } from 'lwc';
import getUnusedCustomLables from '@salesforce/apex/Tooling_CustomLabelCntrl.getCustomLabels';
import getApexClasses from '@salesforce/apex/Tooling_CustomLabelCntrl.getApexBody';
import getLWCBody from '@salesforce/apex/Tooling_CustomLabelCntrl.getLWCResource';

//Unsed Attributes table columns
const columns = [{ "fieldName": "labelURL", "label": "Label Name", "typeAttributes": { "label": { "fieldName": "labelName" }, "target": "_blank" }, "type": "url", "sortable": "true", "cellAttributes": { "wrapText": "true" } }];

//References table columns
const REFERENCE_COLUMNS = [{ 'label': 'Component Name', 'fieldName': 'Name', 'type': 'text' }, { 'label': 'Component Type', 'fieldName': 'Type', 'type': 'text' }];
export default class UnsedCustomLabels extends LightningElement {

    // Track variables
    @track pagesize = 10;
    @track data;
    @track hasData = false;
    @track Loading = true;
    @track sortedDirection = 'asc';
    @track sortedBy;
    columns = columns;
    @track coundOfLables = 0;

    @track noBatches = 0;

    prevBtnLbl = 'Prev';
    nextBtnLbl = 'Next';

    @track tableData = [];
    @track loadMore = true;
    @track loadPrev = false;
    @track currentpage = 1;
    @track noOfPages = 1;
    @track data = [];
    @track apexClassesBody;
    // 
    @track labelDeveloperName;
    @track nameLabelMap = new Map();
    @track referenceData = [];
    @track referencecolumns = REFERENCE_COLUMNS;

    connectedCallback() {
        // Fetch Apex classes and LWC resources
        getApexClasses().then(result => {
            console.log('result : ', result);
            this.apexClassesBody = result;
            getLWCBody().then(lwcresult => {
                this.apexClassesBody = this.apexClassesBody.concat(lwcresult);
                console.log('apexClassesBody : ', this.apexClassesBody);

                // Extract custom labels from Apex class and LWC resources

                // Regular expression to match 'Label.' followed by any characters until the first whitespace or end of line
                const labelRegex = /@salesforce\/label\/c\.(\w+)|\blabel(?:\.c)?\.(\w+)|System\.Label\.(\w+)/g; ///\b(label\.c|c)\.(\w+)/g;

                // Loop through each apex class in the result
                this.apexClassesBody.forEach(apexClass => {
                    // Extracting labels from the apexbody of the current class
                    //const apexbody = apexClass.toLowerCase();
                    const labels = apexClass.Source.match(labelRegex);
                    const resourceName = apexClass.MetadataComponentName + '-' + apexClass.MetadataComponentType;

                    if (labels && labels.length > 0) {
                        // If labels are found, add them to the labelsArray after removing any characters at the end (including special characters and newlines)
                        labels.forEach(label => {
                            const cleanedLabel = label.trim().replace(/[^a-zA-Z0-9_]+$/, ''); // Removes non-alphanumeric characters from the end of the label
                            console.log('cleanedLabel : ', cleanedLabel);
                            //labelsArray.push(cleanedLabel); // labels
                            if (this.nameLabelMap.has(cleanedLabel)) {

                                let resourceNames = this.nameLabelMap.get(cleanedLabel);
                                if (!resourceNames.includes(resourceName)) {
                                    resourceNames.push(resourceName);
                                }
                                this.nameLabelMap.set(cleanedLabel, resourceNames);
                            } else {
                                let resourceNames = [];
                                resourceNames.push(resourceName);
                                this.nameLabelMap.set(cleanedLabel, resourceNames);
                            }

                        });
                    }
                });

                console.log('nameLabelMap  : ', this.nameLabelMap.keys());
                // Fetch unused custom labels and filter them
                if (result) {
                    getUnusedCustomLables().then(result => {
                        if (result) {
                            let parseddata = JSON.parse(JSON.stringify(result));
                            // this.Loading = true;
                            let newData = [];
                            //let containsInApex = false;

                            parseddata.forEach(item => {
                                const keysToCheck = [
                                    'label.' + item.labelName.toLowerCase(),
                                    'label.c.' + item.labelName.toLowerCase(),
                                    '@salesforce/label/c.' + item.labelName.toLowerCase()
                                ];
                                // Check if the label is unused

                                if (keysToCheck.every(key => !this.nameLabelMap.has(key))) {
                                    item.labelURL = '/' + item.Id;
                                    newData.push(item);
                                }

                            });

                            // Update data and pagination properties

                            this.data = newData;
                            this.noOfPages = Math.ceil(this.data.length / this.pagesize);
                            if (this.data.length > 0) {
                                this.coundOfLables = this.data.length;
                                this.hasData = true;
                                this.Loading = false;
                            } else {
                                this.hasData = false;
                                this.Loading = false;
                            }
                            console.log('Result ==>', result);
                            this.getCurrentPageRecords();
                        }
                    })
                        .catch(error => {
                            this.Loading = false;
                            console.log('Error in getUnusedCustomLables ', error);
                        })
                } else {
                    // Handle error if getApexClasses fails

                }
            }).catch(error => {
                console.log('error in getLWCBody: ', error);
            })

            // })
        })
            .catch(error => {
                console.log('error in getApexClasses: ', error);
            })

    }

    updateColumnSorting(event) {
        var fieldName = event.detail.fieldName
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortData('labelName', sortDirection);
        this.sortedDirection = sortDirection;// === 'asc' ? 'desc' : 'asc';
    }


    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        this.data = [];
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        this.data = [...parseData];

    }
    handleNext() {
        if (this.currentpage < this.noOfPages) {
            this.currentpage += 1;
            this.getCurrentPageRecords();
        }
    }

    handlePrevious() {
        if (this.currentpage >= this.noOfPages || this.currentpage > 1) {
            this.currentpage -= 1;
            this.getCurrentPageRecords();
        }

    }

    getCurrentPageRecords() {
        this.tableData = [];
        let start = parseInt((this.currentpage - 1) * this.pagesize);
        let end = parseInt(start) + parseInt(this.pagesize);
        this.tableData = this.data.slice(start, end);
        this.loadMore = (this.currentpage > 1 && this.noOfPages <= this.currentpage) ? true : false;
        this.loadPrev = (this.currentpage === 1) ? true : false;
        this.showingOfTotal = (this.currentpage === this.noOfPages) ? this.data.length : this.currentpage * this.pagesize;
    }

    get getTotal() {
        return this.referenceData.length;
    }


    handleInputChange(evt) {
        this.labelDeveloperName = evt.target.value;
    }

    handleSearch() {
        this.referenceData = [];

        const keysToCheck = [
            'label.' + this.labelDeveloperName.toLowerCase(),
            'label.c.' + this.labelDeveloperName.toLowerCase(),
            '@salesforce/label/c.' + this.labelDeveloperName.toLowerCase()
        ];

        keysToCheck.forEach(key => {
            if (this.nameLabelMap.has(key)) {
                const val = [];
                val.push(this.nameLabelMap.get(key));
                val.map(item => {
                    item = item.toString();
                    const references = item.split('-');
                    const data = {
                        Name: references[0],
                        Type: references[1]
                    };
                    this.referenceData.push(data);
                })

            }
        });
    }

}