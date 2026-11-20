import { LightningElement, track } from 'lwc';
import getUnusedCustomLables from '@salesforce/apex/Tooling_CustomLabelCntrl.getCustomLabels';
import getApexClasses from '@salesforce/apex/Tooling_CustomLabelCntrl.getApexBody';
import getLWCBody from '@salesforce/apex/Tooling_CustomLabelCntrl.getLWCResource';
import getApexTriggerBody from '@salesforce/apex/Tooling_CustomLabelCntrl.getApexTriggerBody';
import getApexPageBody from '@salesforce/apex/Tooling_CustomLabelCntrl.getApexPageBody';
import getAuraCmpBody from '@salesforce/apex/Tooling_CustomLabelCntrl.getAuraCmpBody';
import getApexClassNames from '@salesforce/apex/Tooling_CustomLabelCntrl.getApexClassNames';
import getLWCNames from '@salesforce/apex/Tooling_CustomLabelCntrl.getLWCNames';
import tableSize from '@salesforce/label/c.Tooling_Table_Size';

//Unsed Attributes table columns
const columns = [{ "fieldName": "labelURL", "label": "Label Name", "typeAttributes": { "label": { "fieldName": "labelName" }, "target": "_blank" }, "type": "url", "sortable": "true", "cellAttributes": { "wrapText": "true" } }];

//References table columns
const REFERENCE_COLUMNS = [{ 'label': 'Component Name', 'fieldName': 'Name', 'type': 'text' }, { 'label': 'Component Type', 'fieldName': 'Type', 'type': 'text' }];

export default class Tooling_UnusedCustomLabels extends LightningElement {

    // Track variables
    @track pagesize = tableSize;
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
    @track apexclassNamesLst;



    connectedCallback() {
        // Fetch Apex classes and LWC resources
        getApexClassNames().then(classnames => {
            this.apexclassNamesLst = classnames;
            const batchSize = 1000;
            const batches = Math.ceil(this.apexclassNamesLst.length / batchSize);

            for (let counter = 1; counter <= batches; counter++) {
                const startIndex = (counter - 1) * batchSize;
                const endIndex = Math.min(counter * batchSize, this.apexclassNamesLst.length-1);
                const batchClassNames = this.apexclassNamesLst.slice(startIndex, endIndex);

                getApexClasses({ classNames: batchClassNames[0] })
                    .then(result => {
                        console.log('result: ', result);
                        // Handle the result for each batch (this.apexClassesBody = result;)
                        if(this.apexClassesBody === undefined || this.apexClassesBody === null){
                            this.apexClassesBody = [...result];
                        }else{
                            this.apexClassesBody =  [...this.apexClassesBody, ...result];
                        }
                        console.log('Counter -->',counter ,' Size ==>',this.apexClassesBody.length);
                        // this.apexClassesBody = this.apexClassesBody.concat(result);
                        if (counter == batches) {

                            getApexTriggerBody().then(triggerResult => {
                                console.log('result : ', triggerResult);
                                this.apexClassesBody = [...this.apexClassesBody, ...triggerResult];
                                console.log('getApexTriggerBody Size ==>',this.apexClassesBody.length);
                                getApexPageBody().then(apexPageBody => {
                                    console.log('result : ', apexPageBody);
                                    this.apexClassesBody = [...this.apexClassesBody,...apexPageBody];
                                    console.log('getApexPageBody Size ==>',this.apexClassesBody.length);
                                    getAuraCmpBody().then(auraCmpBody => {
                                        console.log('result : ', auraCmpBody);
                                        this.apexClassesBody = [...this.apexClassesBody,...auraCmpBody];
                                        console.log('getAuraCmpBody Size ==>',this.apexClassesBody.length);
                                        getLWCNames().then(lwcnamesresult => {
                                            const lwcnamebatchsize = 200;
                                            const lwcnamebatches = Math.ceil(lwcnamesresult.length / lwcnamebatchsize);

                                            for (let jcounter = 1; jcounter <= lwcnamebatches; jcounter++) {
                                                const jstartIndex = (jcounter - 1) * lwcnamebatchsize;
                                                const jendIndex = Math.min(jcounter * lwcnamebatchsize, lwcnamesresult.length);
                                                const lwcnames = lwcnamesresult.slice(jstartIndex, jendIndex);
                                                getLWCBody({lwcNames:lwcnames}).then(lwcresult => {
                                                    this.apexClassesBody =[...this.apexClassesBody,...lwcresult];

                                                    console.log('getLWCBody Size ==>',this.apexClassesBody.length);
                                                    if (jcounter == lwcnamebatches) {
                                                        // Extract custom labels from Apex class and LWC resources

                                                        // Regular expression to match 'Label.' followed by any characters until the first whitespace or end of line
                                                        const labelRegex = /@salesforce\/label\/c\.(\w+)|\blabel(?:\.c)?\.(\w+)|System\.Label\.(\w+)/g;

                                                        // Loop through each apex class in the result
                                                        const apexclassdata = JSON.parse(JSON.stringify(this.apexClassesBody));
                                                        console.log('apexclassdata : ', apexclassdata);
                                                        apexclassdata.forEach(apexClass => {
                                                            // Extracting labels from the apexbody of the current class
                                                            //const apexbody = apexClass.toLowerCase();
                                                            const labels = apexClass.Source.match(labelRegex);
                                                            const resourceName = apexClass.MetadataComponentName + '-' + apexClass.MetadataComponentType;

                                                            if (labels && labels.length > 0) {
                                                                // If labels are found, add them to the labelsArray after removing any characters at the end (including special characters and newlines)
                                                                labels.forEach(label => {
                                                                    const cleanedLabel = label.trim().replace(/[^a-zA-Z0-9_]+$/, ''); // Removes non-alphanumeric characters from the end of the label
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
                                                    }

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
                                                    this.Loading = false;
                                                    console.log('error in getLWCBody: ', error);
                                                })
                                            }
                                        })
                                            .catch(error => {
                                                this.Loading = false;
                                                console.log('error in getLWCNames: ', error);
                                            })


                                    })
                                        .catch(error => {
                                            this.Loading = false;
                                            console.log('error in getAuraCmpBody: ', error);
                                        })
                                })
                                    .catch(error => {
                                        this.Loading = false;
                                        console.log('error in getApexPageBody: ', error);
                                    })
                            })
                                .catch(error => {
                                    this.Loading = false;
                                    console.log('error in getApexTriggerBody: ', error);
                                })
                        }
                    })
                    .catch(error => {
                        this.Loading = false;
                        console.log('error in getApexClasses: ', error);
                    });
            }
        })
            .catch(error => {
                console.log('connectedCallback.getApexClassNames.Error ==>', error);
            })
        //add this code inside promise


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