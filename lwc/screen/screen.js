import { LightningElement,track, api } from 'lwc';
import chartOpp from "@salesforce/apex/UCD_AccountDeactivation.chartOpp";
import chartAE from "@salesforce/apex/UCD_AccountDeactivation.chartAE";
import fetchReports from "@salesforce/apex/UCD_AccountDeactivation.combineChart";
//import { loadScript } from "lightning/platformResourceLoader";
//import chartjs from '@salesforce/resourceUrl/chartjs';
import { NavigationMixin } from 'lightning/navigation';

export default class Screen extends NavigationMixin(LightningElement) {
    

    selectedValue;
    oppValues;
    @track oppMap=[];
    @track showOpp = false;
    aeValues;
    @track aeMap=[];
    @track showae = false;

    @track chartConfiguration;
    get options() {
        return [
            { label: 'Opportunity Management', value: 'OpportunityManagement' },
            { label: 'A&E', value: 'a&e' },
            { label: 'PSG', value: 'psg' },
            { label: 'Channel Revenue', value: 'channelRevenue' },
            { label: 'IPA', value: 'ipa' }
        ]
    }

    handleChange(event){        
        this.selectedValue = event.target.value;
        if(this.selectedValue == 'OpportunityManagement'){
            chartOpp()
                .then((response) => {
                    let key;
                    let chartAmtData = [];
                    let chartLabel = [];
                    this.chartConfiguration = {};
                    this.oppValues = response;
                    //console.log('1111111'+JSON.stringify(this.oppValues));
                    this.showOpp=true;
                    this.showae=false;
                    for(key in this.oppValues){            
                        if (Object.prototype.hasOwnProperty.call(this.oppValues, key)) {
                             this.oppMap.push({value: this.oppValues[key], key:key});
                             chartAmtData.push(this.oppValues[key]);
                             chartLabel.push(key);
                        }
                    }
                    
                    console.log('chartAmtData',chartAmtData);

                    this.chartConfiguration = {
                        type: 'bar',
                        data: {
                            datasets: [{
                                    label: 'DQ Score',
                                    backgroundColor: "green",
                                    data: chartAmtData,
                                },
                            ],
                            labels: chartLabel,
                        },
                        options: {},
                    };
                    
                })
                .catch((error) => {
                  console.log(error);
                  // this.showsuccessToast(error,Error);
                });
        }
        else if(this.selectedValue == 'a&e'){
            chartAE()
                .then((response) => {
                    let key;
                    this.aeValues = response;
                    console.log('3333333'+JSON.stringify(this.aeValues));
                    this.showOpp=false;
                    this.showae=true;
                    for(key in this.aeValues){            
                        if (Object.prototype.hasOwnProperty.call(this.aeValues, key)) {
                             this.aeMap.push({value: this.aeValues[key], key:key});
                        }
                    }
                    console.log('4444444'+JSON.stringify(this.aeMap));
                })
                .catch((error) => {
                  console.log(error);
                  console.log('J132 ',error)
                  // this.showsuccessToast(error,Error);
                });
        }
    }

    // MULTISELECT


@api values = [ {label: 'Opportunity Management', value: 'OpportunityManagement' },
{ label: 'A&E', value: 'a&e' },
{ label: 'PSG', value: 'psg' },
{ label: 'Channel Revenue', value: 'channelRevenue' },
{ label: 'IPA', value: 'ipa' }];

@track
selectedvalues = [];

@api
picklistlabel = 'Account Type';

showdropdown;
handleleave() {
        
  let sddcheck= this.showdropdown;

  if(sddcheck){
      this.showdropdown = false;
      this.fetchSelectedValues();
  }
}

fetchSelectedValues() {
  
  this.selectedvalues = [];

  //get all the selected values
  this.template.querySelectorAll('c-picklist-value').forEach(
      element => {
          if(element.selected){
              console.log(element.value);
              this.selectedvalues.push(element.value);
          }
      }
  );

  //refresh original list
  this.refreshOrginalList();
}

refreshOrginalList() {
  //update the original value array to shown after close

  const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));

  picklistvalues.forEach((element, index) => {
      if(this.selectedvalues.includes(element.value)){
          picklistvalues[index].selected = true;
      }else{
          picklistvalues[index].selected = false;
      }
  });

  this.values = picklistvalues;
}

handleShowdropdown(){
  let sdd = this.showdropdown;
  if(sdd){
      this.showdropdown = false;
      this.fetchSelectedValues();
  }else{
      this.showdropdown = true;
  }
}

closePill(event){
  console.log(event.target.dataset.value);
  let selection = event.target.dataset.value;
  let selectedpills = this.selectedvalues;
  console.log(selectedpills);
  let pillIndex = selectedpills.indexOf(selection);
  console.log(pillIndex);
  this.selectedvalues.splice(pillIndex, 1);
  this.refreshOrginalList();
}

get selectedmessage() {
  return this.selectedvalues.length + ' values are selected';
}

@track combineReport = [];
@track loaded = false;
 fetchReports(){
     this.loaded=true;
     console.log('1111111'+this.selectedvalues);
     fetchReports({selectedTypes:this.selectedvalues})
        .then((response) => {
            this.combineReport=response;
            console.log('22222222 ',JSON.stringify(this.combineReport))
            
            let chartAmtData = [];
            let chartLabel = [];
            this.chartConfiguration = [];
            this.oppValues = response;
            this.showOpp=true;
            this.showae=false;

            this.oppValues.map(opp => {
                chartAmtData.push(opp['score']);                
                chartLabel.push(opp['acc'].Name);               
            })

           /* this.chartConfiguration = {
                type: 'bar',
                data: {
                    datasets: [{
                            axis: 'y',
                            label: 'DQ Score',
                            backgroundColor: "green",
                            data: chartAmtData,
                        },
                    ],
                    labels: chartLabel,
                },
                options: {
                    indexAxis: 'y',
                    scales: {
                        xAxes: [
                            {                                
                                ticks: {
                                    autoSkip: false
                                },
                            },
                        ],
                    },
                   
                },
            };*/

            this.chartConfiguration = {
                type: 'bar',
                data: {
                    datasets: [{
                            axis: 'y',
                            label: 'DQ Score',
                           // backgroundColor: "green",
                           backgroundColor: [
                            "rgba(255, 99, 132, 0.2)",
                            "rgba(54, 162, 235, 0.2)",
                            "rgba(255, 206, 86, 0.2)",
                            "rgba(75, 192, 192, 0.2)",
                            "rgba(153, 102, 255, 0.2)",
                            "rgba(255, 159, 64, 0.2)"
                          ],
                            data: chartAmtData,
                        },
                    ],
                    labels: chartLabel,
                },
                options: {
                    indexAxis: 'y',
                    scales: {
                        xAxes: [
                            {                                
                                ticks: {
                                    autoSkip: false
                                },
                            },
                        ],
                    },
                   
                },
            };

            this.showae=true;
            this.loaded=false;
        })
        .catch((error) => {
            console.log(error);
            
        });
 }
// @track combineReport = [];
 @track loaded = false;
 @track openModal = false;
 @track modalData = [];
 showModal(event) {
    console.log('nnnnnnnnnnnnnn',event.currentTarget.dataset.index);
    const itemindex = event.currentTarget.dataset.index;
    this.openModal = true;
    this.modalClass = 'slds-modal slds-fade-in-open';
    //this.modalData = event.detail.value;
    this.modalData = this.combineReport[itemindex].MissingData;
    console.log('vvvvvvvvvvv',this.modalData);
}
 closeModal() {
     this.openModal = false;
 }





}