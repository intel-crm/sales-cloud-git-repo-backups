import { LightningElement,wire,track } from 'lwc';
import getUsers from '@salesforce/apex/ObjectMetrics.getUsers'
export default class PermissionSetAndProfileMetrics extends LightningElement {
@track preSelectedRows=[];
 @track chartConfiguration;
@track isChildmethodcalled=false;
@track isLoading=false;
@track isDataLoaded=false;
flag=true;
@track permissionSetMetricsColumns=[{
    label:'PermissionSet/Profile',
          type:'text',
          fieldName:'perType'
},{
    label:'Count Of Users',
           type:'number',
           fieldName:'countOfUsers'
}, {
    label: 'Downlaod User List', 
    type: 'button',
    typeAttributes:
    {label: { fieldName: 'actionLabel'}, title: 'Click to Download', name: 'download_status', iconName: 'utility:download',initialWidth: 250, class: 'btn_next'},cellAttributes:{ alignment: "center"}
}
];


@track PermissionSetTypes=[
    {
    label: 'Profile',
    value:'true'
},{
    label: 'PermissionSet',
    value:'false'
}];

@track permissionSetMetric=[];
 permdata=[];
 handleSelection(event){
    this.isDataLoaded=true;
    const valueSelected= event.detail.value;
    //console.log(valueSelected);
    this.isLoading = true;
getUsers({selectedType:valueSelected}).then(data=>{
    this.permdata=data;
    var datamap=[];
    //console.log('dsafsdf'+JSON.stringify(data, null, '\t'));
    for(var key in this.permdata) {
    //console.log('dsafsdf'+JSON.stringify(key, null, '\t'));
        datamap.push({perType:key,
                     countOfUsers:this.permdata[key].length,
                    id:key}); 
                    
                                }
        
        this.isLoading = false;
        this.permissionSetMetric=datamap;
        
        var count=1;
           var getselected=[];
           var dataforGraph=[];
           for(var key in this.permdata) {
               if(count<=4){
                getselected.push(key); 
                count=count+1;
                dataforGraph.push({
                    perType:key,
                    countOfUsers:this.permdata[key].length
                })
               }
               else{
                   break;
               }
           } 
this.preSelectedRows=getselected;
if(this.flag===true){   
     this.createChart(dataforGraph);
     this.flag=false;
}
                     
}).catch(error=>{

})
   
}


getSelectedName(event){
var selectRowdata= event.detail.selectedRows;
console.log('Selected Row'+JSON.stringify(selectRowdata, null, '\t'))
this.createChart(selectRowdata);
}
createChart(selectRowdata){
    let chartData = [];
    let chartLabels = [];
    selectRowdata.forEach(opp => {
        chartData.push(opp.countOfUsers); 
        chartLabels.push(opp.perType);
       });
       console.log('Heyyyyy'+JSON.stringify(chartData, null, '\t'));
       
       this.chartConfiguration = {
        type:'bar',
        data: {
         labels: chartLabels,
         datasets: [
          {
           //label: '',
           barPercentage: .5,
           barThickness: 5,
           maxBarThickness: 15,
           minBarLength: 2,
           backgroundColor: [this.getRandomColorHex(),this.getRandomColorHex(),this.getRandomColorHex(),
                                this.getRandomColorHex(),this.getRandomColorHex(),this.getRandomColorHex(),
                                this.getRandomColorHex(),this.getRandomColorHex(),this.getRandomColorHex(),],
           data: chartData,
          },
         ],
        },
        options: {
    
            responsive: true,
            maintainAspectRatio: true,
            scaleShowValues: true,
            scales: {
                        yAxes: [{
                             ticks: {
                                 beginAtZero: true
                                 }
                    }],
                        xAxes: [{
                             ticks: {
                                 autoSkip: false
                                },
                               
                            barPercentage: 0.4,
                            categoryPercentage: 1
                    }]
},
legend:{
 display:false,
}
        },
        
       };
       
      this.template.querySelector('c-chart').checkValue(this.chartConfiguration);
}

getRandomColorHex() {
    var hex = "0123456789ABCDEF",
        color = "#";
    for (var i = 1; i <= 6; i++) {
      color += hex[Math.floor(Math.random() * 16)];
    }
    return color;
  }
handleRowAction(event){
    let actionName = event.detail.action.name;
    var row= event.detail.row;
    var permissionSetTypeName=row.perType;
    var usersList=this.permdata[permissionSetTypeName];
    this.downloadCSVFile(usersList);
}
downloadCSVFile(Users) {
    var csvStringResult, counter, keys, columnDivider, lineDivider;
    if (Users == null || !Users.length) {
        return null;
    }
    columnDivider = ',';
    lineDivider =  '\n';
    keys = ['Id','FirstName','Email','FederationIdentifier','IsActive'];
    //console.log('qwerth'+keys);
    csvStringResult = '';
    csvStringResult += keys.join(columnDivider);
    csvStringResult += lineDivider;        
    for(var i=0; i < Users.length; i++){   
        counter = 0;
        for(var sTempkey in keys) {
            var skey = keys[sTempkey] ;  //console.log('qwerthKEY'+skey);
            if(counter > 0){ 
                csvStringResult += columnDivider; 
            }  
            if(Users[i]){
                if(Users[i][skey]){
                    
                    
                         csvStringResult += '"'+ Users[i][skey]+'"';  
                     
                }else{
                    csvStringResult += '"'+' '+'"';
                }
                
            }else{
                csvStringResult += '"'+' '+'"';
            }
            
            counter++;
            
        } 
        csvStringResult += lineDivider;

    } 
    //console.log('Heyyyy'+JSON.stringify(csvStringResult, null, '\t'));
     
    let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvStringResult);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'exportData.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
}
}