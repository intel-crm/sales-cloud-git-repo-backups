import {
    LightningElement,
    track
} from "lwc";
import getusertrail from "@salesforce/apex/trailhead.getusertrail";
import getusertraildate from "@salesforce/apex/trailhead.getusertraildate";
const columns = [{
    label: "Name",
    fieldName: "Username",
    type: "text"
},
{
    label: "OldPoints",
    fieldName: "OldPoints",
    type: "text"
},
{
    label: "OldRank",
    fieldName: "OldRank",
    type: "text"
},
{
    label: "Points",
    fieldName: "Points",
    type: "text"
},
{
    label: "Rank",
    fieldName: "Rank",
    type: "text"
},
{
    label: "badges",
    fieldName: "badges",
    type: "text"
}
];
export default class TrailHeadReport extends LightningElement {
    @track hrefdata;
    @track userTrailList;
    @track reportColumns = columns;
    @track duration;
    data = [];

    connectedCallback() {
        //this.getusertrail();
    }

    getusertrail() {
        if (this.duration !== null && this.duration > 0) {
            console.log('inside if');
            getusertraildate({ duration: this.duration })
                .then(result => {
                    this.userTrailList = result;
                    this.data = result;
                })
                .catch(error => {
                    this.error = error;
                    console.log(this.error);
                });
        }
        else {
            console.log('inside else');
            getusertrail()
                .then(result => {
                    this.userTrailList = result;
                    this.data = result;
                })
                .catch(error => {
                    this.error = error;
                    console.log(this.error);
                });
        }

    }

    handleDuration(event) {
        this.duration = event.target.value;
        //this.getusertrail();
    }

    exportToCSV() {
        let columnHeader = ["Name", "Rank", "Points", "OldRank", "OldPoints", "badges"];  // This array holds the Column headers to be displayd
        let jsonKeys = ["Username", "Rank", "Points", "OldRank", "OldPoints", "badges"]; // This array holds the keys in the json data  
        var jsonRecordsData = this.userTrailList;
        let csvIterativeData;
        let csvSeperator
        let newLineCharacter;
        csvSeperator = ",";
        newLineCharacter = "\n";
        csvIterativeData = "";
        csvIterativeData += columnHeader.join(csvSeperator);
        csvIterativeData += newLineCharacter;
        //var obj = Array.from(jsonRecordsData.values());
        //console.log(obj);
        for (let i = 0; i < jsonRecordsData.length; i++) {
            let counter = 0;
            for (let iteratorObj in jsonKeys) {
                let dataKey = jsonKeys[iteratorObj];
                if (counter > 0) { csvIterativeData += csvSeperator; }
                if (jsonRecordsData[i][dataKey] !== null &&
                    jsonRecordsData[i][dataKey] !== undefined
                ) {
                    csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';
                } else {
                    csvIterativeData += '""';
                }
                counter++;
            }
            csvIterativeData += newLineCharacter;
        }
        console.log("csvIterativeData", csvIterativeData);
        this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);
    }
}