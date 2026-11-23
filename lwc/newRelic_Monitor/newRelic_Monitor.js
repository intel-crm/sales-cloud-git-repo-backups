import { LightningElement, track } from 'lwc';
import newrelic from '@salesforce/resourceUrl/newrelicmonitor';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class NewRelic_Monitor extends LightningElement {

   
    @track greeting = 'LearnFrenzy World';
    changeHandler(event) {
        this.greeting = event.target.value;
    }

    renderedCallback() {
        console.log('hello');
        
        loadScript(this, newrelic).then(() => {
            console.log('file loaded');
        });
        
/*
            let endPoint = newrelic;
            fetch(endPoint, {
              method: "GET",
              headers:{
                "mode": "no-cors",
                "Access-Control-Allow-Origin": '*'
            }
            })
              .then((response) => console.log('file loaded')); 
               response.json() gives us back a promise
              we need to process the promise in .then()*/
              /*.then((repos) => {
                this.repos = repos;
              });*/
       
              let endPoint = newrelic;
              fetch(endPoint, {
                mode: 'no-cors',
              })
                .then((response) => {
                  // This executes
                  if (!response.ok) {
                    // This executes
                    console.log(response);
                    throw Error(response);
                  } else {
                    // Handle Response
                    console.log(response);
                  }
                })
                .catch((error) => {
                  // This block executes because you are throwing an error
                  // in the if (!response.ok) block.
                  // If not, this block isnt executed.
                  console.log(error);
                });


    }
}